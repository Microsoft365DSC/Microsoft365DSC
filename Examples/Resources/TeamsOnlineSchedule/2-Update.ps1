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
        TeamsOnlineSchedule 'TeamsOnlineSchedule-Example'
        {
            Name                  = "Contoso Business Hours"
            Type                  = "WeeklyRecurrence"
            MondayHours           = @(
                MSFT_TeamsOnlineScheduleTimeRange{
                    Start = "09:00"
                    End   = "17:00"
                }
            )
            TuesdayHours          = @(
                MSFT_TeamsOnlineScheduleTimeRange{
                    Start = "09:00"
                    End   = "17:00"
                }
            )
            WednesdayHours        = @(
                MSFT_TeamsOnlineScheduleTimeRange{
                    Start = "09:00"
                    End   = "17:00"
                }
            )
            ThursdayHours         = @(
                MSFT_TeamsOnlineScheduleTimeRange{
                    Start = "09:00"
                    End   = "17:00"
                }
            )
            FridayHours           = @(
                MSFT_TeamsOnlineScheduleTimeRange{
                    Start = "08:00" # Updated Property
                    End   = "16:00" # Updated Property
                }
            )
            Complement            = $false
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
