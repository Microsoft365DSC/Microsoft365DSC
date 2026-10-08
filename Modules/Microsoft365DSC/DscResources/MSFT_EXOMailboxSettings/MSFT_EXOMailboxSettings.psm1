using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOMailboxSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the Shared Mailbox')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Associated retention policy.')]
    [System.String] $RetentionPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Associated address book policy.')]
    [System.String] $AddressBookPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Associated role assignment policy.')]
    [System.String] $RoleAssignmentPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Associated sharing policy.')]
    [System.String] $SharingPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The name of the Time Zone to assign to the mailbox')]
    [System.String] $TimeZone

    [DscProperty()]
    [System.ComponentModel.Description('The code of the Locale to assign to the mailbox')]
    [System.String] $Locale

    [DscProperty()]
    [System.ComponentModel.Description('The AuditEnabled parameter specifies whether to enable or disable mailbox audit logging for the mailbox. If auditing is enabled, actions specified in the AuditAdmin, AuditDelegate, and AuditOwner parameters are logged')]
    [System.Nullable[System.Boolean]] $AuditEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the Mailbox Settings are applied')]
    [ValidateSet('Present')]
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

    [EXOMailboxSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOMailboxSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Office 365 Mailbox Settings for $($this.DisplayName)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.UserPrincipalName -ne $this.DisplayName)
            {
                Write-Verbose -Message 'No cached instance found, retrieving from service.'
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = @{
                    DisplayName = $this.DisplayName
                }

                $mailboxInfo = Get-Mailbox -Identity $this.DisplayName -ErrorAction SilentlyContinue
            }
            else
            {
                $nullReturn = @{
                    DisplayName = $this.DisplayName
                }
                $mailboxInfo = $this.ExportedInstance
            }

            Write-Verbose -Message "Found an existing instance of Mailbox '$($this.DisplayName)'"

            $mailboxSettings = Get-MailboxRegionalConfiguration -Identity $this.DisplayName -ErrorAction SilentlyContinue
            if ($null -eq $mailboxSettings -or $null -eq $mailboxInfo)
            {
                Write-Verbose -Message "The specified Mailbox doesn't already exist."
                return $this.AsResult($nullReturn)
            }

            $result = @{
                DisplayName           = $this.DisplayName
                TimeZone              = $mailboxSettings.TimeZone
                Locale                = $mailboxSettings.Language.Name
                RetentionPolicy       = $mailboxInfo.RetentionPolicy
                AddressBookPolicy     = $mailboxInfo.AddressBookPolicy
                RoleAssignmentPolicy  = $mailboxInfo.RoleAssignmentPolicy
                SharingPolicy         = $mailboxInfo.SharingPolicy
                AuditEnabled          = $mailboxInfo.AuditEnabled
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

        Write-Verbose -Message "Setting configuration of Office 365 Mailbox Settings for $($this.DisplayName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')
        $null = $this.Connect('ExchangeOnline')

        Set-MailboxRegionalConfiguration -Identity $this.DisplayName `
            -Language $this.Locale `
            -TimeZone $this.TimeZone

        $needToUpdate = $false
        $updateParams = @{
            Identity = $this.DisplayName
        }
        if (-not [System.String]::IsNullOrEmpty($this.AddressBookPolicy))
        {
            $needToUpdate = $true
            $updateParams.Add('AddressBookPolicy', $this.AddressBookPolicy)
        }
        if (-not [System.String]::IsNullOrEmpty($this.RoleAssignmentPolicy))
        {
            $needToUpdate = $true
            $updateParams.Add('RoleAssignmentPolicy', $this.RoleAssignmentPolicy)
        }
        if (-not [System.String]::IsNullOrEmpty($this.RetentionPolicy))
        {
            $needToUpdate = $true
            $updateParams.Add('RetentionPolicy', $this.RetentionPolicy)
        }
        if (-not [System.String]::IsNullOrEmpty($this.SharingPolicy))
        {
            $needToUpdate = $true
            $updateParams.Add('SharingPolicy', $this.SharingPolicy)
        }
        if ($needToUpdate)
        {
            Write-Verbose -Message "Updating Mailbox specific properties with:`r`n$(Convert-M365DscHashtableToString -Hashtable $updateParams)"
            Set-Mailbox @updateParams
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
            [array]$mailboxes = Get-M365DSCExportCachedCollection -Collection 'exoMailboxes'

            $i = 1
            if ($mailboxes.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n"-DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            foreach ($mailbox in $mailboxes)
            {
                $DisplayNameValue = $mailbox.Name
                if ([System.Guid]::TryParse($mailbox.Identity, [ref][System.Guid]::Empty))
                {
                    try
                    {
                        $user = Get-User -Identity $mailbox.Identity
                        $DisplayNameValue = $user.UserPrincipalName
                    }
                    catch
                    {
                        Write-Verbose -Message "Could not retrieve user with id {$($mailbox.Identity)}"
                    }
                }
                Write-M365DSCHost -Message "    |---[$i/$($mailboxes.Length)] $($DisplayNameValue)" -DeferWrite

                if (-not [System.String]::IsNullOrEmpty($DisplayNameValue))
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    $Params = @{
                        Credential            = $this.Credential
                        DisplayName           = $DisplayNameValue
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
                    $rawResults = $Results.Clone()
                    if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
                    {
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
                    }
                    else
                    {
                        Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
                    }
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

    hidden [EXOMailboxSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOMailboxSettings])
        {
            return $Values
        }

        $result = [EXOMailboxSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
