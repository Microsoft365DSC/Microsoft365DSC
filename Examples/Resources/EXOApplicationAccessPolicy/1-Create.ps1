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
        EXOApplicationAccessPolicy 'EXOApplicationAccessPolicy-Example'
        {
            Identity              = "Reporting App Mailbox Access"
            AccessRight           = "DenyAccess"
            AppID                 = '3dbc2ae1-7198-45ed-9f9f-d86ba3ec35b5'
            PolicyScopeGroupId    = "Executives@$TenantId"
            Description           = "Engineering Group Policy"
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
