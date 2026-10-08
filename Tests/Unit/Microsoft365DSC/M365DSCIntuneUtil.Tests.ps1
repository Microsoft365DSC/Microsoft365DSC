BeforeAll {
    $Script:IntuneUtilModule = $null
    $Script:ErrorHandlerModule = $null
    $Script:DefinedStubs = @()
    if ($null -eq (Get-Module -Name 'Microsoft365DSC'))
    {
        foreach ($stubName in @('Invoke-MgGraphRequest', 'New-M365DSCLogEntry'))
        {
            if (-not (Test-Path -Path "Function:\$stubName"))
            {
                New-Item -Path "Function:\global:$stubName" -Value { param ($Method, $Uri, $Body, $Message, $Exception, $Source, $TenantId, $Credential) } | Out-Null
                $Script:DefinedStubs += $stubName
            }
        }
        $Script:ErrorHandlerModule = Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCErrorHandler.psm1" -Global -PassThru
        $Script:IntuneUtilModule = Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCIntuneUtil.psm1" -DisableNameChecking -PassThru
    }

    $Script:PolicyId = '9c1e2f4a-1111-4222-8333-944455556666'
}

AfterAll {
    if ($null -ne $Script:IntuneUtilModule)
    {
        Remove-Module -ModuleInfo $Script:IntuneUtilModule -Force -ErrorAction SilentlyContinue
    }
    if ($null -ne $Script:ErrorHandlerModule)
    {
        Remove-Module -ModuleInfo $Script:ErrorHandlerModule -Force -ErrorAction SilentlyContinue
    }
    foreach ($stubName in $Script:DefinedStubs)
    {
        Remove-Item -Path "Function:\global:$stubName" -ErrorAction SilentlyContinue
    }
}

Describe 'Update-DeviceConfigurationPolicyAssignment' {
    BeforeEach {
        Mock -ModuleName M365DSCIntuneUtil -CommandName New-M365DSCLogEntry
        Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest
    }

    Context 'When Graph accepts the assignments' {
        It 'Should post the assignments to the policy' {
            $targets = @(@{ dataType = '#microsoft.graph.allDevicesAssignmentTarget' })

            { Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $Script:PolicyId -Targets $targets } | Should -Not -Throw

            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -Exactly -Times 1 -ParameterFilter {
                $Method -eq 'POST' -and $Uri -eq "/beta/deviceManagement/configurationPolicies/$($Script:PolicyId)/assign"
            }
            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName New-M365DSCLogEntry -Exactly -Times 0
        }
    }

    Context 'When Graph rejects the assignments' {
        BeforeEach {
            Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -MockWith {
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    [System.Exception]::new('Response status code does not indicate success: BadRequest (Bad Request).'),
                    'GraphRequestFailed',
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $null
                )
                $errorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new('{"error":{"code":"NotSupported","message":"Assigning Entra groups is not supported for this policy."}}')
                throw $errorRecord
            }
        }

        It 'Should throw an error naming the policy and the service error' {
            $targets = @(@{ dataType = '#microsoft.graph.allDevicesAssignmentTarget' })

            { Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $Script:PolicyId -Targets $targets } |
                Should -Throw -ExpectedMessage "Failed to update the assignments of policy {$($Script:PolicyId)}:*NotSupported*"

            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName New-M365DSCLogEntry -Exactly -Times 1
        }
    }
}

Describe 'Update-DeviceAppManagementPolicyAssignment' {
    BeforeEach {
        Mock -ModuleName M365DSCIntuneUtil -CommandName New-M365DSCLogEntry
        Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest
    }

    Context 'When Graph accepts the assignments' {
        It 'Should post the assignments to the app' {
            $assignments = @(@{
                    intent = 'required'
                    target = @{ '@odata.type' = '#microsoft.graph.allLicensedUsersAssignmentTarget' }
                })

            { Update-DeviceAppManagementPolicyAssignment -AppManagementPolicyId $Script:PolicyId -Assignments $assignments } | Should -Not -Throw

            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -Exactly -Times 1 -ParameterFilter {
                $Method -eq 'POST' -and $Uri -eq "/beta/deviceAppManagement/mobileApps/$($Script:PolicyId)/assign"
            }
            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName New-M365DSCLogEntry -Exactly -Times 0
        }
    }

    Context 'When Graph rejects the assignments' {
        BeforeEach {
            Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -MockWith {
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    [System.Exception]::new('Response status code does not indicate success: BadRequest (Bad Request).'),
                    'GraphRequestFailed',
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $null
                )
                $errorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new('{"error":{"code":"NotSupported","message":"Assigning Entra groups is not supported for this policy."}}')
                throw $errorRecord
            }
        }

        It 'Should throw an error naming the app and the service error' {
            $assignments = @(@{
                    intent = 'required'
                    target = @{ '@odata.type' = '#microsoft.graph.allLicensedUsersAssignmentTarget' }
                })

            { Update-DeviceAppManagementPolicyAssignment -AppManagementPolicyId $Script:PolicyId -Assignments $assignments } |
                Should -Throw -ExpectedMessage "Failed to update the assignments of policy {$($Script:PolicyId)}:*NotSupported*"

            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName New-M365DSCLogEntry -Exactly -Times 1
        }
    }
}

Describe 'Wait-M365DSCIntuneMobileAppPublished' {
    BeforeEach {
        Mock -ModuleName M365DSCErrorHandler -CommandName Start-Sleep
    }

    Context 'When the app is already published' {
        BeforeEach {
            Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -MockWith {
                return @{ publishingState = 'published' }
            }
        }

        It 'Should read the publishing state once without waiting' {
            Wait-M365DSCIntuneMobileAppPublished -AppId $Script:PolicyId

            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -Exactly -Times 1 -ParameterFilter {
                $Method -eq 'GET' -and $Uri -eq "/beta/deviceAppManagement/mobileApps/$($Script:PolicyId)?`$select=publishingState"
            }
            Should -Invoke -ModuleName M365DSCErrorHandler -CommandName Start-Sleep -Exactly -Times 0
        }
    }

    Context 'When the app is still processing' {
        BeforeEach {
            $Script:publishingStates = @('processing', 'processing', 'published')
            $Script:stateIndex = 0
            Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -MockWith {
                return @{ publishingState = $Script:publishingStates[$Script:stateIndex++] }
            }
        }

        It 'Should read the publishing state until the app is published' {
            Wait-M365DSCIntuneMobileAppPublished -AppId $Script:PolicyId -RetryDelayInSeconds 0

            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -Exactly -Times 3
        }
    }
}