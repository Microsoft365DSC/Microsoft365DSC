using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOMailboxPlan : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the Mailbox Plan that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the mailbox plan.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('MailboxPlans cannot be created/removed in O365.  This resource cannot be removed and the value must be set to ''Ensure''.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The IssueWarningQuota parameter specifies the warning threshold for the size of the mailboxes that are created or enabled using the mailbox plan.')]
    [System.String] $IssueWarningQuota

    [DscProperty()]
    [System.ComponentModel.Description('The MaxReceiveSize parameter specifies the maximum size of a message that can be sent to the mailbox.')]
    [System.String] $MaxReceiveSize

    [DscProperty()]
    [System.ComponentModel.Description('The MaxSendSize parameter specifies the maximum size of a message that can be sent by the mailbox.')]
    [System.String] $MaxSendSize

    [DscProperty()]
    [System.ComponentModel.Description('The ProhibitSendQuota parameter specifies a size limit for the mailbox.')]
    [System.String] $ProhibitSendQuota

    [DscProperty()]
    [System.ComponentModel.Description('The ProhibitSendReceiveQuota parameter specifies a size limit for the mailbox.')]
    [System.String] $ProhibitSendReceiveQuota

    [DscProperty()]
    [System.ComponentModel.Description('The RetainDeletedItemsFor parameter specifies the length of time to keep soft-deleted items for the mailbox.')]
    [System.String] $RetainDeletedItemsFor

    [DscProperty()]
    [System.ComponentModel.Description('The RetentionPolicy parameter specifies the retention policy that''s applied to the mailbox.')]
    [System.String] $RetentionPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The RoleAssignmentPolicy parameter specifies the role assignment policy that''s applied to the mailbox.')]
    [System.String] $RoleAssignmentPolicy

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

    [EXOMailboxPlan] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOMailboxPlan]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of MailboxPlan for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = @{
                    Identity = $this.Identity
                    Ensure   = 'Absent'
                }

                $MailboxPlan = Get-MailboxPlan -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $MailboxPlan)
                {
                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        Write-Verbose -Message "Couldn't find MailboxPlan by Identity {$($this.Identity)}. Trying by DisplayName."
                        $MailboxPlan = Get-MailboxPlan -Identity $this.DisplayName
                    }
                    else
                    {
                        $MailboxPlan = Get-MailboxPlan -Filter "Name -like '$($this.Identity.Split('-')[0])*'"
                    }

                    if ($null -eq $MailboxPlan)
                    {
                        return $this.AsResult($nullResult)
                    }
                }
            }
            else
            {
                $MailboxPlan = $this.ExportedInstance
            }

            Write-Verbose -Message "Found MailboxPlan $($this.Identity)"

            $result = @{
                Ensure                   = 'Present'
                Identity                 = $this.Identity
                DisplayName              = $MailboxPlan.DisplayName
                IssueWarningQuota        = $MailboxPlan.IssueWarningQuota
                MaxReceiveSize           = $MailboxPlan.MaxReceiveSize
                MaxSendSize              = $MailboxPlan.MaxSendSize
                ProhibitSendQuota        = $MailboxPlan.ProhibitSendQuota
                ProhibitSendReceiveQuota = $MailboxPlan.ProhibitSendReceiveQuota
                RetainDeletedItemsFor    = $MailboxPlan.RetainDeletedItemsFor
                RetentionPolicy          = $MailboxPlan.RetentionPolicy
                RoleAssignmentPolicy     = $MailboxPlan.RoleAssignmentPolicy
                Credential               = $this.Credential
                ApplicationId            = $this.ApplicationId
                CertificateThumbprint    = $this.CertificateThumbprint
                CertificatePath          = $this.CertificatePath
                CertificatePassword      = $this.CertificatePassword
                ManagedIdentity          = $this.ManagedIdentity
                TenantId                 = $this.TenantId
                AccessTokens             = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of MailboxPlan for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $updateParameters.Remove('DisplayName') | Out-Null

        $MailboxPlan = Get-MailboxPlan -Identity $this.Identity

        if ($null -ne $MailboxPlan)
        {
            Write-Verbose -Message "Setting MailboxPlan $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $updateParameters)"
            Set-MailboxPlan @updateParameters
        }
        else
        {
            throw "The specified Mailbox Plan {$($this.Identity)} doesn't exist"
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
            [array]$MailboxPlans = Get-MailboxPlan -ErrorAction Stop

            if ($MailboxPlans.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            foreach ($MailboxPlan in $MailboxPlans)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($MailboxPlans.Count)] $($MailboxPlan.Identity.Split('-')[0])" -DeferWrite
                $Params = @{
                    Identity              = $MailboxPlan.Identity
                    DisplayName           = $MailboxPlan.DisplayName
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $MailboxPlan
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

    hidden [EXOMailboxPlan] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOMailboxPlan])
        {
            return $Values
        }

        $result = [EXOMailboxPlan]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
