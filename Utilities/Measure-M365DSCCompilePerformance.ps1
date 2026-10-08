<#
.SYNOPSIS
    Measures DSC configuration compile times per module, PowerShell edition and compile engine.

.DESCRIPTION
    Every sample runs in a fresh process with exactly one Microsoft365DSC module version visible on
    PSModulePath (a junction stage), the configuration copied next to its ConfigurationData.psd1
    with the Import-DscResource version rewritten to the staged module, and the working directory
    set to that copy because exported configurations invoke themselves with a relative path.

    Engines:

        standard             plain script execution, whichever PSDesiredStateConfiguration the
                             edition resolves (inbox 1.1 on Windows PowerShell, 2.0.7 on PowerShell 7)
        fasthost-cold        Invoke-DscFastCompile with the per-user schema cache of the module removed
        fasthost-warmcache   Invoke-DscFastCompile with a schema cache on disk
        fasthost-warmsession second Invoke-DscFastCompile in the same process

    One warm-up run per cell is discarded and the median of -Repetition samples is reported. The MOF
    of the last sample of every cell is kept under -OutputDirectory and compared with
    Compare-M365DSCMofDocument against the standard engine cell of the same module and edition
    (ModuleParity) and against the standard engine cell of the first module (Parity).

.PARAMETER ConfigPath
    Configuration scripts to compile. Each needs a ConfigurationData.psd1 in its folder.

.PARAMETER ModuleRoot
    Module folders to measure, each holding a Microsoft365DSC.psd1. The first one is the parity
    reference.

.PARAMETER Edition
    PowerShell editions to run: '5.1' (powershell.exe) and/or '7' (pwsh).

.PARAMETER Engine
    Compile engines to run, see the description.

.PARAMETER FastHostPath
    Manifest of the M365DSC.PSDesiredStateConfiguration build to use. Defaults to the sibling
    repository checkout when present, otherwise the highest installed version.

.PARAMETER Repetition
    Timed runs per cell.

.PARAMETER OutputDirectory
    Folder that receives the MOF files and the CSV. Defaults to a folder under the temp path.

.EXAMPLE
    .\Measure-M365DSCCompilePerformance.ps1 -Repetition 1

.EXAMPLE
    .\Measure-M365DSCCompilePerformance.ps1 -ConfigPath D:\M365DSC\M365DSC_Data\EXO\M365TenantConfig_EXO.ps1 -Edition 5.1 -Engine fasthost-warmcache -Repetition 3

.OUTPUTS
    System.Management.Automation.PSCustomObject
#>
[CmdletBinding()]
[OutputType([System.Management.Automation.PSCustomObject])]
param
(
    [Parameter()]
    [System.String[]]
    $ConfigPath = @(
        'D:\testbed\M365TenantConfig.ps1',
        'D:\M365DSC\M365DSC_Data\AAD\M365TenantConfig_AAD.ps1',
        'D:\M365DSC\M365DSC_Data\SC\M365TenantConfig_SC.ps1',
        'D:\M365DSC\M365DSC_Data\EXO\M365TenantConfig_EXO.ps1',
        'D:\M365DSC\M365DSC_Data\INTUNE\M365TenantConfig_INTUNE.ps1'
    ),

    [Parameter()]
    [System.String[]]
    $ModuleRoot = @(
        'C:\Program Files\WindowsPowerShell\Modules\Microsoft365DSC\1.26.826.1',
        (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Modules/Microsoft365DSC')
    ),

    [Parameter()]
    [ValidateSet('5.1', '7')]
    [System.String[]]
    $Edition = @('5.1', '7'),

    [Parameter()]
    [ValidateSet('standard', 'fasthost-cold', 'fasthost-warmcache', 'fasthost-warmsession')]
    [System.String[]]
    $Engine = @('standard', 'fasthost-cold', 'fasthost-warmcache', 'fasthost-warmsession'),

    [Parameter()]
    [System.String]
    $FastHostPath,

    [Parameter()]
    [ValidateRange(1, 25)]
    [System.Int32]
    $Repetition = 3,

    [Parameter()]
    [System.String]
    $OutputDirectory
)

$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'M365DSCBuildHelpers.psm1') -Force

if ([System.String]::IsNullOrEmpty($FastHostPath))
{
    $sibling = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'PSDesiredStateConfiguration/M365DSC.PSDesiredStateConfiguration/M365DSC.PSDesiredStateConfiguration.psd1'
    if (Test-Path -Path $sibling)
    {
        $FastHostPath = (Resolve-Path -Path $sibling).ProviderPath
    }
    else
    {
        $installed = @(Get-Module -ListAvailable -Name 'M365DSC.PSDesiredStateConfiguration' | Sort-Object -Property Version -Descending)
        if ($installed.Count -eq 0)
        {
            throw 'M365DSC.PSDesiredStateConfiguration is not installed and no sibling checkout was found.'
        }
        $FastHostPath = $installed[0].Path
    }
}

if ([System.String]::IsNullOrEmpty($OutputDirectory))
{
    $OutputDirectory = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ('M365DSCCompilePerf_' + [Guid]::NewGuid().ToString('N'))
}
$null = New-Item -Path $OutputDirectory -ItemType Directory -Force

$childTemplate = @'
$ErrorActionPreference = 'Stop'
$engine = '__ENGINE__'
$stageRoot = '__STAGEROOT__'
$configFile = '__CONFIGFILE__'
$fastHostPath = '__FASTHOSTPATH__'
$moduleName = 'Microsoft365DSC'
$result = [ordered] @{ parseMs = 0; compileMs = 0; totalMs = 0; mofPath = ''; mofBytes = 0; fallback = $false; stages = $null }
try
{
    $entries = @($env:PSModulePath -split [System.IO.Path]::PathSeparator |
        Where-Object { $_ -and -not (Test-Path -Path (Join-Path -Path $_ -ChildPath $moduleName)) })
    $env:PSModulePath = (@($stageRoot) + $entries) -join [System.IO.Path]::PathSeparator
    Set-Location -Path (Split-Path -Path $configFile -Parent)
    $configName = [System.IO.Path]::GetFileNameWithoutExtension($configFile)
    $outputFolder = Join-Path -Path (Split-Path -Path $configFile -Parent) -ChildPath $configName
    if (Test-Path -Path $outputFolder) { Remove-Item -Path $outputFolder -Recurse -Force }

    if ($engine -eq 'standard')
    {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $sb = [scriptblock]::Create([System.IO.File]::ReadAllText($configFile))
        $result.parseMs = $sw.ElapsedMilliseconds
        $sw.Restart()
        $null = . $sb
        $result.compileMs = $sw.ElapsedMilliseconds
    }
    else
    {
        Import-Module -Name $fastHostPath -Force -WarningAction SilentlyContinue
        if ($engine -eq 'fasthost-cold')
        {
            $cacheDir = Join-Path -Path ([System.Environment]::GetFolderPath('LocalApplicationData')) -ChildPath 'M365DSC.PSDesiredStateConfiguration\SchemaCache'
            if (Test-Path -Path $cacheDir)
            {
                Get-ChildItem -Path $cacheDir -Filter ($moduleName + '_*') -ErrorAction SilentlyContinue | Remove-Item -Force
            }
        }
        $warnings = @()
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $null = Invoke-DscFastCompile -Path $configFile -WarningVariable warnings -WarningAction SilentlyContinue
        $result.compileMs = $sw.ElapsedMilliseconds
        if ($engine -eq 'fasthost-warmsession')
        {
            if (Test-Path -Path $outputFolder) { Remove-Item -Path $outputFolder -Recurse -Force }
            $sw.Restart()
            $null = Invoke-DscFastCompile -Path $configFile -WarningVariable warnings -WarningAction SilentlyContinue
            $result.compileMs = $sw.ElapsedMilliseconds
        }
        $result.fallback = [bool] @($warnings | Where-Object { "$_" -like 'Falling back*' }).Count
        if (Get-Command -Name Get-DscFastCompileTiming -ErrorAction SilentlyContinue)
        {
            $result.stages = Get-DscFastCompileTiming
        }
    }
    $result.totalMs = $result.parseMs + $result.compileMs
    $mof = Get-ChildItem -Path $outputFolder -Filter '*.mof' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $mof) { throw "No MOF produced in $outputFolder." }
    $result.mofPath = $mof.FullName
    $result.mofBytes = $mof.Length
    $result.workingSetMB = [System.Math]::Round((Get-Process -Id $PID).WorkingSet64 / 1MB)
    '##RESULT## ' + (ConvertTo-Json -InputObject $result -Compress -Depth 4)
}
catch
{
    $message = [regex]::Replace($_.Exception.Message, '\s+', ' ').Trim()
    if ($message.Length -gt 400) { $message = $message.Substring(0, 400) }
    '##RESULT## ' + (ConvertTo-Json -InputObject @{ error = $message } -Compress)
}
'@

function Invoke-CompileSample
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Executable,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Script
    )

    $scriptFile = Join-Path -Path $OutputDirectory -ChildPath ('sample_' + [Guid]::NewGuid().ToString('N') + '.ps1')
    [System.IO.File]::WriteAllText($scriptFile, $Script, [System.Text.UTF8Encoding]::new($true))
    try
    {
        $lines = @(& $Executable -NoProfile -NonInteractive -File $scriptFile 2>$null)
    }
    finally
    {
        Remove-Item -Path $scriptFile -Force -ErrorAction SilentlyContinue
    }

    $line = @($lines | Where-Object { "$_" -like '##RESULT## *' }) | Select-Object -Last 1
    if ($null -eq $line)
    {
        return [PSCustomObject] @{ error = 'No result line. ' + (($lines | Select-Object -Last 3) -join ' | ') }
    }

    return ConvertFrom-Json -InputObject ("$line".Substring(11))
}

$results = [System.Collections.Generic.List[Object]]::new()
$referenceMof = @{}

foreach ($root in $ModuleRoot)
{
    $manifest = Join-Path -Path $root -ChildPath 'Microsoft365DSC.psd1'
    $version = ([Version] (Import-PowerShellDataFile -Path $manifest).ModuleVersion).ToString()
    $moduleLabel = Split-Path -Path $root -Leaf
    if ($moduleLabel -eq 'Microsoft365DSC')
    {
        $moduleLabel = 'repo'
    }
    $moduleLabel = "$moduleLabel($version)"

    $stage = New-M365DSCProbeStage -ModuleRoot $root -Version $version
    try
    {
        foreach ($config in $ConfigPath)
        {
            $configName = [System.IO.Path]::GetFileNameWithoutExtension($config)
            $sourceFolder = Split-Path -Path $config -Parent
            $workFolder = Join-Path -Path $OutputDirectory -ChildPath ('work_' + $configName + '_' + $version)
            $null = New-Item -Path $workFolder -ItemType Directory -Force
            Copy-Item -Path (Join-Path -Path $sourceFolder -ChildPath 'ConfigurationData.psd1') -Destination $workFolder -Force
            $text = [System.IO.File]::ReadAllText($config)
            $text = [regex]::Replace($text, "(-ModuleVersion\s+')[^']+(')", ('${1}' + $version + '${2}'))
            $workConfig = Join-Path -Path $workFolder -ChildPath (Split-Path -Path $config -Leaf)
            [System.IO.File]::WriteAllText($workConfig, $text, [System.Text.UTF8Encoding]::new($true))

            foreach ($ed in $Edition)
            {
                $executable = if ($ed -eq '7') { 'pwsh' } else { 'powershell' }
                foreach ($eng in $Engine)
                {
                    $script = $childTemplate.
                        Replace('__ENGINE__', $eng).
                        Replace('__STAGEROOT__', $stage.Root.Replace("'", "''")).
                        Replace('__CONFIGFILE__', $workConfig.Replace("'", "''")).
                        Replace('__FASTHOSTPATH__', $FastHostPath.Replace("'", "''"))

                    Write-MeasureLog "$moduleLabel / $configName / $ed / $eng" -Level Detail
                    $null = Invoke-CompileSample -Executable $executable -Script $script

                    $samples = [System.Collections.Generic.List[Object]]::new()
                    for ($i = 0; $i -lt $Repetition; $i++)
                    {
                        $sample = Invoke-CompileSample -Executable $executable -Script $script
                        if ($sample.PSObject.Properties['error'])
                        {
                            Write-MeasureLog "  error: $($sample.error)" -Level Warning
                            continue
                        }
                        $samples.Add($sample)
                    }

                    $entry = [PSCustomObject] @{
                        Module       = $moduleLabel
                        Config       = $configName
                        Edition      = $ed
                        Engine       = $eng
                        Samples      = $samples.Count
                        ParseMs      = $null
                        CompileMs    = $null
                        TotalMs      = $null
                        WorkingSetMB = $null
                        MofBytes     = $null
                        Fallback     = $null
                        Parity       = $null
                        ModuleParity = $null
                        Stages       = $null
                        Error        = $null
                    }

                    if ($samples.Count -gt 0)
                    {
                        $sorted = @($samples | Sort-Object -Property totalMs)
                        $median = $sorted[[System.Math]::Floor($sorted.Count / 2)]
                        $entry.ParseMs = $median.parseMs
                        $entry.CompileMs = $median.compileMs
                        $entry.TotalMs = $median.totalMs
                        $entry.WorkingSetMB = $median.workingSetMB
                        $entry.MofBytes = $median.mofBytes
                        $entry.Fallback = $median.fallback
                        if ($null -ne $median.stages)
                        {
                            $entry.Stages = ($median.stages.PSObject.Properties | ForEach-Object { '{0}={1}' -f $_.Name, $_.Value }) -join ';'
                        }

                        $keptMof = Join-Path -Path $OutputDirectory -ChildPath ('{0}_{1}_{2}_{3}.mof' -f $configName, $version, $ed, $eng)
                        Copy-Item -Path $median.mofPath -Destination $keptMof -Force
                        foreach ($scope in @('Parity', 'ModuleParity'))
                        {
                            $referenceKey = if ($scope -eq 'Parity') { "$configName|$ed" } else { "$configName|$ed|$version" }
                            if (-not $referenceMof.ContainsKey($referenceKey))
                            {
                                $referenceMof[$referenceKey] = $keptMof
                                $entry.$scope = 'reference'
                            }
                            else
                            {
                                $entry.$scope = (Compare-M365DSCMofDocument -ReferencePath $referenceMof[$referenceKey] -CandidatePath $keptMof -IgnoreClassPrefix:($scope -eq 'Parity')).Equal
                            }
                        }
                    }
                    else
                    {
                        $entry.Error = 'no usable sample'
                    }

                    $results.Add($entry)
                    Write-MeasureLog ("{0} / {1} / {2} / {3}: parse {4} ms, compile {5} ms, total {6} ms, parity {7}/{8}" -f
                        $moduleLabel, $configName, $ed, $eng, $entry.ParseMs, $entry.CompileMs, $entry.TotalMs, $entry.Parity, $entry.ModuleParity) -Level Success
                }
            }
        }
    }
    finally
    {
        Remove-M365DSCProbeStage -Stage $stage
    }
}

$csv = Join-Path -Path $OutputDirectory -ChildPath 'compile-performance.csv'
$results | Export-Csv -Path $csv -NoTypeInformation
Write-MeasureLog "Wrote $csv"

return $results.ToArray()
