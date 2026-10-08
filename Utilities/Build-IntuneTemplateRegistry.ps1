<#
.SYNOPSIS
    Rewrites IntuneTemplateRegistry.json from the template each resource pins.
#>
[CmdletBinding()]
param ()

. (Join-Path -Path $PSScriptRoot -ChildPath 'Get-M365DSCIntuneTemplateBinding.ps1')

$repositoryRoot = Join-Path -Path $PSScriptRoot -ChildPath '..' -Resolve
$bindings = @(Get-M365DSCIntuneTemplateBinding -ResourcePath (Join-Path -Path $repositoryRoot -ChildPath 'Modules/Microsoft365DSC/DscResources'))

$registry = [ordered]@{}
foreach ($binding in $bindings)
{
    $registry[$binding.Resource] = $binding.TemplateId
}

$json = ($registry | ConvertTo-Json -Depth 5) -replace "`r`n", "`n" -replace "`n", "`r`n"
[System.IO.File]::WriteAllText(
    (Join-Path -Path $repositoryRoot -ChildPath 'Modules/Microsoft365DSC/IntuneTemplateRegistry.json'),
    "$json`r`n", [System.Text.UTF8Encoding]::new($false))

Write-Verbose -Message "Wrote $($bindings.Count) template bindings."
