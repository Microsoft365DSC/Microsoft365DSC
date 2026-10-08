using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceComplianceScriptLinux : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Description of the compliance script.')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the compliance script.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The compliance discovery script. Cannot be empty.')]
    [System.String] $DiscoveryScript

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
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

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    IntuneDeviceComplianceScriptLinux() : base()
    {
        $this.ResourceCache['PropertiesToRetrieve'] =  @('id', 'displayName', 'description', 'settingDefinitionId', 'settingInstance')
    }

    [IntuneDeviceComplianceScriptLinux] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceComplianceScriptLinux]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Device Compliance Script for Linux with Id {$($this.Id)} and Name {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                #region resource generator code
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/reusablePolicySettings/$($this.Id)?`$select=$($this.ResourceCache['PropertiesToRetrieve'] -join ',')" `
                        -Method GET `
                        -SkipHttpErrorCheck `
                        -ErrorAction SilentlyContinue
                    if ($getValue -is [hashtable] -and $getValue.ContainsKey('error'))
                    {
                        # Policy does not exist, set it to $null
                        $getValue = $null
                    }
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Compliance Script for Linux with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = (Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/reusablePolicySettings?`$filter=DisplayName eq '$($this.DisplayName -replace "'", "''")' and settingDefinitionId eq 'linux_customcompliance_discoveryscript_reusablesetting'&select=$($this.ResourceCache['PropertiesToRetrieve'] -join ',')" `
                            -Method GET `
                            -SkipHttpErrorCheck `
                            -ErrorAction SilentlyContinue).value
                        if ($getValue -is [array] -and $getValue.Count -eq 0)
                        {
                            $getValue = $null
                        }
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Compliance Script for Linux with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.id
            Write-Verbose -Message "An Intune Device Compliance Script for Linux with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

            $results = @{
                #region resource generator code
                Description           = $getValue.description
                DiscoveryScript       = $this.DecodeTextPayload($getValue.settingInstance.simpleSettingValue.value)
                DisplayName           = $getValue.displayName
                Id                    = $getValue.id
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                #endregion
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

        Write-Verbose -Message "Setting configuration of the Intune Device Compliance Script for Linux with Id {$($this.Id)} and Name {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters.Remove('DiscoveryScript') | Out-Null
        $boundParameters.Add('settingDefinitionId', 'linux_customcompliance_discoveryscript_reusablesetting')
        $boundParameters.Add('settingInstance', @{
                '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                settingDefinitionId = 'linux_customcompliance_discoveryscript_reusablesetting'
                simpleSettingValue  = @{
                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                    value         = $this.EncodeTextPayload($this.DiscoveryScript)
                }
            })

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Device Compliance Script for Linux with Name {$($this.DisplayName)}"

            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $null = Invoke-M365DSCGraphRequest -Uri '/beta/deviceManagement/reusablePolicySettings' -Method POST -Body $($createParameters | ConvertTo-Json -Depth 10)
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Device Compliance Script for Linux with Id {$($currentInstance.Id)}"

            $updateParameters = $boundParameters
            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/reusablePolicySettings/$($currentInstance.Id)" -Method PUT -Body $($updateParameters | ConvertTo-Json -Depth 10)
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Device Compliance Script for Linux with Id {$($currentInstance.Id)}"
            #region resource generator code
            try
            {
                Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/reusablePolicySettings/$($currentInstance.Id)" -Method DELETE
            }
            catch
            {
                $errorMessage = "Failed to remove the Intune Device Compliance Script for Linux with Id {$($currentInstance.Id)} and Name {$($currentInstance.DisplayName)}."
                $errorMessage += ' Please make sure it is not referenced by a Linux compliance policy.'
                throw $errorMessage
            }
            #endregion
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
            #region resource generator code
            [array]$getValue = Get-M365DSCExportCachedCollection -Collection 'reusablePolicySettings' `
                -PropertyName 'settingDefinitionId' `
                -PropertyValue 'linux_customcompliance_discoveryscript_reusablesetting' `
                -Filter $this.Filter
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                elseif (-not [string]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.DisplayName
                    Ensure                = 'Present'
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

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [IntuneDeviceComplianceScriptLinux] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceComplianceScriptLinux])
        {
            return $Values
        }

        $result = [IntuneDeviceComplianceScriptLinux]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
