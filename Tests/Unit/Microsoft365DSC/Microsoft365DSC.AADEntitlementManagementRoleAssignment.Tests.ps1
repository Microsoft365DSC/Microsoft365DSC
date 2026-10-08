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
    -DscResource 'AADEntitlementManagementRoleAssignment' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -CommandName Add-M365DSCTelemetryEvent -ModuleName '_Shared' -MockWith {
            }

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            Mock -CommandName New-MgBetaRoleManagementEntitlementManagementRoleAssignment -MockWith {
            }

            Mock -CommandName Remove-MgBetaRoleManagementEntitlementManagementRoleAssignment -MockWith {
            }

            Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                return @(
                    @{
                        id = 'user'
                        body = @{
                            userPrincipalName = "John.Smith@contoso.com"
                            id                = "12345-12345-12345-12345-12345"
                        }
                    }
                )
            }

            Mock -CommandName Get-MgBetaRoleManagementEntitlementManagementRoleDefinition -MockWith {
                return @(
                    @{
                        DisplayName = "Catalog creator"
                        Id          = "12345-12345-12345-12345-12345"
                    }
                )
            }

            Mock -CommandName Get-MgBetaRoleManagementEntitlementManagementRoleAssignment -MockWith {
                return @{
                    AppScopeId       = "/"
                    PrincipalId      = '12345-12345-12345-12345-12345'
                    Principal        = @{
                        '@odata.type' = '#microsoft.graph.user'
                        userPrincipalName = "John.Smith@contoso.com"
                    }
                    RoleDefinitionId = '12345-12345-12345-12345-12345'
                    DirectoryScopeId = ''
                }
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
        Context -Name "The assignment doesn't exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    AppScopeId     = "/";
                    Ensure         = "Present";
                    Principal      = "John.Smith@contoso.com";
                    RoleDefinition = "Catalog creator";
                    Credential     = $Credential
                }

                Mock -CommandName Get-MgBetaRoleManagementEntitlementManagementRoleAssignment -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgGroup -MockWith {
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementRoleAssignment' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName Get-MgGroup -Exactly 0
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementRoleAssignment' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementRoleAssignment' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaRoleManagementEntitlementManagementRoleAssignment -Exactly 1
            }
        }

        Context -Name "The assignment already exists" -Fixture {
            BeforeAll {
                $testParams = @{
                    AppScopeId     = "/";
                    Ensure         = "Present";
                    Principal      = "John.Smith@contoso.com";
                    RoleDefinition = "Catalog creator";
                    Credential     = $Credential
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementRoleAssignment' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementRoleAssignment' -Property $testParams).Test() | Should -Be $true
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADEntitlementManagementRoleAssignment' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
