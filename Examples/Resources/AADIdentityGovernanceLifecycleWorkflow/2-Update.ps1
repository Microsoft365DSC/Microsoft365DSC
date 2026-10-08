<#
This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.
#>

Configuration Example
{
    param
    (
        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )

    Import-DscResource -ModuleName Microsoft365DSC

    Node localhost
    {
        AADIdentityGovernanceLifecycleWorkflow "AADIdentityGovernanceLifecycleWorkflow-Example"
        {
            AdministrationScopeTargets = @('4f9dc456-0574-4122-9e55-8b4cc494b27d');
            Category                   = "joiner";
            #updated description
            Description                = "Updated description the onboard of prehire employee";
            DisplayName                = "Onboard pre-hire employee updated version";
            Ensure                     = "Present";
            ExecutionConditions        = MSFT_IdentityGovernanceWorkflowExecutionConditions {
                ScopeValue   = MSFT_IdentityGovernanceScope {
                    #updated rule
                    Rule      = '(not (country eq ''America''))'
                    ODataType = '#microsoft.graph.identityGovernance.ruleBasedSubjectSet'
                }
                TriggerValue = MSFT_IdentityGovernanceTrigger {
                    OffsetInDays       = 4
                    TimeBasedAttribute = 'employeeHireDate'
                    ODataType          = '#microsoft.graph.identityGovernance.timeBasedAttributeTrigger'
                }
                ODataType    = '#microsoft.graph.identityGovernance.triggerAndScopeBasedConditions'
            };
            IsEnabled                  = $True;
            IsSchedulingEnabled        = $False;
            Tasks                      = @(
                MSFT_AADIdentityGovernanceTask {
                    DisplayName       = 'Add user to groups'
                    #updated description
                    Description       = 'Add user to selected groups updated'
                    Category          = 'joiner,leaver,mover'
                    IsEnabled         = $True
                    ExecutionSequence = 1
                    ContinueOnError   = $True
                    TaskDefinitionId  = '22085229-5809-45e8-97fd-270d28d66910'
                    Arguments         = @(
                        MSFT_AADIdentityGovernanceTaskArguments {
                            Name  = 'groupID'
                            Value = '7ad01e00-8c3a-42a6-baaf-39f2390b2565'
                        }
                    )
                }
            );
            ApplicationId              = $ApplicationId
            TenantId                   = $TenantId
            CertificateThumbprint      = $CertificateThumbprint
        }
    }
}
