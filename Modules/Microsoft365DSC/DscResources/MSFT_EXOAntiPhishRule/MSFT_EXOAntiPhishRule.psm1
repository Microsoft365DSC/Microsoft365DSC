using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOAntiPhishRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the name of the antiphishing rule that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this rule should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The AntiPhishPolicy parameter specifies the name of the antiphishing policy that''s associated with the antiphishing rule.')]
    [System.String] $AntiPhishPolicy

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

    [EXOAntiPhishRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOAntiPhishRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AntiPhishRule for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $AntiPhishRule = Get-AntiPhishRule -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $AntiPhishRule)
                {
                    Write-Verbose -Message "AntiPhishRule $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $AntiPhishRule = $this.ExportedInstance
            }

            Write-Verbose -Message "Found AntiPhishRule $($this.Identity)"
            $result = @{
                Identity                  = $this.Identity
                AntiPhishPolicy           = $AntiPhishRule.AntiPhishPolicy
                Comments                  = $AntiPhishRule.Comments
                Enabled                   = $AntiPhishRule.RuleEnabled
                ExceptIfRecipientDomainIs = $AntiPhishRule.ExceptIfRecipientDomainIs
                ExceptIfSentTo            = $AntiPhishRule.ExceptIfSentTo
                ExceptIfSentToMemberOf    = $AntiPhishRule.ExceptIfSentToMemberOf
                Priority                  = $AntiPhishRule.Priority
                RecipientDomainIs         = $AntiPhishRule.RecipientDomainIs
                SentTo                    = $AntiPhishRule.SentTo
                SentToMemberOf            = $AntiPhishRule.SentToMemberOf
                Ensure                    = 'Present'
                Credential                = $this.Credential
                ApplicationId             = $this.ApplicationId
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
                TenantId                  = $this.TenantId
                AccessTokens              = $this.AccessTokens
            }

            if ('Enabled' -eq $AntiPhishRule.State)
            {
                # Accounts for Get-AntiPhishRule returning 'State' instead of 'Enabled' used by New/Set
                $result.Enabled = $true
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

        Write-Verbose -Message "Setting configuration of AntiPhishRule for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $CurrentValues = $this.Get().ToHashtable()
        $boundParameters = ([System.Collections.Hashtable]$this.GetBoundParameters()).Clone()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            $createParameters = $boundParameters
            $createParameters.Add('Name', $this.Identity) | Out-Null
            $createParameters.Remove('Identity') | Out-Null

            [EXOAntiPhishRule]::WaitForAntiPhishPolicy($this.Identity, $this.AntiPhishPolicy)

            Write-Verbose -Message "Creating AntiPhishRule {$($this.Identity)}"
            New-AntiPhishRule @createParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
        {
            $updateParameters = $boundParameters
            $updateParameters.Remove('Enabled') | Out-Null

            [EXOAntiPhishRule]::WaitForAntiPhishPolicy($this.Identity, $this.AntiPhishPolicy)

            # Check to see if the specified policy already has the rule assigned;
            $existingRule = Get-AntiPhishRule | Where-Object -FilterScript { $_.AntiPhishPolicy -eq $this.AntiPhishPolicy }

            if ($null -ne $existingRule)
            {
                # The rule is already assigned to the policy, do try to update the AntiPhishPolicy parameter;
                $updateParameters.Remove('AntiPhishPolicy') | Out-Null
            }

            Write-Verbose -Message "Updating AntiPhishRule {$($this.Identity)}."
            Set-AntiPhishRule @updateParameters

            if ($null -ne $this.Enabled -and $this.Enabled -ne $CurrentValues.Enabled)
            {
                if ($this.Enabled)
                {
                    Enable-AntiPhishRule -Identity $this.Identity -Confirm:$false
                }
                else
                {
                    Disable-AntiPhishRule -Identity $this.Identity -Confirm:$false
                }
            }
        }
        if ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing AntiPhishRule [$($this.Identity)]"
            Remove-AntiPhishRule -Identity $this.Identity -Confirm:$false
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

        try
        {
            $AntiPhishRules = Get-AntiphishRule -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            if ($AntiPhishRules.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($Rule in $AntiPhishRules)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AntiPhishRules.Length)] $($Rule.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $Rule.Identity
                    AntiPhishPolicy       = $Rule.AntiPhishPolicy
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $Rule
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

    hidden static [void] WaitForAntiPhishPolicy([System.String] $Identity, [System.String] $PolicyName)
    {
        $policyExists = Wait-M365DSCCondition -Description "AntiPhishPolicy {$PolicyName}" -ConsecutiveCount 2 -ScriptBlock {
            $null -ne (Get-AntiPhishPolicy -Identity $PolicyName -ErrorAction 'SilentlyContinue')
        }

        if (-not $policyExists)
        {
            throw "Error attempting to create EXOAntiPhishRule {$Identity}. The specified AntiPhishPolicy {$PolicyName} " + `
                "doesn't exist. Make sure you either create it first or specify a valid policy."
        }
    }

    hidden [EXOAntiPhishRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOAntiPhishRule])
        {
            return $Values
        }

        $result = [EXOAntiPhishRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
