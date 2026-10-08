using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceCompliancePolicyNegated : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [IntuneDeviceCompliancePolicyNegated] Get()
    {
        $this.Connect('MicrosoftGraph')
        $filter = "isof('microsoft.graph.windows10CompliancePolicy') and not isof('microsoft.graph.iosCompliancePolicy')"
        # TODO: check whether microsoft.graph.iosCompliancePolicy belongs here
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