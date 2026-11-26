<#
This example updates an existing Microsoft Entra Private Access application, assigning it to a
different connector group.
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
        AADGSAPrivateAccessApplication 'AADGSAPrivateAccessApplication-Example'
        {
            DisplayName               = "Finance File Server"
            ApplicationType           = "nonwebapp"
            IsAccessibleViaZTNAClient = $true
            ConnectorGroupName        = "Corporate Datacenter Connectors" # Updated Property
            IsDnsResolutionEnabled    = $false
            Segments                  = @(
                MSFT_AADGSAPrivateAccessApplicationSegment{
                    DestinationHost = "fileserver.finance.contoso.local"
                    DestinationType = "fqdn"
                    Ports           = @("445-445", "3389-3389")
                    Protocol        = "tcp"
                }
            )
            Ensure                    = "Present"
            ApplicationId             = $ApplicationId
            TenantId                  = $TenantId
            CertificateThumbprint     = $CertificateThumbprint
        }
    }
}
