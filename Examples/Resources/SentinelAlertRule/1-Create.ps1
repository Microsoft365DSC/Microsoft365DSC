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
        SentinelAlertRule "SentinelAlertRule-Example"
        {
            AlertDetailsOverride  = MSFT_SentinelAlertRuleAlertDetailsOverride{
                alertDescriptionFormat = "A cloud application was accessed from an unrecognised location by {{UserPrincipalName}}."
                alertDisplayNameFormat = "Unfamiliar access to {{AppDisplayName}}"
                alertDynamicProperties = @(
                    MSFT_SentinelAlertRuleAlertDetailsOverrideAlertDynamicProperty{
                        alertProperty      = "ProductComponentName"
                        alertPropertyValue = "AppDisplayName"
                    }
                )
            };
            CustomDetails         = @(
                MSFT_SentinelAlertRuleCustomDetails{
                    DetailKey   = "SignInLocation"
                    DetailValue = "Location"
                }
                MSFT_SentinelAlertRuleCustomDetails{
                    DetailKey   = "ClientAddress"
                    DetailValue = "IPAddress"
                }
            );
            Description           = "Raises an incident when a cloud application is accessed from an unrecognised location";
            DisplayName           = "Unfamiliar cloud application access";
            Enabled               = $true;
            Ensure                = "Present";
            EntityMappings        = @(
                MSFT_SentinelAlertRuleEntityMapping{
                    entityType    = "Account"
                    fieldMappings = @(
                        MSFT_SentinelAlertRuleEntityMappingFieldMapping{
                            columnName = "UserPrincipalName"
                            identifier = "FullName"
                        }
                    )
                }
                MSFT_SentinelAlertRuleEntityMapping{
                    entityType    = "CloudApplication"
                    fieldMappings = @(
                        MSFT_SentinelAlertRuleEntityMappingFieldMapping{
                            columnName = "AppId"
                            identifier = "AppId"
                        }
                    )
                }
                MSFT_SentinelAlertRuleEntityMapping{
                    entityType    = "IP"
                    fieldMappings = @(
                        MSFT_SentinelAlertRuleEntityMappingFieldMapping{
                            columnName = "IPAddress"
                            identifier = "Address"
                        }
                    )
                }
            );
            EventGroupingSettings = MSFT_SentinelAlertRuleEventGroupingSettings{
                aggregationKind = "SingleAlert"
            };
            IncidentConfiguration = MSFT_SentinelAlertRuleIncidentConfiguration{
                createIncident        = $true
                groupingConfiguration = MSFT_SentinelAlertRuleIncidentConfigurationGroupingConfiguration{
                    enabled              = $true
                    groupByAlertDetails  = @("DisplayName")
                    groupByCustomDetails = @("SignInLocation")
                    groupByEntities      = @("Account", "CloudApplication")
                    lookbackDuration     = "PT5H"
                    matchingMethod       = "Selected"
                    reopenClosedIncident = $true
                }
            };
            Kind                  = "NRT";
            Query                 = "SigninLogs | where ResultType == 0 | where RiskLevelDuringSignIn in ('high', 'medium') | project TimeGenerated, UserPrincipalName, AppId, AppDisplayName, IPAddress, Location";
            ResourceGroupName     = "<resource-group-name>";
            Severity              = "Medium";
            SubscriptionId        = "<subscription-id>";
            SubTechniques         = @("T1078.004", "T1110.003");
            SuppressionDuration   = "PT5H";
            SuppressionEnabled    = "false";
            Tactics               = @("CredentialAccess", "InitialAccess");
            Techniques            = @("T1078", "T1110");
            WorkspaceName         = "<log-analytics-workspace-name>";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
