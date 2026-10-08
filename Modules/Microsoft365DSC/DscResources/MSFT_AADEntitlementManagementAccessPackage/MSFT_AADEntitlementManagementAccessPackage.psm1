using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADEntitlementManagementAccessPackage : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the access package.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the access package.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Identifier of the access package catalog referencing this access package.')]
    [System.String] $CatalogId

    [DscProperty()]
    [System.ComponentModel.Description('The description of the access package.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Whether the access package is hidden from the requestor.')]
    [System.Nullable[System.Boolean]] $IsHidden

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether role scopes are visible.')]
    [System.Nullable[System.Boolean]] $IsRoleScopesVisible

    [DscProperty()]
    [System.ComponentModel.Description('The resources and roles included in the access package.')]
    [MSFT_AccessPackageResourceRoleScope[]] $AccessPackageResourceRoleScopes

    [DscProperty()]
    [System.ComponentModel.Description('The access packages whose assigned users are ineligible to be assigned this access package.')]
    [System.String[]] $IncompatibleAccessPackages

    [DscProperty()]
    [System.ComponentModel.Description('The access packages that are incompatible with this package.')]
    [System.String[]] $AccessPackagesIncompatibleWith

    [DscProperty()]
    [System.ComponentModel.Description('The groups whose members are ineligible to be assigned this access package.')]
    [System.String[]] $IncompatibleGroups

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

    [AADEntitlementManagementAccessPackage] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADEntitlementManagementAccessPackage]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AzureAD Entitlement Management Access Package for DisplayName {$($this.DisplayName)}"

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
                    $getValue = Get-MgBetaEntitlementManagementAccessPackage -AccessPackageId $this.id `
                        -ExpandProperty "accessPackageResourceRoleScopes(`$expand=accessPackageResourceRole,accessPackageResourceScope)" `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    if (-not [System.String]::IsNullOrEmpty($this.id))
                    {
                        Write-Verbose -Message "Could not find an Azure AD Entitlement Management Access Package with Id {$($this.id)}"
                    }

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaEntitlementManagementAccessPackage `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ExpandProperty "accessPackageResourceRoleScopes(`$expand=accessPackageResourceRole,accessPackageResourceScope)" `
                            -ErrorAction SilentlyContinue
                    }
                }
            }
            else
            {
                $getValue = Get-MgBetaEntitlementManagementAccessPackage -AccessPackageId $this.Id `
                    -ExpandProperty "accessPackageResourceRoleScopes(`$expand=accessPackageResourceRole,accessPackageResourceScope)" `
                    -ErrorAction SilentlyContinue
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "No Azure AD Entitlement Management Access Package with DisplayName {$($this.DisplayName)} was found"
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "Found access package with id {$($getValue.id)} and displayName {$($getValue.displayName)}"

            $getAccessPackageResourceRoleScopes = @()
            foreach ($accessPackageResourceRoleScope in $getValue.AccessPackageResourceRoleScopes)
            {
                $originId = Get-M365DSCAccessPackageResourceOriginDisplayName -OriginId $accessPackageResourceRoleScope.AccessPackageResourceScope.OriginId `
                    -OriginSystem $accessPackageResourceRoleScope.AccessPackageResourceScope.OriginSystem
                $getAccessPackageResourceRoleScopes += @{
                    Id                                     = $accessPackageResourceRoleScope.Id
                    AccessPackageResourceOriginId          = $originId
                    AccessPackageResourceRoleDisplayName   = $accessPackageResourceRoleScope.AccessPackageResourceRole.DisplayName
                    AccessPackageResourceScopeOriginSystem = $accessPackageResourceRoleScope.AccessPackageResourceScope.OriginSystem
                }
            }

            $catalog = Get-MgBetaEntitlementManagementAccessPackageCatalog -AccessPackageCatalog $getValue.CatalogId

            $getIncompatibleAccessPackages = @()
            [Array]$query = Get-MgBetaEntitlementManagementAccessPackageIncompatibleAccessPackage -AccessPackageId $getValue.id
            if ($query.Count -gt 0)
            {
                $getIncompatibleAccessPackages += $query.id
            }

            $getAccessPackagesIncompatibleWith = @()
            [Array]$query = Get-MgBetaEntitlementManagementAccessPackageIncompatibleWith -AccessPackageId $getValue.id
            if ($query.Count -gt 0)
            {
                $getAccessPackagesIncompatibleWith += $query.id
            }

            $getIncompatibleGroups = @()
            [Array]$query = Get-MgBetaEntitlementManagementAccessPackageIncompatibleGroup -AccessPackageId $getValue.id
            if ($query.Count -gt 0)
            {
                $getIncompatibleGroups += $query.id
            }

            $results = @{
                Id                              = $getValue.Id
                CatalogId                       = $catalog.DisplayName
                Description                     = $getValue.Description
                DisplayName                     = $getValue.DisplayName
                IsHidden                        = $getValue.IsHidden
                IsRoleScopesVisible             = $getValue.IsRoleScopesVisible
                AccessPackageResourceRoleScopes = $getAccessPackageResourceRoleScopes
                IncompatibleAccessPackages      = $getIncompatibleAccessPackages
                AccessPackagesIncompatibleWith  = $getAccessPackagesIncompatibleWith #read-only
                IncompatibleGroups              = $getIncompatibleGroups
                Ensure                          = 'Present'
                Credential                      = $this.Credential
                ApplicationId                   = $this.ApplicationId
                TenantId                        = $this.TenantId
                ApplicationSecret               = $this.ApplicationSecret
                CertificateThumbprint           = $this.CertificateThumbprint
                CertificatePath                 = $this.CertificatePath
                CertificatePassword             = $this.CertificatePassword
                ManagedIdentity                 = $this.ManagedIdentity
                AccessTokens                    = $this.AccessTokens
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
        $createParameters = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of AzureAD Entitlement Management Access Package for DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating access package {$($this.DisplayName)}"

            #region basic information
            $createParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            if (-not [System.Guid]::TryParse($createParameters.CatalogId, [ref][System.Guid]::Empty))
            {
                $catalogInstance = Get-MgBetaEntitlementManagementAccessPackageCatalog -Filter "DisplayName eq '$($createParameters.CatalogId -replace "'", "''")'"
                if ($catalogInstance)
                {
                    $createParameters.CatalogId = $catalogInstance.Id
                }
            }

            $createParameters.Remove('Id') | Out-Null
            $createParameters.Remove('AccessPackageResourceRoleScopes') | Out-Null
            $createParameters.Remove('IncompatibleAccessPackages') | Out-Null
            $createParameters.Remove('AccessPackagesIncompatibleWith') | Out-Null
            $createParameters.Remove('IncompatibleGroups') | Out-Null

            $accessPackage = New-MgBetaEntitlementManagementAccessPackage `
                -BodyParameter $createParameters

            #endregion

            #region IncompatibleAccessPackages
            foreach ($incompatibleAccessPackage in $this.IncompatibleAccessPackages)
            {
                $ref = @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/identityGovernance/entitlementManagement/accessPackages/$incompatibleAccessPackage"
                }

                New-MgBetaEntitlementManagementAccessPackageIncompatibleAccessPackageByRef `
                    -AccessPackageId $accessPackage.Id `
                    -BodyParameter $ref
            }
            #endregion

            #region IncompatibleGroups
            foreach ($IncompatibleGroup in $this.IncompatibleGroups)
            {
                $ref = @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/groups/$IncompatibleGroup"
                }

                New-MgBetaEntitlementManagementAccessPackageIncompatibleGroupByRef `
                    -AccessPackageId $accessPackage.Id `
                    -BodyParameter $ref
            }
            #endregion

            #region AccessPackageResourceRoleScopes
            foreach ($accessPackageResourceRoleScope in $this.AccessPackageResourceRoleScopes)
            {
                #Add scopeRole
                $originId = $accessPackageResourceRoleScope.AccessPackageResourceOriginId
                $roleName = $accessPackageResourceRoleScope.AccessPackageResourceRoleDisplayName
                $originSystem = $accessPackageResourceRoleScope.AccessPackageResourceScopeOriginSystem

                $guid = [System.Guid]::Empty
                if ($originSystem -in @('AadApplication', 'AadGroup') -and -not [System.Guid]::TryParse($originId, [ref]$guid))
                {
                    if ($originSystem -eq 'AadApplication')
                    {
                        $application = Get-MgServicePrincipal -Filter "DisplayName eq '$($originId -replace "'", "''")'" -All
                        if ($null -ne $application)
                        {
                            $originId = $application.Id
                        }
                    }
                    else
                    {
                        $group = Get-MgGroup -Filter "DisplayName eq '$($OriginId -replace "'", "''")'" -All
                        if ($null -ne $group)
                        {
                            $originId = $group.Id
                        }
                    }
                }

                Write-Verbose -Message "Adding roleScope {$originId`:$roleName} to access package with Id {$($accessPackage.Id)}"

                $resourceScope = Get-MgBetaEntitlementManagementAccessPackageCatalogAccessPackageResource `
                    -AccessPackageCatalogId $createParameters.CatalogId `
                    -Filter "originId eq '$originId'" `
                    -ExpandProperty 'accessPackageResourceScopes'

                $resourceRole = Get-MgBetaEntitlementManagementAccessPackageCatalogAccessPackageResourceRole `
                    -AccessPackageCatalogId $createParameters.CatalogId `
                    -Filter "(accessPackageResource/Id eq '$($resourceScope.id)' and DisplayName eq '$($roleName -replace "'", "''")' and originSystem eq '$($resourceScope.originSystem)')" `
                    -ExpandProperty 'accessPackageResource'

                $isValidRoleScope = $true
                if ($null -eq $resourceScope)
                {
                    Write-Verbose -Message "The AccessPackageResourceOriginId {$originId} could not be found in catalog with id {$($createParameters.CatalogId)}"
                    $isValidRoleScope = $false
                }

                if ($null -eq $resourceRole)
                {
                    Write-Verbose -Message "The AccessPackageResourceRoleDisplayName {$roleName} could not be found for resource with originID {$originId}"
                    $isValidRoleScope = $false
                }

                if ($isValidRoleScope)
                {
                    $params = @{
                        accessPackageResourceRole  = @{
                            originId              = $resourceRole.OriginId
                            description           = $resourceRole.Description
                            displayName           = $resourceRole.DisplayName
                            id                    = $resourceRole.Id
                            originSystem          = $resourceRole.OriginSystem
                            accessPackageResource = @{
                                id           = $resourceScope.Id
                                resourceType = $resourceScope.ResourceType
                                originId     = $resourceScope.OriginId
                                originSystem = $resourceRole.OriginSystem
                            }
                        }
                        accessPackageResourceScope = @{
                            originId     = $resourceScope.OriginId
                            originSystem = $resourceScope.OriginSystem
                            id           = $resourceScope.AccessPackageResourceScopes[0].Id
                            isRootScope  = $resourceScope.AccessPackageResourceScopes[0].IsRootScope
                        }
                    }

                    New-MgBetaEntitlementManagementAccessPackageResourceRoleScope -AccessPackageId $accessPackage.Id -BodyParameter $params
                }
            }
            #endregion

        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating access package with id {$($this.id)} and displayName {$($this.DisplayName)}"

            #region basic information
            $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            if (-not [System.Guid]::TryParse($updateParameters.CatalogId, [ref][System.Guid]::Empty))
            {
                $catalogInstance = Get-MgBetaEntitlementManagementAccessPackageCatalog -Filter "DisplayName eq '$($updateParameters.CatalogId -replace "'", "''")'"
                if ($catalogInstance)
                {
                    $updateParameters.CatalogId = $catalogInstance.Id
                }
            }

            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Remove('AccessPackageResourceRoleScopes') | Out-Null
            $updateParameters.Remove('IncompatibleAccessPackages') | Out-Null
            $updateParameters.Remove('AccessPackagesIncompatibleWith') | Out-Null
            $updateParameters.Remove('IncompatibleGroups') | Out-Null

            Update-MgBetaEntitlementManagementAccessPackage -BodyParameter $updateParameters `
                -AccessPackageId $currentInstance.Id
            #endregion

            #region IncompatibleAccessPackages
            [Array]$currentIncompatibleAccessPackages = $currentInstance.IncompatibleAccessPackages
            if ($null -eq $currentIncompatibleAccessPackages)
            {
                $currentIncompatibleAccessPackages = @()
            }
            $desiredIncompatibleAccessPackages = $this.IncompatibleAccessPackages
            if ($null -eq $desiredIncompatibleAccessPackages)
            {
                $desiredIncompatibleAccessPackages = @()
            }
            [Array]$compareResult = Compare-Object `
                -ReferenceObject $desiredIncompatibleAccessPackages `
                -DifferenceObject $currentIncompatibleAccessPackages `

            [Array]$toBeAdded = $compareResult | Where-Object -FilterScript { $_.SideIndicator -eq '<=' }

            foreach ($incompatibleAccessPackage in $toBeAdded.InputObject)
            {
                $ref = @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/identityGovernance/entitlementManagement/accessPackages/$incompatibleAccessPackage"
                }

                New-MgBetaEntitlementManagementAccessPackageIncompatibleAccessPackageByRef `
                    -AccessPackageId $currentInstance.Id `
                    -BodyParameter $ref
            }

            [Array]$toBeRemoved = $compareResult | Where-Object -FilterScript { $_.SideIndicator -eq '=>' }

            foreach ($incompatibleAccessPackage in $toBeRemoved.InputObject)
            {
                Remove-MgBetaEntitlementManagementAccessPackageIncompatibleAccessPackageByRef `
                    -AccessPackageId $currentInstance.Id `
                    -AccessPackageId1 $incompatibleAccessPackage
            }
            #endregion

            #region IncompatibleGroups
            [Array]$currentIncompatibleGroups = $currentInstance.IncompatibleGroups
            if ($null -eq $currentIncompatibleGroups)
            {
                $currentIncompatibleGroups = @()
            }
            $desiredIncompatibleGroups = $this.IncompatibleGroups
            if ($null -eq $desiredIncompatibleGroups)
            {
                $desiredIncompatibleGroups = @()
            }
            [Array]$compareResult = Compare-Object `
                -ReferenceObject $desiredIncompatibleGroups `
                -DifferenceObject $currentIncompatibleGroups `

            [Array]$toBeAdded = $compareResult | Where-Object -FilterScript { $_.SideIndicator -eq '<=' }
            foreach ($incompatibleGroup in $toBeAdded.InputObject)
            {

                $ref = @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/groups/$incompatibleGroup"
                }

                New-MgBetaEntitlementManagementAccessPackageIncompatibleGroupByRef `
                    -AccessPackageId $currentInstance.Id `
                    -BodyParameter $ref
            }

            [Array]$toBeRemoved = $compareResult | Where-Object -FilterScript { $_.SideIndicator -eq '=>' }
            foreach ($incompatibleGroup in $toBeRemoved.InputObject)
            {
                Remove-MgBetaEntitlementManagementAccessPackageIncompatibleGroupByRef `
                    -AccessPackageId $currentInstance.Id `
                    -GroupId $incompatibleGroup
            }
            #endregion

            #region AccessPackageResourceRoleScopes
            $currentAccessPackageResourceOriginIds = $currentInstance.AccessPackageResourceRoleScopes.AccessPackageResourceOriginId
            foreach ($accessPackageResourceRoleScope in $this.AccessPackageResourceRoleScopes)
            {
                # Get() reports an AadGroup or AadApplication origin id as the object's display name,
                # so a desired origin id only matches once it is resolved the same way.
                $originKey = Get-M365DSCAccessPackageResourceOriginDisplayName -OriginId $accessPackageResourceRoleScope.AccessPackageResourceOriginId `
                    -OriginSystem $accessPackageResourceRoleScope.AccessPackageResourceScopeOriginSystem

                if ($originKey -notin ($currentAccessPackageResourceOriginIds))
                {
                    #region new roleScope
                    $originId = $accessPackageResourceRoleScope.AccessPackageResourceOriginId
                    $roleName = $accessPackageResourceRoleScope.AccessPackageResourceRoleDisplayName
                    $originSystem = $accessPackageResourceRoleScope.AccessPackageResourceScopeOriginSystem

                    $guid = [System.Guid]::Empty
                    if ($originSystem -in @('AadApplication', 'AadGroup') -and -not [System.Guid]::TryParse($originId, [ref]$guid))
                    {
                        if ($originSystem -eq 'AadApplication')
                        {
                            $application = Get-MgServicePrincipal -Filter "DisplayName eq '$($originId -replace "'", "''")'" -All
                            if ($null -ne $application)
                            {
                                $originId = $application.Id
                            }
                        }
                        else
                        {
                            $group = Get-MgGroup -Filter "DisplayName eq '$($originId -replace "'", "''")'" -All
                            if ($null -ne $group)
                            {
                                $originId = $group.Id
                            }
                        }
                    }

                    Write-Verbose -Message "Adding roleScope {$originId`:$roleName} to access package with Id {$($currentInstance.Id)}"

                    $resourceScope = Get-MgBetaEntitlementManagementAccessPackageCatalogAccessPackageResource `
                        -AccessPackageCatalogId $updateParameters.CatalogId `
                        -Filter "originId eq '$originId'" `
                        -ExpandProperty 'accessPackageResourceScopes'

                    $resourceRole = Get-MgBetaEntitlementManagementAccessPackageCatalogAccessPackageResourceRole `
                        -AccessPackageCatalogId $updateParameters.CatalogId `
                        -Filter "(accessPackageResource/Id eq '$($resourceScope.id)' and DisplayName eq '$($roleName -replace "'", "''")' and originSystem eq '$($resourceScope.originSystem)')" `
                        -ExpandProperty 'accessPackageResource'

                    $isValidRoleScope = $true
                    if ($null -eq $resourceScope)
                    {
                        Write-Verbose -Message "The AccessPackageResourceOriginId {$originId} could not be found in catalog with id {$($updateParameters.CatalogId)}"
                        $isValidRoleScope = $false
                    }

                    if ($null -eq $resourceRole)
                    {
                        Write-Verbose -Message "The AccessPackageResourceRoleDisplayName {$roleName} could not be found for resource with originID {$originId}"
                        $isValidRoleScope = $false
                    }

                    if ($isValidRoleScope)
                    {
                        $params = @{
                            accessPackageResourceRole  = @{
                                originId              = $resourceRole.OriginId
                                description           = $resourceRole.Description
                                displayName           = $resourceRole.DisplayName
                                id                    = $resourceRole.Id
                                originSystem          = $resourceRole.OriginSystem
                                accessPackageResource = @{
                                    id           = $resourceScope.Id
                                    resourceType = $resourceScope.ResourceType
                                    originId     = $resourceScope.OriginId
                                    originSystem = $resourceRole.OriginSystem
                                }
                            }
                            accessPackageResourceScope = @{
                                originId     = $resourceScope.OriginId
                                originSystem = $resourceScope.OriginSystem
                                id           = $resourceScope.AccessPackageResourceScopes[0].Id
                                isRootScope  = $resourceScope.AccessPackageResourceScopes[0].IsRootScope
                            }
                        }

                        New-MgBetaEntitlementManagementAccessPackageResourceRoleScope -AccessPackageId $currentInstance.Id -BodyParameter $params
                    }
                    #endregion
                }
                else
                {
                    $currentRole = $currentInstance.AccessPackageResourceRoleScopes | Where-Object `
                        -FilterScript { $_.AccessPackageResourceOriginId -eq $originKey }
                    if ($accessPackageResourceRoleScope.AccessPackageResourceRoleDisplayName -ne $currentRole.AccessPackageResourceRoleDisplayName )
                    {
                        #region update role

                        $originId = $accessPackageResourceRoleScope.AccessPackageResourceOriginId
                        $roleName = $accessPackageResourceRoleScope.AccessPackageResourceRoleDisplayName

                        Write-Verbose -Message "Updating role {$roleName} from access package rolescope with Id {$($accessPackageResourceRoleScope.id)}"

                        $resourceScope = Get-MgBetaEntitlementManagementAccessPackageCatalogAccessPackageResource `
                            -AccessPackageCatalogId $updateParameters.CatalogId `
                            -Filter "originId eq '$originId'" `
                            -ExpandProperty 'accessPackageResourceScopes'

                        $resourceRole = Get-MgBetaEntitlementManagementAccessPackageCatalogAccessPackageResourceRole `
                            -AccessPackageCatalogId $updateParameters.CatalogId `
                            -Filter "(accessPackageResource/Id eq '$($resourceScope.id)' and DisplayName eq '$($roleName -replace "'", "''")' and originSystem eq '$($resourceScope.originSystem)')" `
                            -ExpandProperty 'accessPackageResource'

                        $isValidRoleScope = $true
                        if ($null -eq $resourceScope)
                        {
                            Write-Verbose -Message "The AccessPackageResourceOriginId {$originId} could not be found in catalog with id {$($updateParameters.CatalogId)}"
                            $isValidRoleScope = $false
                        }

                        if ($null -eq $resourceRole)
                        {
                            Write-Verbose -Message "The AccessPackageResourceRoleDisplayName {$roleName} could not be found for resource with originID {$originId}"
                            $isValidRoleScope = $false
                        }

                        if ($isValidRoleScope)
                        {
                            $params = @{
                                accessPackageResourceRole  = @{
                                    originId              = $resourceRole.OriginId
                                    description           = $resourceRole.Description
                                    displayName           = $resourceRole.DisplayName
                                    id                    = $resourceRole.Id
                                    originSystem          = $resourceRole.OriginSystem
                                    accessPackageResource = @{
                                        id           = $resourceScope.Id
                                        resourceType = $resourceScope.ResourceType
                                        originId     = $resourceScope.OriginId
                                        originSystem = $resourceRole.OriginSystem
                                    }
                                }
                                accessPackageResourceScope = @{
                                    originId     = $resourceScope.OriginId
                                    originSystem = $resourceScope.OriginSystem
                                    id           = $resourceScope.AccessPackageResourceScopes[0].Id
                                    isRootScope  = $resourceScope.AccessPackageResourceScopes[0].IsRootScope
                                }
                            }

                            Remove-MgBetaEntitlementManagementAccessPackageResourceRoleScope `
                                -AccessPackageId $currentInstance.Id `
                                -AccessPackageResourceRoleScopeId $currentRole.Id

                            New-MgBetaEntitlementManagementAccessPackageResourceRoleScope `
                                -AccessPackageId $currentInstance.Id `
                                -BodyParameter $params

                        }
                        #endregion
                    }
                }
            }

            #region remove roleScope
            $currentAccessPackageResourceOriginIdsToRemove = @()
            if ($this.GetBoundParameters().ContainsKey('AccessPackageResourceRoleScopes'))
            {
                $desiredAccessPackageResourceOriginKeys = @()
                foreach ($desiredRoleScope in $this.AccessPackageResourceRoleScopes)
                {
                    $desiredAccessPackageResourceOriginKeys += Get-M365DSCAccessPackageResourceOriginDisplayName -OriginId $desiredRoleScope.AccessPackageResourceOriginId `
                        -OriginSystem $desiredRoleScope.AccessPackageResourceScopeOriginSystem
                }
                $currentAccessPackageResourceOriginIdsToRemove = $currentAccessPackageResourceOriginIds | Where-Object `
                    -FilterScript { $_ -notin $desiredAccessPackageResourceOriginKeys }
            }
            foreach ($originId in $currentAccessPackageResourceOriginIdsToRemove)
            {

                $currentRoleScope = $currentInstance.AccessPackageResourceRoleScopes | Where-Object `
                    -FilterScript { $_.AccessPackageResourceOriginId -eq $originId }

                Write-Verbose -Message "Removing RoleScope with originId {$originId} from access package {$($currentInstance.Id)}"

                Remove-MgBetaEntitlementManagementAccessPackageResourceRoleScope `
                    -AccessPackageId $currentInstance.Id `
                    -AccessPackageResourceRoleScopeId $currentRoleScope.Id
            }
            #endregion

        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing access package with id {$($this.id)} and displayName {$($this.DisplayName)}"

            #region resource generator code
            Remove-MgBetaEntitlementManagementAccessPackage -AccessPackageId $currentInstance.Id
            #endregion
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)
                if ([M365DSCResourceBase]::IsReportContext($PostProcessingArgs) -or
                    $null -eq $DesiredValues.AccessPackageResourceRoleScopes)
                {
                    return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
                }

                $normalizedRoleScopes = @()
                foreach ($roleScope in $DesiredValues.AccessPackageResourceRoleScopes)
                {
                    $normalizedRoleScope = [MSFT_AccessPackageResourceRoleScope]::new()
                    $normalizedRoleScope.Id = $roleScope.Id
                    $normalizedRoleScope.AccessPackageResourceRoleDisplayName = $roleScope.AccessPackageResourceRoleDisplayName
                    $normalizedRoleScope.AccessPackageResourceScopeOriginSystem = $roleScope.AccessPackageResourceScopeOriginSystem
                    $normalizedRoleScope.AccessPackageResourceOriginId = Get-M365DSCAccessPackageResourceOriginDisplayName `
                        -OriginId $roleScope.AccessPackageResourceOriginId `
                        -OriginSystem $roleScope.AccessPackageResourceScopeOriginSystem
                    $normalizedRoleScopes += $normalizedRoleScope
                }
                $DesiredValues.AccessPackageResourceRoleScopes = $normalizedRoleScopes

                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
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
            [array]$getValue = Get-MgBetaEntitlementManagementAccessPackage `
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
                $rawResults = $Results.Clone()
                if ($null -ne $Results.AccessPackageResourceRoleScopes)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ([Array]$Results.AccessPackageResourceRoleScopes) `
                        -CIMInstanceName AccessPackageResourceRoleScope

                    $Results.AccessPackageResourceRoleScopes = $complexTypeStringResult

                    if ([String]::IsNullOrEmpty($complexTypeStringResult))
                    {
                        $Results.Remove('AccessPackageResourceRoleScopes') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('AccessPackageResourceRoleScopes') `
                    -RawResults $rawResults

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
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) Tenant does not meet license requirement to extract this component or the user has not been granted the proper permissions."
                return ''
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }
    }

    hidden [AADEntitlementManagementAccessPackage] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADEntitlementManagementAccessPackage])
        {
            return $Values
        }

        $result = [AADEntitlementManagementAccessPackage]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AccessPackageResourceRoleScope
{
    [DscProperty()]
    [System.ComponentModel.Description('The Id of the resource roleScope.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The origine Id of the resource.')]
    [System.String] $AccessPackageResourceOriginId

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the resource role.')]
    [System.String] $AccessPackageResourceRoleDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The type of the resource in the origin system.')]
    [System.String] $AccessPackageResourceScopeOriginSystem
}
