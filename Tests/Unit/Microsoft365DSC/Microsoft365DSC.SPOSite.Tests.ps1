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
    -DscResource 'SPOSite' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@contoso.onmicrosoft.com', $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Set-PnPTenantSite -MockWith {
            }

            Mock -CommandName Add-PnPHubSiteAssociation -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Start-Sleep -MockWith { }

            Mock -CommandName Get-PnPContext -MockWith {
                $context = @{} | Add-Member -MemberType ScriptMethod -Name ExecuteQuery -Value {
                } -PassThru | Add-Member -MemberType ScriptMethod -Name Load -Value {
                } -PassThru

                return $context
            }

            Mock -CommandName Get-PnPWeb -MockWith {
                $returnval = @{
                    RegionalSettings = @{
                        LocaleId = 1033
                    }
                } | Add-Member -MemberType ScriptMethod -Name Update -Value {
                } -PassThru

                return $returnval
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Write-Warning -MockWith {
            }
        }

        # Test contexts
        Context -Name "When the site doesn't exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Url                            = 'https://contoso.sharepoint.com/sites/TestSite'
                    TimeZoneID                     = 10
                    Owner                          = 'testuser@contoso.com'
                    AllowSelfServiceUpgrade        = $True
                    CommentsOnSitePagesDisabled    = $False
                    DefaultLinkPermission          = 'None'
                    DefaultSharingLinkType         = 'None'
                    DisableAppViews                = 'NotDisabled'
                    DisableCompanyWideSharingLinks = 'NotDisabled'
                    DisableFlows                   = $False
                    Ensure                         = 'Present'
                    Credential                     = $Credential
                    LocaleId                       = 1033
                    StorageMaximumLevel            = 26214400
                    StorageWarningLevel            = 25574400
                    Title                          = 'CommNik'
                    HubUrl                         = 'https://contoso.sharepoint.com/sites/hub'
                    Template                       = 'STS#3'
                }

                Mock -CommandName New-PnPTenantSite -MockWith {
                    $global:M365DscSiteCreated = $true
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    if ($global:M365DscSiteCreated -eq $false)
                    {
                        return $null
                    }
                    else
                    {
                        $site = @{
                            Url = 'https://contoso.sharepoint.com/sites/TestSite'
                        } | Add-Member -MemberType ScriptMethod -Name Update -Value {
                        } -PassThru

                        return $site
                    }
                }

                Mock -CommandName Get-PnPHubSite -MockWith {
                    return @(
                        @{
                            ID                   = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                            Title                = 'Hub Site'
                            SiteId               = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                            SiteUrl              = 'https://contoso.sharepoint.com/sites/hub'
                            LogoUrl              = 'https://contoso.sharepoint.com/images/logo.png'
                            Description          = 'Contoso Hub Site'
                            Permissions          = @(
                                @{
                                    DisplayName   = 'Contoso Admin'
                                    PrincipalName = 'i:0#.f|membership|admin@contoso.onmicrosoft.com'
                                    Rights        = 'Join'
                                },
                                @{
                                    DisplayName   = 'Contoso Admin Group'
                                    PrincipalName = 'c:0t.c|tenant|1e78c600-11ce-4e7b-91c2-f3bb053f7682'
                                    Rights        = 'Join'
                                },
                                @{
                                    DisplayName   = 'Contoso Admin Office 365 Group'
                                    PrincipalName = 'c:0o.c|federateddirectoryclaimprovider|bfc75218-faac-4202-bf33-3a8ba2e2b4a7'
                                    Rights        = 'Join'
                                }
                            )
                            SiteDesignId         = '00000000-0000-0000-0000-000000000000'
                            RequiresJoinApproval = $false
                        }
                    )
                }

                Mock -CommandName Set-PnPTenantSite -MockWith { }
                Mock -CommandName Add-PnPHubSiteAssociation -MockWith { }

            }
            It 'Should return absent from the Get method' {
                $global:M365DscSiteCreated = $false
                ((New-M365DSCResourceInstance -ResourceName 'SPOSite' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                $global:M365DscSiteCreated = $false
                (New-M365DSCResourceInstance -ResourceName 'SPOSite' -Property $testParams).Test() | Should -Be $false
            }

            It 'Creates the site collection in the Set method' {
                $global:M365DscSiteCreated = $false
                (New-M365DSCResourceInstance -ResourceName 'SPOSite' -Property $testParams).Set()
                Should -Invoke -CommandName New-PnPTenantSite -Exactly 1
                Should -Invoke -CommandName Add-PnPHubSiteAssociation -Exactly 1
                Should -Invoke -CommandName Set-PnPTenantSite -Exactly 1
            }
        }

        Context -Name 'The site already exists' -Fixture {
            BeforeAll {
                $testParams = @{
                    Url                            = 'https://contoso.sharepoint.com/sites/TestSite'
                    TimeZoneID                     = 10
                    Owner                          = 'testuser@contoso.com'
                    AllowSelfServiceUpgrade        = $True
                    CommentsOnSitePagesDisabled    = $False
                    DefaultLinkPermission          = 'None'
                    DefaultSharingLinkType         = 'None'
                    DisableAppViews                = 'NotDisabled'
                    DisableCompanyWideSharingLinks = 'NotDisabled'
                    DisableFlows                   = $False
                    Ensure                         = 'Present'
                    Credential                     = $Credential
                    LocaleId                       = 1033
                    StorageMaximumLevel            = 26214400
                    StorageWarningLevel            = 25574400
                    Title                          = 'CommNik'
                    HubUrl                         = 'https://contoso.sharepoint.com/sites/hub'
                    Template                       = 'STS#3'
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    $site = @{
                        Url                            = 'https://contoso.sharepoint.com/sites/TestSite'
                        OwnerEmail                     = 'testuser@contoso.com'
                        TimeZoneId                     = 10
                        AllowSelfServiceUpgrade        = $True
                        CommentsOnSitePagesDisabled    = $False
                        DefaultLinkPermission          = 'None'
                        DefaultSharingLinkType         = 'None'
                        DisableAppViews                = 'NotDisabled'
                        DisableCompanyWideSharingLinks = 'NotDisabled'
                        DisableFlows                   = 'NotDisabled'
                        DisableSharingForNonOwners     = $False
                        LocaleId                       = 1033
                        RestrictedToRegion             = 'Unknown'
                        SocialBarOnSitePagesDisabled   = $False
                        StorageQuota                   = 26214400
                        StorageQuotaWarningLevel       = 25574400
                        Title                          = 'CommNik'
                        Template                       = 'STS#3'
                        HubSiteId                      = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                    } | Add-Member -MemberType ScriptMethod -Name Update -Value {
                    } -PassThru

                    return $site
                }

                Mock -CommandName Get-PnPHubSite -MockWith {
                    return @(
                        @{
                            ID                   = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                            Title                = 'Hub Site'
                            SiteId               = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                            SiteUrl              = 'https://contoso.sharepoint.com/sites/hub'
                            LogoUrl              = 'https://contoso.sharepoint.com/images/logo.png'
                            Description          = 'Contoso Hub Site'
                            Permissions          = @(
                                @{
                                    DisplayName   = 'Contoso Admin'
                                    PrincipalName = 'i:0#.f|membership|admin@contoso.onmicrosoft.com'
                                    Rights        = 'Join'
                                },
                                @{
                                    DisplayName   = 'Contoso Admin Group'
                                    PrincipalName = 'c:0t.c|tenant|1e78c600-11ce-4e7b-91c2-f3bb053f7682'
                                    Rights        = 'Join'
                                },
                                @{
                                    DisplayName   = 'Contoso Admin Office 365 Group'
                                    PrincipalName = 'c:0o.c|federateddirectoryclaimprovider|bfc75218-faac-4202-bf33-3a8ba2e2b4a7'
                                    Rights        = 'Join'
                                }
                            )
                            SiteDesignId         = '00000000-0000-0000-0000-000000000000'
                            RequiresJoinApproval = $false
                        }
                    )
                }

                Mock -CommandName Get-PnPWeb -MockWith {
                    return @(
                        @{
                            RegionalSettings = @{
                                TimeZone = @{
                                    Id = 10
                                }
                            }
                        }
                    )
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSite' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSite' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The site already exists, with incorrect settings' -Fixture {
            BeforeAll {
                $testParams = @{
                    Url                            = 'https://contoso.sharepoint.com/sites/TestSite'
                    TimeZoneID                     = 10
                    Owner                          = 'testuser@contoso.com'
                    AllowSelfServiceUpgrade        = $True
                    CommentsOnSitePagesDisabled    = $False
                    DefaultLinkPermission          = 'None'
                    DefaultSharingLinkType         = 'None'
                    DisableAppViews                = 'NotDisabled'
                    DisableCompanyWideSharingLinks = 'NotDisabled'
                    DisableFlows                   = $False
                    Ensure                         = 'Present'
                    Credential                     = $Credential
                    LocaleId                       = 1033
                    StorageMaximumLevel            = 26214400
                    StorageWarningLevel            = 25574400
                    Title                          = 'CommNik'
                    HubUrl                         = 'https://contoso.sharepoint.com/sites/hub'
                    Template                       = 'STS#3'
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    $site = @{
                        Url                            = 'https://contoso.sharepoint.com/sites/TestSite'
                        Owner                          = 'testuser@contoso.com'
                        TimeZoneId                     = 10
                        AllowSelfServiceUpgrade        = $True
                        CommentsOnSitePagesDisabled    = $False
                        DefaultLinkPermission          = 'None'
                        DefaultSharingLinkType         = 'None'
                        DisableAppViews                = 'NotDisabled'
                        DisableCompanyWideSharingLinks = 'NotDisabled'
                        DisableFlows                   = 'NotDisabled'
                        DisableSharingForNonOwners     = $False
                        DenyAddAndCustomizePages       = 'Enabled'
                        RequestFilesLinkEnabled        = $False
                        LCID                           = 1033
                        RestrictedToRegion             = 'Unknown'
                        SocialBarOnSitePagesDisabled   = $False
                        StorageMaximumLevel            = 26214400
                        StorageWarningLevel            = 25574400
                        Title                          = 'CommNik'
                        Template                       = 'SITEPAGEPUBLISHING#0'
                        HubUrl                         = 'https://contoso.sharepoint.com/sites/hub'
                    } | Add-Member -MemberType ScriptMethod -Name Update -Value {
                    } -PassThru

                    return $site
                }

                Mock -CommandName Get-PnPHubSite -MockWith {
                    return @(
                        @{
                            ID                   = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                            Title                = 'Hub Site'
                            SiteId               = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                            SiteUrl              = 'https://contoso.sharepoint.com/sites/hub'
                            LogoUrl              = 'https://contoso.sharepoint.com/images/logo.png'
                            Description          = 'Contoso Hub Site'
                            Permissions          = @(
                                @{
                                    DisplayName   = 'Contoso Admin'
                                    PrincipalName = 'i:0#.f|membership|admin@contoso.onmicrosoft.com'
                                    Rights        = 'Join'
                                },
                                @{
                                    DisplayName   = 'Contoso Admin Group'
                                    PrincipalName = 'c:0t.c|tenant|1e78c600-11ce-4e7b-91c2-f3bb053f7682'
                                    Rights        = 'Join'
                                },
                                @{
                                    DisplayName   = 'Contoso Admin Office 365 Group'
                                    PrincipalName = 'c:0o.c|federateddirectoryclaimprovider|bfc75218-faac-4202-bf33-3a8ba2e2b4a7'
                                    Rights        = 'Join'
                                }
                            )
                            SiteDesignId         = '00000000-0000-0000-0000-000000000000'
                            RequiresJoinApproval = $false
                        }
                    )
                }
            }

            It 'Should return present from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'SPOSite' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.DenyAddAndCustomizePages | Should -Be $true
                $result.RequestFilesLinkEnabled | Should -Be $false
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSite' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSite' -Property $testParams).Set()
            }
        }

        Context -Name 'The site exists, but association with Hub site will be removed' -Fixture {
            BeforeAll {
                $testParams = @{
                    Url                            = 'https://contoso.sharepoint.com/sites/TestSite'
                    TimeZoneID                     = 10
                    Owner                          = 'testuser@contoso.com'
                    AllowSelfServiceUpgrade        = $True
                    CommentsOnSitePagesDisabled    = $False
                    DefaultLinkPermission          = 'None'
                    DefaultSharingLinkType         = 'None'
                    DisableAppViews                = 'NotDisabled'
                    DisableCompanyWideSharingLinks = 'NotDisabled'
                    DisableFlows                   = $False
                    Ensure                         = 'Present'
                    Credential                     = $Credential
                    LocaleId                       = 1033
                    StorageMaximumLevel            = 26214400
                    StorageWarningLevel            = 25574400
                    Title                          = 'CommNik'
                    HubUrl                         = 'https://contoso.sharepoint.com/sites/hub'
                    Template                       = 'STS#3'
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    $site = @{
                        Url                            = 'https://contoso.sharepoint.com/sites/TestSite'
                        OwnerEmail                     = 'testuser@contoso.com'
                        TimeZoneId                     = 10
                        AllowSelfServiceUpgrade        = $True
                        CommentsOnSitePagesDisabled    = $False
                        DefaultLinkPermission          = 'None'
                        DefaultSharingLinkType         = 'None'
                        DisableAppViews                = 'NotDisabled'
                        DisableCompanyWideSharingLinks = 'NotDisabled'
                        DisableFlows                   = 'NotDisabled'
                        DisableSharingForNonOwners     = $False
                        LCID                           = 1033
                        RestrictedToRegion             = 'Unknown'
                        SocialBarOnSitePagesDisabled   = $False
                        StorageMaximumLevel            = 26214400
                        StorageWarningLevel            = 25574400
                        Title                          = 'CommNik'
                        Template                       = 'SITEPAGEPUBLISHING#0'
                        HubSiteId                      = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                    } | Add-Member -MemberType ScriptMethod -Name Update -Value {
                    } -PassThru

                    return $site
                }

                Mock -CommandName Get-PnPHubSite -MockWith {
                    return @(
                        @{
                            ID                   = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                            Title                = 'Hub Site'
                            SiteId               = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                            SiteUrl              = 'https://contoso.sharepoint.com/sites/hub'
                            LogoUrl              = 'https://contoso.sharepoint.com/images/logo.png'
                            Description          = 'Contoso Hub Site'
                            Permissions          = @(
                                @{
                                    DisplayName   = 'Contoso Admin'
                                    PrincipalName = 'i:0#.f|membership|admin@contoso.onmicrosoft.com'
                                    Rights        = 'Join'
                                },
                                @{
                                    DisplayName   = 'Contoso Admin Group'
                                    PrincipalName = 'c:0t.c|tenant|1e78c600-11ce-4e7b-91c2-f3bb053f7682'
                                    Rights        = 'Join'
                                },
                                @{
                                    DisplayName   = 'Contoso Admin Office 365 Group'
                                    PrincipalName = 'c:0o.c|federateddirectoryclaimprovider|bfc75218-faac-4202-bf33-3a8ba2e2b4a7'
                                    Rights        = 'Join'
                                }
                            )
                            SiteDesignId         = '00000000-0000-0000-0000-000000000000'
                            RequiresJoinApproval = $false
                        }
                    )
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSite' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSite' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update settings in Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSite' -Property $testParams).Set()
            }
        }

        Context -Name 'Deleted existing site' -Fixture {
            BeforeAll {
                $testParams = @{
                    Url                            = 'https://contoso.sharepoint.com/sites/TestSite'
                    TimeZoneID                     = 10
                    Owner                          = 'testuser@contoso.com'
                    AllowSelfServiceUpgrade        = $True
                    CommentsOnSitePagesDisabled    = $False
                    DefaultLinkPermission          = 'None'
                    DefaultSharingLinkType         = 'None'
                    DisableAppViews                = 'NotDisabled'
                    DisableCompanyWideSharingLinks = 'NotDisabled'
                    DisableFlows                   = $False
                    Ensure                         = 'Present'
                    Credential                     = $Credential
                    LocaleId                       = 1033
                    StorageMaximumLevel            = 26214400
                    StorageWarningLevel            = 25574400
                    Title                          = 'CommNik'
                    HubUrl                         = 'https://contoso.sharepoint.com/sites/hub'
                    Template                       = 'STS#3'
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    $site = @{
                        Url                            = 'https://contoso.sharepoint.com/sites/TestSite'
                        OwnerEmail                     = 'testuser@contoso.com'
                        TimeZoneId                     = 10
                        AllowSelfServiceUpgrade        = $True
                        CommentsOnSitePagesDisabled    = $False
                        DefaultLinkPermission          = 'None'
                        DefaultSharingLinkType         = 'None'
                        DisableAppViews                = 'NotDisabled'
                        DisableCompanyWideSharingLinks = 'NotDisabled'
                        DisableFlows                   = 'NotDisabled'
                        DisableSharingForNonOwners     = $False
                        LCID                           = 1033
                        RestrictedToRegion             = 'Unknown'
                        SocialBarOnSitePagesDisabled   = $False
                        StorageMaximumLevel            = 26214400
                        StorageWarningLevel            = 25574400
                        Title                          = 'CommNik'
                        Template                       = 'SITEPAGEPUBLISHING#0'
                        HubSiteId                      = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                    } | Add-Member -MemberType ScriptMethod -Name Update -Value {
                    } -PassThru

                    return $site
                }

                Mock -CommandName Get-PnPHubSite -MockWith {
                    return @(
                        @{
                            ID                   = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                            Title                = 'Hub Site'
                            SiteId               = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                            SiteUrl              = 'https://contoso.sharepoint.com/sites/hub'
                            LogoUrl              = 'https://contoso.sharepoint.com/images/logo.png'
                            Description          = 'Contoso Hub Site'
                            Permissions          = @(
                                @{
                                    DisplayName   = 'Contoso Admin'
                                    PrincipalName = 'i:0#.f|membership|admin@contoso.onmicrosoft.com'
                                    Rights        = 'Join'
                                },
                                @{
                                    DisplayName   = 'Contoso Admin Group'
                                    PrincipalName = 'c:0t.c|tenant|1e78c600-11ce-4e7b-91c2-f3bb053f7682'
                                    Rights        = 'Join'
                                },
                                @{
                                    DisplayName   = 'Contoso Admin Office 365 Group'
                                    PrincipalName = 'c:0o.c|federateddirectoryclaimprovider|bfc75218-faac-4202-bf33-3a8ba2e2b4a7'
                                    Rights        = 'Join'
                                }
                            )
                            SiteDesignId         = '00000000-0000-0000-0000-000000000000'
                            RequiresJoinApproval = $false
                        }
                    )
                }

                Mock -CommandName Remove-PnPTenantSite -MockWith {
                }
            }

            It 'Should find the site' {
                $global:M365DscSiteCreated = $false
                ((New-M365DSCResourceInstance -ResourceName 'SPOSite' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                $global:M365DscSiteCreated = $false
                (New-M365DSCResourceInstance -ResourceName 'SPOSite' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should delete the site' {
                $global:M365DscSiteCreated = $false
                (New-M365DSCResourceInstance -ResourceName 'SPOSite' -Property $testParams).Set()
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                $CalledOnce = $false
                Mock -CommandName Get-PnPTenantSite -MockWith {
                    if (-not $CalledOnce)
                    {
                        $CalledOnce = $true
                        return @{
                            Url                            = 'https://contoso.sharepoint.com/sites/TestSite'
                            OwnerEmail                     = 'testuser@contoso.com'
                            TimeZoneId                     = 10
                            AllowSelfServiceUpgrade        = $True
                            CommentsOnSitePagesDisabled    = $False
                            DefaultLinkPermission          = 'None'
                            DefaultSharingLinkType         = 'None'
                            DisableAppViews                = 'NotDisabled'
                            DisableCompanyWideSharingLinks = 'NotDisabled'
                            DisableFlows                   = 'NotDisabled'
                            DisableSharingForNonOwners     = $False
                            LCID                           = 1033
                            RestrictedToRegion             = 'Unknown'
                            SocialBarOnSitePagesDisabled   = $False
                            StorageMaximumLevel            = 26214400
                            StorageWarningLevel            = 25574400
                            Title                          = 'CommNik'
                            Template                       = 'SITEPAGEPUBLISHING#0'
                            HubSiteId                      = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                        }
                    }
                }
                Mock -CommandName Get-PnPHubSite -MockWith {
                    return @(
                        @{
                            ID                   = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                            Title                = 'Hub Site'
                            SiteId               = 'fcc3c848-6d2f-4821-a56c-980eea7990c5'
                            SiteUrl              = 'https://contoso.sharepoint.com/sites/hub'
                            LogoUrl              = 'https://contoso.sharepoint.com/images/logo.png'
                            Description          = 'Contoso Hub Site'
                            Permissions          = @(
                                @{
                                    DisplayName   = 'Contoso Admin'
                                    PrincipalName = 'i:0#.f|membership|admin@contoso.onmicrosoft.com'
                                    Rights        = 'Join'
                                },
                                @{
                                    DisplayName   = 'Contoso Admin Group'
                                    PrincipalName = 'c:0t.c|tenant|1e78c600-11ce-4e7b-91c2-f3bb053f7682'
                                    Rights        = 'Join'
                                },
                                @{
                                    DisplayName   = 'Contoso Admin Office 365 Group'
                                    PrincipalName = 'c:0o.c|federateddirectoryclaimprovider|bfc75218-faac-4202-bf33-3a8ba2e2b4a7'
                                    Rights        = 'Join'
                                }
                            )
                            SiteDesignId         = '00000000-0000-0000-0000-000000000000'
                            RequiresJoinApproval = $false
                        }
                    )
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOSite' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope

