using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAttributeSet : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $Description

    [DscProperty()]
    [System.String] $MaxAttributesPerSet

    [AADAttributeSet] Get()
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