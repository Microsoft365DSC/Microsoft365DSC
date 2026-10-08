using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceCompliancePolicyConflict : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [IntuneDeviceCompliancePolicyConflict] Get()
    {
        $this.Connect('MicrosoftGraph')
        $odataType = '#microsoft.graph.windows10CompliancePolicy'
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