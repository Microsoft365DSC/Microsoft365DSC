using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOSharedMailbox : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the Shared Mailbox')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the Shared Mailbox')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The primary email address of the Shared Mailbox')]
    [System.String] $PrimarySMTPAddress

    [DscProperty()]
    [System.ComponentModel.Description('The alias of the Shared Mailbox')]
    [System.String] $Alias

    [DscProperty()]
    [System.ComponentModel.Description('The EmailAddresses parameter specifies all the email addresses (proxy addresses) for the Shared Mailbox')]
    [System.String[]] $EmailAddresses

    [DscProperty()]
    [System.ComponentModel.Description('The AuditEnabled parameter specifies whether to enable or disable mailbox audit logging for the mailbox. If auditing is enabled, actions specified in the AuditAdmin, AuditDelegate, and AuditOwner parameters are logged')]
    [System.Nullable[System.Boolean]] $AuditEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The MessageCopyForSendOnBehalfEnabled parameter specifies whether to copy the sender for messages that are sent from a mailbox by users that have the ''send on behalf of'' permission')]
    [System.Nullable[System.Boolean]] $MessageCopyForSendOnBehalfEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The MessageCopyForSentAsEnabled parameter specifies whether to copy the sender for messages that are sent from a mailbox by users that have the ''send as'' permission')]
    [System.Nullable[System.Boolean]] $MessageCopyForSentAsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the group exists, absent ensures it is removed')]
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

    [EXOSharedMailbox] Get()
    {
        $mailbox = $null
        $Id = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOSharedMailbox]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Office 365 Shared Mailbox $($this.DisplayName)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                try
                {
                    if (-not [System.String]::IsNullOrEmpty($this.Identity))
                    {
                        $mailbox = Get-Mailbox -Identity $this.Identity `
                            -RecipientTypeDetails 'SharedMailbox' `
                            -ResultSize Unlimited `
                            -ErrorAction SilentlyContinue
                    }

                    if ($null -eq $mailbox)
                    {
                        $mailbox = Get-Mailbox -Identity $this.DisplayName `
                            -RecipientTypeDetails 'SharedMailbox' `
                            -ResultSize Unlimited `
                            -ErrorAction SilentlyContinue
                    }
                }
                catch
                {
                    Write-Verbose -Message "Could not retrieve AAD roledefinition by Id: {$Id}"
                }

                if ($null -eq $mailbox)
                {
                    Write-Verbose -Message "The specified Shared Mailbox doesn't already exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $mailbox = $this.ExportedInstance
            }

            #region EmailAddresses
            $CurrentEmailAddresses = $mailbox.EmailAddresses | Foreach-Object { $_.Split(':') } | Where-Object { $_ -ne 'smtp' }
            if (-not [System.String]::IsNullOrEmpty($this.PrimarySMTPAddress))
            {
                $CurrentEmailAddresses = $CurrentEmailAddresses | Where-Object { $_ -ne $this.PrimarySMTPAddress }
            }
            else
            {
                $CurrentEmailAddresses = $CurrentEmailAddresses | Where-Object { $_ -ne $mailbox.PrimarySMTPAddress }
            }
            #endregion

            $result = @{
                DisplayName                       = $this.DisplayName
                Identity                          = $mailbox.Identity
                PrimarySMTPAddress                = $mailbox.PrimarySMTPAddress.ToString()
                Alias                             = $mailbox.Alias
                AuditEnabled                      = $mailbox.AuditEnabled
                EmailAddresses                    = Get-M365DSCArrayFromProperty -PropertyValue $CurrentEmailAddresses -ElementType ([System.String])
                MessageCopyForSendOnBehalfEnabled = $mailbox.MessageCopyForSendOnBehalfEnabled
                MessageCopyForSentAsEnabled       = $mailbox.MessageCopyForSentAsEnabled
                Ensure                            = 'Present'
                Credential                        = $this.Credential
                ApplicationId                     = $this.ApplicationId
                CertificateThumbprint             = $this.CertificateThumbprint
                CertificatePath                   = $this.CertificatePath
                CertificatePassword               = $this.CertificatePassword
                ManagedIdentity                   = $this.ManagedIdentity
                TenantId                          = $this.TenantId
                AccessTokens                      = $this.AccessTokens
            }

            Write-Verbose -Message "Found an existing instance of Shared Mailbox '$($this.DisplayName)'"
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

        Write-Verbose -Message "Setting configuration of Office 365 Shared Mailbox $($this.DisplayName)"
        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentMailbox = $this.Get().ToHashtable()

        #region Validation
        foreach ($secondaryAlias in $this.EmailAddresses)
        {
            if (-not [System.String]::IsNullOrEmpty($this.PrimarySMTPAddress) -and $secondaryAlias.ToLower() -eq $this.PrimarySMTPAddress.ToLower())
            {
                throw 'You cannot have the EmailAddresses list contain the PrimarySMTPAddress'
            }
        }
        #endregion

        # CASE: Mailbox doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentMailbox.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Shared Mailbox '$($this.DisplayName)' does not exist but it should. Creating it."

            $NewMailBoxParameters = @{
                Name               = $this.DisplayName
                Shared             = $true
            }

            if ($this.GetBoundParameters().ContainsKey("Alias"))
            {
                $NewMailBoxParameters.Add('Alias', $this.Alias)
            }

            if ($this.GetBoundParameters().ContainsKey("PrimarySMTPAddress"))
            {
                $NewMailBoxParameters.Add('PrimarySMTPAddress', $this.PrimarySMTPAddress)
            }

            New-MailBox @NewMailBoxParameters

            if ($this.GetBoundParameters().ContainsKey("AuditEnabled") -or $this.GetBoundParameters().ContainsKey("EmailAddresses") -or $this.GetBoundParameters().ContainsKey("MessageCopyForSendOnBehalfEnabled") -or $this.GetBoundParameters().ContainsKey("MessageCopyForSentAsEnabled"))
            {
                $SetParameters = @{
                    Identity = $this.DisplayName
                }

                if ($this.GetBoundParameters().ContainsKey("AuditEnabled"))
                {
                    $SetParameters.Add("AuditEnabled", $this.AuditEnabled)
                }

                if ($this.GetBoundParameters().ContainsKey("EmailAddresses"))
                {
                    $SetParameters.Add("EmailAddresses", @{ add = $this.EmailAddresses })
                }

                if ($this.GetBoundParameters().ContainsKey("MessageCopyForSendOnBehalfEnabled"))
                {
                    $SetParameters.Add("MessageCopyForSendOnBehalfEnabled", $this.MessageCopyForSendOnBehalfEnabled)
                }

                if ($this.GetBoundParameters().ContainsKey("MessageCopyForSentAsEnabled"))
                {
                    $SetParameters.Add("MessageCopyForSentAsEnabled", $this.MessageCopyForSentAsEnabled)
                }

                Set-Mailbox @SetParameters
            }
        }
        # CASE: Mailbox exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentMailbox.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Shared Mailbox '$($this.DisplayName)' exists but it shouldn't. Deleting it."
            Remove-Mailbox -Identity $this.DisplayName -Confirm:$false
        }
        # CASE: Mailbox exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentMailbox.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Shared Mailbox '$($this.DisplayName)' already exists, but needs updating."

            if ($this.GetBoundParameters().ContainsKey("PrimarySMTPAddress"))
            {
                if ($currentMailbox.PrimarySMTPAddress -ne $this.PrimarySMTPAddress)
                {
                    Write-Verbose -Message "Updating PrimarySMTPAddress for the Shared Mailbox '$($this.DisplayName)' from $($currentMailbox.PrimarySMTPAddress) to $($this.PrimarySMTPAddress)"
                    Set-Mailbox -Identity $this.DisplayName -WindowsEmailAddress $this.PrimarySMTPAddress -MicrosoftOnlineServicesID $this.PrimarySMTPAddress
                }
            }

            $SetParameters = @{
                Identity = $this.DisplayName
            }

            if ($this.GetBoundParameters().ContainsKey("Alias"))
            {
                if ($currentMailbox.Alias -ne $this.Alias)
                {
                    Write-Verbose -Message "Updating Alias for the Shared Mailbox '$($this.DisplayName)' from $($currentMailbox.Alias) to $($this.Alias)"
                    $SetParameters.Add("Alias", $this.Alias)
                }
            }

            if ($this.GetBoundParameters().ContainsKey("AuditEnabled"))
            {
                if ($this.AuditEnabled -ne $currentMailbox.AuditEnabled)
                {
                    Write-Verbose -Message "AuditEnabled for Shared Mailbox '$($this.DisplayName)' needs to be updated from $($currentMailbox.AuditEnabled) to $($this.AuditEnabled)"
                    $SetParameters.Add("AuditEnabled", $this.AuditEnabled)
                }
            }

            # CASE: EmailAddresses need to be updated
            if ($this.GetBoundParameters().ContainsKey("EmailAddresses"))
            {
                $current = $currentMailbox.EmailAddresses
                $desired = $this.EmailAddresses

                $emailAddressesToAdd = $desired | Where-Object { $_ -notin $current } | Sort-Object -Unique
                if ($null -ne $this.PrimarySMTPAddress)
                {
                    $emailAddressesToAdd = $emailAddressesToAdd | Where-Object { $_ -ne $this.PrimarySMTPAddress }
                }
                else
                {
                    $emailAddressesToAdd = $emailAddressesToAdd | Where-Object { $_ -ne $currentMailbox.PrimarySMTPAddress }
                }

                $emailAddressesToRemove = $current | Where-Object { $_ -notin $desired } | Sort-Object -Unique
                if ($null -ne $this.PrimarySMTPAddress)
                {
                    $emailAddressesToRemove = $emailAddressesToRemove | Where-Object { $_ -ne $this.PrimarySMTPAddress }
                }
                else
                {
                    $emailAddressesToRemove = $emailAddressesToRemove | Where-Object { $_ -ne $currentMailbox.PrimarySMTPAddress }
                }

                if ($null -ne $emailAddressesToAdd -or $null -ne $emailAddressesToRemove)
                {
                    $SetParameters.Add("EmailAddresses", @{})

                    # Add EmailAddresses
                    Write-Verbose -Message "Updating the list of EmailAddresses for the Shared Mailbox '$($this.DisplayName)'"
                    if ($null -ne $emailAddressesToAdd)
                    {
                        Write-Verbose -Message "Adding the following EmailAddresses: $($emailAddressesToAdd | Out-String)"
                        $SetParameters.EmailAddresses.Add("add", $emailAddressesToAdd)
                    }
                    # Remove EmailAddresses
                    if ($null -ne $emailAddressesToRemove)
                    {
                        Write-Verbose -Message "Removing the following EmailAddresses: $($emailAddressesToRemove | Out-String)"
                        $SetParameters.EmailAddresses.Add("remove", $emailAddressesToRemove)
                    }
                }
            }

            if ($this.GetBoundParameters().ContainsKey("MessageCopyForSendOnBehalfEnabled"))
            {
                if ($currentMailbox.MessageCopyForSendOnBehalfEnabled -ne $this.MessageCopyForSendOnBehalfEnabled)
                {
                    Write-Verbose -Message "Updating MessageCopyForSendOnBehalfEnabled for the Shared Mailbox '$($this.DisplayName)' from $($currentMailbox.MessageCopyForSendOnBehalfEnabled) to $($this.MessageCopyForSendOnBehalfEnabled)"
                    $SetParameters.Add("MessageCopyForSendOnBehalfEnabled", $this.MessageCopyForSendOnBehalfEnabled)
                }
            }

            if ($this.GetBoundParameters().ContainsKey("MessageCopyForSentAsEnabled"))
            {
                if ($currentMailbox.MessageCopyForSentAsEnabled -ne $this.MessageCopyForSentAsEnabled)
                {
                    Write-Verbose -Message "Updating MessageCopyForSentAsEnabled for the Shared Mailbox '$($this.DisplayName)' from $($currentMailbox.MessageCopyForSentAsEnabled) to $($this.MessageCopyForSentAsEnabled)"
                    $SetParameters.Add("MessageCopyForSentAsEnabled", $this.MessageCopyForSentAsEnabled)
                }
            }

            Set-Mailbox @SetParameters
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
            [array] $exportedInstances = Get-Mailbox -RecipientTypeDetails 'SharedMailbox' `
                -ResultSize Unlimited `
                -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($mailbox in $exportedInstances)
            {
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Length)] $($mailbox.Name)" -DeferWrite
                $mailboxName = $mailbox.Name
                if ($mailboxName)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    $params = @{
                        Identity              = $mailbox.Identity
                        Credential            = $this.Credential
                        DisplayName           = $mailboxName
                        Alias                 = $mailbox.Alias
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        CertificatePath       = $this.CertificatePath
                        AccessTokens          = $this.AccessTokens
                    }
                    $this.ExportedInstance = $mailbox
                    $Results = $this.GetForExport($Params)
                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                }
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            IncludedProperties = @('DisplayName')
        }
    }

    hidden [EXOSharedMailbox] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOSharedMailbox])
        {
            return $Values
        }

        $result = [EXOSharedMailbox]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
