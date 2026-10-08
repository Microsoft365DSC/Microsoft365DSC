using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADZetaSettings : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $MaxAttributesPerSet

    [DscProperty()]
    [System.String] $IsCustom

    [AADZetaSettings] Get()
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