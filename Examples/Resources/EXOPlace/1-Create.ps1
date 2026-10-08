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
        EXOPlace 'EXOPlace-Example'
        {
            AudioDeviceName        = "MyAudioDevice";
            Building               = "Studio B";
            Capacity               = 15;
            City                   = "Redmond";
            CountryOrRegion        = "US";
            DisplayDeviceName      = "DisplayDeviceName";
            DisplayName            = "Hood";
            Ensure                 = 'Present'
            Floor                  = "3";
            FloorLabel             = "Third Floor";
            GeoCoordinates         = "47.644125;-122.132537";
            Identity               = "Hood@$TenantId";
            IsWheelChairAccessible = $True;
            Label                  = "Hood";
            MTREnabled             = $False;
            ParentType             = "None";
            Phone                  = "555-555-5555";
            PostalCode             = "98052";
            State                  = "WA";
            Street                 = "1 Microsoft Way";
            Tags                   = @("Tag1", "Tag2");
            VideoDeviceName        = "VideoDevice";
            ApplicationId          = $ApplicationId
            TenantId               = $TenantId
            CertificateThumbprint  = $CertificateThumbprint
        }
    }
}
