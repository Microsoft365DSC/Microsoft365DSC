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
    -DscResource 'IntuneRoleAssignment' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDeviceManagementRoleAssignment -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementRoleAssignment -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementRoleAssignment -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-MgBetaDeviceManagementRoleAssignment -MockWith {
                return @{
                    Description     = 'FakeStringValue'
                    DisplayName     = 'FakeStringValue'
                    Id              = 'FakeStringValue'
                    Members         = @('FakeStringValue')
                    resourceScopes  = @('FakeStringValue')
                    ScopeType       = 'resourceScope'
                    RoleScopeTagIds = @('0')
                }
            }
            Mock -CommandName Get-MgDeviceManagementRoleDefinition -MockWith {
                return @{
                    Id          = '7fbbd347-98de-431d-942b-cf5bea92998d'
                    DisplayName = 'FakeStringValue'
                }
            }
            Mock -CommandName Get-MgDeviceManagementRoleDefinitionRoleAssignment -MockWith {
                return @{
                    Id = 'FakeStringValue'
                }
            }
            Mock -CommandName Get-MgGroup -MockWith {
                return @{
                    Displayname = 'FakeStringValue'
                    Id          = 'FakeStringValue'
                }
            }

            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith {
                return @{
                    Displayname = 'FakeStringValue'
                    Id          = 'FakeStringValue'
                }
            }

            Mock -CommandName Get-MgGroup -ParameterFilter { $Filter -like '*OtherMember*' } -MockWith {
                return @{
                    Displayname = 'OtherMember'
                    Id          = 'OtherMember'
                }
            }
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name 'The IntuneRoleAssignment should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description     = 'FakeStringValue'
                    DisplayName     = 'FakeStringValue'
                    Id              = 'FakeStringValue'
                    Ensure          = 'Present'
                    RoleScopeTagIds = @('0')
                    Credential      = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementRoleAssignment -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignment' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignment' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignment' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementRoleAssignment -Exactly 1
            }
        }

        Context -Name 'The IntuneRoleAssignment exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                = 'FakeStringValue'
                    DisplayName                = 'FakeStringValue'
                    Id                         = ''
                    Ensure                     = 'Absent'
                    MembersDisplayNames        = @('FakeStringValue')
                    ResourceScopesDisplayNames = @('FakeStringValue')
                    ScopeType                  = 'resourceScope'
                    RoleScopeTagIds            = @('0')
                    Credential                 = $Credential
                }

                Mock -CommandName Get-MgDeviceManagementRoleDefinition -ParameterFilter { -not [System.String]::IsNullOrEmpty($Filter) } -MockWith {
                    return $null
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignment' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignment' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignment' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementRoleAssignment -Exactly 1
            }
        }
        Context -Name 'The IntuneRoleAssignment Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                = 'FakeStringValue'
                    DisplayName                = 'FakeStringValue'
                    Id                         = 'FakeStringValue'
                    Ensure                     = 'Present'
                    RoleDefinition             = '7fbbd347-98de-431d-942b-cf5bea92998d'
                    MembersDisplayNames        = @('FakeStringValue')
                    ResourceScopesDisplayNames = @('FakeStringValue')
                    ScopeType                  = 'resourceScope'
                    RoleScopeTagIds            = @('0')
                    Credential                 = $Credential
                }
            }


            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignment' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The IntuneRoleAssignment exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                = 'FakeStringValue'
                    DisplayName                = 'FakeStringValue'
                    Id                         = 'FakeStringValue'
                    Ensure                     = 'Present'
                    RoleDefinition             = '7fbbd347-98de-431d-942b-cf5bea92998d'
                    MembersDisplayNames        = @('OtherMember') # Updated property
                    ResourceScopesDisplayNames = @('FakeStringValue')
                    ScopeType                  = 'resourceScope'
                    RoleScopeTagIds            = @('0')
                    Credential                 = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignment' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignment' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignment' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementRoleAssignment -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneRoleAssignment' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
