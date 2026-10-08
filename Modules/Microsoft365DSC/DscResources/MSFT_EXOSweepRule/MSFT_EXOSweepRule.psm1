using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOSweepRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the name of the Sweep rule. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The Provider parameter specifies the provider for the Sweep rule. If the value contains spaces, enclose the value in quotation marks. For Sweep rules that you create in Outlook on the web, the default value is Exchange16.')]
    [System.String] $Provider

    [DscProperty()]
    [System.ComponentModel.Description('The DestinationFolder parameter specifies an action for the Sweep rule that moves messages to the specified folder.')]
    [System.String] $DestinationFolder

    [DscProperty()]
    [System.ComponentModel.Description('The Enabled parameter specifies whether the Sweep rule is enabled or disabled.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The KeepForDays parameter specifies an action for the Sweep rule that specifies the number of days to keep messages that match the conditions of the rule. After the number of days have passed, the messages are moved to the location that''s specified by the DestinationFolder parameter (by default, the Deleted Items folder). You can''t use this parameter with the KeepLatest parameter and the Sweep rule must contain a KeepForDays or KeepLatest parameter value.')]
    [System.Nullable[System.UInt32]] $KeepForDays

    [DscProperty()]
    [System.ComponentModel.Description('The KeepLatest parameter specifies an action for the Sweep rule that specifies the number of messages to keep that match the conditions of the rule. After the number of messages is exceeded, the oldest messages are moved to the location that''s specified by the DestinationFolder parameter (by default, the Deleted Items folder). You can''t use this parameter with the KeepForDays parameter and the Sweep rule must contain a KeepForDays or KeepLatest parameter value.')]
    [System.Nullable[System.UInt32]] $KeepLatest

    [DscProperty(Key)]
    [System.ComponentModel.Description('The Mailbox parameter specifies the mailbox where you want to create the Sweep rule. You can use any value that uniquely identifies the mailbox.')]
    [System.String] $Mailbox

    [DscProperty()]
    [System.ComponentModel.Description('The SenderName parameter specifies a condition for the Sweep rule that looks for the specified sender in messages. For internal senders, you can use any value that uniquely identifies the sender.')]
    [System.String] $SenderName

    [DscProperty()]
    [System.ComponentModel.Description('The SourceFolder parameter specifies a condition for the Sweep rule that looks for messages in the specified folder.')]
    [System.String] $SourceFolder

    [DscProperty()]
    [System.ComponentModel.Description('The SystemCategory parameter specifies a condition for the sweep rule that looks for messages with the specified system category. System categories are available to all mailboxes in the organization.')]
    [System.String] $SystemCategory

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this rule should exist or not.')]
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

    [EXOSweepRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOSweepRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Sweep Rule with Name {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-SweepRule -Mailbox $this.Mailbox -ErrorAction SilentlyContinue |
                    Where-Object -Property Name -EQ $this.Name |
                    Select-Object -First 1
                if ($null -eq $instance)
                {
                    Write-Verbose -Message "No Sweep Rule found with Name {$($this.Name)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "An EXO Sweep Rule with Name {$($instance.Name)} was found."

            $userInfo = Get-User -Identity $instance.MailboxOwnerId

            $senderNameValue = $null
            if (-not [System.String]::IsNullOrEmpty($instance.Sender))
            {
                $senderNameValue = $instance.Sender.Split('"')[1]
            }

            $results = @{
                Name                  = $instance.Name
                Provider              = $instance.Provider
                DestinationFolder     = $userInfo.UserPrincipalName + ':\' + $instance.DestinationFolder
                Enabled               = [Boolean]$instance.Enabled
                KeepForDays           = $instance.KeepForDays
                KeepLatest            = $instance.KeepLatest
                Mailbox               = $userInfo.UserPrincipalName
                SenderName            = $senderNameValue
                SourceFolder          = $userInfo.UserPrincipalName + ':\' + $instance.SourceFolder
                SystemCategory        = $instance.SystemCategory
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration for Sweep Rule with Name {$($this.Name)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($setParameters.ContainsKey('SenderName'))
        {
            $setParameters.Sender = $setParameters.SenderName
            $setParameters.Remove('SenderName') | Out-Null
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message 'Creating new Sweep Rule.'
            New-SweepRule @SetParameters
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message 'Updating existing Sweep Rule.'
            $instance = Get-SweepRule -Mailbox $this.Mailbox | Where-Object -FilterScript { $_.Name -eq $this.Name }
            $SetParameters.Add('Identity', $instance.RuleId)
            Write-Verbose -Message "Parameters:`r`n$(ConvertTo-Json $SetParameters -Depth 10)"
            Set-SweepRule @SetParameters
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message 'Removing existing Sweep Rule.'
            $instance = Get-SweepRule -Mailbox $this.Mailbox | Where-Object -FilterScript { $_.Name -eq $this.Name }
            Remove-SweepRule -Identity $instance.RuleId -Mailbox $this.Mailbox -Confirm:$false
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
            $j = 1
            if ($mailboxes.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            foreach ($mailbox in $mailboxes)
            {
                Write-M365DSCHost -Message "    |---[$j/$($mailboxes.Count)] $($mailbox.Name)" -DeferWrite
                [Array] $currentInstances = Get-SweepRule -Mailbox $mailbox.Name -ErrorAction Stop

                $i = 1
                if ($currentInstances.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }
                foreach ($config in $currentInstances)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }
                    $displayedKey = $config.Name
                    Write-M365DSCHost -Message "        |---[$i/$($currentInstances.Count)] $displayedKey" -DeferWrite
                    $params = @{
                        Name                  = $config.Name
                        Mailbox               = $mailbox.UserPrincipalName
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        ManagedIdentity       = $this.ManagedIdentity
                        AccessTokens          = $this.AccessTokens
                    }
                    $this.ExportedInstance = $config
                    $Results = $this.GetForExport($params)
                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    $i++
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                $j++
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOSweepRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOSweepRule])
        {
            return $Values
        }

        $result = [EXOSweepRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
