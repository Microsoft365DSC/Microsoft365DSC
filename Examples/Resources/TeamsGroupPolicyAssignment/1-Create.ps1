<#
This examples configure a TeamsGroupPolicyAssignment.
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
        TeamsGroupPolicyAssignment 'TeamsGroupPolicyAssignment-Example'
        {
            Ensure                = 'Present'
            GroupDisplayname      = 'Sales and Marketing'
            PolicyName            = 'AllowCalling'
            PolicyType            = 'TeamsCallingPolicy'
            Priority              = 1
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
