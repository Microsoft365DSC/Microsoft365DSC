using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCLabelPolicy : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [SCLabelPolicy] Get()
    {
        $this.Connect('SecurityComplianceCenter')

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