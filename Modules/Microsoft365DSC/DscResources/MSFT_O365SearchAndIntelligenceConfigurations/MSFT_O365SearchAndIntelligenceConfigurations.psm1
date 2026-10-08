using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class O365SearchAndIntelligenceConfigurations : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the resource is a single instance, the value must be ''Yes''')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether or not Item Insights should be available for the organization.')]
    [System.Nullable[System.Boolean]] $ItemInsightsIsEnabledInOrganization

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a single Azure AD Group for which Item Insights needs to be disabled.')]
    [System.String] $ItemInsightsDisabledForGroup

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether or not Meeting Insights should be available for the organization.')]
    [System.Nullable[System.Boolean]] $MeetingInsightsIsEnabledInOrganization

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether or not Person Insights should be available for the organization.')]
    [System.Nullable[System.Boolean]] $PersonInsightsIsEnabledInOrganization

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a single Azure AD Group for which Person Insights needs to be disabled.')]
    [System.String] $PersonInsightsDisabledForGroup

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Global Admin')]
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

    [O365SearchAndIntelligenceConfigurations] Get()
    {
        $PersonInsights = $null
        $PersonInsightsDisabledForGroupValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [O365SearchAndIntelligenceConfigurations]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting the O365 Search and Intelligence Configurations'

        try
        {
            $ConnectionMode = $this.Connect('ExchangeOnline')

            $ConnectionMode = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $tenantIdValue = $this.TenantId
            if ($ConnectionMode -eq 'Credentials')
            {
                $tenantIdValue = $this.Credential.UserName.Split('@')[1]
            }

            $ItemInsights = Get-MgBetaOrganizationSettingItemInsight -OrganizationId $tenantIdValue
            $itemInsightsDisabledForGroupValue = $null
            if (-not [System.String]::IsNullOrEmpty($ItemInsights.DisabledForGroup))
            {
                $group = Invoke-M365DSCCommand -ScriptBlock { Get-MgGroup -GroupId ($ItemInsights.DisabledForGroup) }
                $itemInsightsDisabledForGroupValue = $group.DisplayName
            }

            try
            {
                $PersonInsights = Get-MgBetaOrganizationSettingPersonInsight -OrganizationId $tenantIdValue `
                    -ErrorAction Stop
                $PersonInsightsDisabledForGroupValue = $null
                if (-not [System.String]::IsNullOrEmpty($PersonInsights.DisabledForGroup))
                {
                    $group = Invoke-M365DSCCommand -ScriptBlock { Get-MgGroup -GroupId ($PersonInsights.DisabledForGroup) }
                    $PersonInsightsDisabledForGroupValue = $group.DisplayName
                }
            }
            catch
            {
                if ($_.Exception.Message -eq "[BadRequest] : Resource not found for the segment 'peopleInsights'.")
                {
                    Write-Warning -Message 'The peopleInsights segment is not available in the selected environment.'
                }
                else
                {
                    throw
                }
            }

            $MeetingInsightsResponse = Invoke-M365DSCCommand -ScriptBlock { Get-MeetingInsightsSettings }
            $MeetingInsightsValue = [Boolean]::Parse($MeetingInsightsResponse.Split(':')[1].Trim())

            return $this.AsResult(@{
                IsSingleInstance                       = 'Yes'
                ItemInsightsIsEnabledInOrganization    = $ItemInsights.IsEnabledInOrganization
                ItemInsightsDisabledForGroup           = $itemInsightsDisabledForGroupValue
                MeetingInsightsIsEnabledInOrganization = $MeetingInsightsValue
                PersonInsightsIsEnabledInOrganization  = $PersonInsights.IsEnabledInOrganization
                PersonInsightsDisabledForGroup         = $PersonInsightsDisabledForGroupValue
                Credential                             = $this.Credential
                ApplicationId                          = $this.ApplicationId
                TenantId                               = $tenantIdValue
                CertificateThumbprint                  = $this.CertificateThumbprint
                CertificatePath                        = $this.CertificatePath
                CertificatePassword                    = $this.CertificatePassword
                ManagedIdentity                        = $this.ManagedIdentity
                AccessTokens                           = $this.AccessTokens
            })
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

        Write-Verbose -Message 'Setting the O365 Search and Intelligence Configurations'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $ConnectionMode = $this.Connect('ExchangeOnline')
        $ConnectionMode = $this.Connect('MicrosoftGraph')

        $organizationId = $this.TenantId
        if ($ConnectionMode -eq 'Credentials')
        {
            $organizationId = $this.Credential.UserName.Split('@')[1]
        }

        #region Item Insights
        $ItemInsightsUpdateParams = @{
            IsEnabledInOrganization = $this.ItemInsightsIsEnabledInOrganization
        }
        if ($this.GetBoundParameters().ContainsKey('ItemInsightsDisabledForGroup'))
        {
            $disabledForGroupValue = $null
            try
            {
                $group = Get-MgGroup -Filter "DisplayName eq '$($this.ItemInsightsDisabledForGroup -replace "'", "''")'"
                $disabledForGroupValue = $group.Id
            }
            catch
            {
                $this.LogError($_, 'Error retrieving data getting group')

                throw
            }
            $ItemInsightsUpdateParams.Add('DisabledForGroup', $disabledForGroupValue)
        }
        Write-Verbose -Message 'Updating settings for Item Insights'
        Update-MgBetaOrganizationSettingItemInsight -OrganizationId $organizationId -BodyParameter $ItemInsightsUpdateParams | Out-Null
        #endregion

        #region Person Insights
        $PersonInsightsUpdateParams = @{
            IsEnabledInOrganization = $this.PersonInsightsIsEnabledInOrganization
        }
        if ($this.GetBoundParameters().ContainsKey('PersonInsightsDisabledForGroup'))
        {
            $disabledForGroupValue = $null
            try
            {
                $group = Get-MgGroup -Filter "DisplayName eq '$($this.PersonInsightsDisabledForGroup -replace "'", "''")'"
                $disabledForGroupValue = $group.Id
            }
            catch
            {
                $this.LogError($_, 'Error retrieving data getting group')

                throw
            }
            $PersonInsightsUpdateParams.Add('DisabledForGroup', $disabledForGroupValue)
        }

        Write-Verbose -Message 'Updating settings for Person Insights'
        Update-MgBetaOrganizationSettingPersonInsight -OrganizationId $organizationId -BodyParameter $PersonInsightsUpdateParams | Out-Null
        #endregion

        if ($null -ne $this.MeetingInsightsIsEnabledInOrganization)
        {
            Set-MeetingInsightsSettings -Enabled $this.MeetingInsightsIsEnabledInOrganization | Out-Null
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
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }

            $Results = $this.GetForExport($Params)
            $dscContent = [System.Text.StringBuilder]::new()
            if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
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

    hidden [O365SearchAndIntelligenceConfigurations] AsResult([System.Object] $Values)
    {
        if ($Values -is [O365SearchAndIntelligenceConfigurations])
        {
            return $Values
        }

        $result = [O365SearchAndIntelligenceConfigurations]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
