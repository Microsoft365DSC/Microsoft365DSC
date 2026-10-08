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
    -DscResource 'PPTenantSettings' -GenericStubModule $GenericStubPath

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

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'PP Tenant settings are not configured' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                               = 'Yes'
                    WalkMeOptOut                                   = $false
                    DisableNPSCommentsReachout                     = $false
                    DisableNewsletterSendout                       = $false
                    DisableEnvironmentCreationByNonAdminUsers      = $false
                    DisablePortalsCreationByNonAdminUsers          = $false
                    DisableSurveyFeedback                          = $false
                    DisableTrialEnvironmentCreationByNonAdminUsers = $false
                    DisableCapacityAllocationByEnvironmentAdmins   = $false
                    DisableSupportTicketsVisibleByAllUsers         = $false
                    DisableDocsSearch                              = $false
                    DisableCommunitySearch                         = $false
                    DisableBingVideoSearch                         = $false
                    DisableShareWithEveryone                       = $false
                    EnableGuestsToMake                             = $false
                    EnableDesktopFlowDataPolicyManagement          = $false
                    ShareWithColleaguesUserLimit                   = 10000
                    Credential                                     = $Credential
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        TenantSettings = @{
                            WalkMeOptOut                                   = $testParams.WalkMeOptOut
                            DisableNPSCommentsReachout                     = $testParams.DisableNPSCommentsReachout
                            DisableNewsletterSendout                       = $testParams.DisableNewsletterSendout
                            DisableEnvironmentCreationByNonAdminUsers      = $testParams.DisableEnvironmentCreationByNonAdminUsers
                            DisablePortalsCreationByNonAdminUsers          = $testParams.DisablePortalsCreationByNonAdminUsers
                            DisableSurveyFeedback                          = $testParams.DisableSurveyFeedback
                            DisableTrialEnvironmentCreationByNonAdminUsers = $testParams.DisableTrialEnvironmentCreationByNonAdminUsers
                            DisableCapacityAllocationByEnvironmentAdmins   = $testParams.DisableCapacityAllocationByEnvironmentAdmins
                            DisableSupportTicketsVisibleByAllUsers         = $testParams.DisableSupportTicketsVisibleByAllUsers
                            EnableDesktopFlowDataPolicyManagement          = $false
                            powerPlatform                                  = @(
                                    @{
                                        search = @{
                                            DisableDocsSearch      = $testParams.DisableDocsSearch
                                            DisableCommunitySearch = $testParams.DisableCommunitySearch
                                            DisableBingVideoSearch = $testParams.DisableBingVideoSearch
                                        }
                                    },
                                    @{
                                        powerApps = @{
                                            DisableShareWithEveryone = $testParams.DisableShareWithEveryone
                                            EnableGuestsToMake       = $testParams.EnableGuestsToMake
                                        }
                                    },
                                    @{
                                        teamsIntegration = @{
                                            ShareWithColleaguesUserLimit = $testParams.ShareWithColleaguesUserLimit
                                        }
                                    }
                                )
                            }
                        }
                    }
                }


            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPTenantSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Sets the tenant settings in Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PPTenantSettings' -Property $testParams).Set()
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        WalkMeOptOut                                   = $false
                        DisableNPSCommentsReachout                     = $false
                        DisableNewsletterSendout                       = $false
                        DisableEnvironmentCreationByNonAdminUsers      = $false
                        DisablePortalsCreationByNonAdminUsers          = $false
                        DisableSurveyFeedback                          = $false
                        DisableTrialEnvironmentCreationByNonAdminUsers = $false
                        DisableCapacityAllocationByEnvironmentAdmins   = $false
                        DisableSupportTicketsVisibleByAllUsers         = $false
                        powerPlatform                                  = @(
                            @{
                                search = @{
                                    DisableDocsSearch      = $false
                                    DisableCommunitySearch = $false
                                    DisableBingVideoSearch = $false
                                }
                            },
                            @{
                                powerApps = @{
                                    DisableShareWithEveryone = $false
                                    EnableGuestsToMake       = $false
                                }
                            },
                            @{
                                teamsIntegration = @{
                                    ShareWithColleaguesUserLimit = 10000
                                }
                            }
                        )
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'PPTenantSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }#inmodulescope
}#describe

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
