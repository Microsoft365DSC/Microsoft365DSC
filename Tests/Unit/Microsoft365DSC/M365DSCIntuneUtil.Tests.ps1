BeforeAll {
    $Script:IntuneUtilModule = $null
    $Script:ErrorHandlerModule = $null
    $Script:DefinedStubs = @()
    if ($null -eq (Get-Module -Name 'Microsoft365DSC'))
    {
        $stubs = @{
            'Invoke-MgGraphRequest'                                        = { param ($Method, $Uri, $Body, $Message, $Exception, $Source, $TenantId, $Credential) }
            'New-M365DSCLogEntry'                                          = { param ($Method, $Uri, $Body, $Message, $Exception, $Source, $TenantId, $Credential) }
            'Get-MSCloudLoginConnectionProfile'                            = { param ($Workload) }
            'Get-MgBetaDeviceAppManagementMobileAppCategory'               = { param ($MobileAppCategoryId, $Filter) }
            'Get-MgBetaDeviceManagementTemplateCategory'                   = { param ($DeviceManagementTemplateId) }
            'Get-MgBetaDeviceManagementTemplateCategoryRecommendedSetting' = { param ($DeviceManagementTemplateId, $DeviceManagementTemplateSettingCategoryId) }
        }
        foreach ($stubName in $stubs.Keys)
        {
            if (-not (Test-Path -Path "Function:\$stubName"))
            {
                New-Item -Path "Function:\global:$stubName" -Value $stubs[$stubName] | Out-Null
                $Script:DefinedStubs += $stubName
            }
        }
        $graphStubs = @{
            'Get-MgGroup'                                 = { [CmdletBinding()] param ($GroupId, $Filter, $Property, [switch] $All) }
            'Get-MgBetaDeviceManagementAssignmentFilter' = { [CmdletBinding()] param ([switch] $All) }
        }
        foreach ($stubName in $graphStubs.Keys)
        {
            if (-not (Test-Path -Path "Function:\$stubName"))
            {
                New-Item -Path "Function:\global:$stubName" -Value $graphStubs[$stubName] | Out-Null
                $Script:DefinedStubs += $stubName
            }
        }
        $Script:ErrorHandlerModule = Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCErrorHandler.psm1" -Global -PassThru
        $Script:IntuneUtilModule = Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCIntuneUtil.psm1" -DisableNameChecking -PassThru
    }

    $Script:PolicyId = '9c1e2f4a-1111-4222-8333-944455556666'

    function New-TestGraphError
    {
        param ([System.String] $ErrorId, [System.Int32] $StatusCode = 0)

        $exception = [System.Exception]::new("Graph call failed: $ErrorId")
        if ($StatusCode -gt 0)
        {
            $exception = [Microsoft.PowerShell.Commands.HttpResponseException]::new("Graph call failed: $ErrorId", [System.Net.Http.HttpResponseMessage]::new($StatusCode))
        }
        return [System.Management.Automation.ErrorRecord]::new($exception, $ErrorId, [System.Management.Automation.ErrorCategory]::NotSpecified, $null)
    }
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

Describe 'Get-M365DSCIntuneGroup lookup errors' {
    Context 'When the group does not exist' {
        It 'Should return nothing for a <Name>' -ForEach @(
            @{ Name = 'Request_ResourceNotFound error'; ErrorId = 'Request_ResourceNotFound'; StatusCode = 0 }
            @{ Name = 'malformed id'; ErrorId = 'Request_BadRequest'; StatusCode = 0 }
            @{ Name = '404 response'; ErrorId = 'HttpError'; StatusCode = 404 }
        ) {
            $Script:GroupError = New-TestGraphError -ErrorId $ErrorId -StatusCode $StatusCode
            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith { throw $Script:GroupError }

            Get-M365DSCIntuneGroup -GroupId 'deleted' | Should -BeNullOrEmpty
        }
    }

    Context 'When the lookup fails for another reason' {
        It 'Should throw for a <Name>' -ForEach @(
            @{ Name = 'denied request'; ErrorId = 'Authorization_RequestDenied'; StatusCode = 0 }
            @{ Name = '403 response'; ErrorId = 'HttpError'; StatusCode = 403 }
            @{ Name = 'transport failure'; ErrorId = 'HttpError'; StatusCode = 0 }
        ) {
            $Script:GroupError = New-TestGraphError -ErrorId $ErrorId -StatusCode $StatusCode
            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith { throw $Script:GroupError }

            { Get-M365DSCIntuneGroup -GroupId 'g1' } | Should -Throw
            { Get-M365DSCIntuneGroup -DisplayName 'Group 1' } | Should -Throw
        }
    }
}

Describe 'Intune assignment group resolution' {
    BeforeEach {
        Mock -ModuleName M365DSCIntuneUtil -CommandName New-M365DSCLogEntry
        Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith {
            if ($GroupId -eq 'g1' -or $Filter -eq "displayName eq 'Group 1'") { return @{ Id = 'g1'; DisplayName = 'Group 1' } }
            if ($GroupId) { throw (New-TestGraphError -ErrorId 'Request_ResourceNotFound') }
        }
        Clear-M365DSCIntuneAssignmentFilterCache
    }

    It 'Should name the missing group id when the group was deleted' {
        $assignments = @(@{ dataType = '#microsoft.graph.groupAssignmentTarget'; groupId = 'deleted' })

        $result = ConvertTo-IntunePolicyAssignment -Assignments $assignments -WarningVariable warnings -WarningAction SilentlyContinue

        $result.Count | Should -Be 0
        $warnings | Should -HaveCount 1
        "$($warnings[0])" | Should -BeLike '*group with Id {deleted}*'
    }

    It 'Should resolve the group by display name when the id is unknown' {
        $assignments = @(@{ dataType = '#microsoft.graph.groupAssignmentTarget'; groupId = 'deleted'; groupDisplayName = 'Group 1' })

        $result = ConvertTo-IntuneMobileAppAssignment -Assignments $assignments

        $result[0].target.groupId | Should -Be 'g1'
    }

    Context 'When the group lookup is denied' {
        BeforeEach {
            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith {
                throw (New-TestGraphError -ErrorId 'Authorization_RequestDenied' -StatusCode 403)
            }
        }

        It 'Should throw instead of dropping or replacing the assignments' {
            $assignments = @(@{ dataType = '#microsoft.graph.groupAssignmentTarget'; groupId = 'g1' })

            { ConvertTo-IntunePolicyAssignment -Assignments $assignments } | Should -Throw
            { ConvertTo-IntuneMobileAppAssignment -Assignments $assignments } | Should -Throw

            $targets = @(@{ target = @{ '@odata.type' = '#microsoft.graph.groupAssignmentTarget'; groupId = 'g1' } })

            { Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $Script:PolicyId -Targets $targets } |
                Should -Throw -ExpectedMessage "Failed to update the assignments of policy {$($Script:PolicyId)}:*"
            { Update-DeviceAppManagementPolicyAssignment -AppManagementPolicyId $Script:PolicyId -Assignments @(@{ intent = 'required'; target = $targets[0].target }) } |
                Should -Throw -ExpectedMessage "Failed to update the assignments of policy {$($Script:PolicyId)}:*"

            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -Exactly -Times 0
        }
    }
}

Describe 'Update-DeviceAppManagementPolicyAssignment targets' {
    BeforeEach {
        Mock -ModuleName M365DSCIntuneUtil -CommandName New-M365DSCLogEntry
        Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest
    }

    It 'Should use the target of each assignment, whatever its type' {
        $assignments = @(
            @{ intent = 'required'; target = @{ '@odata.type' = '#microsoft.graph.allLicensedUsersAssignmentTarget' } }
            @{ intent = 'available'; target = [PSCustomObject]@{ '@odata.type' = '#microsoft.graph.allDevicesAssignmentTarget' } }
        )

        Update-DeviceAppManagementPolicyAssignment -AppManagementPolicyId $Script:PolicyId -Assignments $assignments

        Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -Exactly -Times 1 -ParameterFilter {
            ($Body | ConvertFrom-Json).mobileAppAssignments[1].target.'@odata.type' -eq '#microsoft.graph.allDevicesAssignmentTarget'
        }
    }
}

Describe 'Intune assignment filter cache' {
    BeforeEach {
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith { return @{ Id = 'g1'; DisplayName = 'Group 1' } }
        Clear-M365DSCIntuneAssignmentFilterCache
        $Script:FilteredAssignments = @(@{
                dataType                                          = '#microsoft.graph.groupAssignmentTarget'
                groupId                                           = 'g1'
                deviceAndAppManagementAssignmentFilterType        = 'include'
                deviceAndAppManagementAssignmentFilterId          = 'f1'
                deviceAndAppManagementAssignmentFilterDisplayName = 'Filter 1'
            })
    }

    It 'Should read the filters once for a tenant without filters' {
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter
        $assignments = @(@{ Target = @{ '@odata.type' = '#microsoft.graph.allDevicesAssignmentTarget' } })

        $null = ConvertFrom-IntunePolicyAssignment -Assignments $assignments
        $null = ConvertFrom-IntuneMobileAppAssignment -Assignments @(@{ intent = 'required'; Target = $assignments[0].Target })

        Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter -Exactly -Times 1
    }

    It 'Should read the filters again after a failed read' {
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter -MockWith { throw 'Forbidden' }
        $assignments = @(@{ Target = @{ '@odata.type' = '#microsoft.graph.allDevicesAssignmentTarget' } })

        { ConvertFrom-IntunePolicyAssignment -Assignments $assignments } | Should -Not -Throw
        { ConvertFrom-IntunePolicyAssignment -Assignments $assignments } | Should -Not -Throw

        Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter -Exactly -Times 2
    }

    It 'Should read the filters again for a filter created after they were cached' {
        $Script:FilterReads = 0
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter -MockWith {
            $Script:FilterReads++
            if ($Script:FilterReads -gt 1) { return @(@{ Id = 'f1'; DisplayName = 'Filter 1' }) }
        }

        $policyResult = ConvertTo-IntunePolicyAssignment -Assignments $Script:FilteredAssignments
        $appResult = ConvertTo-IntuneMobileAppAssignment -Assignments $Script:FilteredAssignments

        $policyResult[0].target.deviceAndAppManagementAssignmentFilterId | Should -Be 'f1'
        $appResult[0].target.deviceAndAppManagementAssignmentFilterId | Should -Be 'f1'
        Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter -Exactly -Times 2
    }

    It 'Should resolve the filter by display name when the id is unknown and its display name on export' {
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter -MockWith { return @(@{ Id = 'f2'; DisplayName = 'Filter 1' }) }
        $exportAssignments = @(@{ Target = @{ '@odata.type' = '#microsoft.graph.allDevicesAssignmentTarget'; DeviceAndAppManagementAssignmentFilterType = 'include'; DeviceAndAppManagementAssignmentFilterId = 'f2' } })

        $result = ConvertTo-IntunePolicyAssignment -Assignments $Script:FilteredAssignments
        $exportResult = ConvertFrom-IntunePolicyAssignment -Assignments $exportAssignments

        $result[0].target.deviceAndAppManagementAssignmentFilterId | Should -Be 'f2'
        $exportResult[0].deviceAndAppManagementAssignmentFilterDisplayName | Should -Be 'Filter 1'
    }

    It 'Should throw instead of assigning without an unknown filter' {
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter

        { ConvertTo-IntunePolicyAssignment -Assignments $Script:FilteredAssignments } | Should -Throw -ExpectedMessage '*could not be found*'
        { ConvertTo-IntuneMobileAppAssignment -Assignments $Script:FilteredAssignments } | Should -Throw -ExpectedMessage '*could not be found*'
    }

    It 'Should throw when the filters cannot be read' {
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter -MockWith { throw 'Forbidden' }

        { ConvertTo-IntunePolicyAssignment -Assignments $Script:FilteredAssignments } | Should -Throw -ExpectedMessage '*Forbidden*'
    }

    It 'Should not read the filters when no assignment uses one' {
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter
        $assignments = @(@{ dataType = '#microsoft.graph.allDevicesAssignmentTarget'; deviceAndAppManagementAssignmentFilterType = 'none' })

        $result = ConvertTo-IntunePolicyAssignment -Assignments $assignments

        $result[0].target.'@odata.type' | Should -Be '#microsoft.graph.allDevicesAssignmentTarget'
        Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementAssignmentFilter -Exactly -Times 0
    }
}
Describe 'Update-DeviceAppManagementAppCategory' {
    BeforeEach {
        Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            return @{ ResourceUrl = 'https://graph.microsoft.com/' }
        }
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceAppManagementMobileAppCategory -ParameterFilter { $MobileAppCategoryId -eq 'c1' } -MockWith {
            return [pscustomobject]@{ Id = 'c1'; DisplayName = 'One' }
        }
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceAppManagementMobileAppCategory -ParameterFilter { $Filter -eq "DisplayName eq 'Two'" } -MockWith {
            return [pscustomobject]@{ Id = 'c2'; DisplayName = 'Two' }
        }
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceAppManagementMobileAppCategory -ParameterFilter { $Filter -eq "DisplayName eq 'Dup'" } -MockWith {
            return @(
                [pscustomobject]@{ Id = 'd1'; DisplayName = 'Dup' },
                [pscustomobject]@{ Id = 'd2'; DisplayName = 'Dup' }
            )
        }
        $Script:App = [pscustomobject]@{ Id = 'app1'; Categories = @() }
    }

    Context 'When a category after the first has no Id' {
        It 'Should resolve each category on its own' {
            $categories = @(
                [pscustomobject]@{ Id = 'c1'; DisplayName = 'One' },
                [pscustomobject]@{ DisplayName = 'Two' }
            )

            Update-DeviceAppManagementAppCategory -App $Script:App -Categories $categories

            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -Exactly -Times 1 -ParameterFilter {
                $Method -eq 'POST' -and $Uri -eq '/beta/deviceAppManagement/mobileApps/app1/categories/$ref' -and
                $Body.'@odata.id' -eq 'https://graph.microsoft.com/beta/deviceAppManagement/mobileAppCategories/c1'
            }
            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -Exactly -Times 1 -ParameterFilter {
                $Method -eq 'POST' -and $Uri -eq '/beta/deviceAppManagement/mobileApps/app1/categories/$ref' -and
                $Body.'@odata.id' -eq 'https://graph.microsoft.com/beta/deviceAppManagement/mobileAppCategories/c2'
            }
        }
    }

    Context 'When the DisplayName matches several categories' {
        It 'Should throw instead of posting an invalid reference' {
            $categories = @([pscustomobject]@{ DisplayName = 'Dup' })

            { Update-DeviceAppManagementAppCategory -App $Script:App -Categories $categories } |
                Should -Throw -ExpectedMessage 'Multiple Mobile App Categories with DisplayName Dup found.'
            Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -Exactly -Times 0
        }
    }
}

Describe 'Get-M365DSCIntuneDeviceConfigurationSettings' {
    BeforeEach {
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementTemplateCategory -MockWith {
            return @(
                [pscustomobject]@{ Id = 'cat1' },
                [pscustomobject]@{ Id = 'cat2' }
            )
        }
        Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementTemplateCategoryRecommendedSetting -MockWith {
            return [pscustomobject]@{
                '@odata.type' = '#microsoft.graph.deviceManagementStringSettingInstance'
                Id            = "setting-$DeviceManagementTemplateSettingCategoryId"
                DefinitionId  = 'deviceConfiguration--policy_BlockEnabled'
                ValueJson     = '"default"'
            }
        }
    }

    It 'Should read the settings of every template category' {
        $result = Get-M365DSCIntuneDeviceConfigurationSettings -Properties @{} -TemplateId 'template1'

        $result.Count | Should -Be 2
        Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementTemplateCategoryRecommendedSetting -Exactly -Times 1 -ParameterFilter {
            $DeviceManagementTemplateSettingCategoryId -eq 'cat1'
        }
        Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Get-MgBetaDeviceManagementTemplateCategoryRecommendedSetting -Exactly -Times 1 -ParameterFilter {
            $DeviceManagementTemplateSettingCategoryId -eq 'cat2'
        }
    }
}

Describe 'Remove-ComplexFunctionsFromFilterQuery' {
    BeforeEach {
        Mock -ModuleName M365DSCIntuneUtil -CommandName Write-Warning
    }

    It 'Should return <Expected> for <Query>' -ForEach @(
        @{ Query = "displayName eq 'a' and startswith(displayName,'b') and platforms eq 'c'"; Expected = "displayName eq 'a' and platforms eq 'c'" }
        @{ Query = "startswith(displayName,'b') and platforms eq 'c'"; Expected = "platforms eq 'c'" }
        @{ Query = "platforms eq 'c' and endswith(displayName,'b')"; Expected = "platforms eq 'c'" }
        @{ Query = "displayName eq 'a' or contains(displayName,'b')"; Expected = "displayName eq 'a'" }
        @{ Query = "startswith(displayName,'b')"; Expected = '' }
        @{ Query = "startswith(displayName,'a') and endswith(displayName,'b')"; Expected = '' }
        @{ Query = "(startswith(displayName,'a') or contains(displayName,'b')) and platforms eq 'c'"; Expected = "platforms eq 'c'" }
        @{ Query = "displayName eq 'foo()'"; Expected = "displayName eq 'foo()'" }
        @{ Query = "displayName eq 'Win ( ) Baseline'"; Expected = "displayName eq 'Win ( ) Baseline'" }
        @{ Query = "displayName eq 'Win ( ) Baseline' and startswith(displayName,'b')"; Expected = "displayName eq 'Win ( ) Baseline'" }
        @{ Query = "((startswith(displayName,'b'))) and platforms eq 'c'"; Expected = "platforms eq 'c'" }
        @{ Query = "platforms eq 'c' and (startswith(displayName,'b'))"; Expected = "platforms eq 'c'" }
    ) {
        Remove-ComplexFunctionsFromFilterQuery -FilterQuery $Query | Should -BeExactly $Expected
    }

    It 'Should warn only when a function is combined with or' {
        $null = Remove-ComplexFunctionsFromFilterQuery -FilterQuery "displayName eq 'a' and startswith(displayName,'b')"
        Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Write-Warning -Exactly -Times 0

        $null = Remove-ComplexFunctionsFromFilterQuery -FilterQuery "displayName eq 'a' or startswith(displayName,'b')"
        Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Write-Warning -Exactly -Times 1
    }
}

Describe 'Find-GraphDataUsingComplexFunctions' {
    BeforeAll {
        $Script:Policies = @(
            [pscustomobject]@{ displayName = '[Win] Baseline' },
            [pscustomobject]@{ displayName = 'Win Baseline' },
            [pscustomobject]@{ displayName = "O'Brien policy" },
            [pscustomobject]@{ displayName = 'Policy *' }
        )
    }

    It 'Should treat brackets and wildcards in the value literally and ignore case' {
        $result = Find-GraphDataUsingComplexFunctions -Policies $Script:Policies -ComplexFunctions @("startswith(displayName,'[Win]')")
        @($result).displayName | Should -Be @('[Win] Baseline')

        $result = Find-GraphDataUsingComplexFunctions -Policies $Script:Policies -ComplexFunctions @("endswith( displayName ,'*')")
        @($result).displayName | Should -Be @('Policy *')

        $result = Find-GraphDataUsingComplexFunctions -Policies $Script:Policies -ComplexFunctions @("contains(displayName,'baseline')")
        @($result).Count | Should -Be 2
    }

    It 'Should unescape doubled single quotes' {
        $complexFunctions = Get-ComplexFunctionsFromFilterQuery -FilterQuery "startswith(displayName,'o''brien')"
        $result = Find-GraphDataUsingComplexFunctions -Policies $Script:Policies -ComplexFunctions $complexFunctions

        @($result).displayName | Should -Be @("O'Brien policy")
    }
}

Describe 'Wait-ForFileProcessing' {
    BeforeEach {
        Mock -ModuleName M365DSCIntuneUtil -CommandName Start-Sleep
    }

    It 'Should throw on a timed out state' {
        Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -MockWith {
            return @{ uploadState = 'commitFileTimedOut' }
        }

        { Wait-ForFileProcessing -AppId 'app1' -OdataType 'microsoft.graph.iosLobApp' -FileId 'f1' -ContentVersionId '1' -UploadStatePrefix 'CommitFile' } |
            Should -Throw -ExpectedMessage '*commitFileTimedOut*'
    }

    It 'Should throw after the attempt limit when the state never changes' {
        Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -MockWith {
            return @{ uploadState = 'commitFilePending' }
        }

        { Wait-ForFileProcessing -AppId 'app1' -OdataType 'microsoft.graph.iosLobApp' -FileId 'f1' -ContentVersionId '1' -UploadStatePrefix 'CommitFile' } |
            Should -Throw -ExpectedMessage 'File processing did not reach CommitFileSuccess after 120 attempts (last state: commitFilePending).'
    }

    It 'Should return the file once the success state is reached' {
        $Script:uploadStates = @('commitFilePending', 'transientError', 'commitFileSuccess')
        $Script:uploadStateIndex = 0
        Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -MockWith {
            return @{ uploadState = $Script:uploadStates[$Script:uploadStateIndex++] }
        }

        $file = Wait-ForFileProcessing -AppId 'app1' -OdataType 'microsoft.graph.iosLobApp' -FileId 'f1' -ContentVersionId '1' -UploadStatePrefix 'CommitFile'

        $file.uploadState | Should -Be 'commitFileSuccess'
    }
}

Describe 'Invoke-M365DSCIntuneMobileAppInitialUpload' {
    BeforeEach {
        Mock -ModuleName M365DSCIntuneUtil -CommandName Start-Sleep
        Mock -ModuleName M365DSCIntuneUtil -CommandName Write-Warning
        Mock -ModuleName M365DSCIntuneUtil -CommandName Write-Verbose
        Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-RestMethod
        Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -MockWith {
            if ($Method -eq 'GET')
            {
                return @{ id = 'f1'; uploadState = 'azureStorageUriRequestSuccess'; azureStorageUri = 'https://storage.example/blob?sv=1&sig=secret' }
            }
            return @{ id = '1' }
        }
        Mock -ModuleName M365DSCIntuneUtil -CommandName Invoke-WebRequest -MockWith {
            throw 'Forbidden'
        }
    }

    It 'Should stop after five failed uploads without committing the file or logging the SAS token' {
        { Invoke-M365DSCIntuneMobileAppInitialUpload -AppId 'app1' -OdataType '#microsoft.graph.iosLobApp' -FileExtension 'ipa' } |
            Should -Throw -ExpectedMessage 'Failed to upload the initial content of app {app1} to Azure Storage after 5 attempts.'

        Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Invoke-WebRequest -Exactly -Times 5
        Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Invoke-RestMethod -Exactly -Times 0
        Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Invoke-MgGraphRequest -Exactly -Times 0 -ParameterFilter { $Uri -like '*/commit' }
        Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Write-Verbose -ParameterFilter { $Message -eq 'Uploading file to Azure Storage: https://storage.example/blob' }
        Should -Invoke -ModuleName M365DSCIntuneUtil -CommandName Write-Verbose -Exactly -Times 0 -ParameterFilter { $Message -like '*sig=*' }
    }
}
