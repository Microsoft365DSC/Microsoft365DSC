using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceCompliancePolicyAmbiguous : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [IntuneDeviceCompliancePolicyAmbiguous] Get()
    {
        $this.Connect('MicrosoftGraph')
        $odataType = '#microsoft.graph.windows10CompliancePolicy'
        $odataType = '#microsoft.graph.iosCompliancePolicy'
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