using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADGroupLifecyclePolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The number of days a group can exist before it needs to be renewed.')]
    [System.Nullable[System.UInt32]] $GroupLifetimeInDays

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('This parameter allows the admin to select which office 365 groups the policy will apply to. ''None'' will create the policy in a disabled state. ''All'' will apply the policy to every Office 365 group in the tenant. ''Selected'' will allow the admin to choose specific Office 365 groups that the policy will apply to.')]
    [ValidateSet('All', 'None', 'Selected')]
    [System.String] $ManagedGroupTypes

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Notification emails for groups that have no owners will be sent to these email addresses.')]
    [System.String[]] $AlternateNotificationEmails

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Azure AD Groups Lifecycle Policy should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials for the Microsoft Graph delegated permissions.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

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

    [AADGroupLifecyclePolicy] Get()
    {
        $Policy = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADGroupLifecyclePolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of AzureAD Groups Lifecycle Policy'

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullReturn = $this.GetBoundParameters()
            $nullReturn.Ensure = 'Absent'

            try
            {
                $Policy = Get-MgGroupLifecyclePolicy -ErrorAction SilentlyContinue
            }
            catch
            {
                $this.LogError($_, 'Error retrieving data:')
            }

            if ($null -eq $Policy)
            {
                return $this.AsResult($nullReturn)
            }
            else
            {
                Write-Verbose 'Found existing AzureAD Groups Lifecycle Policy'
                $result = @{
                    IsSingleInstance            = 'Yes'
                    GroupLifetimeInDays         = $Policy.GroupLifetimeInDays
                    ManagedGroupTypes           = $Policy.ManagedGroupTypes
                    AlternateNotificationEmails = $Policy.AlternateNotificationEmails.Split(';')
                    Ensure                      = 'Present'
                    Credential                  = $this.Credential
                    ApplicationId               = $this.ApplicationId
                    ApplicationSecret           = $this.ApplicationSecret
                    TenantId                    = $this.TenantId
                    CertificateThumbprint       = $this.CertificateThumbprint
                    ManagedIdentity             = $this.ManagedIdentity
                    AccessTokens                = $this.AccessTokens
                }

                return $this.AsResult($result)
            }
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

        Write-Verbose -Message 'Setting configuration of Azure AD Groups Lifecycle Policy'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('MicrosoftGraph')

        $currentPolicy = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "The Group Lifecycle Policy should exist but it doesn't. Creating it."
            $createParameters = $boundParameters
            $createParameters.Remove('IsSingleInstance') | Out-Null

            $emails = ''
            foreach ($email in $createParameters.alternateNotificationEmails)
            {
                $emails += $email + ';'
            }
            $emails = $emails.TrimEnd(';')
            $createParameters.alternateNotificationEmails = $emails
            New-MgGroupLifecyclePolicy -BodyParameter $createParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
        {
            $updateParameters = $boundParameters
            $updateParameters.Remove('IsSingleInstance') | Out-Null

            $emails = ''
            foreach ($email in $updateParameters.alternateNotificationEmails)
            {
                $emails += $email + ';'
            }
            $emails = $emails.TrimEnd(';')
            $updateParameters.alternateNotificationEmails = $emails

            Write-Verbose -Message "The Group Lifecycle Policy exists but it's not in the Desired State. Updating it."
            Update-MgGroupLifecyclePolicy -GroupLifecyclePolicyId (Get-MgGroupLifecyclePolicy).Id -BodyParameter $updateParameters
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message 'The Group Lifecycle Policy should NOT exist but it DOES. Removing it.'
            Remove-MgGroupLifecyclePolicy -GroupLifecyclePolicyId (Get-MgGroupLifecyclePolicy).Id
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

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $dscContent = [System.Text.StringBuilder]::new()
            $Params = @{
                Credential                  = $this.Credential
                IsSingleInstance            = 'Yes'
                GroupLifetimeInDays         = 1
                ManagedGroupTypes           = 'All'
                AlternateNotificationEmails = 'empty@contoso.com'
                ApplicationId               = $this.ApplicationId
                ApplicationSecret           = $this.ApplicationSecret
                TenantId                    = $this.TenantId
                CertificateThumbprint       = $this.CertificateThumbprint
                CertificatePath             = $this.CertificatePath
                CertificatePassword         = $this.CertificatePassword
                ManagedIdentity             = $this.ManagedIdentity
                AccessTokens                = $this.AccessTokens
            }
            $Results = $this.GetForExport($Params)
            if ($Results.Ensure -eq 'Present')
            {
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

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADGroupLifecyclePolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADGroupLifecyclePolicy])
        {
            return $Values
        }

        $result = [AADGroupLifecyclePolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
