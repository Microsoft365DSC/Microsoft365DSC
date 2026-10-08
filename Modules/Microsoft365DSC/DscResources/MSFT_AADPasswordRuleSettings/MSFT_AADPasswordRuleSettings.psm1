using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADPasswordRuleSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The number of failed login attempts before the first lockout period begins.')]
    [System.Nullable[System.UInt32]] $LockoutThreshold

    [DscProperty()]
    [System.ComponentModel.Description('The duration in seconds of the initial lockout period.')]
    [System.Nullable[System.UInt32]] $LockoutDurationInSeconds

    [DscProperty()]
    [System.ComponentModel.Description('Boolean indicating if the banned password check for tenant specific banned password list is turned on or not.')]
    [System.Nullable[System.Boolean]] $EnableBannedPasswordCheck

    [DscProperty()]
    [System.ComponentModel.Description('A list of banned words in passwords.')]
    [System.String[]] $BannedPasswordList

    [DscProperty()]
    [System.ComponentModel.Description('How should we enforce password policy check in on-premises system.')]
    [ValidateSet('Enforce', 'Audit')]
    [System.String] $BannedPasswordCheckOnPremisesMode

    [DscProperty()]
    [System.ComponentModel.Description('Boolean indicating if the banned password check is turned on or not for on-premises system.')]
    [System.Nullable[System.Boolean]] $EnableBannedPasswordCheckOnPremises

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Azure AD Password Rule Settings should exist or not.')]
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

    [AADPasswordRuleSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADPasswordRuleSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of AzureAD Password Rule Settings'

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

            $Policy = Get-MgBetaDirectorySetting -All | Where-Object -FilterScript { $_.DisplayName -eq 'Password Rule Settings' }

            if ($null -eq $Policy)
            {
                return $this.AsResult($nullReturn)
            }
            else
            {
                Write-Verbose -Message 'Found existing AzureAD DirectorySetting for Password Rule Settings'
                $valueBannedPasswordCheckOnPremisesMode = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'BannedPasswordCheckOnPremisesMode' }
                $valueEnableBannedPasswordCheckOnPremises = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'EnableBannedPasswordCheckOnPremises' }
                $valueEnableBannedPasswordCheck = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'EnableBannedPasswordCheck' }
                $valueLockoutDurationInSeconds = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'LockoutDurationInSeconds' }
                $valueLockoutThreshold = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'LockoutThreshold' }
                $valueBannedPasswordList = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'BannedPasswordList' }

                $bannedPasswordListArray = @()
                # Splitting a null value results in an array with one empty string
                if ($valueBannedPasswordList.Value.Count -gt 0 -and -not [System.String]::IsNullOrEmpty($valueBannedPasswordList.Value[0]))
                {
                    $bannedPasswordListArray = $valueBannedPasswordList.Value -split "`t" # list is tab-delimited
                }
                $result = @{
                    IsSingleInstance                    = 'Yes'
                    BannedPasswordCheckOnPremisesMode   = $valueBannedPasswordCheckOnPremisesMode.Value
                    EnableBannedPasswordCheckOnPremises = [Boolean]::Parse($valueEnableBannedPasswordCheckOnPremises.Value)
                    EnableBannedPasswordCheck           = [Boolean]::Parse($valueEnableBannedPasswordCheck.Value)
                    LockoutDurationInSeconds            = $valueLockoutDurationInSeconds.Value
                    LockoutThreshold                    = $valueLockoutThreshold.Value
                    BannedPasswordList                  = $bannedPasswordListArray
                    Ensure                              = 'Present'
                    ApplicationId                       = $this.ApplicationId
                    TenantId                            = $this.TenantId
                    ApplicationSecret                   = $this.ApplicationSecret
                    CertificateThumbprint               = $this.CertificateThumbprint
                    Credential                          = $this.Credential
                    ManagedIdentity                     = $this.ManagedIdentity
                    AccessTokens                        = $this.AccessTokens
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

        Write-Verbose -Message 'Setting configuration of Azure AD Password Rule Settings'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentPolicy = $this.Get().ToHashtable()

        # Policy should exist but it doesn't
        $needToUpdate = $false
        if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose "Create new DirectorySetting for 'Password Rule Settings' with default values"
            $template = Get-MgBetaDirectorySettingTemplate -All | Where-Object -FilterScript { $_.Displayname -eq 'Password Rule Settings' }
            # need to build a new array for values since the template-values contain property DefaultValue but Value is required
            $defaultValues = @()
            $template.Values | ForEach-Object {
                $defaultValues += @{
                    name  = $_.Name
                    value = $_.DefaultValue
                }
            }
            $Policy = New-MgBetaDirectorySetting -TemplateId $template.Id -Values $defaultValues | Out-Null
            $needToUpdate = $true
        }

        $Policy = Get-MgBetaDirectorySetting -All | Where-Object -FilterScript { $_.DisplayName -eq 'Password Rule Settings' }

        if (($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present') -or $needToUpdate)
        {
            foreach ($property in $Policy.Values)
            {
                if ($property.Name -eq 'LockoutThreshold')
                {
                    $entry = $Policy.Values | Where-Object -FilterScript { $_.Name -eq $property.Name }
                    $entry.Value = [System.String]$this.LockoutThreshold
                }
                elseif ($property.Name -eq 'LockoutDurationInSeconds')
                {
                    $entry = $Policy.Values | Where-Object -FilterScript { $_.Name -eq $property.Name }
                    $entry.Value = [System.String]$this.LockoutDurationInSeconds
                }
                elseif ($property.Name -eq 'EnableBannedPasswordCheck')
                {
                    $entry = $Policy.Values | Where-Object -FilterScript { $_.Name -eq $property.Name }
                    $entry.Value = [System.String]$this.EnableBannedPasswordCheck
                }
                elseif ($property.Name -eq 'BannedPasswordList')
                {
                    $entry = $Policy.Values | Where-Object -FilterScript { $_.Name -eq $property.Name }
                    $entry.Value = $this.BannedPasswordList -join "`t"
                }
                elseif ($property.Name -eq 'EnableBannedPasswordCheckOnPremises')
                {
                    $entry = $Policy.Values | Where-Object -FilterScript { $_.Name -eq $property.Name }
                    $entry.Value = [System.String]$this.EnableBannedPasswordCheckOnPremises
                }
                elseif ($property.Name -eq 'BannedPasswordCheckOnPremisesMode')
                {
                    $entry = $Policy.Values | Where-Object -FilterScript { $_.Name -eq $property.Name }
                    $entry.Value = $this.BannedPasswordCheckOnPremisesMode
                }
            }

            Write-Verbose -Message "Updating Policy's Values with $($Policy.Values | ConvertTo-Json -Depth 10)"
            Update-MgBetaDirectorySetting -DirectorySettingId $Policy.id -Values $Policy.Values | Out-Null
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "An existing Directory Setting entry exists, and we don't allow to have it removed."
            throw 'The AADPasswordRuleSettings resource cannot delete existing Directory Setting entries. Please specify Present.'
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

            $Params = @{
                IsSingleInstance      = 'Yes'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }
            $dscContent = [System.Text.StringBuilder]::new()
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
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADPasswordRuleSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADPasswordRuleSettings])
        {
            return $Values
        }

        $result = [AADPasswordRuleSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
