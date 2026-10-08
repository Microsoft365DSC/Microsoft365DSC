using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOCASMailboxPlan : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the CAS Mailbox Plan that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the CAS Mailbox Plan.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('CASMailboxPlans cannot be created/removed in O365.  This must be set to ''Present''')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The ActiveSyncEnabled parameter enables or disables access to the mailbox by using Exchange Active Sync. Default is $true.')]
    [System.Nullable[System.Boolean]] $ActiveSyncEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ImapEnabled parameter enables or disables access to the mailbox by using IMAP4 clients. The default value is $true for all CAS mailbox plans except ExchangeOnlineDeskless which is $false by default.')]
    [System.Nullable[System.Boolean]] $ImapEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OwaMailboxPolicy parameter specifies the Outlook on the web (formerly known as Outlook Web App) mailbox policy for the mailbox plan. The default value is OwaMailboxPolicy-Default. You can use the Get-OwaMailboxPolicy cmdlet to view the available Outlook on the web mailbox policies.')]
    [System.String] $OwaMailboxPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The PopEnabled parameter enables or disables access to the mailbox by using POP3 clients. Default is $true.')]
    [System.Nullable[System.Boolean]] $PopEnabled

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

    [EXOCASMailboxPlan] Get()
    {
        $MailboxPlan = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOCASMailboxPlan]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of CASMailboxPlan for $($this.Identity)"

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

                $CASMailboxPlan = Invoke-M365DSCCommand -ScriptBlock { Get-CASMailboxPlan -Identity $this.Identity } -SuppressNotFoundError
                if ($null -eq $MailboxPlan)
                {
                    Write-Verbose -Message "MailboxPlan $($this.Identity) does not exist."

                    # Try and retrieve by Display Name
                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $CASMailboxPlan = Invoke-M365DSCCommand -ScriptBlock { Get-CASMailboxPlan -Filter "DisplayName -eq '$($this.DisplayName)'" }
                    }

                    if ($null -eq $MailboxPlan)
                    {
                        $CASMailboxPlan = Invoke-M365DSCCommand -ScriptBlock { Get-CASMailboxPlan -Filter "Name -like '$($this.Identity.Split('-')[0])-*'" }
                        if ($null -eq $CASMailboxPlan)
                        {
                            Write-Verbose -Message "CASMailboxPlan $($this.Identity) does not exist."
                            return $this.AsResult($nullResult)
                        }
                    }
                }
            }
            else
            {
                $CASMailboxPlan = $this.ExportedInstance
            }

            Write-Verbose -Message "Found CASMailboxPlan $($this.Identity)"

            $result = @{
                Ensure                = 'Present'
                Identity              = $CASMailboxPlan.Identity
                DisplayName           = $CASMailboxPlan.DisplayName
                ActiveSyncEnabled     = $CASMailboxPlan.ActiveSyncEnabled
                ImapEnabled           = $CASMailboxPlan.ImapEnabled
                OwaMailboxPolicy      = $CASMailboxPlan.OwaMailboxPolicy
                PopEnabled            = $CASMailboxPlan.PopEnabled
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

        Write-Verbose -Message "Setting configuration of CASMailboxPlan for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $updateParameters.Remove('DisplayName') | Out-Null

        if ($null -eq $currentInstance -or $currentInstance.Ensure -eq 'Absent')
        {
            throw "The specified CAS Mailbox Plan {$($this.Identity)} doesn't exist"
        }

        $updateParameters.Identity = $currentInstance.Identity
        Write-Verbose -Message "Setting CASMailboxPlan $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $updateParameters)"
        Invoke-M365DSCCommand -ScriptBlock { Set-CASMailboxPlan @updateParameters }
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
            [array]$CASMailboxPlans = Get-CASMailboxPlan -ErrorAction Stop

            if ($CASMailboxPlans.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            foreach ($CASMailboxPlan in $CASMailboxPlans)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($CASMailboxPlans.Count)] $($CASMailboxPlan.Identity.Split('-')[0])" -DeferWrite
                $Params = @{
                    Identity              = $CASMailboxPlan.Identity
                    DisplayName           = $CASMailboxPlan.DisplayName
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $CASMailboxPlan
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

    hidden [EXOCASMailboxPlan] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOCASMailboxPlan])
        {
            return $Values
        }

        $result = [EXOCASMailboxPlan]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
