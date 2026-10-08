param(
    [string]$OutputPath = "$PSScriptRoot\function-signatures.json",
    [string]$CmdletSourceModulesPath = "$PSScriptRoot\cmdlet-source-modules.json"
)

# Load the cmdlet-to-module map to only extract what we actually need
$cmdletFilter = $null
if (Test-Path $CmdletSourceModulesPath) {
    $cmdletMap = Get-Content $CmdletSourceModulesPath -Raw | ConvertFrom-Json
    $cmdletFilter = @($cmdletMap.PSObject.Properties.Name)
    Write-Host "Filtering to $($cmdletFilter.Count) cmdlets from settings.json"
}

# Resolve the mapped cmdlets by name so that any verb reaches the signature file
if ($cmdletFilter) {
    $allFunctions = @(Get-Command -Name $cmdletFilter -ErrorAction SilentlyContinue | Sort-Object -Property Name)
    $unresolved = @($cmdletFilter | Where-Object { $_ -notin $allFunctions.Name })
    if ($unresolved.Count -gt 0) {
        Write-Warning "No command found for: $($unresolved -join ', ')"
    }
    Write-Host "Resolved $($allFunctions.Count) of $($cmdletFilter.Count) mapped cmdlets"
}
else {
    $allFunctions = @(Get-Command | Where-Object { $_.Name -match "^(Add|Clear|Get|New|Update|Remove|Restore|Set|Invoke)-Mg" -and $_.Name -ne 'Invoke-MgGraphRequest' -and $_.Name -ne 'Get-MgContext' })
    Write-Host "Found $($allFunctions.Count) Mg* function definitions"
}

$allFunctionsList = [System.Collections.Generic.List[System.Object]]::new($allFunctions.Count)
foreach ($fn in $allFunctions) {
    Get-Command $fn.Name | ForEach-Object { $allFunctionsList.Add($_) }
}

$result = [ordered]@{}
$counter = 0
$commonParameters = @('Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'ProgressAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable', 'WhatIf', 'Confirm')

foreach ($fn in $allFunctionsList) {
    $pList = [System.Collections.Generic.List[object]]::new()

    foreach ($p in $fn.Parameters.GetEnumerator()) {
        $pName = $p.Key

        # Skip common parameters
        if ($pName -in $commonParameters)
        {
            continue
        }

        # Get type constraint
        $pType = $p.Value.ParameterType.FullName
        if ($pType -eq 'Microsoft.Graph.PowerShell.Runtime.SendAsyncStep[]' -or $pType -eq 'Microsoft.Graph.Beta.PowerShell.Runtime.SendAsyncStep[]')
        {
            $pType = 'System.Object[]'
        }
        if ($pType -like 'Microsoft.Graph.Beta.PowerShell.Support.*`[`]' -or $pType -like 'Microsoft.Graph.PowerShell.Support.*`[`]')
        {
            $pType = 'System.Object[]'
        }
        if ($pType -like 'Microsoft.Graph.Beta.PowerShell.Support.*' -or $pType -like 'Microsoft.Graph.PowerShell.Support.*')
        {
            $pType = 'System.Object'
        }
        if ($pType -like 'Microsoft.Graph.PowerShell.Models.*' -or $pType -like 'Microsoft.Graph.Beta.PowerShell.Models.*')
        {
            $pType = 'System.Object'
        }

        $pList.Add([ordered]@{
            Name     = $pName
            Type     = $pType
        })
    }

    # De-duplicate: take first occurrence of each parameter name
    $seen = @{}
    $uniqueParams = [System.Collections.Generic.List[object]]::new()
    foreach ($p in $pList) {
        if (-not $seen.ContainsKey($p.Name)) {
            $seen[$p.Name] = $true
            $uniqueParams.Add($p)
        }
    }

    $result[$fn.Name] = @($uniqueParams)
    $counter++
    if ($counter % 100 -eq 0) {
        Write-Host "  Processed $counter functions..."
    }
}

Write-Host "Saving $($result.Count) function signatures to: $OutputPath"
$result | ConvertTo-Json -Depth 4 | Set-Content $OutputPath -Encoding utf8

# Summary
$totalParams = 0
foreach ($v in $result.Values) { $totalParams += $v.Count }
Write-Host "Done. $($result.Count) functions, $totalParams total parameters."

# Show sample
$sample = $result['Get-MgBetaApplication']
if ($sample) {
    Write-Host "`nSample - Get-MgBetaApplication ($($sample.Count) params):"
    foreach ($p in $sample) {
        Write-Host "  $($p.Name): $($p.Type) Switch=$($p.IsSwitch)"
    }
}
