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
    -DscResource 'AADAuthorizationPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaPolicyAuthorizationPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaPolicyAuthorizationPolicy -MockWith {
                $AADAuthPol = [pscustomobject]@{
                    Id                                                  = 'authorizationPolicy'
                    DisplayName                                         = 'Authorization Policy'
                    Description                                         = 'something'
                    AllowedToSignUpEmailBasedSubscriptions              = $true
                    AllowedToUseSspr                                    = $true
                    AllowEmailVerifiedUsersToJoinOrganization           = $true
                    AllowInvitesFrom                                    = 'Everyone'
                    BlockMsolPowerShell                                 = $false
                    PermissionGrantPolicyIdsAssignedToDefaultUserRole   = [string[]]@()
                    DefaultUserRolePermissions                          = [pscustomobject]@{
                    AllowedToCreateApps                    = $true
                    AllowedToCreateSecurityGroups          = $true
                    AllowedToReadOtherUsers                = $true
                    }
                    EnabledPreviewFeatures                              = [string[]]@('assignGroupsToRoles')
                    GuestUserRoleId                                     = '10dae51f-b6af-4016-8d66-8c2a99b929b3' # Guest
                }
                return $AADAuthPol
            }

            Mock -CommandName Remove-PSSession -MockWith {
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
        # NB The Authorization Policy always exists and cannot be removed or a new one added

        Context -Name 'The role definition exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                                  = 'Yes'
                    DisplayName                                       = 'Authorization Policy'
                    Description                                       = 'something'
                    allowedToSignUpEmailBasedSubscriptions            = $true
                    allowedToUseSSPR                                  = $true
                    allowEmailVerifiedUsersToJoinOrganization         = $true
                    AllowInvitesFrom                                  = 'Everyone'
                    blockMsolPowerShell                               = $false
                    DefaultUserRolePermissions                        = @{
                        AllowedToCreateApps           = $true
                        AllowedToCreateSecurityGroups = $true
                        AllowedToReadOtherUsers       = $true
                    }
                    EnabledPreviewFeatures                            = [string[]]@('assignGroupsToRoles')
                    PermissionGrantPolicyIdsAssignedToDefaultUserRole = [string[]]@()
                    GuestUserRole                                     = 'Guest'
                    Ensure                                            = 'Present'
                    Credential                                        = $Credential
                }
            }

            It 'Should return Values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthorizationPolicy' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaPolicyAuthorizationPolicy' -Exactly 1
            }

            It 'Should return true from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthorizationPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Values are not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                                  = 'Yes'
                    DisplayName                                       = 'Authorization Policy'
                    Description                                       = 'something'
                    allowedToSignUpEmailBasedSubscriptions            = $False
                    allowedToUseSSPR                                  = $false
                    allowEmailVerifiedUsersToJoinOrganization         = $false
                    AllowInvitesFrom                                  = 'AdminsAndGuestInviters'
                    blockMsolPowerShell                               = $false
                    DefaultUserRolePermissions                        = @{
                        AllowedToCreateApps           = $true
                        AllowedToCreateSecurityGroups = $true
                        AllowedToReadOtherUsers       = $true
                    }
                    EnabledPreviewFeatures                            = [string[]]@() # Drift
                    PermissionGrantPolicyIdsAssignedToDefaultUserRole = [string[]]@()
                    GuestUserRole                                     = 'RestrictedGuest' # Drift
                    Ensure                                            = 'Present'
                    Credential                                        = $Credential
                }
            }

            It 'Should return values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthorizationPolicy' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaPolicyAuthorizationPolicy' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthorizationPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthorizationPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaPolicyAuthorizationPolicy' -Exactly 1
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

            It 'Should reverse engineer resource from the export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADAuthorizationPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
