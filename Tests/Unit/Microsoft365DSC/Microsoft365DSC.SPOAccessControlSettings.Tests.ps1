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
    -DscResource 'SPOAccessControlSettings' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Invoke-PnPSPRestMethod -MockWith {
                return @{
                    DelegateRestrictedAccessControlConfiguration    = $false
                    DelegateRestrictedContentDiscoveryConfiguration = $true
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Write-Warning -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'PNP AccessControl settings are not configured' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential                                         = $Credential
                    IsSingleInstance                                   = 'Yes'
                    EnableRestrictedAccessControl                      = $true
                    DisplayStartASiteOption                            = $false
                    StartASiteFormUrl                                  = 'https://o365dsc1.sharepoint.com'
                    IPAddressEnforcement                               = $false
                    #IPAddressAllowList            = "" #would generate an error while writing this resource
                    IPAddressWACTokenLifetime                          = 15
                    DisallowInfectedFileDownload                       = $false
                    ExternalServicesEnabled                            = $true
                    EmailAttestationRequired                           = $false
                    EmailAttestationReAuthDays                         = 30
                    AppOnlyBypassPeoplePickerPolicies                  = $false
                    BlockAppAccessWithAuthenticationContext            = $false
                    ConditionalAccessPolicy                            = 'AllowLimitedAccess'
                    DelegateRestrictedAccessControlManagement          = $true
                    DelegateRestrictedContentDiscoverabilityManagement = $false
                    LimitedAccessFileType                              = 'WebPreviewableFiles'
                    RestrictedAccessControlForOneDriveErrorHelpLink    = 'https://contoso.com/help'
                }

                Mock -CommandName Set-PnPTenant -MockWith {
                    return @{
                        DisplayStartASiteOption       = $false
                        EnableRestrictedAccessControl = $true
                        StartASiteFormUrl             = 'https://o365dsc1.sharepoint.com'
                        IPAddressEnforcement          = $false
                        #IPAddressAllowList            = "" #would generate an error while writing this resource
                        IPAddressWACTokenLifetime     = 15
                        DisallowInfectedFileDownload  = $false
                        ExternalServicesEnabled       = $true
                        EmailAttestationRequired      = $false
                        EmailAttestationReAuthDays    = 30
                    }
                }

                Mock -CommandName Set-PnPTenant -ParameterFilter { $DelegateRestrictedAccessControlManagement -eq $true } -MockWith {
                    throw 'You need a SharePoint Advanced Management license to perform this action.'
                }

                Mock -CommandName Get-PnPTenant -MockWith {
                    return @{
                        DisplayStartASiteOption                         = $true
                        EnableRestrictedAccessControl                   = $true
                        StartASiteFormUrl                               = 'https://o365dsc1.sharepoint.com'
                        IPAddressEnforcement                            = $false
                        #IPAddressAllowList            = "" #would generate an error while writing this resource
                        IPAddressWACTokenLifetime                       = 20
                        DisallowInfectedFileDownload                    = $false
                        ExternalServicesEnabled                         = $true
                        EmailAttestationRequired                        = $false
                        EmailAttestationReAuthDays                      = 29
                        AppOnlyBypassPeoplePickerPolicies               = $false
                        BlockAppAccessWithAuthenticationContext         = $false
                        ConditionalAccessPolicy                         = 'AllowLimitedAccess'
                        LimitedAccessFileType                           = 'OtherFiles'
                        RestrictedAccessControlForOneDriveErrorHelpLink = 'None'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOAccessControlSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Sets the tenant AccessControl settings in Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOAccessControlSettings' -Property $testParams).Set()
                Should -Invoke -CommandName Set-PnPTenant -Times 1 -Exactly -ParameterFilter {
                    $LimitedAccessFileType -eq 'WebPreviewableFiles' -and
                    $RestrictedAccessControlForOneDriveErrorHelpLink -eq 'https://contoso.com/help' -and
                    -not $PSBoundParameters.ContainsKey('DelegateRestrictedAccessControlManagement')
                }
                Should -Invoke -CommandName Set-PnPTenant -Times 1 -Exactly -ParameterFilter {
                    $DelegateRestrictedAccessControlManagement -eq $true -and
                    -not $PSBoundParameters.ContainsKey('LimitedAccessFileType')
                }
                Should -Invoke -CommandName Write-Warning -Times 1 -Exactly -ParameterFilter {
                    $Message -like '*SharePoint Advanced Management license*'
                }
            }
        }

        Context -Name 'PNP AccessControl settings are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential                        = $Credential
                    IsSingleInstance                  = 'Yes'
                    EnableRestrictedAccessControl     = $true
                    LimitedAccessFileType             = 'OfficeOnlineFilesOnly'
                    AppOnlyBypassPeoplePickerPolicies = $true
                }

                Mock -CommandName Get-PnPTenant -MockWith {
                    return @{
                        EnableRestrictedAccessControl                   = $true
                        ConditionalAccessPolicy                         = 'AllowFullAccess'
                        LimitedAccessFileType                           = 'WebPreviewableFiles'
                        AppOnlyBypassPeoplePickerPolicies               = $true
                        BlockAppAccessWithAuthenticationContext         = $true
                        RestrictedAccessControlForOneDriveErrorHelpLink = 'https://contoso.com/help'
                    }
                }
            }

            It 'Should return the EnableRestrictedAccessControl value from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'SPOAccessControlSettings' -Property $testParams).Get().ToHashtable()
                $result.EnableRestrictedAccessControl | Should -Be $true
                $result.AppOnlyBypassPeoplePickerPolicies | Should -Be $true
                $result.DelegateRestrictedAccessControlManagement | Should -Be $false
                $result.DelegateRestrictedContentDiscoverabilityManagement | Should -Be $true
                $result.LimitedAccessFileType | Should -Be 'WebPreviewableFiles'
                $result.BlockAppAccessWithAuthenticationContext | Should -Be $true
                $result.RestrictedAccessControlForOneDriveErrorHelpLink | Should -Be 'https://contoso.com/help'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOAccessControlSettings' -Property $testParams).Test() | Should -Be $true
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
                        DisplayStartASiteOption      = $false
                        StartASiteFormUrl            = 'https://o365dsc1.sharepoint.com'
                        IPAddressEnforcement         = $false
                        #IPAddressAllowList           = "" #would generate an error while writing this resource
                        IPAddressWACTokenLifetime    = 15
                        DisallowInfectedFileDownload = $false
                        ExternalServicesEnabled      = $true
                        EmailAttestationRequired     = $false
                        EmailAttestationReAuthDays   = 30
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOAccessControlSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }#inmodulescope
}#describe

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
