using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADGroupsNamingPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Prefixes and suffixes to add to the group name.')]
    [System.String] $PrefixSuffixNamingRequirement

    [DscProperty()]
    [System.ComponentModel.Description('Comma delimited list of words that should be blocked from being included in groups'' names.')]
    [System.String[]] $CustomBlockedWordsList

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

    [AADGroupsNamingPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADGroupsNamingPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of AzureAD Groups Naming Policy'

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
                Write-Verbose 'Found existing AzureAD Groups Naming Policy'
                $valuePrefix = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'PrefixSuffixNamingRequirement' }
                $valueBlockedWords = $Policy.Values | Where-Object -FilterScript { $_.Name -eq 'CustomBlockedWordsList' }
                $customBlockedWordsListValue = @()
                if (-not [System.String]::IsNullOrEmpty($valueBlockedWords.Value))
                {
                    foreach ($word in $valueBlockedWords.Value.Split(',') | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })
                    {
                        $customBlockedWordsListValue += $word
                    }
                }
                $result = @{
                    IsSingleInstance              = 'Yes'
                    PrefixSuffixNamingRequirement = $valuePrefix.Value
                    CustomBlockedWordsList        = $customBlockedWordsListValue
                    Ensure                        = 'Present'
                    Credential                    = $this.Credential
                    ApplicationId                 = $this.ApplicationId
                    TenantId                      = $this.TenantId
                    ApplicationSecret             = $this.ApplicationSecret
                    CertificateThumbprint         = $this.CertificateThumbprint
                    ManagedIdentity               = $this.ManagedIdentity
                    AccessTokens                  = $this.AccessTokens
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

        Write-Verbose -Message 'Setting configuration of Azure AD Groups Naming Policy'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentPolicy = $this.Get().ToHashtable()

        # Policy should exist but it doesn't
        $needToUpdate = $false
        if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message 'Creating new Groups Naming Policy'
            $Policy = New-MgBetaDirectorySetting -TemplateId '62375ab9-6b52-47ed-826b-58e47e0e304b' | Out-Null
            $needToUpdate = $true
        }

        if ($null -eq $Policy)
        {
            $Policy = Get-MgBetaDirectorySetting | Where-Object -FilterScript { $_.DisplayName -eq 'Group.Unified' }
        }

        if (($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present') -or $needToUpdate)
        {

            [string]$blockedWordsValue = $null
            $blockedWordsValue = $this.CustomBlockedWordsList -join ','

            $index = 0
            foreach ($property in $Policy.Values)
            {
                if ($property.Name -eq 'CustomBlockedWordsList')
                {
                    $Policy.Values[$index].Value = $blockedWordsValue
                }
                elseif ($property.Name -eq 'PrefixSuffixNamingRequirement')
                {
                    $Policy.Values[$index].Value = $this.PrefixSuffixNamingRequirement
                }
                $index++
            }
            Write-Verbose -Message "Updating Groups Naming Policy to {$($Policy.Values -join ',')}"
            Update-MgBetaDirectorySetting -DirectorySettingId $Policy.id -Values $Policy.Values | Out-Null
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing existing Groups Naming Policy {$($policy.Id)}"
            $Policy = Get-MgBetaDirectorySetting | Where-Object -FilterScript { $_.DisplayName -eq 'Group.Unified' }
            Remove-MgBetaDirectorySetting -DirectorySettingId $policy.Id | Out-Null
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $currentDSCBlock = $null
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

            $Results = $this.GetForExport($Params)
            if ($Results.Ensure -eq 'Present')
            {
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                [void]$dscContent.Append($currentDSCBlock)
            }

            if ($currentDSCBlock)
            {
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

    hidden [AADGroupsNamingPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADGroupsNamingPolicy])
        {
            return $Values
        }

        $result = [AADGroupsNamingPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
