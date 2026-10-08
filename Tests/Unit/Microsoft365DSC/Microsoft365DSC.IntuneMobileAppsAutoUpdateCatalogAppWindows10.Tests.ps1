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
    -DscResource 'IntuneMobileAppsAutoUpdateCatalogAppWindows10' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Add-M365DSCTelemetryEvent -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceAppManagementMobileApp -MockWith {
                return @{
                    Id = 'FakeStringValue'
                }
            }

            Mock -CommandName Update-MgBetaDeviceAppManagementMobileApp -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceAppManagementMobileApp -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementMobileApp -MockWith {
                return @{
                    Categories                      = @(
                        @{
                            id          = 'FakeCategoryId'
                            displayName = 'Productivity'
                        }
                    )
                    Assignments                     = @(
                        @{
                            dataType = '#microsoft.graph.allLicensedUsersAssignmentTarget'
                            intent   = 'available'
                        }
                    )
                    Description                     = 'FakeStringValue'
                    Developer                       = 'FakeStringValue'
                    DisplayName                     = 'FakeStringValue'
                    Id                              = 'FakeStringValue'
                    InformationUrl                  = 'FakeStringValue'
                    IsFeatured                      = $true
                    LargeIcon                       = @{
                        type  = 'FakeStringValue'
                        value = 'FakeStringValue'
                    }
                    Notes                           = 'FakeStringValue'
                    Owner                           = 'FakeStringValue'
                    PrivacyInformationUrl           = 'FakeStringValue'
                    Publisher                       = 'FakeStringValue'
                    RoleScopeTagIds                 = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    '@odata.type'                   = '#microsoft.graph.windowsAutoUpdateCatalogApp'
                    allowedArchitectures            = 'none'
                    installExperience               = @{
                        deviceRestartBehavior = 'basedOnReturnCode'
                        runAsAccount          = 'system'
                    }
                    mobileAppCatalogPackageBranchId = 'FakeStringValue'
                }
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementMobileAppAssignment -MockWith {
            }

            Mock -CommandName Update-DeviceAppManagementAppCategory -MockWith {
            }

            Mock -CommandName Update-DeviceAppManagementPolicyAssignment -MockWith {
            }

            Mock -CommandName Wait-M365DSCIntuneMobileAppPublished -MockWith {
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                return @{}
            }

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
                return "IntuneMobileAppsAutoUpdateCatalogAppWindows10 'TestInstance' {}`r`n"
            }

            $Script:exportedInstance = $null
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The instance should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                     = 'FakeStringValue'
                    Developer                       = 'FakeStringValue'
                    DisplayName                     = 'FakeStringValue'
                    Id                              = 'FakeStringValue'
                    InformationUrl                  = 'FakeStringValue'
                    InstallExperience               = @{
                        DeviceRestartBehavior = 'basedOnReturnCode'
                        RunAsAccount          = 'system'
                    }
                    IsFeatured                      = $true
                    LargeIcon                       = @{
                        Type  = 'FakeStringValue'
                        Value = 'FakeStringValue'
                    }
                    MobileAppCatalogPackageBranchId = 'FakeStringValue'
                    Notes                           = 'FakeStringValue'
                    Owner                           = 'FakeStringValue'
                    PrivacyInformationUrl           = 'FakeStringValue'
                    Publisher                       = 'FakeStringValue'
                    RoleScopeTagIds                 = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    Categories                      = @(
                        [MSFT_DeviceManagementMobileAppCategory] @{
                            DisplayName = 'Productivity'
                        }
                    )
                    Ensure                          = 'Present'
                    Credential                      = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementMobileApp -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementMobileApp -ParameterFilter { -not [System.String]::IsNullOrEmpty($Filter) } -MockWith {
                    return @{
                        '@odata.type' = '#microsoft.graph.win32CatalogApp'
                        id            = 'FakeStringValue'
                        displayName   = 'FakeStringValue'
                    }
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsAutoUpdateCatalogAppWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName Get-MgBetaDeviceAppManagementMobileApp -ParameterFilter { $Filter -eq "DisplayName eq 'FakeStringValue'" }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsAutoUpdateCatalogAppWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsAutoUpdateCatalogAppWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceAppManagementMobileApp' -Exactly 1
                Should -Invoke -CommandName Wait-M365DSCIntuneMobileAppPublished -Exactly 1
                Should -Invoke -CommandName 'Update-DeviceAppManagementAppCategory' -Exactly 1
            }
        }

        Context -Name 'The instance exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'FakeStringValue'
                    Ensure      = 'Absent'
                    Credential  = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsAutoUpdateCatalogAppWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaDeviceAppManagementMobileApp'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsAutoUpdateCatalogAppWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsAutoUpdateCatalogAppWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MgBetaDeviceAppManagementMobileApp' -Exactly 1
            }
        }

        Context -Name 'The instance exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                     = 'FakeStringValue'
                    Developer                       = 'FakeStringValue'
                    DisplayName                     = 'FakeStringValue'
                    Id                              = 'FakeStringValue'
                    InformationUrl                  = 'FakeStringValue'
                    InstallExperience               = @{
                        DeviceRestartBehavior = 'basedOnReturnCode'
                        RunAsAccount          = 'system'
                    }
                    IsFeatured                      = $true
                    LargeIcon                       = @{
                        Type  = 'FakeStringValue'
                        Value = 'FakeStringValue'
                    }
                    MobileAppCatalogPackageBranchId = 'FakeStringValue'
                    Notes                           = 'FakeStringValue'
                    Owner                           = 'FakeStringValue'
                    PrivacyInformationUrl           = 'FakeStringValue'
                    Publisher                       = 'FakeStringValue'
                    RoleScopeTagIds                 = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    Categories                      = @(
                        [MSFT_DeviceManagementMobileAppCategory] @{
                            DisplayName = 'Productivity'
                        }
                    )
                    Ensure                          = 'Present'
                    Credential                      = $Credential
                }
            }

            It 'Should return the expected values from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsAutoUpdateCatalogAppWindows10' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.Description | Should -Be 'FakeStringValue'
                $result.Categories.DisplayName | Should -Be 'Productivity'
                $result.Developer | Should -Be 'FakeStringValue'
                $result.DisplayName | Should -Be 'FakeStringValue'
                $result.Id | Should -Be 'FakeStringValue'
                $result.InformationUrl | Should -Be 'FakeStringValue'
                $result.IsFeatured | Should -Be $true
                $result.MobileAppCatalogPackageBranchId | Should -Be 'FakeStringValue'
                $result.Notes | Should -Be 'FakeStringValue'
                $result.Owner | Should -Be 'FakeStringValue'
                $result.PrivacyInformationUrl | Should -Be 'FakeStringValue'
                $result.Publisher | Should -Be 'FakeStringValue'
                $result.RoleScopeTagIds | Should -Be @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                Should -Invoke -CommandName 'Get-MgBetaDeviceAppManagementMobileApp'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsAutoUpdateCatalogAppWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                     = 'FakeStringValueDrift' # Updated property
                    Developer                       = 'FakeStringValue'
                    DisplayName                     = 'FakeStringValue'
                    Id                              = 'FakeStringValue'
                    InformationUrl                  = 'FakeStringValue'
                    InstallExperience               = @{
                        DeviceRestartBehavior = 'basedOnReturnCode'
                        RunAsAccount          = 'system'
                    }
                    IsFeatured                      = $true
                    LargeIcon                       = @{
                        Type  = 'FakeStringValue'
                        Value = 'FakeStringValue'
                    }
                    MobileAppCatalogPackageBranchId = 'FakeStringValue'
                    Notes                           = 'FakeStringValue'
                    Owner                           = 'FakeStringValue'
                    PrivacyInformationUrl           = 'FakeStringValue'
                    Publisher                       = 'FakeStringValue'
                    RoleScopeTagIds                 = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
                    Categories                      = @(
                        [MSFT_DeviceManagementMobileAppCategory] @{
                            DisplayName = 'Business'
                        }
                    )
                    Ensure                          = 'Present'
                    Credential                      = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsAutoUpdateCatalogAppWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaDeviceAppManagementMobileApp'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsAutoUpdateCatalogAppWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsAutoUpdateCatalogAppWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaDeviceAppManagementMobileApp' -Exactly 1
                Should -Invoke -CommandName 'Update-DeviceAppManagementAppCategory' -Exactly 1 -ParameterFilter { $Compare }
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

            It 'Should reverse engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneMobileAppsAutoUpdateCatalogAppWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                Should -Invoke -CommandName 'Get-MgBetaDeviceAppManagementMobileApp'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
