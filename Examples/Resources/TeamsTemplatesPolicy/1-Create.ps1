<#
This example adds a new Teams Calling Policy.
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
        TeamsTemplatesPolicy "TeamsTemplatesPolicy-Example"
        {
            Description           = "Hides the templates that are not approved for use";
            Ensure                = "Present";
            HiddenTemplates       = @("Manage a Project","Manage an Event","Adopt Office 365","Organize Help Desk");
            Identity              = "Approved Templates";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
