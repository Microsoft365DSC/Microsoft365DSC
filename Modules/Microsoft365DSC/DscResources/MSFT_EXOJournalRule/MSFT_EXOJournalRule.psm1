using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOJournalRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the Journal Rule')]
    [System.String] $Name

    [DscProperty(Key)]
    [System.ComponentModel.Description('The JournalEmailAddress parameter specifies a recipient object to which journal reports are sent. You can use any value that uniquely identifies the recipient.')]
    [System.String] $JournalEmailAddress

    [DscProperty()]
    [System.ComponentModel.Description('The Recipient parameter specifies the SMTP address of a mailbox, contact, or distribution group to journal. If you specify a distribution group, all recipients in that distribution group are journaled. All messages sent to or from a recipient are journaled.')]
    [System.String] $Recipient

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the Journal Rule is enabled or not.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The Scope parameter specifies the scope of email messages to which the journal rule is applied')]
    [ValidateSet('Global', 'Internal', 'External')]
    [System.String] $RuleScope

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the rule exists, Absent that it does not.')]
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

    [EXOJournalRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOJournalRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Journal Rule for {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $rule = Get-JournalRule -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $rule)
                {
                    Write-Verbose -Message "Can't find the existing journal rule {$($this.Name)}."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $rule = $this.ExportedInstance
            }

            Write-Verbose -Message "Found configuration of the Journal Rule {$($this.Name)}}"

            $result = @{
                Name                  = $this.Name
                JournalEmailAddress   = $rule.JournalEmailAddress
                Enabled               = $rule.Enabled
                Recipient             = $rule.Recipient
                RuleScope             = $rule.Scope
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                TenantId              = $this.TenantId
                AccessTokens          = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of Journal Rule {$($this.Name)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentValues = $this.Get().ToHashtable()

        $null = $this.Connect('ExchangeOnline')

        $opsParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $opsParams.Add('Scope', $this.RuleScope) | Out-Null
        $opsParams.Remove('RuleScope') | Out-Null

        # If the Rule should exist, but it doesn't - Create the Rule
        if ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Journal Rule {$($this.Name)} with Enabled set to {$($this.Enabled)}"
            New-JournalRule @opsParams | Out-Null
        }
        # If the Rule should exist and it already does - Update the Rule
        elseif ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating Journal Rule {$($this.Name)}"
            $opsParams.Add('Identity', $this.Name) | Out-Null
            $opsParams.Remove('Enabled') | Out-Null

            Set-JournalRule @opsParams | Out-Null

            if ($currentValues.Enabled -ne $this.Enabled)
            {
                Write-Verbose -Message "Setting the Enabled status of Rule {$($this.Name)} to {$($this.Enabled)}"

                if ($this.Enabled -eq $true)
                {
                    Enable-JournalRule -Identity $this.Name -Confirm:$false | Out-Null
                }
                else
                {
                    Disable-JournalRule -Identity $this.Name -Confirm:$false | Out-Null
                }
            }
        }
        # If the Rule exists and it should not - Delete the Rule
        elseif ($this.Ensure -eq 'Absent' -and $currentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Journal Rule {$($this.Name)}"
            Remove-JournalRule -Identity $this.Name -Confirm:$false | Out-Null
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
            [array]$allRules = Get-JournalRule

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($allRules.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($rule in $allRules)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($allRules.Length)] $($rule.Name)" -DeferWrite
                $Params = @{
                    Credential            = $this.Credential
                    Name                  = $Rule.name
                    JournalEmailAddress   = $Rule.JournalEmailAddress
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $rule
                $Results = $this.GetForExport($Params)
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
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

    hidden [EXOJournalRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOJournalRule])
        {
            return $Values
        }

        $result = [EXOJournalRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
