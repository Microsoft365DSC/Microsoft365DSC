<#
.SYNOPSIS
    Returns the Intune configuration policy template each resource pins.

.DESCRIPTION
    The binding is a literal assignment in the resource module, spelled templateReferenceId in some
    resources and policyTemplateId in others. A mention in a comment or inside a string does not
    count.

.PARAMETER ResourcePath
    Specifies the folder holding the MSFT_<Name> resource folders.

.OUTPUTS
    Objects with Resource and TemplateId, ordered by resource name.
#>
function Get-M365DSCIntuneTemplateBinding
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourcePath
    )

    $names = @('templateReferenceId', 'policyTemplateId')
    $bindings = [System.Collections.Generic.List[System.Object]]::new()

    foreach ($file in (Get-ChildItem -Path $ResourcePath -Filter '*.psm1' -Recurse -File | Sort-Object -Property FullName))
    {
        $content = Get-Content -Path $file.FullName -Raw
        if ($null -eq $content -or ($names | Where-Object -FilterScript { $content -match $_ }).Count -eq 0)
        {
            continue
        }

        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref] $null, [ref] $parseErrors)
        if ($parseErrors.Count -gt 0)
        {
            throw "'$($file.FullName)' does not parse: $($parseErrors[0].Message)"
        }

        $found = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)

        foreach ($assignment in $ast.FindAll({
                    param ($node)
                    return $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                        $node.Left -is [System.Management.Automation.Language.VariableExpressionAst] -and
                        $node.Right.Expression -is [System.Management.Automation.Language.StringConstantExpressionAst]
                }, $true))
        {
            if ($assignment.Left.VariablePath.UserPath -notin $names)
            {
                continue
            }

            $null = $found.Add($assignment.Right.Expression.Value)
        }

        if ($found.Count -eq 0)
        {
            continue
        }

        $resource = $file.BaseName -replace '^MSFT_', ''

        if ($found.Count -gt 1)
        {
            throw "'$resource' pins more than one template: $(@($found) -join ', ')."
        }

        $bindings.Add([PSCustomObject]@{
                Resource   = $resource
                TemplateId = @($found)[0]
            })
    }

    return [System.Object[]] @($bindings | Sort-Object -Property @{ Expression = { $_.Resource } })
}
