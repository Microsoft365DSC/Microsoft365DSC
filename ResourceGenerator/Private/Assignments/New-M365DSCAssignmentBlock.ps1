<#
    Emitter blocks for the Intune Assignments property, following the shipped class-based
    resources (e.g. MSFT_IntuneWindowsUpdateForBusinessDriverUpdateProfileWindows10): read via
    the assignment cmdlet + ConvertFrom-IntunePolicyAssignment, write via
    ConvertTo-IntunePolicyAssignment + Update-DeviceConfigurationPolicyAssignment.
#>

<#
.SYNOPSIS
    Renders the assignments retrieval appended after the Get() result hashtable.
#>
function New-M365DSCAssignmentsGetBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel
    )

    if (-not $ResourceModel.HasAssignments)
    {
        return ''
    }

    $indent = ' ' * 12
    $cmdlets = $ResourceModel.Cmdlets
    $builder = [System.Text.StringBuilder]::new()

    if ($ResourceModel.AssignmentKind -eq 'MobileApp')
    {
        $null = $builder.AppendLine('')
        $null = $builder.AppendLine("$indent`$assignmentsValues = $($cmdlets.AssignmentCmdlet) -$($cmdlets.AssignmentKeyParameter) `$getValue.Id -ErrorAction SilentlyContinue")
        $null = $builder.AppendLine("$indent`$assignmentResult = @()")
        $null = $builder.AppendLine("${indent}if (`$null -ne `$assignmentsValues -and `$assignmentsValues.Count -gt 0)")
        $null = $builder.AppendLine("$indent{")
        $null = $builder.AppendLine("$indent    [array] `$assignmentsValues = `$assignmentsValues | Where-Object -FilterScript { `$_.source -eq 'direct' }")
        $null = $builder.AppendLine("$indent    `$assignmentResult += ConvertFrom-IntuneMobileAppAssignment ``")
        $null = $builder.AppendLine("$indent        -IncludeDeviceFilter `$true ``")
        $null = $builder.AppendLine("$indent        -Assignments `$assignmentsValues")
        $null = $builder.AppendLine("$indent}")
        $null = $builder.Append("$indent`$result.Add('Assignments', `$assignmentResult)")

        return $builder.ToString()
    }

    $null = $builder.AppendLine('')
    $null = $builder.AppendLine("$indent`$assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance `$getValue")
    $null = $builder.AppendLine("${indent}if (`$null -eq `$assignmentsValues)")
    $null = $builder.AppendLine("$indent{")
    $null = $builder.AppendLine("$indent    `$assignmentsValues = $($cmdlets.AssignmentCmdlet) -$($cmdlets.AssignmentKeyParameter) `$getValue.Id -ErrorAction SilentlyContinue")
    $null = $builder.AppendLine("$indent}")
    $null = $builder.AppendLine("$indent`$assignmentResult = @()")
    $null = $builder.AppendLine("${indent}if (`$null -ne `$assignmentsValues -and `$assignmentsValues.Count -gt 0)")
    $null = $builder.AppendLine("$indent{")
    $null = $builder.AppendLine("$indent    `$assignmentResult += ConvertFrom-IntunePolicyAssignment ``")
    $null = $builder.AppendLine("$indent        -IncludeDeviceFilter:`$true ``")
    $null = $builder.AppendLine("$indent        -Assignments `$assignmentsValues")
    $null = $builder.AppendLine("$indent}")
    $null = $builder.Append("$indent`$result.Add('Assignments', `$assignmentResult)")

    return $builder.ToString()
}

<#
.SYNOPSIS
    Renders the assignment update appended to a Set() create or update branch.

.PARAMETER PolicyIdExpression
    Specifies the expression holding the policy id, e.g. '$createdInstance.Id' or '$this.Id'.
#>
function New-M365DSCAssignmentsSetBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PolicyIdExpression
    )

    $indent = ' ' * 16
    $cmdlets = $ResourceModel.Cmdlets
    $builder = [System.Text.StringBuilder]::new()

    if ($ResourceModel.AssignmentKind -eq 'MobileApp')
    {
        $null = $builder.AppendLine('')
        $null = $builder.AppendLine("$indent`$assignmentsHash = ConvertTo-IntuneMobileAppAssignment -IncludeDeviceFilter:`$true -Assignments `$this.Assignments")
        $null = $builder.AppendLine("${indent}if ($PolicyIdExpression)")
        $null = $builder.AppendLine("$indent{")
        $null = $builder.AppendLine("$indent    Update-DeviceAppManagementPolicyAssignment ``")
        $null = $builder.AppendLine("$indent        -AppManagementPolicyId $PolicyIdExpression ``")
        $null = $builder.AppendLine("$indent        -Assignments `$assignmentsHash")
        $null = $builder.Append("$indent}")

        return $builder.ToString()
    }

    $null = $builder.AppendLine('')
    $null = $builder.AppendLine("$indent`$assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:`$true -Assignments `$this.Assignments")
    $null = $builder.AppendLine("${indent}if ($PolicyIdExpression)")
    $null = $builder.AppendLine("$indent{")
    $null = $builder.AppendLine("$indent    Update-DeviceConfigurationPolicyAssignment ``")
    $null = $builder.AppendLine("$indent        -DeviceConfigurationPolicyId $PolicyIdExpression ``")
    $null = $builder.AppendLine("$indent        -Targets `$assignmentsHash ``")
    $null = $builder.AppendLine("$indent        -Repository '$($cmdlets.AssignmentRepository)'")
    $null = $builder.Append("$indent}")

    return $builder.ToString()
}
