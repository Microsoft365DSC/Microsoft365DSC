using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADEntitlementManagementAccessPackageCatalog : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the access package catalog.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The id of the access package catalog.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Has the value Published if the access packages are available for management.')]
    [System.String] $CatalogStatus

    [DscProperty()]
    [System.ComponentModel.Description('One of UserManaged or ServiceDefault.')]
    [ValidateSet('UserManaged', 'ServiceDefault')]
    [System.String] $CatalogType

    [DscProperty()]
    [System.ComponentModel.Description('The description of the access package catalog.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Whether the access packages in this catalog can be requested by users outside of the tenant.')]
    [System.Nullable[System.Boolean]] $IsExternallyVisible

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
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

    [AADEntitlementManagementAccessPackageCatalog] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADEntitlementManagementAccessPackageCatalog]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AzureAD Entitlement Management Access Package Catalog for DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null

                if (-not [System.String]::IsNullOrEmpty($this.id))
                {
                    $getValue = Get-MgBetaEntitlementManagementAccessPackageCatalog -AccessPackageCatalogId $this.id -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    if (-not [System.String]::IsNullOrEmpty($this.Id))
                    {
                        Write-Verbose -Message "No Azure AD Entitlement Management Access Package Catalog with id {$($this.id)} was found"
                    }

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaEntitlementManagementAccessPackageCatalog `
                            -ErrorAction Stop | Where-Object `
                            -FilterScript {
                                $_.DisplayName -eq $this.DisplayName
                            }
                    }
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "No Azure AD Entitlement Management Access Package Catalog with DisplayName {$($this.DisplayName)} was found"
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "An Azure AD Entitlement Management Access Package Catalog with id {$($this.id)} was found"
            $results = @{
                #region resource generator code
                Id                    = $getValue.Id
                CatalogStatus         = $getValue.CatalogStatus
                CatalogType           = $getValue.CatalogType
                Description           = $getValue.Description
                DisplayName           = $getValue.DisplayName
                IsExternallyVisible   = $getValue.IsExternallyVisible
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

        Write-Verbose -Message "Getting configuration of AzureAD Entitlement Management Access Package Catalog for DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating {$($this.DisplayName)}"

            $createParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            $createParameters.Remove('Id') | Out-Null
            $createParameters.Remove('Verbose') | Out-Null

            $createParameters.Add('@odata.type', '#microsoft.graph.accessPackageCatalog')

            #region resource generator code
            $policy = New-MgBetaEntitlementManagementAccessPackageCatalog -BodyParameter $createParameters

            #endregion

        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating {$($this.DisplayName)}"

            $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Remove('Verbose') | Out-Null

            $updateParameters.Add('@odata.type', '#microsoft.graph.accessPackageCatalog')

            #region resource generator code
            Update-MgBetaEntitlementManagementAccessPackageCatalog -BodyParameter $updateParameters `
                -AccessPackageCatalogId $currentInstance.Id

            #endregion

        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing {$($this.DisplayName)}"

            Remove-MgBetaEntitlementManagementAccessPackageCatalog -AccessPackageCatalogId $currentInstance.Id
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
            [array]$packages = Get-MgBetaEntitlementManagementAccessPackage -All -Filter $this.Filter -ErrorAction Stop
            $catalogIds = @()
            foreach ($pkg in $packages)
            {
                if ($null -ne $pkg.CatalogId)
                {
                    $catalogIds += $pkg.CatalogId
                }
            }
            [array]$getValue = $catalogIds | Select-Object -Unique
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

            foreach ($catalogId in $getValue)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $config = Get-MgBetaEntitlementManagementAccessPackageCatalog -AccessPackageCatalogId $catalogId
                $displayedKey = $config.id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }

                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.id
                    DisplayName           = $config.displayName
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

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
            }

            return $dscContent.ToString()
        }
        catch
        {
            if ($_.ErrorDetails.Message -like '*User is not authorized to perform the operation.*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) Tenant does not meet license requirement to extract this component."
                return ''
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }
    }

    hidden [AADEntitlementManagementAccessPackageCatalog] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADEntitlementManagementAccessPackageCatalog])
        {
            return $Values
        }

        $result = [AADEntitlementManagementAccessPackageCatalog]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
