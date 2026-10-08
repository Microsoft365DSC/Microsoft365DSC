using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceCategory : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the device category.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the device category.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Optional role scope tags for the device category.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the category exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
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

    [IntuneDeviceCategory] Get()
    {
        $Identity = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceCategory]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Category {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $category = Get-MgBetaDeviceManagementDeviceCategory -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" -All
                if ($null -eq $category)
                {
                    Write-Verbose -Message "No Device Category with DisplayName {$($this.DisplayName)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $category = $this.ExportedInstance
            }

            Write-Verbose -Message "Found Device Category with Identity {$Identity}"
            return $this.AsResult(@{
                DisplayName           = $category.DisplayName
                Description           = $category.Description
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $category.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
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

        Write-Verbose -Message "Updating the Intune Device Category with DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentCategory = $this.Get().ToHashtable()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($null -ne $resolvedRoleScopeTagIds)
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $resolvedRoleScopeTagIds
        }

        if ($this.Ensure -eq 'Present' -and $currentCategory.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Device Category {$($this.DisplayName)}"
            $createParameters = @{
                DisplayName = $this.DisplayName
                Description = $this.Description
            }
            if ($null -ne $resolvedRoleScopeTagIds)
            {
                $createParameters.RoleScopeTagIds = $resolvedRoleScopeTagIds
            }
            New-MgBetaDeviceManagementDeviceCategory @createParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $currentCategory.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating Device Category {$($this.DisplayName)}"
            $category = Get-MgBetaDeviceManagementDeviceCategory -All -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'"
            $updateParameters = @{
                DeviceCategoryId = $category.id
                DisplayName      = $this.DisplayName
                Description      = $this.Description
            }
            if ($null -ne $resolvedRoleScopeTagIds)
            {
                $updateParameters.RoleScopeTagIds = $resolvedRoleScopeTagIds
            }
            Update-MgBetaDeviceManagementDeviceCategory @updateParameters
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentCategory.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Device Category {$($this.DisplayName)}"
            $category = Get-MgBetaDeviceManagementDeviceCategory -All -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'"
            Remove-MgBetaDeviceManagementDeviceCategory -DeviceCategoryId $category.id
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
            [array]$categories = Get-MgBetaDeviceManagementDeviceCategory -All -Filter $this.Filter -ErrorAction Stop
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($categories.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($category in $categories)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($categories.Count)] $($category.displayName)" -DeferWrite
                $params = @{
                    DisplayName           = $category.displayName
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    ApplicationSecret     = $this.ApplicationSecret
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $category
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
            if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                    $_.Exception -like '*Request not applicable to target tenant*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }

        # Every code path must return in a method with a declared return type.
        return ''
    }

    hidden [IntuneDeviceCategory] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceCategory])
        {
            return $Values
        }

        $result = [IntuneDeviceCategory]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
