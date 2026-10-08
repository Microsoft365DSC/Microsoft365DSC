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
        SCCaseHoldPolicy 'SCCaseHoldPolicy-Example'
        {
            Case                  = 'Contoso Litigation 2026'
            ExchangeLocation      = @("AdeleV@$TenantId", "MeganB@$TenantId")
            Name                  = 'Litigation Hold 2026'
            Comment               = 'Preserves content for the pending litigation'
            Enabled               = $True
            Ensure                = 'Present'
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
