<#
.SYNOPSIS
    Generates an HTML or JSON test report from deployment test results.

.DESCRIPTION
    Takes the results array from Invoke-M365DSCDeploymentTest and generates
    a detailed report showing pass/fail status, drift details, and timing
    per resource and authentication method.

.PARAMETER Results
    Array of test result hashtables from the deployment test engine.

.PARAMETER OutputPath
    Path where the report file will be saved.

.PARAMETER Type
    Report type: HTML or JSON. Defaults to HTML.

.EXAMPLE
    $results = Invoke-M365DSCDeploymentTest -Workload 'AAD' -AuthMethod 'CertificateThumbprint'
    New-TestReport -Results $results -OutputPath './TestReport.html'
#>
function New-TestReport
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable[]]
        $Results,

        [Parameter(Mandatory = $true)]
        [System.String]
        $OutputPath,

        [Parameter()]
        [ValidateSet('HTML', 'JSON')]
        [System.String]
        $Type = 'HTML'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $totalTests = $Results.Count
    $passed = ($Results | Where-Object { $_.Status -eq 'Passed' }).Count
    $failed = ($Results | Where-Object { $_.Status -eq 'Failed' }).Count
    $skipped = ($Results | Where-Object { $_.Status -eq 'Skipped' }).Count
    $knownIssue = ($Results | Where-Object { $_.Status -eq 'KnownIssue' }).Count

    if ($Type -eq 'JSON')
    {
        $report = @{
            Timestamp    = $timestamp
            Summary      = @{
                Total      = $totalTests
                Passed     = $passed
                Failed     = $failed
                Skipped    = $skipped
                KnownIssue = $knownIssue
            }
            Results      = $Results
        }
        $report | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputPath -Encoding UTF8
        Write-Host "JSON report saved to: $OutputPath" -ForegroundColor Green
        return
    }

    # HTML Report
    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>M365DSC Deployment Test Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #1a1a2e; color: #eee; padding: 20px; }
        .header { background: linear-gradient(135deg, #16213e, #0f3460); padding: 30px; border-radius: 12px; margin-bottom: 20px; }
        .header h1 { font-size: 24px; margin-bottom: 8px; }
        .header .timestamp { color: #a0a0b0; font-size: 14px; }
        .summary { display: flex; gap: 15px; margin-bottom: 20px; flex-wrap: wrap; }
        .summary .card { flex: 1; min-width: 150px; padding: 20px; border-radius: 10px; text-align: center; }
        .card.total { background: #16213e; }
        .card.passed { background: #1b4332; }
        .card.failed { background: #641220; }
        .card.skipped { background: #3d3d00; }
        .card.known { background: #5a3e00; }
        .card .number { font-size: 36px; font-weight: bold; }
        .card .label { font-size: 14px; color: #a0a0b0; margin-top: 5px; }
        table { width: 100%; border-collapse: collapse; background: #16213e; border-radius: 10px; overflow: hidden; }
        th { background: #0f3460; padding: 12px 15px; text-align: left; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
        td { padding: 10px 15px; border-bottom: 1px solid #1a1a3e; font-size: 14px; }
        tr:hover td { background: #1a2744; }
        .status-passed { color: #4ade80; font-weight: bold; }
        .status-failed { color: #f87171; font-weight: bold; }
        .status-skipped { color: #fbbf24; font-weight: bold; }
        .status-knownissue { color: #fb923c; font-weight: bold; }
        .auth-badge { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 12px; margin: 1px; background: #0f3460; }
        .drift-details { font-size: 12px; color: #f87171; max-width: 400px; overflow: hidden; text-overflow: ellipsis; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Microsoft365DSC Deployment Test Report</h1>
        <div class="timestamp">Generated: $timestamp</div>
    </div>

    <div class="summary">
        <div class="card total"><div class="number">$totalTests</div><div class="label">Total Tests</div></div>
        <div class="card passed"><div class="number">$passed</div><div class="label">Passed</div></div>
        <div class="card failed"><div class="number">$failed</div><div class="label">Failed</div></div>
        <div class="card skipped"><div class="number">$skipped</div><div class="label">Skipped</div></div>
        <div class="card known"><div class="number">$knownIssue</div><div class="label">Known Issues</div></div>
    </div>

    <table>
        <thead>
            <tr>
                <th>Resource</th>
                <th>Auth Method</th>
                <th>Status</th>
                <th>Deploy</th>
                <th>Export</th>
                <th>Drift Check</th>
                <th>Duration</th>
                <th>Details</th>
            </tr>
        </thead>
        <tbody>
"@

    foreach ($result in ($Results | Sort-Object { $_.ResourceName }))
    {
        $statusClass = "status-$($result.Status.ToLower())"
        $driftInfo = if ($result.DriftDetails) { $result.DriftDetails } else { '-' }
        $deployIcon  = if ($result.DeploySuccess)  { '&#x2705;' } else { '&#x274C;' }
        $exportIcon  = if ($result.ExportSuccess)  { '&#x2705;' } else { '&#x274C;' }
        $driftIcon   = if ($result.NoDrift)        { '&#x2705;' } else { '&#x274C;' }

        if ($result.Status -eq 'Skipped')
        {
            $deployIcon = '&#x23ED;'
            $exportIcon = '&#x23ED;'
            $driftIcon  = '&#x23ED;'
        }

        $html += @"
            <tr>
                <td>$($result.ResourceName)</td>
                <td><span class="auth-badge">$($result.AuthMethod)</span></td>
                <td class="$statusClass">$($result.Status)</td>
                <td>$deployIcon</td>
                <td>$exportIcon</td>
                <td>$driftIcon</td>
                <td>$($result.Duration)</td>
                <td class="drift-details">$driftInfo</td>
            </tr>
"@
    }

    $html += @"
        </tbody>
    </table>
</body>
</html>
"@

    $html | Set-Content -Path $OutputPath -Encoding UTF8
    Write-Host "HTML report saved to: $OutputPath" -ForegroundColor Green
}

Export-ModuleMember -Function @(
    'New-TestReport'
)
