using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADConditionalAccessPolicy : M365DSCResourceBase
{
    [DscProperty()]
    [System.String] $Id

    [DscProperty()]
    [System.String] $DisplayName

    [DscProperty()]
    [System.String] $State

    [AADConditionalAccessPolicy] Get()
    {
        $this.Connect('MicrosoftGraph')
        $odataType = '#microsoft.graph.conditionalAccessAllExternalTenants'
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