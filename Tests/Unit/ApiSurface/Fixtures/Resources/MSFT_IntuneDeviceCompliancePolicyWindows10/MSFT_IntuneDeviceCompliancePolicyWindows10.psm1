using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceCompliancePolicyWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [DscProperty()]
    [System.String] $Assignments

    [DscProperty()]
    [System.String] $BitLockerEnabled

    [IntuneDeviceCompliancePolicyWindows10] Get()
    {
        $this.Connect('MicrosoftGraph')
        $odataType = '#microsoft.graph.windows10CompliancePolicy'
        $odataType = '#microsoft.graph.deviceCompliancePolicyAssignment'
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