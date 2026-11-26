BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Microsoft365DSC.psd1" -Global

    $missingFunctions = @(@('New-SelfSignedCertificate', 'Export-PfxCertificate') | Where-Object -FilterScript { -not (Test-Path -Path "Function:\$_") })
    if ($missingFunctions.Count -gt 0)
    {
        Import-Module -Name "$PSScriptRoot/../Stubs/Generic.psm1" -Function $missingFunctions -Global -WarningAction SilentlyContinue
    }
}

Describe 'M365DSCAgent' {
    Context 'Test-M365DSCAgent' {
        BeforeEach {
            Mock -ModuleName M365DSCAgent -CommandName Add-M365DSCTelemetryEvent -MockWith {}
            Mock -ModuleName M365DSCAgent -CommandName WinRM -MockWith {}
            Mock -ModuleName M365DSCAgent -CommandName Write-Progress -MockWith {}
            Mock -ModuleName M365DSCAgent -CommandName Get-Item -MockWith { [PSCustomObject]@{ Value = 500 } }
            Mock -ModuleName M365DSCAgent -CommandName Update-M365DSCDependencies -MockWith {
                @(
                    [PSCustomObject]@{ ModuleName = 'Test.First'; RequiredVersion = '1.0.0' }
                    [PSCustomObject]@{ ModuleName = 'Test.Second'; RequiredVersion = '2.0.0' }
                )
            }
        }

        It 'Numbers every issue and starts the recommendations on their own line' {
            Test-M365DSCAgent -ErrorVariable agentErrors -ErrorAction SilentlyContinue -WarningVariable agentWarnings -WarningAction SilentlyContinue 2>$null

            $agentErrors[0].Exception.Message | Should -Match '\[1/\d\] '
            $agentErrors[0].Exception.Message | Should -Match '\[2/\d\] '
            $agentErrors[0].Exception.Message | Should -Match 'Test\.Second'
            $agentWarnings[0].Message | Should -BeLike "*addressing those: `r`n    [[]1/1] *"
        }
    }

    Context 'Set-M365DSCAgentCertificateConfiguration' {
        BeforeEach {
            $Script:OriginalTemp = $env:TEMP
            $env:TEMP = $TestDrive
            $Script:LcmConfigContent = $null

            Mock -ModuleName M365DSCAgent -CommandName Write-Host -MockWith {}
            Mock -ModuleName M365DSCAgent -CommandName New-SelfSignedCertificate -MockWith {}
            Mock -ModuleName M365DSCAgent -CommandName Export-PfxCertificate -MockWith {}
            # Capture the LCM meta-configuration and write an empty script
            Mock -ModuleName M365DSCAgent -CommandName Out-File -MockWith {
                $Script:LcmConfigContent = [System.String]$InputObject
                Set-Content -Path $FilePath -Value ''
            }
            Mock -ModuleName M365DSCAgent -CommandName Get-ChildItem -ParameterFilter { "$Path" -like 'Cert:*' } -MockWith {
                @(
                    [PSCustomObject]@{ Subject = 'CN=M365DSCEncryptionCert'; Thumbprint = 'OLDTHUMBPRINT'; NotAfter = (Get-Date).AddYears(1); PSPath = 'Cert:\LocalMachine\My\OLDTHUMBPRINT' }
                    [PSCustomObject]@{ Subject = 'CN=M365DSCEncryptionCert'; Thumbprint = 'NEWTHUMBPRINT'; NotAfter = (Get-Date).AddYears(9); PSPath = 'Cert:\LocalMachine\My\NEWTHUMBPRINT' }
                )
            }
        }

        AfterEach {
            $env:TEMP = $Script:OriginalTemp
        }

        It 'Uses only the newest certificate when several match' {
            $thumbprint = Set-M365DSCAgentCertificateConfiguration

            $thumbprint | Should -Be 'NEWTHUMBPRINT'
            $Script:LcmConfigContent | Should -Match "CertificateID = 'NEWTHUMBPRINT'"
        }

        It 'Fails before configuring the LCM when GeneratePFX is used with an existing certificate' {
            { Set-M365DSCAgentCertificateConfiguration -GeneratePFX -Password 'Test!P@ss' } |
                Should -Throw 'GeneratePFX requires either no certificate to exist or the -ForceRenew parameter.'

            Should -Invoke -ModuleName M365DSCAgent -CommandName Out-File -Times 0 -Exactly
        }

        It 'Warns when GeneratePFX relies on the default password' {
            $pfxError = $null
            try
            {
                Set-M365DSCAgentCertificateConfiguration -GeneratePFX -WarningVariable pfxWarnings -WarningAction SilentlyContinue
            }
            catch
            {
                $pfxError = $_
            }

            $pfxError | Should -Not -BeNullOrEmpty -Because 'a certificate already exists'
            $pfxWarnings | Should -HaveCount 1
            $pfxWarnings[0].Message | Should -BeLike '*with a default password*'

            Set-M365DSCAgentCertificateConfiguration -WarningVariable noPfxWarnings -WarningAction SilentlyContinue | Out-Null
            $noPfxWarnings | Should -BeNullOrEmpty
        }
    }
}
