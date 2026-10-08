using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOMailboxIRMAccess : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the mailbox that you want to modify')]
    [System.String] $Identity

    [DscProperty(Key)]
    [System.ComponentModel.Description('The User parameter specifies the delegate who is blocked from reading IRM-protected messages in the mailbox.')]
    [System.String] $User

    [DscProperty()]
    [System.ComponentModel.Description('The AccessLevel parameter specifies what delegates can do to IRM-protected messages in the mailbox that''s specified by the Identity parameter.')]
    [ValidateSet('Block')]
    [System.String] $AccessLevel

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the resource exists, absent ensures it is removed')]
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

    [EXOMailboxIRMAccess] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOMailboxIRMAccess]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Mailbox IRM Access with Identity {$($this.Identity)} and User {$($this.User)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.User -ne $this.User)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-MailboxIRMAccess -Identity $this.Identity -User $this.User -ErrorAction SilentlyContinue
                if ($null -eq $instance)
                {
                    Write-Verbose -Message "No Mailbox IRM Access found for Identity {$($this.Identity)} and User {$($this.User)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "A Mailbox IRM Access with Identity {$($this.Identity)} for User {$($this.User)} was found."

            $results = @{
                Identity              = $this.Identity
                User                  = $this.User
                AccessLevel           = $instance.AccessLevel
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

        Write-Verbose -Message "Setting configuration of Mailbox IRM Access with Identity {$($this.Identity)} and User {$($this.User)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Set-MailboxIRMAccess @setParameters
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            $setParameters.Remove('AccessLevel') | Out-Null
            Remove-MailboxIRMAccess @SetParameters
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

        ##TODO - Replace workload
        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$mailboxes = Get-M365DSCExportCachedCollection -Collection 'exoMailboxes'

            if ($mailboxes.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            foreach ($mailbox in $mailboxes)
            {
                Write-M365DSCHost -Message "    |---[$i/$($mailboxes.Count)] $($mailbox.UserPrincipalName)" -DeferWrite

                [Array]$irmAccesses = Get-MailboxIRMAccess -Identity $mailbox.UserPrincipalName

                $j = 1
                Write-M365DSCHost -Message "`r`n" -DeferWrite
                foreach ($irmAccess in $irmAccesses)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "        |---[$j/$($irmAccesses.Count)] $($irmAccess.User)" -DeferWrite
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                    $Params = @{
                        Identity              = $mailbox.UserPrincipalName
                        User                  = $irmAccess.User
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        CertificatePath       = $this.CertificatePath
                        AccessTokens          = $this.AccessTokens
                    }
                    $this.ExportedInstance = $irmAccess
                    $Results = $this.GetForExport($Params)
                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    [void]$dscContent.Append($currentDSCBlock)

                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    $j++
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

    hidden [EXOMailboxIRMAccess] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOMailboxIRMAccess])
        {
            return $Values
        }

        $result = [EXOMailboxIRMAccess]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
