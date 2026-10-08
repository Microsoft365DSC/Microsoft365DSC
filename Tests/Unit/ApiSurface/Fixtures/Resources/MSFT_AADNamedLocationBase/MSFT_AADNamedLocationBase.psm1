using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADNamedLocationBase : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [AADNamedLocationBase] Get()
    {
        $this.Connect('MicrosoftGraph')
        $odataType = '#microsoft.graph.namedLocation'
        $filter = "isof('microsoft.graph.ipNamedLocation')"
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