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
        AADGroupsSettings 'AADGroupsSettings-Example'
        {
            IsSingleInstance              = "Yes"
            AllowGuestsToAccessGroups     = $True
            AllowGuestsToBeGroupOwner     = $True
            AllowToAddGuests              = $True
            EnableGroupCreation           = $True
            GroupCreationAllowedGroupName = "All Company"
            GuestUsageGuidelinesUrl       = "https://contoso.com/guestusage"
            UsageGuidelinesUrl            = "https://contoso.com/usage"
            Ensure                        = "Present"
            ApplicationId                 = $ApplicationId
            TenantId                      = $TenantId
            CertificateThumbprint         = $CertificateThumbprint
        }
    }
}
