using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADEntitlementManagementConnectedOrganization : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the connected organization.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the Connected organization object.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The description of the connected organization.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The identity sources in this connected organization.')]
    [MSFT_AADEntitlementManagementConnectedOrganizationIdentitySource[]] $IdentitySources

    [DscProperty()]
    [System.ComponentModel.Description('The state of a connected organization defines whether assignment policies with requestor scope type AllConfiguredConnectedOrganizationSubjects are applicable or not.')]
    [ValidateSet('configured', 'proposed', 'unknownFutureValue')]
    [System.String] $State

    [DscProperty()]
    [System.ComponentModel.Description('Collection of objectID of external sponsors. the sponsor can be a user or a group.')]
    [System.String[]] $ExternalSponsors

    [DscProperty()]
    [System.ComponentModel.Description('Collection of objectID of internal sponsors. the sponsor can be a user or a group.')]
    [System.String[]] $InternalSponsors

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

    [AADEntitlementManagementConnectedOrganization] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADEntitlementManagementConnectedOrganization]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AzureAD Entitlement Management Connected Organization for DisplayName {$($this.DisplayName)}"

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

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaEntitlementManagementConnectedOrganization -ConnectedOrganizationId $this.Id `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    if (-not [System.String]::IsNullOrEmpty($this.Id))
                    {
                        Write-Verbose -Message "Entitlement Management Connected Organization with id {$($this.Id)} was not found."
                    }

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaEntitlementManagementConnectedOrganization `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Entitlement Management Connected Organization with displayName {$($this.DisplayName)} was not found."
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "Entitlement Management Connected Organization with id {$($getValue.id)} and displayName {$($getValue.DisplayName)} was found."
            [Array]$getExternalSponsors = Get-MgBetaEntitlementManagementConnectedOrganizationExternalSponsor -ConnectedOrganizationId $getValue.id

            $ExternalSponsorsValues = @()
            if ($null -ne $getExternalSponsors -and $getExternalSponsors.Count -gt 0)
            {
                foreach ($sponsor in $getExternalSponsors)
                {
                    if ($sponsor.'@odata.type' -eq '#microsoft.graph.user')
                    {
                        $ExternalSponsorsValues += $sponsor.userPrincipalName
                    }
                    elseif ($sponsor.'@odata.type' -eq '#microsoft.graph.group')
                    {
                        $ExternalSponsorsValues += $sponsor.displayName
                    }
                }
            }

            [Array]$getInternalSponsors = Get-MgBetaEntitlementManagementConnectedOrganizationInternalSponsor -ConnectedOrganizationId $getValue.id

            $InternalSponsorsValues = @()
            if ($null -ne $getInternalSponsors -and $getInternalSponsors.Count -gt 0)
            {
                foreach ($sponsor in $getInternalSponsors)
                {
                    if ($sponsor.'@odata.type' -eq '#microsoft.graph.user')
                    {
                        $InternalSponsorsValues += $sponsor.userPrincipalName
                    }
                    elseif ($sponsor.'@odata.type' -eq '#microsoft.graph.group')
                    {
                        $InternalSponsorsValues += $sponsor.displayName
                    }
                }
            }

            $getIdentitySources = $null
            if ($null -ne $getValue.IdentitySources)
            {
                $sources = @()
                foreach ($source in $getValue.IdentitySources)
                {
                    $formattedSource = @{
                        odataType = $source.'@odata.type'
                    }

                    if (-not [String]::IsNullOrEmpty($source.displayName))
                    {
                        $formattedSource.Add('DisplayName', $source.displayName)
                    }

                    if (-not [String]::IsNullOrEmpty($source.tenantId))
                    {
                        $formattedSource.Add('ExternalTenantId', $source.tenantId)
                    }

                    if (-not [String]::IsNullOrEmpty($source.cloudInstance))
                    {
                        $formattedSource.Add('CloudInstance', $source.cloudInstance)
                    }

                    if (-not [String]::IsNullOrEmpty($source.domainName))
                    {
                        $formattedSource.Add('DomainName', $source.domainName)
                    }

                    if (-not [String]::IsNullOrEmpty($source.issuerUri))
                    {
                        $formattedSource.Add('IssuerUri', $source.issuerUri)
                    }
                    $sources += $formattedSource
                }
                $getIdentitySources = $sources
            }

            $results = @{
                Id                    = $getValue.id
                Description           = $getValue.description
                DisplayName           = $getValue.displayName
                ExternalSponsors      = $ExternalSponsorsValues
                IdentitySources       = $getIdentitySources
                InternalSponsors      = $InternalSponsorsValues
                State                 = $getValue.state
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

        Write-Verbose -Message "Setting configuration of AzureAD Entitlement Management Connected Organization for DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $keyToRename = @{
            'odataType'        = '@odata.type'
            'ExternalTenantId' = 'tenantId'
        }

        $ExternalSponsorsValues = @()
        $InternalSponsorsValues = @()
        if ($this.Ensure -eq 'Present')
        {
            foreach ($sponsor in $this.ExternalSponsors)
            {
                if (-not [System.Guid]::TryParse($sponsor, [ref][System.Guid]::Empty))
                {
                    try
                    {
                        $user = Get-MgUser -UserId $sponsor -ErrorAction SilentlyContinue
                        if ($null -ne $user)
                        {
                            $ExternalSponsorsValues += $user.Id
                        }
                        else
                        {
                            $group = Get-MgGroup -Filter "displayName eq '$sponsor'" -ErrorAction SilentlyContinue
                            if ($null -ne $group)
                            {
                                $ExternalSponsorsValues += $group.Id
                            }
                            else
                            {
                                Write-Verbose -Message "Could not find External Sponsor {$sponsor}"
                            }
                        }
                    }
                    catch
                    {
                        Write-Verbose -Message "Could not find External Sponsor {$sponsor}"
                    }
                }
                else
                {
                    $ExternalSponsorsValues += $sponsor
                }
            }
            foreach ($sponsor in $this.InternalSponsors)
            {
                if (-not [System.Guid]::TryParse($sponsor, [ref][System.Guid]::Empty))
                {
                    try
                    {
                        $user = Get-MgUser -UserId $sponsor -ErrorAction SilentlyContinue
                        if ($null -ne $user)
                        {
                            $InternalSponsorsValues += $user.Id
                        }
                        else
                        {
                            $group = Get-MgGroup -Filter "displayName eq '$sponsor'" -ErrorAction SilentlyContinue
                            if ($null -ne $group)
                            {
                                $InternalSponsorsValues += $group.Id
                            }
                            else
                            {
                                Write-Verbose -Message "Could not find Internal Sponsor {$sponsor}"
                            }
                        }
                    }
                    catch
                    {
                        Write-Verbose -Message "Could not find Internal Sponsor {$sponsor}"
                    }
                }
                else
                {
                    $InternalSponsorsValues += $sponsor
                }
            }
        }

        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters -KeyMapping $keyToRename

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a new Entitlement Management Connected Organization {$($this.DisplayName)}"

            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null
            $createParameters.Remove('ExternalSponsors') | Out-Null
            $createParameters.Remove('InternalSponsors') | Out-Null

            Write-Verbose -Message "Create Parameters: $(Convert-M365DscHashtableToString -Hashtable $createParameters)"
            $newConnectedOrganization = New-MgBetaEntitlementManagementConnectedOrganization -BodyParameter $createParameters

            foreach ($sponsor in $ExternalSponsorsValues)
            {
                $directoryObjectRef = @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/directoryObjects/$($sponsor)"
                }

                New-MgBetaEntitlementManagementConnectedOrganizationExternalSponsorByRef `
                    -ConnectedOrganizationId $newConnectedOrganization.id `
                    -BodyParameter $directoryObjectRef
            }

            foreach ($sponsor in $InternalSponsorsValues)
            {
                $directoryObjectRef = @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/directoryObjects/$($sponsor)"
                }

                New-MgBetaEntitlementManagementConnectedOrganizationInternalSponsorByRef `
                    -ConnectedOrganizationId $newConnectedOrganization.id `
                    -BodyParameter $directoryObjectRef
            }

        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating a new Entitlement Management Connected Organization {$($currentInstance.Id)}"

            $updateParameters = $boundParameters
            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Remove('ExternalSponsors') | Out-Null
            $updateParameters.Remove('InternalSponsors') | Out-Null

            Update-MgBetaEntitlementManagementConnectedOrganization -BodyParameter $updateParameters `
                -ConnectedOrganizationId $currentInstance.Id

            #region External Sponsors
            if ($currentInstance.ExternalSponsors)
            {
                $currentExternalSponsors = @()
                foreach ($sponsor in $CurrentInstance.ExternalSponsors)
                {
                    $sponsorId = $this.ResolveSponsorId($sponsor)
                    if ($sponsorId)
                    {
                        $currentExternalSponsors += $sponsorId
                    }
                }
                $currentInstance.ExternalSponsors = $currentExternalSponsors
            }
            $sponsorsDifferences = Compare-Object -ReferenceObject @($ExternalSponsorsValues | Select-Object) -DifferenceObject @($currentInstance.ExternalSponsors | Select-Object)
            $sponsorsToAdd = ($sponsorsDifferences | Where-Object -FilterScript { $_.SideIndicator -eq '<=' }).InputObject
            $sponsorsToRemove = ($sponsorsDifferences | Where-Object -FilterScript { $_.SideIndicator -eq '=>' }).InputObject
            foreach ($sponsor in $sponsorsToAdd)
            {
                $directoryObjectRef = @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/directoryObjects/$($sponsor)"
                }

                New-MgBetaEntitlementManagementConnectedOrganizationExternalSponsorByRef `
                    -ConnectedOrganizationId $currentInstance.Id `
                    -BodyParameter $directoryObjectRef
            }
            foreach ($sponsor in $sponsorsToRemove)
            {
                Remove-MgBetaEntitlementManagementConnectedOrganizationExternalSponsorDirectoryObjectByRef `
                    -ConnectedOrganizationId $currentInstance.Id `
                    -DirectoryObjectId $sponsor
            }
            #endregion

            #region Internal Sponsors
            if ($currentInstance.InternalSponsors)
            {
                $currentInternalSponsors = @()
                foreach ($sponsor in $CurrentInstance.InternalSponsors)
                {
                    $sponsorId = $this.ResolveSponsorId($sponsor)
                    if ($sponsorId)
                    {
                        $currentInternalSponsors += $sponsorId
                    }
                }
                $currentInstance.InternalSponsors = $currentInternalSponsors
            }
            $sponsorsDifferences = Compare-Object -ReferenceObject @($InternalSponsorsValues | Select-Object) -DifferenceObject @($currentInstance.InternalSponsors | Select-Object)
            $sponsorsToAdd = ($sponsorsDifferences | Where-Object -FilterScript { $_.SideIndicator -eq '<=' }).InputObject
            $sponsorsToRemove = ($sponsorsDifferences | Where-Object -FilterScript { $_.SideIndicator -eq '=>' }).InputObject
            foreach ($sponsor in $sponsorsToAdd)
            {
                $directoryObjectRef = @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/directoryObjects/$($sponsor)"
                }

                New-MgBetaEntitlementManagementConnectedOrganizationInternalSponsorByRef `
                    -ConnectedOrganizationId $currentInstance.Id `
                    -BodyParameter $directoryObjectRef
            }
            foreach ($sponsor in $sponsorsToRemove)
            {
                Remove-MgBetaEntitlementManagementConnectedOrganizationInternalSponsorDirectoryObjectByRef `
                    -ConnectedOrganizationId $currentInstance.Id `
                    -DirectoryObjectId $sponsor
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing a new Entitlement Management Connected Organization  {$($currentInstance.Id)}"
            Remove-MgBetaEntitlementManagementConnectedOrganization -ConnectedOrganizationId $currentInstance.Id
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
            [array]$getValue = Get-MgBetaEntitlementManagementConnectedOrganization `
                -All `
                -Filter $this.Filter `
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
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    id                    = $config.id
                    DisplayName           = $displayedKey
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

                if ($Results.IdentitySources)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.IdentitySources -CIMInstanceName AADEntitlementManagementConnectedOrganizationIdentitySource
                    if ($complexTypeStringResult)
                    {
                        $Results.IdentitySources = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('IdentitySources') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('IdentitySources')

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

    hidden [System.String] ResolveSponsorId([System.String] $Sponsor)
    {
        $user = Get-MgUser -UserId $Sponsor -ErrorAction SilentlyContinue
        if ($null -ne $user)
        {
            return $user.Id
        }

        $group = Get-MgGroup -Filter "displayName eq '$($Sponsor -replace "'", "''")'" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -ne $group)
        {
            return $group.Id
        }

        return $null
    }

    hidden [AADEntitlementManagementConnectedOrganization] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADEntitlementManagementConnectedOrganization])
        {
            return $Values
        }

        $result = [AADEntitlementManagementConnectedOrganization]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADEntitlementManagementConnectedOrganizationIdentitySource
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Type of the identity source.')]
    [ValidateSet('#microsoft.graph.azureActiveDirectoryTenant', '#microsoft.graph.crossCloudAzureActiveDirectoryTenant', '#microsoft.graph.domainIdentitySource', '#microsoft.graph.externalDomainFederation')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('The name of the Azure Active Directory tenant.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The ID of the Azure Active Directory tenant.')]
    [System.String] $ExternalTenantId

    [DscProperty()]
    [System.ComponentModel.Description('The ID of the cloud where the tenant is located, one of microsoftonline.com, microsoftonline.us or partner.microsoftonline.cn.')]
    [System.String] $CloudInstance

    [DscProperty()]
    [System.ComponentModel.Description('The domain name.')]
    [System.String] $DomainName

    [DscProperty()]
    [System.ComponentModel.Description('The issuerURI of the incoming federation.')]
    [System.String] $IssuerUri
}
