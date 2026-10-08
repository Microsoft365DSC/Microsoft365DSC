using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOMailboxAutoReplyConfiguration : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the mailbox that you want to modify. You can use any value that uniquely identifies the mailbox.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('User Principal Name of the mailbox owner')]
    [System.String] $Owner

    [DscProperty()]
    [System.ComponentModel.Description('The AutoDeclineFutureRequestsWhenOOF parameter specifies whether to automatically decline new meeting requests that are sent to the mailbox during the scheduled time period when Automatic Replies are being sent. ')]
    [System.Nullable[System.Boolean]] $AutoDeclineFutureRequestsWhenOOF

    [DscProperty()]
    [System.ComponentModel.Description('The AutoReplyState parameter specifies whether the mailbox is enabled for Automatic Replies. Valid values are: Enabled, Disabled, Scheduled')]
    [ValidateSet('Enabled', 'Disabled', 'Scheduled')]
    [System.String] $AutoReplyState

    [DscProperty()]
    [System.ComponentModel.Description('The CreateOOFEvent parameter specifies whether to create a calendar event that corresponds to the scheduled time period when Automatic Replies are being sent for the mailbox.')]
    [System.Nullable[System.Boolean]] $CreateOOFEvent

    [DscProperty()]
    [System.ComponentModel.Description('The DeclineAllEventsForScheduledOOF parameter specifies whether to decline all existing calendar events in the mailbox during the scheduled time period when Automatic Replies are being sent.')]
    [System.Nullable[System.Boolean]] $DeclineAllEventsForScheduledOOF

    [DscProperty()]
    [System.ComponentModel.Description('The DeclineEventsForScheduledOOF parameter specifies whether it''s possible to decline existing calendar events in the mailbox during the scheduled time period when Automatic Replies are being sent. ')]
    [System.Nullable[System.Boolean]] $DeclineEventsForScheduledOOF

    [DscProperty()]
    [System.ComponentModel.Description('The DeclineMeetingMessage parameter specifies the text in the message when meetings requests that are sent to the mailbox are automatically declined.')]
    [System.String] $DeclineMeetingMessage

    [DscProperty()]
    [System.ComponentModel.Description('The EndTime parameter specifies the end date and time that Automatic Replies are sent for the mailbox. You use this parameter only when the AutoReplyState parameter is set to Scheduled, and the value of this parameter is meaningful only when AutoReplyState is Scheduled.')]
    [System.String] $EndTime

    [DscProperty()]
    [System.ComponentModel.Description('The EventsToDeleteIDs parameter specifies the calendar events to delete from the mailbox when the DeclineEventsForScheduledOOF parameter is set to $true.')]
    [System.String[]] $EventsToDeleteIDs

    [DscProperty()]
    [System.ComponentModel.Description('The ExternalAudience parameter specifies whether Automatic Replies are sent to external senders. Valid values are: None, Known, All')]
    [ValidateSet('None', 'Known', 'All')]
    [System.String] $ExternalAudience

    [DscProperty()]
    [System.ComponentModel.Description('The ExternalMessage parameter specifies the Automatic Replies message that''s sent to external senders or senders outside the organization. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $ExternalMessage

    [DscProperty()]
    [System.ComponentModel.Description('The InternalMessage parameter specifies the Automatic Replies message that''s sent to internal senders or senders within the organization. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $InternalMessage

    [DscProperty()]
    [System.ComponentModel.Description('The OOFEventSubject parameter specifies the subject for the calendar event that''s automatically created when the CreateOOFEvent parameter is set to $true.')]
    [System.String] $OOFEventSubject

    [DscProperty()]
    [System.ComponentModel.Description('The StartTime parameter specifies the start date and time that Automatic Replies are sent for the specified mailbox. You use this parameter only when the AutoReplyState parameter is set to Scheduled, and the value of this parameter is meaningful only when AutoReplyState is Scheduled.')]
    [System.String] $StartTime

    [DscProperty()]
    [System.ComponentModel.Description('Represents the existence of the instance. This resource cannot be removed and the value must be set to ''Ensure''.')]
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

    [EXOMailboxAutoReplyConfiguration] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOMailboxAutoReplyConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Mailbox AutoReply Configuration for $($this.Identity)"

        try
        {
            $null = $this.Connect('ExchangeOnline')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullReturn = $this.GetBoundParameters()
            $nullReturn.Ensure = 'Absent'

            $config = Get-MailboxAutoReplyConfiguration -Identity $this.Identity -ErrorAction SilentlyContinue
            if ($null -eq $config)
            {
                Write-Verbose -Message "Mailbox for $($this.Identity) does not exist."
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found Mailbox $($this.Identity)"

            $userPrincipalName = $this.Identity
            if ($userPrincipalName -notlike '*@*')
            {
                $userPrincipalName = (Get-User -Identity $this.Identity).UserPrincipalName
            }

            # Exchange returns a rolling StartTime and EndTime when the state is not Scheduled
            $startTimeValue = $null
            $endTimeValue = $null
            if ($config.AutoReplyState -eq 'Scheduled')
            {
                if ($null -ne $config.StartTime)
                {
                    $startTimeValue = ([System.DateTime]$config.StartTime).ToString('yyyy-MM-ddTHH:mm:ss', [System.Globalization.CultureInfo]::InvariantCulture)
                }

                if ($null -ne $config.EndTime)
                {
                    $endTimeValue = ([System.DateTime]$config.EndTime).ToString('yyyy-MM-ddTHH:mm:ss', [System.Globalization.CultureInfo]::InvariantCulture)
                }
            }

            $result = @{
                Identity                         = $userPrincipalName
                Owner                            = $userPrincipalName
                AutoDeclineFutureRequestsWhenOOF = [Boolean]$config.AutoDeclineFutureRequestsWhenOOF
                AutoReplyState                   = $config.AutoReplyState
                CreateOOFEvent                   = [Boolean]$config.CreateOOFEvent
                DeclineAllEventsForScheduledOOF  = [Boolean]$config.DeclineAllEventsForScheduledOOF
                DeclineEventsForScheduledOOF     = [Boolean]$config.DeclineEventsForScheduledOOF
                DeclineMeetingMessage            = $config.DeclineMeetingMessage
                EndTime                          = $endTimeValue
                EventsToDeleteIDs                = [System.String[]]$config.EventsToDeleteIDs
                ExternalAudience                 = $config.ExternalAudience
                ExternalMessage                  = $config.ExternalMessage
                InternalMessage                  = $config.InternalMessage
                OOFEventSubject                  = $config.OOFEventSubject
                StartTime                        = $startTimeValue
                Credential                       = $this.Credential
                Ensure                           = 'Present'
                ApplicationId                    = $this.ApplicationId
                CertificateThumbprint            = $this.CertificateThumbprint
                CertificatePath                  = $this.CertificatePath
                CertificatePassword              = $this.CertificatePassword
                ManagedIdentity                  = $this.ManagedIdentity
                TenantId                         = $this.TenantId
                AccessTokens                     = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of AntiPhishPolicy for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $updateParameters.Remove('Owner') | Out-Null

        Set-MailboxAutoReplyConfiguration @updateParameters
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
            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1

            if ($mailboxes.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($mailbox in $mailboxes)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($mailboxes.Length)] $($mailbox.UserPrincipalName)" -DeferWrite

                $Params = @{
                    Identity              = $mailbox.UserPrincipalName
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
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

    hidden [EXOMailboxAutoReplyConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOMailboxAutoReplyConfiguration])
        {
            return $Values
        }

        $result = [EXOMailboxAutoReplyConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
