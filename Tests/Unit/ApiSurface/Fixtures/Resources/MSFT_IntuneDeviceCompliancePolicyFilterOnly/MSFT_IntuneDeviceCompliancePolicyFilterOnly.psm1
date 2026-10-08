using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceCompliancePolicyFilterOnly : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [IntuneDeviceCompliancePolicyFilterOnly] Get()
    {
        $this.Connect('MicrosoftGraph')
        $filter = "isof('microsoft.graph.iosCompliancePolicy')"
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