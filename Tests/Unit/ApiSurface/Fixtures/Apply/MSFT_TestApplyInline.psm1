[DscResource()]
class TestApplyInline
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The severity.')]
    [ValidateSet('Critical', 'Warning')]
    [System.String] $Severity

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [TestApplyInline] Get()
    {
        $getValue = $null
        $enumSeverity = $null

        return $this.AsResult(@{
                DisplayName = $getValue.displayName
                Severity    = $enumSeverity
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

    hidden [TestApplyInline] AsResult([System.Object] $Values)
    {
        return $null
    }
}
