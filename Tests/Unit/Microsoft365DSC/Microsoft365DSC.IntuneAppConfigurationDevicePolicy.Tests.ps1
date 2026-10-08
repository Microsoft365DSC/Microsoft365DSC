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
    -DscResource "IntuneAppConfigurationDevicePolicy" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceAppManagementMobileAppConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceAppManagementMobileAppConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceAppManagementMobileAppConfiguration -MockWith {
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementMobileApp -MockWith {
                return @{
                    Id = "FakeStringValue"
                    packageId = "FakeStringValue"
                    '@odata.type' = "#microsoft.graph.androidManagedStoreApp"
                }
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementMobileAppConfiguration -MockWith {
                return @{
                    appSupportsOemConfig = $True
                    '@odata.type' = "#microsoft.graph.androidManagedStoreAppConfiguration"
                    payloadJson = "eyJ0ZXN0IjoidmFsdWUifQ=="
                    profileApplicability = "default"
                    permissionActions = @(
                        @{
                            permission = "FakeStringValue"
                            action = "prompt"
                        }
                    )
                    packageId = "FakeStringValue"
                    connectedAppsEnabled = $True
                    credentialProviderRoleState = "allowed"
                    createdDateTime = "2023-01-01T00:00:00.0000000+01:00"
                    description = "FakeStringValue"
                    displayName = "FakeStringValue"
                    id = "FakeStringValue"
                    lastModifiedDateTime = "2023-01-01T00:00:00.0000000+01:00"
                    roleScopeTagIds = @("FakeStringValue")
                    targetedMobileApps = @("FakeStringValue")
                    version = 25
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceAppManagementMobileAppConfigurationAssignment -MockWith {
            }
        }
        # Test contexts
        Context -Name "The IntuneAppConfigurationDevicePolicy should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ConnectedAppsEnabled = $True
                    CredentialProviderRoleState = "allowed"
                    description = "FakeStringValue"
                    displayName = "FakeStringValue"
                    id = "FakeStringValue"
                    PackageId = "FakeStringValue"
                    PayloadJson = "{`"test`":`"value`"}"
                    permissionActions = @(
                        ([MSFT_MicrosoftGraphandroidPermissionAction] @{
                            permission = "FakeStringValue"
                            action = "prompt"
                        })
                    )
                    profileApplicability = "default"
                    roleScopeTagIds = @("FakeStringValue")
                    targetedMobileApps = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementMobileAppConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationDevicePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationDevicePolicy' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationDevicePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceAppManagementMobileAppConfiguration -Exactly 1
            }
        }

        Context -Name "The IntuneAppConfigurationDevicePolicy exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ConnectedAppsEnabled = $True
                    CredentialProviderRoleState = "allowed"
                    description = "FakeStringValue"
                    displayName = "FakeStringValue"
                    id = "FakeStringValue"
                    PackageId = "FakeStringValue"
                    PayloadJson = "{`"test`":`"value`"}"
                    permissionActions = @(
                        ([MSFT_MicrosoftGraphandroidPermissionAction] @{
                            permission = "FakeStringValue"
                            action = "prompt"
                        })
                    )
                    profileApplicability = "default"
                    roleScopeTagIds = @("FakeStringValue")
                    targetedMobileApps = @("FakeStringValue")
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationDevicePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationDevicePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationDevicePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceAppManagementMobileAppConfiguration -Exactly 1
            }
        }
        Context -Name "The IntuneAppConfigurationDevicePolicy Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ConnectedAppsEnabled = $True
                    CredentialProviderRoleState = "allowed"
                    description = "FakeStringValue"
                    displayName = "FakeStringValue"
                    id = "FakeStringValue"
                    PackageId = "FakeStringValue"
                    PayloadJson = "{`"test`":`"value`"}"
                    permissionActions = @(
                        ([MSFT_MicrosoftGraphandroidPermissionAction] @{
                            permission = "FakeStringValue"
                            action = "prompt"
                        })
                    )
                    profileApplicability = "default"
                    roleScopeTagIds = @("FakeStringValue")
                    targetedMobileApps = @("FakeStringValue")
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationDevicePolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneAppConfigurationDevicePolicy exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @()
                    ConnectedAppsEnabled = $True
                    CredentialProviderRoleState = "notConfigured" # Updated property
                    description = "FakeStringValue"
                    displayName = "FakeStringValue"
                    id = "FakeStringValue"
                    PackageId = "FakeStringValue"
                    PayloadJson = "{`"test`":`"value`"}"
                    permissionActions = @(
                        ([MSFT_MicrosoftGraphandroidPermissionAction] @{
                            permission = "OtherPermission" # Updated property
                            action = "prompt"
                        })
                    )
                    profileApplicability = "default"
                    roleScopeTagIds = @("FakeStringValue")
                    targetedMobileApps = @("FakeStringValue")
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationDevicePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationDevicePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationDevicePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceAppManagementMobileAppConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneAppConfigurationDevicePolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
