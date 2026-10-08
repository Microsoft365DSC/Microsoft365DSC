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
    -DscResource 'AADEntitlementManagementAccessPackage' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaEntitlementManagementAccessPackage -MockWith {
            }

            Mock -CommandName New-MgBetaEntitlementManagementAccessPackage -MockWith {
            }

            Mock -CommandName Remove-MgBetaEntitlementManagementAccessPackage -MockWith {
            }

            Mock -CommandName Get-MgBetaEntitlementManagementAccessPackageCatalog -MockWith {
                return @{
                    DisplayName                     = 'FakeStringValue'
                    Id                              = 'FakeStringValue'
                }
            }
            Mock -CommandName Get-MgBetaEntitlementManagementAccessPackage -MockWith {
                return @{
                    CatalogId                       = 'FakeStringValue'
                    Description                     = 'FakeStringValue'
                    DisplayName                     = 'FakeStringValue'
                    Id                              = 'FakeStringValue'
                    IsHidden                        = $True
                    IsRoleScopesVisible             = $True
                    AccessPackageResourceRoleScopes = @{
                        Id = 'FakeStringValue'
                        AccessPackageResourceScope = @{
                            OriginId = '123456789'
                        }
                        AccessPackageResourceRole  = @{
                            DisplayName = 'TestRole'
                        }
                    }
                }
            }
            Mock -CommandName Get-MgBetaEntitlementManagementAccessPackageIncompatibleAccessPackage -MockWith {
                return @(
                    @{
                        id = 'packageId1'
                    }
                    @{
                        id = 'packageId2'
                    }
                )
            }
            Mock -CommandName Get-MgBetaEntitlementManagementAccessPackageIncompatibleWith -MockWith {
                return @()
            }
            Mock -CommandName Get-MgBetaEntitlementManagementAccessPackageIncompatibleGroup -MockWith {
                return @(
                    @{
                        id = 'groupId1'
                    }
                    @{
                        id = 'groupId2'
                    }
                )
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The AADEntitlementManagementAccessPackage should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    CatalogId                       = 'FakeStringValue'
                    Description                     = 'FakeStringValue'
                    DisplayName                     = 'FakeStringValue'
                    Id                              = 'FakeStringValue'
                    IsHidden                        = $True
                    IsRoleScopesVisible             = $True
                    AccessPackageResourceRoleScopes = ([MSFT_AccessPackageResourceRoleScope] @{
                            Id                                   = 'FakeStringValue'
                            AccessPackageResourceOriginId        = '123456789'
                            AccessPackageResourceRoleDisplayName = 'TestRole'
                        })
                    Ensure                          = 'Present'
                    Credential                      = $Credential
                }

                Mock -CommandName Get-MgBetaEntitlementManagementAccessPackage -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackage' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackage' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackage' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaEntitlementManagementAccessPackage -Exactly 1
            }
        }

        Context -Name 'The AADEntitlementManagementAccessPackage exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    CatalogId                       = 'FakeStringValue'
                    Description                     = 'FakeStringValue'
                    DisplayName                     = 'FakeStringValue'
                    Id                              = 'FakeStringValue'
                    IsHidden                        = $True
                    IsRoleScopesVisible             = $True
                    IncompatibleAccessPackages      = @('packageId1', 'packageId2')
                    IncompatibleGroups              = @('groupId1', 'groupId2')
                    AccessPackageResourceRoleScopes = ([MSFT_AccessPackageResourceRoleScope] @{
                            Id                                   = 'FakeStringValue'
                            AccessPackageResourceOriginId        = '123456789'
                            AccessPackageResourceRoleDisplayName = 'TestRole'
                        })
                    Ensure                          = 'Absent'
                    Credential                      = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackage' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackage' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackage' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaEntitlementManagementAccessPackage -Exactly 1
            }
        }
        Context -Name 'The AADEntitlementManagementAccessPackage Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    CatalogId                       = 'FakeStringValue'
                    Description                     = 'FakeStringValue'
                    DisplayName                     = 'FakeStringValue'
                    Id                              = 'FakeStringValue'
                    IsHidden                        = $True
                    IsRoleScopesVisible             = $True
                    IncompatibleAccessPackages      = @('packageId1', 'packageId2')
                    IncompatibleGroups              = @('groupId1', 'groupId2')
                    AccessPackageResourceRoleScopes = ([MSFT_AccessPackageResourceRoleScope] @{
                            Id                                   = 'FakeStringValue'
                            AccessPackageResourceOriginId        = '123456789'
                            AccessPackageResourceRoleDisplayName = 'TestRole'
                        })
                    Ensure                          = 'Present'
                    Credential                      = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackage' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The AADEntitlementManagementAccessPackage identifies a resource role scope by object id and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    CatalogId                       = 'FakeStringValue'
                    Description                     = 'FakeStringValue'
                    DisplayName                     = 'FakeStringValue'
                    Id                              = 'FakeStringValue'
                    IsHidden                        = $True
                    IsRoleScopesVisible             = $True
                    IncompatibleAccessPackages      = @('packageId1', 'packageId2')
                    IncompatibleGroups              = @('groupId1', 'groupId2')
                    AccessPackageResourceRoleScopes = ([MSFT_AccessPackageResourceRoleScope] @{
                            Id                                     = 'FakeStringValue'
                            AccessPackageResourceOriginId          = '9ba7bd2f-8d0f-4c3a-96f5-9e5eab7b7a1d'
                            AccessPackageResourceRoleDisplayName   = 'TestRole'
                            AccessPackageResourceScopeOriginSystem = 'AadGroup'
                        })
                    Ensure                          = 'Present'
                    Credential                      = $Credential
                }

                Mock -CommandName Get-M365DSCAccessPackageResourceOriginDisplayName -MockWith {
                    if ($OriginId -eq '9ba7bd2f-8d0f-4c3a-96f5-9e5eab7b7a1d' -and $OriginSystem -eq 'AadGroup')
                    {
                        return 'Marketing Team'
                    }

                    return $OriginId
                }

                Mock -CommandName Get-MgBetaEntitlementManagementAccessPackage -MockWith {
                    return @{
                        CatalogId                       = 'FakeStringValue'
                        Description                     = 'FakeStringValue'
                        DisplayName                     = 'FakeStringValue'
                        Id                              = 'FakeStringValue'
                        IsHidden                        = $True
                        IsRoleScopesVisible             = $True
                        AccessPackageResourceRoleScopes = @{
                            Id                         = 'FakeStringValue'
                            AccessPackageResourceScope = @{
                                OriginId     = '9ba7bd2f-8d0f-4c3a-96f5-9e5eab7b7a1d'
                                OriginSystem = 'AadGroup'
                            }
                            AccessPackageResourceRole  = @{
                                DisplayName = 'TestRole'
                            }
                        }
                    }
                }
            }

            It 'Should return the group display name from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackage' -Property $testParams).Get().ToHashtable()).AccessPackageResourceRoleScopes[0].AccessPackageResourceOriginId | Should -Be 'Marketing Team'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackage' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The AADEntitlementManagementAccessPackage exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    CatalogId                       = 'FakeStringValue'
                    Description                     = 'FakeStringValue'
                    DisplayName                     = 'FakeStringValue'
                    Id                              = 'FakeStringValue'
                    IsHidden                        = $false # Drift
                    IsRoleScopesVisible             = $true
                    IncompatibleAccessPackages      = @('packageId1', 'packageId2')
                    IncompatibleGroups              = @('groupId1', 'groupId2')
                    Ensure                          = 'Present'
                    Credential                      = $Credential
                }

                Mock -CommandName Remove-MgBetaEntitlementManagementAccessPackageResourceRoleScope -MockWith {
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackage' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackage' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackage' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaEntitlementManagementAccessPackage -Exactly 1
                Should -Invoke -CommandName Remove-MgBetaEntitlementManagementAccessPackageResourceRoleScope -Exactly 0
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADEntitlementManagementAccessPackage' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
