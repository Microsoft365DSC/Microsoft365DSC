using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOTenantCdnPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Type of Content Delivery Network. Can be ''Private'' or ''Public''.')]
    [ValidateSet('Private', 'Public')]
    [System.String] $CDNType

    [DscProperty()]
    [System.ComponentModel.Description('List of site classifications to exclude.')]
    [System.String[]] $ExcludeRestrictedSiteClassifications

    [DscProperty()]
    [System.ComponentModel.Description('List of file extensions to include in the Policy.')]
    [System.String[]] $IncludeFileExtensions

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Office365 Tenant Admin.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
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

    [SPOTenantCdnPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOTenantCdnPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for SPOTenantCdnPolicy {$($this.CDNType)}"

        try
        {
            if (-not $this.ResourceCache['ExportMode'])
            {
                $null = $this.Connect('PNP')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')
            }

            $Policies = Get-PnPTenantCdnPolicies -CdnType $this.CDNType -ErrorAction Stop

            $excludeRestrictedSiteClassificationsValue = @()
            $includeFileExtensionsValue = @()
            $Policies.GetEnumerator() | ForEach-Object {
                if ($_.Key -eq 'ExcludeRestrictedSiteClassifications' -and $_.Value.Length -gt 0)
                {
                    $excludeRestrictedSiteClassificationsValue = $_.Value.Split(',')
                }
                if ($_.Key -eq 'IncludeFileExtensions' -and $_.Value.Length -gt 0)
                {
                    $includeFileExtensionsValue = $_.Value.Split(',')
                }
            }

            return $this.AsResult(@{
                CDNType                              = $this.CDNType
                ExcludeRestrictedSiteClassifications = $excludeRestrictedSiteClassificationsValue
                IncludeFileExtensions                = $includeFileExtensionsValue
                Credential                           = $this.Credential
                ApplicationId                        = $this.ApplicationId
                TenantId                             = $this.TenantId
                ApplicationSecret                    = $this.ApplicationSecret
                CertificateThumbprint                = $this.CertificateThumbprint
                CertificatePath                      = $this.CertificatePath
                CertificatePassword                  = $this.CertificatePassword
                ManagedIdentity                      = $this.ManagedIdentity
                AccessTokens                         = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration for SPOTenantCdnPolicy {$($this.CDNType)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $curPolicies = $this.Get().ToHashtable()

        if ($null -ne `
            (Compare-Object -ReferenceObject $curPolicies.IncludeFileExtensions -DifferenceObject $this.IncludeFileExtensions))
        {
            Write-Verbose 'Found difference in IncludeFileExtensions'

            $includeFileExtensionsPolicyValue = [String[]]$this.IncludeFileExtensions -join ','
            Set-PnPTenantCdnPolicy -CdnType $this.CDNType `
                -PolicyType 'IncludeFileExtensions' `
                -PolicyValue $includeFileExtensionsPolicyValue
        }

        if ($null -ne (Compare-Object -ReferenceObject $curPolicies.ExcludeRestrictedSiteClassifications `
                    -DifferenceObject $this.ExcludeRestrictedSiteClassifications))
        {
            Write-Verbose 'Found difference in ExcludeRestrictedSiteClassifications'

            $excludeRestrictedSiteClassificationsPolicyValue = [String[]]$this.ExcludeRestrictedSiteClassifications -join ','
            Set-PnPTenantCdnPolicy -CdnType $this.CDNType `
                -PolicyType 'ExcludeRestrictedSiteClassifications' `
                -PolicyValue $excludeRestrictedSiteClassificationsPolicyValue
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

        try
        {
            $ConnectionMode = $this.Connect('PNP')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Export')
            #endregion

            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }
            $this.ResourceCache['ExportMode'] = $true

            $Params = @{
                CdnType               = 'Public'
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                Credential            = $this.Credential
                AccessTokens          = $this.AccessTokens
            }
            $dscContent = [System.Text.StringBuilder]::new()

            Write-M365DSCHost -Message "`r`n    |---[1/2] Public" -DeferWrite
            $Results = $this.GetForExport($Params)
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

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
            }

            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $Params = @{
                CdnType               = 'Private'
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                Credential            = $this.Credential
            }
            Write-M365DSCHost -Message '    |---[2/2] Private' -DeferWrite
            $Results = $this.GetForExport($Params)
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

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
            }

            return $dscContent.ToString()
        }
        catch
        {
            # This method is not implemented in some sovereign clouds (e.g. GCCHigh)
            if ($_.Exception -like '*The method or operation is not implemented*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant does not support this feature."
                return ''
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }
    }

    hidden [SPOTenantCdnPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOTenantCdnPolicy])
        {
            return $Values
        }

        $result = [SPOTenantCdnPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
