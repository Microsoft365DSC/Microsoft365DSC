[DscResource()]
class TestApplyAmbiguous
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The mode of the policy.')]
    [ValidateSet('alpha')]
    [System.String] $Mode

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [TestApplyAmbiguous] Get()
    {
        $getValue = $null
        $enumMode = $null

        if ($null -eq $getValue)
        {
            return $this.AsResult(@{
                    DisplayName = $getValue.displayName
                    Ensure      = 'Absent'
                    Credential  = $this.Credential
                })
        }

        return $this.AsResult(@{
                DisplayName = $getValue.displayName
                Mode        = $enumMode
                Ensure      = 'Present'
                Credential  = $this.Credential
            })
    }

    [void] Set()
    {
    }

    [System.Boolean] Test()
    {
        return $true
    }

    hidden [TestApplyAmbiguous] AsResult([System.Object] $Values)
    {
        return $null
    }
}
