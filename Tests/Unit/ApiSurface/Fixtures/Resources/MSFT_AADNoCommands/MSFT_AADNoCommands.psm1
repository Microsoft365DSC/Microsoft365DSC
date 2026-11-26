using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADNoCommands : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [AADNoCommands] Get()
    {
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