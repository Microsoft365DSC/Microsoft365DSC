using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADZetaNoOverlap : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $Alpha

    [DscProperty()]
    [System.String] $Bravo

    [AADZetaNoOverlap] Get()
    {
        $this.Connect('MicrosoftGraph')
        $null = Invoke-MgGraphRequest -Method PATCH -Uri '/beta/directory/attributeSets/x'
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