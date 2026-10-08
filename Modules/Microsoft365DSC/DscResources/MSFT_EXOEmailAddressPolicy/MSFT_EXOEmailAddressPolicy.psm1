using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOEmailAddressPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name of the email address policy. The maximum length is 64 characters.')]
    [ValidateLength(1, 64)]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The Priority parameter specifies the order that the email address policies are evaluated. By default, every time that you add a new email address policy, the policy is assigned a priority of N+1, where N is the number of email address policies that you''ve created.')]
    [System.String] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('The EnabledEmailAddressTemplates parameter specifies the rules in the email address policy that are used to generate email addresses for recipients.')]
    [System.String[]] $EnabledEmailAddressTemplates

    [DscProperty()]
    [System.ComponentModel.Description('The EnabledPrimarySMTPAddressTemplate parameter specifies the specifies the rule in the email address policy that''s used to generate the primary SMTP email addresses for recipients. You can use this parameter instead of the EnabledEmailAddressTemplates if the policy only applies the primary email address and no additional proxy addresses.')]
    [System.String[]] $EnabledPrimarySMTPAddressTemplate

    [DscProperty()]
    [System.ComponentModel.Description('The ManagedByFilter parameter specifies the email address policies to apply to Office 365 groups based on the properties of the users who create the Office 365 groups.')]
    [System.String] $ManagedByFilter

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Email Address Policy should exist or not.')]
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

    [EXOEmailAddressPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOEmailAddressPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Email Address Policy configuration for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $EmailAddressPolicy = Get-EmailAddressPolicy -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $EmailAddressPolicy)
                {
                    Write-Verbose -Message "Email Address Policy $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $EmailAddressPolicy = $this.ExportedInstance
            }

            Write-Verbose -Message "Found Email Address Policy $($this.Name)"

            $result = @{
                Name                              = $EmailAddressPolicy.Name
                Priority                          = $EmailAddressPolicy.Priority
                EnabledEmailAddressTemplates      = $EmailAddressPolicy.EnabledEmailAddressTemplates
                EnabledPrimarySMTPAddressTemplate = $EmailAddressPolicy.EnabledPrimarySMTPAddressTemplate
                ManagedByFilter                   = $EmailAddressPolicy.ManagedByFilter
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

        Write-Verbose -Message "Setting Email Address Policy configuration for $($this.Name)"

        $currentEmailAddressPolicyConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $NewEmailAddressPolicyParams = @{
            Name                              = $this.Name
            Priority                          = $this.Priority
            EnabledEmailAddressTemplates      = $this.EnabledEmailAddressTemplates
            EnabledPrimarySMTPAddressTemplate = $this.EnabledPrimarySMTPAddressTemplate
            ManagedByFilter                   = $this.ManagedByFilter
            IncludeUnifiedGroupRecipients     = $true
            Confirm                           = $false
        }

        $SetEmailAddressPolicyParams = @{
            Identity                          = $this.Name
            Priority                          = $this.Priority
            EnabledEmailAddressTemplates      = $this.EnabledEmailAddressTemplates
            EnabledPrimarySMTPAddressTemplate = $this.EnabledPrimarySMTPAddressTemplate
            Confirm                           = $false
        }

        # EnabledEmailAddressTemplates and EnabledPrimarySMTPAddressTemplate cannot used at the same time.
        # If both parameters are specified, EnabledPrimarySMTPAddressTemplate will be removed and only
        # EnabledEmailAddressTemplates will be used.
        if ($null -ne $this.EnabledEmailAddressTemplates)
        {
            $NewEmailAddressPolicyParams.Remove('EnabledPrimarySMTPAddressTemplate')
            $SetEmailAddressPolicyParams.Remove('EnabledPrimarySMTPAddressTemplate')
        }

        # CASE: Email Address Policy doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentEmailAddressPolicyConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Email Address Policy '$($this.Name)' does not exist but it should. Create and configure it."
            # Create Email Address Policy
            New-EmailAddressPolicy @NewEmailAddressPolicyParams

        }
        # CASE: Email Address Policy exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentEmailAddressPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Email Address Policy '$($this.Name)' exists but it shouldn't. Remove it."
            Remove-EmailAddressPolicy -Identity $this.Name -Confirm:$false
        }
        # CASE: Email Address Policy exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentEmailAddressPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Email Address Policy '$($this.Name)' already exists, but needs updating."

            $managedByFilterChanged = $this.GetBoundParameters().ContainsKey('ManagedByFilter') -and [System.String]$this.ManagedByFilter -ne [System.String]$currentEmailAddressPolicyConfig.ManagedByFilter
            if ($managedByFilterChanged -and $this.Name -ne 'Default Policy')
            {
                Write-Verbose -Message "ManagedByFilter of Email Address Policy '$($this.Name)' changed. Recreating the policy."
                Remove-EmailAddressPolicy -Identity $this.Name -Confirm:$false
                New-EmailAddressPolicy @NewEmailAddressPolicyParams
                return
            }

            if ($this.Name -eq 'Default Policy')
            {
                $SetEmailAddressPolicyParams.Remove('Priority')
            }
            Set-EmailAddressPolicy @SetEmailAddressPolicyParams
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

        if ($null -eq (Get-Command Get-EmailAddressPolicy -ErrorAction SilentlyContinue))
        {
            Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiRedX) The specified account doesn't have permissions to access Email Address Policy"
            return ''
        }

        try
        {
            [array]$AllEmailAddressPolicies = Get-EmailAddressPolicy -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            if ($AllEmailAddressPolicies.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($EmailAddressPolicy in $AllEmailAddressPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllEmailAddressPolicies.Count)] $($EmailAddressPolicy.Name)" -DeferWrite

                $Params = @{
                    Name                  = $EmailAddressPolicy.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $EmailAddressPolicy
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

    hidden [EXOEmailAddressPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOEmailAddressPolicy])
        {
            return $Values
        }

        $result = [EXOEmailAddressPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
