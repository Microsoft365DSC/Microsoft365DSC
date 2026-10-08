[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
                        -ChildPath '..\..\Unit' `
                        -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
            -ChildPath '\Stubs\Microsoft365.psm1' `
            -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
    -ChildPath '\Stubs\Generic.psm1' `
    -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\UnitTestHelper.psm1' `
        -Resolve)

$CurrentScriptPath = $PSCommandPath.Split('\')
$CurrentScriptName = $CurrentScriptPath[$CurrentScriptPath.Length -1]
$ResourceName      = $CurrentScriptName.Split('.')[1]
$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource $ResourceName -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Get-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -MockWith {
                return @{
                    Id = "12345-67890"
                    DisplayName = "Contoso Root CA"
                    Description = "Trusted CAs from Contoso"
                }
            }

            Mock -CommandName Get-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfigurationTrustedCertificateAuthority -MockWith {
                return @(
                    @{
                        Certificate = "MIIC..."
                        IsRootAuthority = $true
                        Issuer = "CN=Contoso Root CA"
                        IssuerSubjectKeyIdentifier = "ABC123"
                    }
                )
            }

            Mock -Command New-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -MockWith {
                return @{ Id = "new-12345" }
            }

            Mock -Command Update-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -MockWith {
            }

            Mock -Command Remove-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -MockWith {
            }

            Mock -Command New-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfigurationTrustedCertificateAuthority -MockWith {
            }

            Mock -Command Update-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfigurationTrustedCertificateAuthority -MockWith {
            }

            Mock -Command Remove-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfigurationTrustedCertificateAuthority -MockWith {
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            function New-TestTrustedCA
            {
                param(
                    [byte[]] $CertificateBytes,
                    [bool] $IsRoot,
                    [string] $Issuer = $null,
                    [string] $IssuerSubjectKeyIdentifier = $null
                )

                return [pscustomobject]@{
                    Certificate                = [System.Convert]::ToBase64String($CertificateBytes)
                    IsRootAuthority            = $IsRoot
                    Issuer                     = $Issuer
                    IssuerSubjectKeyIdentifier = $IssuerSubjectKeyIdentifier
                }
            }
        }

        # Test contexts
        Context -Name "The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = "Contoso Root CA"
                    Description = "Trusted CAs from Contoso"
                    Ensure = 'Present'
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -MockWith {
                    return $null
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADCertificateBasedApplicationConfiguration' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCertificateBasedApplicationConfiguration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCertificateBasedApplicationConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -Exactly 1
            }
        }

        Context -Name "Creating trusted CA sends public key data" -Fixture {
            BeforeAll {
                Mock -CommandName Get-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -MockWith { return $null }

                $testParams = @{
                    DisplayName = "Contoso Root CA"
                    Description = "Trusted CAs from Contoso"
                    Ensure = 'Present'
                    Credential = $Credential
                    TrustedCertificateAuthorities = @(
                        (New-TestTrustedCA -CertificateBytes ([System.Text.Encoding]::UTF8.GetBytes("publickeydata")) -IsRoot $true)
                    )
                }

                $script:expectedCert = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("publickeydata"))
            }

            It 'Should send certificate data to the trusted CA creation command' {
                (New-M365DSCResourceInstance -ResourceName 'AADCertificateBasedApplicationConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -Exactly 1 -ParameterFilter {
                    $BodyParameter.trustedCertificateAuthorities.Count -eq 1 -and
                    $BodyParameter.trustedCertificateAuthorities[0].certificate -eq $script:expectedCert -and
                    $BodyParameter.trustedCertificateAuthorities[0].isRootAuthority -eq $true
                }
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = "Contoso Root CA"
                    Description = "Trusted CAs from Contoso"
                    Ensure = 'Absent'
                    Credential = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADCertificateBasedApplicationConfiguration' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCertificateBasedApplicationConfiguration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCertificateBasedApplicationConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -Exactly 1
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = "Contoso Root CA"
                    Description = "Trusted CAs from Contoso"
                    Ensure = 'Present'
                    Credential = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCertificateBasedApplicationConfiguration' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "Trusted certificate authority details include public key and root flag" -Fixture {
            BeforeAll {
                Mock -CommandName Get-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfigurationTrustedCertificateAuthority -MockWith {
                    return @(
                        @{
                            Certificate = [System.Text.Encoding]::UTF8.GetBytes("publickeydata")
                            IsRootAuthority = $true
                            Issuer = "CN=Contoso Root CA"
                            IssuerSubjectKeyIdentifier = "ABC123"
                        }
                    )
                }

                $testParams = @{
                    DisplayName = "Contoso Root CA"
                    Description = "Trusted CAs from Contoso"
                    Ensure = 'Present'
                    Credential = $Credential
                }
            }

            It 'Should return base64 encoded certificate and root flag from Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADCertificateBasedApplicationConfiguration' -Property $testParams).Get().ToHashtable()
                $result.TrustedCertificateAuthorities | Should -Not -BeNullOrEmpty
                $result.TrustedCertificateAuthorities[0].Certificate | Should -Be ([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("publickeydata")))
                $result.TrustedCertificateAuthorities[0].IsRootAuthority | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = "Contoso Root CA"
                    Description = "UPDATED Description"  # Drift
                    Ensure = 'Present'
                    Credential = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADCertificateBasedApplicationConfiguration' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCertificateBasedApplicationConfiguration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCertificateBasedApplicationConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -Exactly 1
            }
        }

        Context -Name "Trusted CA drift updates certificate payload" -Fixture {
            BeforeAll {
                Mock -CommandName Get-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -MockWith {
                    return @{
                        Id = "12345-67890"
                        DisplayName = "Contoso Root CA"
                        Description = "Trusted CAs from Contoso"
                    }
                }

                Mock -CommandName Get-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfigurationTrustedCertificateAuthority -MockWith {
                    return @(
                        [PSCustomObject]@{
                            Id = "ca-id"
                            Certificate = [System.Text.Encoding]::UTF8.GetBytes("publickeydata")
                            IsRootAuthority = $true
                            Issuer = "CN=Contoso Root CA"
                            IssuerSubjectKeyIdentifier = "ABC123"
                        }
                    )
                }

                $testParams = @{
                    DisplayName = "Contoso Root CA"
                    Description = "Trusted CAs from Contoso"
                    Ensure = 'Present'
                    Credential = $Credential
                    TrustedCertificateAuthorities = @(
                        (New-TestTrustedCA -CertificateBytes ([System.Text.Encoding]::UTF8.GetBytes("publickeydata")) -IsRoot $false -Issuer "CN=Contoso Root CA" -IssuerSubjectKeyIdentifier "ABC123")
                    )
                }

                $script:expectedCertUpdate = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("publickeydata"))
            }

            It 'Should call update for trusted CA with certificate payload' {
                (New-M365DSCResourceInstance -ResourceName 'AADCertificateBasedApplicationConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfigurationTrustedCertificateAuthority -Exactly 1 -ParameterFilter {
                    $BodyParameter.Certificate -eq $script:expectedCertUpdate -and
                    $BodyParameter.IsRootAuthority -eq $false
                }
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"

                Mock -CommandName Get-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfiguration -MockWith {
                    return @(
                        [PSCustomObject]@{
                            Id          = "12345-67890"
                            DisplayName = "Contoso Root CA"
                            Description = "Trusted CAs from Contoso"
                        }
                    )
                }

                Mock -CommandName Get-MgBetaDirectoryCertificateAuthorityCertificateBasedApplicationConfigurationTrustedCertificateAuthority -MockWith {
                    return @(
                        [PSCustomObject]@{
                            Certificate = [System.Text.Encoding]::UTF8.GetBytes("exportpublickey")
                            IsRootAuthority = $true
                            Issuer = "CN=Contoso Root CA"
                            IssuerSubjectKeyIdentifier = "ABC123"
                        }
                    )
                }

                Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
                    return 'ExportBlock'
                }

                Mock -CommandName Save-M365DSCPartialExport -MockWith {
                }

                $script:expectedExportCert = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("exportpublickey"))

                $testParams = @{
                    Credential = $Credential
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $exportErr = $null
                $result = $null
                try
                {
                    $result = Invoke-M365DSCResourceMethod -ResourceName 'AADCertificateBasedApplicationConfiguration' -MethodName 'Export' -Parameters $testParams
                }
                catch
                {
                    $exportErr = $_
                }

                $result | Should -Not -BeNullOrEmpty -Because $exportErr
                Should -Invoke -CommandName Get-M365DSCExportContentForResource -Exactly 1 -ParameterFilter {
                    ($Results.TrustedCertificateAuthorities -match $script:expectedExportCert) -and
                    ($Results.TrustedCertificateAuthorities -match 'IsRootAuthority')
                }
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
