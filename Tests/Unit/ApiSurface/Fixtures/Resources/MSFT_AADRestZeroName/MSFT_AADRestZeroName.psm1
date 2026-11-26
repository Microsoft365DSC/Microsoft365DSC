using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADRestZeroName : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [AADRestZeroName] Get()
    {
        $this.Connect('MicrosoftGraph')
        $null = Invoke-MgGraphRequest -Method GET -Uri '/beta/admin/settings'
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