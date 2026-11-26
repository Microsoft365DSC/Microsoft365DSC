using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsMeetingPolicy : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Identity

    [DscProperty()]
    [System.String] $AllowChat

    [TeamsMeetingPolicy] Get()
    {
        $this.Connect('MicrosoftTeams')

        return $this
    }

    [void] Set()
    {
    }

    [bool] Test()
    {
        return $true
    }

    [string] Export()
    {
        return ''
    }
}