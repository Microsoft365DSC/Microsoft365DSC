using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceComplianceScriptWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Optional description for the device compliance script.')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the device compliance script.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Indicate whether the script signature needs be checked.')]
    [System.Nullable[System.Boolean]] $EnforceSignatureCheck

    [DscProperty()]
    [System.ComponentModel.Description('Publisher of the script.')]
    [System.String] $Publisher

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tag IDs for this PowerShellScript instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('A value indicating whether the PowerShell script should run as 32-bit')]
    [System.Nullable[System.Boolean]] $RunAs32Bit

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the type of execution context. Possible values are: system, user.')]
    [ValidateSet('system', 'user')]
    [System.String] $RunAsAccount

    [DscProperty()]
    [System.ComponentModel.Description('The script content in Base64.')]
    [System.String] $DetectionScriptContent

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

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

    [IntuneDeviceComplianceScriptWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceComplianceScriptWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Compliance Script for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $getValue = $null
            #region resource generator code
            if (-not [string]::IsNullOrEmpty($this.Id))
            {
                $getValue = Invoke-M365DSCGraphRequest -Method GET -Uri "/beta/deviceManagement/deviceComplianceScripts/$($this.Id)" -SkipHttpErrorCheck
                if ($null -ne $getValue.error)
                {
                    $getValue = $null
                }
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Intune Device Compliance Script for Windows10 with Id {$($this.Id)}"

                if (-not [string]::IsNullOrEmpty($this.DisplayName))
                {
                    [array]$matchingScripts = (Invoke-M365DSCGraphRequest -Method GET `
                        -Uri "/beta/deviceManagement/deviceComplianceScripts?`$filter=DisplayName eq '$($this.DisplayName -replace "'", "''")' and platform eq 'windows10'").value
                    if ($matchingScripts.Count -gt 0)
                    {
                        $getValue = Invoke-M365DSCGraphRequest -Method GET -Uri "/beta/deviceManagement/deviceComplianceScripts/$($matchingScripts[0].id)"
                    }
                }
            }
            #endregion
            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Intune Device Compliance Script for Windows10 with DisplayName {$($this.DisplayName)}"
                return $this.AsResult($nullResult)
            }
            $resolvedId = $getValue.Id

            Write-Verbose -Message "An Intune Device Compliance Script for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            $results = @{
                #region resource generator code
                Description            = $getValue.Description
                DisplayName            = $getValue.DisplayName
                EnforceSignatureCheck  = $getValue.EnforceSignatureCheck
                RoleScopeTagIds        = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                RunAs32Bit             = $getValue.RunAs32Bit
                RunAsAccount           = $getValue.RunAsAccount
                DetectionScriptContent = $this.DecodeTextPayload($getValue.DetectionScriptContent)
                Publisher              = $getValue.Publisher
                Id                     = $getValue.Id
                Ensure                 = 'Present'
                Credential             = $this.Credential
                ApplicationId          = $this.ApplicationId
                TenantId               = $this.TenantId
                ApplicationSecret      = $this.ApplicationSecret
                CertificateThumbprint  = $this.CertificateThumbprint
                CertificatePath        = $this.CertificatePath
                CertificatePassword    = $this.CertificatePassword
                ManagedIdentity        = $this.ManagedIdentity
                AccessTokens           = $this.AccessTokens
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters.DetectionScriptContent = $this.EncodeTextPayload($boundParameters.DetectionScriptContent)
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Device Compliance Script for Windows10 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null
            $createParameters.Add('platform', 'windows10')
            Invoke-M365DSCGraphRequest -Method POST -Uri '/beta/deviceManagement/deviceComplianceScripts' -Body $($createParameters | ConvertTo-Json)
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Device Compliance Script for Windows10 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            Invoke-M365DSCGraphRequest -Method PATCH -Uri "/beta/deviceManagement/deviceComplianceScripts/$($currentInstance.Id)" -Body $($updateParameters | ConvertTo-Json)
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Device Compliance Script for Windows10 with Id {$($currentInstance.Id)}"
            try
            {
                Invoke-M365DSCGraphRequest -Method DELETE -Uri "/beta/deviceManagement/deviceComplianceScripts/$($currentInstance.Id)" -ErrorAction Stop
            }
            catch
            {
                throw "Failed to delete Intune Device Compliance Script for Windows10 with Id $($currentInstance.Id). Error: $($_.ErrorDetails.Message)"
            }
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
            $uri = '/beta/deviceManagement/deviceComplianceScripts'
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $uri += "?`$filter=$($this.Filter)"
            }
            [array]$getValue = (Invoke-M365DSCGraphRequest `
                    -Method GET `
                    -Uri $uri `
                    -ErrorAction Stop).value
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
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
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

    hidden [IntuneDeviceComplianceScriptWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceComplianceScriptWindows10])
        {
            return $Values
        }

        $result = [IntuneDeviceComplianceScriptWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
