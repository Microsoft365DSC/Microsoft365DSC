<#
.SYNOPSIS
    Orchestrates a reverse extraction of Microsoft 365 tenant configuration.

.DESCRIPTION
    Coordinates the end-to-end reverse DSC export flow, including authentication validation, workload/resource selection, configuration data generation, and resource export execution.
    This function is the bridge between export entry points and the ReverseDSC extraction pipeline.

.PARAMETER Credential
    Specifies the credential used for delegated authentication.

.PARAMETER Components
    Specifies resource component names to export.

.PARAMETER ExcludeComponents
    Specifies resource component names to exclude from export.

.PARAMETER AllComponents
    Indicates that all components should be considered for export.

.PARAMETER Path
    Specifies the destination path for generated files.

.PARAMETER FileName
    Specifies the output file name for the generated configuration.

.PARAMETER ConfigurationName
    Specifies the DSC configuration name to generate.

.PARAMETER Workloads
    Specifies workload names used to derive exportable components.

.PARAMETER Mode
    Specifies the export mode.

.PARAMETER GenerateInfo
    Indicates whether additional resource information should be generated.

.PARAMETER Filters
    Specifies resource-level filters used to limit exported instances.

.PARAMETER ApplicationId
    Specifies the application id used for app-based authentication.

.PARAMETER ApplicationSecret
    Specifies the application secret used for app-based authentication.

.PARAMETER TenantId
    Specifies the tenant id or tenant domain used for authentication.

.PARAMETER CertificateThumbprint
    Specifies the certificate thumbprint used for app-based authentication.

.PARAMETER CertificatePath
    Specifies the certificate file path used for app-based authentication.

.PARAMETER CertificatePassword
    Specifies the certificate password used to read the certificate file.

.PARAMETER ManagedIdentity
    Indicates that managed identity authentication should be used.

.PARAMETER AccessTokens
    Specifies one or more pre-acquired access tokens to use.

.PARAMETER SubscriptionId
    Specifies the Azure subscription id used by Azure-backed resources.

.PARAMETER Validate
    Indicates whether extracted configuration should be validated.

.PARAMETER Parallel
    Indicates whether resource extraction should run in parallel.

.PARAMETER ThrottleLimit
    Specifies the number of parallel workers. Default: 5.

.PARAMETER ResourceSettings
    Specifies resource settings metadata used during extraction.

.PARAMETER WithStatistics
    Indicates whether extraction statistics should be collected and emitted.

.PARAMETER IncludeDependencies
    Indicates whether dependency relationships should be included in output.

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.Collections.Hashtable
#>
function Start-M365DSCConfigurationExtract
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Conversion for credential creation')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'GenerateInfo', Justification = 'Using statement not detected')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Filters', Justification = 'Using statement not detected')]
    param(
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String[]]
        $Components,

        [Parameter()]
        [System.String[]]
        $ExcludeComponents,

        [Parameter()]
        [Switch]
        $AllComponents,

        [Parameter()]
        [System.String]
        $Path,

        [Parameter()]
        [System.String]
        $FileName,

        [Parameter()]
        [System.String]
        $ConfigurationName = 'M365TenantConfig',

        [Parameter()]
        [ValidateSet('AAD', 'ADO', 'AZURE', 'COMMERCE', 'DEFENDER', 'EXO', 'FABRIC', 'INTUNE', 'O365', 'OD', 'PLANNER', 'PP', 'SC', 'SENTINEL', 'SH', 'SPO', 'TEAMS', 'VIVA')]
        [System.String[]]
        $Workloads,

        [Parameter()]
        [ValidateSet('Default', 'Full')]
        [System.String]
        $Mode = 'Default',

        [Parameter()]
        [System.Boolean]
        $GenerateInfo = $false,

        [Parameter()]
        [System.Collections.Hashtable]
        $Filters,

        [Parameter()]
        [System.String]
        $ApplicationId,

        # TODO: Change to PSCredential during next breaking change
        [Parameter()]
        [System.String]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

        [Parameter()]
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens,

        [Parameter()]
        [System.String]
        $SubscriptionId,

        [Parameter()]
        [Switch]
        $Validate,

        [Parameter()]
        [Switch]
        $Parallel,

        [Parameter()]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $ThrottleLimit = 5,

        [Parameter()]
        [System.Collections.Generic.Dictionary[System.String, System.Object]]
        $ResourceSettings,

        [Parameter()]
        [Switch]
        $WithStatistics,

        [Parameter()]
        [Switch]
        $IncludeDependencies
    )

    # Start by checking to see if a new version of the tool is available in the PowerShell Gallery
    try
    {
        Write-Verbose -Message 'Testing Module Validity'
        Test-M365DSCModuleValidity
    }
    catch
    {
        Add-M365DSCEvent -Message $_ -Source 'M365DSCReverse::Test-M365DSCModuleValidity'
    }

    try
    {
        $shouldOpenOutputDirectory = $false
        #region Prompt the user for a location to save the extract and generate the files
        if ([System.String]::IsNullOrEmpty($Path))
        {
            $shouldOpenOutputDirectory = $true
            $OutputDSCPath = Read-Host "`r`nDestination Path"
        }
        else
        {
            $OutputDSCPath = $Path
        }

        if ([System.String]::IsNullOrEmpty($OutputDSCPath))
        {
            $OutputDSCPath = '.'
        }

        while ((Test-Path -Path $OutputDSCPath -PathType Container -ErrorAction SilentlyContinue) -eq $false)
        {
            try
            {
                Write-M365DSCHost -Message "Directory `"$OutputDSCPath`" doesn't exist; creating..."
                New-Item -Path $OutputDSCPath -ItemType Directory | Out-Null
                if ($?)
                {
                    break
                }
            }
            catch
            {
                Write-Warning "$($_.Exception.Message)"
                Write-Warning "Could not create folder $OutputDSCPath!"
            }
            $OutputDSCPath = Read-Host 'Please Provide Output Folder for DSC Configuration (will be created as necessary)'
        }
        <## Ensures the path we specify ends with a Slash, in order to make sure the resulting file path is properly structured. #>
        if (-not $OutputDSCPath.EndsWith('\') -and -not $OutputDSCPath.EndsWith('/'))
        {
            $OutputDSCPath += [System.IO.Path]::DirectorySeparatorChar
        }
        Push-Location -Path $OutputDSCPath
        #endregion

        $Global:PartialExportFileName = "$(New-Guid).partial.ps1"

        # Telemetry parameters initialization
        $Global:M365DSCExportResourceTypes = @()
        $Global:M365DSCExportResourceInstancesCount = 0

        $M365DSCExportStartTime = [System.DateTime]::Now

        [System.String[]]$Script:allM365DSCResources = Get-M365DSCAllResources

        if ($null -ne $Workloads)
        {
            Write-Verbose -Message 'Retrieving the resources to export by workloads'
            $Workloads = $Workloads | Select-Object -Unique
            $Components = Get-M365DSCResourcesByWorkloads -Workloads $Workloads `
                -Mode $Mode
        }

        $ComponentsToSkip = @()
        if ($Mode -eq 'Default' -and $null -eq $Components)
        {
            $ComponentsToSkip = Get-M365DSCResourcesByExportMode -Mode 'Full' -ExcludeConfigurationResources
        }

        if ($null -ne $ExcludeComponents)
        {
            $ComponentsToSkip += $ExcludeComponents
        }

        if ($null -ne $Components)
        {
            $newComponents = @()
            foreach ($component in $Components)
            {
                if ($component.Contains('*'))
                {
                    $matchingResources = $Script:allM365DSCResources -like $component
                    if ($matchingResources.Count -eq 0)
                    {
                        Write-Warning -Message "The component filter '$component' did not match any resources and will be ignored."
                    }
                    else
                    {
                        Write-Verbose -Message "The component filter '$component' matched the following resources: $($matchingResources -join ',')"
                        $newComponents += ($matchingResources | Where-Object { $ComponentsToSkip -notcontains $_ })
                    }
                }
                else
                {
                    $newComponents += $component
                }
            }
            $Components = $newComponents | Select-Object -Unique
            $resourcesInBothIncludeAndExclude = Compare-Object -ReferenceObject $Components `
                -DifferenceObject $ComponentsToSkip -ExcludeDifferent -IncludeEqual
        }

        if ($resourcesInBothIncludeAndExclude.Count -gt 0)
        {
            foreach ($resource in $resourcesInBothIncludeAndExclude)
            {
                Write-Warning -Message "The component '$($resource.InputObject)' was specified in both -Components and -ExcludeComponents parameters. It will be excluded from the export."
            }
        }

        # Check to validate that based on the received authentication parameters
        # we are allowed to export the selected components.
        $AuthMethods = @()

        Write-M365DSCHost -Message ' '
        Write-M365DSCHost -Message 'Authentication methods specified:'
        if ($null -ne $Credential -and `
                [System.String]::IsNullOrEmpty($ApplicationId) )
        {
            Write-M365DSCHost -Message '- Credentials'
            $AuthMethods += 'Credentials'
        }
        if ($null -ne $Credential -and `
                [System.String]::IsNullOrEmpty($ApplicationId) -and `
                -not [System.String]::IsNullOrEmpty($TenantId))
        {
            Write-M365DSCHost -Message '- Credentials with Tenant Id'
            $AuthMethods += 'CredentialsWithTenantId'
        }
        if ($null -ne $Credential -and `
                -not [System.String]::IsNullOrEmpty($ApplicationId))
        {
            Write-M365DSCHost -Message '- CredentialsWithApplicationId'
            $AuthMethods += 'CredentialsWithApplicationId'
        }
        if (-not [System.String]::IsNullOrEmpty($CertificateThumbprint))
        {
            Write-M365DSCHost -Message '- Service Principal with Certificate Thumbprint'
            $AuthMethods += 'CertificateThumbprint'
        }

        if (-not [System.String]::IsNullOrEmpty($CertificatePath))
        {
            Write-M365DSCHost -Message '- Service Principal with Certificate Path'
            $AuthMethods += 'CertificatePath'
        }

        if (-not [System.String]::IsNullOrEmpty($ApplicationSecret))
        {
            Write-M365DSCHost -Message '- Service Principal with Application Secret'
            $AuthMethods += 'ApplicationWithSecret'
        }

        if ($ManagedIdentity.IsPresent)
        {
            Write-M365DSCHost -Message '- Managed Identity'
            $AuthMethods += 'ManagedIdentity'
        }

        if ($null -ne $AccessTokens)
        {
            Write-M365DSCHost -Message '- Access Tokens'
            $AuthMethods += 'AccessTokens'
        }

        Write-M365DSCHost -Message ' '

        # If some resources are not supported based on the Authentication parameters
        # received, write a warning.
        $Components = $Components | Select-Object -Unique
        if ($Components.Length -eq 0)
        {
            Write-Verbose -Message 'Retrieving all resources'
            $selectedItems = Compare-Object -ReferenceObject $Script:allM365DSCResources `
                -DifferenceObject $ComponentsToSkip | Where-Object -Property SideIndicator -EQ '<='
            $selectedResources = @()
            foreach ($item in $selectedItems)
            {
                $selectedResources += $item.InputObject
            }
        }
        else
        {
            foreach ($component in $Components)
            {
                if ($Script:allM365DSCResources -notcontains $component)
                {
                    Write-Warning -Message "The component '$component' is not a valid Microsoft365DSC resource and will be ignored."
                    $ComponentsToSkip += $component
                }
            }
            $selectedResources = $Components
        }

        Write-Verbose -Message 'Based on provided parameters, retrieving the most secure authentication method to use.'
        $allSupportedResourcesWithMostSecureAuthMethod = Get-M365DSCComponentsWithMostSecureAuthenticationType -AuthenticationMethod $AuthMethods `
            -Resources $selectedResources

        try
        {
            if ($allSupportedResourcesWithMostSecureAuthMethod.Length -eq 0)
            {
                $allSupportedResourcesWithMostSecureAuthMethod = @()
            }
            if ($selectedResources.Length -eq 0)
            {
                $selectedResources = @()
            }
            # Filter null elements in case one resource was provided and is not supported with the provided authentication method
            # to avoid Compare-Object from throwing a ParameterArgumentValidationErrorNullNotAllowed error
            $allSupportedResourcesWithMostSecureAuthMethodArray = @()
            foreach ($resource in ($allSupportedResourcesWithMostSecureAuthMethod | Where-Object { $null -ne $_ }))
            {
                $allSupportedResourcesWithMostSecureAuthMethodArray += $resource.Resource
            }
            [Array]$compareResourcesResult = Compare-Object -ReferenceObject $allSupportedResourcesWithMostSecureAuthMethodArray `
                -DifferenceObject $selectedResources | Where-Object -Property SideIndicator -EQ '=>'
        }
        catch
        {
            Write-Verbose -Message $_
        }

        if ($null -ne $compareResourcesResult)
        {
            # The client is trying to extract at least one resource which is not supported
            # using only the provided authentication parameters;
            $resourcesNotSupported = @()
            foreach ($resource in $compareResourcesResult)
            {
                $resourcesNotSupported += $resource.InputObject

                # Skip resources that are not supported;
                $ComponentsToSkip += $resource.InputObject
            }

            $warningMessage = 'Based on the provided Authentication parameters, the following resources cannot be extracted: '
            $warningMessage += $resourcesNotSupported -join ','
            Write-Warning -Message $warningMessage

            # If all selected resources are not valid based on the authentication method used, simply return.
            if ($ComponentsToSkip.Length -eq $selectedResources.Length)
            {
                return
            }
        }

        # Get Tenant Info
        $organization = ''
        if ($AuthMethods -contains 'CertificateThumbprint' -or `
                $AuthMethods -contains 'CertificatePath' -or `
                $AuthMethods -contains 'ApplicationWithSecret')
        {
            $AppSecretAsPSCredential = $null
            # TODO: Remove during next breaking change, when ApplicationSecret is changed to PSCredential
            if (-not [System.String]::IsNullOrEmpty($ApplicationSecret))
            {
                [SecureString]$secStringPassword = ConvertTo-SecureString $ApplicationSecret -AsPlainText -Force
                [PSCredential]$AppSecretAsPSCredential = New-Object System.Management.Automation.PSCredential ('ApplicationSecret', $secStringPassword)
            }

            $organization = $TenantId
        }
        elseif ($AuthMethods -contains 'Credentials' -or `
                $AuthMethods -contains 'CredentialsWithApplicationId')
        {
            if ($null -ne $Credential -and $Credential.UserName.Contains('@'))
            {
                Write-Verbose -Message 'Retrieving organization name based on provided credentials.'
                $organization = $Credential.UserName.Split('@')[1]
            }
        }
        elseif ($AuthMethods -contains 'AccessTokens')
        {
            $organization = $TenantId
        }
        elseif ($AuthMethods -contains 'ManagedIdentity')
        {
            # If tenantId comes in as a GUID then query to replace with string representation, else use what was provided
            if ($TenantId -match ('^(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}$'))
            {
                $null = New-M365DSCConnection -Workload 'MicrosoftGraph' -InboundParameters @{'ManagedIdentity' = $true; 'TenantId' = $TenantId }
                $organization = Get-M365DSCTenantDomain -TenantId $TenantId -ManagedIdentity
            }
            else
            {
                $organization = $TenantId
            }
        }

        $AzureAutomation = $false

        [array] $version = Get-Module 'Microsoft365DSC'
        $version = $version[0].Version
        $DSCContent = [System.Text.StringBuilder]::new()
        $DSCContent.Append("# Generated with Microsoft365DSC version $version`r`n") | Out-Null
        $DSCContent.Append("# For additional information on how to use Microsoft365DSC, please visit https://aka.ms/M365DSC`r`n") | Out-Null
        $DSCContent.Append("param (`r`n") | Out-Null

        # Add script parameters, only add PSCredential parameters. All other information
        # is placed in the Configuration Data file.
        $newline = $false
        switch ($AuthMethods)
        {
            'CertificatePath'
            {
                if ($newline)
                {
                    $DSCContent.Append("`r`n") | Out-Null
                }
                $DSCContent.Append("    [Parameter()]`r`n") | Out-Null
                $DSCContent.Append("    [System.Management.Automation.PSCredential]`r`n") | Out-Null
                $DSCContent.Append("    `$CertificatePassword`r`n") | Out-Null
                $newline = $true
            }
            { $_ -in 'Credentials', 'CredentialsWithApplicationId' }
            {
                if ($newline)
                {
                    $DSCContent.Append("`r`n") | Out-Null
                }
                $DSCContent.Append("    [Parameter()]`r`n") | Out-Null
                $DSCContent.Append("    [System.Management.Automation.PSCredential]`r`n") | Out-Null
                $DSCContent.Append("    `$Credential`r`n") | Out-Null
                $newline = $true
            }
        }

        $DSCContent.Append(")`r`n`r`n") | Out-Null

        # Create Configuration section
        if (-not [System.String]::IsNullOrEmpty($FileName))
        {
            $FileParts = $FileName.Split('.')

            if ([System.String]::IsNullOrEmpty($ConfigurationName))
            {
                $ConfigurationName = $FileName.Replace('.' + $FileParts[$FileParts.Length - 1], '').Replace(' ', '_')
            }
        }
        if ([System.String]::IsNullOrEmpty($ConfigurationName))
        {
            $ConfigurationName = 'M365TenantConfig'
        }
        $DSCContent.Append("Configuration $ConfigurationName`r`n{`r`n") | Out-Null

        # Adding Parameter section
        $DSCContent.Append("    param (`r`n") | Out-Null

        $newline = $false
        $postParamContent = [System.Text.StringBuilder]::new()
        switch ($AuthMethods)
        {
            { $_ -in 'CertificateThumbprint', 'CertificatePath', 'ApplicationWithSecret' }
            {
                $postParamContent.Append("    `$OrganizationName = `$ConfigurationData.NonNodeData.OrganizationName`r`n") | Out-Null

                Add-ConfigurationDataEntry -Node 'NonNodeData' `
                    -Key 'OrganizationName' `
                    -Value $organization `
                    -Description "Tenant's default verified domain name"
                Add-ConfigurationDataEntry -Node 'NonNodeData' `
                    -Key 'ApplicationId' `
                    -Value $ApplicationId `
                    -Description 'Azure AD Application Id for Authentication'
                Add-ConfigurationDataEntry -Node 'NonNodeData' `
                    -Key 'TenantId' `
                    -Value $TenantId `
                    -Description 'The Id or Name of the tenant to authenticate against'
            }
            'CertificateThumbprint'
            {
                Add-ConfigurationDataEntry -Node 'NonNodeData' `
                    -Key 'CertificateThumbprint' `
                    -Value $CertificateThumbprint `
                    -Description 'Thumbprint of the certificate to use for authentication'
            }
            'CertificatePath'
            {
                if ($newline)
                {
                    $DSCContent.Append("`r`n") | Out-Null
                }
                $DSCContent.Append("        [Parameter()]`r`n") | Out-Null
                $DSCContent.Append("        [System.Management.Automation.PSCredential]`r`n") | Out-Null
                $DSCContent.Append("        `$CertificatePassword`r`n") | Out-Null

                if ($newline)
                {
                    $postParamContent.Append("`r`n") | Out-Null
                }
                $postParamContent.Append("    if (`$null -eq `$CertificatePassword)`r`n") | Out-Null
                $postParamContent.Append("    {`r`n") | Out-Null
                $postParamContent.Append("        <# Credentials #>`r`n") | Out-Null
                $postParamContent.Append("    }`r`n") | Out-Null
                $postParamContent.Append("    else`r`n") | Out-Null
                $postParamContent.Append("    {`r`n") | Out-Null
                $postParamContent.Append("        `$CredsCertificatePassword = `$CertificatePassword`r`n") | Out-Null
                $postParamContent.Append("    }`r`n`r`n") | Out-Null

                Add-ConfigurationDataEntry -Node 'NonNodeData' `
                    -Key 'CertificatePath' `
                    -Value $CertificatePath `
                    -Description 'Local path to the .pfx certificate to use for authentication'

                $newline = $true
            }
            'ApplicationWithSecret'
            {
                Add-ConfigurationDataEntry -Node 'NonNodeData' `
                    -Key 'ApplicationSecret' `
                    -Value $ApplicationSecret `
                    -Description 'Azure AD Application Secret for Authentication'
            }
            'AccessTokens'
            {
                Add-ConfigurationDataEntry -Node 'NonNodeData' `
                    -Key 'AccessTokens' `
                    -Value $AccessTokens `
                    -Description 'Access tokens to use for authentication'

                Add-ConfigurationDataEntry -Node 'NonNodeData' `
                    -Key 'TenantId' `
                    -Value $TenantId `
                    -Description 'The Id or Name of the tenant to authenticate against'

                Set-M365DSCStringReplacementMap -Map @{ $TenantId = 'TenantId' }
            }
            { $_ -in 'Credentials', 'CredentialsWithApplicationId', 'CredentialsWithTenantId' }
            {
                if ($newline)
                {
                    $DSCContent.Append("`r`n") | Out-Null
                }
                $DSCContent.Append("        [Parameter()]`r`n") | Out-Null
                $DSCContent.Append("        [System.Management.Automation.PSCredential]`r`n") | Out-Null
                $DSCContent.Append("        `$Credential`r`n") | Out-Null

                if ($newline)
                {
                    $postParamContent.Append("`r`n") | Out-Null
                }
                $postParamContent.Append("    if (`$null -eq `$Credential)`r`n") | Out-Null
                $postParamContent.Append("    {`r`n") | Out-Null
                $postParamContent.Append("        <# Credentials #>`r`n") | Out-Null
                $postParamContent.Append("    }`r`n") | Out-Null
                $postParamContent.Append("    else`r`n") | Out-Null
                $postParamContent.Append("    {`r`n") | Out-Null
                $postParamContent.Append("        `$CredsCredential = `$Credential`r`n") | Out-Null
                $postParamContent.Append("    }`r`n`r`n") | Out-Null
                $postParamContent.Append("    `$OrganizationName = `$CredsCredential.UserName.Split('@')[1]`r`n") | Out-Null

                $newline = $true
            }
            'ManagedIdentity'
            {
                $postParamContent.Append("    `$OrganizationName = `$ConfigurationData.NonNodeData.OrganizationName`r`n") | Out-Null

                Add-ConfigurationDataEntry -Node 'NonNodeData' `
                    -Key 'OrganizationName' `
                    -Value $organization `
                    -Description "Tenant's default verified domain name"

                Add-ConfigurationDataEntry -Node 'NonNodeData' `
                    -Key 'TenantId' `
                    -Value $TenantId `
                    -Description 'The Id or Name of the tenant to authenticate against'

                Set-M365DSCStringReplacementMap -Map @{ $TenantId = 'TenantId' }
            }
        }

        $DSCContent.Append("    )`r`n`r`n") | Out-Null
        $DSCContent.Append($postParamContent.ToString()) | Out-Null
        $DSCContent.Append("`r`n") | Out-Null

        # Create Node section
        $DSCContent.Append("    Import-DscResource -ModuleName 'Microsoft365DSC' -ModuleVersion '$version'`r`n`r`n") | Out-Null
        $DSCContent.Append("    Node localhost`r`n") | Out-Null
        $DSCContent.Append("    {`r`n") | Out-Null

        Write-Verbose -Message 'Adding initial entry in the ConfigurationData file.'
        Add-ConfigurationDataEntry -Node 'localhost' `
            -Key 'ServerNumber' `
            -Value '0' `
            -Description 'Default Value Used to Ensure a Configuration Data File is Generated'

        $resourcesToExport = [System.Collections.Generic.List[Hashtable[]]]::new()
        $resourcesToProcess = [System.Collections.Generic.List[System.Object]]::new()
        Initialize-M365DSCResourcesDictionary

        $containsConfigurationPolicies = $false
        $requestedConfigurationPolicyTemplateIds = @()
        # TODO: Update to -AsHashtable once PowerShell 7 is enforced
        $intuneTemplateRegistryObject = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath '../IntuneTemplateRegistry.json') -Raw | ConvertFrom-Json
        $intuneTemplateRegistry = @{}
        foreach ($property in $intuneTemplateRegistryObject.psobject.properties)
        {
            $intuneTemplateRegistry.Add($property.Name, $property.Value)
        }

        foreach ($resourceModule in $Script:allM365DSCResources)
        {
            try
            {
                if ((($Components -and ($Components -contains $resourceModule)) -or $AllComponents -or `
                        (-not $Components -and $null -eq $Workloads)) -and `
                    $ComponentsToSkip -notcontains $resourceModule -and `
                        $resourcesNotSupported -notcontains $resourceModule -and `
                        -not $resourceModule.StartsWith('M365DSC'))
                {
                    $authMethod = $allSupportedResourcesWithMostSecureAuthMethod | Where-Object -Property Resource -EQ $resourceModule
                    $resourceInfo = @{
                        Name                 = $resourceModule
                        AuthenticationMethod = $authMethod.AuthMethod
                    }
                    $resourcesToExport.Add($resourceInfo)

                    $resourceDefinition = Get-M365DSCResourceDefinition -ResourceName $resourceModule
                    if ($null -ne $resourceDefinition)
                    {
                        $resourcesToProcess.Add($resourceDefinition)
                    }
                    else
                    {
                        Write-Warning -Message "Resource {$resourceModule} was not found in the resource dictionary and will be skipped."
                    }

                    if ($intuneTemplateRegistry.ContainsKey($resourceModule))
                    {
                        $requestedConfigurationPolicyTemplateIds += $intuneTemplateRegistry.$resourceModule
                        $containsConfigurationPolicies = $true
                    }
                }
            }
            catch
            {
                New-M365DSCLogEntry -Message $resourceModule `
                    -Exception $_ `
                    -Source "[M365DSCReverse]$resourceModule"
            }
        }
        $resourcesToProcess = $resourcesToProcess | Sort-Object -Property Name
        Register-M365DSCExportCollectionConsumers -ResourceNames @($resourcesToProcess | ForEach-Object -Process { $_.Name })

        # If the tenant id is not a GUID, retrieve it based on the organization name
        # Only implemented for public cloud tenants
        if (-not ($TenantId -match ('^(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}$')))
        {
            try
            {
                Write-Verbose -Message 'Retrieving Tenant Id based on provided organization name.'
                $tenantGuid = (Invoke-RestMethod -Uri "https://login.microsoftonline.com/$organization/.well-known/openid-configuration" -Method Get).authorization_endpoint.Split('/')[3]
                $currentStringReplacementMap = Get-M365DSCStringReplacementMap
                if (-not $currentStringReplacementMap.ContainsKey($tenantGuid))
                {
                    $currentStringReplacementMap.Add($tenantGuid, 'TenantGuid')
                    Set-M365DSCStringReplacementMap -Map $currentStringReplacementMap
                }
            }
            catch
            {
                Write-Warning -Message "Failed to resolve current tenant id from organization name '$organization'. Not replacing tenant id in exported configuration.
         If you want to have your tenant id replaced in the export, use the -TokenReplacement parameter of Export-M365DSCConfiguration."
            }
        }

        Confirm-M365DSCDependencies
        $partialExportName = $Global:PartialExportFileName
        $synchronizedHashtable = [System.Collections.Concurrent.ConcurrentDictionary[System.String, System.Object]]::new()
        [void]$synchronizedHashtable.TryAdd('ResourceCounter', 1)
        [void]$synchronizedHashtable.TryAdd('ResourcesResult', [System.Collections.Concurrent.ConcurrentDictionary[System.String, System.String]]::new())
        [void]$synchronizedHashtable.TryAdd('ResourceStatus', [System.Collections.Concurrent.ConcurrentDictionary[System.String, System.String]]::new())
        [void]$synchronizedHashtable.TryAdd('InstanceCounts', [System.Collections.Concurrent.ConcurrentDictionary[System.String, System.Int32]]::new())
        [void]$synchronizedHashtable.TryAdd('BusyWorkers', 0)
        $resourceDictionary = Get-M365DSCResourcesDictionary
        $M365DSCStringReplacementMap = Get-M365DSCStringReplacementMap
        $m365dscModulePath = (Get-Module -Name 'Microsoft365DSC').Path
        $workQueue = [System.Collections.Concurrent.ConcurrentQueue[System.Object]]::new()
        $telemetryContext = Get-M365DSCTelemetryContext
        $exportScriptBlock = {
            if ($null -eq (Get-Module -Name 'Microsoft365DSC'))
            {
                Import-Module -Name $using:m365dscModulePath -DisableNameChecking -ErrorAction Stop
            }
            $Global:MaximumFunctionCount = 32768
            $Global:PartialExportFileName = $using:partialExportName
            if ($using:Parallel)
            {
                $Global:M365DSCSkipDependenciesValidation = $true
                $Global:M365DSCStringReplacementMap = $using:M365DSCStringReplacementMap
            }
            $Global:M365DSCExportInProgress = $true
            Set-M365DSCResourcesDictionary -DscResourceDictionary $using:resourceDictionary
            Set-M365DSCTelemetryContext -Context $using:telemetryContext
            $sharedState = $using:synchronizedHashtable
            $workQueue = $using:workQueue
            [System.Threading.Monitor]::Enter($sharedState)
            try
            {
                $sharedState.BusyWorkers++
            }
            finally
            {
                [System.Threading.Monitor]::Exit($sharedState)
            }
            try
            {
                $resource = $null
                while ($workQueue.TryDequeue([ref] $resource))
                {
                    $resourceName = $resource.Name
                    $mostSecureAuthMethod = ($using:allSupportedResourcesWithMostSecureAuthMethod | Where-Object -Property Resource -EQ $resourceName).AuthMethod

                    $parameters = @{}
                    switch ($mostSecureAuthMethod)
                    {
                        { $_ -in 'CertificateThumbprint', 'CertificatePath', 'ApplicationSecret' }
                        {
                            $parameters.Add('ApplicationId', $using:ApplicationId)
                            $parameters.Add('TenantId', $using:TenantId)
                        }
                        'CertificateThumbprint'
                        {
                            $parameters.Add('CertificateThumbprint', $using:CertificateThumbprint)
                        }
                        'CertificatePath'
                        {
                            $parameters.Add('CertificatePath', $using:CertificatePath)
                            $parameters.Add('CertificatePassword', $using:CertificatePassword)
                        }
                        'ApplicationSecret'
                        {
                            # TODO: Update during next breaking change, when ApplicationSecret is changed to PSCredential
                            $applicationSecretValue = New-Object System.Management.Automation.PSCredential ('ApplicationSecret', (ConvertTo-SecureString $using:ApplicationSecret -AsPlainText -Force))
                            $parameters.Add('ApplicationSecret', $applicationSecretValue)
                        }
                        { $_ -in 'Credentials', 'CredentialsWithApplicationId' }
                        {
                            if ($using:AuthMethods -contains 'CredentialsWithApplicationId')
                            {
                                $parameters.Add('ApplicationId', $using:ApplicationId)
                            }
                            $parameters.Add('Credential', $using:Credential)
                        }
                        'CredentialsWithTenantId'
                        {
                            $parameters.Add('Credential', $using:Credential)
                            $parameters.Add('TenantId', $using:TenantId)
                        }
                        'ManagedIdentity'
                        {
                            $parameters.Add('ManagedIdentity', $using:ManagedIdentity)
                            $parameters.Add('TenantId', $using:TenantId)
                        }
                        'AccessTokens'
                        {
                            $parameters.Add('AccessTokens', $using:AccessTokens)
                            $parameters.Add('TenantId', $using:TenantId)
                        }
                    }

                    if ($using:ComponentsToSkip -notcontains $resourceName)
                    {
                        [System.Threading.Monitor]::Enter($sharedState)
                        try
                        {
                            $counter = $sharedState.ResourceCounter++
                        }
                        finally
                        {
                            [System.Threading.Monitor]::Exit($sharedState)
                        }
                        Write-M365DSCHost -Message "[$counter/$($using:resourcesToExport.Count)] Extracting [" -DeferWrite
                        Write-M365DSCHost -Message $resourceName -ForegroundColor Green -DeferWrite
                        Write-M365DSCHost -Message '] using {' -DeferWrite
                        Write-M365DSCHost -Message $mostSecureAuthMethod -ForegroundColor Cyan -DeferWrite
                        Write-M365DSCHost -Message '}...' -DeferWrite
                        $exportString = [System.Text.StringBuilder]::new()
                        if ($using:GenerateInfo)
                        {
                            $exportString.Append("`r`n        # For information on how to use this resource, please refer to:`r`n") | Out-Null
                            $exportString.Append("        # https://github.com/microsoft/Microsoft365DSC/wiki/$($resource.Name)`r`n") | Out-Null
                        }

                        # Check if filters for the current resource were specified.
                        $resourceFilter = $null
                        $filterExists = Test-M365DSCResourceProperty -ResourceName $resourceName -PropertyName 'Filter'
                        if ($filterExists -and $null -ne $using:Filters -and ($using:Filters).Keys.Where({ $_ -eq $resourceName }))
                        {
                            $resourceFilter = ($using:Filters).$resourceName
                            if ($filterExists)
                            {
                                $parameters.Add('Filter', $resourceFilter)
                            }
                            elseif ($null -ne $resourceFilter)
                            {
                                Write-M365DSCHost -Message "    `r`n$($Global:M365DSCEmojiYellowCircle) You specified a filter for resource {$resourceName} but it doesn't support filters. Filter will be ignored and all instances of the resource will be captured." -ForegroundColor DarkYellow -CommitWrite
                            }
                        }

                        # Check whether the resource's export supports -SubscriptionId.
                        $supportsSubscriptionId = Test-M365DSCResourceProperty -ResourceName $resourceName -PropertyName 'SubscriptionId'

                        if ($supportsSubscriptionId -and -not [System.String]::IsNullOrEmpty($using:SubscriptionId))
                        {
                            $parameters.Add('SubscriptionId', $using:SubscriptionId)
                        }

                        # Check for ErrorAction Preference
                        $parameters.Add('ErrorAction', $using:ErrorActionPreference)

                        $Global:M365DSCExportInstanceTally = 0
                        try
                        {
                            $exportOutput = Invoke-M365DSCResourceMethod -ResourceName $resourceName -MethodName 'Export' -Parameters $parameters
                            $exportString.Append($exportOutput) | Out-Null
                            [void]$sharedState.ResourcesResult.TryAdd($resourceName, $exportString.ToString())
                            [void]$sharedState.ResourceStatus.TryAdd($resourceName, 'Succeeded')
                        }
                        catch
                        {
                            Write-M365DSCHost -Message "$($Global:M365DSCEmojiRedX)`r`n    An error occurred while exporting resource {$resourceName}: $($_.Exception.Message)" -ForegroundColor Red -CommitWrite
                            [void]$sharedState.ResourceStatus.TryAdd($resourceName, 'Failed')
                            if ($ErrorActionPreference -eq 'Stop')
                            {
                                throw $_
                            }
                        }
                        finally
                        {
                            [void]$sharedState.InstanceCounts.TryAdd($resourceName, $Global:M365DSCExportInstanceTally)
                            $Global:M365DSCExportInstanceTally = $null
                            Complete-M365DSCExportCollectionConsumer -ResourceName $resourceName
                        }
                    }
                }
            }
            finally
            {
                [System.Threading.Monitor]::Enter($sharedState)
                try
                {
                    $sharedState.BusyWorkers--
                }
                finally
                {
                    [System.Threading.Monitor]::Exit($sharedState)
                }
            }

            # ExchangeOnlineManagement references each connection's runspace until it is disconnected.
            # Disconnecting while another worker runs Exchange cmdlets breaks that worker.
            if ($using:Parallel -and $null -ne (Get-Module -Name 'ExchangeOnlineManagement'))
            {
                while ($sharedState.BusyWorkers -gt 0)
                {
                    Start-Sleep -Milliseconds 250
                }
                $loadedModuleFolders = @(Get-Module).ModuleBase
                $ownConnections = @(Get-ConnectionInformation -ErrorAction SilentlyContinue | Where-Object -FilterScript { $loadedModuleFolders -contains $_.ModuleName })
                foreach ($connection in $ownConnections)
                {
                    Disconnect-ExchangeOnline -ConnectionId $connection.ConnectionId -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                }
            }
        }

        if ($containsConfigurationPolicies)
        {
            $null = New-M365DSCConnection -Workload MicrosoftGraph -InboundParameters @{
                Credential = $Credential
                ApplicationId = $ApplicationId
                ApplicationSecret = $ApplicationSecret
                CertificateThumbprint = $CertificateThumbprint
                CertificatePath = $CertificatePath
                CertificatePassword = $CertificatePassword
                TenantId = $TenantId
                ManagedIdentity = $ManagedIdentity
                AccessTokens = $AccessTokens
            }
            $allRequestedConfigurationPolicies = Get-M365DSCArrayFromProperty -PropertyValue (Get-MgBetaDeviceManagementConfigurationPolicy -All `
                -Filter "templateReference/templateFamily ne 'none'" -Property creationSource, description, templateReference, name, technologies, id, roleScopeTagIds, platforms `
                -ExpandProperty 'assignments' | Where-Object {
                    $_.templateReference.templateId -in $requestedConfigurationPolicyTemplateIds
                }
            )
            $policiesById = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new([System.StringComparer]::OrdinalIgnoreCase)
            $batchRequests = @()
            foreach ($policy in $allRequestedConfigurationPolicies)
            {
                $policiesById[[System.String]$policy.id] = $policy
                $batchRequests += @{
                    Id = $policy.id
                    Method = 'GET'
                    Url = "/deviceManagement/configurationPolicies/$($policy.id)/settings?`$expand=settingDefinitions&`$top=1000"
                }
            }
            $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests
            foreach ($policySettings in $batchResponses)
            {
                $policy = $null
                if ($policiesById.TryGetValue([System.String]$policySettings.id, [ref] $policy))
                {
                    $policy.settings = $policySettings.body.value
                }
            }
            [Microsoft365DSC.Intune.ConfigurationPolicyCache]::Populate($allRequestedConfigurationPolicies, [System.Func[System.Object, System.String]]{ param($policy) $policy.templateReference.templateId })
        }

        if ($Parallel)
        {
            if ($Workloads.Count -eq 0)
            {
                $Workloads = Get-M365DSCWorkloadForResource -ResourceName $resourcesToExport.Name
            }

            $queuedResources = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
            foreach ($workload in $Workloads)
            {
                foreach ($resource in ($resourcesToProcess | Where-Object -Property Name -Like "$workload*"))
                {
                    if ($queuedResources.Add($resource.Name))
                    {
                        $workQueue.Enqueue($resource)
                    }
                }
            }

            foreach ($resource in $resourcesToProcess)
            {
                if ($queuedResources.Add($resource.Name))
                {
                    $workQueue.Enqueue($resource)
                }
            }

            # Each worker imports the module once and processes resources of all workloads.
            $workerCount = [System.Math]::Max(1, [System.Math]::Min($ThrottleLimit, $workQueue.Count))
            Write-M365DSCHost -Message "Starting export in parallel mode for workloads {$($Workloads -join ', ')} with $workerCount workers. Initialization may take a while..."
            1..$workerCount | Invoke-Parallel -ScriptBlock $exportScriptBlock -ThrottleLimit $workerCount -Verbose
        }
        else
        {
            Write-M365DSCHost -Message 'Starting export in sequential mode...'
            foreach ($resource in $resourcesToProcess)
            {
                $workQueue.Enqueue($resource)
            }
            $exportScriptBlock = [ScriptBlock]::Create($exportScriptBlock.ToString().Replace('$using:', '$'))
            . $exportScriptBlock
        }

        $Global:M365DSCExportResourceInstancesCount = [System.Int32]($synchronizedHashtable.InstanceCounts.Values | Measure-Object -Sum).Sum
        $Global:M365DSCExportResourceTypes = @($synchronizedHashtable.ResourceStatus.Keys | Sort-Object)
        $synchronizedHashtable['SuccessfulResources'] = @($synchronizedHashtable.ResourceStatus.Values | Where-Object -FilterScript { $_ -eq 'Succeeded' }).Count
        $synchronizedHashtable['FailedResources'] = @($synchronizedHashtable.ResourceStatus.Values | Where-Object -FilterScript { $_ -eq 'Failed' }).Count

        foreach ($resource in $($synchronizedHashtable.ResourcesResult.Keys | Sort-Object))
        {
            [void]$DSCContent.Append($synchronizedHashtable.ResourcesResult[$resource])
        }
        $synchronizedHashtable.ResourcesResult.Clear()

        # Post-process: inject DependsOn declarations and generate stub blocks
        if ($IncludeDependencies.IsPresent)
        {
            $processedContent = Add-M365DSCExportDependsOn -DSCContent $DSCContent.ToString()
            $DSCContent = [System.Text.StringBuilder]::new()
            $DSCContent.Append($processedContent) | Out-Null
        }

        foreach ($pair in (Get-M365DSCStringReplacementMap).GetEnumerator())
        {
            Add-ConfigurationDataEntry -Node 'NonNodeData' `
                -Key $pair.Value `
                -Value $pair.Key `
                -Description "Placeholder for sensitive data - $($pair.Value)"
        }

        # Close the Node and Configuration declarations
        $DSCContent.Append("    }`r`n") | Out-Null
        $DSCContent.Append("}`r`n") | Out-Null

        # Azure Automation Check
        $AzureAutomation = $false
        if ($env:AZUREPS_HOST_ENVIRONMENT -like 'AzureAutomation*')
        {
            $AzureAutomation = $true
        }

        $launchCommand = "$ConfigurationName -ConfigurationData .\ConfigurationData.psd1"
        switch ($AuthMethods)
        {
            'CertificatePath'
            {
                $credsContent = ''
                $credsContent += '        $CredsCertificatePassword = Get-Credential -Message "Certificate Password"'
                $credsContent += "`r`n"
                $startPosition = $DSCContent.ToString().IndexOf('<# Credentials #>') + 19
                $DSCContent = $DSCContent.Insert($startPosition, $credsContent)
                $launchCommand += " -CertificatePassword `$CredsCertificatePassword"
            }
            { $_ -in 'Credentials', 'CredentialsWithApplicationId' }
            {
                #region Add the Prompt for Required Credentials at the top of the Configuration
                $credsContent = ''
                $credsContent += '        $CredsCredential ' + "= Get-Credential -Message `"Credentials`"`r`n"
                $credsContent += "`r`n"
                $startPosition = $DSCContent.ToString().IndexOf('<# Credentials #>') + 19
                $DSCContent = $DSCContent.Insert($startPosition, $credsContent)
                $launchCommand += " -Credential `$CredsCredential"
                #endregion
            }
        }

        $DSCContent.Append("`r`n") | Out-Null
        $DSCContent.Append("$launchCommand") | Out-Null

        #region Benchmarks
        $M365DSCExportEndTime = [System.DateTime]::Now
        $timeTaken = New-TimeSpan -Start ($M365DSCExportStartTime.ToString()) `
            -End ($M365DSCExportEndTime.ToString())
        Write-M365DSCHost -Message "$($Global:M365DSCEmojiHourglass) Export took {" -DeferWrite
        Write-M365DSCHost -Message "$($timeTaken.TotalSeconds) seconds" -DeferWrite -ForegroundColor Cyan
        Write-M365DSCHost -Message '} for {' -DeferWrite
        Write-M365DSCHost -Message "$($Global:M365DSCExportResourceInstancesCount) instances" -DeferWrite -ForegroundColor Magenta
        Write-M365DSCHost -Message '}' -CommitWrite
        Write-M365DSCHost -Message "Successful exports: {$($synchronizedHashtable.SuccessfulResources)}"
        Write-M365DSCHost -Message "Failed exports: {$($synchronizedHashtable.FailedResources)}"
        if ($($synchronizedHashtable.FailedResources) -eq 0)
        {
            $Message = "$($Global:M365DSCEmojiGreenCheckmark) Export completed successfully."
            Write-M365DSCHost -Message $Message -ForegroundColor Green
        }
        else
        {
            $Message = "$($Global:M365DSCEmojiRedX) Export completed with errors."
            Write-M365DSCHost -Message $Message -ForegroundColor Red
        }
        Send-M365DSCPushNotification -Body $Message
        #endregion

        $sessions = Get-PSSession | Where-Object -FilterScript { $_.Name -like 'SfBPowerShellSessionViaTeamsModule_*' -or `
                $_.Name -like 'ExchangeOnlineInternalSession*' }
        foreach ($session in $sessions)
        {
            try
            {
                Write-Verbose -Message "Closing PSSession {$($session.Name)}"
                Remove-PSSession $session | Out-Null
            }
            catch
            {
                Write-Verbose -Message $_
            }
        }

        # Check if configuration validation needs to be performed
        if ($Validate.IsPresent)
        {
            Write-M365DSCHost -Message "$($Global:M365DSCMagnifyingGlass) Starting configuration validation..."
            [Array]$results = Get-M365DSCConfigurationConflict -ConfigurationContent $DSCContent.ToString()
            Write-M365DSCHost -Message 'Results:'
            if ($results.Count -gt 0)
            {
                $errorMessage = ''
                foreach ($issue in $results)
                {
                    $errorMessage += "    - [$($issue.Reason)]: $($issue.InstanceName)`r`n"
                }
                Write-Error -Message $errorMessage -ErrorAction Continue
            }
            else
            {
                Write-M365DSCHost -Message 'No conflicts detected'
            }
        }

        #region Copy Downloaded files back into output folder
        if (($null -ne $Components -and $Components.Contains('SPOApp') -and -not $ComponentsToSkip.Contains('SPOApp')) -or $AllComponents)
        {
            if ($AuthMethods -contains 'Credentials')
            {
                $filesToDownload = Get-AllSPOPackages -Credential $Credential
            }
            else
            {
                $filesToDownload = Get-AllSPOPackages -ApplicationId $ApplicationId -CertificateThumbprint $CertificateThumbprint `
                    -CertificatePassword $CertificatePassword -TenantId $TenantId -CertificatePath $CertificatePath -ManagedIdentity:$ManagedIdentity.IsPresent
            }
            if ($filesToDownload.Count -gt 0)
            {
                foreach ($fileToCopy in $filesToDownload)
                {
                    if (-not [System.String]::IsNullOrEmpty($env:TEMP))
                    {
                        $filePath = Join-Path $env:TEMP $fileToCopy.Name -Resolve
                        $destPath = Join-Path $OutputDSCPath $fileToCopy.Name
                        Copy-Item -Path $filePath -Destination $destPath -Force
                    }
                }
            }
        }
        #endregion

        if (-not [System.String]::IsNullOrEmpty($FileName))
        {
            $outputDSCFile = $FileName
        }
        else
        {
            $outputDSCFile = 'M365TenantConfig.ps1'
        }

        # Clean empty lines with semi-colons, normally generated from CIMInstances convertions to String.
        $DSCContent = $DSCContent.Replace("`r`n;`r`n", ";`r`n")
        $DSCContent.ToString() | Out-File $outputDSCFile

        try
        {
            $Global:M365DSCExportContentSize = $DSCContent.Length
        }
        catch
        {
            Write-Verbose -Message $_
        }

        if (-not $AzureAutomation -and -not $ManagedIdentity.IsPresent)
        {
            try
            {
                if ($PSEdition -eq 'Desktop' -or $IsWindows -and ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
                {
                    $LCMConfig = Get-DscLocalConfigurationManager
                    if ($null -ne $LCMConfig.CertificateID)
                    {
                        try
                        {
                            # Export the certificate assigned to the LCM
                            $certPath = $OutputDSCPath + 'M365DSC.cer'
                            if (Test-Path $certPath)
                            {
                                Remove-Item $certPath -Force
                            }
                            Export-Certificate -FilePath $certPath `
                                -Cert "cert:\LocalMachine\my\$($LCMConfig.CertificateID)" `
                                -Type CERT `
                                -NoClobber | Out-Null
                        }
                        catch
                        {
                            New-M365DSCLogEntry -Message 'Error while exporting the DSC certificate:' `
                                -Exception $_ `
                                -Source $($MyInvocation.MyCommand.Source) `
                                -TenantId $TenantId `
                                -Credential $Credential
                        }

                        Add-ConfigurationDataEntry -Node 'localhost' `
                            -Key 'CertificateFile' `
                            -Value 'M365DSC.cer' `
                            -Description 'Path of the certificate used to encrypt credentials in the file.'
                    }
                }
                else
                {
                    Write-Verbose -Message "Cannot export Local Configuration Manager settings. This process isn't executed with Administrative Privileges."
                }
            }
            catch
            {
                Write-Verbose -Message 'Could not retrieve current Windows Principal. This may be due to the fact that the current OS is not Windows.'
            }
        }
        $outputConfigurationData = '.\ConfigurationData.psd1'
        New-ConfigurationDataDocument -Path $outputConfigurationData
        if ($shouldOpenOutputDirectory)
        {
            try
            {
                Invoke-Item -Path $OutputDSCPath
            }
            catch
            {
                Write-Verbose -Message $_
            }
        }

        # Close the partial export StreamWriter
        Close-M365DSCPartialExport

        # Remove Temp Partial Export File
        if (-not [System.String]::IsNullOrEmpty($env:TEMP))
        {
            $partialPath = Join-Path $env:TEMP -ChildPath "$($Global:PartialExportFileName)"
            if (Test-Path $partialPath)
            {
                Remove-Item -Path $partialPath -Force
            }
        }

        Pop-Location
        if ($WithStatistics)
        {
            @{
                ExportDurationInSeconds = $timeTaken.TotalSeconds
                ExportedResourceCount   = $synchronizedHashtable.SuccessfulResources
                FailedResourceCount     = $synchronizedHashtable.FailedResources
                TotalResourceCount      = $synchronizedHashtable.SuccessfulResources + $synchronizedHashtable.FailedResources
            }
        }
    }
    catch
    {
        # Close the partial export StreamWriter
        Close-M365DSCPartialExport

        if (-not [System.String]::IsNullOrEmpty($env:TEMP))
        {
            $partialPath = Join-Path $env:TEMP -ChildPath "$($Global:PartialExportFileName)"
            Write-M365DSCHost -Message "Partial Export file was saved at: $partialPath"
        }

        throw
    }
}

<#
.DESCRIPTION
    This function gets all resources for the specified workloads

.FUNCTIONALITY
    Internal, Hidden
#>
function Get-M365DSCResourcesByWorkloads
{
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[System.String[]]])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Workloads,

        [Parameter()]
        [ValidateSet('Default', 'Full')]
        [System.String]
        $Mode = 'Default'
    )

    $components = [System.Collections.Generic.List[System.String[]]]::new()
    foreach ($Workload in $Workloads)
    {
        Write-M365DSCHost -Message "Finding all resources for workload {$Workload} and Mode {$Mode}" -ForegroundColor Gray

        $fullComponents = Get-M365DSCResourcesByExportMode -Mode 'Full' -ExcludeConfigurationResources
        foreach ($resource in $Script:allM365DSCResources)
        {
            if ($resource.StartsWith($Workload, 'CurrentCultureIgnoreCase') -and
                ($Mode -eq 'Full' -or `
                ($Mode -eq 'Default' -and -not $fullComponents.Contains($resource))))
            {
                $components.Add($resource)
            }
        }
    }

    return $components
}

Export-ModuleMember -Function @(
    'Start-M365DSCConfigurationExtract'
)
