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
    -DscResource 'SPOTenantSettings' -GenericStubModule $GenericStubPath

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

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Update-MgAdminSharepointSetting -MockWith {
                return $null
            }

            Mock -CommandName Invoke-PnPSPRestMethod -MockWith {
                return $null
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'SPO Tenant settings are not configured' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                              = 'Yes'
                    Credential                                    = $Credential
                    MinCompatibilityLevel                         = 16
                    MaxCompatibilityLevel                         = 16
                    SearchResolveExactEmailOrUPN                  = $false
                    OfficeClientADALDisabled                      = $false
                    LegacyAuthProtocolsEnabled                    = $true
                    SignInAccelerationDomain                      = ''
                    UsePersistentCookiesForExplorerView           = $false
                    PublicCdnEnabled                              = $false
                    PublicCdnAllowedFileTypes                     = 'CSS,EOT,GIF,ICO,JPEG,JPG,JS,MAP,PNG,SVG,TTF,WOFF'
                    UseFindPeopleInPeoplePicker                   = $false
                    NotificationsInSharePointEnabled              = $true
                    OwnerAnonymousNotification                    = $true
                    ApplyAppEnforcedRestrictionsToAdHocRecipients = $true
                    FilePickerExternalImageSearchEnabled          = $true
                    HideDefaultThemes                             = $false
                    EnableSensitivityLabelForOneNote              = $true
                    EnableSensitivityLabelForVideoFiles           = $true
                    TenantDefaultTimeZone                         = "(UTC-05:00) Eastern Time (US and Canada)"
                }

                Mock -CommandName Set-PnPTenant -MockWith {
                    return @{
                        CompatibilityRange                            = '16,16'
                        SearchResolveExactEmailOrUPN                  = $false
                        OfficeClientADALDisabled                      = $false
                        LegacyAuthProtocolsEnabled                    = $true
                        SignInAccelerationDomain                      = ''
                        UsePersistentCookiesForExplorerView           = $false
                        PublicCdnEnabled                              = $false
                        PublicCdnAllowedFileTypes                     = 'CSS,EOT,GIF,ICO,JPEG,JPG,JS,MAP,PNG,SVG,TTF,WOFF'
                        UseFindPeopleInPeoplePicker                   = $false
                        NotificationsInSharePointEnabled              = $true
                        OwnerAnonymousNotification                    = $true
                        ApplyAppEnforcedRestrictionsToAdHocRecipients = $true
                        FilePickerExternalImageSearchEnabled          = $true
                        HideDefaultThemes                             = $true
                    }
                }

                Mock -CommandName Get-PnPTenant -MockWith {
                    return @{
                        CompatibilityRange                            = '16,16'
                        SearchResolveExactEmailOrUPN                  = $false
                        OfficeClientADALDisabled                      = $false
                        LegacyAuthProtocolsEnabled                    = $true
                        SignInAccelerationDomain                      = ''
                        UsePersistentCookiesForExplorerView           = $false
                        PublicCdnEnabled                              = $false
                        PublicCdnAllowedFileTypes                     = 'CSS,EOT,GIF,ICO,JPEG,JPG,JS,MAP,PNG,SVG,TTF,WOFF'
                        UseFindPeopleInPeoplePicker                   = $false
                        NotificationsInSharePointEnabled              = $true
                        OwnerAnonymousNotification                    = $true
                        ApplyAppEnforcedRestrictionsToAdHocRecipients = $true
                        FilePickerExternalImageSearchEnabled          = $true
                        HideDefaultThemes                             = $true
                        EnableSensitivityLabelForOneNote              = $false
                        EnableSensitivityLabelForVideoFiles           = $false
                    }
                }

                Mock -CommandName Get-MgAdminSharepointSetting -MockWith {
                    return @{
                        DefaultTimeZone                               = "(UTC-05:00) Eastern Time (US and Canada)"
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOTenantSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Sets the tenant AccessControl settings in Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOTenantSettings' -Property $testParams).Set()
            }
        }

        Context -Name 'SPO Tenant settings using invalid TenantDefaultTimezone' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                              = 'Yes'
                    Credential                                    = $Credential
                    MinCompatibilityLevel                         = 16
                    MaxCompatibilityLevel                         = 16
                    SearchResolveExactEmailOrUPN                  = $false
                    OfficeClientADALDisabled                      = $false
                    LegacyAuthProtocolsEnabled                    = $true
                    SignInAccelerationDomain                      = ''
                    UsePersistentCookiesForExplorerView           = $false
                    PublicCdnEnabled                              = $false
                    PublicCdnAllowedFileTypes                     = 'CSS,EOT,GIF,ICO,JPEG,JPG,JS,MAP,PNG,SVG,TTF,WOFF'
                    UseFindPeopleInPeoplePicker                   = $false
                    NotificationsInSharePointEnabled              = $true
                    OwnerAnonymousNotification                    = $true
                    ApplyAppEnforcedRestrictionsToAdHocRecipients = $true
                    FilePickerExternalImageSearchEnabled          = $true
                    HideDefaultThemes                             = $false
                    EnableSensitivityLabelForOneNote              = $true
                    EnableSensitivityLabelForVideoFiles           = $true
                    TenantDefaultTimeZone                         = "(UT-05:00)"
                }

                Mock -CommandName Set-PnPTenant -MockWith {
                    return @{
                        CompatibilityRange                            = '16,16'
                        SearchResolveExactEmailOrUPN                  = $false
                        OfficeClientADALDisabled                      = $false
                        LegacyAuthProtocolsEnabled                    = $true
                        SignInAccelerationDomain                      = ''
                        UsePersistentCookiesForExplorerView           = $false
                        PublicCdnEnabled                              = $false
                        PublicCdnAllowedFileTypes                     = 'CSS,EOT,GIF,ICO,JPEG,JPG,JS,MAP,PNG,SVG,TTF,WOFF'
                        UseFindPeopleInPeoplePicker                   = $false
                        NotificationsInSharePointEnabled              = $true
                        OwnerAnonymousNotification                    = $true
                        ApplyAppEnforcedRestrictionsToAdHocRecipients = $true
                        FilePickerExternalImageSearchEnabled          = $true
                        HideDefaultThemes                             = $true
                    }
                }

                Mock -CommandName Get-PnPTenant -MockWith {
                    return @{
                        CompatibilityRange                            = '16,16'
                        SearchResolveExactEmailOrUPN                  = $false
                        OfficeClientADALDisabled                      = $false
                        LegacyAuthProtocolsEnabled                    = $true
                        SignInAccelerationDomain                      = ''
                        UsePersistentCookiesForExplorerView           = $false
                        PublicCdnEnabled                              = $false
                        PublicCdnAllowedFileTypes                     = 'CSS,EOT,GIF,ICO,JPEG,JPG,JS,MAP,PNG,SVG,TTF,WOFF'
                        UseFindPeopleInPeoplePicker                   = $false
                        NotificationsInSharePointEnabled              = $true
                        OwnerAnonymousNotification                    = $true
                        ApplyAppEnforcedRestrictionsToAdHocRecipients = $true
                        FilePickerExternalImageSearchEnabled          = $true
                        HideDefaultThemes                             = $true
                        EnableSensitivityLabelForOneNote              = $true
                        EnableSensitivityLabelForVideoFiles           = $true
                    }
                }

                Mock -CommandName Get-MgAdminSharepointSetting -MockWith {
                    return @{
                        DefaultTimeZone                               = "(UTC-05:00) Eastern Time (US and Canada)"
                    }
                }

                Mock -CommandName Update-MgAdminSharepointSetting -MockWith {
                    throw "Invalid TenantDefaultTimezone '(UT-05:00)'"
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOTenantSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Sets the tenant AccessControl settings in Set method should throw' {
                {(New-M365DSCResourceInstance -ResourceName 'SPOTenantSettings' -Property $testParams).Set()} | Should -Throw
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPTenant -MockWith {
                    return @{
                        CompatibilityRange                            = '16,16'
                        SearchResolveExactEmailOrUPN                  = $false
                        OfficeClientADALDisabled                      = $false
                        LegacyAuthProtocolsEnabled                    = $true
                        SignInAccelerationDomain                      = ''
                        UsePersistentCookiesForExplorerView           = $false
                        PublicCdnEnabled                              = $false
                        PublicCdnAllowedFileTypes                     = 'CSS,EOT,GIF,ICO,JPEG,JPG,JS,MAP,PNG,SVG,TTF,WOFF'
                        UseFindPeopleInPeoplePicker                   = $false
                        NotificationsInSharePointEnabled              = $true
                        OwnerAnonymousNotification                    = $true
                        ApplyAppEnforcedRestrictionsToAdHocRecipients = $true
                        FilePickerExternalImageSearchEnabled          = $true
                        HideDefaultThemes                             = $false
                        EnableSensitivityLabelForOneNote              = $true
                        EnableSensitivityLabelForVideoFiles           = $true
                    }
                }

                Mock -CommandName Get-MgAdminSharepointSetting -MockWith {
                    return @{
                        DefaultTimeZone                               = "(UTC-05:00) Eastern Time (US and Canada)"
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOTenantSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }#inmodulescope
}#describe

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
