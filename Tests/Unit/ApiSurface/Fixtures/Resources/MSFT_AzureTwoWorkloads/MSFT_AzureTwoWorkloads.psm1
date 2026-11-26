using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AzureTwoWorkloads : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [AzureTwoWorkloads] Get()
    {
        $this.Connect('Azure')
        $this.Connect('AdminAPI')

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