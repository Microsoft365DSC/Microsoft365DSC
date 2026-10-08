using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOMailboxCalendarFolder : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the calendar folder that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The DetailLevel parameter specifies the level of calendar detail that''s published and available to anonymous users.')]
    [ValidateSet('AvailabilityOnly', 'LimitedDetails', 'FullDetails')]
    [System.String] $DetailLevel

    [DscProperty()]
    [System.ComponentModel.Description('The PublishDateRangeFrom parameter specifies the start date of calendar information to publish (past information).')]
    [ValidateSet('OneDay', 'ThreeDays', 'OneWeek', 'OneMonth', 'ThreeMonths', 'SixMonths', 'OneYear')]
    [System.String] $PublishDateRangeFrom

    [DscProperty()]
    [System.ComponentModel.Description('The PublishDateRangeTo parameter specifies the end date of calendar information to publish (future information).')]
    [ValidateSet('OneDay', 'ThreeDays', 'OneWeek', 'OneMonth', 'ThreeMonths', 'SixMonths', 'OneYear')]
    [System.String] $PublishDateRangeTo

    [DscProperty()]
    [System.ComponentModel.Description('The PublishEnabled parameter specifies whether to publish the specified calendar information.')]
    [System.Nullable[System.Boolean]] $PublishEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SearchableUrlEnabled parameter specifies whether the published calendar URL is discoverable on the web.')]
    [System.Nullable[System.Boolean]] $SearchableUrlEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SharedCalendarSyncStartDate parameter specifies the limit for past events in the shared calendar that are visible to delegates. A copy of the shared calendar within the specified date range is stored in the delegate''s mailbox.')]
    [System.String] $SharedCalendarSyncStartDate

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether or not the instance exist. This resource cannot be removed and the value must be set to ''Ensure''.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

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

    [EXOMailboxCalendarFolder] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOMailboxCalendarFolder]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Mailbox Calendar Folder with Identity {$($this.Identity)}"

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

            $IdentityParts = $this.Identity.Split(':')
            $userInfo = @{
                UserPrincipalName = $IdentityParts[0]
            }
            if ($IdentityParts[0] -notlike '*@*')
            {
                $userInfo = Get-User -Identity $IdentityParts[0]
            }
            $IdentityValue = $userInfo.UserPrincipalName + ':' + $IdentityParts[1]
            $folder = Get-MailboxCalendarFolder -Identity $this.Identity -ErrorAction SilentlyContinue

            if ($null -eq $folder)
            {
                return $this.AsResult($nullReturn)
            }

            $result = @{
                Identity                    = $IdentityValue
                DetailLevel                 = $folder.DetailLevel
                PublishDateRangeFrom        = $folder.PublishDateRangeFrom
                PublishDateRangeTo          = $folder.PublishDateRangeTo
                PublishEnabled              = [Boolean]$folder.PublishEnabled
                SearchableUrlEnabled        = [Boolean]$folder.SearchableUrlEnabled
                SharedCalendarSyncStartDate = $folder.SharedCalendarSyncStartDate
                Ensure                      = 'Present'
                Credential                  = $this.Credential
                ApplicationId               = $this.ApplicationId
                CertificateThumbprint       = $this.CertificateThumbprint
                CertificatePath             = $this.CertificatePath
                CertificatePassword         = $this.CertificatePassword
                ManagedIdentity             = $this.ManagedIdentity
                TenantId                    = $this.TenantId
                AccessTokens                = $this.AccessTokens
            }

            Write-Verbose -Message "Found Calendar Folder for {$($this.Identity)}"
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

        Write-Verbose -Message "Setting configuration of Calendar Folder for {$($this.Identity)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Get().ToHashtable()
        $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # The SharedCalendarSyncStartDate needs to be used by itself in a subsequent call.
        if ($this.GetBoundParameters().ContainsKey('SharedCalendarSyncStartDate'))
        {
            Write-Verbose -Message "Updating the Mailbox Calendar Folder SharedCalendarSyncStartDate property for {$($this.Identity)}"
            Set-MailboxCalendarFolder -Identity $this.Identity -SharedCalendarSyncStartDate $this.SharedCalendarSyncStartDate
            $updateParameters.Remove('SharedCalendarSyncStartDate') | Out-Null
        }
        Write-Verbose -Message "Updating the Mailbox Calendar Folder for {$($this.Identity)}"
        Set-MailboxCalendarFolder @updateParameters
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
            $dscContent = [System.Text.StringBuilder]::new()
            [array]$mailboxes = Get-M365DSCExportCachedCollection -Collection 'exoMailboxes'

            if ($null -eq $mailboxes)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                return ''
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            $i = 1
            foreach ($mailbox in $mailboxes)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                # Name of calendar folder depends on the language of the mailbox
                $calendarFolderName = (Get-MailboxFolderStatistics -Identity $($mailbox.UserPrincipalName) -FolderScope Calendar | Where-Object { $_.FolderType -eq 'Calendar' }).Name
                $folderPath = $mailbox.UserPrincipalName + ':\' + $calendarFolderName
                Write-M365DSCHost -Message "    |---[$i/$($mailboxes.Count)] $($folderPath)" -DeferWrite
                $Params = @{
                    Identity              = $folderPath
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
                if ($Results.SharedCalendarSyncStartDate -eq '01/02/0001 00:00:00')
                {
                    $Results.Remove('SharedCalendarSyncStartDate') | Out-Null
                }

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

    hidden [EXOMailboxCalendarFolder] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOMailboxCalendarFolder])
        {
            return $Values
        }

        $result = [EXOMailboxCalendarFolder]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
