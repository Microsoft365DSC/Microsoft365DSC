<#
This examples create a new Teams Meeting Broadcast Policy.
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
        TeamsMeetingBroadcastPolicy 'TeamsMeetingBroadcastPolicy-Example'
        {
            Identity                        = "Town Hall Broadcasts"
            AllowBroadcastScheduling        = $True
            AllowBroadcastTranscription     = $True # Updated Property
            BroadcastAttendeeVisibilityMode = "EveryoneInCompany"
            BroadcastRecordingMode          = "AlwaysEnabled"
            Ensure                          = "Present"
            ApplicationId                   = $ApplicationId
            TenantId                        = $TenantId
            CertificateThumbprint           = $CertificateThumbprint
        }
    }
}
