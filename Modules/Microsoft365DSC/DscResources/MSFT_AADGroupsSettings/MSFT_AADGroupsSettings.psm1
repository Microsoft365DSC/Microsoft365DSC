using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADGroupsSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The flag indicating whether Office 365 group creation is allowed in the directory by non-admin users. This setting does not require an Azure Active Directory Premium P1 license.')]
    [System.Nullable[System.Boolean]] $EnableGroupCreation

    [DscProperty()]
    [System.ComponentModel.Description('Boolean indicating whether or not sensitivity labels can be assigned to M365-groups.')]
    [System.Nullable[System.Boolean]] $EnableMIPLabels

    [DscProperty()]
    [System.ComponentModel.Description('Boolean indicating whether or not a guest user can be an owner of groups.')]
    [System.Nullable[System.Boolean]] $AllowGuestsToBeGroupOwner

    [DscProperty()]
    [System.ComponentModel.Description('Boolean indicating whether or not a guest user can have access to Office 365 groups content. This setting does not require an Azure Active Directory Premium P1 license.')]
    [System.Nullable[System.Boolean]] $AllowGuestsToAccessGroups

    [DscProperty()]
    [System.ComponentModel.Description('The url of a link to the guest usage guidelines.')]
    [System.String] $GuestUsageGuidelinesUrl

    [DscProperty()]
    [System.ComponentModel.Description('Name of the security group for which the members are allowed to create Office 365 groups even when EnableGroupCreation == false.')]
    [System.String] $GroupCreationAllowedGroupName

    [DscProperty()]
    [System.ComponentModel.Description('A boolean indicating whether or not is allowed to add guests to this directory.')]
    [System.Nullable[System.Boolean]] $AllowToAddGuests

    [DscProperty()]
    [System.ComponentModel.Description('A link to the Group Usage Guidelines.')]
    [System.String] $UsageGuidelinesUrl

    [DscProperty()]
    [System.ComponentModel.Description('Boolean, a tenant-wide setting that assigns the default value to the writebackConfiguration/isEnabled property of new groups, if the property isn''t specified during group creation. This setting is applicable when group writeback is configured in Microsoft Entra Connect.')]
    [System.Nullable[System.Boolean]] $NewUnifiedGroupWritebackDefault

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Azure AD Groups Naming Policy should exist or not.')]
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

    [AADGroupsSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADGroupsSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of AzureAD Groups Settings'
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
            $Policy = Get-MgBetaDirectorySetting | Where-Object -FilterScript { $_.DisplayName -eq 'Group.Unified' }

            if ($null -eq $Policy)
            {
                return $this.AsResult($nullReturn)
            }
            else
            {
                Write-Verbose -Message 'Found existing AzureAD DirectorySetting for Group.Unified'
                $AllowedGroupName = $null
                $GroupCreationValue = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'GroupCreationAllowedGroupId' }
                if (-not [System.String]::IsNullOrEmpty($GroupCreationValue.Value))
                {
                    $groupObject = Get-MgGroup -GroupId $GroupCreationValue.Value -ErrorAction SilentlyContinue
                    $AllowedGroupName = $null
                    if ($groupObject)
                    {
                        $AllowedGroupName = $groupObject.DisplayName
                    }
                }

                $valueEnableGroupCreation = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'EnableGroupCreation' }
                $valueEnableMIPLabels = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'EnableMIPLabels' }
                $valueAllowGuestsToBeGroupOwner = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'AllowGuestsToBeGroupOwner' }
                $valueAllowGuestsToAccessGroups = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'AllowGuestsToAccessGroups' }
                $valueGuestUsageGuidelinesUrl = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'GuestUsageGuidelinesUrl' }
                $valueAllowToAddGuests = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'AllowToAddGuests' }
                $valueUsageGuidelinesUrl = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'UsageGuidelinesUrl' }
                $valueNewUnifiedGroupWritebackDefault = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'NewUnifiedGroupWritebackDefault' }

                $result = @{
                    IsSingleInstance          = 'Yes'
                    EnableGroupCreation       = [Boolean]::Parse($valueEnableGroupCreation.Value)
                    EnableMIPLabels           = [Boolean]::Parse($valueEnableMIPLabels.Value)
                    AllowGuestsToBeGroupOwner = [Boolean]::Parse($valueAllowGuestsToBeGroupOwner.Value)
                    AllowGuestsToAccessGroups = [Boolean]::Parse($valueAllowGuestsToAccessGroups.Value)
                    GuestUsageGuidelinesUrl   = $valueGuestUsageGuidelinesUrl.Value
                    AllowToAddGuests          = [Boolean]::Parse($valueAllowToAddGuests.Value)
                    UsageGuidelinesUrl        = $valueUsageGuidelinesUrl.Value
                    Ensure                    = 'Present'
                    ApplicationId             = $this.ApplicationId
                    TenantId                  = $this.TenantId
                    ApplicationSecret         = $this.ApplicationSecret
                    CertificateThumbprint     = $this.CertificateThumbprint
                    Credential                = $this.Credential
                    ManagedIdentity           = $this.ManagedIdentity
                    AccessTokens              = $this.AccessTokens
                }
                if (-not [System.String]::IsNullOrEmpty($valueNewUnifiedGroupWritebackDefault.Value))
                {
                    $result.Add('NewUnifiedGroupWritebackDefault', [Boolean]::Parse($valueNewUnifiedGroupWritebackDefault.Value))
                }

                if (-not [System.String]::IsNullOrEmpty($AllowedGroupName))
                {
                    $result.Add('GroupCreationAllowedGroupName', $AllowedGroupName)
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
        $Policy = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message 'Setting configuration of Azure AD Groups Settings'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentPolicy = $this.Get().ToHashtable()

        # Policy should exist but it doesn't
        $needToUpdate = $false
        if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
        {
            $Policy = New-MgBetaDirectorySetting -TemplateId '62375ab9-6b52-47ed-826b-58e47e0e304b' | Out-Null
            $needToUpdate = $true
        }
        elseif ($currentPolicy.Ensure -eq 'Present')
        {
            $Policy = Get-MgBetaDirectorySetting -All | Where-Object -FilterScript { $_.DisplayName -eq 'Group.Unified' }
        }

        if (($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present') -or $needToUpdate)
        {
            $groupObject = $null
            if (-not [System.String]::IsNullOrEmpty($this.GroupCreationAllowedGroupName))
            {
                $groupObject = Get-MgGroup -Filter "DisplayName eq '$($this.GroupCreationAllowedGroupName -replace "'", "''")'"
            }
            $groupId = $null
            if ($null -ne $groupObject)
            {
                $groupId = $groupObject.Id
            }

            $index = 0
            $newValues = $Policy.Values
            foreach ($property in $newValues)
            {
                if ($property.Name -eq 'EnableGroupCreation')
                {
                    $entry = $newValues | Where-Object -FilterScript { $_.Name -eq 'EnableGroupCreation' }
                    $entry.value = $this.EnableGroupCreation.ToString().ToLower()
                }
                elseif ($property.Name -eq 'EnableMIPLabels')
                {
                    $entry = $newValues | Where-Object -FilterScript { $_.Name -eq 'EnableMIPLabels' }
                    $entry.value = $this.EnableMIPLabels.ToString().ToLower()
                }
                elseif ($property.Name -eq 'AllowGuestsToBeGroupOwner')
                {
                    $entry = $newValues | Where-Object -FilterScript { $_.Name -eq 'AllowGuestsToBeGroupOwner' }
                    $entry.value = $this.AllowGuestsToBeGroupOwner.ToString().ToLower()
                }
                elseif ($property.Name -eq 'AllowGuestsToAccessGroups')
                {
                    $entry = $newValues | Where-Object -FilterScript { $_.Name -eq 'AllowGuestsToAccessGroups' }
                    $entry.value = $this.AllowGuestsToAccessGroups.ToString().ToLower()
                }
                elseif ($property.Name -eq 'GuestUsageGuidelinesUrl')
                {
                    $entry = $newValues | Where-Object -FilterScript { $_.Name -eq 'GuestUsageGuidelinesUrl' }
                    $entry.value = $this.GuestUsageGuidelinesUrl
                }
                elseif ($property.Name -eq 'GroupCreationAllowedGroupId')
                {
                    $entry = $newValues | Where-Object -FilterScript { $_.Name -eq 'GroupCreationAllowedGroupId' }
                    $entry.value = [System.String]$groupId
                }
                elseif ($property.Name -eq 'AllowToAddGuests')
                {
                    $entry = $newValues | Where-Object -FilterScript { $_.Name -eq 'AllowToAddGuests' }
                    $entry.value = $this.AllowToAddGuests.ToString().ToLower()
                }
                elseif ($property.Name -eq 'UsageGuidelinesUrl')
                {
                    $entry = $newValues | Where-Object -FilterScript { $_.Name -eq 'UsageGuidelinesUrl' }
                    $entry.value = $this.UsageGuidelinesUrl
                }
                elseif ($property.Name -eq 'NewUnifiedGroupWritebackDefault')
                {
                    $entry = $newValues | Where-Object -FilterScript { $_.Name -eq 'NewUnifiedGroupWritebackDefault' }
                    $newUnifiedGroupWritebackDefaultValue = $this.NewUnifiedGroupWritebackDefault
                    if ($null -eq $newUnifiedGroupWritebackDefaultValue)
                    {
                        $newUnifiedGroupWritebackDefaultValue = $false
                    }
                    $entry.value = $newUnifiedGroupWritebackDefaultValue.ToString().ToLower()
                }
                $index++
            }

            $body = @{
                values = $newValues
            }
            Write-Verbose -Message "Updating Policy's Values with $($body | ConvertTo-Json -Depth 10)"
            Invoke-M365DSCCommand -ScriptBlock  {
                Update-MgBetaDirectorySetting -DirectorySettingId $Policy.id -BodyParameter $body
            } -RetryOnNotFoundError

        }
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "An existing Directory Setting entry exists, and we don't allow to have it removed."
            throw 'The AADGroupsSettings resource cannot delete existing Directory Setting entries. Please specify Present.'
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
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADGroupsSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADGroupsSettings])
        {
            return $Values
        }

        $result = [AADGroupsSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
