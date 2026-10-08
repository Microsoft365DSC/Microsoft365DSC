using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOSafeLinksRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the name of the SafeLink rule that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this rule should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The SafeLinksPolicy parameter specifies the name of the SafeLink policy that''s associated with the SafeLinksing rule.')]
    [System.String] $SafeLinksPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this rule should be enabled. Default is $true.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The Priority parameter specifies a priority value for the rule that determines the order of rule processing. A lower integer value indicates a higher priority, the value 0 is the highest priority, and rules can''t have the same priority value.')]
    [System.Nullable[System.UInt32]] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('The Comments parameter specifies informative comments for the rule, such as what the rule is used for or how it has changed over time. The length of the comment can''t exceed 1024 characters.')]
    [System.String] $Comments

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfRecipientDomainIs parameter specifies an exception that looks for recipients with email address in the specified domains. You can specify multiple domains separated by commas.')]
    [System.String[]] $ExceptIfRecipientDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSentTo parameter specifies an exception that looks for recipients in messages. You can use any value that uniquely identifies the recipient.')]
    [System.String[]] $ExceptIfSentTo

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSentToMemberOf parameter specifies an exception that looks for messages sent to members of groups. You can use any value that uniquely identifies the group.')]
    [System.String[]] $ExceptIfSentToMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientDomainIs parameter specifies a condition that looks for recipients with email address in the specified domains. You can specify multiple domains separated by commas.')]
    [System.String[]] $RecipientDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('The SentTo parameter specifies a condition that looks for recipients in messages. You can use any value that uniquely identifies the recipient.')]
    [System.String[]] $SentTo

    [DscProperty()]
    [System.ComponentModel.Description('The SentToMemberOf parameter looks for messages sent to members of groups. You can use any value that uniquely identifies the group.')]
    [System.String[]] $SentToMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
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

    [EXOSafeLinksRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOSafeLinksRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SafeLinksRule for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $SafeLinksRule = Get-SafeLinksRule -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $SafeLinksRule)
                {
                    Write-Verbose -Message "SafeLinksRule $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $SafeLinksRule = $this.ExportedInstance
            }

            $result = @{
                Identity                  = $SafeLinksRule.Identity
                SafeLinksPolicy           = $SafeLinksRule.SafeLinksPolicy
                Comments                  = $SafeLinksRule.Comments
                Enabled                   = $true
                ExceptIfRecipientDomainIs = $SafeLinksRule.ExceptIfRecipientDomainIs
                ExceptIfSentTo            = $SafeLinksRule.ExceptIfSentTo
                ExceptIfSentToMemberOf    = $SafeLinksRule.ExceptIfSentToMemberOf
                Priority                  = $SafeLinksRule.Priority
                RecipientDomainIs         = $SafeLinksRule.RecipientDomainIs
                SentTo                    = $SafeLinksRule.SentTo
                SentToMemberOf            = $SafeLinksRule.SentToMemberOf
                Credential                = $this.Credential
                Ensure                    = 'Present'
                ApplicationId             = $this.ApplicationId
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
                TenantId                  = $this.TenantId
                AccessTokens              = $this.AccessTokens
            }

            if ('Enabled' -eq $SafeLinksRule.State)
            {
                # Accounts for Get-SafeLinksRule returning 'State' instead of 'Enabled' used by New/Set
                $result.Enabled = $true
            }
            else
            {
                $result.Enabled = $false
            }

            return $this.AsResult($result)
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

        Write-Verbose -Message "Setting configuration of SafeLinksRule for $($this.Identity)"
        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $SafeLinksRule = Get-SafeLinksRule -Identity $this.Identity -ErrorAction SilentlyContinue
        $SafeLinksRuleParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ('Present' -eq $this.Ensure -and -not $SafeLinksRule)
        {
            $SafeLinksRuleParams.Add('Name', $SafeLinksRuleParams.Identity)
            $SafeLinksRuleParams.Remove('Identity') | Out-Null
            $SafeLinksRuleParams.Remove('MakeDefault') | Out-Null
            Write-Verbose -Message "Creating New SafeLinksRule $($SafeLinksRuleParams.Name)"
            New-SafeLinksRule @SafeLinksRuleParams -Confirm:$false
        }

        if ('Present' -eq $this.Ensure -and $SafeLinksRule)
        {
            $SafeLinksRuleParams.Remove('Enabled') | Out-Null
            if ($SafeLinksRuleParams.SafeLinksPolicy -eq $SafeLinksRule.SafeLinksPolicy)
            {
                $SafeLinksRuleParams.Remove('SafeLinksPolicy')
            }
            Write-Verbose -Message "Setting SafeLinksRule $($this.Identity)"
            Set-SafeLinksRule @SafeLinksRuleParams -Confirm:$false

            $currentEnabled = $SafeLinksRule.State -eq 'Enabled'
            if ($null -ne $this.Enabled -and $this.Enabled -ne $currentEnabled)
            {
                if ($this.Enabled)
                {
                    Enable-SafeLinksRule -Identity $this.Identity -Confirm:$false
                }
                else
                {
                    Disable-SafeLinksRule -Identity $this.Identity -Confirm:$false
                }
            }
        }

        if ('Absent' -eq $this.Ensure -and $SafeLinksRule)
        {
            Write-Verbose -Message "Removing SafeLinksRule $($this.Identity)"
            Remove-SafeLinksRule -Identity $this.Identity -Confirm:$false
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        $dscContent = [System.Text.StringBuilder]::new()

        try
        {
            if (Confirm-ImportedCmdletIsAvailable -CmdletName Get-SafeLinksRule)
            {
                [array]$SafeLinksRules = Get-SafeLinksRule -ErrorAction Stop

                if ($SafeLinksRules.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }
                $i = 1
                foreach ($SafeLinksRule in $SafeLinksRules)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "    |---[$i/$($SafeLinksRules.Length)] $($SafeLinksRule.Identity)" -DeferWrite
                    $Params = @{
                        Identity              = $SafeLinksRule.Identity
                        SafeLinksPolicy       = $SafeLinksRule.SafeLinksPolicy
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        CertificatePath       = $this.CertificatePath
                        AccessTokens          = $this.AccessTokens
                    }
                    $this.ExportedInstance = $SafeLinksRule
                    $Results = $this.GetForExport($Params)
                    $rawResults = $Results.Clone()
                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential `
                        -RawResults $rawResults
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    $i++
                }
            }
            else
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered to allow for Safe Links Rules."
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOSafeLinksRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOSafeLinksRule])
        {
            return $Values
        }

        $result = [EXOSafeLinksRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
