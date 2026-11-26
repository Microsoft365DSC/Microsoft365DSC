using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsTeam : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [TeamsTeam] Get()
    {
        $this.Connect('MicrosoftTeams')
        $this.Connect('MicrosoftGraph')

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