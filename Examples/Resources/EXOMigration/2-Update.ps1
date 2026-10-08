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
        EXOMigration "EXOMigration-Example"
        {
            AddUsers              = $True; # Updated Property
            CompleteAfter         = "12/31/9999 11:59:59 PM";
            Ensure                = "Present";
            Identity              = "Mailbox Batch 1";
            MigrationUsers        = @("AdeleV@$TenantId", "AlexW@$TenantId");
            MoveOptions           = @();
            NotificationEmails    = @("MeganB@$TenantId");
            SkipMerging           = @();
            Status                = "Completed";
            Update                = $False;
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
