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

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource 'AADPermissionGrantPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            # Stands in for the resource instance's $this.ResourceCache when the helper methods
            # are exercised directly.
            $testCache = @{}
            $resource = [AADPermissionGrantPolicy]::new()

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Add-M365DSCTelemetryEvent -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName New-MgBetaPolicyPermissionGrantPolicy -MockWith {
            }

            Mock -CommandName Update-MgBetaPolicyPermissionGrantPolicy -MockWith {
            }

            Mock -CommandName Remove-MgBetaPolicyPermissionGrantPolicy -MockWith {
            }

            Mock -CommandName New-MgBetaPolicyPermissionGrantPolicyInclude -MockWith {
            }

            Mock -CommandName Remove-MgBetaPolicyPermissionGrantPolicyInclude -MockWith {
            }

            Mock -CommandName New-MgBetaPolicyPermissionGrantPolicyExclude -MockWith {
            }

            Mock -CommandName Remove-MgBetaPolicyPermissionGrantPolicyExclude -MockWith {
            }

            Mock -CommandName Start-Sleep -MockWith {
            }

            Mock -CommandName Get-MgServicePrincipal -MockWith {
                return @{
                    AppId                  = '00000003-0000-0000-c000-000000000000'
                    DisplayName            = 'Microsoft Graph'
                    Oauth2PermissionScopes = @(
                        @{ Id = 'e1fe6dd8-ba31-4d61-89e7-88639da4683d'; Value = 'User.Read' }
                        @{ Id = '37f7f235-527c-4136-accd-4a02d197296e'; Value = 'openid' }
                        @{ Id = '14dad69e-099b-42c9-810b-d002981feec1'; Value = 'profile' }
                    )
                    AppRoles               = @(
                        @{ Id = 'df021288-bdef-4463-88db-98f22de89214'; Value = 'User.Read.All' }
                        @{ Id = '19dbc75e-c2e2-444c-a770-ec596d83d9ad'; Value = 'Directory.Read.All' }
                    )
                }
            }

            Mock -CommandName Get-MgBetaPolicyPermissionGrantPolicy -MockWith {
                if ($All)
                {
                    return @(
                        @{
                            Id          = 'test-policy'
                            DisplayName = 'Test Permission Grant Policy'
                            Description = 'Test policy description'
                            Includes    = @()
                            Excludes    = @()
                        }
                    )
                }
                elseif ($PermissionGrantPolicyId)
                {
                    return @{
                        Id          = $PermissionGrantPolicyId
                        DisplayName = 'Test Permission Grant Policy'
                        Description = 'Test policy description'
                        Includes    = @()
                        Excludes    = @()
                    }
                }
                return $null
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                return @{}
            }

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
                return "AADPermissionGrantPolicy 'TestPolicy' {}`r`n"
            }

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            $Script:exportedInstance = $null
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The Policy should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                                = 'test-policy'
                    DisplayName                       = 'Test Permission Grant Policy'
                    Description                       = 'Test policy description'
                    IncludeAllPreApprovedApplications = $false
                    ResourceScopeType                 = 'tenant'
                    Includes                          = @(
                        [MSFT_AADPermissionGrantConditionSet] @{
                            PermissionType       = 'delegated'
                            ClientApplicationIds = @('all')
                        }
                    )
                    Ensure                            = 'Present'
                    Credential                        = $Credential
                }

                $script:includeCreated = $false

                Mock -CommandName Get-MgBetaPolicyPermissionGrantPolicy -MockWith {
                    if (-not $script:includeCreated)
                    {
                        return $null
                    }
                    return @{
                        Id       = 'test-policy'
                        Includes = @(@{ Id = 'include-1' })
                    }
                }

                Mock -CommandName New-MgBetaPolicyPermissionGrantPolicyInclude -MockWith {
                    $script:includeCreated = $true
                    return @{ Id = 'include-1' }
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-MgBetaPolicyPermissionGrantPolicy' -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaPolicyPermissionGrantPolicy' -Exactly 1
                Should -Invoke -CommandName 'New-MgBetaPolicyPermissionGrantPolicyInclude' -Exactly 1
                Should -Invoke -CommandName 'Get-MgBetaPolicyPermissionGrantPolicy' -Exactly 3
            }
        }

        Context -Name 'The Policy exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Id         = 'test-policy'
                    Ensure     = 'Absent'
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaPolicyPermissionGrantPolicy -MockWith {
                    return @{
                        Id          = 'test-policy'
                        DisplayName = 'Test Permission Grant Policy'
                        Description = 'Test policy description'
                        Includes    = @()
                        Excludes    = @()
                    }
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaPolicyPermissionGrantPolicy' -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MgBetaPolicyPermissionGrantPolicy' -Exactly 1
            }
        }

        Context -Name 'The Policy Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                                = 'test-policy'
                    DisplayName                       = 'Test Permission Grant Policy'
                    Description                       = 'Test policy description'
                    IncludeAllPreApprovedApplications = $false
                    ResourceScopeType                 = 'tenant'
                    Ensure                            = 'Present'
                    Credential                        = $Credential
                }

                Mock -CommandName Get-MgBetaPolicyPermissionGrantPolicy -MockWith {
                    return @{
                        Id                                = 'test-policy'
                        DisplayName                       = 'Test Permission Grant Policy'
                        Description                       = 'Test policy description'
                        IncludeAllPreApprovedApplications = $false
                        ResourceScopeType                 = 'tenant'
                        Includes                          = @()
                        Excludes                          = @()
                    }
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaPolicyPermissionGrantPolicy' -Exactly 1
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                                = 'test-policy'
                    DisplayName                       = 'Updated Permission Grant Policy'
                    Description                       = 'Updated policy description'
                    IncludeAllPreApprovedApplications = $true
                    ResourceScopeType                 = 'group'
                    Ensure                            = 'Present'
                    Credential                        = $Credential
                }

                Mock -CommandName Get-MgBetaPolicyPermissionGrantPolicy -MockWith {
                    return @{
                        Id                                = 'test-policy'
                        DisplayName                       = 'Test Permission Grant Policy'
                        Description                       = 'Test policy description'
                        IncludeAllPreApprovedApplications = $false
                        ResourceScopeType                 = 'tenant'
                        Includes                          = @()
                        Excludes                          = @()
                    }
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaPolicyPermissionGrantPolicy' -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaPolicyPermissionGrantPolicy' -Exactly 1
            }
        }

        Context -Name 'Complex Scenario - Policy with multiple includes and excludes' -Fixture {
            BeforeAll {
                Mock -CommandName Get-MgBetaPolicyPermissionGrantPolicy -MockWith {
                    return @{
                        Id          = 'complex-policy'
                        DisplayName = 'Complex Policy'
                        Description = 'Policy with complex conditions'
                        Includes    = @(
                            @{
                                Id                       = 'include-1'
                                PermissionType           = 'delegated'
                                PermissionClassification = 'low'
                                ClientApplicationIds     = @('all')
                                ResourceApplication      = '00000003-0000-0000-c000-000000000000'
                                Permissions              = @('User.Read', 'openid', 'profile')
                            },
                            @{
                                Id                              = 'include-2'
                                PermissionType                  = 'delegated'
                                ClientApplicationIds            = @('app-id-1', 'app-id-2')
                                ClientApplicationsFromVerifiedPublisherOnly = $true
                                ResourceApplication             = 'any'
                                Permissions                     = @('all')
                            }
                        )
                        Excludes    = @(
                            @{
                                Id                       = 'exclude-1'
                                PermissionType           = 'application'
                                ClientApplicationIds     = @('all')
                                ResourceApplication      = 'any'
                                Permissions              = @('all')
                            }
                        )
                    }
                }
            }

            It 'Should correctly retrieve policy with multiple condition sets' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property @{ Id = 'complex-policy'; Credential = $Credential }).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.Includes.Count | Should -Be 2
                $result.Excludes.Count | Should -Be 1
                $result.Includes[0].Id | Should -Be 'include-1'
                $result.Includes[1].Id | Should -Be 'include-2'
                $result.Excludes[0].Id | Should -Be 'exclude-1'
            }
        }

        Context -Name 'Complex Scenario - Condition set with arrays' -Fixture {
            BeforeAll {
                Mock -CommandName Get-MgBetaPolicyPermissionGrantPolicy -MockWith {
                    return @{
                        Id          = 'array-policy'
                        DisplayName = 'Array Test Policy'
                        Description = 'Tests array properties'
                        Includes    = @(
                            @{
                                Id                            = 'array-include'
                                PermissionType                = 'delegated'
                                ClientApplicationIds          = @('id1', 'id2', 'id3')
                                ClientApplicationPublisherIds = @('pub1', 'pub2')
                                ClientApplicationTenantIds    = @('tenant1')
                                Permissions                   = @('Permission1', 'Permission2', 'Permission3')
                                ResourceApplication           = '00000003-0000-0000-c000-000000000000'
                            }
                        )
                        Excludes    = @()
                    }
                }
            }

            It 'Should correctly handle array properties' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property @{ Id = 'array-policy'; Credential = $Credential }).Get().ToHashtable()
                $result.Includes[0].ClientApplicationIds.Count | Should -Be 3
                $result.Includes[0].ClientApplicationPublisherIds.Count | Should -Be 2
                $result.Includes[0].Permissions.Count | Should -Be 3
            }
        }

        Context -Name 'Complex Scenario - Helper function Test-ConditionSetsEqual' -Fixture {
            It 'Should return true for identical condition sets' {
                $set1 = @{
                    Id                       = 'test-id'
                    PermissionType           = 'delegated'
                    PermissionClassification = 'low'
                    ClientApplicationIds     = @('all')
                    Permissions              = @('User.Read')
                }

                $set2 = @{
                    Id                       = 'test-id'
                    PermissionType           = 'delegated'
                    PermissionClassification = 'low'
                    ClientApplicationIds     = @('all')
                    Permissions              = @('User.Read')
                }

                $resource.TestConditionSetsEqual($testCache, $set1, $set2) | Should -Be $true
            }

            It 'Should return false for different permission types' {
                $set1 = @{
                    Id             = 'test-id'
                    PermissionType = 'delegated'
                }

                $set2 = @{
                    Id             = 'test-id'
                    PermissionType = 'application'
                }

                $resource.TestConditionSetsEqual($testCache, $set1, $set2) | Should -Be $false
            }

            It 'Should return false for different array values' {
                $set1 = @{
                    Id          = 'test-id'
                    Permissions = @('User.Read', 'User.Write')
                }

                $set2 = @{
                    Id          = 'test-id'
                    Permissions = @('User.Read')
                }

                $resource.TestConditionSetsEqual($testCache, $set1, $set2) | Should -Be $false
            }

            It 'Should return true for arrays in different order' {
                $set1 = @{
                    Id                   = 'test-id'
                    ClientApplicationIds = @('id1', 'id2', 'id3')
                }

                $set2 = @{
                    Id                   = 'test-id'
                    ClientApplicationIds = @('id3', 'id1', 'id2')
                }

                $resource.TestConditionSetsEqual($testCache, $set1, $set2) | Should -Be $true
            }

            It 'Should return false when properties are missing' {
                $set1 = @{
                    Id             = 'test-id'
                    PermissionType = 'delegated'
                    Permissions    = @('User.Read')
                }

                $set2 = @{
                    Id             = 'test-id'
                    PermissionType = 'delegated'
                }

                $resource.TestConditionSetsEqual($testCache, $set1, $set2) | Should -Be $false
            }
        }

        Context -Name 'Complex Scenario - Helper function Get-PermissionGrantConditionSetAsHashtable' -Fixture {
            It 'Should convert all properties correctly' {
                $conditionSet = [PSCustomObject]@{
                    Id                                          = 'test-id'
                    PermissionType                              = 'delegated'
                    PermissionClassification                    = 'low'
                    ClientApplicationIds                        = @('all')
                    ClientApplicationPublisherIds               = @('publisher1')
                    ClientApplicationTenantIds                  = @('tenant1')
                    CertifiedClientApplicationsOnly             = $false
                    ClientApplicationsFromVerifiedPublisherOnly = $true
                    Permissions                                 = @('User.Read')
                    ResourceApplication                         = '00000003-0000-0000-c000-000000000000'
                }

                $result = [AADPermissionGrantPolicy]::GetPermissionGrantConditionSetAsHashtable($testCache, $conditionSet)

                $result.Id | Should -Be 'test-id'
                $result.PermissionType | Should -Be 'delegated'
                $result.PermissionClassification | Should -Be 'low'
                $result.ClientApplicationIds.Count | Should -Be 1
                $result.ClientApplicationsFromVerifiedPublisherOnly | Should -Be $true
            }

            It 'Should handle null properties' {
                $conditionSet = [PSCustomObject]@{
                    Id             = 'test-id'
                    PermissionType = 'delegated'
                }

                $result = [AADPermissionGrantPolicy]::GetPermissionGrantConditionSetAsHashtable($testCache, $conditionSet)

                $result.ContainsKey('Id') | Should -Be $true
                $result.ContainsKey('PermissionType') | Should -Be $true
                $result.ContainsKey('PermissionClassification') | Should -Be $false
            }
        }

        Context -Name 'Complex Scenario - Helper function Get-PermissionGrantConditionSetAsParameters' -Fixture {
            It 'Should convert to API parameters correctly' {
                $conditionSet = [PSCustomObject]@{
                    Id                   = 'test-id'
                    PermissionType       = 'delegated'
                    ClientApplicationIds = @('all')
                    Permissions          = @('all')
                    ResourceApplication  = 'any'
                }

                $result = $resource.GetPermissionGrantConditionSetAsParameters($testCache, $conditionSet)

                $result.ContainsKey('PermissionGrantConditionSetId') | Should -Be $false
                $result.PermissionType | Should -Be 'delegated'
                $result.ClientApplicationIds | Should -Be @('all')
            }

            It 'Should skip empty arrays' {
                $conditionSet = [PSCustomObject]@{
                    Id                   = 'test-id'
                    PermissionType       = 'delegated'
                    ClientApplicationIds = @()
                }

                $result = $resource.GetPermissionGrantConditionSetAsParameters($testCache, $conditionSet)

                $result.ContainsKey('ClientApplicationIds') | Should -Be $false
            }

        }

        Context -Name 'Complex Scenario - Helper function ConvertTo-PermissionGuid' -Fixture {
            It 'Should pass through wildcard all as all' {
                $result = $resource.ConvertToPermissionGuid($testCache, 'all', $null, $null)
                $result | Should -Be 'all'
            }

            It 'Should convert any wildcard to all' {
                $result = $resource.ConvertToPermissionGuid($testCache, 'any', $null, $null)
                $result | Should -Be 'all'
            }

            It 'Should pass through existing GUIDs unchanged' {
                $guid = 'e1fe6dd8-ba31-4d61-89e7-88639da4683d'
                $result = $resource.ConvertToPermissionGuid($testCache, $guid, $null, $null)
                $result | Should -Be $guid
            }

            It 'Should resolve delegated permission name to GUID' {
                $result = $resource.ConvertToPermissionGuid($testCache, 'User.Read', '00000003-0000-0000-c000-000000000000', 'delegated')
                $result | Should -Be 'e1fe6dd8-ba31-4d61-89e7-88639da4683d'
            }

            It 'Should resolve application permission name to GUID' {
                $result = $resource.ConvertToPermissionGuid($testCache, 'User.Read.All', '00000003-0000-0000-c000-000000000000', 'application')
                $result | Should -Be 'df021288-bdef-4463-88db-98f22de89214'
            }

            It 'Should return name when ResourceApplication is any' {
                $result = $resource.ConvertToPermissionGuid($testCache, 'User.Read', 'any', 'delegated')
                $result | Should -Be 'User.Read'
            }

            It 'Should return name when ResourceApplication is not specified' {
                $result = $resource.ConvertToPermissionGuid($testCache, 'User.Read', $null, $null)
                $result | Should -Be 'User.Read'
            }

            It 'Should cache service principal and only call Get-MgServicePrincipal once for same ResourceApplication' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)

                $result1 = $resource.ConvertToPermissionGuid($testCache, 'User.Read', '00000003-0000-0000-c000-000000000000', 'delegated')
                $result2 = $resource.ConvertToPermissionGuid($testCache, 'openid', '00000003-0000-0000-c000-000000000000', 'delegated')
                $result3 = $resource.ConvertToPermissionGuid($testCache, 'User.Read.All', '00000003-0000-0000-c000-000000000000', 'application')

                $result1 | Should -Be 'e1fe6dd8-ba31-4d61-89e7-88639da4683d'
                $result2 | Should -Be '37f7f235-527c-4136-accd-4a02d197296e'
                $result3 | Should -Be 'df021288-bdef-4463-88db-98f22de89214'

                Should -Invoke -CommandName 'Get-MgServicePrincipal' -Exactly 1
            }
        }

        Context -Name 'Helper function ConvertTo-PermissionName' -Fixture {
            It 'Should pass through wildcard all unchanged' {
                $result = [AADPermissionGrantPolicy]::ConvertToPermissionName($testCache, 'all', $null, $null)
                $result | Should -Be 'all'
            }

            It 'Should pass through wildcard any unchanged' {
                $result = [AADPermissionGrantPolicy]::ConvertToPermissionName($testCache, 'any', $null, $null)
                $result | Should -Be 'any'
            }

            It 'Should pass through non-GUID value as already a name' {
                $result = [AADPermissionGrantPolicy]::ConvertToPermissionName($testCache, 'User.Read', $null, $null)
                $result | Should -Be 'User.Read'
            }

            It 'Should resolve delegated permission GUID to name' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                $result = [AADPermissionGrantPolicy]::ConvertToPermissionName($testCache, 'e1fe6dd8-ba31-4d61-89e7-88639da4683d', '00000003-0000-0000-c000-000000000000', 'delegated')
                $result | Should -Be 'User.Read'
            }

            It 'Should resolve application permission GUID to name' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                $result = [AADPermissionGrantPolicy]::ConvertToPermissionName($testCache, 'df021288-bdef-4463-88db-98f22de89214', '00000003-0000-0000-c000-000000000000', 'application')
                $result | Should -Be 'User.Read.All'
            }

            It 'Should return GUID when ResourceApplication is any' {
                $result = [AADPermissionGrantPolicy]::ConvertToPermissionName($testCache, 'e1fe6dd8-ba31-4d61-89e7-88639da4683d', 'any', 'delegated')
                $result | Should -Be 'e1fe6dd8-ba31-4d61-89e7-88639da4683d'
            }

            It 'Should return GUID when ResourceApplication is not specified' {
                $result = [AADPermissionGrantPolicy]::ConvertToPermissionName($testCache, 'e1fe6dd8-ba31-4d61-89e7-88639da4683d', $null, $null)
                $result | Should -Be 'e1fe6dd8-ba31-4d61-89e7-88639da4683d'
            }

            It 'Should resolve GUID even without PermissionType by searching both collections' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                $result = [AADPermissionGrantPolicy]::ConvertToPermissionName($testCache, 'e1fe6dd8-ba31-4d61-89e7-88639da4683d', '00000003-0000-0000-c000-000000000000', $null)
                $result | Should -Be 'User.Read'
            }

            It 'Should return GUID when permission is not found in service principal' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                $result = [AADPermissionGrantPolicy]::ConvertToPermissionName($testCache, 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee', '00000003-0000-0000-c000-000000000000', 'delegated')
                $result | Should -Be 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
            }

            It 'Should resolve SP name as ResourceApplicationId and resolve permission' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                $result = [AADPermissionGrantPolicy]::ConvertToPermissionName($testCache, 'e1fe6dd8-ba31-4d61-89e7-88639da4683d', 'Microsoft Graph', 'delegated')
                $result | Should -Be 'User.Read'
            }
        }

        Context -Name 'Helper function Resolve-ResourceApplicationName' -Fixture {
            It 'Should resolve GUID to service principal display name' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                $result = $resource.ResolveResourceApplicationName($testCache, '00000003-0000-0000-c000-000000000000')
                $result | Should -Be 'Microsoft Graph'
            }

            It 'Should pass through wildcard any unchanged' {
                $result = $resource.ResolveResourceApplicationName($testCache, 'any')
                $result | Should -Be 'any'
            }

            It 'Should pass through non-GUID value as already a name' {
                $result = $resource.ResolveResourceApplicationName($testCache, 'Microsoft Graph')
                $result | Should -Be 'Microsoft Graph'
            }

            It 'Should return GUID when service principal is not found' {
                Mock -CommandName Get-MgServicePrincipal -MockWith { return $null }
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                $result = $resource.ResolveResourceApplicationName($testCache, 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee')
                $result | Should -Be 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
            }

            It 'Should use cache for repeated lookups' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                Mock -CommandName Get-MgServicePrincipal -MockWith {
                    return @{
                        AppId       = '00000003-0000-0000-c000-000000000000'
                        DisplayName = 'Microsoft Graph'
                    }
                }

                $null = $resource.ResolveResourceApplicationName($testCache, '00000003-0000-0000-c000-000000000000')
                $null = $resource.ResolveResourceApplicationName($testCache, '00000003-0000-0000-c000-000000000000')

                Should -Invoke -CommandName 'Get-MgServicePrincipal' -Exactly 1
            }

            It 'Should also cache by DisplayName so name lookups can find cached entries' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                Mock -CommandName Get-MgServicePrincipal -MockWith {
                    return @{
                        AppId       = '00000003-0000-0000-c000-000000000000'
                        DisplayName = 'Microsoft Graph'
                    }
                }

                $null = $resource.ResolveResourceApplicationName($testCache, '00000003-0000-0000-c000-000000000000')
                ([AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $false)).ContainsKey('Microsoft Graph') | Should -BeTrue
            }
        }

        Context -Name 'Helper function Resolve-ResourceApplicationId' -Fixture {
            It 'Should resolve service principal name to AppId GUID' {
                $result = [AADPermissionGrantPolicy]::ResolveResourceApplicationId($testCache, 'Microsoft Graph')
                $result | Should -Be '00000003-0000-0000-c000-000000000000'
            }

            It 'Should pass through GUID value unchanged' {
                $result = [AADPermissionGrantPolicy]::ResolveResourceApplicationId($testCache, '00000003-0000-0000-c000-000000000000')
                $result | Should -Be '00000003-0000-0000-c000-000000000000'
            }

            It 'Should pass through wildcard any unchanged' {
                $result = [AADPermissionGrantPolicy]::ResolveResourceApplicationId($testCache, 'any')
                $result | Should -Be 'any'
            }

            It 'Should return name when service principal is not found' {
                Mock -CommandName Get-MgServicePrincipal -MockWith { return $null }
                $result = [AADPermissionGrantPolicy]::ResolveResourceApplicationId($testCache, 'NonExistentApp')
                $result | Should -Be 'NonExistentApp'
            }

            It 'Should use cache for repeated name-based lookups' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                Mock -CommandName Get-MgServicePrincipal -MockWith {
                    return @{
                        AppId       = '00000003-0000-0000-c000-000000000000'
                        DisplayName = 'Microsoft Graph'
                    }
                }

                $null = [AADPermissionGrantPolicy]::ResolveResourceApplicationId($testCache, 'Microsoft Graph')
                $null = [AADPermissionGrantPolicy]::ResolveResourceApplicationId($testCache, 'Microsoft Graph')

                Should -Invoke -CommandName 'Get-MgServicePrincipal' -Exactly 1
            }

            It 'Should find cached entry after GUID-based lookup by Resolve-ResourceApplicationName' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                Mock -CommandName Get-MgServicePrincipal -MockWith {
                    return @{
                        AppId       = '00000003-0000-0000-c000-000000000000'
                        DisplayName = 'Microsoft Graph'
                    }
                }

                # First lookup by GUID populates cache with both GUID and name keys
                $null = $resource.ResolveResourceApplicationName($testCache, '00000003-0000-0000-c000-000000000000')
                # Second lookup by name should use cache
                $result = [AADPermissionGrantPolicy]::ResolveResourceApplicationId($testCache, 'Microsoft Graph')
                $result | Should -Be '00000003-0000-0000-c000-000000000000'

                Should -Invoke -CommandName 'Get-MgServicePrincipal' -Exactly 1
            }
        }

        Context -Name 'ConvertTo-PermissionGuid with SP name as ResourceApplicationId' -Fixture {
            It 'Should resolve SP name and then resolve permission' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                $result = $resource.ConvertToPermissionGuid($testCache, 'User.Read', 'Microsoft Graph', 'delegated')
                $result | Should -Be 'e1fe6dd8-ba31-4d61-89e7-88639da4683d'
            }

            It 'Should resolve SP name for application permission' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                $result = $resource.ConvertToPermissionGuid($testCache, 'User.Read.All', 'Microsoft Graph', 'application')
                $result | Should -Be 'df021288-bdef-4463-88db-98f22de89214'
            }
        }

        Context -Name 'Get-PermissionGrantConditionSetAsHashtable passes through ResourceApplication' -Fixture {
            It 'Should pass through GUID for ResourceApplication' {
                $conditionSet = [PSCustomObject]@{
                    Id                  = 'test-id'
                    PermissionType      = 'delegated'
                    ResourceApplication = '00000003-0000-0000-c000-000000000000'
                }

                $result = [AADPermissionGrantPolicy]::GetPermissionGrantConditionSetAsHashtable($testCache, $conditionSet)
                $result.ResourceApplication | Should -Be '00000003-0000-0000-c000-000000000000'
            }

            It 'Should pass through any wildcard for ResourceApplication' {
                $conditionSet = [PSCustomObject]@{
                    Id                  = 'test-id'
                    PermissionType      = 'delegated'
                    ResourceApplication = 'any'
                }

                $result = [AADPermissionGrantPolicy]::GetPermissionGrantConditionSetAsHashtable($testCache, $conditionSet)
                $result.ResourceApplication | Should -Be 'any'
            }

            It 'Should resolve permission GUIDs to names' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                $conditionSet = [PSCustomObject]@{
                    Id                  = 'test-id'
                    PermissionType      = 'delegated'
                    ResourceApplication = '00000003-0000-0000-c000-000000000000'
                    Permissions         = @('e1fe6dd8-ba31-4d61-89e7-88639da4683d', '37f7f235-527c-4136-accd-4a02d197296e')
                }

                $result = [AADPermissionGrantPolicy]::GetPermissionGrantConditionSetAsHashtable($testCache, $conditionSet)
                $result.Permissions | Should -Be @('User.Read', 'openid')
            }

            It 'Should pass through all wildcard for Permissions' {
                $conditionSet = [PSCustomObject]@{
                    Id                  = 'test-id'
                    PermissionType      = 'delegated'
                    ResourceApplication = 'any'
                    Permissions         = @('all')
                }

                $result = [AADPermissionGrantPolicy]::GetPermissionGrantConditionSetAsHashtable($testCache, $conditionSet)
                $result.Permissions | Should -Be @('all')
            }
        }

        Context -Name 'Get-PermissionGrantConditionSetAsParameters passes through ResourceApplication' -Fixture {
            It 'Should pass through GUID for ResourceApplication' {
                $conditionSet = [PSCustomObject]@{
                    Id                  = 'test-id'
                    PermissionType      = 'delegated'
                    Permissions         = @('all')
                    ResourceApplication = '00000003-0000-0000-c000-000000000000'
                }

                $result = $resource.GetPermissionGrantConditionSetAsParameters($testCache, $conditionSet)
                $result.ResourceApplication | Should -Be '00000003-0000-0000-c000-000000000000'
            }

            It 'Should pass through any wildcard for ResourceApplication' {
                $conditionSet = [PSCustomObject]@{
                    Id                  = 'test-id'
                    PermissionType      = 'delegated'
                    Permissions         = @('all')
                    ResourceApplication = 'any'
                }

                $result = $resource.GetPermissionGrantConditionSetAsParameters($testCache, $conditionSet)
                $result.ResourceApplication | Should -Be 'any'
            }
        }

        Context -Name 'Get-TargetResource resolves ResourceApplication and Permissions to names' -Fixture {
            BeforeAll {
                Mock -CommandName Get-MgBetaPolicyPermissionGrantPolicy -MockWith {
                    return @{
                        Id          = 'name-test-policy'
                        DisplayName = 'Name Test Policy'
                        Description = 'Policy for name resolution test'
                        Includes    = @(
                            @{
                                Id                   = 'include-1'
                                PermissionType       = 'delegated'
                                ClientApplicationIds = @('all')
                                ResourceApplication  = '00000003-0000-0000-c000-000000000000'
                                Permissions          = @('e1fe6dd8-ba31-4d61-89e7-88639da4683d', '37f7f235-527c-4136-accd-4a02d197296e')
                            }
                        )
                        Excludes    = @(
                            @{
                                Id                   = 'exclude-1'
                                PermissionType       = 'application'
                                ClientApplicationIds = @('all')
                                ResourceApplication  = '00000003-0000-0000-c000-000000000000'
                                Permissions          = @('df021288-bdef-4463-88db-98f22de89214')
                            }
                        )
                    }
                }
            }

            It 'Should keep ResourceApplication GUID as-is in Includes' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property @{ Id = 'name-test-policy'; Credential = $Credential }).Get().ToHashtable()
                $result.Includes[0].ResourceApplication | Should -Be '00000003-0000-0000-c000-000000000000'
            }

            It 'Should keep ResourceApplication GUID as-is in Excludes' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property @{ Id = 'name-test-policy'; Credential = $Credential }).Get().ToHashtable()
                $result.Excludes[0].ResourceApplication | Should -Be '00000003-0000-0000-c000-000000000000'
            }

            It 'Should resolve Permission GUIDs to names in Includes' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                $result = (New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property @{ Id = 'name-test-policy'; Credential = $Credential }).Get().ToHashtable()
                $result.Includes[0].Permissions | Should -Be @('User.Read', 'openid')
            }

            It 'Should resolve Permission GUIDs to names in Excludes' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)
                $result = (New-M365DSCResourceInstance -ResourceName 'AADPermissionGrantPolicy' -Property @{ Id = 'name-test-policy'; Credential = $Credential }).Get().ToHashtable()
                $result.Excludes[0].Permissions | Should -Be @('User.Read.All')
            }
        }

        Context -Name 'Test-ConditionSetsEqual ignores Id for content-based matching' -Fixture {
            It 'Should return true when condition sets match by content but have different Ids' {
                $set1 = @{
                    PermissionType           = 'delegated'
                    PermissionClassification = 'all'
                    ClientApplicationIds     = @('all')
                    Permissions              = @('User.Read')
                    ResourceApplication      = '00000003-0000-0000-c000-000000000000'
                }

                $set2 = @{
                    Id                                          = 'auto-generated-guid'
                    CertifiedClientApplicationsOnly             = $false
                    PermissionType                              = 'delegated'
                    PermissionClassification                    = 'all'
                    ClientApplicationIds                        = @('all')
                    ClientApplicationPublisherIds               = @('all')
                    ClientApplicationTenantIds                  = @('all')
                    ClientApplicationsFromVerifiedPublisherOnly = $false
                    Permissions                                 = @('User.Read')
                    ResourceApplication                         = '00000003-0000-0000-c000-000000000000'
                }

                $resource.TestConditionSetsEqual($testCache, $set1, $set2) | Should -Be $true
            }

            It 'Should return true when both have Ids but content matches' {
                $set1 = @{
                    Id                       = 'id-1'
                    PermissionType           = 'delegated'
                    ClientApplicationIds     = @('all')
                    Permissions              = @('User.Read')
                }

                $set2 = @{
                    Id                       = 'id-2'
                    PermissionType           = 'delegated'
                    ClientApplicationIds     = @('all')
                    Permissions              = @('User.Read')
                }

                $resource.TestConditionSetsEqual($testCache, $set1, $set2) | Should -Be $true
            }

            It 'Should return false when content differs even with same Id' {
                $set1 = @{
                    Id             = 'same-id'
                    PermissionType = 'delegated'
                }

                $set2 = @{
                    Id             = 'same-id'
                    PermissionType = 'application'
                }

                $set3 = @{
                    Id                       = 'same-id'
                    PermissionType           = 'delegated'
                    PermissionClassification = 'low'
                }

                $resource.TestConditionSetsEqual($testCache, $set1, $set2) | Should -Be $false
                $resource.TestConditionSetsEqual($testCache, $set1, $set3) | Should -Be $false
            }
        }

        Context -Name 'Set() uses content-based matching for includes' -Fixture {
            It 'Should match desired include without Id to current include with Id via Test-ConditionSetsEqual' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)

                # Simulate: desired state has no Id (like real DSC config CIM instances)
                $desiredInclude = @{
                    PermissionType                              = 'delegated'
                    PermissionClassification                    = 'all'
                    ClientApplicationIds                        = @('all')
                    ClientApplicationPublisherIds               = @('all')
                    ClientApplicationTenantIds                  = @('all')
                    ClientApplicationsFromVerifiedPublisherOnly = $false
                    Permissions                                 = @('User.Read')
                    ResourceApplication                         = '00000003-0000-0000-c000-000000000000'
                }

                # Simulate: current state has auto-generated Id from Graph API
                # and uses GUIDs for ResourceApplication and Permissions
                $currentInclude = @{
                    Id                                          = 'a83c7b01-2f79-4200-945a-fcd91cb8e083'
                    PermissionType                              = 'delegated'
                    PermissionClassification                    = 'all'
                    ClientApplicationIds                        = @('all')
                    ClientApplicationPublisherIds               = @('all')
                    ClientApplicationTenantIds                  = @('all')
                    ClientApplicationsFromVerifiedPublisherOnly = $false
                    Permissions                                 = @('e1fe6dd8-ba31-4d61-89e7-88639da4683d')
                    ResourceApplication                         = '00000003-0000-0000-c000-000000000000'
                }

                # This should return true because both use the same GUID for ResourceApplication,
                # permissions resolve to the same display names, and Id is skipped during comparison
                $resource.TestConditionSetsEqual($testCache, $desiredInclude, $currentInclude) | Should -Be $true
            }

            It 'Should match multiple desired includes without Ids to current includes with Ids' {
                $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($testCache, $true)

                $desiredIncludes = @(
                    @{
                        PermissionType           = 'delegated'
                        PermissionClassification = 'all'
                        ClientApplicationIds     = @('all')
                        Permissions              = @('User.Read')
                        ResourceApplication      = '00000003-0000-0000-c000-000000000000'
                    },
                    @{
                        PermissionType           = 'application'
                        PermissionClassification = 'all'
                        ClientApplicationIds     = @('all')
                        Permissions              = @('User.Read.All')
                        ResourceApplication      = '00000003-0000-0000-c000-000000000000'
                    }
                )

                $currentIncludes = @(
                    @{
                        Id                       = 'a83c7b01-guid-1'
                        PermissionType           = 'delegated'
                        PermissionClassification = 'all'
                        ClientApplicationIds     = @('all')
                        Permissions              = @('e1fe6dd8-ba31-4d61-89e7-88639da4683d')
                        ResourceApplication      = '00000003-0000-0000-c000-000000000000'
                    },
                    @{
                        Id                       = '05eada6b-guid-2'
                        PermissionType           = 'application'
                        PermissionClassification = 'all'
                        ClientApplicationIds     = @('all')
                        Permissions              = @('df021288-bdef-4463-88db-98f22de89214')
                        ResourceApplication      = '00000003-0000-0000-c000-000000000000'
                    }
                )

                # Simulate the content-based matching loop from Set()
                $matchedCurrentIds = @()
                foreach ($desired in $desiredIncludes)
                {
                    foreach ($current in $currentIncludes)
                    {
                        if ($current.Id -notin $matchedCurrentIds -and
                            ($resource.TestConditionSetsEqual($testCache, $desired, $current)))
                        {
                            $matchedCurrentIds += $current.Id
                            break
                        }
                    }
                }

                # All current includes should be matched
                $matchedCurrentIds.Count | Should -Be 2
                $matchedCurrentIds | Should -Contain 'a83c7b01-guid-1'
                $matchedCurrentIds | Should -Contain '05eada6b-guid-2'
            }

            It 'Should detect unmatched desired includes when content differs' {
                $desiredIncludes = @(
                    @{
                        PermissionType           = 'delegated'
                        PermissionClassification = 'all'
                        ClientApplicationIds     = @('all')
                        Permissions              = @('User.Read', 'openid')
                        ResourceApplication      = '00000003-0000-0000-c000-000000000000'
                    }
                )

                $currentIncludes = @(
                    @{
                        Id                       = 'existing-guid'
                        PermissionType           = 'delegated'
                        PermissionClassification = 'all'
                        ClientApplicationIds     = @('all')
                        Permissions              = @('e1fe6dd8-ba31-4d61-89e7-88639da4683d')
                        ResourceApplication      = '00000003-0000-0000-c000-000000000000'
                    }
                )

                # The desired has 2 permissions, current has 1 - should NOT match
                $matchedCurrentIds = @()
                foreach ($desired in $desiredIncludes)
                {
                    foreach ($current in $currentIncludes)
                    {
                        if ($current.Id -notin $matchedCurrentIds -and
                            ($resource.TestConditionSetsEqual($testCache, $desired, $current)))
                        {
                            $matchedCurrentIds += $current.Id
                            break
                        }
                    }
                }

                # No match should be found since permissions differ
                $matchedCurrentIds.Count | Should -Be 0
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaPolicyPermissionGrantPolicy -MockWith {
                    if ($All)
                    {
                        return @(
                            @{
                                Id          = 'test-policy-1'
                                DisplayName = 'Test Policy 1'
                                Description = 'First test policy'
                                Includes    = @()
                                Excludes    = @()
                            },
                            @{
                                Id          = 'test-policy-2'
                                DisplayName = 'Test Policy 2'
                                Description = 'Second test policy'
                                Includes    = @()
                                Excludes    = @()
                            }
                        )
                    }
                    return $null
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADPermissionGrantPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }

        Context -Name 'ReverseDSC Tests - Export with Condition Sets' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaPolicyPermissionGrantPolicy -MockWith {
                    if ($All)
                    {
                        return @(
                            @{
                                Id          = 'microsoft-all-application-permissions'
                                DisplayName = 'All application permissions, for any client app'
                                Description = 'Includes all application permissions for all APIs.'
                                Includes    = @(
                                    @{
                                        Id                                          = 'include-1'
                                        PermissionType                              = 'application'
                                        PermissionClassification                    = 'all'
                                        ClientApplicationIds                        = @('all')
                                        ClientApplicationPublisherIds               = @('all')
                                        ClientApplicationTenantIds                  = @('all')
                                        ClientApplicationsFromVerifiedPublisherOnly = $false
                                        ResourceApplication                         = 'any'
                                        Permissions                                 = @('all')
                                    }
                                )
                                Excludes    = @(
                                    @{
                                        Id                   = 'exclude-1'
                                        PermissionType       = 'application'
                                        ClientApplicationIds = @('all')
                                        ResourceApplication  = 'any'
                                        Permissions          = @('all')
                                    }
                                )
                            }
                        )
                    }
                    return $null
                }
            }

            It 'Should Reverse Engineer resource with condition sets from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADPermissionGrantPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
