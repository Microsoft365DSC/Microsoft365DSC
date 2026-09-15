using namespace System.Management.Automation.Language

<#
.SYNOPSIS
    Full end-to-end deployment testing engine for Microsoft365DSC resources.

.DESCRIPTION
    This module extends the existing M365DSCTestEngine with full lifecycle testing:
    1. Deploy resource configuration (Create)
    2. Export tenant state
    3. Assert no drift via Assert-M365DSCBlueprint
    4. Deploy resource update (Update)
    5. Re-assert no drift
    6. Remove resource (Cleanup)
    7. Generate results per resource per auth method

    Unlike unit tests, this validates real deployments against real M365 tenants.
#>

# Import helper modules
$helpersPath = Join-Path -Path $PSScriptRoot -ChildPath 'Helpers'
. (Join-Path $helpersPath 'Get-ResourceAuthMethods.ps1')
. (Join-Path $helpersPath 'New-TestReport.ps1')
. (Join-Path $helpersPath 'Invoke-TenantCleanup.ps1')

function Get-AuthParamsForMethod
{
    <#
    .SYNOPSIS
        Builds authentication parameter hashtable for a given auth method
        using environment variables.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Credential', 'CertificateThumbprint', 'ApplicationSecret', 'ManagedIdentity', 'AccessTokens')]
        [System.String]
        $AuthMethod,

        [Parameter()]
        [System.String]
        $TenantPrefix = 'M365DSC_TEST'
    )

    $params = @{}

    switch ($AuthMethod)
    {
        'Credential'
        {
            $user = [Environment]::GetEnvironmentVariable("${TenantPrefix}_CREDENTIAL_USER")
            $pass = [Environment]::GetEnvironmentVariable("${TenantPrefix}_CREDENTIAL_PASS")
            if ([string]::IsNullOrEmpty($user) -or [string]::IsNullOrEmpty($pass))
            {
                throw "Environment variables ${TenantPrefix}_CREDENTIAL_USER and ${TenantPrefix}_CREDENTIAL_PASS must be set for Credential auth."
            }
            $secPass = ConvertTo-SecureString $pass -AsPlainText -Force
            $params['Credential'] = New-Object System.Management.Automation.PSCredential($user, $secPass)
        }
        'CertificateThumbprint'
        {
            $appId = [Environment]::GetEnvironmentVariable("${TenantPrefix}_APPID")
            $tenantId = [Environment]::GetEnvironmentVariable("${TenantPrefix}_TENANTID")
            $thumbprint = [Environment]::GetEnvironmentVariable("${TenantPrefix}_CERTTHUMBPRINT")
            if ([string]::IsNullOrEmpty($appId) -or [string]::IsNullOrEmpty($tenantId) -or [string]::IsNullOrEmpty($thumbprint))
            {
                throw "Environment variables ${TenantPrefix}_APPID, ${TenantPrefix}_TENANTID, and ${TenantPrefix}_CERTTHUMBPRINT must be set."
            }
            $params['ApplicationId'] = $appId
            $params['TenantId'] = $tenantId
            $params['CertificateThumbprint'] = $thumbprint
        }
        'ApplicationSecret'
        {
            $appId = [Environment]::GetEnvironmentVariable("${TenantPrefix}_APPID")
            $tenantId = [Environment]::GetEnvironmentVariable("${TenantPrefix}_TENANTID")
            $secret = [Environment]::GetEnvironmentVariable("${TenantPrefix}_APPSECRET")
            if ([string]::IsNullOrEmpty($appId) -or [string]::IsNullOrEmpty($tenantId) -or [string]::IsNullOrEmpty($secret))
            {
                throw "Environment variables ${TenantPrefix}_APPID, ${TenantPrefix}_TENANTID, and ${TenantPrefix}_APPSECRET must be set."
            }
            $secSecret = ConvertTo-SecureString $secret -AsPlainText -Force
            $params['ApplicationId'] = $appId
            $params['TenantId'] = $tenantId
            $params['ApplicationSecret'] = New-Object System.Management.Automation.PSCredential('ApplicationSecret', $secSecret)
        }
        'ManagedIdentity'
        {
            $params['ManagedIdentity'] = $true
            $tenantId = [Environment]::GetEnvironmentVariable("${TenantPrefix}_TENANTID")
            if (-not [string]::IsNullOrEmpty($tenantId))
            {
                $params['TenantId'] = $tenantId
            }
        }
        'AccessTokens'
        {
            $token = [Environment]::GetEnvironmentVariable("${TenantPrefix}_ACCESSTOKEN")
            if ([string]::IsNullOrEmpty($token))
            {
                throw "Environment variable ${TenantPrefix}_ACCESSTOKEN must be set for AccessTokens auth."
            }
            $params['AccessTokens'] = @($token)
        }
    }

    return $params
}

function Invoke-SingleResourceDeploymentTest
{
    <#
    .SYNOPSIS
        Runs the full deploy/export/drift-check cycle for a single resource
        with a specific auth method.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AuthMethod,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $AuthParams,

        [Parameter()]
        [System.String]
        $ExamplesBasePath,

        [Parameter()]
        [Switch]
        $SkipCleanup
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $result = @{
        ResourceName  = $ResourceName
        AuthMethod    = $AuthMethod
        Status        = 'Failed'
        DeploySuccess = $false
        ExportSuccess = $false
        NoDrift       = $false
        DriftDetails  = $null
        Duration      = ''
        Error         = $null
    }

    if ([string]::IsNullOrEmpty($ExamplesBasePath))
    {
        $repoRoot = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\' -Resolve
        $ExamplesBasePath = Join-Path $repoRoot 'Examples\Resources'
    }

    $resourceExamplesPath = Join-Path $ExamplesBasePath $ResourceName
    $createFile = Join-Path $resourceExamplesPath '1-Create.ps1'

    if (-not (Test-Path $createFile))
    {
        Write-Warning "No Create example found for $ResourceName at $createFile"
        $result.Status = 'Skipped'
        $result.DriftDetails = 'No 1-Create.ps1 example found'
        $sw.Stop()
        $result.Duration = '{0:mm\:ss}' -f $sw.Elapsed
        return $result
    }

    try
    {
        # ============================================================
        # STEP 1: Deploy (Create)
        # ============================================================
        Write-Host "    [Create] Deploying $ResourceName..." -NoNewline

        $configName = "Deploy_${ResourceName}_Create"
        $configContent = Build-DeploymentConfig -ExampleFile $createFile -ConfigName $configName -AuthParams $AuthParams

        $tempConfigPath = Join-Path $env:TEMP "$configName.ps1"
        $configContent | Set-Content -Path $tempConfigPath -Encoding UTF8

        . $tempConfigPath

        $configData = @{
            AllNodes = @(@{
                NodeName                    = 'Localhost'
                PSDSCAllowPlaintextPassword = $true
            })
        }

        & $configName -ConfigurationData $configData @AuthParams
        Start-DscConfiguration -Path ".\$configName" -Wait -Force -Verbose -ErrorAction Stop

        $result.DeploySuccess = $true
        Write-Host ' OK' -ForegroundColor Green

        # ============================================================
        # STEP 2: Export & Assert Blueprint
        # ============================================================
        Write-Host "    [Assert] Checking for drift on $ResourceName..." -NoNewline

        $blueprintFile = Join-Path $env:TEMP "Blueprint_${ResourceName}.M365"
        $exportFile = Join-Path $env:TEMP "Export_${ResourceName}.ps1"
        $reportFile = Join-Path $env:TEMP "DriftReport_${ResourceName}.json"

        # Copy the deployed config as the blueprint
        Copy-Item -Path $tempConfigPath -Destination $blueprintFile -Force

        # Export current tenant state for this resource
        $exportParams = @{
            Components = @($ResourceName)
            Path       = $env:TEMP
            FileName   = "Export_${ResourceName}.ps1"
        } + $AuthParams

        Export-M365DSCConfiguration @exportParams -ErrorAction Stop
        $result.ExportSuccess = $true

        # Use Assert-M365DSCBlueprint for drift detection
        Assert-M365DSCBlueprint -BluePrintUrl $blueprintFile `
            -OutputReportPath $reportFile `
            -Type 'JSON' `
            @AuthParams -ErrorAction Stop

        # Check the report for drifts
        if (Test-Path $reportFile)
        {
            $driftReport = Get-Content $reportFile -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($null -eq $driftReport -or $driftReport.TotalDrifts -eq 0)
            {
                $result.NoDrift = $true
                Write-Host ' No drift' -ForegroundColor Green
            }
            else
            {
                $result.DriftDetails = "Drifts found: $($driftReport.TotalDrifts)"
                Write-Host " DRIFT DETECTED ($($driftReport.TotalDrifts))" -ForegroundColor Yellow
            }
        }
        else
        {
            $result.NoDrift = $true
            Write-Host ' No drift report (assumed OK)' -ForegroundColor Green
        }

        # ============================================================
        # STEP 3: Update (if example exists)
        # ============================================================
        $updateFile = Join-Path $resourceExamplesPath '2-Update.ps1'
        if (Test-Path $updateFile)
        {
            Write-Host "    [Update] Applying update for $ResourceName..." -NoNewline

            $updateConfigName = "Deploy_${ResourceName}_Update"
            $updateContent = Build-DeploymentConfig -ExampleFile $updateFile -ConfigName $updateConfigName -AuthParams $AuthParams

            $tempUpdatePath = Join-Path $env:TEMP "$updateConfigName.ps1"
            $updateContent | Set-Content -Path $tempUpdatePath -Encoding UTF8

            . $tempUpdatePath
            & $updateConfigName -ConfigurationData $configData @AuthParams
            Start-DscConfiguration -Path ".\$updateConfigName" -Wait -Force -ErrorAction Stop

            Write-Host ' OK' -ForegroundColor Green

            # Clean up
            Remove-Item -Path $tempUpdatePath -Force -ErrorAction SilentlyContinue
            Remove-Item -Path ".\$updateConfigName" -Recurse -Force -ErrorAction SilentlyContinue
        }

        # ============================================================
        # STEP 4: Remove (cleanup if example exists)
        # ============================================================
        if (-not $SkipCleanup)
        {
            $removeFile = Join-Path $resourceExamplesPath '3-Remove.ps1'
            if (Test-Path $removeFile)
            {
                Write-Host "    [Remove] Cleaning up $ResourceName..." -NoNewline

                $removeConfigName = "Deploy_${ResourceName}_Remove"
                $removeContent = Build-DeploymentConfig -ExampleFile $removeFile -ConfigName $removeConfigName -AuthParams $AuthParams

                $tempRemovePath = Join-Path $env:TEMP "$removeConfigName.ps1"
                $removeContent | Set-Content -Path $tempRemovePath -Encoding UTF8

                . $tempRemovePath
                & $removeConfigName -ConfigurationData $configData @AuthParams
                Start-DscConfiguration -Path ".\$removeConfigName" -Wait -Force -ErrorAction Stop

                Write-Host ' OK' -ForegroundColor Green

                # Clean up
                Remove-Item -Path $tempRemovePath -Force -ErrorAction SilentlyContinue
                Remove-Item -Path ".\$removeConfigName" -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        # If we made it here with deployment + no drift, it's a pass
        if ($result.DeploySuccess -and $result.NoDrift)
        {
            $result.Status = 'Passed'
        }
        elseif ($result.DeploySuccess)
        {
            $result.Status = 'Failed'
            $result.DriftDetails = $result.DriftDetails ?? 'Drift detected after deployment'
        }
    }
    catch
    {
        $result.Error = $_.Exception.Message
        $result.DriftDetails = "Error: $($_.Exception.Message)"
        Write-Host " FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally
    {
        # Clean up temp files
        Remove-Item -Path (Join-Path $env:TEMP "Deploy_${ResourceName}*") -Force -ErrorAction SilentlyContinue
        Remove-Item -Path (Join-Path $env:TEMP "Blueprint_${ResourceName}*") -Force -ErrorAction SilentlyContinue
        Remove-Item -Path (Join-Path $env:TEMP "Export_${ResourceName}*") -Force -ErrorAction SilentlyContinue
        Remove-Item -Path (Join-Path $env:TEMP "DriftReport_${ResourceName}*") -Force -ErrorAction SilentlyContinue
        Remove-Item -Path ".\Deploy_${ResourceName}*" -Recurse -Force -ErrorAction SilentlyContinue

        $sw.Stop()
        $result.Duration = '{0:mm\:ss}' -f $sw.Elapsed
    }

    return $result
}

function Build-DeploymentConfig
{
    <#
    .SYNOPSIS
        Reads an example file and wraps it into a deployable configuration
        script that accepts auth parameters.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $ExampleFile,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ConfigName,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $AuthParams
    )

    $exampleContent = Get-Content $ExampleFile -Raw

    # Replace the configuration name 'Example' with our custom name
    $modifiedContent = $exampleContent -replace '(?i)Configuration\s+Example', "Configuration $ConfigName"

    return $modifiedContent
}

function Invoke-M365DSCDeploymentTest
{
    <#
    .SYNOPSIS
        Main entry point for running deployment tests across resources.

    .DESCRIPTION
        Orchestrates deployment testing for Microsoft365DSC resources. Tests
        each resource with each supported authentication method, performing
        the full deploy/export/drift-check lifecycle.

    .PARAMETER Workload
        Filter by workload (AAD, EXO, Intune, Teams, SPO, SC, etc.)

    .PARAMETER ResourceName
        Test a specific resource by name.

    .PARAMETER AuthMethod
        Use a specific auth method. If not set, tests all supported methods.

    .PARAMETER All
        Test all resources across all workloads.

    .PARAMETER SkipKnownIssues
        Skip resources listed in Config/KnownIssues.json.

    .PARAMETER OutputReportPath
        Path for the output report file. Defaults to ./DeploymentTestReport.html

    .PARAMETER ReportFormat
        Format of the report: HTML or JSON. Defaults to HTML.

    .EXAMPLE
        Invoke-M365DSCDeploymentTest -Workload 'AAD' -AuthMethod 'CertificateThumbprint'

    .EXAMPLE
        Invoke-M365DSCDeploymentTest -ResourceName 'AADApplication' -AuthMethod 'CertificateThumbprint'

    .EXAMPLE
        Invoke-M365DSCDeploymentTest -All
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $Workload,

        [Parameter()]
        [System.String]
        $ResourceName,

        [Parameter()]
        [ValidateSet('Credential', 'CertificateThumbprint', 'ApplicationSecret', 'ManagedIdentity', 'AccessTokens')]
        [System.String]
        $AuthMethod,

        [Parameter()]
        [Switch]
        $All,

        [Parameter()]
        [Switch]
        $SkipKnownIssues,

        [Parameter()]
        [Switch]
        $SkipCleanup,

        [Parameter()]
        [System.String]
        $OutputReportPath,

        [Parameter()]
        [ValidateSet('HTML', 'JSON')]
        [System.String]
        $ReportFormat = 'HTML'
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host '  Microsoft365DSC Deployment Test Engine' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ''

    # Load known issues
    $knownIssuesFile = Join-Path -Path $PSScriptRoot -ChildPath 'Config\KnownIssues.json'
    $knownIssues = @()
    if (Test-Path $knownIssuesFile)
    {
        $knownIssuesData = Get-Content $knownIssuesFile -Raw | ConvertFrom-Json
        $knownIssues = $knownIssuesData.KnownIssues | ForEach-Object { $_.ResourceName }
    }

    # Determine which resources to test
    $repoRoot = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\' -Resolve
    $modulePath = Join-Path $repoRoot 'Modules\Microsoft365DSC'
    $examplesPath = Join-Path $repoRoot 'Examples\Resources'

    if (-not [string]::IsNullOrEmpty($ResourceName))
    {
        $testMatrix = Get-ResourceTestMatrix -ModulePath $modulePath |
            Where-Object { $_.ResourceName -eq $ResourceName }
    }
    elseif (-not [string]::IsNullOrEmpty($Workload))
    {
        $testMatrix = Get-ResourceTestMatrix -Workload $Workload -ModulePath $modulePath
    }
    elseif ($All)
    {
        $testMatrix = Get-ResourceTestMatrix -ModulePath $modulePath
    }
    else
    {
        throw "Specify -Workload, -ResourceName, or -All to select which resources to test."
    }

    # Filter to resources that have at least a Create example
    $testMatrix = $testMatrix | Where-Object { $_.HasCreate }

    Write-Host "Found $($testMatrix.Count) resources with Create examples to test." -ForegroundColor White
    Write-Host ''

    $allResults = @()

    foreach ($resource in $testMatrix)
    {
        $resName = $resource.ResourceName
        $isKnownIssue = $knownIssues -contains $resName

        Write-Host "  [$resName]" -ForegroundColor White

        if ($isKnownIssue -and $SkipKnownIssues)
        {
            Write-Host "    Skipped (known issue)" -ForegroundColor Yellow
            $allResults += @{
                ResourceName  = $resName
                AuthMethod    = 'N/A'
                Status        = 'KnownIssue'
                DeploySuccess = $false
                ExportSuccess = $false
                NoDrift       = $false
                DriftDetails  = 'Skipped due to known issue'
                Duration      = '00:00'
                Error         = $null
            }
            continue
        }

        # Determine auth methods to test
        $methodsToTest = $resource.AuthMethods
        if (-not [string]::IsNullOrEmpty($AuthMethod))
        {
            if ($methodsToTest -contains $AuthMethod)
            {
                $methodsToTest = @($AuthMethod)
            }
            else
            {
                Write-Host "    $AuthMethod not supported by $resName (supports: $($resource.AuthMethods -join ', '))" -ForegroundColor Yellow
                $allResults += @{
                    ResourceName  = $resName
                    AuthMethod    = $AuthMethod
                    Status        = 'Skipped'
                    DeploySuccess = $false
                    ExportSuccess = $false
                    NoDrift       = $false
                    DriftDetails  = "Auth method '$AuthMethod' not supported"
                    Duration      = '00:00'
                    Error         = $null
                }
                continue
            }
        }

        foreach ($method in $methodsToTest)
        {
            try
            {
                $authParams = Get-AuthParamsForMethod -AuthMethod $method
            }
            catch
            {
                Write-Host "    [$method] Skipped - missing env vars: $_" -ForegroundColor Yellow
                $allResults += @{
                    ResourceName  = $resName
                    AuthMethod    = $method
                    Status        = 'Skipped'
                    DeploySuccess = $false
                    ExportSuccess = $false
                    NoDrift       = $false
                    DriftDetails  = "Missing environment variables for $method"
                    Duration      = '00:00'
                    Error         = $_.Exception.Message
                }
                continue
            }

            Write-Host "    [$method]" -ForegroundColor DarkGray
            $testResult = Invoke-SingleResourceDeploymentTest `
                -ResourceName $resName `
                -AuthMethod $method `
                -AuthParams $authParams `
                -ExamplesBasePath $examplesPath `
                -SkipCleanup:$SkipCleanup

            if ($isKnownIssue -and $testResult.Status -eq 'Failed')
            {
                $testResult.Status = 'KnownIssue'
            }

            $allResults += $testResult
        }
    }

    # Generate report
    if ([string]::IsNullOrEmpty($OutputReportPath))
    {
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $ext = if ($ReportFormat -eq 'JSON') { 'json' } else { 'html' }
        $OutputReportPath = Join-Path $PSScriptRoot "DeploymentTestReport_$timestamp.$ext"
    }

    New-TestReport -Results $allResults -OutputPath $OutputReportPath -Type $ReportFormat

    $sw.Stop()

    # Summary
    $passed = ($allResults | Where-Object { $_.Status -eq 'Passed' }).Count
    $failed = ($allResults | Where-Object { $_.Status -eq 'Failed' }).Count
    $skipped = ($allResults | Where-Object { $_.Status -eq 'Skipped' }).Count
    $known = ($allResults | Where-Object { $_.Status -eq 'KnownIssue' }).Count

    Write-Host ''
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host "  Results: $passed passed, $failed failed, $skipped skipped, $known known issues" -ForegroundColor White
    Write-Host "  Total time: $($sw.Elapsed.Hours)h $($sw.Elapsed.Minutes)m $($sw.Elapsed.Seconds)s" -ForegroundColor White
    Write-Host "  Report: $OutputReportPath" -ForegroundColor White
    Write-Host '============================================================' -ForegroundColor Cyan

    return $allResults
}

Export-ModuleMember -Function @(
    'Invoke-M365DSCDeploymentTest',
    'Invoke-SingleResourceDeploymentTest',
    'Get-AuthParamsForMethod',
    'Build-DeploymentConfig'
)
