$Script:M365DSCStringReplacementMap = @{}
$Script:M365DSCMandatoryKeyCache = @{}
$Script:M365DSCCompiledRegexCache = @{}
$Script:M365DSCAuthenticationParameterSet = @{
    ServicePrincipalWithThumbprint = @('ApplicationId', 'CertificateThumbprint', 'TenantId')
    ServicePrincipalWithSecret = @('ApplicationId', 'ApplicationSecret', 'TenantId')
    ServicePrincipalWithPath = @('ApplicationId', 'CertificatePath', 'CertificatePassword', 'TenantId')
    CredentialsWithTenantId = @('Credential', 'TenantId')
    CredentialsWithApplicationId = @('Credential', 'ApplicationId')
    Credentials = @('Credential')
    ManagedIdentity = @('ManagedIdentity', 'TenantId')
    AccessTokens = @('AccessTokens', 'TenantId')
}
$Script:M365DSCRelationIndex = $null
$Script:M365DSCExportComponentNames = $null

<#
.SYNOPSIS
    Returns the resource names offered by the Components argument completer.

.DESCRIPTION
    Resolved on first completion rather than at import, because the manifest reader lives in a
    module that loads after this one.

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.String[]
#>
function Get-M365DSCExportComponentName
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param()

    if ($null -ne $Script:M365DSCExportComponentNames)
    {
        return $Script:M365DSCExportComponentNames
    }

    $names = @()
    $dscResourcesFolder = Join-Path -Path $PSScriptRoot -ChildPath '../DscResources/'
    if (Test-Path -Path $dscResourcesFolder)
    {
        $names = @(Get-ChildItem -Path $dscResourcesFolder -Recurse -Filter 'MSFT_*.psm1' -File | ForEach-Object {
            $_.Name -replace 'MSFT_', '' -replace '.psm1', ''
        })
    }

    if ($names.Count -eq 0)
    {
        $manifestPath = Join-Path -Path $PSScriptRoot -ChildPath '../Microsoft365DSC.psd1'
        if (Test-Path -Path $manifestPath)
        {
            $names = @((Import-PowerShellDataFile -Path $manifestPath).DscResourcesToExport)
        }
    }

    $Script:M365DSCExportComponentNames = [System.String[]] $names
    return $Script:M365DSCExportComponentNames
}

Register-ArgumentCompleter -CommandName Export-M365DSCConfiguration -ParameterName Components -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $resources = (Get-M365DSCExportComponentName) -like "$wordToComplete*"
    foreach ($resource in $resources)
    {
        [System.Management.Automation.CompletionResult]::new($resource, $resource, 'ParameterValue', $resource)
    }
}

<#
.SYNOPSIS
    Exports tenant configuration to Microsoft365DSC configuration content.

.DESCRIPTION
    Entry point for ReverseDSC export.
    Validates authentication inputs, resolves target resources, executes extraction, and returns the generated configuration content.

.PARAMETER LaunchWebUI
    Indicates that the export Web UI should be launched.

.PARAMETER Path
    Specifies the output path for exported configuration files.

.PARAMETER FileName
    Specifies the output configuration file name.

.PARAMETER ConfigurationName
    Specifies the generated DSC configuration name.

.PARAMETER Components
    Specifies component names to export.

.PARAMETER ExcludeComponents
    Specifies component names to exclude.

.PARAMETER Workloads
    Specifies workloads used to derive components.

.PARAMETER Mode
    Specifies the export mode.

.PARAMETER GenerateInfo
    Indicates whether informational metadata should be generated in export output.

.PARAMETER Filters
    Specifies resource-level filters used during export.

.PARAMETER ApplicationId
    Specifies the application id used for app-based authentication.

.PARAMETER TenantId
    Specifies the tenant id or tenant domain used for authentication.

.PARAMETER ApplicationSecret
    Specifies the application secret used for app-based authentication.

.PARAMETER CertificateThumbprint
    Specifies the certificate thumbprint used for app-based authentication.

.PARAMETER Credential
    Specifies delegated credentials used for authentication.

.PARAMETER CertificatePassword
    Specifies the password used to read the certificate file.

.PARAMETER CertificatePath
    Specifies the certificate file path used for app-based authentication.

.PARAMETER ManagedIdentity
    Indicates that managed identity authentication should be used.

.PARAMETER AccessTokens
    Specifies one or more pre-acquired access tokens.

.PARAMETER SubscriptionId
    Specifies the Azure subscription id used by Azure resources.

.PARAMETER Validate
    Indicates whether the exported configuration should be validated.

.PARAMETER Parallel
    Indicates whether export should execute in parallel.

.PARAMETER ThrottleLimit
    Specifies the number of parallel workers. Requires Parallel. Default: 5.

.PARAMETER TokenReplacement
    Specifies token replacement mappings applied to exported content.

.PARAMETER WithStatistics
    Indicates whether export statistics should be collected.

.PARAMETER IncludeDependencies
    Indicates whether dependency extraction and DependsOn generation should run.

.EXAMPLE
    PS> Export-M365DSCConfiguration -Components @("AADApplication", "AADConditionalAccessPolicy", "AADGroupsSettings") -Credential $Credential

.EXAMPLE
    PS> Export-M365DSCConfiguration -Mode 'Default' -ApplicationId '2560bb7c-bc85-415f-a799-841e10ec4f9a' -TenantId 'contoso.sharepoint.com' -ApplicationSecret 'abcdefghijkl'

.EXAMPLE
    PS> Export-M365DSCConfiguration -Components @("AADApplication", "AADConditionalAccessPolicy", "AADGroupsSettings") -Credential $Credential -Path 'C:\DSC' -FileName 'MyConfig.ps1'

.EXAMPLE
    PS> Export-M365DSCConfiguration -Credential $Credential -Filters @{AADApplication = "DisplayName eq 'MyApp'"} -TokenReplacement @{ 'alternate-email.onmicrosoft.com' = 'AlternateEmail' }

.EXAMPLE
    PS> Export-M365DSCConfiguration -Workloads @("SPO") -ExcludeComponents @("SPOPropertyBag") -Credential $Credential

.EXAMPLE
    PS> Export-M365DSCConfiguration -Workloads @("SPO") -ApplicationId $clientId -TenantId $tenantName -CertificateThumbprint $certThumbprint -IncludeDependencies

.EXAMPLE
    PS> Export-M365DSCConfiguration -Workloads @("SPO") -ApplicationId $clientId -TenantId $tenantName -CertificateThumbprint $certThumbprint -IncludeDependencies -Parallel -ThrottleLimit 2

.FUNCTIONALITY
    Public
#>
function Export-M365DSCConfiguration
{
    [CmdletBinding(DefaultParameterSetName = 'Export')]
    param
    (
        [Parameter(ParameterSetName = 'WebUI')]
        [Switch]
        $LaunchWebUI,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.String]
        $Path,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.String]
        $FileName,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.String]
        $ConfigurationName,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.String[]]
        $Components,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.String[]]
        $ExcludeComponents,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [ValidateSet('AAD', 'ADO', 'AZURE', 'COMMERCE', 'DEFENDER', 'EXO', 'FABRIC', 'INTUNE', 'O365', 'OD', 'PLANNER', 'PP', 'SC', 'SENTINEL', 'SH', 'SPO', 'TEAMS', 'VIVA')]
        [System.String[]]
        $Workloads,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [ValidateSet('Default', 'Full')]
        [System.String]
        $Mode = 'Default',

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.Boolean]
        $GenerateInfo = $false,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.Collections.Hashtable]
        $Filters,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.String]
        $ApplicationId,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [ValidateScript({
                $invalid = $false
                if ([System.Guid]::TryParse($_, [ref][System.Guid]::Empty))
                {
                    throw 'Please provide the tenant name (e.g., contoso.onmicrosoft.com or contoso.onsovcloud.com for sovereign tenants) for TenantId instead of its GUID.'
                }
                $invalid = $_ -notmatch '.onmicrosoft.' -and $_ -notmatch '.onsovcloud.'
                if ($invalid)
                {
                    Write-Warning -Message 'We recommend providing the TenantId property in the format of <tenant>.onmicrosoft.* or <tenant>.onsovcloud.* for sovereign tenants.'
                }
                return $true
            })]
        [System.String]
        $TenantId,

        # TODO: Change to PSCredential during next breaking change
        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.String]
        $ApplicationSecret,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.String]
        $CertificateThumbprint,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.String]
        $CertificatePath,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [Switch]
        $ManagedIdentity,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.String[]]
        $AccessTokens,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.String]
        $SubscriptionId,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [Switch]
        $Validate,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel', Mandatory = $true)]
        [Switch]
        $Parallel,

        [Parameter(ParameterSetName = 'ExportParallel')]
        [ValidateRange(1, [System.Int32]::MaxValue)]
        [System.Int32]
        $ThrottleLimit = 5,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [System.Collections.Hashtable]
        $TokenReplacement,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [Switch]
        $WithStatistics,

        [Parameter(ParameterSetName = 'Export')]
        [Parameter(ParameterSetName = 'ExportParallel')]
        [Switch]
        $IncludeDependencies
    )

    if ($IncludeDependencies.IsPresent)
    {
        Write-Warning -Message "The -IncludeDependencies parameter is currently in preview. Please review the generated configuration to ensure it captures the dependencies as expected.
         If you encounter any issues or have feedback, please report it at https://github.com/Microsoft365DSC/Microsoft365DSC."
    }

    $currentStartDateTime = [System.DateTime]::Now
    $Global:M365DSCExportInProgress = $true
    $Global:MaximumFunctionCount = 32767

    Clear-M365DSCHostMessageCache

    # Initialize the relation assembly and reset its state for this export session
    Initialize-M365DSCDllLoader -ErrorAction Stop
    [Microsoft365DSC.Relations.ExportInstanceNames]::Reset()
    [Microsoft365DSC.Intune.ConfigurationPolicyCache]::Reset()
    Initialize-M365DSCExportCollectionCache
    Reset-M365DSCConnectionFailureCache

    # Clear performance caches for fresh export
    $Script:M365DSCMandatoryKeyCache = @{}
    $Script:M365DSCCompiledRegexCache = @{}
    Set-M365DSCStringReplacementMap -Clear
    $Global:M365DSCStringReplacementMap = $null
    Clear-ConfigurationDataContent

    # Track cross-resource relations only when the caller asked for DependsOn output.
    [Microsoft365DSC.Relations.ExportRelationSession]::Reset()
    if ($IncludeDependencies.IsPresent)
    {
        $null = New-M365DSCExportRelationSession
    }

    # LaunchWebUI specified, launching that now
    if ($LaunchWebUI)
    {
        Write-Output -InputObject "Launching web page 'https://export.microsoft365dsc.com'"
        explorer 'https://export.microsoft365dsc.com'
        return
    }

    # Suppress Progress overlays
    $Global:ProgressPreference = 'SilentlyContinue'

    # Check ErrorActionPreference - Azure DevOps and other Pipeline environments set it to 'Stop' by default
    if ($ErrorActionPreference -eq 'Stop' -and -not $PSBoundParameters.ContainsKey('ErrorAction'))
    {
        $ErrorActionPreference = 'Continue'
    }

    ##### FIRST CHECK AUTH PARAMETERS
    if ($PSBoundParameters.ContainsKey('Credential') -eq $true -and `
            -not [System.String]::IsNullOrEmpty($Credential))
    {
        if ($Credential.Username -notmatch '.onmicrosoft.' -and $Credential.Username -notmatch '.onsovcloud.')
        {
            Write-Warning -Message 'We recommend providing the username in the format of <tenant>.onmicrosoft.* (or <tenant>.onsovcloud.* for sovereign tenants) for the Credential property.'
        }
    }

    if ($PSBoundParameters.ContainsKey('CertificatePath') -eq $true -and `
            $PSBoundParameters.ContainsKey('CertificatePassword') -eq $false)
    {
        throw 'You have to specify CertificatePassword when you specify CertificatePath'
    }

    if ($PSBoundParameters.ContainsKey('CertificatePassword') -eq $true -and `
            $PSBoundParameters.ContainsKey('CertificatePath') -eq $false)
    {
        throw 'You have to specify CertificatePath when you specify CertificatePassword'
    }

    if ($PSBoundParameters.ContainsKey('ApplicationId') -eq $true -and `
            $PSBoundParameters.ContainsKey('Credential') -eq $false -and `
            $PSBoundParameters.ContainsKey('TenantId') -eq $false)
    {
        throw 'You have to specify TenantId when you specify ApplicationId'
    }

    if ($PSBoundParameters.ContainsKey('ApplicationId') -eq $true -and `
            $PSBoundParameters.ContainsKey('TenantId') -eq $true -and `
            $PSBoundParameters.ContainsKey('Credential') -eq $false -and `
        ($PSBoundParameters.ContainsKey('CertificateThumbprint') -eq $false -and `
                $PSBoundParameters.ContainsKey('ApplicationSecret') -eq $false -and `
                $PSBoundParameters.ContainsKey('CertificatePath') -eq $false))
    {
        throw 'You have to specify ApplicationSecret, CertificateThumbprint or CertificatePath when you specify ApplicationId/TenantId'
    }

    if (($PSBoundParameters.ContainsKey('ApplicationId') -eq $false -or `
                $PSBoundParameters.ContainsKey('TenantId') -eq $false) -and `
        ($PSBoundParameters.ContainsKey('Credential') -eq $false -and `
                $PSBoundParameters.ContainsKey('CertificateThumbprint') -eq $true -or `
                $PSBoundParameters.ContainsKey('ApplicationSecret') -eq $true -or `
                $PSBoundParameters.ContainsKey('CertificatePath') -eq $true))
    {
        throw 'You have to specify ApplicationId and TenantId when you specify ApplicationSecret, CertificateThumbprint or CertificatePath'
    }

    # Default to Credential if no authentication mechanism were provided
    if ($PSBoundParameters.ContainsKey('Credential') -eq $false -and `
            $ManagedIdentity.IsPresent -eq $false -and `
            $PSBoundParameters.ContainsKey('ApplicationId') -eq $false -and `
            $PSBoundParameters.ContainsKey('AccessTokens') -eq $false)
    {
        $Credential = Get-Credential
    }

    #region Telemetry
    $data = [System.Collections.Generic.Dictionary[[System.String], [System.Object]]]::new()

    $data.Add('Path', [System.String]::IsNullOrEmpty($Path))
    $data.Add('FileName', $null -ne [System.String]::IsNullOrEmpty($FileName))
    $data.Add('Components', $Components)
    $data.Add('Workloads', $Workloads)
    #endregion

    Confirm-M365DSCDependencies

    # Make sure we are not connected to Microsoft Graph on another tenant
    # except if connected through MSCloudLoginAssistant - it will handle the connection
    try
    {
        Confirm-M365DSCLoadedModule -ModuleName 'Microsoft.Graph.Authentication'
        $currentConnectionProfile = Get-MSCloudLoginConnectionProfile -Workload 'MicrosoftGraph'
        if ($null -ne (Get-MgContext) -and -not $currentConnectionProfile.Connected)
        {
            Disconnect-MgGraph -ErrorAction Stop | Out-Null
            Reset-MSCloudLoginConnectionProfileContext -Workload 'MicrosoftGraph'
        }
    }
    catch
    {
        Write-Verbose -Message 'No existing connections to Microsoft Graph'
    }

    $Tenant = Get-M365DSCTenantNameFromParameterSet -ParameterSet $PSBoundParameters
    $Script:ConnectionMode = Get-M365DSCAuthenticationMode $PSBoundParameters
    $data.Add('Tenant', $Tenant)
    $currentExportID = (New-Guid).ToString()
    $data.Add('M365DSCExportId', $currentExportID)
    $data.Add('ConnectionMode', $Script:ConnectionMode)

    $telemetryParams = Get-M365DSCTelemetryConnectionParameter
    # Define connection to Graph parameters because it is required by the telemetry.
    if ($null -eq $telemetryParams -or `
        ($null -ne $telemetryParams -and `
                $telemetryParams.Keys.Count -eq 0))
    {
        $telemetryParams = @{
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            ApplicationSecret     = $ApplicationSecret
            CertificateThumbprint = $CertificateThumbprint
            CertificatePassword   = $CertificatePassword
            CertificatePath       = $CertificatePath
            Identity              = $ManagedIdentity.IsPresent
            AccessTokens          = $AccessTokens
        }
        Set-M365DSCTelemetryConnectionParameter -Parameters $telemetryParams
    }

    Add-M365DSCTelemetryEvent -Type 'ExportInitiated' -Data $data
    Initialize-M365DSCResourcesDictionary
    if ($PSBoundParameters.ContainsKey('TokenReplacement'))
    {
        Set-M365DSCStringReplacementMap -Map $TokenReplacement
    }

    $resourceSettings = Get-M365DSCResourceSettings
    try
    {
        if ($null -ne $Workloads)
        {
            Write-M365DSCHost -Message "Exporting Microsoft 365 configuration for Workloads: $($Workloads -join ', ')"
            Start-M365DSCConfigurationExtract -Credential $Credential `
                -Workloads $Workloads `
                -ExcludeComponents $ExcludeComponents `
                -Mode $Mode `
                -Path $Path -FileName $FileName `
                -ConfigurationName $ConfigurationName `
                -ApplicationId $ApplicationId `
                -ApplicationSecret $ApplicationSecret `
                -TenantId $TenantId `
                -CertificateThumbprint $CertificateThumbprint `
                -CertificatePath $CertificatePath `
                -CertificatePassword $CertificatePassword `
                -ManagedIdentity:$ManagedIdentity.IsPresent `
                -AccessTokens $AccessTokens `
                -SubscriptionId $SubscriptionId `
                -GenerateInfo $GenerateInfo `
                -Filters $Filters `
                -Validate:$Validate.IsPresent `
                -Parallel:$Parallel.IsPresent `
                -ThrottleLimit $ThrottleLimit `
                -ResourceSettings $resourceSettings `
                -ErrorAction $ErrorActionPreference `
                -WithStatistics:$WithStatistics.IsPresent `
                -IncludeDependencies:$IncludeDependencies.IsPresent
        }
        elseif ($null -ne $Components)
        {
            Write-M365DSCHost -Message "Exporting Microsoft 365 configuration for Components: $($Components -join ', ')"
            Start-M365DSCConfigurationExtract -Credential $Credential `
                -Components $Components `
                -ExcludeComponents $ExcludeComponents `
                -Path $Path -FileName $FileName `
                -ConfigurationName $ConfigurationName `
                -ApplicationId $ApplicationId `
                -ApplicationSecret $ApplicationSecret `
                -TenantId $TenantId `
                -CertificateThumbprint $CertificateThumbprint `
                -CertificatePath $CertificatePath `
                -CertificatePassword $CertificatePassword `
                -ManagedIdentity:$ManagedIdentity.IsPresent `
                -AccessTokens $AccessTokens `
                -SubscriptionId $SubscriptionId `
                -GenerateInfo $GenerateInfo `
                -Filters $Filters `
                -Validate:$Validate.IsPresent `
                -Parallel:$Parallel.IsPresent `
                -ThrottleLimit $ThrottleLimit `
                -ResourceSettings $resourceSettings `
                -ErrorAction $ErrorActionPreference `
                -WithStatistics:$WithStatistics.IsPresent `
                -IncludeDependencies:$IncludeDependencies.IsPresent
        }
        elseif ($null -ne $Mode)
        {
            Write-M365DSCHost -Message "Exporting Microsoft 365 configuration for Mode: $Mode"
            Start-M365DSCConfigurationExtract -Credential $Credential `
                -Mode $Mode `
                -ExcludeComponents $ExcludeComponents `
                -Path $Path -FileName $FileName `
                -ConfigurationName $ConfigurationName `
                -ApplicationId $ApplicationId `
                -ApplicationSecret $ApplicationSecret `
                -TenantId $TenantId `
                -CertificateThumbprint $CertificateThumbprint `
                -CertificatePath $CertificatePath `
                -CertificatePassword $CertificatePassword `
                -ManagedIdentity:$ManagedIdentity.IsPresent `
                -AccessTokens $AccessTokens `
                -SubscriptionId $SubscriptionId `
                -GenerateInfo $GenerateInfo `
                -AllComponents `
                -Filters $Filters `
                -Validate:$Validate.IsPresent `
                -Parallel:$Parallel.IsPresent `
                -ThrottleLimit $ThrottleLimit `
                -ResourceSettings $resourceSettings `
                -ErrorAction $ErrorActionPreference `
                -WithStatistics:$WithStatistics.IsPresent `
                -IncludeDependencies:$IncludeDependencies.IsPresent
        }
    }
    finally
    {
        Reset-M365DSCExportCollectionCache
        Reset-M365DSCConnectionFailureCache
    }

    if ($IncludeDependencies.IsPresent)
    {
        $relationSession = [Microsoft365DSC.Relations.ExportRelationSession]::Current
        if ($null -eq $relationSession -or $relationSession.InstanceCount -eq 0)
        {
            Write-Warning -Message ('No resource instances were recorded for dependency tracking, so no DependsOn ' + `
                'statements were generated. Please report this at https://github.com/Microsoft365DSC/Microsoft365DSC.')
        }
    }

    # Release the export-scoped state held on the relation assembly
    [Microsoft365DSC.Relations.ExportInstanceNames]::Reset()
    [Microsoft365DSC.Relations.ExportRelationSession]::Reset()
    [Microsoft365DSC.Intune.ConfigurationPolicyCache]::Reset()
    Reset-M365DSCExportCollectionCache
    Reset-M365DSCConnectionFailureCache
    $Global:M365DSCExportInProgress = $false

    $data = [System.Collections.Generic.Dictionary[[System.String], [System.Object]]]::new()
    if ([System.String]::IsNullOrEmpty($data.Tenant) -and -not [System.String]::IsNullOrEmpty($TenantId))
    {
        $data.Add('Tenant', $TenantId)
    }
    else
    {
        $data.Add('Tenant', $Tenant)
    }
    $data.Add('M365DSCExportId', $currentExportID)
    $data.Add('ConnectionMode', $Script:ConnectionMode)
    $timeTaken = [System.DateTime]::Now.Subtract($currentStartDateTime)
    $data.Add('TotalSeconds', $timeTaken.TotalSeconds)
    Add-M365DSCTelemetryEvent -Type 'ExportCompleted' -Data $data
}

<#
.SYNOPSIS
    Returns exportable resource names for a selected export mode.

.DESCRIPTION
    Filters resource settings by mode and optionally excludes configuration resources when Full mode is used.

.PARAMETER Mode
    Specifies the export mode used to select resources.

.PARAMETER ExcludeConfigurationResources
    Indicates that configuration-only resources should be excluded in Full mode.

.EXAMPLE
    Get-M365DSCResourcesByExportMode -Mode 'Default'

    This command retrieves all resources that are available in the Default export mode.

.EXAMPLE
    Get-M365DSCResourcesByExportMode -Mode 'Full'

    This command retrieves all resources that are available in the Full export mode.

.OUTPUTS
    System.String[]
#>
function Get-M365DSCResourcesByExportMode
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Default', 'Full')]
        [System.String]
        $Mode,

        [Parameter(Mandatory = $false)]
        [switch]
        $ExcludeConfigurationResources
    )

    $resourceSettings = Get-M365DSCResourceSettings
    $resources = [System.Collections.Generic.List[System.String]]::new($resourceSettings.Keys.Count)
    foreach ($resource in $resourceSettings.Keys)
    {
        if ($Mode -eq 'Default' -and $resourceSettings[$resource].mode -eq 'Configuration')
        {
            $resources.Add($resource)
        }
        elseif ($Mode -eq 'Full')
        {
            if ($ExcludeConfigurationResources -and $resourceSettings[$resource].mode -eq 'Configuration')
            {
                continue
            }
            $resources.Add($resource)
        }
    }

    return $resources.ToArray()
}

<#
.SYNOPSIS
    Builds DSC resource block content for a single exported resource instance.

.DESCRIPTION
    Converts resource export results into DSC text content.
    It normalizes authentication fields, handles escaping rules, and emits resource block content for the target module.

.PARAMETER ResourceName
    Specifies the resource name being rendered.

.PARAMETER ConnectionMode
    Specifies the resolved authentication connection mode.

.PARAMETER ModulePath
    Specifies the path to the resource module used during export rendering.

.PARAMETER Results
    Specifies exported resource values to render.

.PARAMETER Credential
    Specifies delegated credentials used for contextual rendering.

.PARAMETER NoEscape
    Specifies property names that should not be string-escaped.

.PARAMETER SkipAuthenticationUpdate
    Indicates that authentication fields should not be transformed.

.PARAMETER SkipRemoveSpecialCharacters
    Indicates that special characters should not be removed from the resource instance name.

.PARAMETER AllowVariablesInStrings
    Indicates that variable placeholders may be preserved inside strings.

.PARAMETER RawResults
    Specifies the original unprocessed export result values.

.OUTPUTS
    System.String
#>
function Get-M365DSCExportContentForResource
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet('ServicePrincipalWithThumbprint', 'ServicePrincipalWithSecret', 'ServicePrincipalWithPath', 'CredentialsWithTenantId', 'CredentialsWithApplicationId', 'Credentials', 'ManagedIdentity', 'AccessTokens')]
        $ConnectionMode,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ModulePath,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Results,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String[]]
        $NoEscape,

        [Parameter()]
        [switch]
        $SkipAuthenticationUpdate,

        [Parameter()]
        [switch]
        $SkipRemoveSpecialCharacters,

        [Parameter()]
        [switch]
        $AllowVariablesInStrings,

        [Parameter()]
        [System.Collections.Hashtable]
        $RawResults
    )

    $OrganizationName = ''
    if ($ConnectionMode -like 'ServicePrincipal*' -or `
            $ConnectionMode -eq 'ManagedIdentity')
    {
        $OrganizationName = $Results.TenantId
    }
    elseif ($null -ne $Credential.UserName)
    {
        $OrganizationName = $Credential.UserName.Split('@')[1]
    }
    else
    {
        $OrganizationName = ''
    }

    if (-not $SkipAuthenticationUpdate)
    {
        $withoutAuthentication = Update-M365DSCExportAuthenticationResults -ConnectionMode $ConnectionMode `
            -Results $Results
        $Results = $withoutAuthentication.Results
        $NoEscape += $withoutAuthentication.NoEscape
    }
    $NoEscape = $NoEscape | Select-Object -Unique

    $primaryKey = ''
    if ($Script:M365DSCMandatoryKeyCache.ContainsKey($ResourceName))
    {
        $Keys = $Script:M365DSCMandatoryKeyCache[$ResourceName]
    }
    else
    {
        $Keys = @(Get-M365DSCResourceMandatoryKey -ResourceName $ResourceName)
        $Script:M365DSCMandatoryKeyCache[$ResourceName] = $Keys
    }

    if ($Keys.Contains('IsSingleInstance'))
    {
        $primaryKey = ''
    }
    elseif ($Keys.Contains('DisplayName') -and -not [System.String]::IsNullOrEmpty($Results.DisplayName))
    {
        $primaryKey = $Results.DisplayName
    }
    elseif ($Keys.Contains('Name'))
    {
        $primaryKey = $Results.Name
    }
    elseif ($Keys.Contains('Title'))
    {
        $primaryKey = $Results.Title
    }
    elseif ($Keys.Contains('Identity'))
    {
        $primaryKey = $Results.Identity
    }
    elseif ($Keys.Contains('Id'))
    {
        $primaryKey = $Results.Id
    }
    elseif ($Keys.Contains('CDNType'))
    {
        $primaryKey = $Results.CDNType
    }
    elseif ($Keys.Contains('WorkspaceName'))
    {
        $primaryKey = $Results.WorkspaceName
    }
    elseif ($Keys.Contains('OrganizationName'))
    {
        $primaryKey = $Results.OrganizationName
    }
    elseif ($Keys.Contains('DomainName'))
    {
        $primaryKey = $Results.DomainName
    }
    elseif ($Keys.Contains('UserPrincipalName'))
    {
        $primaryKey = $Results.UserPrincipalName
    }

    if ([String]::IsNullOrEmpty($primaryKey) -and -not $Keys.Contains('IsSingleInstance'))
    {
        foreach ($Key in $Keys)
        {
            $primaryKey += $Results.$Key
        }
    }

    $instanceName = $ResourceName
    if (-not [System.String]::IsNullOrEmpty($primaryKey))
    {
        if ($SkipRemoveSpecialCharacters)
        {
            $instanceName += "-$primaryKey"
        }
        else
        {
            $instanceName += "-$(Remove-M365DSCSpecialCharacters -String $primaryKey)"
        }
    }

    if ($Results.ContainsKey('Workload'))
    {
        $instanceName += "-$($Results.Workload)"
    }

    # Check to see if a resource with this exact name was already exported, if so, append a
    # number to the end. Claiming the name is one atomic operation on the shared registry, so
    # two runspaces of a parallel export cannot both decide the same name is free.
    Initialize-M365DSCDllLoader -ErrorAction Stop
    $instanceName = [Microsoft365DSC.Relations.ExportInstanceNames]::Reserve($instanceName)

    # Record the instance and resolve its cross-resource relations
    $relationSession = Get-M365DSCExportRelationSession
    if ($null -ne $relationSession)
    {
        $resolveResults = $Results
        if ($null -ne $RawResults)
        {
            $resolveResults = $RawResults
        }

        $relationSession.RegisterInstance($ResourceName, $instanceName, $primaryKey, $resolveResults)
        $relationSession.ResolveRelations($ResourceName, $instanceName, $resolveResults)
    }

    $content = [System.Text.StringBuilder]::new()
    [void]$content.Append("        $ResourceName `"$instanceName`"`r`n")
    [void]$content.Append("        {`r`n")
    $partialContent = Get-DSCBlock -Params $Results -ModulePath $ModulePath -NoEscape $NoEscape -AllowVariablesInStrings:$AllowVariablesInStrings

    if ($partialContent.IndexOf($OrganizationName, [System.StringComparison]::OrdinalIgnoreCase) -gt 0)
    {
        if (-not $Script:M365DSCCompiledRegexCache.ContainsKey("OrgColon_$OrganizationName"))
        {
            $Script:M365DSCCompiledRegexCache["OrgColon_$OrganizationName"] = [regex]::new([regex]::Escape($OrganizationName + ':'), 'IgnoreCase, Compiled')
            $Script:M365DSCCompiledRegexCache["OrgAt_$OrganizationName"] = [regex]::new([regex]::Escape('@' + $OrganizationName), 'IgnoreCase, Compiled')
            $Script:M365DSCCompiledRegexCache["Org_$OrganizationName"] = [regex]::new([regex]::Escape($OrganizationName), 'IgnoreCase, Compiled')
        }
        $partialContent = $Script:M365DSCCompiledRegexCache["OrgColon_$OrganizationName"].Replace($partialContent, "`$(`$OrganizationName):")
        $partialContent = $Script:M365DSCCompiledRegexCache["OrgAt_$OrganizationName"].Replace($partialContent, "@`$OrganizationName")
        $partialContent = $Script:M365DSCCompiledRegexCache["Org_$OrganizationName"].Replace($partialContent, "`$OrganizationName")
    }

    # Apply additional string to variable replacements from mapping
    if ($Global:M365DSCStringReplacementMap)
    {
        Set-M365DSCStringReplacementMap -Map $Global:M365DSCStringReplacementMap
    }
    if ($null -ne $Script:M365DSCStringReplacementMap -and $Script:M365DSCStringReplacementMap.Count -gt 0)
    {
        foreach ($entry in $Script:M365DSCStringReplacementMap.GetEnumerator())
        {
            $target = $entry.Key
            $varName = $entry.Value
            if ([System.String]::IsNullOrEmpty($target) -or [System.String]::IsNullOrEmpty($varName))
            {
                Write-Verbose -Message "Skipping invalid string replacement map entry: Key = '$target', VariableName = '$varName'"
                continue
            }
            # Skip if already handled as OrganizationName
            if ($OrganizationName -and ($target -ieq $OrganizationName))
            {
                Write-Verbose -Message "Skipping replacement for target [$target] because it matches the OrganizationName: '$OrganizationName'"
                continue
            }

            if ($partialContent.IndexOf($target, [System.StringComparison]::OrdinalIgnoreCase) -gt 0)
            {
                $cacheKeyBase = "Map_$target"
                if (-not $Script:M365DSCCompiledRegexCache.ContainsKey("${cacheKeyBase}_colon"))
                {
                    $Script:M365DSCCompiledRegexCache["${cacheKeyBase}_colon"] = [regex]::new([regex]::Escape($target + ':'), 'IgnoreCase, Compiled')
                    $Script:M365DSCCompiledRegexCache["${cacheKeyBase}_at"] = [regex]::new([regex]::Escape('@' + $target), 'IgnoreCase, Compiled')
                    $Script:M365DSCCompiledRegexCache["${cacheKeyBase}_plain"] = [regex]::new([regex]::Escape($target), 'IgnoreCase, Compiled')
                }
                $partialContent = $Script:M365DSCCompiledRegexCache["${cacheKeyBase}_colon"].Replace($partialContent, "`$(`$ConfigurationData.NonNodeData.$varName):")
                $partialContent = $Script:M365DSCCompiledRegexCache["${cacheKeyBase}_at"].Replace($partialContent, "@`$(`$ConfigurationData.NonNodeData.$varName)")
                $partialContent = $Script:M365DSCCompiledRegexCache["${cacheKeyBase}_plain"].Replace($partialContent, "`$(`$ConfigurationData.NonNodeData.$varName)")
            }
        }
    }

    [void]$content.Append($partialContent)
    [void]$content.Append("        }`r`n")

    if ($null -ne $Global:M365DSCExportInstanceTally)
    {
        $Global:M365DSCExportInstanceTally++
    }

    return $content.ToString()
}

<#
.SYNOPSIS
    Updates the export string replacement map.

.DESCRIPTION
    Merges replacement entries into the module string replacement map and optionally clears existing mappings first.

.PARAMETER Map
    Specifies replacement mappings where key is source text and value is replacement token.

.PARAMETER Clear
    Indicates that existing mappings should be cleared before applying Map.
#>
function Set-M365DSCStringReplacementMap
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.Collections.Hashtable]
        $Map,

        [Parameter()]
        [switch]
        $Clear
    )

    if ($Clear)
    {
        $Script:M365DSCStringReplacementMap = @{}
    }

    if ($PSBoundParameters.ContainsKey('Map'))
    {
        foreach ($key in $Map.Keys)
        {
            $Script:M365DSCStringReplacementMap[$key] = $Map[$key]
        }
    }
}

<#
.SYNOPSIS
    Returns the current export string replacement map.

.DESCRIPTION
    Returns a clone of the in-memory map used for token replacement in exported content.

.OUTPUTS
    System.Collections.Hashtable
#>
function Get-M365DSCStringReplacementMap
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param()

    return $Script:M365DSCStringReplacementMap.Clone()
}

<#
.SYNOPSIS
    Joins split DSC configuration files into a single configuration content block.

.DESCRIPTION
    This function is used to join two or more M365DSC configurations into a single configuration.
    The function reads the configuration from the specified paths and combines them into a single configuration.
    Please note that the function won't be updating the authentication parameters if they differ between the configurations. Make sure that the authentication parameters are the same over all configurations.

.PARAMETER ConfigurationFile
    Specifies the base configuration file name.

.PARAMETER ConfigurationPath
    Specifies the folder containing configuration files to merge.

.EXAMPLE
    Join-M365DSCConfiguration -ConfigurationFile 'M365TenantConfig.ps1' -ConfigurationPath 'D:\testbed'
    This example joins the 'M365TenantConfig.ps1' file with all the configuration files in the 'D:\testbed' directory.

.FUNCTIONALITY
    Public
#>
function Join-M365DSCConfiguration
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ConfigurationFile,

        [Parameter(Mandatory = $true)]
        [string]
        $ConfigurationPath
    )

    if ($ConfigurationFile -notlike '*.ps1')
    {
        throw 'The ConfigurationFile parameter must be a .ps1 file.'
    }

    if (-not (Test-Path -Path $ConfigurationPath))
    {
        throw 'The ConfigurationPath parameter must be a valid path.'
    }

    $ConfigurationFilePath = Join-Path -Path $ConfigurationPath -ChildPath $ConfigurationFile
    $ConfigurationPath = Join-Path -Path $ConfigurationPath -ChildPath '*'

    $baseConfiguration = ConvertTo-DSCObject -Path $ConfigurationFilePath
    $additionalConfigurations = Get-Item -Path $ConfigurationPath -Filter *.ps1 -Exclude $ConfigurationFile | ForEach-Object { ConvertTo-DSCObject -Path $_.FullName }

    $combinedArray = @($baseConfiguration) + @($additionalConfigurations)
    $combinedConfiguration = ConvertFrom-DSCObject -DSCResources $combinedArray

    # Indent all lines by 8 spaces to match the indentation of the configuration file
    $combinedConfiguration = $combinedConfiguration -replace '(?m)^', '        '
    $combinedConfiguration = $combinedConfiguration.TrimEnd()

    # Remove everything in the "Node localhost" part in the configuration file, while excluding the last two closing brackets
    $content = Get-Content -Path $ConfigurationFilePath -Raw
    $content = $content -replace '(?s)(?<=Node localhost\s*\{)(.*\s{8}\}?)(?=\s*\})', ''

    # Append the combined configuration after the "Node localhost" part in the configuration file
    $content = $content -replace '(?s)(?<=Node localhost\s*\{)', "`r`n$combinedConfiguration"

    return $content
}

<#
.SYNOPSIS
    Splits a large DSC configuration file into smaller files.

.DESCRIPTION
    Parses Node localhost resource blocks and writes chunked configuration files based on maximum file size and optional resource count limits.

.PARAMETER Path
    Specifies the source configuration file path.

.PARAMETER OutputFolder
    Specifies the destination folder for split files.

.PARAMETER MaxFileSizeMB
    Specifies the maximum file size per output file in megabytes.

.PARAMETER MaxResources
    Specifies the maximum number of resource blocks per output file.

.EXAMPLE
    Split-M365DSCConfiguration -Path 'C:\Configs\M365TenantConfig.ps1' -OutputFolder 'C:\Configs\Split' -MaxFileSizeMB 2 -MaxResources 50
    This example splits the 'M365TenantConfig.ps1' file into smaller files, each with a maximum size of 2 MB and a maximum of 50 resources, saving them in the 'C:\Configs\Split' folder.

.FUNCTIONALITY
    Public
#>
function Split-M365DSCConfiguration
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [System.String]
        $OutputFolder = (Split-Path $Path),

        [Parameter()]
        [System.Double]
        $MaxFileSizeMB = 3,

        [Parameter()]
        [System.Int32]
        $MaxResources = 0  # 0 = ignore resource count limit
    )

    $fileContent = Get-Content -Encoding utf8 -Path $Path -Raw

    # Extract content inside "Node localhost { ... }"
    $pattern = 'Node localhost\s*{([\s\S]*)\s+}(\r|\n)+\s+}'
    $nodeMatch = [regex]::Match($fileContent, $pattern)
    if (-not $nodeMatch.Success)
    {
        throw "Could not find a 'Node localhost { ... }' block in file: $Path"
    }

    $nodeContent = $nodeMatch.Groups[1].Value

    # Extract header (everything before Node localhost)
    $header = ($fileContent -split 'Node localhost')[0] + "Node localhost`n    {`n"
    $footer = "`n    }`n}`n`nM365TenantConfig -ConfigurationData .\ConfigurationData.psd1"

    # Split into DSC resource text blocks using brace-depth parsing
    $resources = @()
    $lines = $nodeContent -split "`r?`n"
    $currentResource = [System.Text.StringBuilder]::new()
    $braceDepth = 0
    $insideResource = $false

    for ($i = 0; $i -lt $lines.Count; $i++)
    {
        $line = $lines[$i]
        # Detect resource start
        if (-not $insideResource -and $line.Trim() -match '^[a-zA-Z0-9_]+\s+"[^"]+"')
        {
            $insideResource = $true
            $null = $currentResource.Clear()
            $null = $currentResource.AppendLine($line)
            # Calculate brace depth
            $braceDepth = ($line -split '{').Count - ($line -split '}').Count
            continue
        }

        if ($insideResource)
        {
            $null = $currentResource.AppendLine($line)

            # Adjust brace depth based on line content
            $braceDepth += ($line -split '{').Count - ($line -split '}').Count

            # End of resource block
            if ($braceDepth -le 0)
            {
                $resources += '        ' + $currentResource.ToString().Trim()
                $insideResource = $false
            }
        }
    }

    if (-not $resources)
    {
        throw 'No DSC resources found in the Node block.'
    }

    # Splitting logic
    $i = 1
    $currentGroup = @()
    $currentSize = 0
    $maxBytes = $MaxFileSizeMB * 1MB

    foreach ($res in $resources)
    {
        # Calculate size of the resource in bytes
        $resBytes = [System.Text.Encoding]::UTF8.GetByteCount($res)
        $resourceCountLimitReached = ($MaxResources -gt 0 -and $currentGroup.Count -ge $MaxResources)
        $sizeLimitReached = ($currentSize + $resBytes) -gt $maxBytes

        # Write current group if limits are reached
        if (($sizeLimitReached -or $resourceCountLimitReached) -and $currentGroup.Count -gt 0)
        {
            $outPath = Join-Path $OutputFolder ('M365TenantConfig_{0}.ps1' -f $i)
            $configText = $header + ($currentGroup -join "`n") + $footer
            Set-Content -Path $outPath -Value $configText -Encoding UTF8 -Force
            Write-M365DSCHost -Message "Created: $outPath" -CommitWrite
            $i++
            $currentGroup = @()
            $currentSize = 0
        }

        $currentGroup += $res
        $currentSize += $resBytes
    }

    # Write final group
    if ($currentGroup.Count -gt 0)
    {
        $outPath = Join-Path $OutputFolder ('M365TenantConfig_{0}.ps1' -f $i)
        $configText = $header + ($currentGroup -join "`n`n") + $footer
        Set-Content -Path $outPath -Value $configText -Encoding UTF8 -Force
        Write-M365DSCHost -Message "Created: $outPath" -CommitWrite
    }
}

<#
.SYNOPSIS
    Normalizes authentication fields in exported resource results.

.DESCRIPTION
    Transforms authentication-related properties into configuration-data references and returns updated results with no-escape property metadata.

.PARAMETER ConnectionMode
    Specifies the authentication mode used for transformation rules.

.PARAMETER Results
    Specifies exported resource values to normalize.

.OUTPUTS
    System.Collections.Hashtable
#>
function Update-M365DSCExportAuthenticationResults
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('ServicePrincipalWithThumbprint', 'ServicePrincipalWithSecret', 'ServicePrincipalWithPath', 'CredentialsWithTenantId', 'CredentialsWithApplicationId', 'Credentials', 'ManagedIdentity', 'AccessTokens')]
        [System.String]
        $ConnectionMode,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Results
    )

    $noEscape = @()
    if ($Results.ContainsKey('ManagedIdentity') -and -not $Results.ManagedIdentity)
    {
        $Results.Remove('ManagedIdentity')
    }

    if ($ConnectionMode -in @('Credentials', 'CredentialsWithTenantId'))
    {
        $Results.Credential = '$CredsCredential'
        $noEscape += 'Credential'

        # Credentials mode removes TenantId; CredentialsWithTenantId keeps it.
        $keysToRemove = @('ApplicationId', 'ApplicationSecret', 'CertificateThumbprint', 'CertificatePath', 'CertificatePassword')
        if ($ConnectionMode -eq 'Credentials')
        {
            $keysToRemove += 'TenantId'
        }

        foreach ($key in $keysToRemove)
        {
            if ($Results.ContainsKey($key))
            {
                $Results.Remove($key) | Out-Null
            }
        }
    }
    else
    {
        # Handle Credential based on CredentialsWithApplicationId mode
        if ($Results.ContainsKey('Credential'))
        {
            if ($ConnectionMode -eq 'CredentialsWithApplicationId')
            {
                $Results.Credential = '$CredsCredential'
                $noEscape += 'Credential'
            }
            else
            {
                $Results.Remove('Credential') | Out-Null
            }
        }

        # Keys that map to a simple ConfigurationData reference when non-empty
        $configDataKeys = @('ApplicationId', 'CertificateThumbprint', 'CertificatePath', 'TenantId')
        foreach ($key in $configDataKeys)
        {
            if (-not [System.String]::IsNullOrEmpty($Results.$key))
            {
                $Results.$key = "`$ConfigurationData.NonNodeData.$key"
                $noEscape += $key
            }
            else
            {
                try
                {
                    $Results.Remove($key) | Out-Null
                }
                catch
                {
                    Write-Verbose -Message "Error removing $key from Update-M365DSCExportAuthenticationResults"
                }
            }
        }

        # ApplicationSecret gets a PSCredential wrapper
        if (-not [System.String]::IsNullOrEmpty($Results.ApplicationSecret))
        {
            $Results.ApplicationSecret = "New-Object System.Management.Automation.PSCredential ('ApplicationSecret', (ConvertTo-SecureString `$ConfigurationData.NonNodeData.ApplicationSecret -AsPlainText -Force))"
            $noEscape += 'ApplicationSecret'
        }
        else
        {
            try
            {
                $Results.Remove('ApplicationSecret') | Out-Null
            }
            catch
            {
                Write-Verbose -Message 'Error removing ApplicationSecret from Update-M365DSCExportAuthenticationResults'
            }
        }

        # CertificatePassword gets resolved as credentials
        if ($null -ne $Results.CertificatePassword)
        {
            $Results.CertificatePassword = '$CredsCertificatePassword'
            $noEscape += 'CertificatePassword'
        }
        else
        {
            try
            {
                $Results.Remove('CertificatePassword') | Out-Null
            }
            catch
            {
                Write-Verbose -Message 'Error removing CertificatePassword from Update-M365DSCExportAuthenticationResults'
            }
        }

        if ($null -ne $Results.AccessTokens)
        {
            $Results.AccessTokens = "`$ConfigurationData.NonNodeData.AccessTokens"
            $noEscape += 'AccessTokens'
        }
    }

    return @{
        Results  = $Results
        NoEscape = $noEscape
    }
}

<#
.SYNOPSIS
    Registers a discovered resource dependency during export.

.DESCRIPTION
    Adds a source-target dependency record to the global export dependency collector.

.PARAMETER SourceInstanceName
    Specifies the source resource instance name.

.PARAMETER SourceResourceName
    Specifies the source resource type name.

.PARAMETER TargetResourceType
    Specifies the target resource type name.

.PARAMETER TargetKey
    Specifies the target key value used to resolve the dependency target instance.
#>
function Register-M365DSCExportDependency
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SourceInstanceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SourceResourceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TargetResourceType,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TargetKey
    )

    $session = Get-M365DSCExportRelationSession
    if ($null -ne $session)
    {
        $session.RegisterDependency($SourceInstanceName, $SourceResourceName, $TargetResourceType, $TargetKey)
    }
}

<#
.SYNOPSIS
    Removes JavaScript-style comments from a JSON document.

.DESCRIPTION
    The relation templates are annotated with // and /* */ comments. Windows PowerShell's
    ConvertFrom-Json rejects those, so they are stripped before parsing on that edition.
    The scanner tracks string literals so that a comment marker appearing inside a value is
    left untouched.

    This exists only to keep Windows PowerShell working. Delete it, and its caller in
    Get-M365DSCRelationIndex, once the module requires PowerShell 7.

.PARAMETER Json
    Specifies the raw JSON document.

.OUTPUTS
    System.String

.FUNCTIONALITY
    Internal
#>
function Remove-M365DSCJsonComment
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Json
    )

    $builder = [System.Text.StringBuilder]::new($Json.Length)
    $inString = $false
    $escaped = $false
    $index = 0

    while ($index -lt $Json.Length)
    {
        $character = $Json[$index]

        if ($inString)
        {
            [void]$builder.Append($character)
            if ($escaped)
            {
                $escaped = $false
            }
            elseif ($character -eq '\')
            {
                $escaped = $true
            }
            elseif ($character -eq '"')
            {
                $inString = $false
            }

            $index++
            continue
        }

        if ($character -eq '"')
        {
            $inString = $true
            [void]$builder.Append($character)
            $index++
            continue
        }

        if ($character -eq '/' -and ($index + 1) -lt $Json.Length)
        {
            $next = $Json[$index + 1]

            if ($next -eq '/')
            {
                while ($index -lt $Json.Length -and $Json[$index] -ne "`n")
                {
                    $index++
                }
                continue
            }

            if ($next -eq '*')
            {
                $index += 2
                while (($index + 1) -lt $Json.Length -and -not ($Json[$index] -eq '*' -and $Json[$index + 1] -eq '/'))
                {
                    $index++
                }
                $index += 2
                continue
            }
        }

        [void]$builder.Append($character)
        $index++
    }

    return $builder.ToString()
}

<#
.SYNOPSIS
    Expands relation entries, resolving any template references they contain.

.DESCRIPTION
    A relation may be a $ref pointing at another template rather than a relation of its own.
    This returns a flat list with every reference replaced by the relations it names.

.PARAMETER Relations
    Specifies the relation entries to expand.

.PARAMETER Templates
    Specifies all templates, used to look references up.

.PARAMETER Visited
    Specifies the template names already being expanded, used to stop reference cycles.

.OUTPUTS
    System.Collections.Generic.List[System.Object]

.FUNCTIONALITY
    Internal
#>
function Expand-M365DSCRelationTemplate
{
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[System.Object]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Object]
        $Relations,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Templates,

        [Parameter()]
        [System.Collections.Generic.HashSet[System.String]]
        $Visited
    )

    if ($null -eq $Visited)
    {
        $Visited = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    }

    $expanded = [System.Collections.Generic.List[System.Object]]::new()
    foreach ($relation in $Relations)
    {
        $reference = $relation.'$ref'
        if ([System.String]::IsNullOrEmpty($reference))
        {
            $expanded.Add($relation)
            continue
        }

        $referencedName = $reference.Split('/')[-1]
        if (-not $Visited.Add($referencedName))
        {
            Write-Verbose -Message "Skipping circular relation template reference '$referencedName'."
            continue
        }

        $referenced = Expand-M365DSCRelationTemplate -Relations $Templates.$referencedName.relations `
            -Templates $Templates `
            -Visited $Visited
        $expanded.AddRange($referenced)
        [void]$Visited.Remove($referencedName)
    }

    return , $expanded
}

<#
.SYNOPSIS
    Returns the relation index, building it on first use.

.DESCRIPTION
    Parses M365DSCRelationTemplates.json and inverts it into a lookup keyed by resource name.
    The templates list the resources each relation applies to, so without this inversion every
    exported instance would have to scan every template.

    Parsing stays in PowerShell deliberately: handing the parsed schema to the relation
    assembly keeps that assembly free of a JSON dependency, and therefore free of assembly
    version conflicts with other modules loaded in the same session.

.OUTPUTS
    Microsoft365DSC.Relations.RelationIndex

.FUNCTIONALITY
    Internal
#>
function Get-M365DSCRelationIndex
{
    [CmdletBinding()]
    # Quoted so the attribute does not force the type to resolve while the module is being
    # parsed, which happens before the assemblies are loaded.
    [OutputType('Microsoft365DSC.Relations.RelationIndex')]
    param()

    if ($null -ne $Script:M365DSCRelationIndex)
    {
        return $Script:M365DSCRelationIndex
    }

    Initialize-M365DSCDllLoader -ErrorAction Stop

    $templatesPath = Join-Path -Path $PSScriptRoot -ChildPath 'M365DSCRelationTemplates.json'
    $rawTemplates = Get-Content -Path $templatesPath -Raw

    if ($PSVersionTable.PSEdition -eq 'Desktop')
    {
        $rawTemplates = Remove-M365DSCJsonComment -Json $rawTemplates
    }

    $templates = ($rawTemplates | ConvertFrom-Json).templates
    $builder = [Microsoft365DSC.Relations.RelationIndexBuilder]::new()

    foreach ($template in $templates.PSObject.Properties)
    {
        $relations = Expand-M365DSCRelationTemplate -Relations $template.Value.relations -Templates $templates
        foreach ($resourceName in $template.Value.resources)
        {
            foreach ($relation in $relations)
            {
                $builder.AddRelation(
                    $resourceName,
                    $relation.property,
                    $relation.childProperty,
                    $relation.targetResource,
                    $relation.targetKeyProperty,
                    $relation.condition)
            }
        }
    }

    $Script:M365DSCRelationIndex = $builder.Build()
    return $Script:M365DSCRelationIndex
}

<#
.SYNOPSIS
    Creates the relation session used to collect dependencies during an export.

.DESCRIPTION
    Returns a session that records exported instances, accumulates the references between
    them, and rewrites the finished configuration with DependsOn declarations.

.OUTPUTS
    Microsoft365DSC.Relations.ExportRelationSession

.FUNCTIONALITY
    Internal
#>
function New-M365DSCExportRelationSession
{
    [CmdletBinding()]
    [OutputType('Microsoft365DSC.Relations.ExportRelationSession')]
    param()

    Initialize-M365DSCDllLoader -ErrorAction Stop
    $index = Get-M365DSCRelationIndex

    return [Microsoft365DSC.Relations.ExportRelationSession]::Start($index)
}

<#
.SYNOPSIS
    Returns the relation session the running export is accumulating into.

.DESCRIPTION
    The session lives on the relation assembly rather than in a variable. A parallel export
    runs its resources in a pool of runspaces, and PowerShell variables are not shared across
    runspaces, so a session held in one would be invisible to the workers that need to write
    to it. The assemblies are loaded once per process, so static state on them is visible
    everywhere.

.OUTPUTS
    Microsoft365DSC.Relations.ExportRelationSession, or $null when the export was not asked
    for dependency tracking.

.FUNCTIONALITY
    Internal
#>
function Get-M365DSCExportRelationSession
{
    [CmdletBinding()]
    [OutputType('Microsoft365DSC.Relations.ExportRelationSession')]
    param()

    Initialize-M365DSCDllLoader -ErrorAction Stop
    return [Microsoft365DSC.Relations.ExportRelationSession]::Current
}

<#
.SYNOPSIS
    Resolves relation templates into concrete export dependencies.

.DESCRIPTION
    Evaluates configured relation templates for the resource instance and registers dependencies for referenced target resources.

.PARAMETER ResourceName
    Specifies the source resource type name.

.PARAMETER InstanceName
    Specifies the source resource instance name.

.PARAMETER Results
    Specifies exported property values used to evaluate relation definitions.
#>
function Resolve-M365DSCExportRelations
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Results
    )

    $session = Get-M365DSCExportRelationSession
    if ($null -eq $session)
    {
        return
    }

    $session.ResolveRelations($ResourceName, $InstanceName, $Results)
}

<#
.SYNOPSIS
    Injects DependsOn statements into exported DSC content.

.DESCRIPTION
    Resolves collected dependencies to exported instances, injects DependsOn arrays into source resource blocks, and generates minimal stub blocks for unresolved targets.

.PARAMETER DSCContent
    Specifies the exported DSC content to enrich with dependency data.

.OUTPUTS
    System.String
#>
function Add-M365DSCExportDependsOn
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DSCContent
    )

    $session = Get-M365DSCExportRelationSession
    if ($null -eq $session -or $session.DependencyCount -eq 0)
    {
        return $DSCContent
    }

    $processedContent = $session.InjectDependsOn($DSCContent, (New-M365DSCStubBlockOption))

    foreach ($warning in $session.Warnings)
    {
        Write-Verbose -Message $warning
    }

    return $processedContent
}

<#
.SYNOPSIS
    Collects the inputs needed to render dependency stub blocks.

.DESCRIPTION
    Gathers the mandatory properties of every resource and the authentication properties for
    the current connection mode, so the relation assembly can render stubs without calling
    back into the module while it rewrites the configuration.

.OUTPUTS
    Microsoft365DSC.Relations.StubBlockOptions

.FUNCTIONALITY
    Internal
#>
function New-M365DSCStubBlockOption
{
    [CmdletBinding()]
    [OutputType('Microsoft365DSC.Relations.StubBlockOptions')]
    param()

    Initialize-M365DSCDllLoader -ErrorAction Stop

    # The type and any allowed values travel with each property, so a stub can be given a
    # placeholder of the right shape for every mandatory property instead of only for the
    # handful whose names happen to be recognised.
    $mandatoryProperties = @{}
    try
    {
        foreach ($resourceName in (Get-M365DSCAllResources))
        {
            $definition = Get-M365DSCResourceDefinition -ResourceName $resourceName
            if ($null -eq $definition)
            {
                continue
            }

            $properties = @($definition.Properties.Where({ $_.IsMandatory }) | ForEach-Object {
                @{
                    Name         = $_.Name
                    PropertyType = $_.PropertyType
                    Values       = [System.String[]]@($_.Values)
                }
            })

            if ($properties.Count -gt 0)
            {
                $mandatoryProperties[$resourceName] = $properties
            }
        }
    }
    catch
    {
        Write-Verbose -Message "Unable to load resource dictionary for stub generation: $_"
    }

    # ConnectionMode is only set once an export has authenticated; without that guard the
    # hashtable lookup below throws on a null key.
    $authenticationProperties = @()
    if (-not [System.String]::IsNullOrEmpty($Script:ConnectionMode))
    {
        $authenticationProperties = $Script:M365DSCAuthenticationParameterSet.$($Script:ConnectionMode)
    }

    $options = [Microsoft365DSC.Relations.StubBlockOptions]::new()
    $options.MandatoryPropertiesByResource = $mandatoryProperties
    $options.AuthenticationProperties = [System.String[]]@($authenticationProperties)

    return $options
}

<#
.SYNOPSIS
    Builds minimal DSC stub blocks for unresolved dependency targets.

.DESCRIPTION
    Generates placeholder resource blocks with mandatory keys and authentication fields so unresolved dependency references can still compile.

.PARAMETER UnresolvedTargets
    Specifies unresolved target definitions keyed by resource type and target key.

.OUTPUTS
    System.String
#>
function Get-M365DSCMinimalExportBlocks
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $UnresolvedTargets
    )

    Initialize-M365DSCDllLoader -ErrorAction Stop

    return [Microsoft365DSC.Relations.DependsOnInjector]::RenderStubs($UnresolvedTargets.Values, (New-M365DSCStubBlockOption))
}

<#
.SYNOPSIS
    Maps each export collection cache key to the resources that consume it.

.DESCRIPTION
    Returns the resource names whose Export() lists a collection through Get-M365DSCExportCachedCollection,
    keyed by collection. Used to register and release cache consumers during an export.

.OUTPUTS
    System.Collections.Hashtable
#>
function Get-M365DSCExportCollectionConsumerMap
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param ()

    return @{
        deviceConfigurations           = @(
            'IntuneDeviceConfigurationCustomPolicyMacOS',
            'IntuneDeviceConfigurationCustomPolicyWindows10',
            'IntuneDeviceConfigurationCustomPolicyiOS',
            'IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10',
            'IntuneDeviceConfigurationDomainJoinPolicyWindows10',
            'IntuneDeviceConfigurationEmailProfilePolicyWindows10',
            'IntuneDeviceConfigurationEndpointProtectionPolicyWindows10',
            'IntuneDeviceConfigurationFirmwareInterfacePolicyWindows10',
            'IntuneDeviceConfigurationHealthMonitoringPolicyWindows10',
            'IntuneDeviceConfigurationIdentityProtectionPolicyWindows10',
            'IntuneDeviceConfigurationImportedPfxCertificatePolicyWindows10',
            'IntuneDeviceConfigurationKioskPolicyWindows10',
            'IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10',
            'IntuneDeviceConfigurationPkcsCertificatePolicyWindows10',
            'IntuneDeviceConfigurationPolicyAndroidDeviceOwner',
            'IntuneDeviceConfigurationPolicyAndroidOpenSourceProject',
            'IntuneDeviceConfigurationPolicyAndroidWorkProfile',
            'IntuneDeviceConfigurationPolicyMacOS',
            'IntuneDeviceConfigurationPolicyWindows10',
            'IntuneDeviceConfigurationPolicyiOS',
            'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10',
            'IntuneDeviceConfigurationSecureAssessmentPolicyWindows10',
            'IntuneDeviceConfigurationSharedMultiDevicePolicyWindows10',
            'IntuneDeviceConfigurationTrustedCertificatePolicyWindows10',
            'IntuneDeviceConfigurationVpnPolicyWindows10',
            'IntuneDeviceConfigurationWindowsTeamPolicyWindows10',
            'IntuneDeviceConfigurationWiredNetworkPolicyMacOS',
            'IntuneDeviceConfigurationWiredNetworkPolicyWindows10',
            'IntuneDeviceFeaturesConfigurationPolicyIOS',
            'IntuneDeviceFeaturesConfigurationPolicyMacOS',
            'IntuneTrustedRootCertificateAndroidDeviceOwner',
            'IntuneTrustedRootCertificateAndroidWork',
            'IntuneTrustedRootCertificateIOS',
            'IntuneVPNConfigurationPolicyAndroidDeviceOwner',
            'IntuneVPNConfigurationPolicyAndroidWork',
            'IntuneVPNConfigurationPolicyIOS',
            'IntuneVPNConfigurationPolicyMacOS',
            'IntuneWifiConfigurationPolicyAndroidEnterpriseDeviceOwner',
            'IntuneWifiConfigurationPolicyAndroidEnterpriseWorkProfile',
            'IntuneWifiConfigurationPolicyAndroidForWork',
            'IntuneWifiConfigurationPolicyAndroidOpenSourceProject',
            'IntuneWifiConfigurationPolicyIOS',
            'IntuneWifiConfigurationPolicyMacOS',
            'IntuneWifiConfigurationPolicyWindows10',
            'IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10'
        )
        deviceCompliancePolicies       = @(
            'IntuneDeviceCompliancePolicyAndroidDeviceOwner',
            'IntuneDeviceCompliancePolicyAndroidWorkProfile',
            'IntuneDeviceCompliancePolicyMacOS',
            'IntuneDeviceCompliancePolicyWindows10',
            'IntuneDeviceCompliancePolicyiOs'
        )
        deviceEnrollmentConfigurations = @(
            'IntuneDeviceEnrollmentLimitRestriction',
            'IntuneDeviceEnrollmentPlatformRestriction',
            'IntuneDeviceEnrollmentStatusPageWindows10',
            'IntuneWindowsBackupForOrganizationConfiguration',
            'IntuneWindowsHelloForBusinessGlobalPolicy'
        )
        exoMailboxes                   = @(
            'EXOCalendarProcessing',
            'EXOFocusedInbox',
            'EXOMailboxAutoReplyConfiguration',
            'EXOMailboxCalendarConfiguration',
            'EXOMailboxCalendarFolder',
            'EXOMailboxIRMAccess',
            'EXOMailboxPermission',
            'EXOMailboxSettings',
            'EXOSweepRule'
        )
        exoUsers                       = @(
            'EXOCalendarProcessing',
            'EXOMailboxPermission',
            'EXORecipientPermission'
        )
        pimGroups                      = @(
            'AADGroupEligibilitySchedule',
            'AADGroupEligibilityScheduleSettings',
            'AADPIMGroupSetting'
        )
        reusablePolicySettings         = @(
            'IntuneDeviceComplianceScriptLinux',
            'IntuneDeviceControlPolicySetting',
            'IntuneEpmCertificatePolicySetting',
            'IntuneFirewallPolicySetting'
        )
    }
}

<#
.SYNOPSIS
    Clears and enables the export collection cache for a new export session.

.DESCRIPTION
    Resets the process-wide export collection cache and enables it so that resources exported in this
    session share one download per Graph collection.
#>
function Initialize-M365DSCExportCollectionCache
{
    [CmdletBinding()]
    param ()

    [Microsoft365DSC.Cache.ExportCollectionCache]::Reset()
    [Microsoft365DSC.Intune.IntuneGroupCache]::Reset()
    [Microsoft365DSC.Intune.SettingTemplateCache]::Reset()
    [Microsoft365DSC.Intune.RoleScopeTagCache]::Reset()
    Clear-M365DSCIntuneAssignmentFilterCache
    [Microsoft365DSC.Cache.ExportCollectionCache]::Enable()
}

<#
.SYNOPSIS
    Clears and disables the export collection cache.

.DESCRIPTION
    Releases every cached collection and disables the cache so that resources use live Graph requests.
#>
function Reset-M365DSCExportCollectionCache
{
    [CmdletBinding()]
    param ()

    Clear-M365DSCIntuneAssignmentFilterCache
    if ($null -ne ('Microsoft365DSC.Cache.ExportCollectionCache' -as [System.Type]))
    {
        [Microsoft365DSC.Cache.ExportCollectionCache]::Reset()
        [Microsoft365DSC.Intune.IntuneGroupCache]::Reset()
        [Microsoft365DSC.Intune.SettingTemplateCache]::Reset()
        [Microsoft365DSC.Intune.RoleScopeTagCache]::Reset()
        [Microsoft365DSC.Intune.ConfigurationPolicyCache]::Reset()
    }
}

<#
.SYNOPSIS
    Registers how many exported resources consume each cached collection.

.DESCRIPTION
    Counts the resources in the export selection per collection key and registers those counts with
    the export collection cache so that a collection is released after its last consumer.

.PARAMETER ResourceNames
    Specifies the names of the resources selected for the export.
#>
function Register-M365DSCExportCollectionConsumers
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.String[]]
        $ResourceNames
    )

    $map = Get-M365DSCExportCollectionConsumerMap
    foreach ($key in $map.Keys)
    {
        $count = @($map[$key] | Where-Object -FilterScript { $ResourceNames -contains $_ }).Count
        if ($count -gt 0)
        {
            [Microsoft365DSC.Cache.ExportCollectionCache]::RegisterConsumers($key, $count)
        }
    }
}

<#
.SYNOPSIS
    Releases the cached collections consumed by a resource once its export has completed.

.DESCRIPTION
    Decrements the consumer count of every collection the resource consumes. The cache frees a
    collection when its count reaches zero.

.PARAMETER ResourceName
    Specifies the name of the resource whose export has completed.
#>
function Complete-M365DSCExportCollectionConsumer
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName
    )

    if ($null -eq ('Microsoft365DSC.Cache.ExportCollectionCache' -as [System.Type]))
    {
        return
    }

    $map = Get-M365DSCExportCollectionConsumerMap
    foreach ($key in $map.Keys)
    {
        if ($map[$key] -contains $ResourceName)
        {
            $null = [Microsoft365DSC.Cache.ExportCollectionCache]::Release($key)
        }
    }
}

<#
.SYNOPSIS
    Returns the items of an Intune collection, served from the export collection cache when possible.

.DESCRIPTION
    Lists a Graph collection once per export and filters the cached items client-side on '@odata.type'.
    Performs the resource's live filtered request when the cache is disabled or when a user filter is
    supplied.

.PARAMETER Collection
    Specifies the Graph collection to list.

.PARAMETER ODataType
    Specifies the OData types to return, written like the isof() argument (for example
    'microsoft.graph.windowsKioskConfiguration'). Returns every type when omitted.

.PARAMETER ExcludeODataType
    Specifies the OData types to exclude from the result.

.PARAMETER PropertyName
    Specifies the top-level property to match, for collections whose consumers differ by a property
    rather than by OData type. Applied client-side on the cached items and server-side otherwise.

.PARAMETER PropertyValue
    Specifies the values the property must match. Returns every item when omitted.

.PARAMETER Filter
    Specifies the user-supplied OData filter. A non-empty filter bypasses the cache.

.OUTPUTS
    System.Object[]
#>
function Get-M365DSCExportCachedCollection
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('deviceConfigurations', 'deviceCompliancePolicies', 'deviceEnrollmentConfigurations', 'reusablePolicySettings', 'exoMailboxes', 'exoUsers', 'pimGroups')]
        [System.String]
        $Collection,

        [Parameter()]
        [System.String[]]
        $ODataType = @(),

        [Parameter()]
        [System.String[]]
        $ExcludeODataType = @(),

        [Parameter()]
        [System.String]
        $PropertyName,

        [Parameter()]
        [System.String[]]
        $PropertyValue = @(),

        [Parameter()]
        [System.String]
        $Filter
    )

    $descriptors = @{
        deviceConfigurations           = @{ Expand = @('assignments'); ServerSideTypeFilter = $true }
        deviceCompliancePolicies       = @{ Expand = @('scheduledActionsForRule($expand=scheduledActionConfigurations)', 'assignments'); ServerSideTypeFilter = $true }
        deviceEnrollmentConfigurations = @{ Expand = @('assignments'); ServerSideTypeFilter = $false }
        reusablePolicySettings         = @{ Expand = @(); ServerSideTypeFilter = $false; Select = @('id', 'displayName', 'description', 'settingDefinitionId', 'settingInstance') }
        exoMailboxes                   = @{ Fetch = { Get-Mailbox -ResultSize 'Unlimited' -ErrorAction Stop } }
        exoUsers                       = @{ Fetch = { Get-User -ResultSize 'Unlimited' } }
        pimGroups                      = @{ Fetch = { Get-M365DSCPIMEnabledGroup } }
    }
    $descriptor = $descriptors[$Collection]

    $cacheAvailable = $null -ne ('Microsoft365DSC.Cache.ExportCollectionCache' -as [System.Type]) -and
        [Microsoft365DSC.Cache.ExportCollectionCache]::IsEnabled

    if ($null -ne $descriptor -and $null -ne $descriptor.Fetch)
    {
        if (-not $cacheAvailable)
        {
            return , [System.Object[]]@(& $descriptor.Fetch)
        }

        $items = $null
        if ([Microsoft365DSC.Cache.ExportCollectionCache]::TryGet($Collection, [ref] $items))
        {
            return , [System.Object[]]@($items)
        }

        $fetched = @(& $descriptor.Fetch)
        $null = [Microsoft365DSC.Cache.ExportCollectionCache]::TrySet($Collection, [System.Object[]]$fetched)
        return , [System.Object[]]$fetched
    }

    if ($cacheAvailable -and [System.String]::IsNullOrEmpty($Filter))
    {
        $cached = [Microsoft365DSC.Cache.ExportCollectionCache]::GetByODataType($Collection, [System.String[]]$ODataType, [System.String[]]$ExcludeODataType)
        if ($null -eq $cached)
        {
            $all = Invoke-M365DSCExportCollectionList -Collection $Collection -ExpandProperty $descriptor.Expand -Property $descriptor.Select
            $null = [Microsoft365DSC.Cache.ExportCollectionCache]::TrySet($Collection, [System.Object[]]$all)
            $cached = [Microsoft365DSC.Cache.ExportCollectionCache]::FilterByODataType([System.Object[]]$all, [System.String[]]$ODataType, [System.String[]]$ExcludeODataType)
        }

        return , [System.Object[]][Microsoft365DSC.Cache.ExportCollectionCache]::FilterByProperty([System.Object[]]$cached, $PropertyName, [System.String[]]$PropertyValue)
    }

    $typeFilter = ''
    if ($descriptor.ServerSideTypeFilter -and $ODataType.Count -gt 0)
    {
        $typeFilter = ($ODataType | ForEach-Object -Process { "isof('$_')" }) -join ' or '
        if ($ODataType.Count -gt 1)
        {
            $typeFilter = "($typeFilter)"
        }
        foreach ($excluded in $ExcludeODataType)
        {
            $typeFilter += " and not isof('$excluded')"
        }
    }

    if (-not [System.String]::IsNullOrEmpty($PropertyName) -and $PropertyValue.Count -gt 0)
    {
        $propertyFilter = ($PropertyValue | ForEach-Object -Process { "$PropertyName eq '$_'" }) -join ' or '
        if ($PropertyValue.Count -gt 1)
        {
            $propertyFilter = "($propertyFilter)"
        }
        $typeFilter = if ([System.String]::IsNullOrEmpty($typeFilter)) { $propertyFilter } else { "($typeFilter) and ($propertyFilter)" }
    }

    $mergedFilter = $typeFilter
    if (-not [System.String]::IsNullOrEmpty($Filter))
    {
        $mergedFilter = if ([System.String]::IsNullOrEmpty($typeFilter)) { $Filter } else { "($typeFilter) and ($Filter)" }
    }

    $items = Invoke-M365DSCExportCollectionList -Collection $Collection -ExpandProperty $descriptor.Expand -Property $descriptor.Select -Filter $mergedFilter
    if (-not $descriptor.ServerSideTypeFilter -and $null -ne ('Microsoft365DSC.Cache.ExportCollectionCache' -as [System.Type]))
    {
        $items = [Microsoft365DSC.Cache.ExportCollectionCache]::FilterByODataType([System.Object[]]$items, [System.String[]]$ODataType, [System.String[]]$ExcludeODataType)
    }
    elseif (-not $descriptor.ServerSideTypeFilter -and $ODataType.Count -gt 0)
    {
        $wanted = @($ODataType | ForEach-Object -Process { $_.TrimStart('#') })
        $items = @($items | Where-Object -FilterScript { $wanted -contains ([System.String]$_.'@odata.type').TrimStart('#') })
    }

    return , [System.Object[]]$items
}

<#
.SYNOPSIS
    Lists the groups enabled in Privileged Identity Management (PIM) for Groups.

.DESCRIPTION
    Reads the group resources of PIM for Groups and resolves their display names in one batch. A group
    is listed once a PIM operation, such as a policy change or an eligible assignment, has enabled it.

.OUTPUTS
    System.Object[]
#>
function Get-M365DSCPIMEnabledGroup
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param ()

    $resources = Get-M365DSCRawGraphCollection -Uri '/beta/identityGovernance/privilegedAccess/group/resources' -Property 'id'
    $requests = foreach ($resource in $resources)
    {
        @{
            id     = $resource.id
            method = 'GET'
            url    = "/groups/$($resource.id)?`$select=id,displayName"
        }
    }

    foreach ($response in (Invoke-M365DSCGraphBatchRequest -Requests @($requests) -AsList))
    {
        if ($response.status -eq 200)
        {
            [PSCustomObject]@{
                Id          = $response.body.id
                DisplayName = $response.body.displayName
            }
        }
    }
}

<#
.SYNOPSIS
    Lists a Graph collection as raw JSON items, following the paging links.

.DESCRIPTION
    Calls Invoke-MgGraphRequest on the collection and follows '@odata.nextLink' until every page has
    been read. Returns the items in the shape Graph sends them rather than in the SDK object model.

.PARAMETER Uri
    Specifies the collection URI.

.PARAMETER Property
    Specifies the properties to select. Required for properties the collection omits by default.

.PARAMETER Filter
    Specifies the OData filter to apply.

.OUTPUTS
    System.Object[]
#>
function Get-M365DSCRawGraphCollection
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        [Parameter()]
        [System.String[]]
        $Property,

        [Parameter()]
        [System.String]
        $Filter
    )

    $query = [System.Collections.Generic.List[System.String]]::new()
    if ($Property.Count -gt 0)
    {
        $query.Add('$select=' + ($Property -join ','))
    }
    if (-not [System.String]::IsNullOrEmpty($Filter))
    {
        $query.Add('$filter=' + $Filter)
    }

    $requestUri = $Uri
    if ($query.Count -gt 0)
    {
        $requestUri = $Uri + '?' + ($query -join '&')
    }

    $items = [System.Collections.Generic.List[System.Object]]::new()
    while (-not [System.String]::IsNullOrEmpty($requestUri))
    {
        $response = Invoke-MgGraphRequest -Method GET -Uri $requestUri -ErrorAction Stop
        foreach ($item in $response.value)
        {
            if ($null -ne $item)
            {
                $items.Add($item)
            }
        }

        $requestUri = $response.'@odata.nextLink'
    }

    return , $items.ToArray()
}

<#
.SYNOPSIS
    Lists a Graph collection with the given expand and filter.

.DESCRIPTION
    Calls the collection's Get cmdlet with -All and returns the items as an array without null entries.

.PARAMETER Collection
    Specifies the Graph collection to list.

.PARAMETER ExpandProperty
    Specifies the navigation properties to expand.

.PARAMETER Property
    Specifies the properties to select. Required for properties the collection omits by default.

.PARAMETER Filter
    Specifies the OData filter to apply.

.OUTPUTS
    System.Object[]
#>
function Invoke-M365DSCExportCollectionList
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Collection,

        [Parameter()]
        [System.String[]]
        $ExpandProperty,

        [Parameter()]
        [System.String[]]
        $Property,

        [Parameter()]
        [System.String]
        $Filter
    )

    $params = @{ All = $true; ErrorAction = 'Stop' }
    if ($ExpandProperty.Count -gt 0)
    {
        $params.ExpandProperty = $ExpandProperty
    }
    if ($Property.Count -gt 0)
    {
        $params.Property = $Property
    }
    if (-not [System.String]::IsNullOrEmpty($Filter))
    {
        $params.Filter = $Filter
    }

    $result = switch ($Collection)
    {
        'deviceConfigurations' { Get-MgBetaDeviceManagementDeviceConfiguration @params }
        'deviceCompliancePolicies' { Get-MgBetaDeviceManagementDeviceCompliancePolicy @params }
        'deviceEnrollmentConfigurations' { Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration @params }
        'reusablePolicySettings' { Get-M365DSCRawGraphCollection -Uri '/beta/deviceManagement/reusablePolicySettings' -Property $Property -Filter $Filter }
    }

    $items = [System.Collections.Generic.List[System.Object]]::new()
    foreach ($item in $result)
    {
        if ($null -ne $item)
        {
            $items.Add($item)
        }
    }

    return , $items.ToArray()
}


Export-ModuleMember -Function @(
    'Get-M365DSCExportCollectionConsumerMap',
    'Initialize-M365DSCExportCollectionCache',
    'Reset-M365DSCExportCollectionCache',
    'Register-M365DSCExportCollectionConsumers',
    'Complete-M365DSCExportCollectionConsumer',
    'Get-M365DSCExportCachedCollection',
    'Get-M365DSCPIMEnabledGroup',
    'Get-M365DSCRawGraphCollection',
    'Invoke-M365DSCExportCollectionList',
    'Export-M365DSCConfiguration',
    'Get-M365DSCExportContentForResource',
    'Get-M365DSCResourcesByExportMode',
    'Join-M365DSCConfiguration',
    'Split-M365DSCConfiguration',
    'Set-M365DSCStringReplacementMap',
    'Get-M365DSCStringReplacementMap',
    'Update-M365DSCExportAuthenticationResults',
    'Register-M365DSCExportDependency',
    'Resolve-M365DSCExportRelations',
    'Add-M365DSCExportDependsOn',
    'Get-M365DSCMinimalExportBlocks'
)
