using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOHostedContentFilterRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the name of the HostedContentFilter rule that you want to modify.')]
    [System.String] $Identity

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The HostedContentFilterPolicy parameter specifies the name of the HostedContentFilter policy that''s associated with the HostedContentFilter rule.')]
    [System.String] $HostedContentFilterPolicy

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

    [EXOHostedContentFilterRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOHostedContentFilterRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of HostedContentFilterRule for [$($this.Identity)]"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')
                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $HostedContentFilterRule = Get-HostedContentFilterRule -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $HostedContentFilterRule)
                {
                    Write-Verbose -Message "Couldn't find rule by ID, trying by name."
                    $rules = Get-HostedContentFilterRule
                    $HostedContentFilterRule = $rules | Where-Object -FilterScript { $_.Name -eq $this.Identity -and $_.HostedContentFilterPolicy -eq $this.HostedContentFilterPolicy }
                }

                if ($null -eq $HostedContentFilterRule)
                {
                    Write-Verbose -Message "HostedContentFilterRule $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $HostedContentFilterRule = $this.ExportedInstance
            }

            Write-Verbose -Message "Found HostedContentFilterRule $($this.Identity)"

            $result = @{
                Ensure                    = 'Present'
                Identity                  = $this.Identity
                HostedContentFilterPolicy = $HostedContentFilterRule.HostedContentFilterPolicy
                Comments                  = $HostedContentFilterRule.Comments
                Enabled                   = $false
                ExceptIfRecipientDomainIs = $HostedContentFilterRule.ExceptIfRecipientDomainIs
                ExceptIfSentTo            = $HostedContentFilterRule.ExceptIfSentTo
                ExceptIfSentToMemberOf    = $HostedContentFilterRule.ExceptIfSentToMemberOf
                Priority                  = $HostedContentFilterRule.Priority
                RecipientDomainIs         = $HostedContentFilterRule.RecipientDomainIs
                SentTo                    = $HostedContentFilterRule.SentTo
                SentToMemberOf            = $HostedContentFilterRule.SentToMemberOf
                Credential                = $this.Credential
                ApplicationId             = $this.ApplicationId
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
                TenantId                  = $this.TenantId
                AccessTokens              = $this.AccessTokens
            }

            if ('Enabled' -eq $HostedContentFilterRule.State)
            {
                # Accounts for Get-HostedContentFilterRule returning 'State' instead of 'Enabled' used by New/Set
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

        Write-Verbose -Message "Setting configuration of HostedContentFilterRule for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()
        $boundParameters = ([System.Collections.Hashtable]$this.GetBoundParameters()).Clone()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            $createParameters = $boundParameters
            # Make sure that the associated Policy exists;
            $AssociatedPolicy = Get-HostedContentFilterPolicy -Identity $this.HostedContentFilterPolicy -ErrorAction 'SilentlyContinue'
            if ($null -eq $AssociatedPolicy)
            {
                throw "Error attempting to create EXOHostedContentFilterRule {$($this.Identity)}. The specified HostedContentFilterPolicy " + `
                    "{$($this.HostedContentFilterPolicy)} doesn't exist. Make sure you either create it first or specify a valid policy."
            }

            # Make sure that the associated Policy is not Default;
            if ($AssociatedPolicy.IsDefault -eq $true )
            {
                throw "Policy $($this.Identity) is marked as the default. Creating a rule to apply the default policy is not allowed."
            }

            Write-Verbose -Message "Creating new HostedContentFilterRule {$($this.Identity)}"
            Write-Verbose -Message "With Parameters: $(Convert-M365DscHashtableToString -Hashtable $createParameters)"
            $createParameters.Add('Name', $this.Identity)
            $createParameters.Remove('Identity') | Out-Null
            New-HostedContentFilterRule @createParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
        {
            $updateParameters = $boundParameters
            # Make sure that the associated Policy exists;
            $AssociatedPolicy = Get-HostedContentFilterPolicy -Identity $this.HostedContentFilterPolicy -ErrorAction 'SilentlyContinue'
            if ($null -eq $AssociatedPolicy)
            {
                throw "Error attempting to create EXOHostedContentFilterRule {$($this.Identity)}. The specified HostedContentFilterPolicy " + `
                    "{$($this.HostedContentFilterPolicy)} doesn't exist. Make sure you either create it first or specify a valid policy."
            }

            # Make sure that the associated Policy is not Default;
            if ($AssociatedPolicy.IsDefault -eq $true )
            {
                throw "Policy $($this.Identity) is marked as the default. Creating a rule to apply the default policy is not allowed."
            }

            $updateParameters.Remove('Enabled') | Out-Null
            if ($CurrentValues.HostedContentFilterPolicy -eq $updateParameters.HostedContentFilterPolicy)
            {
                $updateParameters.Remove('HostedContentFilterPolicy') | Out-Null
            }
            Write-Verbose -Message "Updating HostedContentFilterRule {$($this.Identity)}"
            Set-HostedContentFilterRule @updateParameters
            if ($null -ne $this.Enabled -and $this.Enabled -ne $CurrentValues.Enabled)
            {
                if ($this.Enabled)
                {
                    Enable-HostedContentFilterRule -Identity $this.Identity -Confirm:$false
                }
                else
                {
                    Disable-HostedContentFilterRule -Identity $this.Identity -Confirm:$false
                }
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing existing HostedContentFilterRule {$($this.Identity)}."
            Remove-HostedContentFilterRule -Identity $this.Identity -Confirm:$false
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        $ConnectionMode = $this.Connect('ExchangeOnline')

        try
        {
            [array] $HostedContentFilterRules = Get-HostedContentFilterRule -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()

            $i = 1
            if ($HostedContentFilterRules.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($HostedContentFilterRule in $HostedContentFilterRules)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($HostedContentFilterRules.Count)] $($HostedContentFilterRule.Identity)" -DeferWrite
                $Params = @{
                    Credential                = $this.Credential
                    Identity                  = $HostedContentFilterRule.Identity
                    HostedContentFilterPolicy = $HostedContentFilterRule.HostedContentFilterPolicy
                    ApplicationId             = $this.ApplicationId
                    TenantId                  = $this.TenantId
                    CertificateThumbprint     = $this.CertificateThumbprint
                    CertificatePassword       = $this.CertificatePassword
                    CertificatePath           = $this.CertificatePath
                    ManagedIdentity           = $this.ManagedIdentity
                    AccessTokens              = $this.AccessTokens
                }
                $this.ExportedInstance = $HostedContentFilterRule
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
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOHostedContentFilterRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOHostedContentFilterRule])
        {
            return $Values
        }

        $result = [EXOHostedContentFilterRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
