using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADPreserve : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [AADPreserve] Get()
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