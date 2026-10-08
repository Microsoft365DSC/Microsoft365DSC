using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADConnectorGroupApplicationProxy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name associated with the connectorGroup.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The region the connectorGroup is assigned to and will optimize traffic for. This region can only be set if no connectors or applications are assigned to the connectorGroup. The possible values are: nam (for North America), eur (for Europe), aus (for Australia), asia (for Asia), ind (for India), and unknownFutureValue.')]
    [ValidateSet('nam', 'eur', 'aus', 'asia', 'ind', 'unknownFutureValue')]
    [System.String] $Region

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

    [AADConnectorGroupApplicationProxy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADConnectorGroupApplicationProxy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AzureAD Connector Group Application Proxy for {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                #region resource generator code
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaOnPremisePublishingProfileConnectorGroup -ConnectorGroupId $this.Id -OnPremisesPublishingProfileId 'applicationProxy' -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue -and -not [string]::IsNullOrEmpty($this.Id))
                {
                    Write-Verbose -Message "Could not find an Azure AD Connector Group Application Proxy with Name {$($this.Name)}"
                    if (-not [string]::IsNullOrEmpty($this.Name))
                    {
                        $getValue = Get-MgBetaOnPremisePublishingProfileConnectorGroup -OnPremisesPublishingProfileId 'applicationProxy' -Filter "Name eq '$($this.Name -replace "'", "''")'" -ErrorAction Stop
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Connector Group Application Proxy with Name {$($this.Name)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Azure AD Connector Group Application Proxy with Id {$($resolvedId)} and Name {$($this.Name)} was found"

            #endregion

            $results = @{
                #region resource generator code
                Name                  = $getValue.Name
                Region                = $getValue.Region
                Id                    = $getValue.Id
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
        $DisplayName = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of AzureAD Connector Group Application Proxy for {$($this.Name)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $OnPremisesPublishingProfileId = 'applicationProxy'

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Azure AD Connector Group Application Proxy with Name {$DisplayName}"

            $createParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $policy = New-MgBetaOnPremisePublishingProfileConnectorGroup `
                -OnPremisesPublishingProfileId $OnPremisesPublishingProfileId `
                -BodyParameter $createParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Connector Group Application Proxy with Id {$($currentInstance.Id)}"

            $updateParameters = ([Hashtable]$boundParameters).Clone()
            $updateParameters.Remove('Id') | Out-Null

            Update-MgBetaOnPremisePublishingProfileConnectorGroup `
                -ConnectorGroupId $currentInstance.Id `
                -OnPremisesPublishingProfileId $OnPremisesPublishingProfileId `
                -BodyParameter $updateParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Connector Group Application Proxy with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaOnPremisePublishingProfileConnectorGroup `
                -ConnectorGroupId $currentInstance.Id `
                -OnPremisesPublishingProfileId $OnPremisesPublishingProfileId
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
            [array]$getValue = Get-MgBetaOnPremisePublishingProfileConnectorGroup `
            -All `
            -Filter $this.Filter `
            -OnPremisesPublishingProfileId 'applicationProxy' `
            -ErrorAction Stop
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
                if (-not [string]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
                }

                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    Name                  = $config.Name
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

    hidden [AADConnectorGroupApplicationProxy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADConnectorGroupApplicationProxy])
        {
            return $Values
        }

        $result = [AADConnectorGroupApplicationProxy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
