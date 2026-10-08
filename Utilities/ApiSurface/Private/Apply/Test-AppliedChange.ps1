<#
.SYNOPSIS
    Checks a resource after an edit and says whether the change may stay.

.DESCRIPTION
    Three gates, in cost order. The file parses, the property appears in the Get() result
    hashtable, the resource unit test passes. A declaration with no hashtable entry exports as
    null forever.

.PARAMETER Path
    Specifies the resource module.

.PARAMETER PropertyName
    Specifies the property to look for. Empty skips the presence gates.

.PARAMETER RequireResultEntry
    Indicates that the property must also appear in the Get() result hashtable.

.PARAMETER TestPath
    Specifies the resource unit test. Missing or empty skips the test gate.

.OUTPUTS
    An ordered dictionary with Passed and Reason.
#>
function Test-AppliedChange
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $PropertyName,

        [Parameter()]
        [switch]
        $RequireResultEntry,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $TestPath
    )

    try
    {
        $null = Get-ResourceAst -Path $Path
    }
    catch
    {
        return [ordered]@{ Passed = $false; Reason = $_.Exception.Message }
    }

    if (-not [System.String]::IsNullOrEmpty($PropertyName))
    {
        $classEdit = Get-ResourceClassEdit -Path $Path

        if (-not $classEdit.Property.Contains($PropertyName))
        {
            return [ordered]@{ Passed = $false; Reason = "'$PropertyName' is not declared on the class." }
        }

        if ($RequireResultEntry)
        {
            if ($null -eq $classEdit.ResultHashtable)
            {
                return [ordered]@{ Passed = $false; Reason = 'The Get() result hashtable could not be resolved.' }
            }

            $keys = @($classEdit.ResultHashtable.KeyValuePairs.Item1.Extent.Text)
            if ($keys -notcontains $PropertyName)
            {
                return [ordered]@{ Passed = $false; Reason = "'$PropertyName' is declared but absent from the Get() result hashtable, so it would export as null." }
            }
        }
    }

    if ([System.String]::IsNullOrEmpty($TestPath) -or -not (Test-Path -Path $TestPath))
    {
        return [ordered]@{ Passed = $true; Reason = 'No unit test was run.' }
    }

    $result = Invoke-Pester -Path $TestPath -PassThru -Output None
    if ($result.FailedCount -gt 0)
    {
        $failed = @($result.Tests | Where-Object -FilterScript { $_.Result -eq 'Failed' } |
                ForEach-Object -Process { $_.ExpandedName })
        return [ordered]@{ Passed = $false; Reason = "$($result.FailedCount) unit test(s) failed: $(($failed | Select-Object -First 3) -join '; ')" }
    }

    return [ordered]@{ Passed = $true; Reason = "$($result.PassedCount) unit test(s) passed." }
}
