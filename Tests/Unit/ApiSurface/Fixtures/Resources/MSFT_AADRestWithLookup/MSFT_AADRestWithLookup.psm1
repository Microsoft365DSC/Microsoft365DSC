using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADRestWithLookup : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [AADRestWithLookup] Get()
    {
        $this.Connect('MicrosoftGraph')
        $null = Invoke-MgGraphRequest -Method GET -Uri '/beta/employeeExperience/roles'
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