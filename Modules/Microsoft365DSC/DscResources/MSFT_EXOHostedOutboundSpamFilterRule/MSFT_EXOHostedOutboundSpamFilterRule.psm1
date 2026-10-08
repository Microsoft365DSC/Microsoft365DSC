using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOHostedOutboundSpamFilterRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the name of the HostedOutboundSpamFilter rule that you want to modify.')]
    [System.String] $Identity

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The HostedOutboundSpamFilterPolicy parameter specifies the name of the HostedOutboundSpamFilter policy that''s associated with the HostedOutboundSpamFilter rule.')]
    [System.String] $HostedOutboundSpamFilterPolicy

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
    [System.ComponentModel.Description('The ExceptIfSenderDomainIs parameter specifies an exception that looks for senders with email address in the specified domains. You can specify multiple domains separated by commas.')]
    [System.String[]] $ExceptIfSenderDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfFrom parameter specifies an exception that looks for messages from specific senders. You can use any value that uniquely identifies the sender.')]
    [System.String[]] $ExceptIfFrom

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfFromMemberOf parameter specifies an exception that looks for messages sent by group members. You can use any value that uniquely identifies the group.')]
    [System.String[]] $ExceptIfFromMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The SenderDomainIs parameter specifies a condition that looks for senders with email address in the specified domains. You can specify multiple domains separated by commas.')]
    [System.String[]] $SenderDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('The From parameter specifies a condition that looks for messages from specific senders. You can use any value that uniquely identifies the sender.')]
    [System.String[]] $From

    [DscProperty()]
    [System.ComponentModel.Description('The FromMemberOf parameter specifies a condition that looks for messages sent by group members. You can use any value that uniquely identifies the group.')]
    [System.String[]] $FromMemberOf

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

    [EXOHostedOutboundSpamFilterRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOHostedOutboundSpamFilterRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of HostedOutboundSpamFilterRule for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')
                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $HostedOutboundSpamFilterRule = Get-HostedOutboundSpamFilterRule -Identity $this.Identity -ErrorAction SilentlyContinue
                if (-not $HostedOutboundSpamFilterRule)
                {
                    Write-Verbose -Message "HostedOutboundSpamFilterRule $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $HostedOutboundSpamFilterRule = $this.ExportedInstance
            }

            Write-Verbose -Message "Found HostedOutboundSpamFilterRule $($this.Identity)"

            $result = @{
                Ensure                         = 'Present'
                Identity                       = $this.Identity
                HostedOutboundSpamFilterPolicy = $HostedOutboundSpamFilterRule.HostedOutboundSpamFilterPolicy
                Comments                       = $HostedOutboundSpamFilterRule.Comments
                Enabled                        = $false
                ExceptIfSenderDomainIs         = $HostedOutboundSpamFilterRule.ExceptIfSenderDomainIs
                ExceptIfFrom                   = $HostedOutboundSpamFilterRule.ExceptIfFrom
                ExceptIfFromMemberOf           = $HostedOutboundSpamFilterRule.ExceptIfFromMemberOf
                Priority                       = $HostedOutboundSpamFilterRule.Priority
                SenderDomainIs                 = $HostedOutboundSpamFilterRule.SenderDomainIs
                From                           = $HostedOutboundSpamFilterRule.From
                FromMemberOf                   = $HostedOutboundSpamFilterRule.FromMemberOf
                Credential                     = $this.Credential
                ApplicationId                  = $this.ApplicationId
                CertificateThumbprint          = $this.CertificateThumbprint
                CertificatePath                = $this.CertificatePath
                CertificatePassword            = $this.CertificatePassword
                ManagedIdentity                = $this.ManagedIdentity
                TenantId                       = $this.TenantId
                AccessTokens                   = $this.AccessTokens
            }

            if ('Enabled' -eq $HostedOutboundSpamFilterRule.State)
            {
                # Accounts for Get-HostedOutboundSpamFilterRule returning 'State' instead of 'Enabled' used by New/Set
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

        Write-Verbose -Message "Setting configuration of HostedOutboundSpamFilterRule for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()
        $boundParameters = ([System.Collections.Hashtable]$this.GetBoundParameters()).Clone()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $boundParameters

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            $createParameters = $boundParameters
            [EXOHostedOutboundSpamFilterRule]::WaitForHostedOutboundSpamFilterPolicy($this.Identity, $this.HostedOutboundSpamFilterPolicy)

            Write-Verbose -Message "Creating new HostedOutboundSpamFilterRule {$($this.Identity)}"
            $createParameters.Add('Name', $this.Identity)
            $createParameters.Remove('Identity') | Out-Null
            New-HostedOutboundSpamFilterRule @createParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
        {
            $updateParameters = $boundParameters
            $updateParameters.Remove('Enabled') | Out-Null

            [EXOHostedOutboundSpamFilterRule]::WaitForHostedOutboundSpamFilterPolicy($this.Identity, $this.HostedOutboundSpamFilterPolicy)

            if ($CurrentValues.HostedOutboundSpamFilterPolicy -eq $updateParameters.HostedOutboundSpamFilterPolicy)
            {
                $updateParameters.Remove('HostedOutboundSpamFilterPolicy') | Out-Null
            }
            Write-Verbose -Message "Updating HostedOutboundSpamFilterRule {$($this.Identity)}"
            Set-HostedOutboundSpamFilterRule @updateParameters
            if ($null -ne $this.Enabled -and $this.Enabled -ne $CurrentValues.Enabled)
            {
                if ($this.Enabled)
                {
                    Enable-HostedOutboundSpamFilterRule -Identity $this.Identity -Confirm:$false
                }
                else
                {
                    Disable-HostedOutboundSpamFilterRule -Identity $this.Identity -Confirm:$false
                }
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing existing HostedOutboundSpamFilterRule {$($this.Identity)}."
            Remove-HostedOutboundSpamFilterRule -Identity $this.Identity -Confirm:$false
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
            [array] $HostedOutboundSpamFilterRules = Get-HostedOutboundSpamFilterRule -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()

            $i = 1
            if ($HostedOutboundSpamFilterRules.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($HostedOutboundSpamFilterRule in $HostedOutboundSpamFilterRules)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($HostedOutboundSpamFilterRules.Count)] $($HostedOutboundSpamFilterRule.Identity)" -DeferWrite
                $Params = @{
                    Credential                     = $this.Credential
                    Identity                       = $HostedOutboundSpamFilterRule.Identity
                    HostedOutboundSpamFilterPolicy = $HostedOutboundSpamFilterRule.HostedOutboundSpamFilterPolicy
                    ApplicationId                  = $this.ApplicationId
                    TenantId                       = $this.TenantId
                    CertificateThumbprint          = $this.CertificateThumbprint
                    CertificatePassword            = $this.CertificatePassword
                    CertificatePath                = $this.CertificatePath
                    ManagedIdentity                = $this.ManagedIdentity
                    AccessTokens                   = $this.AccessTokens
                }
                $this.ExportedInstance = $HostedOutboundSpamFilterRule
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

    hidden static [void] WaitForHostedOutboundSpamFilterPolicy([System.String] $Identity, [System.String] $PolicyName)
    {
        $policyExists = Wait-M365DSCCondition -Description "HostedOutboundSpamFilterPolicy {$PolicyName}" -ConsecutiveCount 2 -ScriptBlock {
            $null -ne (Get-HostedOutboundSpamFilterPolicy -Identity $PolicyName -ErrorAction 'SilentlyContinue')
        }

        if (-not $policyExists)
        {
            throw "Error attempting to create EXOHostedOutboundSpamFilterRule {$Identity}. The specified HostedOutboundSpamFilterPolicy " + `
                "{$PolicyName} doesn't exist. Make sure you either create it first or specify a valid policy."
        }
    }

    hidden [EXOHostedOutboundSpamFilterRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOHostedOutboundSpamFilterRule])
        {
            return $Values
        }

        $result = [EXOHostedOutboundSpamFilterRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
