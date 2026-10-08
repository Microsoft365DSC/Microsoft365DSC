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
    -DscResource 'TeamsAppPermissionPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-GUID).ToString() -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-CsTeamsAppPermissionPolicy -MockWith {
                return @{
                    DefaultCatalogApps     = @(
                        @{
                            Id = "com.microsoft.teamspace.tab.vsts";
                        }
                    )
                    DefaultCatalogAppsType = "AllowedAppList";
                    Description            = "This is a test policy";
                    GlobalCatalogAppsType  = "BlockedAppList";
                    Identity               = "TestPolicy";
                    PrivateCatalogAppsType = "BlockedAppList";
                }
            }

            Mock -CommandName Set-CsTeamsAppPermissionPolicy -MockWith {
            }

            Mock -CommandName New-CsTeamsAppPermissionPolicy -MockWith {
            }

            Mock -CommandName Remove-CsTeamsAppPermissionPolicy -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            $fakeAssembly = @"
                namespace Microsoft.Teams.Policy.Administration.Cmdlets.Core
                {
                    public class DefaultCatalogApp
                    {
                        public DefaultCatalogApp(string appInstance)
                        {}
                    }
                }
"@
            try
            {
                Add-Type -TypeDefinition $fakeAssembly -ErrorAction SilentlyContinue
            }
            catch
            {

            }
        }

        # Test contexts
        Context -Name 'The policy should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DefaultCatalogApps     = "com.microsoft.teamspace.tab.vsts";
                    DefaultCatalogAppsType = "AllowedAppList";
                    Description            = "This is a test policy";
                    Ensure                 = "Present";
                    GlobalCatalogAppsType  = "BlockedAppList";
                    Identity               = "TestPolicy";
                    PrivateCatalogAppsType = "BlockedAppList";
                    Credential             = $Credential
                }

                Mock -CommandName Get-CsTeamsAppPermissionPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsAppPermissionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAppPermissionPolicy' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAppPermissionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-CsTeamsAppPermissionPolicy -Exactly 1
            }
        }

        Context -Name 'The policy exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DefaultCatalogApps     = "com.microsoft.teamspace.tab.vsts";
                    DefaultCatalogAppsType = "AllowedAppList";
                    Description            = "This is a test policy";
                    Ensure                 = "Absent";
                    GlobalCatalogAppsType  = "BlockedAppList";
                    Identity               = "TestPolicy";
                    PrivateCatalogAppsType = "BlockedAppList";
                    Credential             = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsAppPermissionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAppPermissionPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAppPermissionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-CsTeamsAppPermissionPolicy -Exactly 1
            }
        }

        Context -Name 'The policy Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DefaultCatalogApps     = "com.microsoft.teamspace.tab.vsts";
                    DefaultCatalogAppsType = "AllowedAppList";
                    Description            = "This is a test policy";
                    Ensure                 = "Present";
                    GlobalCatalogAppsType  = "BlockedAppList";
                    Identity               = "TestPolicy";
                    PrivateCatalogAppsType = "BlockedAppList";
                    Credential             = $Credential
                }
            }


            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAppPermissionPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The policy exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DefaultCatalogApps     = "com.microsoft.teamspace.tab.vsts";
                    DefaultCatalogAppsType = "AllowedAppList";
                    Description            = "This is a test policy";
                    Ensure                 = "Present";
                    GlobalCatalogAppsType  = "AllowedAppList"; # Drift
                    Identity               = "TestPolicy";
                    PrivateCatalogAppsType = "BlockedAppList";
                    Credential             = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsAppPermissionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAppPermissionPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAppPermissionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsAppPermissionPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsAppPermissionPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
