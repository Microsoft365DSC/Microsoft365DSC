using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPORetentionLabelsSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the resource is a single instance, the value must be ''Yes''')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Set whether files with Keep Label can be deleted in OneDrive for Business.')]
    [System.Nullable[System.Boolean]] $AllowFilesWithKeepLabelToBeDeletedODB

    [DscProperty()]
    [System.ComponentModel.Description('Set whether files with Keep Label can be deleted in SharePoint Online.')]
    [System.Nullable[System.Boolean]] $AllowFilesWithKeepLabelToBeDeletedSPO

    [DscProperty()]
    [System.ComponentModel.Description('Set to enable or disable the advanced record versioning.')]
    [System.Nullable[System.Boolean]] $AdvancedRecordVersioningDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Set metadata edit blocking enabled setting.')]
    [System.Nullable[System.Boolean]] $MetadataEditBlockingEnabled

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
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [SPORetentionLabelsSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPORetentionLabelsSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting current SharePoint Online Retention Labels Settings configuration'

        try
        {
            if (-not $this.ResourceCache['ExportMode'])
            {
                $null = $this.Connect('PnP') | Out-Null

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')
            }

            $AllowFilesWithKeepLabelToBeDeletedODBValue = $this.InvokeRetentionLabelsSetting('GetAllowFilesWithKeepLabelToBeDeletedODB')
            $AllowFilesWithKeepLabelToBeDeletedSPOValue = $this.InvokeRetentionLabelsSetting('GetAllowFilesWithKeepLabelToBeDeletedSPO')
            $AdvancedRecordVersioningDisabledValue      = $this.InvokeRetentionLabelsSetting('GetAdvancedRecordVersioningDisabled')
            $MetadataEditBlockingEnabledValue           = $this.InvokeRetentionLabelsSetting('GetMetadataEditBlockingEnabled')
            $results = @{
                IsSingleInstance                      = 'Yes'
                AllowFilesWithKeepLabelToBeDeletedODB = $AllowFilesWithKeepLabelToBeDeletedODBValue
                AllowFilesWithKeepLabelToBeDeletedSPO = $AllowFilesWithKeepLabelToBeDeletedSPOValue
                AdvancedRecordVersioningDisabled      = $AdvancedRecordVersioningDisabledValue
                MetadataEditBlockingEnabled           = $MetadataEditBlockingEnabledValue
                Credential                            = $this.Credential
                ApplicationId                         = $this.ApplicationId
                TenantId                              = $this.TenantId
                CertificateThumbprint                 = $this.CertificateThumbprint
                CertificatePath                       = $this.CertificatePath
                CertificatePassword                   = $this.CertificatePassword
                ManagedIdentity                       = $this.ManagedIdentity
                AccessTokens                          = $this.AccessTokens
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

        Write-Verbose -Message 'Setting SPORetentionLabelsSettings configuration'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        if ($this.AllowFilesWithKeepLabelToBeDeletedODB -ne $currentInstance.AllowFilesWithKeepLabelToBeDeletedODB)
        {
            Write-Verbose -Message "Updating AllowFilesWithKeepLabelToBeDeletedODB with value {$($this.AllowFilesWithKeepLabelToBeDeletedODB)}"
            $null = $this.InvokeRetentionLabelsSetting('SetAllowFilesWithKeepLabelToBeDeletedODB', 'POST', @{allowDeletion = $this.AllowFilesWithKeepLabelToBeDeletedODB })
        }
        if ($this.AllowFilesWithKeepLabelToBeDeletedSPO -ne $currentInstance.AllowFilesWithKeepLabelToBeDeletedSPO)
        {
            Write-Verbose -Message "Updating AllowFilesWithKeepLabelToBeDeletedSPO with value {$($this.AllowFilesWithKeepLabelToBeDeletedSPO)}"
            $null = $this.InvokeRetentionLabelsSetting('SetAllowFilesWithKeepLabelToBeDeletedSPO', 'POST', @{allowDeletion = $this.AllowFilesWithKeepLabelToBeDeletedSPO })
        }
        if ($this.AdvancedRecordVersioningDisabled -ne $currentInstance.AdvancedRecordVersioningDisabled)
        {
            Write-Verbose -Message "Updating AdvancedRecordVersioningDisabled with value {$($this.AdvancedRecordVersioningDisabled)}"
            $null = $this.InvokeRetentionLabelsSetting('SetAdvancedRecordVersioningDisabled', 'POST', @{disabled = $this.AdvancedRecordVersioningDisabled })
        }
        if ($this.MetadataEditBlockingEnabled -ne $currentInstance.MetadataEditBlockingEnabled)
        {
            Write-Verbose -Message "Updating MetadataEditBlockingEnabled with value {$($this.MetadataEditBlockingEnabled)}"
            $null = $this.InvokeRetentionLabelsSetting('SetMetadataEditBlockingEnabled', 'POST', @{enabled = $this.MetadataEditBlockingEnabled })
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

        $ConnectionMode = $this.Connect('PnP')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $this.ResourceCache['ExportMode'] = $true

            $dscContent = [System.Text.StringBuilder]::new()
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }
            $params = @{
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

    hidden [System.Object] InvokeRetentionLabelsSetting([System.String] $CommandName)
    {
        return $this.InvokeRetentionLabelsSetting($CommandName, 'GET', $null)
    }

    hidden [System.Object] InvokeRetentionLabelsSetting([System.String] $CommandName, [System.String] $Method, [System.Collections.Hashtable] $Body)
    {
        try
        {
            $url = $(Get-MSCloudLoginConnectionProfile -Workload 'SharePointOnlineREST').AdminUrl + `
                "/_api/SP.CompliancePolicy.SPPolicyStoreProxy.$($CommandName)/"

            $invokeParams = @{
                Url     = $url
                Method  = $Method
                Content = $Body
            }

            $result = Invoke-PnPSPRestMethod @invokeParams

            if ($Method -eq 'GET')
            {
                return $result.Value
            }
        }
        catch
        {
            throw $_
        }

        return $true
    }

    hidden [SPORetentionLabelsSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPORetentionLabelsSettings])
        {
            return $Values
        }

        $result = [SPORetentionLabelsSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
