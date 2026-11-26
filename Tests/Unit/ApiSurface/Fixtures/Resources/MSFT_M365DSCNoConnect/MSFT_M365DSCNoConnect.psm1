using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class M365DSCNoConnect : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [M365DSCNoConnect] Get()
    {


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