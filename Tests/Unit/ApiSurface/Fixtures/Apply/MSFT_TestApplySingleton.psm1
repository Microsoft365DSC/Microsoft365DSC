[DscResource()]
class TestApplySingleton
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only one instance is allowed.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The tier.')]
    [ValidateSet('basic')]
    [System.String] $Tier

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [TestApplySingleton] Get()
    {
        $settings = $null
        $policySettings = @{
            IsSingleInstance = 'Yes'
            Tier             = $settings.tier
            Credential       = $this.Credential
        }

        return $this.AsResult($policySettings)
    }

    [void] Set()
    {
    }

    [System.Boolean] Test()
    {
        return $true
    }

    hidden [TestApplySingleton] AsResult([System.Object] $Values)
    {
        return $null
    }
}
