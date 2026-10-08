using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOMigration : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter identifies the name of the current migration batch.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The NotificationEmails parameter specifies one or more email addresses that migration status reports are sent to.')]
    [System.String[]] $NotificationEmails

    [DscProperty()]
    [System.ComponentModel.Description('The CompleteAfter parameter specifies a delay before the batch is completed.')]
    [System.String] $CompleteAfter

    [DscProperty()]
    [System.ComponentModel.Description('The AddUsers parameter controls whether additional users can be dynamically added to an existing migration batch after it has been created.')]
    [System.Nullable[System.Boolean]] $AddUsers

    [DscProperty()]
    [System.ComponentModel.Description('The MoveOptions parameter specifies the stages of the migration that you want to skip for debugging purposes.')]
    [System.String[]] $MoveOptions

    [DscProperty()]
    [System.ComponentModel.Description('The SkipMerging parameter specifies the stages of the migration that you want to skip for debugging purposes.')]
    [System.String[]] $SkipMerging

    [DscProperty()]
    [System.ComponentModel.Description('The StartAfter parameter specifies a delay before the data migration for the users within the batch is started.')]
    [System.String] $StartAfter

    [DscProperty()]
    [System.ComponentModel.Description('The Update switch sets the Update flag on the migration batch.')]
    [System.Nullable[System.Boolean]] $Update

    [DscProperty()]
    [System.ComponentModel.Description('The Status parameter returns information about migration users that have the specified status state.')]
    [System.String] $Status

    [DscProperty()]
    [System.ComponentModel.Description('Migration Users states the list of the users/mailboxes that are part of a migration batch that are to be migrated.')]
    [System.String[]] $MigrationUsers

    [DscProperty()]
    [System.ComponentModel.Description('The SourceEndpoint parameter specifies the migration endpoint to use for the source of the migration batch.')]
    [System.String] $SourceEndpoint

    [DscProperty()]
    [System.ComponentModel.Description('The TargetDeliveryDomain parameter specifies the FQDN of the external email address created in the source forest for the mail-enabled user when the migration batch is complete.')]
    [System.String] $TargetDeliveryDomain

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if the migration endpoint should exist or not.')]
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

    [EXOMigration] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOMigration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Migration Batch with Identity {$($this.Identity)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-MigrationBatch -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Migration Batch with Identity $($this.Identity) not found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "Migration Batch with Identity $($this.Identity) found"

            $Users = Get-MigrationUser -BatchId $this.Identity
            $UserEmails = @()
            foreach ($user in $Users)
            {
                $UserEmails += $user.Identity
            }

            $results = @{
                Identity              = $this.Identity
                NotificationEmails    = [System.String[]]$instance.NotificationEmails
                AddUsers              = [System.Boolean]$instance.AddUsers
                MoveOptions           = [System.String[]]$instance.MoveOptions
                SkipMerging           = [System.String[]]$instance.SkipMerging
                Update                = [System.Boolean]$instance.Update
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
                Status                = $instance.Status.Value
                MigrationUsers        = $UserEmails
                SourceEndpoint        = $instance.SourceEndpoint.Identity.Id
                TargetDeliveryDomain  = $instance.TargetDeliveryDomain
            }

            if ($null -ne $instance.CompleteAfter)
            {
                $results.Add('CompleteAfter', $instance.CompleteAfter.ToString('MM/dd/yyyy hh:mm tt'))
            }

            if ($null -ne $instance.StartAfter)
            {
                $results.Add('StartAfter', $instance.StartAfter.ToString('MM/dd/yyyy hh:mm tt'))
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

        Write-Verbose -Message "Setting configuration for Migration Batch with Identity {$($this.Identity)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            # Convert the list of users to CSV format
            $csvContent = @('"EmailAddress"') + ($this.MigrationUsers | ForEach-Object { "`"$_`"" })

            # Join the results into a single string with new lines
            $csvContent = $csvContent -join "`r`n"

            # Convert the CSV content to bytes directly without saving to a file
            $csvBytes = [System.Text.Encoding]::UTF8.GetBytes($csvContent -join "`r`n")

            $BatchParams = @{
                Name                 = $this.Identity  # Use the existing Identity as the new batch name
                CSVData              = $csvBytes  # Directly use the byte array
                NotificationEmails   = $this.NotificationEmails  # Use the same notification emails if provided
                CompleteAfter        = $this.CompleteAfter
                StartAfter           = $this.StartAfter
                SkipMerging          = $this.SkipMerging
                SourceEndpoint       = $this.SourceEndpoint
                TargetDeliveryDomain = $this.TargetDeliveryDomain
            }

            # Create a new migration batch with the specified parameters
            New-MigrationBatch @BatchParams
            Write-M365DSCHost -Message "A new migration batch named '$($currentInstance.Identity)' has been created with the specified parameters."
        }

        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            # Retrieve the migration batch
            $migrationBatch = Get-MigrationBatch -Identity $currentInstance.Identity -ErrorAction Stop

            if ($migrationBatch.Status.Value -in @('Completed', 'CompletedWithErrors', 'Stopped', 'Failed', 'SyncedWithErrors'))
            {
                # If the migration batch is in a final state, remove it directly
                Remove-MigrationBatch -Identity $currentInstance.Identity -Confirm:$false
                Write-M365DSCHost -Message "Migration batch '$($currentInstance.Identity)' has been removed as it was in a completed or stopped state."
            }
            elseif ($migrationBatch.Status.Value -in @('InProgress', 'Syncing', 'Queued', 'Completing'))
            {
                # If the migration batch is in progress, stop it first
                Stop-MigrationBatch -Identity $currentInstance.Identity -Confirm:$false
                Write-M365DSCHost -Message "Migration batch '$($currentInstance.Identity)' was in progress and has been stopped."

                # Now remove the migration batch
                Remove-MigrationBatch -Identity $currentInstance.Identity -Confirm:$false
                Write-M365DSCHost -Message "Migration batch '$($currentInstance.Identity)' has been removed after stopping."
            }
            else
            {
                Write-M365DSCHost -Message "Migration batch '$($currentInstance.Identity)' is in an unexpected status: $($migrationBatch.Status.Value). Manual intervention may be required."
            }
        }

        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            # Define the path for the CSV file to store the migration users
            $csvFilePath = "$env:TEMP\MigrationUsers.csv"

            # Convert each item in the array to a custom object with an EmailAddress property
            $csvContent = $this.MigrationUsers | ForEach-Object { @{EmailAddress = $_ } }

            # Export to CSV with the header "EmailAddress"
            $csvContent | Export-Csv -Path $csvFilePath -NoTypeInformation -Force

            $BatchParams = @{
                Identity           = $this.Identity  # Use the existing Identity as the new batch name
                CSVData            = [System.IO.File]::ReadAllBytes($csvFilePath)  # Load the CSV as byte array
                NotificationEmails = $this.NotificationEmails  # Use the same notification emails if provided
                CompleteAfter      = $this.CompleteAfter
                StartAfter         = $this.StartAfter
                SkipMerging        = $this.SkipMerging
                Update             = $this.Update
                AddUsers           = $this.AddUsers
            }

            Set-MigrationBatch @BatchParams

            $migrationBatch = Get-MigrationBatch -Identity $currentInstance.Identity -ErrorAction Stop

            if ($currentInstance.Status -eq 'Stopped' -and $migrationBatch.Status -eq 'Started')
            {
                # If currentInstance is stopped but migrationBatch is started, stop the migration batch
                Stop-MigrationBatch -Identity $currentInstance.Identity -Confirm:$false
                Write-M365DSCHost -Message "Migration batch '$($currentInstance.Identity)' was running and has been stopped to match the current instance status."
            }
            elseif ($currentInstance.Status -eq 'Started' -and $migrationBatch.Status -eq 'Stopped')
            {
                # If currentInstance is started but migrationBatch is stopped, start the migration batch
                Start-MigrationBatch -Identity $currentInstance.Identity -Confirm:$false
                Write-M365DSCHost -Message "Migration batch '$($currentInstance.Identity)' was stopped and has been started to match the current instance status."
            }
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

        #region Telemetry
        $this.AddTelemetry('Export')
        #endregion

        try
        {
            [array]$migrationBatches = Get-MigrationBatch -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($migrationBatches.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $migrationBatches)
            {
                $displayedKey = $config.Identity
                Write-M365DSCHost -Message "    |---[$i/$($migrationBatches.Count)] $displayedKey" -DeferWrite
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

    hidden [EXOMigration] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOMigration])
        {
            return $Values
        }

        $result = [EXOMigration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
