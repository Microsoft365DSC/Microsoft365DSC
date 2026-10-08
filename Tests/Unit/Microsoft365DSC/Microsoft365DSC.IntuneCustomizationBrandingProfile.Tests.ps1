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
    -DscResource "IntuneCustomizationBrandingProfile" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDeviceManagementIntuneBrandingProfile -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementIntuneBrandingProfile -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementIntuneBrandingProfile -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementIntuneBrandingProfile -MockWith {
                return @{
                    CompanyPortalBlockedActions = @(
                        @{
                            Platform = "android"
                            OwnerType = "unknown"
                            Action = "unknown"
                        }
                    )
                    ContactITEmailAddress = "FakeStringValue"
                    ContactITName = "FakeStringValue"
                    ContactITNotes = "FakeStringValue"
                    ContactITPhoneNumber = "FakeStringValue"
                    CustomCanSeePrivacyMessage = "FakeStringValue"
                    CustomCantSeePrivacyMessage = "FakeStringValue"
                    CustomPrivacyMessage = "FakeStringValue"
                    DisableClientTelemetry = $True
                    DisableDeviceCategorySelection = $True
                    DisplayName = "FakeStringValue"
                    EnrollmentAvailability = "availableWithPrompts"
                    Id = "FakeStringValue"
                    IsDefaultProfile = $True
                    IsFactoryResetDisabled = $True
                    IsRemoveDeviceDisabled = $True
                    OnlineSupportSiteName = "FakeStringValue"
                    OnlineSupportSiteUrl = "FakeStringValue"
                    PrivacyUrl = "FakeStringValue"
                    ProfileDescription = "FakeStringValue"
                    ProfileName = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    SendDeviceOwnershipChangePushNotification = $True
                    ShowAzureADEnterpriseApps = $True
                    ShowConfigurationManagerApps = $True
                    ShowDisplayNameNextToLogo = $True
                    ShowLogo = $True
                    ShowOfficeWebApps = $True
                    ThemeColor = @{
                        r = 0
                        g = 0
                        b = 0
                    }
                }
            }

            Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                return @(
                    @{
                        id = 'themeColorLogo'
                        body = @{
                            type = 'image/png'
                            value = 'FakeStringValue1'
                        }
                    }
                    @{
                        id = 'lightBackgroundLogo'
                        body = @{
                            type = 'image/png'
                            value = 'FakeStringValue2'
                        }
                    }
                    @{
                        id = 'landingPageCustomizedImage'
                        body = @{
                            type = 'image/png'
                            value = 'FakeStringValue3'
                        }
                    }
                )
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceManagementIntuneBrandingProfileAssignment -MockWith {
            }
        }

        # Test contexts
        Context -Name "The IntuneCustomizationBrandingProfile should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    CompanyPortalBlockedActions = @(
                        ([MSFT_MicrosoftGraphcompanyPortalBlockedAction] @{
                            Platform = "android"
                            OwnerType = "unknown"
                            Action = "unknown"
                        })
                    )
                    ContactITEmailAddress = "FakeStringValue"
                    ContactITName = "FakeStringValue"
                    ContactITNotes = "FakeStringValue"
                    ContactITPhoneNumber = "FakeStringValue"
                    CustomCanSeePrivacyMessage = "FakeStringValue"
                    CustomCantSeePrivacyMessage = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    EnrollmentAvailability = "availableWithPrompts"
                    Id = "FakeStringValue"
                    LandingPageCustomizedImage = ([MSFT_MicrosoftGraphMimeContent] @{
                        Type = "image/png"
                        Value = 'FakeStringValue3'
                    })
                    LightBackgroundLogo = ([MSFT_MicrosoftGraphMimeContent] @{
                        Type = "image/png"
                        Value = 'FakeStringValue2'
                    })
                    OnlineSupportSiteName = "FakeStringValue"
                    OnlineSupportSiteUrl = "FakeStringValue"
                    PrivacyUrl = "FakeStringValue"
                    ProfileDescription = "FakeStringValue"
                    ProfileName = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    ShowAzureADEnterpriseApps = $True
                    ShowConfigurationManagerApps = $True
                    ShowDisplayNameNextToLogo = $True
                    ShowLogo = $True
                    ShowOfficeWebApps = $True
                    ThemeColor = ([MSFT_MicrosoftGraphrgbColor] @{
                        r = 0
                        g = 0
                        b = 0
                    })
                    ThemeColorLogo = ([MSFT_MicrosoftGraphMimeContent] @{
                        Type = "image/png"
                        Value = 'FakeStringValue1'
                    })
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementIntuneBrandingProfile -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneCustomizationBrandingProfile' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCustomizationBrandingProfile' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCustomizationBrandingProfile' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementIntuneBrandingProfile -Exactly 1
            }
        }

        Context -Name "The IntuneCustomizationBrandingProfile exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    CompanyPortalBlockedActions = @(
                        ([MSFT_MicrosoftGraphcompanyPortalBlockedAction] @{
                            Platform = "android"
                            OwnerType = "unknown"
                            Action = "unknown"
                        })
                    )
                    ContactITEmailAddress = "FakeStringValue"
                    ContactITName = "FakeStringValue"
                    ContactITNotes = "FakeStringValue"
                    ContactITPhoneNumber = "FakeStringValue"
                    CustomCanSeePrivacyMessage = "FakeStringValue"
                    CustomCantSeePrivacyMessage = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    EnrollmentAvailability = "availableWithPrompts"
                    Id = "FakeStringValue"
                    LandingPageCustomizedImage = ([MSFT_MicrosoftGraphMimeContent] @{
                        Type = "image/png"
                        Value = 'FakeStringValue3'
                    })
                    LightBackgroundLogo = ([MSFT_MicrosoftGraphMimeContent] @{
                        Type = "image/png"
                        Value = 'FakeStringValue2'
                    })
                    OnlineSupportSiteName = "FakeStringValue"
                    OnlineSupportSiteUrl = "FakeStringValue"
                    PrivacyUrl = "FakeStringValue"
                    ProfileDescription = "FakeStringValue"
                    ProfileName = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    ShowAzureADEnterpriseApps = $True
                    ShowConfigurationManagerApps = $True
                    ShowDisplayNameNextToLogo = $True
                    ShowLogo = $True
                    ShowOfficeWebApps = $True
                    ThemeColor = ([MSFT_MicrosoftGraphrgbColor] @{
                        r = 0
                        g = 0
                        b = 0
                    })
                    ThemeColorLogo = ([MSFT_MicrosoftGraphMimeContent] @{
                        Type = "image/png"
                        Value = 'FakeStringValue1'
                    })
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneCustomizationBrandingProfile' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCustomizationBrandingProfile' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCustomizationBrandingProfile' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementIntuneBrandingProfile -Exactly 1
            }
        }

        Context -Name "The IntuneCustomizationBrandingProfile Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    CompanyPortalBlockedActions = @(
                        ([MSFT_MicrosoftGraphcompanyPortalBlockedAction] @{
                            Platform = "android"
                            OwnerType = "unknown"
                            Action = "unknown"
                        })
                    )
                    ContactITEmailAddress = "FakeStringValue"
                    ContactITName = "FakeStringValue"
                    ContactITNotes = "FakeStringValue"
                    ContactITPhoneNumber = "FakeStringValue"
                    CustomCanSeePrivacyMessage = "FakeStringValue"
                    CustomCantSeePrivacyMessage = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    EnrollmentAvailability = "availableWithPrompts"
                    Id = "FakeStringValue"
                    LandingPageCustomizedImage = ([MSFT_MicrosoftGraphMimeContent] @{
                        Type = "image/png"
                        Value = 'FakeStringValue3'
                    })
                    LightBackgroundLogo = ([MSFT_MicrosoftGraphMimeContent] @{
                        Type = "image/png"
                        Value = 'FakeStringValue2'
                    })
                    OnlineSupportSiteName = "FakeStringValue"
                    OnlineSupportSiteUrl = "FakeStringValue"
                    PrivacyUrl = "FakeStringValue"
                    ProfileDescription = "FakeStringValue"
                    ProfileName = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    ShowAzureADEnterpriseApps = $True
                    ShowConfigurationManagerApps = $True
                    ShowDisplayNameNextToLogo = $True
                    ShowLogo = $True
                    ShowOfficeWebApps = $True
                    ThemeColor = ([MSFT_MicrosoftGraphrgbColor] @{
                        r = 0
                        g = 0
                        b = 0
                    })
                    ThemeColorLogo = ([MSFT_MicrosoftGraphMimeContent] @{
                        Type = "image/png"
                        Value = 'FakeStringValue1'
                    })
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCustomizationBrandingProfile' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneCustomizationBrandingProfile exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    CompanyPortalBlockedActions = @(
                        ([MSFT_MicrosoftGraphcompanyPortalBlockedAction] @{
                            Platform = "android"
                            OwnerType = "unknown"
                            Action = "unknown"
                        })
                    )
                    ContactITEmailAddress = "FakeStringValue"
                    ContactITName = "FakeStringValue"
                    ContactITNotes = "FakeStringValue"
                    ContactITPhoneNumber = "FakeStringValue"
                    CustomCanSeePrivacyMessage = "FakeStringValue"
                    CustomCantSeePrivacyMessage = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    EnrollmentAvailability = "availableWithPrompts"
                    Id = "FakeStringValue"
                    LandingPageCustomizedImage = ([MSFT_MicrosoftGraphMimeContent] @{
                        Type = "image/png"
                        Value = 'FakeStringValue2' # Drift
                    })
                    LightBackgroundLogo = ([MSFT_MicrosoftGraphMimeContent] @{
                        Type = "image/png"
                        Value = 'FakeStringValue2'
                    })
                    OnlineSupportSiteName = "FakeStringValue"
                    OnlineSupportSiteUrl = "FakeStringValue"
                    PrivacyUrl = "FakeStringValue"
                    ProfileDescription = "FakeStringValue"
                    ProfileName = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    ShowAzureADEnterpriseApps = $True
                    ShowConfigurationManagerApps = $True
                    ShowDisplayNameNextToLogo = $True
                    ShowLogo = $True
                    ShowOfficeWebApps = $True
                    ThemeColor = ([MSFT_MicrosoftGraphrgbColor] @{
                        r = 0
                        g = 0
                        b = 0
                    })
                    ThemeColorLogo = ([MSFT_MicrosoftGraphMimeContent] @{
                        Type = "image/png"
                        Value = 'FakeStringValue1'
                    })
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneCustomizationBrandingProfile' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCustomizationBrandingProfile' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneCustomizationBrandingProfile' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementIntuneBrandingProfile -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneCustomizationBrandingProfile' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
