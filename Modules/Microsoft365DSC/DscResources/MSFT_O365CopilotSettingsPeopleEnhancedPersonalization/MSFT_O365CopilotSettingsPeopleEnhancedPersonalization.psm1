using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class O365CopilotSettingsPeopleEnhancedPersonalization : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('If true, enables the enhanced personalization control and therefore related features as defined in control enhanced personalization privacy Required.')]
    [System.Nullable[System.Boolean]] $isEnabledInOrganization

    [DscProperty()]
    [System.ComponentModel.Description('The ID of a Microsoft Entra group to which the value is used to disable the control for populated users. Optional.')]
    [System.String] $disabledForGroup

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
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
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

    [O365CopilotSettingsPeopleEnhancedPersonalization] Get()
    {
        $currdisabledForGroup = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [O365CopilotSettingsPeopleEnhancedPersonalization]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Get the Copilot setting for personalization capabilities'

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()

            $uri = '/beta/copilot/settings/people/enhancedpersonalization'
            $instance = Invoke-M365DSCGraphRequest -Uri $uri -Method Get
            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            # Convert GroupId toDisplayName if needed
            if ($null -ne $instance.disabledForGroup)
            {
                $currdisabledForGroup = Get-MgGroup -GroupId $instance.disabledForGroup -Property DisplayName
            }

            $results = @{
                IsSingleInstance        = 'Yes'
                isEnabledInOrganization = $instance.isEnabledInOrganization
                disabledForGroup        = if ($null -ne $currdisabledForGroup)
                {
                    $currdisabledForGroup.displayName
                }
                else
                {
                    $null
                }
                Credential              = $this.Credential
                ApplicationId           = $this.ApplicationId
                TenantId                = $this.TenantId
                ApplicationSecret       = $this.ApplicationSecret
                CertificateThumbprint   = $this.CertificateThumbprint
                CertificatePath         = $this.CertificatePath
                CertificatePassword     = $this.CertificatePassword
                ManagedIdentity         = $this.ManagedIdentity
                AccessTokens            = $this.AccessTokens
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

        Write-Verbose -Message 'Set the Copilot setting for personalization capabilities'

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        # Check if $disabledForGroup is a guid or display name and convert to guid if needed
        $disabledForGroupId = $this.disabledForGroup
        if (-not [string]::IsNullOrEmpty($disabledForGroupId))
        {
            if (-not ([System.Guid]::TryParse($disabledForGroupId, [ref][System.Guid]::Empty)))
            {
                $group = Get-MgGroup -Filter "displayName eq '$disabledForGroupId'" -Property Id -Top 1
                if ($null -ne $group)
                {
                    $disabledForGroupId = $group.Id
                }
                else
                {
                    throw "Group with display name '$disabledForGroupId' not found."
                }
            }
        }

        Write-Verbose -Message "Updating the isEnabledInOrganization setting to {$($this.isEnabledInOrganization.ToString())}"
        $settings = @{
            isEnabledInOrganization = $this.isEnabledInOrganization
            disabledForGroup        = if ([string]::IsNullOrEmpty($disabledForGroupId))
            {
                $null
            }
            else
            {
                $disabledForGroupId
            }
        }
        $body = ConvertTo-Json $settings
        $uri = '/beta/copilot/settings/people/enhancedpersonalization'
        Invoke-M365DSCGraphRequest -Uri $uri -Method PATCH -Body $Body | Out-Null
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
            $dscContent = [System.Text.StringBuilder]::new()
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $params = @{
                ISSingleInstance      = 'Yes'
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

    hidden [O365CopilotSettingsPeopleEnhancedPersonalization] AsResult([System.Object] $Values)
    {
        if ($Values -is [O365CopilotSettingsPeopleEnhancedPersonalization])
        {
            return $Values
        }

        $result = [O365CopilotSettingsPeopleEnhancedPersonalization]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
