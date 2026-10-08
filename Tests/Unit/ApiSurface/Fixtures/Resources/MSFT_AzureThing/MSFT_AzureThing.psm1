using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AzureThing : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [AzureThing] Get()
    {
        $this.Connect('Azure')

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