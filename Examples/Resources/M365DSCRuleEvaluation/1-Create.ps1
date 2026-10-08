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
        M365DSCRuleEvaluation 'M365DSCRuleEvaluation-Example'
        {
            ResourceTypeName      = 'TeamsMeetingPolicy'
            RuleDefinition        = "`$_.AllowAnonymousUsersToJoinMeeting -eq `$true"
            RuleName              = "Meeting policies must block anonymous participants"
            AfterRuleCountQuery   = "-eq 0"
            Filter                = "Tag:*"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
