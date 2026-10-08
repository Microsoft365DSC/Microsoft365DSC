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
    -DscResource 'AADEntitlementManagementAccessPackageAssignmentPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ("tenantadmin@onmicrosoft.com", $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'
            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Set-MgBetaEntitlementManagementAccessPackageAssignmentPolicy -MockWith {
            }

            Mock -CommandName New-MgBetaEntitlementManagementAccessPackageAssignmentPolicy -MockWith {
            }

            Mock -CommandName Remove-MgBetaEntitlementManagementAccessPackageAssignmentPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaEntitlementManagementAccessPackage -MockWith {
                return @{
                    Id = 'FakeStringValue'
                }
            }

            Mock -CommandName Get-MgBetaEntitlementManagementAccessPackageAssignmentPolicy -MockWith {
                return @{
                    AccessPackageId                   = 'FakeStringValue'
                    AccessPackageNotificationSettings = @{
                        isAssignmentNotificationDisabled = $True
                    }
                    AccessReviewSettings              = @{
                        isEnabled                       = $True
                        isAccessRecommendationEnabled   = $True
                        isAgenticExperienceEnabled      = $True
                        isApprovalJustificationRequired = $True
                        recurrenceType                  = 'FakeStringValue'
                        reviewerType                    = 'FakeStringValue'
                        durationInDays                  = 25
                        startDateTime                   = [System.DateTime]::new(2032, 12, 17, 23, 59, 59, [System.DateTimeKind]::Utc)
                    }
                    CanExtend                         = $True
                    CustomExtensionHandlers           = @(
                        @{
                            CustomExtension = @{
                                AuthenticationConfiguration = @{
                                    ResourceId = 'MyResourceId'
                                }
                                ClientConfiguration         = @{
                                    TimeoutInMilliseconds = 10
                                }
                                Description                 = 'MyCustomExtensionDescription'
                                DisplayName                 = 'MyCustomExtensionDisplayName'
                                EndpointConfiguration       = @{
                                    LogicAppWorkflowName = 'MyLogicAppWorkflowName'
                                    ResourceGroupName    = 'MyResourceGroupName'
                                    SubscriptionId       = 'MySubscriptionId'
                                }
                                Id                          = 'MyCustomExtensionId'
                            }
                            Stage           = 'assignmentRequestCreated'
                            Id              = 'MyCustomExtensionHandlersId'
                        }
                    )
                    Description                       = 'FakeStringValue'
                    DisplayName                       = 'FakeStringValue'
                    DurationInDays                    = 25
                    Id                                = 'FakeStringValue'
                    Questions                         = @(
                        @{
                            isAnswerEditable     = $True
                            id                   = 'FakeStringValue'
                            isRequired           = $True
                            sequence             = 25
                            '@odata.type'           = '#microsoft.graph.accessPackageMultipleChoiceQuestion'
                            allowsMultipleSelection = $True
                        }
                    )
                    RequestApprovalSettings           = @{
                        approvalMode                     = 'NoApproval'
                        isRequestorJustificationRequired = $True
                        isApprovalRequiredForExtension   = $False
                        isApprovalRequired               = $False
                    }
                    RequestorSettings                 = @{
                        scopeType      = 'NoSubjects'
                        acceptRequests = $True
                    }
                    VerifiableCredentialSettings      = @{
                        credentialTypes = @(
                            @{
                                credentialType = 'FakeStringValue'
                                issuers        = @('FakeStringValue')
                            }
                        )
                    }
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name 'The AADEntitlementManagementAccessPackageAssignmentPolicy should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AccessPackageId                   = 'FakeStringValue'
                    AccessPackageNotificationSettings = ([MSFT_MicrosoftGraphaccessPackageNotificationSettings] @{
                            isAssignmentNotificationDisabled = $True
                        })
                    AccessReviewSettings              = ([MSFT_MicrosoftGraphassignmentreviewsettings] @{
                            isEnabled                       = $True
                            isAccessRecommendationEnabled   = $True
                            isAgenticExperienceEnabled      = $True
                            isApprovalJustificationRequired = $True
                            recurrenceType                  = 'FakeStringValue'
                            reviewerType                    = 'FakeStringValue'
                            durationInDays                  = 25
                            StartDateTime                   = '12/17/2032 23:59:59'
                        })
                    CanExtend                         = $True
                    CustomExtensionHandlers           = @(
                            ([MSFT_MicrosoftGraphcustomextensionhandler] @{
                            CustomExtensionId = 'MyCustomExtensionId'
                            Stage           = 'assignmentRequestCreated'
                        })
                    )
                    Description                       = 'FakeStringValue'
                    DisplayName                       = 'FakeStringValue'
                    DurationInDays                    = 25
                    Id                                = 'FakeStringValue'
                    Questions                         = @(
                            ([MSFT_MicrosoftGraphaccesspackagequestion] @{
                            allowsMultipleSelection = $True
                            isAnswerEditable        = $True
                            id                      = 'FakeStringValue'
                            isRequired              = $True
                            odataType               = '#microsoft.graph.accessPackageMultipleChoiceQuestion'
                            SequencePosition        = 25
                        })
                    )
                    RequestApprovalSettings           = ([MSFT_MicrosoftGraphapprovalsettings] @{
                            approvalMode                     = 'NoApproval'
                            isRequestorJustificationRequired = $True
                            isApprovalRequiredForExtension   = $False
                            isApprovalRequired               = $False
                        })
                    RequestorSettings                 = ([MSFT_MicrosoftGraphrequestorsettings] @{
                            scopeType      = 'NoSubjects'
                            acceptRequests = $True
                        })
                    VerifiableCredentialSettings      = ([MSFT_MicrosoftGraphverifiableCredentialSettings] @{
                            credentialTypes = @(
                                    ([MSFT_MicrosoftGraphverifiableCredentialType] @{
                                    credentialType = 'FakeStringValue'
                                    issuers        = @('FakeStringValue')
                                })
                            )
                        })

                    Ensure                            = 'Present'
                    Credential                        = $Credential
                }
                Mock -CommandName Get-MgBetaEntitlementManagementAccessPackageAssignmentPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageAssignmentPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageAssignmentPolicy' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageAssignmentPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaEntitlementManagementAccessPackageAssignmentPolicy -Exactly 1 -ParameterFilter {
                    $BodyParameter.AccessReviewSettings.StartDateTime -eq '2032-12-17T23:59:59.0000000Z'
                }
            }
        }

        Context -Name 'The AADEntitlementManagementAccessPackageAssignmentPolicy exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AccessPackageId                   = 'FakeStringValue'
                    AccessPackageNotificationSettings = ([MSFT_MicrosoftGraphaccessPackageNotificationSettings] @{
                            isAssignmentNotificationDisabled = $True
                        })
                    AccessReviewSettings              = ([MSFT_MicrosoftGraphassignmentreviewsettings] @{
                            isEnabled                       = $True
                            isAccessRecommendationEnabled   = $True
                            isAgenticExperienceEnabled      = $True
                            isApprovalJustificationRequired = $True
                            recurrenceType                  = 'FakeStringValue'
                            reviewerType                    = 'FakeStringValue'
                            durationInDays                  = 25
                            StartDateTime                   = '2032-12-17T23:59:59.0000000Z'
                        })
                    CanExtend                         = $True
                    CustomExtensionHandlers           = @(
                            ([MSFT_MicrosoftGraphcustomextensionhandler] @{
                            CustomExtensionId = 'MyCustomExtensionId'
                            Stage           = 'assignmentRequestCreated'
                        })
                    )
                    Description                       = 'FakeStringValue'
                    DisplayName                       = 'FakeStringValue'
                    DurationInDays                    = 25
                    Id                                = 'FakeStringValue'
                    Questions                         = @(
                            ([MSFT_MicrosoftGraphaccesspackagequestion] @{
                            allowsMultipleSelection = $True
                            isAnswerEditable        = $True
                            id                      = 'FakeStringValue'
                            isRequired              = $True
                            odataType               = '#microsoft.graph.accessPackageMultipleChoiceQuestion'
                            SequencePosition        = 25
                        })
                    )
                    RequestApprovalSettings           = ([MSFT_MicrosoftGraphapprovalsettings] @{
                            approvalMode                     = 'NoApproval'
                            isRequestorJustificationRequired = $True
                            isApprovalRequiredForExtension   = $False
                            isApprovalRequired               = $False
                        })
                    RequestorSettings                 = ([MSFT_MicrosoftGraphrequestorsettings] @{
                            scopeType      = 'NoSubjects'
                            acceptRequests = $True
                        })
                    VerifiableCredentialSettings      = ([MSFT_MicrosoftGraphverifiableCredentialSettings] @{
                            credentialTypes = @(
                                    ([MSFT_MicrosoftGraphverifiableCredentialType] @{
                                    credentialType = 'FakeStringValue'
                                    issuers        = @('FakeStringValue')
                                })
                            )
                        })

                    Ensure                            = 'Absent'
                    Credential                        = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageAssignmentPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageAssignmentPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageAssignmentPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaEntitlementManagementAccessPackageAssignmentPolicy -Exactly 1
            }
        }
        Context -Name 'The AADEntitlementManagementAccessPackageAssignmentPolicy Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AccessPackageId                   = 'FakeStringValue'
                    AccessPackageNotificationSettings = ([MSFT_MicrosoftGraphaccessPackageNotificationSettings] @{
                            isAssignmentNotificationDisabled = $True
                        })
                    AccessReviewSettings              = ([MSFT_MicrosoftGraphassignmentreviewsettings] @{
                            isEnabled                       = $True
                            isAccessRecommendationEnabled   = $True
                            isAgenticExperienceEnabled      = $True
                            isApprovalJustificationRequired = $True
                            recurrenceType                  = 'FakeStringValue'
                            reviewerType                    = 'FakeStringValue'
                            durationInDays                  = 25
                            StartDateTime                   = '12/17/2032 23:59:59'
                        })
                    CanExtend                         = $True
                    CustomExtensionHandlers           = @(
                            ([MSFT_MicrosoftGraphcustomextensionhandler] @{
                            CustomExtensionId = 'MyCustomExtensionId'
                            Stage           = 'assignmentRequestCreated'
                        })
                    )
                    Description                       = 'FakeStringValue'
                    DisplayName                       = 'FakeStringValue'
                    DurationInDays                    = 25
                    Id                                = 'FakeStringValue'
                    Questions                         = @(
                            ([MSFT_MicrosoftGraphaccesspackagequestion] @{
                            allowsMultipleSelection = $True
                            isAnswerEditable        = $True
                            id                      = 'FakeStringValue'
                            isRequired              = $True
                            odataType               = '#microsoft.graph.accessPackageMultipleChoiceQuestion'
                            SequencePosition        = 25
                        })
                    )
                    RequestApprovalSettings           = ([MSFT_MicrosoftGraphapprovalsettings] @{
                            approvalMode                     = 'NoApproval'
                            isRequestorJustificationRequired = $True
                            isApprovalRequiredForExtension   = $False
                            isApprovalRequired               = $False
                        })
                    RequestorSettings                 = ([MSFT_MicrosoftGraphrequestorsettings] @{
                            scopeType      = 'NoSubjects'
                            acceptRequests = $True
                        })
                    VerifiableCredentialSettings      = ([MSFT_MicrosoftGraphverifiableCredentialSettings] @{
                            credentialTypes = @(
                                    ([MSFT_MicrosoftGraphverifiableCredentialType] @{
                                    credentialType = 'FakeStringValue'
                                    issuers        = @('FakeStringValue')
                                })
                            )
                        })

                    Ensure                            = 'Present'
                    Credential                        = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageAssignmentPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The AADEntitlementManagementAccessPackageAssignmentPolicy exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AccessPackageId                   = 'FakeStringValue'
                    AccessPackageNotificationSettings = ([MSFT_MicrosoftGraphaccessPackageNotificationSettings] @{
                            isAssignmentNotificationDisabled = $False # Drift
                        })
                    AccessReviewSettings              = ([MSFT_MicrosoftGraphassignmentreviewsettings] @{
                            isEnabled                       = $True
                            isAccessRecommendationEnabled   = $True
                            isAgenticExperienceEnabled      = $True
                            isApprovalJustificationRequired = $True
                            recurrenceType                  = 'FakeStringValue'
                            reviewerType                    = 'FakeStringValue'
                            durationInDays                  = 30 # Drift
                        })
                    CanExtend                         = $True
                    CustomExtensionHandlers           = @(
                            ([MSFT_MicrosoftGraphcustomextensionhandler] @{
                            CustomExtensionId = 'MyCustomExtensionId'
                            Stage           = 'assignmentRequestCreated'
                        })
                    )
                    Description                       = 'FakeStringValue'
                    DisplayName                       = 'FakeStringValue'
                    DurationInDays                    = 25
                    Id                                = 'FakeStringValue'
                    Questions                         = @(
                            ([MSFT_MicrosoftGraphaccesspackagequestion] @{
                            allowsMultipleSelection = $True
                            isAnswerEditable        = $True
                            id                      = 'FakeStringValue'
                            isRequired              = $True
                            odataType               = '#microsoft.graph.accessPackageMultipleChoiceQuestion'
                            SequencePosition        = 25
                        })
                    )
                    RequestApprovalSettings           = ([MSFT_MicrosoftGraphapprovalsettings] @{
                            approvalMode                     = 'NoApproval'
                            isRequestorJustificationRequired = $True
                            isApprovalRequiredForExtension   = $False
                            isApprovalRequired               = $False
                        })
                    RequestorSettings                 = ([MSFT_MicrosoftGraphrequestorsettings] @{
                            scopeType      = 'NoSubjects'
                            acceptRequests = $True
                        })
                    VerifiableCredentialSettings      = ([MSFT_MicrosoftGraphverifiableCredentialSettings] @{
                            credentialTypes = @(
                                    ([MSFT_MicrosoftGraphverifiableCredentialType] @{
                                    credentialType = 'DriftStringValue' # Drift
                                    issuers        = @('FakeStringValue')
                                })
                            )
                        })

                    Ensure                            = 'Present'
                    Credential                        = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageAssignmentPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageAssignmentPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADEntitlementManagementAccessPackageAssignmentPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-MgBetaEntitlementManagementAccessPackageAssignmentPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADEntitlementManagementAccessPackageAssignmentPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
