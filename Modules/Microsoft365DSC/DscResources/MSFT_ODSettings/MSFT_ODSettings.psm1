using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class ODSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Should be set to yes')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The resource quota to apply to the OneDrive sites')]
    [System.Nullable[System.UInt32]] $OneDriveStorageQuota

    [DscProperty()]
    [System.ComponentModel.Description('Number of days after a user''s account is deleted that their OneDrive for Business content will be deleted.')]
    [System.Nullable[System.UInt32]] $OrphanedPersonalSitesRetentionPeriod

    [DscProperty()]
    [System.ComponentModel.Description('Enable guest acess for OneDrive')]
    [System.Nullable[System.Boolean]] $OneDriveForGuestsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Turn notifications on/off OneDrive')]
    [System.Nullable[System.Boolean]] $NotificationsInOneDriveForBusinessEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Lets administrators set policy on re-sharing behavior in OneDrive for Business')]
    [ValidateSet('On', 'Off', 'Unspecified')]
    [System.String] $ODBMembersCanShare

    [DscProperty()]
    [System.ComponentModel.Description('Lets administrators set policy on access requests and requests to share in OneDrive for Business')]
    [ValidateSet('On', 'Off', 'Unspecified')]
    [System.String] $ODBAccessRequests

    [DscProperty()]
    [System.ComponentModel.Description('Block sync client on Mac')]
    [System.Nullable[System.Boolean]] $BlockMacSync

    [DscProperty()]
    [System.ComponentModel.Description('Disable dialog box')]
    [System.Nullable[System.Boolean]] $DisableReportProblemDialog

    [DscProperty()]
    [System.ComponentModel.Description('Enable/disable Safe domain List - if disabled overrides DomainGuids value')]
    [System.Nullable[System.Boolean]] $TenantRestrictionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Safe domain list')]
    [System.String[]] $DomainGuids

    [DscProperty()]
    [System.ComponentModel.Description('Exclude files from being synced to OneDrive')]
    [System.String[]] $ExcludedFileExtensions

    [DscProperty()]
    [System.ComponentModel.Description('Groove block options')]
    [ValidateSet('OptOut', 'HardOptIn', 'SoftOptIn')]
    [System.String] $GrooveBlockOption

    [DscProperty()]
    [System.ComponentModel.Description('Allows configuration on Add shortcut to OneDrive feature in SharePoint document libraries. If set to $true, then this feature will be disabled on all sites in the tenant. If set to $false, it will be enabled on all sites in the tenant.')]
    [System.Nullable[System.Boolean]] $DisableAddToOneDrive

    [DscProperty()]
    [System.ComponentModel.Description('Allows configuring whether display name of people who view the file are visible in the property pane of the site in OneDrive for business sites.')]
    [System.Nullable[System.Boolean]] $DisplayNamesOfFileViewers

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the account to authenticate with.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

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

    [ODSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [ODSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of OneDrive Settings'

        try
        {
            $null = $this.Connect('PnP')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            Write-Verbose -Message 'Getting OneDrive quota size for tenant'
            $tenant = Get-PnPTenant -ErrorAction Stop

            if ($null -eq $tenant)
            {
                throw 'Failed to get Tenant information'
            }

            Write-Verbose -Message "Getting OneDrive quota size for tenant $($tenant.OneDriveStorageQuota)"
            Write-Verbose -Message 'Getting tenant client sync setting'
            $tenantRestrictions = Get-PnPTenantSyncClientRestriction -ErrorAction Stop

            if ($null -eq $tenantRestrictions)
            {
                throw 'Failed to get Tenant client sync settings!'
            }

            $GrooveOption = $null

            if (($tenantRestrictions.OptOutOfGrooveBlock -eq $true) -and ($tenantRestrictions.OptOutOfGrooveSoftBlock -eq $false))
            {
                $GrooveOption = 'SoftOptIn'
            }

            if (($tenantRestrictions.OptOutOfGrooveBlock -eq $false) -and ($tenantRestrictions.OptOutOfGrooveSoftBlock -eq $true))
            {
                $GrooveOption = 'HardOptIn'
            }

            if (($tenantRestrictions.OptOutOfGrooveBlock -eq $true) -and ($tenantRestrictions.OptOutOfGrooveSoftBlock -eq $true))
            {
                $GrooveOption = 'OptOut'
            }

            $FixedExcludedFileExtensions = $tenantRestrictions.ExcludedFileExtensions
            if ($FixedExcludedFileExtensions.Count -eq 0 -or
                ($FixedExcludedFileExtensions.Count -eq 1 -and $FixedExcludedFileExtensions[0] -eq ''))
            {
                $FixedExcludedFileExtensions = @()
            }

            $FixedAllowedDomainList = @($tenantRestrictions.AllowedDomainList | ForEach-Object {
                $_.ToString()
            })
            if ($FixedAllowedDomainList.Count -eq 0 -or
                ($FixedAllowedDomainList.Count -eq 1 -and $FixedAllowedDomainList[0] -eq ''))
            {
                $FixedAllowedDomainList = @()
            }

            $ODBMembersCanShareValue = $tenant.ODBMembersCanShare
            if ([System.String]::IsNullOrEmpty($ODBMembersCanShareValue))
            {
                $ODBMembersCanShareValue = 'Unspecified'
            }
            return $this.AsResult(@{
                IsSingleInstance                          = 'Yes'
                BlockMacSync                              = $tenantRestrictions.BlockMacSync
                DisableReportProblemDialog                = $tenantRestrictions.DisableReportProblemDialog
                TenantRestrictionEnabled                  = $tenantRestrictions.TenantRestrictionEnabled
                DomainGuids                               = $FixedAllowedDomainList
                ExcludedFileExtensions                    = $FixedExcludedFileExtensions
                GrooveBlockOption                         = $GrooveOption
                DisableAddToOneDrive                      = $tenant.DisableAddToOneDrive
                DisplayNamesOfFileViewers                 = $tenant.DisplayNamesOfFileViewers
                OneDriveStorageQuota                      = $tenant.OneDriveStorageQuota
                OrphanedPersonalSitesRetentionPeriod      = $tenant.OrphanedPersonalSitesRetentionPeriod
                OneDriveForGuestsEnabled                  = $tenant.OneDriveForGuestsEnabled
                ODBAccessRequests                         = $tenant.ODBAccessRequests
                ODBMembersCanShare                        = $ODBMembersCanShareValue
                NotificationsInOneDriveForBusinessEnabled = $tenant.NotificationsInOneDriveForBusinessEnabled
                ApplicationId                             = $this.ApplicationId
                TenantId                                  = $this.TenantId
                CertificatePassword                       = $this.CertificatePassword
                CertificatePath                           = $this.CertificatePath
                CertificateThumbprint                     = $this.CertificateThumbprint
                Credential                                = $this.Credential
                ManagedIdentity                           = $this.ManagedIdentity
                AccessTokens                              = $this.AccessTokens
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

        Write-Verbose -Message 'Setting configuration of OneDrive Settings'

        $null = $this.Connect('PnP')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('PnP')

        ## Configure OneDrive settings
        ## Parameters below are remove for the Set-SPOTenant cmdlet
        ## they are used in the Set-SPOTenantSyncClientRestriction cmdlet
        $CurrentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $Options = @{}

        if ($CurrentParameters.ContainsKey('BlockMacSync'))
        {
            $Options.Add('BlockMacSync', $CurrentParameters.BlockMacSync)
            $CurrentParameters.Remove('BlockMacSync') | Out-Null
        }
        # set the TenantRestrictionEnabled and DomainGuids values to avoid invalid configurations
        $tenantRestrictionEnabledValue = $this.TenantRestrictionEnabled
        $domainGuidsValue = $this.DomainGuids
        if ($this.TenantRestrictionEnabled -eq $true)
        {
            if (!($CurrentParameters.ContainsKey('DomainGuids') -and ($CurrentParameters.DomainGuids.Count -gt 0) -and ($CurrentParameters.DomainGuids[0] -ne '') ))
            {
                Write-Verbose -Message 'Invalid configuration specified: TenantRestrictionEnabled is True but No DomainGuids Specified, this option will not be enabled'
                $tenantRestrictionEnabledValue = $false
                $domainGuidsValue = @()

            }
            $CurrentParameters.Remove('TenantRestrictionEnabled') | Out-Null
        }
        else
        {
            if ($CurrentParameters.ContainsKey('TenantRestrictionEnabled'))
            {
                if ($CurrentParameters.ContainsKey('DomainGuids') -and ($CurrentParameters.DomainGuids.Count -gt 0) -and ($CurrentParameters.DomainGuids[0] -ne '') )
                {
                    Write-Verbose -Message 'DomainGuids have been Specified but TenantRestrictionEnabled is set to False, DomainGuids value will be ignored'
                    $tenantRestrictionEnabledValue = $false
                    $domainGuidsValue = @()

                }
                else
                {
                    $tenantRestrictionEnabledValue = $false
                    $domainGuidsValue = @()
                }
                $CurrentParameters.Remove('TenantRestrictionEnabled') | Out-Null
            }
            else
            {
                if ($CurrentParameters.ContainsKey('DomainGuids') -and ($CurrentParameters.DomainGuids.Count -gt 0) -and ($CurrentParameters.DomainGuids[0] -ne '') )
                {
                    Write-Verbose -Message 'TenantRestrictionEnabled value not specified but a valid DomainGuids value is present - TenantRestrictionEnabled will be set to true'
                    $tenantRestrictionEnabledValue = $true
                    $domainGuidsValue = $CurrentParameters.DomainGuids
                }
                else
                {
                    Write-Verbose -Message 'TenantRestrictionEnabled value not specified - No valid DomainGuids value is present - TenantRestrictionEnabled will be set to False'
                    $tenantRestrictionEnabledValue = $false
                    $domainGuidsValue = @()
                }
            }
        }

        if ($CurrentParameters.ContainsKey('DomainGuids'))
        {
            $CurrentParameters.Remove('DomainGuids') | Out-Null
        }

        $Options.Add('DomainGuids', [System.Guid[]]$domainGuidsValue)
        $Options.Add('Enable', $tenantRestrictionEnabledValue)

        if ($CurrentParameters.ContainsKey('DisableReportProblemDialog'))
        {
            $Options.Add('DisableReportProblemDialog', $CurrentParameters.DisableReportProblemDialog)
            $CurrentParameters.Remove('DisableReportProblemDialog') | Out-Null
        }
        if ($CurrentParameters.ContainsKey('ExcludedFileExtensions'))
        {
            $Options.Add('ExcludedFileExtensions', $CurrentParameters.ExcludedFileExtensions)
            $CurrentParameters.Remove('ExcludedFileExtensions') | Out-Null
        }
        if ($CurrentParameters.ContainsKey('GrooveBlockOption'))
        {
            $Options.Add('GrooveBlockOption', $CurrentParameters.GrooveBlockOption)
            $CurrentParameters.Remove('GrooveBlockOption') | Out-Null
        }
        if ($CurrentParameters.ContainsKey('IsSingleInstance'))
        {
            $CurrentParameters.Remove('IsSingleInstance') | Out-Null
        }

        Write-Verbose -Message 'Configuring OneDrive settings.'
        Set-PnPTenant @CurrentParameters -Force

        ## Configure Sync Client restrictions
        ## Set-SPOTenantSyncClientRestriction has different parameter sets and they cannot be combined see article:
        ## https://docs.microsoft.com/en-us/powershell/module/sharepoint-online/set-spotenantsyncclientrestriction?view=sharepoint-ps
        Write-Verbose -Message 'Setting other configuration parameters'
        Write-Verbose -Message ($Options | Out-String)

        Set-PnPTenantSyncClientRestriction @Options
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
            $ConnectionMode = $this.Connect('PnP')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Export')
            #endregion

            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $Params = @{
                IsSingleInstance      = 'Yes'
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                Credential            = $this.Credential
                AccessTokens          = $this.AccessTokens
            }

            $Results = $this.GetForExport($Params)
            if ([System.String]::IsNullOrEmpty($Results.GrooveBlockOption))
            {
                $Results.Remove('GrooveBlockOption') | Out-Null
            }

            $dscContent = [System.Text.StringBuilder]::new()
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

    hidden [ODSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [ODSettings])
        {
            return $Values
        }

        $result = [ODSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
