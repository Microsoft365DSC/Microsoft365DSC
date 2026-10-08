<#
.SYNOPSIS
    Builds the Microsoft365DSC C# projects and copies the DLLs to the module dependencies folder.

.DESCRIPTION
    This script builds the Microsoft365DSC solution targeting netstandard2.0 and copies the resulting
    DLLs to the Microsoft365DSC module's Dependencies/Assemblies directory.

.PARAMETER Configuration
    Build configuration: Debug or Release. Default is Release.

.PARAMETER RepositoryRoot
    Root directory of the Microsoft365DSC repository. Default is parent of script location.

.PARAMETER SkipClean
    Skip the clean step before building. Useful for incremental builds during development and on a
    fresh CI checkout, where there is nothing to clean.

.EXAMPLE
    PS> .\Build-DllFiles.ps1
    Builds the Microsoft365DSC C# projects in Release configuration.

.EXAMPLE
    PS> .\Build-DllFiles.ps1 -Configuration Debug -SkipClean
    Builds in Debug configuration without cleaning first.

.NOTES
    Requires .NET SDK 6.0 or higher to be installed for build tools.
    The compiled DLL targets .NET Standard 2.0 for compatibility with .NET Framework 4.7.2+ and .NET Core 2.0+.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Debug', 'Release')]
    [System.String]
    $Configuration = 'Release',

    [Parameter()]
    [System.String]
    $RepositoryRoot,

    [Parameter()]
    [switch]
    $SkipClean
)

# Verify .NET SDK is available
try {
    $dotnetVersion = dotnet --version
    Write-Host "Using .NET SDK version: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Error "dotnet CLI not found. Please install .NET SDK 6.0 or higher from https://dotnet.microsoft.com/download"
    exit 1
}

# Determine repository root
if ([System.String]::IsNullOrEmpty($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Path $PSScriptRoot -Parent
}

$solutionPath = Join-Path -Path $RepositoryRoot -ChildPath 'src/Microsoft365DSC.sln'
if (-not (Test-Path -Path $solutionPath)) {
    Write-Error "Solution file not found at: $solutionPath"
    exit 1
}

$targetDir = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC/Dependencies/Assemblies'

$nugetSource = "https://api.nuget.org/v3/index.json"
$currentNugetSources = (dotnet nuget list source --format short) -join ", "
if (-not ($currentNugetSources -like "*$nugetSource*")) {
    Write-Host "Adding NuGet source: $nugetSource" -ForegroundColor Yellow
    dotnet nuget add source $nugetSource --name "nuget.org"
} else {
    Write-Host "NuGet source already configured: $nugetSource" -ForegroundColor Green
}

if (-not $SkipClean) {
    Write-Host ""
    Write-Host "Cleaning previous build artifacts..." -ForegroundColor Yellow
    $cleanResult = dotnet clean $solutionPath -c $Configuration --nologo 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Clean failed, continuing with build..."
        Write-Verbose ($cleanResult | Out-String)
    }
}

Write-Host ""
Write-Host "Building solution $solutionPath..." -ForegroundColor Yellow
$buildResult = dotnet build $solutionPath -c $Configuration --nologo 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed with exit code $LASTEXITCODE"
    Write-Error ($buildResult | Out-String)
    exit $LASTEXITCODE
}

Write-Host "Build succeeded!" -ForegroundColor Green

if (-not (Test-Path -Path $targetDir)) {
    New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
}

Write-Host ""
Write-Host "Copying assemblies to module dependencies..." -ForegroundColor Yellow

$projects = Get-ChildItem -Path (Join-Path -Path $RepositoryRoot -ChildPath 'src') -Filter '*.csproj' -File -Recurse
foreach ($project in $projects) {
    $projectName = $project.BaseName
    $outputDir = Join-Path -Path $project.DirectoryName -ChildPath "bin/$Configuration/netstandard2.0"

    $dllPath = Join-Path -Path $outputDir -ChildPath "$projectName.dll"
    if (-not (Test-Path -Path $dllPath)) {
        Write-Error "Build succeeded but DLL not found at expected location: $dllPath"
        exit 1
    }

    foreach ($fileName in @("$projectName.dll", "$projectName.pdb", "$projectName.xml")) {
        $sourcePath = Join-Path -Path $outputDir -ChildPath $fileName
        if (Test-Path -Path $sourcePath) {
            Copy-Item -Path $sourcePath -Destination (Join-Path -Path $targetDir -ChildPath $fileName) -Force
            Write-Host "  Copied: $fileName" -ForegroundColor Gray
        } else {
            Write-Warning "  Skipped: $fileName (not found)"
        }
    }
}

Write-Host ""
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "Output location: $targetDir" -ForegroundColor Cyan
