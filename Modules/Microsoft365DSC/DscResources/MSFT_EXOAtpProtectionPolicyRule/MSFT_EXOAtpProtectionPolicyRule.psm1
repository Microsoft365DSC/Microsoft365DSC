using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOAtpProtectionPolicyRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identifier for the rule')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the rule is enabled')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('Informative comments for the rule, such as what the rule is used for or how it has changed over time. The length of the comment can''t exceed 1024 characters.')]
    [System.String] $Comments

    [DscProperty()]
    [System.ComponentModel.Description('Specifies an exception that looks for recipients with email addresses in the specified domains.')]
    [System.String[]] $ExceptIfRecipientDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('Specifies an exception that looks for recipients in messages. You can use any value that uniquely identifies the recipient')]
    [System.String[]] $ExceptIfSentTo

    [DscProperty()]
    [System.ComponentModel.Description('Specifies an exception that looks for messages sent to members of groups. You can use any value that uniquely identifies the group.')]
    [System.String[]] $ExceptIfSentToMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('Unique name for the rule. The maximum length is 64 characters.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a priority value for the rule that determines the order of rule processing. A lower integer value indicates a higher priority, the value 0 is the highest priority, and rules can''t have the same priority value.')]
    [System.Nullable[System.UInt32]] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a condition that looks for recipients with email addresses in the specified domains.')]
    [System.String[]] $RecipientDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the existing Safe Attachments policy that''s associated with the preset security policy.')]
    [System.String] $SafeAttachmentPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the existing Safe Links policy that''s associated with the preset security policy.')]
    [System.String] $SafeLinksPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a condition that looks for recipients in messages. You can use any value that uniquely identifies the recipient.')]
    [System.String[]] $SentTo

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a condition that looks for messages sent to members of distribution groups, dynamic distribution groups, or mail-enabled security groups. ')]
    [System.String[]] $SentToMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the workload''s Admin')]
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

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [EXOAtpProtectionPolicyRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOAtpProtectionPolicyRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for ATP Protection Policy Rule with Identity $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-ATPProtectionPolicyRule -Identity $this.Identity -ErrorAction SilentlyContinue

                if ($null -eq $instance)
                {
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "Found ATP Protection Policy Rule with Identity $($instance.Identity)"

            $results = @{
                Identity                  = $instance.Identity
                Ensure                    = 'Present'
                Comments                  = $instance.Comments
                Enabled                   = $instance.State -eq 'Enabled'
                ExceptIfRecipientDomainIs = $instance.ExceptIfRecipientDomainIs
                ExceptIfSentTo            = $instance.ExceptIfSentTo
                ExceptIfSentToMemberOf    = $instance.ExceptIfSentToMemberOf
                Name                      = $instance.Name
                Priority                  = $instance.Priority
                RecipientDomainIs         = $instance.RecipientDomainIs
                SafeAttachmentPolicy      = $instance.SafeAttachmentPolicy
                SafeLinksPolicy           = $instance.SafeLinksPolicy
                SentTo                    = $instance.SentTo
                SentToMemberOf            = $instance.SentToMemberOf
                Credential                = $this.Credential
                ApplicationId             = $this.ApplicationId
                TenantId                  = $this.TenantId
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
                AccessTokens              = $this.AccessTokens
            }
            return $this.AsResult($results)
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

        Write-Verbose -Message "Setting configuration for ATP Protection Policy Rule with Identity $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $SetParameters.Remove('Identity') | Out-Null
            New-ATPProtectionPolicyRule @SetParameters
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            if ($SetParameters.ContainsKey('SafeAttachmentPolicy') -and $currentInstance.SafeAttachmentPolicy -ne $SetParameters.SafeAttachmentPolicy)
            {
                throw 'SafeAttachmentPolicy cannot be changed after creation'
            }
            if ($SetParameters.ContainsKey('SafeLinksPolicy') -and $currentInstance.SafeLinksPolicy -ne $SetParameters.SafeLinksPolicy)
            {
                throw 'SafeLinksPolicy cannot be changed after creation'
            }

            if ($null -ne $this.Enabled -and $currentInstance.Enabled -ne $this.Enabled)
            {
                Write-Verbose -Message "Changing Enabled state of the ATPProtectionPolicyRule $($currentInstance.Identity) from $($currentInstance.Enabled) to $($setParameters.Enabled)"
                if ($setParameters.Enabled)
                {
                    Enable-ATPProtectionPolicyRule -Identity $currentInstance.Identity -Confirm:$false
                }
                else
                {
                    Disable-ATPProtectionPolicyRule -Identity $currentInstance.Identity -Confirm:$false
                }
            }

            $SetParameters.Remove('SafeLinksPolicy') | Out-Null
            $SetParameters.Remove('SafeAttachmentPolicy') | Out-Null
            $SetParameters.Remove('Enabled') | Out-Null

            Set-ATPProtectionPolicyRule @SetParameters
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Remove-ATPProtectionPolicyRule -Identity $currentInstance.Identity -Confirm:$false
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

        ##TODO - Replace workload
        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$rules = Get-ATPProtectionPolicyRule -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($rules.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $rules)
            {
                $displayedKey = $config.Identity
                Write-M365DSCHost -Message "    |---[$i/$($rules.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Identity              = $config.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $config
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
                $i++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOAtpProtectionPolicyRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOAtpProtectionPolicyRule])
        {
            return $Values
        }

        $result = [EXOAtpProtectionPolicyRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
