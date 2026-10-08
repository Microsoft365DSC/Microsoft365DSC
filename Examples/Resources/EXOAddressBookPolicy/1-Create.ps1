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
        EXOAddressBookPolicy 'EXOAddressBookPolicy-Example'
        {
            Name                  = "All Fabrikam ABP"
            AddressLists          = "\All Distribution Lists"
            RoomList              = "\All Rooms"
            OfflineAddressBook    = "\Default Offline Address Book"
            GlobalAddressList     = "\Default Global Address List"
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
