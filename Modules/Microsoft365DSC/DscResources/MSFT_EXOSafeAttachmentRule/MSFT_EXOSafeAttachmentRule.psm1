using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOSafeAttachmentRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the name of the SafeAttachment rule that you want to modify.')]
    [System.String] $Identity

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The SafeAttachmentPolicy parameter specifies the name of the SafeAttachment policy that''s associated with the SafeAttachment rule.')]
    [System.String] $SafeAttachmentPolicy

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
    [System.ComponentModel.Description('Specify if this rule should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

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

    [EXOSafeAttachmentRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOSafeAttachmentRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SafeAttachmentRule for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $SafeAttachmentRule = Get-SafeAttachmentRule -Identity $this.Identity -ErrorAction SilentlyContinue
                if (-not $SafeAttachmentRule)
                {
                    Write-Verbose -Message "SafeAttachmentRule $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $SafeAttachmentRule = $this.ExportedInstance
            }

            Write-Verbose -Message "Found existing instance of SafeAttachmentRule $($this.Identity)"

            $result = @{
                Ensure                    = 'Present'
                Identity                  = $SafeAttachmentRule.Identity
                SafeAttachmentPolicy      = $SafeAttachmentRule.SafeAttachmentPolicy
                Comments                  = $SafeAttachmentRule.Comments
                Enabled                   = $true
                ExceptIfRecipientDomainIs = $SafeAttachmentRule.ExceptIfRecipientDomainIs
                ExceptIfSentTo            = $SafeAttachmentRule.ExceptIfSentTo
                ExceptIfSentToMemberOf    = $SafeAttachmentRule.ExceptIfSentToMemberOf
                Priority                  = $SafeAttachmentRule.Priority
                RecipientDomainIs         = $SafeAttachmentRule.RecipientDomainIs
                SentTo                    = $SafeAttachmentRule.SentTo
                SentToMemberOf            = $SafeAttachmentRule.SentToMemberOf
                Credential                = $this.Credential
                ApplicationId             = $this.ApplicationId
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
                TenantId                  = $this.TenantId
                AccessTokens              = $this.AccessTokens
            }
            if ('Enabled' -eq $SafeAttachmentRule.State)
            {
                # Accounts for Get-SafeAttachmentRule returning 'State' instead of 'Enabled' used by New/Set
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

        Write-Verbose -Message "Setting configuration of SafeAttachmentRule for $($this.Identity)"
        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $SafeAttachmentRules = Get-SafeAttachmentRule
        $SafeAttachmentRule = $SafeAttachmentRules | Where-Object -FilterScript { $_.Identity -eq $this.Identity }
        $SafeAttachmentRuleParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $null -eq $SafeAttachmentRule)
        {
            $SafeAttachmentRuleParams.Add('Name', $SafeAttachmentRuleParams.Identity)
            $SafeAttachmentRuleParams.Remove('Identity') | Out-Null
            $SafeAttachmentRuleParams.Remove('MakeDefault') | Out-Null
            New-SafeAttachmentRule @SafeAttachmentRuleParams -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Present' -and $null -ne $SafeAttachmentRule)
        {
            $SafeAttachmentRuleParams.Remove('Enabled') | Out-Null
            if ($SafeAttachmentRuleParams.SafeAttachmentPolicy -eq $SafeAttachmentRule.SafeAttachmentPolicy)
            {
                $SafeAttachmentRuleParams.Remove('SafeAttachmentPolicy')
            }
            Write-Verbose -Message "Setting SafeAttachmentRule $($this.Identity)"
            Set-SafeAttachmentRule @SafeAttachmentRuleParams -Confirm:$false

            $currentEnabled = $SafeAttachmentRule.State -eq 'Enabled'
            if ($null -ne $this.Enabled -and $this.Enabled -ne $currentEnabled)
            {
                if ($this.Enabled)
                {
                    Enable-SafeAttachmentRule -Identity $this.Identity -Confirm:$false
                }
                else
                {
                    Disable-SafeAttachmentRule -Identity $this.Identity -Confirm:$false
                }
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $null -ne $SafeAttachmentRule)
        {
            Write-Verbose -Message "Removing SafeAttachmentRule $($this.Identity)"
            Remove-SafeAttachmentRule -Identity $this.Identity -Confirm:$false
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
            if (Confirm-ImportedCmdletIsAvailable -CmdletName Get-SafeAttachmentRule)
            {
                [array]$SafeAttachmentRules = Get-SafeAttachmentRule
                $i = 1

                if ($SafeAttachmentRules.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }

                foreach ($SafeAttachmentRule in $SafeAttachmentRules)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "    |---[$i/$($SafeAttachmentRules.Length)] $($SafeAttachmentRule.Identity)" -DeferWrite
                    $Params = @{
                        Identity              = $SafeAttachmentRule.Identity
                        SafeAttachmentPolicy  = $SafeAttachmentRule.SafeAttachmentPolicy
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        CertificatePath       = $this.CertificatePath
                        AccessTokens          = $this.AccessTokens
                    }
                    $this.ExportedInstance = $SafeAttachmentRule
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
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant doesn't have access to the Safe Attachment Rule API."
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOSafeAttachmentRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOSafeAttachmentRule])
        {
            return $Values
        }

        $result = [EXOSafeAttachmentRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
