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
    -DscResource "IntuneWindowsUpdateForBusinessHotpatchProfileWindows10" -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-MgBetaDeviceManagementManagedDeviceCleanupRule -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementManagedDeviceCleanupRule -MockWith {
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' -and $Uri -like "*windowsQualityUpdatePolicies/FakeStringValue" } -MockWith {
                return @{
                    Description = "FakeStringValue"
                    HotpatchEnabled = $True
                    RoleScopeTagIds = @("0")
                    ApprovalSettings = @(
                        @{
                            ApprovalMethodType = "automatic"
                            DeferredDeploymentInDay = 2
                            WindowsQualityUpdateCadence = "monthly"
                            WindowsQualityUpdateCategory = "all"
                        }
                    )
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                }
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' -and $Uri -like "*windowsQualityUpdatePolicies*" -and $Uri -notlike "*FakeStringValue*" } -MockWith {
                return @{
                    value = @(
                        @{
                            Description = "FakeStringValue"
                            HotpatchEnabled = $True
                            RoleScopeTagIds = @("0")
                            ApprovalSettings = @(
                                @{
                                    ApprovalMethodType = "automatic"
                                    DeferredDeploymentInDay = 2
                                    WindowsQualityUpdateCadence = "monthly"
                                    WindowsQualityUpdateCategory = "all"
                                }
                            )
                            DisplayName = "FakeStringValue"
                            Id = "FakeStringValue"
                        }
                    )
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "The IntuneWindowsUpdateForBusinessHotpatchProfileWindows10 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "FakeStringValue"
                    HotpatchEnabled = $True
                    RoleScopeTagIds = @("0")
                    ApprovalSettings = @(
                        ([MSFT_MicrosoftGraphWindowsQualityUpdateApprovalSetting] @{
                            ApprovalMethodType = "automatic"
                            DeferredDeploymentInDay = 2
                            WindowsQualityUpdateCadence = "monthly"
                            WindowsQualityUpdateCategory = "all"
                        })
                    )
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' -and $Uri -like "*windowsQualityUpdatePolicies*" -and $Uri -notlike "*FakeStringValue*" } -MockWith {
                    return $null
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Method -eq 'GET' -and $Uri -like "*windowsQualityUpdatePolicies/FakeStringValue" } -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessHotpatchProfileWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessHotpatchProfileWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessHotpatchProfileWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 3
            }
        }

        Context -Name "The IntuneWindowsUpdateForBusinessHotpatchProfileWindows10 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "FakeStringValue"
                    HotpatchEnabled = $True
                    RoleScopeTagIds = @("0")
                    ApprovalSettings = @(
                        ([MSFT_MicrosoftGraphWindowsQualityUpdateApprovalSetting] @{
                            ApprovalMethodType = "automatic"
                            DeferredDeploymentInDay = 2
                            WindowsQualityUpdateCadence = "monthly"
                            WindowsQualityUpdateCategory = "all"
                        })
                    )
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessHotpatchProfileWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessHotpatchProfileWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessHotpatchProfileWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 3
            }
        }

        Context -Name "The IntuneWindowsUpdateForBusinessHotpatchProfileWindows10 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "FakeStringValue"
                    HotpatchEnabled = $True
                    RoleScopeTagIds = @("0")
                    ApprovalSettings = @(
                        ([MSFT_MicrosoftGraphWindowsQualityUpdateApprovalSetting] @{
                            ApprovalMethodType = "automatic"
                            DeferredDeploymentInDay = 2
                            WindowsQualityUpdateCadence = "monthly"
                            WindowsQualityUpdateCategory = "all"
                        })
                    )
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessHotpatchProfileWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneWindowsUpdateForBusinessHotpatchProfileWindows10 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "FakeStringValue"
                    HotpatchEnabled = $False # Drift
                    RoleScopeTagIds = @("0")
                    ApprovalSettings = @(
                        ([MSFT_MicrosoftGraphWindowsQualityUpdateApprovalSetting] @{
                            ApprovalMethodType = "automatic"
                            DeferredDeploymentInDay = 2
                            WindowsQualityUpdateCadence = "monthly"
                            WindowsQualityUpdateCategory = "all"
                        })
                    )
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessHotpatchProfileWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessHotpatchProfileWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessHotpatchProfileWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 3
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneWindowsUpdateForBusinessHotpatchProfileWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
