[DscResource()]
class TestApplyBasic
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The mode of the policy.')]
    [ValidateSet('alpha', 'beta')]
    [System.String] $Mode

    [DscProperty()]
    [System.ComponentModel.Description('A plain flag.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [TestApplyBasic] Get()
    {
        $getValue = $null
        $enumMode = $null
        $nullResult = @{ DisplayName = $this.DisplayName; Ensure = 'Absent' }

        if ($null -eq $getValue)
        {
            return $this.AsResult($nullResult)
        }

        $result = @{
            DisplayName  = $getValue.displayName
            Mode         = $enumMode
            Enabled      = $getValue.enabled
            Ensure       = 'Present'
            Credential   = $this.Credential
            AccessTokens = $this.AccessTokens
        }

        return $this.AsResult($result)
    }

    [void] Set()
    {
    }

    [System.Boolean] Test()
    {
        return $true
    }

    hidden [TestApplyBasic] AsResult([System.Object] $Values)
    {
        return $null
    }
}
