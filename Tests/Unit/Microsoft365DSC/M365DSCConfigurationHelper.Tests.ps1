BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCConfigurationHelper.psm1" -Force

    Mock -ModuleName 'M365DSCConfigurationHelper' -CommandName ConvertTo-DSCObject -MockWith {
        @(
            @{ ResourceName = 'AADGroup' }
            @{ ResourceName = 'AADGroup' }
            @{ ResourceName = 'AADUser' }
        )
    }

    $script:ConfigurationPath = Join-Path $TestDrive 'M365TenantConfig.ps1'
    Set-Content -Path $script:ConfigurationPath -Value '# placeholder'
}

Describe 'Get-M365DSCEvaluationRulesForConfiguration' {
    Context 'Parameter sets' {
        It 'binds to Plaintext without OutputPath and returns the rules' {
            $result = Get-M365DSCEvaluationRulesForConfiguration -ConfigurationPath $script:ConfigurationPath -ConnectionMode 'ManagedIdentity'

            $result | Should -BeOfType [System.String]
            $result | Should -Match "M365DSCRuleEvaluation 'AADGroup'"
            $result | Should -Match "ResourceTypeName\s+= 'AADGroup'"
            $result | Should -Match '-eq 2'
            $result | Should -Match "M365DSCRuleEvaluation 'AADUser'"
            $result | Should -Match '-eq 1'
            $result | Should -Match 'ManagedIdentity\s+= \$true'
            $result | Should -Match 'TenantId\s+= \$ConfigurationData\.NonNodeData\.OrganizationName'
        }

        It 'binds to Configuration with OutputPath and writes the file' {
            $outputPath = Join-Path $TestDrive 'Rules.ps1'

            $result = Get-M365DSCEvaluationRulesForConfiguration -ConfigurationPath $script:ConfigurationPath -ConnectionMode 'ManagedIdentity' -OutputPath $outputPath

            $result | Should -BeNullOrEmpty
            Test-Path -Path $outputPath | Should -BeTrue
            Get-Content -Path $outputPath -Raw | Should -Match "M365DSCRuleEvaluation 'AADGroup'"
        }
    }

    Context 'Authentication' {
        It 'emits ApplicationSecret for ServicePrincipalWithSecret' {
            $result = Get-M365DSCEvaluationRulesForConfiguration -ConfigurationPath $script:ConfigurationPath -ConnectionMode 'ServicePrincipalWithSecret'

            $result | Should -Match 'ApplicationSecret\s+= New-Object System\.Management\.Automation\.PSCredential'
            $result | Should -Match '\$ConfigurationData\.NonNodeData\.ApplicationSecret'
            $result | Should -Not -Match 'CertificatePassword'
        }

        It 'emits the exported certificate password variable for ServicePrincipalWithPath' {
            $result = Get-M365DSCEvaluationRulesForConfiguration -ConfigurationPath $script:ConfigurationPath -ConnectionMode 'ServicePrincipalWithPath'

            $result | Should -Match 'CertificatePath\s+= \$ConfigurationData\.NonNodeData\.CertificatePath'
            $result | Should -Match 'CertificatePassword\s+= \$CredsCertificatePassword'
        }

        It 'writes a parseable configuration for <ConnectionMode>' -ForEach @(
            @{ ConnectionMode = 'ServicePrincipalWithThumbprint'; ParameterName = $null }
            @{ ConnectionMode = 'ServicePrincipalWithSecret'; ParameterName = $null }
            @{ ConnectionMode = 'ServicePrincipalWithPath'; ParameterName = 'CertificatePassword' }
            @{ ConnectionMode = 'CredentialsWithTenantId'; ParameterName = 'Credential' }
            @{ ConnectionMode = 'CredentialsWithApplicationId'; ParameterName = 'Credential' }
            @{ ConnectionMode = 'Credentials'; ParameterName = 'Credential' }
            @{ ConnectionMode = 'ManagedIdentity'; ParameterName = $null }
        ) {
            $outputPath = Join-Path $TestDrive "$ConnectionMode.ps1"

            Get-M365DSCEvaluationRulesForConfiguration -ConfigurationPath $script:ConfigurationPath -ConnectionMode $ConnectionMode -OutputPath $outputPath

            $tokens = $null
            $parseErrors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($outputPath, [ref]$tokens, [ref]$parseErrors)
            # The parser validates the resource schema when Microsoft365DSC is resolvable; tolerate only its absence.
            $parseErrors | Where-Object -FilterScript { $_.ErrorId -ne 'ModuleNotFoundDuringParse' } | Should -BeNullOrEmpty

            $content = Get-Content -Path $outputPath -Raw
            if ($ParameterName)
            {
                $ast.ParamBlock.Parameters.Name.VariablePath.UserPath | Should -Be $ParameterName
                $content | Should -Match "M365TenantConfig -ConfigurationData \.\\ConfigurationData\.psd1 -$ParameterName \`$$ParameterName"
                $content | Should -Match 'Get-Credential'
            }
            else
            {
                $ast.ParamBlock.Parameters | Should -BeNullOrEmpty
                $content | Should -Not -Match 'Get-Credential'
            }
        }
    }
}
