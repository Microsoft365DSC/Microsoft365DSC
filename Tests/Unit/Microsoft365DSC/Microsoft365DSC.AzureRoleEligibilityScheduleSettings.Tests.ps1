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

$CurrentScriptPath = $PSCommandPath.Split('\')
$CurrentScriptName = $CurrentScriptPath[$CurrentScriptPath.Length -1]
$ResourceName      = $CurrentScriptName.Split('.')[1]
$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource $ResourceName -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
                return @{
                    ManagementUrl = 'https://management.azure.com/'
                }
            }

            Mock -CommandName Get-MgBetaDirectoryObjectById -MockWith {
                return $null
            }

            Mock -CommandName Get-MgUser -MockWith {
                return $null
            }

            Mock -CommandName Get-MgGroup -MockWith {
                return $null
            }

            $Script:mockRules = @(
                @{
                    id = "Expiration_EndUser_Assignment"
                    ruleType = "RoleManagementPolicyExpirationRule"
                    isExpirationRequired = $true
                    maximumDuration = "PT4H"
                    target = @{ caller = "EndUser"; operations = @("All"); level = "Assignment" }
                }
                @{
                    id = "Enablement_EndUser_Assignment"
                    ruleType = "RoleManagementPolicyEnablementRule"
                    enabledRules = @("Justification", "Ticketing")
                    target = @{ caller = "EndUser"; operations = @("All"); level = "Assignment" }
                }
                @{
                    id = "Approval_EndUser_Assignment"
                    ruleType = "RoleManagementPolicyApprovalRule"
                    setting = @{
                        isApprovalRequired = $true
                        isApprovalRequiredForExtension = $false
                        isRequestorJustificationRequired = $true
                        approvalMode = "SingleStage"
                        approvalStages = @(
                            @{
                                approvalStageTimeOutInDays = 1
                                isApproverJustificationRequired = $true
                                escalationTimeInMinutes = 0
                                isEscalationEnabled = $false
                                primaryApprovers = @()
                                escalationApprovers = @()
                            }
                        )
                    }
                    target = @{ caller = "EndUser"; operations = @("All"); level = "Assignment" }
                }
                @{
                    id = "Expiration_Admin_Eligibility"
                    ruleType = "RoleManagementPolicyExpirationRule"
                    isExpirationRequired = $true
                    maximumDuration = "P180D"
                    target = @{ caller = "Admin"; operations = @("All"); level = "Eligibility" }
                }
                @{
                    id = "Expiration_Admin_Assignment"
                    ruleType = "RoleManagementPolicyExpirationRule"
                    isExpirationRequired = $true
                    maximumDuration = "P90D"
                    target = @{ caller = "Admin"; operations = @("All"); level = "Assignment" }
                }
                @{
                    id = "Enablement_Admin_Assignment"
                    ruleType = "RoleManagementPolicyEnablementRule"
                    enabledRules = @("Justification")
                    target = @{ caller = "Admin"; operations = @("All"); level = "Assignment" }
                }
                @{
                    id = "Enablement_Admin_Eligibility"
                    ruleType = "RoleManagementPolicyEnablementRule"
                    enabledRules = @()
                    target = @{ caller = "Admin"; operations = @("All"); level = "Eligibility" }
                }
                @{
                    id = "Notification_Admin_Admin_Eligibility"
                    ruleType = "RoleManagementPolicyNotificationRule"
                    notificationType = "Email"; recipientType = "Admin"
                    notificationLevel = "Critical"
                    isDefaultRecipientsEnabled = $true
                    notificationRecipients = @("eligibility-admin@contoso.com")
                    target = @{ caller = "Admin"; operations = @("All"); level = "Eligibility" }
                }
                @{
                    id = "Notification_Requestor_Admin_Eligibility"
                    ruleType = "RoleManagementPolicyNotificationRule"
                    notificationType = "Email"; recipientType = "Requestor"
                    notificationLevel = "All"
                    isDefaultRecipientsEnabled = $true
                    notificationRecipients = @()
                    target = @{ caller = "Admin"; operations = @("All"); level = "Eligibility" }
                }
                @{
                    id = "Notification_Approver_Admin_Eligibility"
                    ruleType = "RoleManagementPolicyNotificationRule"
                    notificationType = "Email"; recipientType = "Approver"
                    notificationLevel = "All"
                    isDefaultRecipientsEnabled = $true
                    notificationRecipients = @()
                    target = @{ caller = "Admin"; operations = @("All"); level = "Eligibility" }
                }
                @{
                    id = "Notification_Admin_Admin_Assignment"
                    ruleType = "RoleManagementPolicyNotificationRule"
                    notificationType = "Email"; recipientType = "Admin"
                    notificationLevel = "All"
                    isDefaultRecipientsEnabled = $true
                    notificationRecipients = @("assignment-admin@contoso.com")
                    target = @{ caller = "Admin"; operations = @("All"); level = "Assignment" }
                }
                @{
                    id = "Notification_Requestor_Admin_Assignment"
                    ruleType = "RoleManagementPolicyNotificationRule"
                    notificationType = "Email"; recipientType = "Requestor"
                    notificationLevel = "All"
                    isDefaultRecipientsEnabled = $true
                    notificationRecipients = @()
                    target = @{ caller = "Admin"; operations = @("All"); level = "Assignment" }
                }
                @{
                    id = "Notification_Approver_Admin_Assignment"
                    ruleType = "RoleManagementPolicyNotificationRule"
                    notificationType = "Email"; recipientType = "Approver"
                    notificationLevel = "All"
                    isDefaultRecipientsEnabled = $true
                    notificationRecipients = @()
                    target = @{ caller = "Admin"; operations = @("All"); level = "Assignment" }
                }
                @{
                    id = "Notification_Admin_EndUser_Assignment"
                    ruleType = "RoleManagementPolicyNotificationRule"
                    notificationType = "Email"; recipientType = "Admin"
                    notificationLevel = "All"
                    isDefaultRecipientsEnabled = $true
                    notificationRecipients = @("admin@contoso.com")
                    target = @{ caller = "EndUser"; operations = @("All"); level = "Assignment" }
                }
                @{
                    id = "Notification_Requestor_EndUser_Assignment"
                    ruleType = "RoleManagementPolicyNotificationRule"
                    notificationType = "Email"; recipientType = "Requestor"
                    notificationLevel = "All"
                    isDefaultRecipientsEnabled = $true
                    notificationRecipients = @()
                    target = @{ caller = "EndUser"; operations = @("All"); level = "Assignment" }
                }
                @{
                    id = "Notification_Approver_EndUser_Assignment"
                    ruleType = "RoleManagementPolicyNotificationRule"
                    notificationType = "Email"; recipientType = "Approver"
                    notificationLevel = "All"
                    isDefaultRecipientsEnabled = $true
                    notificationRecipients = @()
                    target = @{ caller = "EndUser"; operations = @("All"); level = "Assignment" }
                }
                @{
                    id = "AuthenticationContext_EndUser_Assignment"
                    ruleType = "RoleManagementPolicyAuthenticationContextRule"
                    isEnabled = $false
                    claimValue = ""
                    target = @{ caller = "EndUser"; operations = @("All"); level = "Assignment" }
                }
            )

            Mock -CommandName Invoke-AzRestMethod -MockWith {
                return @{
                    Content = ConvertTo-Json (@{
                        value = @(
                            @{
                                id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleManagementPolicyAssignments/test_assignment"
                                properties = @{
                                    roleDefinitionId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000001"
                                    policyId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleManagementPolicies/test_policy_id"
                                    roleDefinitionDisplayName = "Owner"
                                    policyAssignmentProperties = @{
                                        roleDefinition = @{
                                            displayName = "Owner"
                                        }
                                    }
                                }
                            }
                        )
                        properties = @{
                            rules = $Script:mockRules
                        }
                    }) -Depth 20
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }

        Context -Name "The activation settings are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName = "Owner"
                    ScopeId                   = "subscriptions/00000000-0000-0000-0000-000000000000"
                    ActivationMaxDuration     = "PT4H"
                    ActivationReqJustification = $true
                    ActivationReqTicket       = $true
                    ActivationReqMFA          = $false
                    ApprovaltoActivate        = $true
                    ActivateApprover          = @()
                    SubscriptionId            = "00000000-0000-0000-0000-000000000000"
                    Credential                = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The activation settings are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName = "Owner"
                    ScopeId                   = "subscriptions/00000000-0000-0000-0000-000000000000"
                    ActivationMaxDuration     = "PT8H" # drift
                    ActivationReqJustification = $true
                    ActivationReqTicket       = $true
                    ActivationReqMFA          = $false
                    SubscriptionId            = "00000000-0000-0000-0000-000000000000"
                    Credential                = $Credential;
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Set() } | Should -Not -Throw
            }
        }

        Context -Name "The eligible assignment notification is already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName                    = "Owner"
                    ScopeId                                      = "subscriptions/00000000-0000-0000-0000-000000000000"
                    EligibleAlertNotificationDefaultRecipient    = $true
                    EligibleAlertNotificationAdditionalRecipient = @("eligibility-admin@contoso.com")
                    EligibleAlertNotificationOnlyCritical        = $true
                    SubscriptionId                               = "00000000-0000-0000-0000-000000000000"
                    Credential                                   = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The eligible assignment notification is NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName                    = "Owner"
                    ScopeId                                      = "subscriptions/00000000-0000-0000-0000-000000000000"
                    EligibleAlertNotificationDefaultRecipient    = $false # drift
                    EligibleAlertNotificationAdditionalRecipient = @("eligibility-admin@contoso.com")
                    EligibleAlertNotificationOnlyCritical        = $true
                    SubscriptionId                               = "00000000-0000-0000-0000-000000000000"
                    Credential                                   = $Credential;
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Set() } | Should -Not -Throw
            }
        }

        Context -Name "Partial notification: only AdditionalRecipient specified for active assignee notification" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName                        = "Owner"
                    ScopeId                                          = "subscriptions/00000000-0000-0000-0000-000000000000"
                    ActiveAssigneeNotificationAdditionalRecipient    = @("foo@test.com")
                    SubscriptionId                                   = "00000000-0000-0000-0000-000000000000"
                    Credential                                       = $Credential;
                }
            }

            It 'Should call the Set method without error when only AdditionalRecipient is specified' {
                { (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Set() } | Should -Not -Throw
            }
        }

        Context -Name "Single notificationRecipients is serialized as JSON array (not scalar) in PATCH payload" -Fixture {
            BeforeAll {
                $Script:capturedPayload = $null

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    if ($Method -eq 'PATCH')
                    {
                        $Script:capturedPayload = $Payload
                        return @{ Content = ConvertTo-Json @{} -Depth 5 }
                    }
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @(
                                @{
                                    id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleManagementPolicyAssignments/test_assignment"
                                    properties = @{
                                        roleDefinitionId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000001"
                                        policyId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleManagementPolicies/test_policy_id"
                                        roleDefinitionDisplayName = "Owner"
                                        policyAssignmentProperties = @{
                                            roleDefinition = @{
                                                displayName = "Owner"
                                            }
                                        }
                                    }
                                }
                            )
                            properties = @{
                                rules = $Script:mockRules
                            }
                        }) -Depth 20
                    }
                }

                $testParams = @{
                    RoleDefinitionDisplayName                        = "Owner"
                    ScopeId                                          = "subscriptions/00000000-0000-0000-0000-000000000000"
                    ActiveAssigneeNotificationAdditionalRecipient    = @("foo@test.com")
                    SubscriptionId                                   = "00000000-0000-0000-0000-000000000000"
                    Credential                                       = $Credential;
                }
            }

            It 'Should serialize a single notificationRecipients email as a JSON array in the PATCH payload' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Set()
                $Script:capturedPayload | Should -Not -BeNullOrEmpty
                # Verify the email is serialized as a JSON array ["foo@test.com"], not a plain string
                $Script:capturedPayload | Should -Match '"notificationRecipients":\s*\[\s*"foo@test\.com"\s*\]'
            }
        }

        Context -Name "Partial notification: only DefaultRecipient specified for eligible alert notification" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName                    = "Owner"
                    ScopeId                                      = "subscriptions/00000000-0000-0000-0000-000000000000"
                    EligibleAlertNotificationDefaultRecipient    = $false
                    SubscriptionId                               = "00000000-0000-0000-0000-000000000000"
                    Credential                                   = $Credential;
                }
            }

            It 'Should call the Set method without error when only DefaultRecipient is specified' {
                { (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Set() } | Should -Not -Throw
            }
        }

        Context -Name "Partial notification: only OnlyCritical specified for activation alert notification" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName                       = "Owner"
                    ScopeId                                         = "subscriptions/00000000-0000-0000-0000-000000000000"
                    ActivationAlertNotificationOnlyCritical         = $true
                    SubscriptionId                                  = "00000000-0000-0000-0000-000000000000"
                    Credential                                      = $Credential;
                }
            }

            It 'Should call the Set method without error when only OnlyCritical is specified' {
                { (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Set() } | Should -Not -Throw
            }
        }

        Context -Name "The activation alert notification is already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName                       = "Owner"
                    ScopeId                                         = "subscriptions/00000000-0000-0000-0000-000000000000"
                    ActivationAlertNotificationDefaultRecipient     = $true
                    ActivationAlertNotificationAdditionalRecipient  = @("admin@contoso.com")
                    ActivationAlertNotificationOnlyCritical         = $false
                    SubscriptionId                                  = "00000000-0000-0000-0000-000000000000"
                    Credential                                      = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The expiration settings for eligible assignments are in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName                       = "Owner"
                    ScopeId                                         = "subscriptions/00000000-0000-0000-0000-000000000000"
                    PermanentEligibleAssignmentisExpirationRequired = $true
                    ExpireEligibleAssignment                        = "P180D"
                    SubscriptionId                                  = "00000000-0000-0000-0000-000000000000"
                    Credential                                      = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The expiration settings for eligible assignments are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName                       = "Owner"
                    ScopeId                                         = "subscriptions/00000000-0000-0000-0000-000000000000"
                    PermanentEligibleAssignmentisExpirationRequired = $false # drift
                    ExpireEligibleAssignment                        = "P180D"
                    SubscriptionId                                  = "00000000-0000-0000-0000-000000000000"
                    Credential                                      = $Credential;
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name "The enablement rule for active assignment is in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName  = "Owner"
                    ScopeId                    = "subscriptions/00000000-0000-0000-0000-000000000000"
                    AssignmentReqMFA           = $false
                    AssignmentReqJustification = $true
                    SubscriptionId             = "00000000-0000-0000-0000-000000000000"
                    Credential                 = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The enablement rule for active assignment is NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName  = "Owner"
                    ScopeId                    = "subscriptions/00000000-0000-0000-0000-000000000000"
                    AssignmentReqMFA           = $true # drift
                    AssignmentReqJustification = $true
                    SubscriptionId             = "00000000-0000-0000-0000-000000000000"
                    Credential                 = $Credential;
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Set() } | Should -Not -Throw
            }
        }

        Context -Name "Partial enablement: only Justification and Ticketing specified for EndUser Assignment" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName  = "Owner"
                    ScopeId                    = "subscriptions/00000000-0000-0000-0000-000000000000"
                    ActivationReqJustification = $true
                    ActivationReqTicket        = $true
                    SubscriptionId             = "00000000-0000-0000-0000-000000000000"
                    Credential                 = $Credential;
                }
            }

            It 'Should call the Set method without error when MFA is not specified' {
                { (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Set() } | Should -Not -Throw
            }
        }

        Context -Name "Partial enablement: only Justification specified for Admin Assignment" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName  = "Owner"
                    ScopeId                    = "subscriptions/00000000-0000-0000-0000-000000000000"
                    AssignmentReqJustification = $true
                    SubscriptionId             = "00000000-0000-0000-0000-000000000000"
                    Credential                 = $Credential;
                }
            }

            It 'Should call the Set method without error when MFA is not specified' {
                { (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Set() } | Should -Not -Throw
            }
        }

        Context -Name "Partial enablement: only MFA specified for Admin Assignment" -Fixture {
            BeforeAll {
                $testParams = @{
                    RoleDefinitionDisplayName = "Owner"
                    ScopeId                   = "subscriptions/00000000-0000-0000-0000-000000000000"
                    AssignmentReqMFA          = $true
                    SubscriptionId            = "00000000-0000-0000-0000-000000000000"
                    Credential                = $Credential;
                }
            }

            It 'Should call the Set method without error when Justification is not specified' {
                { (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Set() } | Should -Not -Throw
            }
        }

        Context -Name "The approval settings with user approver are in the desired state" -Fixture {
            BeforeAll {
                $Script:mockRulesWithUserApprover = $Script:mockRules | ForEach-Object {
                    if ($_.id -eq 'Approval_EndUser_Assignment')
                    {
                        @{
                            id = $_.id
                            ruleType = $_.ruleType
                            setting = @{
                                isApprovalRequired = $true
                                isApprovalRequiredForExtension = $false
                                isRequestorJustificationRequired = $true
                                approvalMode = "SingleStage"
                                approvalStages = @(
                                    @{
                                        approvalStageTimeOutInDays = 1
                                        isApproverJustificationRequired = $true
                                        escalationTimeInMinutes = 0
                                        isEscalationEnabled = $false
                                        primaryApprovers = @(
                                            @{
                                                id = "11111111-1111-1111-1111-111111111111"
                                                userType = "User"
                                                isBackup = $false
                                            }
                                        )
                                        escalationApprovers = @()
                                    }
                                )
                            }
                            target = $_.target
                        }
                    }
                    else
                    {
                        $_
                    }
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @(
                                @{
                                    id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleManagementPolicyAssignments/test_assignment"
                                    properties = @{
                                        roleDefinitionId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000001"
                                        policyId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleManagementPolicies/test_policy_id"
                                        roleDefinitionDisplayName = "Owner"
                                        policyAssignmentProperties = @{
                                            roleDefinition = @{
                                                displayName = "Owner"
                                            }
                                        }
                                    }
                                }
                            )
                            properties = @{
                                rules = $Script:mockRulesWithUserApprover
                            }
                        }) -Depth 20
                    }
                }

                Mock -CommandName Get-MgBetaDirectoryObjectById -MockWith {
                    if ($Ids -contains '11111111-1111-1111-1111-111111111111')
                    {
                        return @{
                            Id                   = '11111111-1111-1111-1111-111111111111'
                            '@odata.type'     = '#microsoft.graph.user'
                            userPrincipalName = 'approver@contoso.com'
                        }
                    }
                    return $null
                }

                Mock -CommandName Get-MgUser -MockWith {
                    if ($Filter -like "*approver@contoso.com*")
                    {
                        return @{ Id = '11111111-1111-1111-1111-111111111111'; UserPrincipalName = 'approver@contoso.com' }
                    }
                    return $null
                } -ParameterFilter { $Filter }

                $testParams = @{
                    RoleDefinitionDisplayName = "Owner"
                    ScopeId                   = "subscriptions/00000000-0000-0000-0000-000000000000"
                    ApprovaltoActivate        = $true
                    ActivateApprover          = @("approver@contoso.com")
                    SubscriptionId            = "00000000-0000-0000-0000-000000000000"
                    Credential                = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return the user approver UPN from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Get().ToHashtable()
                $result.ActivateApprover | Should -Contain "approver@contoso.com"
            }
        }

        Context -Name "The approval settings with user and group approvers should call Set without error" -Fixture {
            BeforeAll {
                $Script:mockRulesWithMixedApprovers = $Script:mockRules | ForEach-Object {
                    if ($_.id -eq 'Approval_EndUser_Assignment')
                    {
                        @{
                            id = $_.id
                            ruleType = $_.ruleType
                            setting = @{
                                isApprovalRequired = $true
                                isApprovalRequiredForExtension = $false
                                isRequestorJustificationRequired = $true
                                approvalMode = "SingleStage"
                                approvalStages = @(
                                    @{
                                        approvalStageTimeOutInDays = 1
                                        isApproverJustificationRequired = $true
                                        escalationTimeInMinutes = 0
                                        isEscalationEnabled = $false
                                        primaryApprovers = @(
                                            @{
                                                id = "22222222-2222-2222-2222-222222222222"
                                                userType = "User"
                                                isBackup = $false
                                            },
                                            @{
                                                id = "33333333-3333-3333-3333-333333333333"
                                                userType = "Group"
                                                isBackup = $false
                                            }
                                        )
                                        escalationApprovers = @()
                                    }
                                )
                            }
                            target = $_.target
                        }
                    }
                    else
                    {
                        $_
                    }
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @(
                                @{
                                    id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleManagementPolicyAssignments/test_assignment"
                                    properties = @{
                                        roleDefinitionId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000001"
                                        policyId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleManagementPolicies/test_policy_id"
                                        roleDefinitionDisplayName = "Owner"
                                        policyAssignmentProperties = @{
                                            roleDefinition = @{
                                                displayName = "Owner"
                                            }
                                        }
                                    }
                                }
                            )
                            properties = @{
                                rules = $Script:mockRulesWithMixedApprovers
                            }
                        }) -Depth 20
                    }
                }

                Mock -CommandName Get-MgBetaDirectoryObjectById -MockWith {
                    if ($Ids -contains '22222222-2222-2222-2222-222222222222')
                    {
                        return @{
                            Id                   = '22222222-2222-2222-2222-222222222222'
                            '@odata.type'     = '#microsoft.graph.user'
                            userPrincipalName = 'approver@contoso.com'
                        }
                    }
                    elseif ($Ids -contains '33333333-3333-3333-3333-333333333333')
                    {
                        return @{
                            Id                   = '33333333-3333-3333-3333-333333333333'
                            '@odata.type'  = '#microsoft.graph.group'
                            displayName    = 'PIM Approvers'
                        }
                    }
                    return $null
                }

                Mock -CommandName Get-MgUser -MockWith {
                    if ($Filter -like "*approver@contoso.com*")
                    {
                        return @{ Id = '22222222-2222-2222-2222-222222222222'; UserPrincipalName = 'approver@contoso.com' }
                    }
                    return $null
                } -ParameterFilter { $Filter }

                Mock -CommandName Get-MgGroup -MockWith {
                    if ($Filter -like "*PIM Approvers*")
                    {
                        return @{ Id = '33333333-3333-3333-3333-333333333333'; DisplayName = 'PIM Approvers' }
                    }
                    return $null
                } -ParameterFilter { $Filter }

                $testParams = @{
                    RoleDefinitionDisplayName = "Owner"
                    ScopeId                   = "subscriptions/00000000-0000-0000-0000-000000000000"
                    ApprovaltoActivate        = $true
                    ActivateApprover          = @("approver@contoso.com", "PIM Approvers")
                    SubscriptionId            = "00000000-0000-0000-0000-000000000000"
                    Credential                = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should call the Set method without error' {
                { (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Set() } | Should -Not -Throw
            }

            It 'Should return all approvers with correct names from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AzureRoleEligibilityScheduleSettings' -Property $testParams).Get().ToHashtable()
                $result.ActivateApprover | Should -HaveCount 2
                $result.ActivateApprover | Should -Contain "approver@contoso.com"
                $result.ActivateApprover | Should -Contain "PIM Approvers"
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    SubscriptionId = "00000000-0000-0000-0000-000000000000"
                    Credential     = $Credential
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @(
                                @{
                                    subscriptionId = "00000000-0000-0000-0000-000000000000"
                                    displayName = "TestSubscription"
                                }
                            )
                        }) -Depth 10
                    }
                } -ParameterFilter { $Uri -like "*subscriptions?*" }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @()
                        }) -Depth 10
                    }
                } -ParameterFilter { $Uri -like "*resourcegroups*" }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @()
                        }) -Depth 10
                    }
                } -ParameterFilter { $Uri -like "*managementGroups*" }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @(
                                @{
                                    id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleManagementPolicyAssignments/test_assignment"
                                    properties = @{
                                        roleDefinitionId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000001"
                                        policyId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleManagementPolicies/test_policy_id"
                                        policyAssignmentProperties = @{
                                            roleDefinition = @{
                                                displayName = "Owner"
                                            }
                                        }
                                    }
                                }
                            )
                        }) -Depth 10
                    }
                } -ParameterFilter { $Uri -like "*roleManagementPolicyAssignments*" }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @(
                                @{
                                    name = "test_policy_id"
                                    properties = @{
                                        lastModifiedBy = @{
                                            displayName = "Admin"
                                        }
                                        lastModifiedDateTime = "2024-01-15T10:00:00Z"
                                        rules = $Script:mockRules
                                    }
                                }
                            )
                        }) -Depth 20
                    }
                } -ParameterFilter { $Uri -like "*roleManagementPolicies`?*" -and $Uri -notlike "*Assignments*" }

                Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                    return @{}
                }

                Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
                    return "AzureRoleEligibilityScheduleSettings 'Owner' {}`r`n"
                }

                Mock -CommandName Save-M365DSCPartialExport -MockWith {
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AzureRoleEligibilityScheduleSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }

        Context -Name 'ReverseDSC Tests - ModifiedOnly filter skips unmodified policies' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    SubscriptionId = "00000000-0000-0000-0000-000000000000"
                    Credential     = $Credential
                    Filter         = 'ModifiedOnly'
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @(
                                @{
                                    subscriptionId = "00000000-0000-0000-0000-000000000000"
                                    displayName = "TestSubscription"
                                }
                            )
                        }) -Depth 10
                    }
                } -ParameterFilter { $Uri -like "*subscriptions?*" }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @()
                        }) -Depth 10
                    }
                } -ParameterFilter { $Uri -like "*resourcegroups*" }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @()
                        }) -Depth 10
                    }
                } -ParameterFilter { $Uri -like "*managementGroups*" }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @(
                                @{
                                    id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleManagementPolicyAssignments/test_assignment"
                                    properties = @{
                                        roleDefinitionId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000001"
                                        policyId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleManagementPolicies/test_policy_id"
                                        policyAssignmentProperties = @{
                                            roleDefinition = @{
                                                displayName = "Owner"
                                            }
                                        }
                                    }
                                }
                            )
                        }) -Depth 10
                    }
                } -ParameterFilter { $Uri -like "*roleManagementPolicyAssignments*" }

                # Return policy with null lastModifiedBy and lastModifiedDateTime (Azure defaults)
                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @(
                                @{
                                    name = "test_policy_id"
                                    properties = @{
                                        rules = $Script:mockRules
                                    }
                                }
                            )
                        }) -Depth 20
                    }
                } -ParameterFilter { $Uri -like "*roleManagementPolicies`?*" -and $Uri -notlike "*Assignments*" }
            }

            It 'Should return empty string when ModifiedOnly filter is set and all policies are unmodified Azure defaults' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AzureRoleEligibilityScheduleSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -BeNullOrEmpty
            }
        }

        Context -Name 'ReverseDSC Tests - No filter exports unmodified policies' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    SubscriptionId = "00000000-0000-0000-0000-000000000000"
                    Credential     = $Credential
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @(
                                @{
                                    subscriptionId = "00000000-0000-0000-0000-000000000000"
                                    displayName = "TestSubscription"
                                }
                            )
                        }) -Depth 10
                    }
                } -ParameterFilter { $Uri -like "*subscriptions?*" }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @()
                        }) -Depth 10
                    }
                } -ParameterFilter { $Uri -like "*resourcegroups*" }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @()
                        }) -Depth 10
                    }
                } -ParameterFilter { $Uri -like "*managementGroups*" }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @(
                                @{
                                    id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleManagementPolicyAssignments/test_assignment"
                                    properties = @{
                                        roleDefinitionId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000001"
                                        policyId = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleManagementPolicies/test_policy_id"
                                        policyAssignmentProperties = @{
                                            roleDefinition = @{
                                                displayName = "Owner"
                                            }
                                        }
                                    }
                                }
                            )
                        }) -Depth 10
                    }
                } -ParameterFilter { $Uri -like "*roleManagementPolicyAssignments*" }

                # Return policy with null lastModifiedDateTime (Azure defaults) - should still be exported when no filter
                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json (@{
                            value = @(
                                @{
                                    name = "test_policy_id"
                                    properties = @{
                                        rules = $Script:mockRules
                                    }
                                }
                            )
                        }) -Depth 20
                    }
                } -ParameterFilter { $Uri -like "*roleManagementPolicies`?*" -and $Uri -notlike "*Assignments*" }

                Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                    return @{}
                }

                Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
                    return "AzureRoleEligibilityScheduleSettings 'Owner' {}`r`n"
                }

                Mock -CommandName Save-M365DSCPartialExport -MockWith {
                }
            }

            It 'Should export unmodified policies when no filter is specified' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AzureRoleEligibilityScheduleSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
