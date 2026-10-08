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
    -DscResource "IntuneMobileAppsManagedGooglePlayApp" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Add-MgBetaDeviceManagementAndroidManagedStoreAccountEnterpriseSettingApp -MockWith {
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            Mock -CommandName Start-Sleep -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceAppManagementMobileApp -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceAppManagementMobileApp -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementMobileApp -MockWith {
                return @{
                    supportsOemConfig = $True
                    appIdentifier = "FakeStringValue"
                    isSystemApp = $False
                    appTracks = @(
                        @{
                            trackAlias = "FakeStringValue"
                            trackId = "FakeStringValue"
                        }
                    )
                    '@odata.type' = "#microsoft.graph.androidManagedStoreApp"
                    packageId = "FakeStringValue"
                    appStoreUrl = "FakeStringValue"
                    usedLicenseCount = 25
                    isPrivate = $True
                    totalLicenseCount = 25
                    dependentAppCount = 25
                    description = "FakeStringValue"
                    developer = "FakeStringValue"
                    displayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    informationUrl = "FakeStringValue"
                    isFeatured = $True
                    LargeIcon = @{
                        Type = "FakeStringValue"
                        Value = "VGVzdA=="
                    }
                    Notes = "FakeStringValue"
                    Owner = "FakeStringValue"
                    PrivacyInformationUrl = "FakeStringValue"
                    Publisher = "FakeStringValue"
                    PublishingState = "notPublished"
                    RoleScopeTagIds = @("FakeStringValue")
                    SupersededAppCount = 25
                    SupersedingAppCount = 25
                    UploadState = 25
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Wait-M365DSCIntuneMobileAppPublished -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceAppManagementMobileAppAssignment -MockWith {
            }

        }

        # Test contexts
        Context -Name "The IntuneMobileAppsManagedGooglePlayApp should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    PackageId = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                $Script:PackageApproved = $false
                Mock -CommandName Add-MgBetaDeviceManagementAndroidManagedStoreAccountEnterpriseSettingApp -MockWith {
                    $Script:PackageApproved = $true
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementMobileApp -MockWith {
                    if ($Script:PackageApproved)
                    {
                        return @{
                            '@odata.type' = '#microsoft.graph.androidManagedStoreApp'
                            displayName   = 'FakeStringValue'
                            Id            = 'FakeStringValue'
                            packageId     = 'FakeStringValue'
                        }
                    }
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsManagedGooglePlayApp' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsManagedGooglePlayApp' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsManagedGooglePlayApp' -Property $testParams).Set()
                Should -Invoke -CommandName Add-MgBetaDeviceManagementAndroidManagedStoreAccountEnterpriseSettingApp -Exactly 1
                Should -Invoke -CommandName Wait-M365DSCIntuneMobileAppPublished -Exactly 1
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -ParameterFilter { $Uri -like '*/syncApps' }
                Should -Invoke -CommandName Update-MgBetaDeviceAppManagementMobileApp -Exactly 1 -ParameterFilter {
                    $BodyParameter.Keys.Count -eq 2 -and $BodyParameter.ContainsKey('roleScopeTagIds')
                }
            }
            It 'Throws when the approved package has no app with the DisplayName' {
                $Script:PackageApproved = $false
                Mock -CommandName Add-MgBetaDeviceManagementAndroidManagedStoreAccountEnterpriseSettingApp -MockWith {
                }

                { (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsManagedGooglePlayApp' -Property $testParams).Set() } |
                    Should -Throw -ExpectedMessage '*DisplayName must match the name of the app in the store*'
            }
        }

        Context -Name "The IntuneMobileAppsManagedGooglePlayApp exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    PackageId = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsManagedGooglePlayApp' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsManagedGooglePlayApp' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsManagedGooglePlayApp' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceAppManagementMobileApp -Exactly 1
            }
        }

        Context -Name "The IntuneMobileAppsManagedGooglePlayApp Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    PackageId = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsManagedGooglePlayApp' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneMobileAppsManagedGooglePlayApp exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    PackageId = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue_New") # Drift
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsManagedGooglePlayApp' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsManagedGooglePlayApp' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsManagedGooglePlayApp' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceAppManagementMobileApp -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneMobileAppsManagedGooglePlayApp' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
