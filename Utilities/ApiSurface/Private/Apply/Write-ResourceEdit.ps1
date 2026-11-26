<#
.SYNOPSIS
    Splices a set of offset edits into a file and proves the result still parses.

.DESCRIPTION
    Follows Utilities/Convert-M365DSCResourceToClass.ps1. The file is written, re-parsed from disk
    and restored when the parse fails. Formatting varies across the 531 resources and nothing here
    matches on text.

.PARAMETER Path
    Specifies the file.

.PARAMETER Text
    Specifies the text the edits were computed against.

.PARAMETER Edit
    Specifies the edits, each with Offset, Length and Text.

.OUTPUTS
    The rewritten text.
#>
function Write-ResourceEdit
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Text,

        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $Edit
    )

    $result = Merge-ResourceEdit -Text $Text -Edit $Edit

    if (-not $PSCmdlet.ShouldProcess($Path, 'Apply drift edit'))
    {
        return $result
    }

    # The parse has to happen on disk. A relative 'using module' only resolves from the file path.
    [System.IO.File]::WriteAllText($Path, $result, [System.Text.UTF8Encoding]::new($false))

    try
    {
        $null = Get-ResourceAst -Path $Path
    }
    catch
    {
        [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
        throw "The edit left '$Path' unparseable and was rolled back. $($_.Exception.Message)"
    }

    return $result
}

<#
.SYNOPSIS
    Applies a set of offset edits to a string.

.DESCRIPTION
    An edit fully inside another is dropped and the outer one wins. The rest are applied from the
    highest offset down, which keeps every earlier offset valid.

.PARAMETER Text
    Specifies the text the offsets were computed against.

.PARAMETER Edit
    Specifies the edits.

.OUTPUTS
    The rewritten text.
#>
function Merge-ResourceEdit
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Text,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Edit
    )

    $ordered = @($Edit | Sort-Object -Property Offset, @{ Expression = { $_.Length }; Descending = $true })
    $kept = [System.Collections.Generic.List[System.Object]]::new()
    $coveredTo = -1

    foreach ($item in $ordered)
    {
        if ($item.Offset -lt $coveredTo)
        {
            continue
        }

        $kept.Add($item)
        $coveredTo = $item.Offset + $item.Length
    }

    $result = $Text
    foreach ($item in ($kept | Sort-Object -Property Offset -Descending))
    {
        $result = $result.Remove($item.Offset, $item.Length).Insert($item.Offset, $item.Text)
    }

    return $result
}

<#
.SYNOPSIS
    Builds one edit record.

.PARAMETER Offset
    Specifies where the replacement starts.

.PARAMETER Length
    Specifies how much is replaced.

.PARAMETER Text
    Specifies the replacement.

.PARAMETER Reason
    Specifies what the edit is for, reported when a run is inspected.

.OUTPUTS
    The edit record, a PSCustomObject that Sort-Object can order by property.
#>
function New-ResourceEdit
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Int32]
        $Offset,

        [Parameter(Mandatory = $true)]
        [System.Int32]
        $Length,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Text,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Reason
    )

    return [PSCustomObject]@{
        Offset = $Offset
        Length = $Length
        Text   = $Text
        Reason = $Reason
    }
}
