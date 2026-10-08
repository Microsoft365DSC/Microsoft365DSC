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
        M365DSCGraphAPIRuleEvaluation 'M365DSCGraphAPIRuleEvaluation-Example'
        {
            APIUrl                = 'https://graph.microsoft.com/beta/serviceprincipals'
            InstancesProperty     = 'value'
            InstanceIdentifier    = 'displayName'
            RuleDefinition        = "`$_.appCategory -eq 'mdm'"
            RuleName              = "Only approved device management applications are registered"
            AfterRuleCountQuery   = '-eq 4'
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
