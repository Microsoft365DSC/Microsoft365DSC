<#
.SYNOPSIS
    Renders a value as PowerShell source text.

.DESCRIPTION
    Turns the fake/drift values carried by the property models into the literal text embedded in
    generated unit tests and example files. Supported values: $null, strings, booleans, numeric
    types, script blocks (emitted verbatim, e.g. { $Credential } renders as $Credential), arrays
    and dictionaries. IDictionary keys keep their order when the dictionary is ordered and are
    sorted alphabetically otherwise, so output stays deterministic either way.

.PARAMETER Value
    Specifies the value to render.

.PARAMETER IndentCount
    Specifies the current indentation in spaces. Nested structures indent by 4 from here.

.PARAMETER DoubleQuoteStrings
    Renders strings double-quoted (escaping ", ` and $) instead of single-quoted. Used by the
    example emitter, whose convention is double quotes.
#>
function ConvertTo-M365DSCPSLiteral
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter()]
        [System.Int32]
        $IndentCount = 0,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $DoubleQuoteStrings
    )

    $indent = ' ' * $IndentCount
    $childIndent = ' ' * ($IndentCount + 4)

    if ($null -eq $Value)
    {
        return '$null'
    }

    if ($Value -is [System.Management.Automation.ScriptBlock])
    {
        return $Value.ToString().Trim()
    }

    if ($Value -is [System.Boolean])
    {
        if ($Value)
        {
            return '$true'
        }

        return '$false'
    }

    if ($Value -is [System.String])
    {
        if ($DoubleQuoteStrings)
        {
            $escaped = $Value.Replace('`', '``').Replace('"', '`"').Replace('$', '`$')
            return '"' + $escaped + '"'
        }

        return "'" + $Value.Replace("'", "''") + "'"
    }

    if ($Value -is [System.ValueType])
    {
        return [System.Convert]::ToString($Value, [System.Globalization.CultureInfo]::InvariantCulture)
    }

    if ($Value -is [System.Collections.IDictionary])
    {
        if ($Value.Count -eq 0)
        {
            return '@{}'
        }

        $keys = @($Value.Keys)
        if ($Value -isnot [System.Collections.Specialized.OrderedDictionary])
        {
            $keys = @($keys | Sort-Object)
        }

        # Keys that are not plain identifiers (e.g. '@odata.type') must be quoted.
        $renderedKeys = @{}
        foreach ($key in $keys)
        {
            if ($key -match '^[A-Za-z_]\w*$')
            {
                $renderedKeys[$key] = $key
            }
            else
            {
                $renderedKeys[$key] = "'" + $key.Replace("'", "''") + "'"
            }
        }

        $longestKey = ($renderedKeys.Values | Measure-Object -Property Length -Maximum).Maximum

        $lines = @('@{')
        foreach ($key in $keys)
        {
            $renderedKey = $renderedKeys[$key]
            $padding = ' ' * ($longestKey - $renderedKey.Length)
            $renderedValue = ConvertTo-M365DSCPSLiteral -Value $Value[$key] -IndentCount ($IndentCount + 4) -DoubleQuoteStrings:$DoubleQuoteStrings
            $lines += "$childIndent$renderedKey$padding = $renderedValue"
        }
        $lines += "$indent}"

        return $lines -join [System.Environment]::NewLine
    }

    if ($Value -is [System.Collections.IEnumerable])
    {
        $items = @($Value)
        if ($items.Count -eq 0)
        {
            return '@()'
        }

        $hasStructuredItem = $false
        foreach ($item in $items)
        {
            if ($item -is [System.Collections.IDictionary] -or ($item -is [System.Collections.IEnumerable] -and $item -isnot [System.String]))
            {
                $hasStructuredItem = $true
                break
            }
        }

        if (-not $hasStructuredItem)
        {
            $renderedItems = foreach ($item in $items)
            {
                ConvertTo-M365DSCPSLiteral -Value $item -DoubleQuoteStrings:$DoubleQuoteStrings
            }

            return '@(' + ($renderedItems -join ', ') + ')'
        }

        $lines = @('@(')
        foreach ($item in $items)
        {
            $lines += "$childIndent" + (ConvertTo-M365DSCPSLiteral -Value $item -IndentCount ($IndentCount + 4) -DoubleQuoteStrings:$DoubleQuoteStrings)
        }
        $lines += "$indent)"

        return $lines -join [System.Environment]::NewLine
    }

    throw "ConvertTo-M365DSCPSLiteral: unsupported value type '$($Value.GetType().FullName)'."
}
