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
    -DscResource 'SPOHubSite' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Grant-PnPHubSiteRights -MockWith {
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
        Context -Name "When the site doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Url                  = 'https://contoso.sharepoint.com/sites/Marketing'
                    Title                = 'Marketing Hub'
                    Description          = 'Hub for the Marketing division'
                    LogoUrl              = 'https://contoso.sharepoint.com/sites/Marketing/SiteAssets/hublogo.png'
                    RequiresJoinApproval = $true
                    AllowedToJoin        = @('admin@contoso.onmicrosoft.com', 'superuser@contoso.onmicrosoft.com')
                    SiteDesignId         = 'f7eba920-9cca-4de8-b5aa-1da75a2a893c'
                    Credential           = $Credential
                    Ensure               = 'Present'
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call  the Set method' {
                Mock -CommandName Get-PnPTenantSite -MockWith {
                    throw
                }
                { (New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Set() } | Should -Throw "The specified Site Collection {$($testParams.Url)} for SPOHubSite doesn't already exist."
            }
        }

        Context -Name "When the site isn't a hub site and shouldn't" -Fixture {
            BeforeAll {
                $testParams = @{
                    Url        = 'https://contoso.sharepoint.com/sites/Marketing'
                    Credential = $Credential
                    Ensure     = 'Absent'
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    return @{
                        IsHubSite = $false
                        Url       = 'https://contoso.hub.com'
                    }
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "When the site is a hub site and shouldn't" -Fixture {
            BeforeAll {
                $testParams = @{
                    Url        = 'https://contoso.sharepoint.com/sites/Marketing'
                    Credential = $Credential
                    Ensure     = 'Absent'
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    return @{
                        IsHubSite = $true
                        Url       = 'https://contoso.sharepoint.com'
                    }
                }

                Mock -CommandName Get-PnPHubSite -MockWith {
                    $returnVal = @{
                        Permissions          = @(
                            @{
                                PrincipalName = 'i:0#.f|membership|admin@contoso.onmicrosoft.com'
                            },
                            @{
                                PrincipalName = 'c:0o.c|federateddirectoryclaimprovider|bfc75218-faac-4202-bf33-3a8ba2e2b4a7'
                            }
                        )
                        LogoUrl              = 'https://contoso.sharepoint.com/sites/Marketing/SiteAssets/hublogo.png'
                        Title                = 'Marketing Hub'
                        Description          = 'Hub for the Marketing division'
                        RequiresJoinApproval = $true
                        SiteDesignId         = 'f7eba920-9cca-4de8-b5aa-1da75a2a893c'
                    }
                    return $returnVal
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return @(
                        @{
                            EmailAddress = 'group@contoso.onmicrosoft.com'
                        }
                    )
                }

                Mock -CommandName Unregister-PnPHubSite -MockWith { }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call mocks in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Set()
                Should -Invoke Unregister-PnPHubSite -Exactly 1
            }
        }

        Context -Name 'When the site should be a hub site and is correctly configured' -Fixture {
            BeforeAll {
                $testParams = @{
                    Url                  = 'https://contoso.sharepoint.com/sites/Marketing'
                    Title                = 'Marketing Hub'
                    Description          = 'Hub for the Marketing division'
                    LogoUrl              = 'https://contoso.sharepoint.com/sites/Marketing/SiteAssets/hublogo.png'
                    RequiresJoinApproval = $true
                    AllowedToJoin        = @('admin@contoso.onmicrosoft.com', 'group@contoso.onmicrosoft.com')
                    SiteDesignId         = 'f7eba920-9cca-4de8-b5aa-1da75a2a893c'
                    Credential           = $Credential
                    Ensure               = 'Present'
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    return @{
                        IsHubSite = $true
                        Url       = 'https://contoso.sharepoint.com'
                    }
                }

                Mock -CommandName Get-PnPHubSite -MockWith {
                    $returnVal = @{
                        Permissions          = @(
                            @{
                                PrincipalName = 'i:0#.f|membership|admin@contoso.onmicrosoft.com'
                            },
                            @{
                                PrincipalName = 'c:0o.c|federateddirectoryclaimprovider|bfc75218-faac-4202-bf33-3a8ba2e2b4a7'
                            }
                        )
                        LogoUrl              = 'https://contoso.sharepoint.com/sites/Marketing/SiteAssets/hublogo.png'
                        Title                = 'Marketing Hub'
                        Description          = 'Hub for the Marketing division'
                        RequiresJoinApproval = $true
                        SiteDesignId         = 'f7eba920-9cca-4de8-b5aa-1da75a2a893c'
                    }
                    return $returnVal
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        EmailAddress = 'group@contoso.onmicrosoft.com'
                    }
                }

                Mock -CommandName Unregister-PnPHubSite -MockWith { }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the site should be a hub site, but is incorrectly configured' -Fixture {
            BeforeAll {
                $testParams = @{
                    Url                  = 'https://contoso.sharepoint.com/sites/Marketing'
                    Title                = 'Marketing Hub'
                    Description          = 'Hub for the Marketing division'
                    LogoUrl              = 'https://contoso.sharepoint.com/sites/Marketing/SiteAssets/hublogo.png'
                    RequiresJoinApproval = $true
                    AllowedToJoin        = @('admin@contoso.onmicrosoft.com', 'group@contoso.onmicrosoft.com')
                    SiteDesignId         = 'f7eba920-9cca-4de8-b5aa-1da75a2a893c'
                    Credential           = $Credential
                    Ensure               = 'Present'
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    return @{
                        IsHubSite = $true
                        Url       = 'https://contoso.sharepoint.com'
                    }
                }

                Mock -CommandName Get-PnPHubSite -MockWith {
                    $returnVal = @{
                        Permissions          = @(
                            @{
                                PrincipalName = 'i:0#.f|membership|wrongadmin@contoso.onmicrosoft.com'
                            },
                            @{
                                PrincipalName = 'c:0o.c|federateddirectoryclaimprovider|bfc75218-faac-4202-bf33-3a8ba2e2b4a7'
                            }
                        )
                        LogoUrl              = 'https://contoso.sharepoint.com/sites/Marketing/SiteAssets/hublogo.png'
                        Title                = 'Wrong Title'
                        Description          = 'Wrong Description'
                        RequiresJoinApproval = $false
                        SiteDesignId         = 'e8eba920-9cca-4de8-b5aa-1da75a2a893c'
                        SiteUrl              = 'https://contoso.hub.sharepoint.com'
                    }
                    return $returnVal
                }

                Mock -CommandName Get-MGGroup -MockWith {
                    return @{
                        EmailAddress = 'wronggroup@contoso.onmicrosoft.com'
                    }
                }

                Mock -CommandName Set-PnPHubSite -MockWith { }
                Mock -CommandName Grant-PnPHubSiteRights -MockWith { }
                Mock -CommandName Revoke-PnPHubSiteRights -MockWith { }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call mocks in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Set()
                Should -Invoke Set-PnPHubSite -Exactly 1
                Should -Invoke Grant-PnPHubSiteRights -Exactly 2
                Should -Invoke Revoke-PnPHubSiteRights -Exactly 2
            }
        }

        Context -Name "When the site isn't a hub site but should be" -Fixture {
            BeforeAll {
                $testParams = @{
                    Url                  = 'https://contoso.sharepoint.com/sites/Marketing'
                    Title                = 'Marketing Hub'
                    Description          = 'Hub for the Marketing division'
                    LogoUrl              = 'https://contoso.sharepoint.com/sites/Marketing/SiteAssets/hublogo.png'
                    RequiresJoinApproval = $true
                    AllowedToJoin        = @('admin@contoso.onmicrosoft.com', 'group@contoso.onmicrosoft.com', 'SecurityGroup')
                    SiteDesignId         = 'f7eba920-9cca-4de8-b5aa-1da75a2a893c'
                    Credential           = $Credential
                    Ensure               = 'Present'
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    return @{
                        IsHubSite = $false
                        Url       = 'https://contoso.sharepoint.com'
                    }
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        DisplayName = 'SecurityGroup'
                    }
                }

                Mock -CommandName Register-PnPHubSite -MockWith { }
                Mock -CommandName Set-PnPHubSite -MockWith { }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call mocks in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Set()
                Should -Invoke Register-PnPHubSite -Exactly 1
                Should -Invoke Set-PnPHubSite -Exactly 1
            }
        }

        Context -Name "When specified AllowedToJoin group doesn't exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Url                  = 'https://contoso.sharepoint.com/sites/Marketing'
                    Title                = 'Marketing Hub'
                    Description          = 'Hub for the Marketing division'
                    LogoUrl              = 'https://contoso.sharepoint.com/sites/Marketing/SiteAssets/hublogo.png'
                    RequiresJoinApproval = $true
                    AllowedToJoin        = @('admin@contoso.onmicrosoft.com', 'group@contoso.onmicrosoft.com', 'SecurityGroup')
                    SiteDesignId         = 'f7eba920-9cca-4de8-b5aa-1da75a2a893c'
                    Credential           = $Credential
                    Ensure               = 'Present'
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    return @{
                        IsHubSite = $false
                        Url       = 'https://contoso.sharepoint.com'
                    }
                }

                Mock -CommandName Register-PnPHubSite -MockWith { }
                Mock -CommandName Set-PnPHubSite -MockWith { }

                Mock -CommandName Get-MgGroup -MockWith {
                    return @(
                        @{
                            EmailAddress = 'group@contoso.onmicrosoft.com'
                        }
                    )
                }
            }

            It 'Should throw exception the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'SPOHubSite' -Property $testParams).Set() } | Should -Throw '*Error for principal*'
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    return @{
                        IsHubSite = $true
                        Url       = 'https://contoso.sharepoint.com'
                    }
                }

                Mock -CommandName Get-PnPHubSite -MockWith {
                    $returnVal = @{
                        Permissions          = @(
                            @{
                                PrincipalName = 'i:0#.f|membership|wrongadmin@contoso.onmicrosoft.com'
                            },
                            @{
                                PrincipalName = 'c:0o.c|federateddirectoryclaimprovider|bfc75218-faac-4202-bf33-3a8ba2e2b4a7'
                            }
                        )
                        LogoUrl              = 'https://contoso.sharepoint.com/sites/Marketing/SiteAssets/hublogo.png'
                        Title                = 'Wrong Title'
                        Description          = 'Wrong Description'
                        RequiresJoinApproval = $false
                        SiteDesignId         = 'e8eba920-9cca-4de8-b5aa-1da75a2a893c'
                        SiteUrl              = 'https://contoso.hub.sharepoint.com'
                    }
                    return $returnVal
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return @(
                        @{
                            EmailAddress = 'group@contoso.onmicrosoft.com'
                        }
                    )
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOHubSite' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
