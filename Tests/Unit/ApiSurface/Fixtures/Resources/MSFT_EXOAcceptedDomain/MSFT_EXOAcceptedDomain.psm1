using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOAcceptedDomain : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Identity

    [DscProperty()]
    [System.String] $DomainType

    [EXOAcceptedDomain] Get()
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