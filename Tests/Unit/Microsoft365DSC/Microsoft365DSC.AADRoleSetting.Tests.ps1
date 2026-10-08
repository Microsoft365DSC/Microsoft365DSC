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
    -DscResource 'AADRoleSetting' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Get-MgBetaPolicyRoleManagementPolicyAssignment -MockWith {
                return @{
                    PolicyId = 'DirectoryRole_1e1b61e9-1bad-4b5f-aca3-973feb8d36e0_2d3a49e9-4a0b-4456-b381-3311753988a8'
                    RoleDefinitionId = 'fe930be7-5e62-47db-91af-98c3a49a38b1'
                }
            }

            Mock -CommandName Get-MgBetaRoleManagementDirectoryRoleDefinition -MockWith {
                return @{
                    DisplayName = 'User administrator'
                    Id          = 'fe930be7-5e62-47db-91af-98c3a49a38b1'
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            $json = @'
[
    {
        "Id":  "Enablement_Admin_Eligibility",
        "Target":  {
                       "Caller":  "Admin",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Eligibility",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyEnablementRule",
        "enabledRules":  [

                        ]
    },
    {
        "Id":  "Expiration_Admin_Eligibility",
        "Target":  {
                       "Caller":  "Admin",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Eligibility",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyExpirationRule",
        "isExpirationRequired":  false,
        "maximumDuration":  "P365D"
    },
    {
        "Id":  "Notification_Approver_Admin_Eligibility",
        "Target":  {
                       "Caller":  "Admin",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Eligibility",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyNotificationRule",
        "notificationType":  "Email",
        "recipientType":  "Approver",
        "notificationLevel":  "All",
        "isDefaultRecipientsEnabled":  true,
        "notificationRecipients":  [

                                ]
    },
    {
        "Id":  "Notification_Admin_Admin_Eligibility",
        "Target":  {
                       "Caller":  "Admin",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Eligibility",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyNotificationRule",
        "notificationType":  "Email",
        "recipientType":  "Admin",
        "notificationLevel":  "All",
        "isDefaultRecipientsEnabled":  true,
        "notificationRecipients":  [

                                   ]
    },
    {
        "Id":  "Notification_Requestor_Admin_Eligibility",
        "Target":  {
                       "Caller":  "Admin",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Eligibility",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyNotificationRule",
        "notificationType":  "Email",
        "recipientType":  "Requestor",
        "notificationLevel":  "All",
        "isDefaultRecipientsEnabled":  true,
        "notificationRecipients":  [

                                   ]
    },
    {
        "Id":  "Enablement_Admin_Assignment",
        "Target":  {
                       "Caller":  "Admin",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Assignment",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyEnablementRule",
        "enabledRules":  [
                             "Justification"
                         ]
    },
    {
        "Id":  "Expiration_Admin_Assignment",
        "Target":  {
                       "Caller":  "Admin",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Assignment",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyExpirationRule",
        "isExpirationRequired":  false,
        "maximumDuration":  "P180D"
    },
    {
        "Id":  "Notification_Admin_Admin_Assignment",
        "Target":  {
                       "Caller":  "Admin",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Assignment",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyNotificationRule",
        "notificationType":  "Email",
        "recipientType":  "Admin",
        "notificationLevel":  "All",
        "isDefaultRecipientsEnabled":  true,
        "notificationRecipients":  [

                                   ]
    },
    {
        "Id":  "Notification_Approver_Admin_Assignment",
        "Target":  {
                       "Caller":  "Admin",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Assignment",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyNotificationRule",
        "notificationType":  "Email",
        "recipientType":  "Approver",
        "notificationLevel":  "All",
        "isDefaultRecipientsEnabled":  true,
        "notificationRecipients":  [

                                   ]
    },
    {
        "Id":  "Notification_Requestor_Admin_Assignment",
        "Target":  {
                       "Caller":  "Admin",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Assignment",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyNotificationRule",
        "notificationType":  "Email",
        "recipientType":  "Requestor",
        "notificationLevel":  "All",
        "isDefaultRecipientsEnabled":  true,
        "notificationRecipients":  [

                                   ]
    },
    {
        "Id":  "Approval_EndUser_Assignment",
        "Target":  {
                       "Caller":  "EndUser",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Assignment",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyApprovalRule",
        "setting":  {
                        "isApprovalRequired":  false,
                        "isApprovalRequiredForExtension":  false,
                        "isRequestorJustificationRequired":  true,
                        "approvalMode":  "SingleStage",
                        "approvalStages":  [
                                               {
                                                   "approvalStageTimeOutInDays":  1,
                                                   "isApproverJustificationRequired":  true,
                                                   "escalationTimeInMinutes":  0,
                                                   "isEscalationEnabled":  false,
                                                   "primaryApprovers":  [

                                                                        ],
                                                   "escalationApprovers":  [

                                                                           ]
                                               }
                                           ]
                    }
    },
    {
        "Id":  "AuthenticationContext_EndUser_Assignment",
        "Target":  {
                       "Caller":  "EndUser",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Assignment",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyAuthenticationContextRule",
        "isEnabled":  false,
        "claimValue":  ""
    },
    {
        "Id":  "Enablement_EndUser_Assignment",
        "Target":  {
                       "Caller":  "EndUser",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Assignment",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyEnablementRule",
        "enabledRules":  [
                             "MultiFactorAuthentication",
                             "Justification"
                         ]
    },
    {
        "Id":  "Expiration_EndUser_Assignment",
        "Target":  {
                       "Caller":  "EndUser",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Assignment",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyExpirationRule",
        "isExpirationRequired":  false,
        "maximumDuration":  "PT8H"
    },
    {
        "Id":  "Notification_Approver_EndUser_Assignment",
        "Target":  {
                       "Caller":  "EndUser",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Assignment",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyNotificationRule",
        "notificationType":  "Email",
        "recipientType":  "Approver",
        "notificationLevel":  "All",
        "isDefaultRecipientsEnabled":  true,
        "notificationRecipients":  [

                                   ]
    },
    {
        "Id":  "Notification_Admin_EndUser_Assignment",
        "Target":  {
                       "Caller":  "EndUser",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Assignment",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyNotificationRule",
        "notificationType":  "Email",
        "recipientType":  "Admin",
        "notificationLevel":  "All",
        "isDefaultRecipientsEnabled":  true,
        "notificationRecipients":  [

                                   ]
    },
    {
        "Id":  "Notification_Requestor_EndUser_Assignment",
        "Target":  {
                       "Caller":  "EndUser",
                       "EnforcedSettings":  [

                                            ],
                       "InheritableSettings":  [

                                               ],
                       "Level":  "Assignment",
                       "Operations":  [
                                          "all"
                                      ],
                       "TargetObjects":  null
                   },
        "@odata.type":  "#microsoft.graph.unifiedRoleManagementPolicyNotificationRule",
        "notificationType":  "Email",
        "recipientType":  "Requestor",
        "notificationLevel":  "All",
        "isDefaultRecipientsEnabled":  true,
        "notificationRecipients":  [

                                   ]
    }
]
'@
            $mockRole = $json | ConvertFrom-Json
            Mock -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -MockWith {
                return $mockRole
            }

            Mock -CommandName Get-MgBetaPolicyRoleManagementPolicy -MockWith {
                return @{
                    Id = 'DirectoryRole_1e1b61e9-1bad-4b5f-aca3-973feb8d36e0_2d3a49e9-4a0b-4456-b381-3311753988a8'
                    Rules = $mockRole
                }
            }

            Mock -CommandName Update-MgBetaPolicyRoleManagementPolicyRule -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts

        Context -Name 'The role definition exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    ActivateApprover                                          = @()
                    ActivationMaxDuration                                     = 'PT8H'
                    ActivationReqJustification                                = $True
                    ActivationReqMFA                                          = $True
                    ActivationReqTicket                                       = $False
                    ActiveAlertNotificationAdditionalRecipient                = @()
                    ActiveAlertNotificationDefaultRecipient                   = $True
                    ActiveAlertNotificationOnlyCritical                       = $False
                    ActiveApproveNotificationAdditionalRecipient              = @()
                    ActiveApproveNotificationDefaultRecipient                 = $True
                    ActiveApproveNotificationOnlyCritical                     = $False
                    ActiveAssigneeNotificationAdditionalRecipient             = @()
                    ActiveAssigneeNotificationDefaultRecipient                = $True
                    ActiveAssigneeNotificationOnlyCritical                    = $False
                    ApplicationId                                             = $ConfigurationData.NonNodeData.ApplicationId
                    ApprovaltoActivate                                        = $False
                    AssignmentReqJustification                                = $True
                    AssignmentReqMFA                                          = $False
                    CertificateThumbprint                                     = $ConfigurationData.NonNodeData.CertificateThumbprint
                    Displayname                                               = 'User administrator'
                    EligibilityAssignmentReqJustification                     = $False
                    EligibilityAssignmentReqMFA                               = $False
                    EligibleAlertNotificationAdditionalRecipient              = @()
                    EligibleAlertNotificationDefaultRecipient                 = $True
                    EligibleAlertNotificationOnlyCritical                     = $False
                    EligibleApproveNotificationAdditionalRecipient            = @()
                    EligibleApproveNotificationDefaultRecipient               = $True
                    EligibleApproveNotificationOnlyCritical                   = $False
                    EligibleAssigneeNotificationAdditionalRecipient           = @()
                    EligibleAssigneeNotificationDefaultRecipient              = $True
                    EligibleAssigneeNotificationOnlyCritical                  = $False
                    EligibleAssignmentAlertNotificationAdditionalRecipient    = @()
                    EligibleAssignmentAlertNotificationDefaultRecipient       = $True
                    EligibleAssignmentAlertNotificationOnlyCritical           = $False
                    EligibleAssignmentAssigneeNotificationAdditionalRecipient = @()
                    EligibleAssignmentAssigneeNotificationDefaultRecipient    = $True
                    EligibleAssignmentAssigneeNotificationOnlyCritical        = $False
                    ExpireActiveAssignment                                    = 'P180D'
                    ExpireEligibleAssignment                                  = 'P365D'
                    Id                                                        = 'fe930be7-5e62-47db-91af-98c3a49a38b1'
                    PermanentActiveAssignmentisExpirationRequired             = $False
                    PermanentEligibleAssignmentisExpirationRequired           = $False
                }
            }

            It 'Should return Values from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADRoleSetting' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be "Present"
            }

            It 'Should return true from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleSetting' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Values are not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    ActivateApprover                                          = @()
                    ActivationMaxDuration                                     = 'PT8H'
                    ActivationReqJustification                                = $False
                    ActivationReqMFA                                          = $True
                    ActivationReqTicket                                       = $False
                    ActiveAlertNotificationAdditionalRecipient                = @()
                    ActiveAlertNotificationDefaultRecipient                   = $True
                    ActiveAlertNotificationOnlyCritical                       = $False
                    ActiveApproveNotificationAdditionalRecipient              = @()
                    ActiveApproveNotificationDefaultRecipient                 = $True
                    ActiveApproveNotificationOnlyCritical                     = $False
                    ActiveAssigneeNotificationAdditionalRecipient             = @()
                    ActiveAssigneeNotificationDefaultRecipient                = $True
                    ActiveAssigneeNotificationOnlyCritical                    = $False
                    ApplicationId                                             = $ConfigurationData.NonNodeData.ApplicationId
                    ApprovaltoActivate                                        = $False
                    AssignmentReqJustification                                = $True
                    AssignmentReqMFA                                          = $False
                    CertificateThumbprint                                     = $ConfigurationData.NonNodeData.CertificateThumbprint
                    Displayname                                               = 'User administrator'
                    EligibilityAssignmentReqJustification                     = $False
                    EligibilityAssignmentReqMFA                               = $False
                    EligibleAlertNotificationAdditionalRecipient              = @()
                    EligibleAlertNotificationDefaultRecipient                 = $True
                    EligibleAlertNotificationOnlyCritical                     = $False
                    EligibleApproveNotificationAdditionalRecipient            = @()
                    EligibleApproveNotificationDefaultRecipient               = $True
                    EligibleApproveNotificationOnlyCritical                   = $False
                    EligibleAssigneeNotificationAdditionalRecipient           = @()
                    EligibleAssigneeNotificationDefaultRecipient              = $True
                    EligibleAssigneeNotificationOnlyCritical                  = $False
                    EligibleAssignmentAlertNotificationAdditionalRecipient    = @()
                    EligibleAssignmentAlertNotificationDefaultRecipient       = $True
                    EligibleAssignmentAlertNotificationOnlyCritical           = $False
                    EligibleAssignmentAssigneeNotificationAdditionalRecipient = @()
                    EligibleAssignmentAssigneeNotificationDefaultRecipient    = $True
                    EligibleAssignmentAssigneeNotificationOnlyCritical        = $False
                    ExpireActiveAssignment                                    = 'P180D'
                    ExpireEligibleAssignment                                  = 'P365D'
                    Id                                                        = 'fe930be7-5e62-47db-91af-98c3a49a38b1'
                    PermanentActiveAssignmentisExpirationRequired             = $False
                    PermanentEligibleAssignmentisExpirationRequired           = $False
                }
            }

            It 'Should return values from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADRoleSetting' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be "Present"
            }

            It 'Should call the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleSetting' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaPolicyRoleManagementPolicyRule' -Exactly 15
            }
        }

        Context -Name 'Only the display name is supplied and values are not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    ActivateApprover                                          = @()
                    ActivationMaxDuration                                     = 'PT8H'
                    ActivationReqJustification                                = $False
                    ActivationReqMFA                                          = $True
                    ActivationReqTicket                                       = $False
                    ActiveAlertNotificationAdditionalRecipient                = @()
                    ActiveAlertNotificationDefaultRecipient                   = $True
                    ActiveAlertNotificationOnlyCritical                       = $False
                    ActiveApproveNotificationAdditionalRecipient              = @()
                    ActiveApproveNotificationDefaultRecipient                 = $True
                    ActiveApproveNotificationOnlyCritical                     = $False
                    ActiveAssigneeNotificationAdditionalRecipient             = @()
                    ActiveAssigneeNotificationDefaultRecipient                = $True
                    ActiveAssigneeNotificationOnlyCritical                    = $False
                    ApplicationId                                             = $ConfigurationData.NonNodeData.ApplicationId
                    ApprovaltoActivate                                        = $False
                    AssignmentReqJustification                                = $True
                    AssignmentReqMFA                                          = $False
                    CertificateThumbprint                                     = $ConfigurationData.NonNodeData.CertificateThumbprint
                    Displayname                                               = 'User administrator'
                    EligibilityAssignmentReqJustification                     = $False
                    EligibilityAssignmentReqMFA                               = $False
                    EligibleAlertNotificationAdditionalRecipient              = @()
                    EligibleAlertNotificationDefaultRecipient                 = $True
                    EligibleAlertNotificationOnlyCritical                     = $False
                    EligibleApproveNotificationAdditionalRecipient            = @()
                    EligibleApproveNotificationDefaultRecipient               = $True
                    EligibleApproveNotificationOnlyCritical                   = $False
                    EligibleAssigneeNotificationAdditionalRecipient           = @()
                    EligibleAssigneeNotificationDefaultRecipient              = $True
                    EligibleAssigneeNotificationOnlyCritical                  = $False
                    EligibleAssignmentAlertNotificationAdditionalRecipient    = @()
                    EligibleAssignmentAlertNotificationDefaultRecipient       = $True
                    EligibleAssignmentAlertNotificationOnlyCritical           = $False
                    EligibleAssignmentAssigneeNotificationAdditionalRecipient = @()
                    EligibleAssignmentAssigneeNotificationDefaultRecipient    = $True
                    EligibleAssignmentAssigneeNotificationOnlyCritical        = $False
                    ExpireActiveAssignment                                    = 'P180D'
                    ExpireEligibleAssignment                                  = 'P365D'
                    PermanentActiveAssignmentisExpirationRequired             = $False
                    PermanentEligibleAssignmentisExpirationRequired           = $False
                }
            }

            It 'Should resolve the role definition from the display name' {
                ((New-M365DSCResourceInstance -ResourceName 'AADRoleSetting' -Property $testParams).Get().ToHashtable()).Id | Should -Be 'fe930be7-5e62-47db-91af-98c3a49a38b1'
            }

            It 'Should return the current value of the drifted property from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADRoleSetting' -Property $testParams).Get().ToHashtable()).ActivationReqJustification | Should -Be $true
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleSetting' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'ReverseDSC tests' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential = $Credential
                }
            }

            It 'Should reverse engineer resource from the export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADRoleSetting' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
