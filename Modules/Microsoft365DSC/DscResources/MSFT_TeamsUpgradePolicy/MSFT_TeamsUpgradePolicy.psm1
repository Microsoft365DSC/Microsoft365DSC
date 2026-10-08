using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsUpgradePolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identity of the Teams Upgrade Policy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('DEPRECATED. Use the TeamsUserPolicyAssignment resource instead.')]
    [System.String[]] $Users

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to move existing Skype for Business meetings organized by the user to Teams. This parameter can only be true if the mode of the specified policy instance is either TeamsOnly or SfBWithTeamsCollabAndMeetings, and if the policy instance is being granted to a specific user. It not possible to trigger meeting migration when granting TeamsUpgradePolicy to the entire tenant.')]
    [System.Nullable[System.Boolean]] $MigrateMeetingsToTeams

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Azure Active Directory application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    [TeamsUpgradePolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsUpgradePolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Teams Upgrade Policy $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity.Replace('Tag:', '') -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                Write-Verbose -Message 'Checking the Teams Upgrade Policies'

                $policy = Get-CsTeamsUpgradePolicy -Identity $this.Identity `
                    -ErrorAction SilentlyContinue

                if ($null -eq $policy)
                {
                    throw  "No Teams Upgrade Policy with Identity {$($this.Identity)} was found"
                }
            }
            else
            {
                $policy = $this.ExportedInstance
            }

            Write-Verbose -Message "Found Teams Upgrade Policy with Identity {$($this.Identity)}"
            return $this.AsResult(@{
                Identity               = $this.Identity
                #DEPRECATED
                #Users                  = $usersList
                MigrateMeetingsToTeams = $this.MigrateMeetingsToTeams
                Credential             = $this.Credential
                ApplicationId          = $this.ApplicationId
                TenantId               = $this.TenantId
                CertificateThumbprint  = $this.CertificateThumbprint
                CertificatePath        = $this.CertificatePath
                CertificatePassword    = $this.CertificatePassword
                ManagedIdentity        = $this.ManagedIdentity
                AccessTokens           = $this.AccessTokens
            })
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration for Teams Upgrade Policy $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')
        Write-Verbose -Message "Updating Teams Upgrade Policy {$($this.Identity)}"

        $null = $this.Connect('MicrosoftTeams')

        if ($this.Identity -eq 'Global' -and $this.Users.Length -eq 1 -and $this.Users[0] -eq '*')
        {
            Write-Verbose -Message "Granting TeamsUpgradePolicy {$($this.Identity)} to all Users with MigrateMeetingsToTeams=$($this.MigrateMeetingsToTeams)"
            Grant-CsTeamsUpgradePolicy -PolicyName $this.Identity `
                -MigrateMeetingsToTeams:$this.MigrateMeetingsToTeams `
                -Global
        }
        else
        {
            foreach ($user in $this.Users)
            {
                Write-Verbose -Message "Granting TeamsUpgradePolicy {$($this.Identity)} to User {$user} with MigrateMeetingsToTeams=$($this.MigrateMeetingsToTeams)"
                Grant-CsTeamsUpgradePolicy -PolicyName $this.Identity `
                    -Identity $user `
                    -MigrateMeetingsToTeams:$this.MigrateMeetingsToTeams
            }
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftTeams')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$policies = Get-CsTeamsUpgradePolicy -ErrorAction Stop
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($policy in $policies)
            {
                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.Identity.Replace('Tag:', ''))" -DeferWrite
                $params = @{
                    Identity              = $policy.Identity.Replace('Tag:', '')
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport($Params)
                if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName

                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
                }

                $i++
            }

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [TeamsUpgradePolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsUpgradePolicy])
        {
            return $Values
        }

        $result = [TeamsUpgradePolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
