<#
This example adds a new Teams Channels Policy.
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
        TeamsUserCallingSettings 'TeamsUserCallingSettings-Example'
        {
            BusyOnBusyOption          = "RedirectAsUnansweredCall";
            CallGroupOrder            = "Simultaneous";
            CallGroupTargets          = @("megan.bowen@contoso.com", "alex.wilber@contoso.com");
            Ensure                    = "Present";
            ForwardingTarget          = "alex.wilber@contoso.com";
            ForwardingTargetType      = "SingleTarget";
            ForwardingType            = "Simultaneous";
            GroupNotificationOverride = "Ring";
            Identity                  = "John.Smith@contoso.com";
            IsForwardingEnabled       = $true;
            IsUnansweredEnabled       = $true;
            MaximumConcurrentCalls    = 2;
            UnansweredDelay           = "00:00:20";
            UnansweredTarget          = "megan.bowen@contoso.com";
            UnansweredTargetType      = "SingleTarget";
            ApplicationId             = $ApplicationId;
            TenantId                  = $TenantId;
            CertificateThumbprint     = $CertificateThumbprint;
        }
    }
}
