<#
.SYNOPSIS
    Produces the fake (desired-state) or drifted value for a property model.

.DESCRIPTION
    Fake values populate the generated unit test mocks, the desired-state test parameters and the
    example files. Drift values are guaranteed to differ from the fake value so that the generated
    "values are NOT in the desired state" test context exercises a real drift.

    Auth properties return $null (they are wired to $Credential and friends by the emitters, not
    faked). A property whose drift cannot differ - an enum with a single allowed value - returns
    $null from the drift projection, and complex values drift exactly one driftable scalar leaf.

    ScriptBlock values are understood by ConvertTo-M365DSCPSLiteral as raw PowerShell text.
#>
function Get-M365DSCFakeValue
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $PropertyModel,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Drift
    )

    if ($PropertyModel.IsAuth)
    {
        return $null
    }

    $value = $null

    switch ($PropertyModel.FakeKind)
    {
        'String'
        {
            if ($Drift)
            {
                $value = 'FakeStringValueDrift'
            }
            else
            {
                $value = 'FakeStringValue'
            }
        }
        'Boolean'
        {
            $value = -not $Drift.IsPresent
        }
        'Int'
        {
            if ($Drift)
            {
                $value = 7
            }
            else
            {
                $value = 25
            }
        }
        'Real'
        {
            if ($Drift)
            {
                $value = 7.5
            }
            else
            {
                $value = 2.5
            }
        }
        'DateTime'
        {
            # Matches what Get() emits: .ToUniversalTime().ToString('o') of a UTC instant.
            if ($Drift)
            {
                $value = '2024-01-01T00:00:00.0000000Z'
            }
            else
            {
                $value = '2023-01-01T00:00:00.0000000Z'
            }
        }
        'Time'
        {
            if ($Drift)
            {
                $value = '01:00:00'
            }
            else
            {
                $value = '00:00:00'
            }
        }
        'Guid'
        {
            if ($Drift)
            {
                $value = 'bbbbbbbb-2222-3333-4444-cccccccccccc'
            }
            else
            {
                $value = 'aaaaaaaa-0000-1111-2222-bbbbbbbbbbbb'
            }
        }
        'IntEnum'
        {
            # Choice settings with integer option values (settings catalog).
            if ($Drift)
            {
                if ($PropertyModel.EnumValues.Count -gt 1)
                {
                    $value = [System.Int32] $PropertyModel.EnumValues[1]
                }
                else
                {
                    $value = $null
                }
            }
            else
            {
                $value = [System.Int32] $PropertyModel.EnumValues[0]
            }
        }
        'Enum'
        {
            if ($Drift)
            {
                if ($PropertyModel.EnumValues.Count -gt 1)
                {
                    $value = $PropertyModel.EnumValues[1]
                }
                else
                {
                    # Single allowed value: no drift is possible for this property.
                    $value = $null
                }
            }
            else
            {
                $value = $PropertyModel.EnumValues[0]
            }
        }
        'Credential'
        {
            $value = { $Credential }
        }
        'Complex'
        {
            $value = @{}
            $drifted = $false
            foreach ($member in $PropertyModel.Members)
            {
                $memberValue = Get-M365DSCFakeValue -PropertyModel $member

                # Drift exactly one scalar leaf so the drift stays observable and minimal.
                if ($Drift -and -not $drifted -and -not $member.IsComplex)
                {
                    $driftCandidate = Get-M365DSCFakeValue -PropertyModel $member -Drift
                    if ($null -ne $driftCandidate)
                    {
                        $memberValue = $driftCandidate
                        $drifted = $true
                    }
                }

                if ($null -ne $memberValue)
                {
                    $value[$member.Name] = $memberValue
                }
            }
        }
    }

    if ($null -eq $value)
    {
        return $null
    }

    if ($PropertyModel.IsArray)
    {
        if ($PropertyModel.FakeKind -eq 'String' -and -not $PropertyModel.IsEnum)
        {
            if ($Drift)
            {
                return @('FakeStringArrayValueDrift1', 'FakeStringArrayValue2')
            }

            return @('FakeStringArrayValue1', 'FakeStringArrayValue2')
        }

        return @($value)
    }

    return $value
}
