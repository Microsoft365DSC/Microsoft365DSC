using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOWrongModule : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [EXOWrongModule] Get()
    {
        $this.Connect('ExchangeOnline')

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