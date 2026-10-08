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
    -DscResource "IntuneRoleAssignmentWindows365" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Reset-MSCloudLoginConnectionProfileContext -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Get-MgBetaRoleManagementCloudPcRoleDefinition -MockWith {
                return @{
                    Id = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                }
            }

            Mock -CommandName Update-MgBetaRoleManagementCloudPcRoleAssignment -MockWith {
            }

            Mock -CommandName New-MgBetaRoleManagementCloudPcRoleAssignment -MockWith {
            }

            Mock -CommandName Remove-MgBetaRoleManagementCloudPcRoleAssignment -MockWith {
            }

            Mock -CommandName Get-MgBetaRoleManagementCloudPcRoleAssignment -MockWith {
                return @{
                    AppScopeIds = @("FakeStringValue")
                    Condition = "FakeStringValue"
                    Description = "FakeStringValue"
                    DirectoryScopeIds = @("FakeStringValue")
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    PrincipalIds = @("FakeStringValue")
                    RoleDefinitionId = "FakeStringValue"
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                return @(
                    @{
                        id = "FakeStringValue"
                        status = 200
                        body = @(
                            @{
                                id = "FakeStringValue"
                                displayName = "FakeStringValue"
                            }
                        )
                    }
                )
            }

            Mock -CommandName Invoke-M365DSCGraphBatchRequest -ParameterFilter { $Requests[0].url -like '*$filter=*' } -MockWith {
                return @(
                    @{
                        id = "FakeStringValue"
                        status = 200
                        body = @{
                            value = @(
                                @{
                                    id = "FakeStringValue"
                                    displayName = "FakeStringValue"
                                }
                            )
                        }
                    }
                )
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "The IntuneRoleAssignmentWindows365 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AppScopeIds = @("FakeStringValue")
                    Description = "FakeStringValue"
                    DirectoryScopes = @("FakeStringValue")
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    Principals = @("FakeStringValue")
                    RoleDefinition = "FakeStringValue"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaRoleManagementCloudPcRoleAssignment -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignmentWindows365' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignmentWindows365' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignmentWindows365' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaRoleManagementCloudPcRoleAssignment -Exactly 1
            }
        }

        Context -Name "The IntuneRoleAssignmentWindows365 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AppScopeIds = @("FakeStringValue")
                    Description = "FakeStringValue"
                    DirectoryScopes = @("FakeStringValue")
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    Principals = @("FakeStringValue")
                    RoleDefinition = "FakeStringValue"
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignmentWindows365' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignmentWindows365' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignmentWindows365' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaRoleManagementCloudPcRoleAssignment -Exactly 1
            }
        }

        Context -Name "The IntuneRoleAssignmentWindows365 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AppScopeIds = @("FakeStringValue")
                    Description = "FakeStringValue"
                    DirectoryScopes = @("FakeStringValue")
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    Principals = @("FakeStringValue")
                    RoleDefinition = "FakeStringValue"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignmentWindows365' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneRoleAssignmentWindows365 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AppScopeIds = @("FakeStringValue2") # Drift
                    Description = "FakeStringValue"
                    DirectoryScopes = @("FakeStringValue")
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    Principals = @("FakeStringValue")
                    RoleDefinition = "FakeStringValue"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignmentWindows365' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignmentWindows365' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneRoleAssignmentWindows365' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaRoleManagementCloudPcRoleAssignment -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneRoleAssignmentWindows365' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
