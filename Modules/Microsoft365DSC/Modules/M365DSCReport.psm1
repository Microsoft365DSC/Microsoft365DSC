$Script:ReportCSS = @'
<style>
    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background-color: #f8f9fa;
        color: #212529;
        margin: 0;
        padding: 20px;
    }
    .report-container {
        max-width: 1200px;
        margin: auto;
        background-color: #ffffff;
        border: 1px solid #dee2e6;
        border-radius: 5px;
        padding: 40px;
        box-shadow: 0 0 10px rgba(0,0,0,0.1);
    }
    h1, h2, h3 {
        color: #005a9e;
    }
    h1 {
        text-align: center;
        border-bottom: 2px solid #005a9e;
        padding-bottom: 10px;
        margin-top: 0;
    }
    h2 {
        border-bottom: 1px solid #ccc;
        padding-bottom: 5px;
        margin-top: 0;
    }
    table .resource-icon {
        width: 20%;
        text-align: center;
        vertical-align: middle;
    }
    .comparison-text {
        text-align: center;
        font-style: italic;
        color: #4d6477;
        margin: 40px 0 20px 0;
    }
    .comparison-text ul {
        display: inline-block;
        text-align: left;
        margin-top: 5px;
        padding-left: 20px;
    }
    .logo-container {
        text-align: center;
        margin-bottom: 20px;
    }
    .workload-section {
        margin-bottom: 30px;
    }
    .workload-header {
        background-color: #f0f0f0;
        padding: 15px;
        border-left: 4px solid #005a9e;
        margin-bottom: 15px;
        border-radius: 3px;
    }
    .workload-header h3 {
        margin: 0;
        color: #005a9e;
    }
    .workload-header img {
        height: 40px;
        width: auto;
    }
    .toc {
        background-color: #e9ecef;
        padding: 5px 15px 5px;
        border-radius: 5px;
        border: 1px solid #dee2e6;
    }
    .toc ul {
        list-style-type: none;
        padding: 0;
        margin: 0;
    }
    .toc li {
        margin-bottom: 10px;
    }
    .toc a {
        text-decoration: none;
        color: #005a9e;
        font-weight: bold;
    }
    .toc a:hover {
        text-decoration: underline;
    }
    .resource-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 20px;
        border: 1px solid #dee2e6;
        h1, h2, h3 {
            color: #ffffff;
        }
    }
    .resource-table th, .resource-table td {
        padding: 8px 12px;
        text-align: left;
        border: 1px solid #dee2e6;
    }
    .resource-table .resource-header {
        background-color: #005a9e;
        color: #ffffff;
        text-align: center;
    }
    .drift-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 20px;
        border: 1px solid #dee2e6;
        h1, h2, h3 {
            color: #ffffff;
        }
    }
    .drift-table th, .drift-table td {
        padding: 8px 12px;
        text-align: left;
        border: 1px solid #dee2e6;
    }
    .drift-table .drift-header {
        background-color: #005a9e;
        color: #ffffff;
        text-align: center;
    }
    .drift-table .drift-subheader {
        background-color: #e9ecef;
        font-weight: bold;
        text-align: center;
    }
    .property-name {
        text-align: left;
        font-weight: bold;
        width: 25%;
    }
    .property-value {
        text-align: left;
        width: 75%;
        max-width: 600px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .drift-table .value-cell {
        width: 27.5%;
    }
    .level-L1 { background-color: #F6CECE; }
    .level-L2 { background-color: #F7F8E0; }
    .level-L3 { background-color: #FFFFFF; }
    .emoticon { font-size: 1.2em; }
    .no-discrepancies {
        text-align: center;
        font-size: 1.2em;
        color: #28a745;
        margin-top: 20px;
        padding: 20px;
        background-color: #e9f7ef;
        border: 1px solid #a3d9b8;
        border-radius: 5px;
    }
</style>
'@

# Shared lookup table mapping resource name prefixes to workload names and icon file names.
# Order matters: longer/more-specific prefixes must come before shorter ones (e.g. 'SPO' before 'SH').
$Script:WorkloadMapping = [ordered]@{
    'AAD'      = @{ WorkloadName = 'Azure Active Directory'; IconName = 'AzureAD.jpg' }
    'ADO'      = @{ WorkloadName = 'Azure DevOps';           IconName = 'AzureDevOps.png' }
    'Azure'    = @{ WorkloadName = 'Azure';                  IconName = 'Azure.png' }
    'Defender' = @{ WorkloadName = 'Microsoft Defender';      IconName = 'SecurityAndCompliance.png' }
    'EXO'      = @{ WorkloadName = 'Exchange Online';        IconName = 'Exchange.jpg' }
    'Intune'   = @{ WorkloadName = 'Intune';                 IconName = 'Intune.jpg' }
    'O365'     = @{ WorkloadName = 'Office 365';             IconName = 'Office365.jpg' }
    'OD'       = @{ WorkloadName = 'OneDrive';               IconName = 'OneDrive.jpg' }
    'Planner'  = @{ WorkloadName = 'Planner';                IconName = 'Planner.png' }
    'PP'       = @{ WorkloadName = 'Power Platform';         IconName = 'PowerApps.jpg' }
    'SC'       = @{ WorkloadName = 'Security & Compliance';  IconName = 'SecurityAndCompliance.png' }
    'Sentinel' = @{ WorkloadName = 'Sentinel';               IconName = $null }
    'SH'       = @{ WorkloadName = 'Services Hub';           IconName = $null }
    'SPO'      = @{ WorkloadName = 'SharePoint Online';      IconName = 'SharePoint.jpg' }
    'Teams'    = @{ WorkloadName = 'Microsoft Teams';        IconName = 'Teams.jpg' }
}

<#
.DESCRIPTION
    This function generates HTML workload sections by grouping resources

.FUNCTIONALITY
    Internal, Hidden
#>
function New-M365DSCWorkloadSection
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Array]
        $Resources,

        [Parameter(Mandatory = $true)]
        [ScriptBlock]
        $ResourceRenderer
    )

    $output = [System.Text.StringBuilder]::new()

    # Group by workload
    $resourcesByWorkload = @{}
    foreach ($resource in $Resources)
    {
        $workload = Get-M365WorkloadName -ResourceName $resource.ResourceName
        if (-not $resourcesByWorkload.ContainsKey($workload))
        {
            $resourcesByWorkload[$workload] = @()
        }
        $resourcesByWorkload[$workload] += $resource
    }

    # Process each workload group
    foreach ($workload in ($resourcesByWorkload.Keys | Sort-Object))
    {
        $workloadResources = $resourcesByWorkload[$workload]
        $firstResource = $workloadResources[0]

        [void]$output.AppendLine("<div class='workload-section'>")
        [void]$output.AppendLine("<div class='workload-header'>")
        $iconPath = Get-IconPath -ResourceName $firstResource.ResourceName
        [void]$output.AppendLine("<img src='$iconPath' alt='$workload' style='vertical-align: middle; margin-right: 10px;' />")
        [void]$output.AppendLine("<h3 style='display: inline;'>$workload</h3>")
        [void]$output.AppendLine('</div>')

        foreach ($resource in $workloadResources)
        {
            $resourceOutput = & $ResourceRenderer $resource
            [void]$output.Append($resourceOutput)
        }

        [void]$output.AppendLine('</div>')
    }

    return $output.ToString()
}

<#
.DESCRIPTION
    This function creates a Markdown report from the specified exported configuration. Every
    resource instance lands in one document, unless SplitByResource is specified.

.FUNCTIONALITY
    Internal, Hidden
#>
function New-M365DSCConfigurationToMarkdown
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [Array]
        $ParsedContent,

        [Parameter(Mandatory = $true)]
        [System.String]
        $OutputPath,

        [Parameter()]
        [System.String]
        $OrganizationName,

        [Parameter()]
        [System.String]
        $TenantGuid,

        [Parameter()]
        [Switch]
        $IncludeAllInformation,

        [Parameter()]
        [Switch]
        $SplitByResource
    )

    Initialize-M365DSCDllLoader -ErrorAction Stop

    $OutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
    if ($SplitByResource -and [System.IO.Path]::GetExtension($OutputPath) -eq '.md')
    {
        $outputFolder = Split-Path -Path $OutputPath -Parent
        Write-Warning -Message "A split Markdown report is written to a folder. Using '$outputFolder' instead of '$OutputPath'."
        $OutputPath = $outputFolder
    }

    $resources = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()
    foreach ($resource in $ParsedContent)
    {
        if ($resource -isnot [System.Collections.IDictionary])
        {
            throw "ParsedContent contains a $($resource.GetType().Name). Every entry has to be a dictionary."
        }

        $resources.Add($resource)
    }

    $request = [Microsoft365DSC.Reporting.ReportRequest]::new()
    $request.Resources = $resources
    $request.OutputPath = $OutputPath
    $request.ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
    $request.OrganizationName = $OrganizationName
    $request.TenantGuid = $TenantGuid
    $request.IncludeAllInformation = $IncludeAllInformation.IsPresent
    $request.SplitByResource = $SplitByResource.IsPresent
    $request.Warn = [System.Action[System.String]] { param($Message) Write-Warning -Message $Message }

    $null = [Microsoft365DSC.Reporting.ReportConverterRegistry]::Convert('Markdown', $request)
}

<#
.DESCRIPTION
    This function creates a new HTML document from the specified exported configuration

.FUNCTIONALITY
    Internal, Hidden
#>
function New-M365DSCConfigurationToHTML
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [Array]
        $ParsedContent,

        [Parameter()]
        [System.String]
        $OutputPath,

        [Parameter()]
        [System.String]
        $TemplateName,

        [Parameter()]
        [switch]
        $SortProperties
    )

    # Always sort properties by default
    $SortProperties = $true

    if ([System.String]::IsNullOrEmpty($TemplateName))
    {
        $TemplateName = 'Configuration Report'
    }

    Write-Output 'Generating HTML report'
    $fullHTML = '<!DOCTYPE html>'
    $fullHTML += '<html>'
    $fullHTML += '<head><meta charset="utf-8"><title>Configuration Report</title>'
    $fullHTML += $Script:ReportCSS
    $fullHTML += '</head>'
    $fullHTML += '<body>'
    $fullHTML += "<div class='report-container'>"
    $fullHTML += '<h1>' + $TemplateName + '</h1>'
    $fullHTML += "<div class='logo-container'><img src='" + (Get-IconPath -ResourceName 'Promo') + "' alt='Microsoft365DSC Slogan' width='500' /></div>"
    $fullHTML += '<h2>Template Details</h2>'

    # Group resources by workload
    $resourcesByWorkload = @{}
    foreach ($resource in $parsedContent)
    {
        $workload = Get-M365WorkloadName -ResourceName $resource.ResourceName
        if (-not $resourcesByWorkload.ContainsKey($workload))
        {
            $resourcesByWorkload[$workload] = @()
        }
        $resourcesByWorkload[$workload] += $resource
    }

    $totalCount = $parsedContent.Count
    $currentCount = 0

    # Process each workload group
    foreach ($workload in ($resourcesByWorkload.Keys | Sort-Object))
    {
        $workloadResources = $resourcesByWorkload[$workload]
        $firstResource = $workloadResources[0]

        # Add workload header with icon
        $fullHTML += "<div class='workload-section'>"
        $fullHTML += "<div class='workload-header'>"
        $fullHTML += "<img src='" + (Get-IconPath -ResourceName $firstResource.ResourceName) + "' alt='$workload' style='vertical-align: middle; margin-right: 10px;' />"
        $fullHTML += "<h3 style='display: inline;'>$workload</h3>"
        $fullHTML += '</div>'

        # Process each resource in this workload
        foreach ($resource in $workloadResources)
        {
            $percentage = [math]::Round(($currentCount / $totalCount) * 100, 2)
            Write-Progress -Activity 'Processing generated DSC Object' -Status ("{0:N2}% completed - $($resource.ResourceName)" -f $percentage) -PercentComplete $percentage

            $partHTML = "<table class='resource-table'>"
            $partHTML += "<tr><td class='resource-header' colspan='2'>"
            $partHTML += '<strong>' + $resource.ResourceName + " '" + $resource.ResourceInstanceName + "'</strong>"
            $resource.Remove('ResourceInstanceName') | Out-Null
            $partHTML += '</td></tr>'

            if ($SortProperties)
            {
                $properties = $resource.Keys | Sort-Object
            }
            else
            {
                $properties = $resource.Keys
            }

            foreach ($property in $properties)
            {
                if ($property -ne 'ResourceName')
                {
                    $partHTML += "<tr><td class='property-name'>" + $property + '</td>'
                    $value = "`$null"
                    if ($null -ne $resource.$property)
                    {
                        if ($resource.$property.GetType().Name -eq 'Object[]' -or `
                            $resource.$property.GetType().Name -eq 'Hashtable')
                        {
                            if ($resource.$property -and
                                (($resource.$property -is [hashtable]) -or ($resource.$property -is [array] -and $resource.$property.Count -gt 0 -and ($resource.$property[0] -is [hashtable])))
                            )
                            {
                                $value = Convert-ObjectToHtmlList -InputObject $resource.$property -ParentName $property
                            }
                            else
                            {
                                $temp = $resource.$property -join ','
                                [array]$components = $temp.Split(',')
                                if ($components.Length -gt 0 -and
                                    -not [System.String]::IsNullOrEmpty($temp))
                                {
                                    $Value = '<ul>'
                                    foreach ($comp in $components)
                                    {
                                        $value += "<li>$comp</li>"
                                    }
                                    $value += '</ul>'
                                }
                            }
                        }
                        else
                        {
                            if (-not [System.String]::IsNullOrEmpty($resource.$property))
                            {
                                $value = ($resource.$property).ToString()
                            }
                        }
                    }
                    $partHTML += "<td class='property-value'>" + $value + '</td></tr>'
                }
            }

            $partHTML += '</table><br />'
            $fullHTML += $partHTML

            $currentCount++
        }

        $fullHTML += '</div>' # Close workload-section
    }

    $fullHTML += '</div>' # Close report-container
    $fullHTML += '</body>'
    $fullHTML += '</html>'

    if (-not [System.String]::IsNullOrEmpty($OutputPath))
    {
        Write-Output 'Saving HTML report'
        $fullHtml | Out-File $OutputPath
    }

    Write-Output 'Completed generating HTML report'
}

<#
.DESCRIPTION
    This function creates a new JSON file from the specified exported configuration

.FUNCTIONALITY
    Internal, Hidden
#>
function New-M365DSCConfigurationToJSON
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Array]
        $ParsedContent,

        [Parameter(Mandatory = $true)]
        [System.String]
        $OutputPath
    )

    $jsonContent = $ParsedContent | ConvertTo-Json -Depth 25
    $jsonContent | Out-File -FilePath $OutputPath
}

<#
.DESCRIPTION
    This function gets the workload name from a resource name

.FUNCTIONALITY
    Internal, Hidden
#>
function Get-M365WorkloadName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName
    )

    foreach ($prefix in $Script:WorkloadMapping.Keys)
    {
        if ($ResourceName.StartsWith($prefix))
        {
            return $Script:WorkloadMapping[$prefix].WorkloadName
        }
    }

    return 'Other'
}

<#
.DESCRIPTION
    This function gets the URL to the logo of the workload of the specified resource

.FUNCTIONALITY
    Internal, Hidden
#>
function Get-IconPath
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName
    )

    if ($ResourceName.StartsWith('Promo'))
    {
        return Get-Base64EncodedImage -IconName 'Promo.png'
    }

    foreach ($prefix in $Script:WorkloadMapping.Keys)
    {
        if ($ResourceName.StartsWith($prefix))
        {
            $iconName = $Script:WorkloadMapping[$prefix].IconName
            if ($null -ne $iconName)
            {
                return Get-Base64EncodedImage -IconName $iconName
            }
            return $null
        }
    }

    return $null
}

<#
.DESCRIPTION
    This function returns a string containing mime-type and base64 encoded image to embed into DSC report directly.

.FUNCTIONALITY
    Internal, Hidden
#>
function Get-Base64EncodedImage
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [string]
        $IconName
    )

    $IconPath = Join-Path -Path $PSScriptRoot `
        -ChildPath "..\Dependencies\Images\$($IconName)" `
        -Resolve

    if (Test-Path -Path $IconPath)
    {
        $icon = Get-Item -Path $IconPath

        if ($icon.Extension.EndsWith('jpg') -or $icon.Extension.EndsWith('jpeg'))
        {
            $mimeType = 'image/jpeg'
        }

        if ($icon.Extension.EndsWith('png'))
        {
            $mimeType = 'image/png'
        }

        if ($PSVersionTable.PSEdition -eq 'Core')
        {
            $base64EncodedImage = [System.Convert]::ToBase64String((Get-Content -Path $IconPath -AsByteStream -ReadCount 0))
        }
        else
        {
            $base64EncodedImage = [System.Convert]::ToBase64String((Get-Content -Path $iconPath -Encoding Byte -ReadCount 0))
        }

        return $("data:$($mimeType);base64,$($base64EncodedImage)")
    }
    else
    {
        return $null
    }
}

<#
.DESCRIPTION
    This function creates a new Excel document from the specified exported configuration

.FUNCTIONALITY
    Internal, Hidden
#>
function New-M365DSCConfigurationToExcel
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Array]
        $ParsedContent,

        [Parameter(Mandatory = $true)]
        [System.String]
        $OutputPath
    )

    try
    {
        $excel = New-Object -ComObject excel.application
    }
    catch [System.Runtime.InteropServices.COMException]
    {
        throw 'Excel is not installed on this machine. Please install Excel to use this feature.'
    }
    $excel.visible = $True
    $workbook = $excel.Workbooks.Add()
    $report = $workbook.Worksheets.Item(1)
    $report.Name = 'Report'
    $report.Cells.Item(1, 1) = 'Component Name'
    $report.Cells.Item(1, 1).Font.Size = 18
    $report.Cells.Item(1, 1).Font.Bold = $True
    $report.Cells.Item(1, 2) = 'Property'
    $report.Cells.Item(1, 2).Font.Size = 18
    $report.Cells.Item(1, 2).Font.Bold = $True
    $report.Cells.Item(1, 3) = 'Value'
    $report.Cells.Item(1, 3).Font.Size = 18
    $report.Cells.Item(1, 3).Font.Bold = $True
    $report.Range('A1:C1').Borders.Weight = -4138
    $row = 2

    foreach ($resource in $parsedContent)
    {
        $beginRow = $row
        foreach ($property in $resource.Keys)
        {
            if ($property -ne 'ResourceName' -and $property -ne 'Credential')
            {
                $report.Cells.Item($row, 1) = $resource.ResourceName
                $report.Cells.Item($row, 2) = $property
                try
                {
                    if ([System.String]::IsNullOrEmpty($resource.$property))
                    {
                        $report.Cells.Item($row, 3) = "`$null"
                    }
                    else
                    {
                        if ($resource.$property.GetType().Name -eq 'Object[]')
                        {
                            $value = $resource.$property | Out-String
                            $report.Cells.Item($row, 3) = $value
                        }
                        else
                        {
                            $value = ($resource.$property).ToString().Replace('$', '')
                            $value = $value.Replace('@', '')
                            $value = $value.Replace('(', '')
                            $value = $value.Replace(')', '')
                            $report.Cells.Item($row, 3) = $value
                        }
                    }

                    $report.Cells.Item($row, 3).HorizontalAlignment = -4131
                }
                catch
                {
                    New-M365DSCLogEntry -Message 'Error during conversion to Excel:' `
                        -Exception $_ `
                        -Source $($MyInvocation.MyCommand.Source) `
                        -TenantId $TenantId `
                        -Credential $Credential
                }

                if ($property -in @('Identity', 'Name', 'IsSingleInstance', 'DisplayName'))
                {
                    $OriginPropertyName = $report.Cells.Item($beginRow, 2).Text
                    $OriginPropertyValue = $report.Cells.Item($beginRow, 3).Text
                    $CurrentPropertyName = $report.Cells.Item($row, 2).Text
                    $CurrentPropertyValue = $report.Cells.Item($row, 3).Text

                    $report.Cells.Item($beginRow, 2) = $CurrentPropertyName
                    $report.Cells.Item($beginRow, 3) = $CurrentPropertyValue
                    $report.Cells.Item($row, 2) = $OriginPropertyName
                    $report.Cells.Item($row, 3) = $OriginPropertyValue

                    $report.Cells($beginRow, 1).Font.ColorIndex = 10
                    $report.Cells($beginRow, 2).Font.ColorIndex = 10
                    $report.Cells($beginRow, 3).Font.ColorIndex = 10
                    $report.Cells($beginRow, 1).Font.Bold = $true
                    $report.Cells($beginRow, 2).Font.Bold = $true
                    $report.Cells($beginRow, 3).Font.Bold = $true
                }
                $row++
            }
        }
        $rangeValue = "A$beginRow" + ':' + "C$row"
        $report.Range($rangeValue).Borders[8].Weight = -4138
    }
    $usedRange = $report.UsedRange
    $usedRange.EntireColumn.AutoFit() | Out-Null
    $workbook.SaveAs($OutputPath)
    $excel.Quit()
}

<#
.DESCRIPTION
    This function creates a new CSV file from the specified exported configuration

.FUNCTIONALITY
    Internal, Hidden
#>
function New-M365DSCConfigurationToCSV
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Array]
        $ParsedContent,

        [Parameter(Mandatory = $true)]
        [System.String]
        $OutputPath,

        [Parameter()]
        [System.String]
        $Delimiter = ','
    )

    $modelRow = @{'Component Name' = $null; Property = $null; Value = $null }
    $row = 0
    $csvOutput = @()

    foreach ($resource in $parsedContent)
    {
        $newRow = $modelRow.Clone()
        if ($row -gt 0)
        {
            Write-Verbose -Message 'add separator-line in CSV-file between resources'
            $newRow.'Component Name' = '======================'
            $csvOutput += [pscustomobject]$newRow
            $row++
        }
        $beginRow = $row
        foreach ($property in $resource.Keys)
        {
            $newRow = $modelRow.Clone()
            if ($property -ne 'ResourceName' -and $property -ne 'Credential')
            {
                $newRow.'Component Name' = $resource.ResourceName
                $newRow.Property = $property
                try
                {
                    if ([System.String]::IsNullOrEmpty($resource.$property))
                    {
                        $newRow.Value = "`$null"
                    }
                    else
                    {
                        if ($resource.$property.GetType().Name -eq 'Object[]')
                        {
                            $value = $resource.$property | Out-String
                            $newRow.Value = $value
                        }
                        else
                        {
                            $value = ($resource.$property).ToString() # .Replace('$', '')
                            $value = $value.Replace('@', '')
                            $value = $value.Replace('(', '')
                            $value = $value.Replace(')', '')
                            $newRow.Value = $value
                        }
                    }
                }
                catch
                {
                    New-M365DSCLogEntry -Message 'Error during conversion to CSV:' `
                        -Exception $_ `
                        -Source $($MyInvocation.MyCommand.Source) `
                        -TenantId $TenantId `
                        -Credential $Credential
                }

                if ($property -in @('Identity', 'Name', 'IsSingleInstance', 'DisplayName'))
                {
                    $OriginPropertyName   = $csvOutput[$beginRow].Property
                    $OriginPropertyValue  = $csvOutput[$beginRow].Value
                    $CurrentPropertyName  = $newRow.Property
                    $CurrentPropertyValue = $newRow.Value

                    $csvOutput[$beginRow].Property = $CurrentPropertyName
                    $csvOutput[$beginRow].Value = $CurrentPropertyValue
                    $newRow.Property = $OriginPropertyName
                    $newRow.Value = $OriginPropertyValue
                }
                $csvOutput += [pscustomobject]$newRow
                $row++
            }
        }
    }
    $csvOutput | Export-Csv -Path $OutputPath -Encoding UTF8 -Delimiter $Delimiter -NoTypeInformation
}

<#
.SYNOPSIS
    Generates a report file from an exported DSC configuration.

.DESCRIPTION
    Parses a DSC configuration file and renders a report in the requested output format.
    Supports Excel, HTML, JSON, Markdown, and CSV output types.

.PARAMETER Type
    Specifies the report output format.

.PARAMETER ConfigurationPath
    Specifies the source DSC configuration file path.

.PARAMETER OutputPath
    Specifies the destination report file path. A Markdown report that is split by resource is
    written to a folder instead of a file.

.PARAMETER IncludeAllInformation
    Specifies that the report carries every property the resource supports, set or not, with its
    attribute, data type, allowed values and description, and the permissions of the resource.
    Without it, a report carries the name, data type and value of every property the
    configuration sets. Only available when Type is Markdown.

.PARAMETER SplitByResource
    Specifies that every resource instance becomes its own document, in a folder per workload
    below OutputPath. Without it, the whole configuration lands in a single document. Only
    available when Type is Markdown.

.PARAMETER OrganizationName
    Specifies the tenant domain name that is replaced by a portable token in every value. Only
    available when Type is Markdown.

.PARAMETER TenantGuid
    Specifies the tenant identifier that is replaced by a portable token in every value. Only
    available when Type is Markdown.

.EXAMPLE
    PS> New-M365DSCReportFromConfiguration -Type 'HTML' -ConfigurationPath 'C:\DSC\ConfigName.ps1' -OutputPath 'C:\Dsc\M365Report.html'

.EXAMPLE
    PS> New-M365DSCReportFromConfiguration -Type 'Excel' -ConfigurationPath 'C:\DSC\ConfigName.ps1' -OutputPath 'C:\Dsc\M365Report.xlsx'

.EXAMPLE
    PS> New-M365DSCReportFromConfiguration -Type 'JSON' -ConfigurationPath 'C:\DSC\ConfigName.ps1' -OutputPath 'C:\Dsc\M365Report.json'

.FUNCTIONALITY
    Public
#>
function New-M365DSCReportFromConfiguration
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Excel', 'HTML', 'JSON', 'Markdown', 'CSV')]
        [System.String]
        $Type,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ConfigurationPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $OutputPath
    )

    dynamicparam # 'Delimiter' requires Type = 'CSV', the other parameters require Type = 'Markdown'
    {
        $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
        if ($Type -eq 'Markdown')
        {
            foreach ($markdownParam in @(
                    @{ Name = 'IncludeAllInformation'; Type = [Switch] }
                    @{ Name = 'SplitByResource'; Type = [Switch] }
                    @{ Name = 'OrganizationName'; Type = [System.String] }
                    @{ Name = 'TenantGuid'; Type = [System.String] }
                ))
            {
                $markdownAttr = [System.Management.Automation.ParameterAttribute]::new()
                $markdownAttr.Mandatory = $false
                $markdownCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
                $markdownCollection.Add($markdownAttr)
                $paramDictionary.Add($markdownParam.Name, [System.Management.Automation.RuntimeDefinedParameter]::New(
                        $markdownParam.Name, $markdownParam.Type, $markdownCollection))
            }
        }

        if ($Type -eq 'CSV')
        {
            $delimiterAttr = [System.Management.Automation.ParameterAttribute]::new()
            $delimiterAttr.Mandatory = $false
            $attributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
            $attributeCollection.Add($delimiterAttr)
            $delimiterParam = [System.Management.Automation.RuntimeDefinedParameter]::New('Delimiter', [System.String], $attributeCollection)
            $delimiterParam.Value = ';' # default value, comma makes a mess when importing a CSV-file in Excel
            $paramDictionary.Add('Delimiter', $delimiterParam)
            $PSBoundParameters.Add('Delimiter', $delimiterParam.Value)
        }
        return $paramDictionary
    }

    begin
    {
        if ($PSBoundParameters.ContainsKey('Delimiter'))
        {
            $Delimiter = $PSBoundParameters.Delimiter
        }

        $markdownParameters = @{ }
        foreach ($markdownParam in @('IncludeAllInformation', 'SplitByResource', 'OrganizationName', 'TenantGuid'))
        {
            if ($PSBoundParameters.ContainsKey($markdownParam))
            {
                $markdownParameters.$markdownParam = $PSBoundParameters.$markdownParam
            }
        }
    }
    process # required with DynamicParam
    {
        # Validate that the latest version of the module is installed.
        Test-M365DSCModuleValidity

        #Ensure the proper dependencies are installed in the current environment.
        Confirm-M365DSCDependencies

        #region Telemetry
        $data = [System.Collections.Generic.Dictionary[[System.String], [System.Object]]]::new()
        $data.Add('Event', 'Report')
        $data.Add('Type', $Type)
        Add-M365DSCTelemetryEvent -Data $data -Type 'NewReport'
        #endregion

        [Array] $parsedContent = Initialize-M365DSCReporting -ConfigurationPath $ConfigurationPath

        if ($null -ne $parsedContent)
        {
            switch ($Type)
            {
                'Excel'
                {
                    New-M365DSCConfigurationToExcel -ParsedContent $parsedContent -OutputPath $OutputPath
                }
                'HTML'
                {
                    $template = Get-Item $ConfigurationPath
                    $templateName = $template.Name.Split('.')[0]
                    New-M365DSCConfigurationToHTML -ParsedContent $parsedContent -OutputPath $OutputPath -TemplateName $templateName
                }
                'JSON'
                {
                    New-M365DSCConfigurationToJSON -ParsedContent $parsedContent -OutputPath $OutputPath
                }
                'Markdown'
                {
                    New-M365DSCConfigurationToMarkdown -ParsedContent $parsedContent -OutputPath $OutputPath @markdownParameters
                }
                'CSV'
                {
                    New-M365DSCConfigurationToCSV -ParsedContent $parsedContent -OutputPath $OutputPath -Delimiter $Delimiter
                }
            }
        }
        else
        {
            Write-Warning -Message 'Parsed content was null. No report was generated.'
        }
    }
}

<#
.SYNOPSIS
    Determines the preferred key property name for a CIM instance hashtable.

.DESCRIPTION
    Inspects known key candidates in priority order and returns the property name used as the instance key.

.PARAMETER CIMInstance
    Specifies the CIM instance hashtable to inspect.

.FUNCTIONALITY
    Internal

.OUTPUTS
    System.String
#>
function Get-M365DSCCIMInstanceKey
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $CIMInstance
    )

    $primaryKey = ''
    if ($CIMInstance.ContainsKey('IsSingleInstance'))
    {
        $primaryKey = ''
    }
    elseif ($CIMInstance.ContainsKey('DisplayName'))
    {
        $primaryKey = 'DisplayName'
    }
    elseif ($CIMInstance.ContainsKey('Identity'))
    {
        $primaryKey = 'Identity'
    }
    elseif ($CIMInstance.ContainsKey('Id'))
    {
        $primaryKey = 'Id'
    }
    elseif ($CIMInstance.ContainsKey('Name'))
    {
        $primaryKey = 'Name'
    }
    elseif ($CIMInstance.ContainsKey('Title'))
    {
        $primaryKey = 'Title'
    }
    elseif ($CIMInstance.ContainsKey('CdnType'))
    {
        $primaryKey = 'CdnType'
    }
    elseif ($CIMInstance.ContainsKey('Usage'))
    {
        $primaryKey = 'Usage'
    }
    elseif ($CIMInstance.ContainsKey('odataType'))
    {
        $primaryKey = 'odataType'
    }
    elseif ($CIMInstance.ContainsKey('dataType'))
    {
        $primaryKey = 'dataType'
    }
    elseif ($CIMInstance.ContainsKey('Dmn'))
    {
        $primaryKey = 'Dmn'
    }
    elseif ($CIMInstance.ContainsKey('EmergencyDialString'))
    {
        $primaryKey = 'EmergencyDialString'
    }
    else
    {
        $primaryKey = $CIMInstance.Keys[0]
    }

    return $primaryKey
}

<#
.SYNOPSIS
    Creates a delta report between two configuration sources.

.DESCRIPTION
    Compares source and destination configurations, evaluates drifted resources and properties, and renders a report in HTML or JSON format.
    Optional variable substitution support can be applied during comparison.

.PARAMETER Source
    Specifies the source configuration file path.

.PARAMETER Destination
    Specifies the destination configuration file path.

.PARAMETER OutputPath
    Specifies the destination report file path.

.PARAMETER DriftOnly
    Indicates that only drifted properties should be included.

.PARAMETER IsBlueprintAssessment
    Indicates that report generation is running as a blueprint assessment.

.PARAMETER HeaderFilePath
    Specifies a custom header file path for HTML output.

.PARAMETER Delta
    Specifies a precomputed delta structure to render.

.PARAMETER Type
    Specifies the report format.

.PARAMETER ExcludedProperties
    Specifies property names to exclude from comparison.

.PARAMETER ExcludedResources
    Specifies resource names to exclude from comparison.

.PARAMETER UseVariableSubstitution
    Indicates that variable substitution should be applied during comparison.

.PARAMETER SourceConfigurationDataPath
    Specifies the source configuration data file path used for substitution.

.PARAMETER DestinationConfigurationDataPath
    Specifies the destination configuration data file path used for substitution.

.PARAMETER ExcludedSubstitutionProperties
    Specifies property names excluded from variable substitution.

.EXAMPLE
    PS> New-M365DSCDeltaReport -Source 'C:\DSC\Source.ps1' -Destination 'C:\DSC\Destination.ps1' -OutputPath 'C:\DSC\DeltaReport.html'

.EXAMPLE
    PS> New-M365DSCDeltaReport -Source 'C:\DSC\Source.ps1' -Destination 'C:\DSC\Destination.ps1' -OutputPath 'C:\DSC\DeltaReport.html' -DriftOnly $true

.EXAMPLE
    PS> New-M365DSCDeltaReport -Source 'C:\DSC\Source.ps1' -Destination 'C:\DSC\Destination.ps1' -OutputPath 'C:\DSC\DeltaReport.html' -IsBlueprintAssessment $true

.EXAMPLE
    PS> New-M365DSCDeltaReport -Source 'C:\DSC\Source.ps1' -Destination 'C:\DSC\Destination.ps1' -OutputPath 'C:\DSC\DeltaReport.html' -HeaderFilePath 'C:\DSC\CustomHeader.html' `
        -SourceConfigurationDataPath 'C:\DSC\SourceConfigData.psd1' -DestinationConfigurationDataPath 'C:\DSC\DestinationConfigData.psd1' -ExcludedSubstitutionProperties @('TenantEnvironment')

.FUNCTIONALITY
    Public
#>
function New-M365DSCDeltaReport
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Source,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Destination,

        [Parameter()]
        [System.String]
        $OutputPath,

        [Parameter()]
        [System.Boolean]
        $DriftOnly = $false,

        [Parameter()]
        [System.Boolean]
        $IsBlueprintAssessment = $false,

        [Parameter()]
        [System.String]
        $HeaderFilePath,

        [Parameter()]
        [Array]
        $Delta,

        [Parameter()]
        [System.String]
        [ValidateSet('HTML', 'JSON')]
        $Type = 'HTML',

        [Parameter()]
        [Array]
        $ExcludedProperties,

        [Parameter()]
        [Array]
        $ExcludedResources,

        [Parameter(ParameterSetName = 'VariableSubstitution')]
        [Switch]
        $UseVariableSubstitution,

        [Parameter(ParameterSetName = 'VariableSubstitution')]
        [System.String]
        $SourceConfigurationDataPath,

        [Parameter(ParameterSetName = 'VariableSubstitution')]
        [System.String]
        $DestinationConfigurationDataPath,

        [Parameter(ParameterSetName = 'VariableSubstitution')]
        [System.String[]]
        $ExcludedSubstitutionProperties
    )

    # Validate that the latest version of the module is installed.
    Test-M365DSCModuleValidity

    if ((Test-Path -Path $Source) -eq $false)
    {
        Write-Error "Cannot find file specified in parameter Source: $Source. Please make sure the file exists!"
        return
    }

    if ((Test-Path -Path $Destination) -eq $false)
    {
        Write-Error "Cannot find file specified in parameter Destination: $Destination. Please make sure the file exists!"
        return
    }

    if ($OutputPath -and (Test-Path -Path $OutputPath) -eq $true)
    {
        Write-Warning "File specified in parameter OutputPath already exists and will be overwritten: $OutputPath"
        Write-Warning "Make sure you specify a file that does not exist if you don't want the file to be overwritten!"
    }

    if ($PSBoundParameters.ContainsKey('HeaderFilePath') -and -not [System.String]::IsNullOrEmpty($HeaderFilePath) -and `
        (Test-Path -Path $HeaderFilePath) -eq $false)
    {
        Write-Error "Cannot find file specified in parameter HeaderFilePath: $HeaderFilePath. Please make sure the file exists!"
        return
    }

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies
    Initialize-M365DSCDllLoader -ErrorAction Stop

    #region Telemetry
    $data = [System.Collections.Generic.Dictionary[[System.String], [System.Object]]]::new()
    $data.Add('Event', 'DeltaReport')
    Add-M365DSCTelemetryEvent -Data $data -Type 'CompareConfigurations'
    #endregion

    # Excluding authentication properties by default.
    $authParameters = @('Credential', 'ManagedIdentity', 'ApplicationId', 'TenantId', 'CertificatePath', 'CertificatePassword', 'CertificateThumbprint', 'ApplicationSecret')
    $ExcludedProperties += 'ResourceInstanceName'
    $ExcludedProperties = $ExcludedProperties + $authParameters | Select-Object -Unique

    if ($null -eq $Script:DscResourceInfo)
    {
        $Script:DscResourceInfo = Get-M365DSCResourceSchema
    }

    Write-Verbose -Message 'Obtaining Delta between the source and destination configurations'
    if (-not $Delta)
    {
        #region ConfigurationData variable substitution
        $effectiveSource = $Source
        $effectiveDestination = $Destination
        $tempSourcePath = $null
        $tempDestinationPath = $null

        if ($UseVariableSubstitution)
        {
            # Build a map of ConfigurationData paths: key = file path, value = config data path
            $configDataMap = @{}
            if (-not [System.String]::IsNullOrEmpty($SourceConfigurationDataPath))
            {
                $configDataMap[$Source] = $SourceConfigurationDataPath
            }
            if (-not [System.String]::IsNullOrEmpty($DestinationConfigurationDataPath))
            {
                $configDataMap[$Destination] = $DestinationConfigurationDataPath
            }

            # Auto-detect ConfigurationData.psd1 when no explicit path was provided
            foreach ($filePath in @($Source, $Destination))
            {
                if (-not $configDataMap.ContainsKey($filePath))
                {
                    $autoPath = Join-Path -Path (Split-Path -Path $filePath -Parent) -ChildPath 'ConfigurationData.psd1'
                    if (Test-Path -Path $autoPath)
                    {
                        $configDataMap[$filePath] = $autoPath
                    }
                }
            }

            foreach ($filePath in @($Source, $Destination))
            {
                if (-not $configDataMap.ContainsKey($filePath))
                {
                    continue
                }

                $configDataFile = $configDataMap[$filePath]
                if (-not (Test-Path -Path $configDataFile))
                {
                    Write-Warning -Message "ConfigurationData file not found at '$configDataFile'. Skipping variable substitution for '$filePath'."
                    continue
                }

                Write-Verbose -Message "Importing ConfigurationData from '$configDataFile' for '$filePath'"
                $configData = Import-PowerShellDataFile -Path $configDataFile

                # Collect all string properties from NonNodeData
                $substitutions = @{}
                if ($null -ne $configData.NonNodeData)
                {
                    $nonNodeEntries = @()
                    if ($configData.NonNodeData -is [System.Array])
                    {
                        $nonNodeEntries = $configData.NonNodeData
                    }
                    else
                    {
                        $nonNodeEntries = @($configData.NonNodeData)
                    }

                    $ExcludedSubstitutionProperties += @('ApplicationId', 'ApplicationSecret', 'CertificatePath', 'CertificatePassword', 'CertificateThumbprint', 'Credential', 'ManagedIdentity', 'TenantId', 'TenantGuid')
                    $ExcludedSubstitutionProperties = $ExcludedSubstitutionProperties | Select-Object -Unique
                    foreach ($entry in $nonNodeEntries)
                    {
                        if ($entry -is [System.Collections.IDictionary])
                        {
                            foreach ($key in $entry.Keys)
                            {
                                if ($ExcludedSubstitutionProperties -contains $key)
                                {
                                    Write-Verbose -Message "  Skipping excluded property '$key'"
                                    continue
                                }

                                $value = $entry[$key]
                                if ($key -eq 'OrganizationName')
                                {
                                    $substitutions["`$OrganizationName"] = $value
                                    continue
                                }

                                if ($value -is [System.String] -and -not [System.String]::IsNullOrEmpty($value))
                                {
                                    $substitutions["`$ConfigurationData.NonNodeData.$key"] = $value
                                }
                            }
                        }
                    }
                }

                if ($substitutions.Count -eq 0)
                {
                    continue
                }

                $content = [System.IO.File]::ReadAllText($filePath)
                $hasSubstitutions = $false
                foreach ($varName in $substitutions.Keys)
                {
                    if ($content.Contains($varName))
                    {
                        Write-Verbose -Message "  Replacing $varName with '$($substitutions[$varName])'"
                        $content = $content.Replace('$(' + $varName.TrimStart('`$') + ')', $substitutions[$varName])
                        $content = $content.Replace('$(' + $varName + ')', $substitutions[$varName])
                        $content = $content.Replace($varName, $substitutions[$varName])
                        $hasSubstitutions = $true
                    }
                }

                if ($hasSubstitutions)
                {
                    $tempPath = [System.IO.Path]::GetTempFileName() + '.ps1'
                    [System.IO.File]::WriteAllText($tempPath, $content)

                    if ($filePath -eq $Source)
                    {
                        $effectiveSource = $tempPath
                        $tempSourcePath = $tempPath
                    }
                    else
                    {
                        $effectiveDestination = $tempPath
                        $tempDestinationPath = $tempPath
                    }
                }
            }
        }
        #endregion

        $desiredSplat = @{
            ConfigurationPath = $effectiveDestination
            IncludeComments   = $false
            DscResourceInfo   = $Script:DscResourceInfo
        }

        if ($IsBlueprintAssessment)
        {
            $desiredSplat.IncludeComments = $true
        }

        # Parse the blueprint file, pass to other comparison functions as object (including comments aka metadata)
        [Array]$desiredConfiguration = Initialize-M365DSCReporting @desiredSplat
        [Array]$sourceReporting = Initialize-M365DSCReporting -ConfigurationPath $effectiveSource

        # Clean up temp files if created
        foreach ($tempPath in @($tempSourcePath, $tempDestinationPath))
        {
            if ($null -ne $tempPath -and (Test-Path -Path $tempPath))
            {
                Remove-Item -Path $tempPath -Force
            }
        }

        # The comparison runs on the schema the module ships, and resolves resource keys from it.
        Initialize-M365DSCSchemaCache

        # PostProcessing callbacks are resource code, so they cannot come from the schema and are
        # collected here for the resources the configurations mention.
        $compareParameters = [System.Collections.Generic.Dictionary[System.String, Microsoft365DSC.Compare.ResourceCompareParameters]]::new()
        foreach ($resourceName in @($sourceReporting.ResourceName) + @($desiredConfiguration.ResourceName) | Select-Object -Unique)
        {
            if ([System.String]::IsNullOrEmpty($resourceName) -or $compareParameters.ContainsKey($resourceName))
            {
                continue
            }

            $schemaEntry = [Microsoft365DSC.Cache.CacheManager]::FilterLoadedCimClassesByName("MSFT_$resourceName")
            if ($null -eq $schemaEntry -or -not $schemaEntry['HasPostProcessing'])
            {
                continue
            }

            try
            {
                $customCompareParams = Get-M365DSCResourceComparisonParameters -ResourceName $resourceName
            }
            catch
            {
                Write-Warning -Message "Failed to retrieve custom comparison parameters for $resourceName`: $_. Using default comparison."
                continue
            }

            if ($null -eq $customCompareParams -or $customCompareParams.Count -eq 0)
            {
                continue
            }

            $parameters = [Microsoft365DSC.Compare.ResourceCompareParameters]::new()
            $parameters.ExcludedProperties = [System.String[]] $customCompareParams.ExcludedProperties
            $parameters.IncludedProperties = [System.String[]] $customCompareParams.IncludedProperties
            $parameters.PostProcessing = $customCompareParams.PostProcessing

            $existingArgs = @()
            if ($null -ne $customCompareParams.PostProcessingArgs)
            {
                $existingArgs = @($customCompareParams.PostProcessingArgs)
            }

            $parameters.PostProcessingArgs = [System.Object[]] ($existingArgs + @{ IsReport = $true })
            $compareParameters.Add($resourceName, $parameters)
        }

        [Array]$Delta = [Microsoft365DSC.Compare.ConfigurationComparer]::Compare(
            $sourceReporting,
            $desiredConfiguration,
            [Microsoft365DSC.Cache.CacheManager]::Schema,
            $ExcludedProperties,
            $ExcludedResources,
            $compareParameters) | ForEach-Object -Process { $_.ToHashtable() }
    }

    if ($Type -eq 'HTML')
    {
        $reportSB = [System.Text.StringBuilder]::new()
        $ReportTitle = 'Microsoft365DSC - Delta Report'
        $headerTitle = 'Delta Report'
        if ($IsBlueprintAssessment)
        {
            $ReportTitle = 'Microsoft365DSC - Blueprint Assessment Report'
            $headerTitle = 'Blueprint Assessment Report'
        }
        [void]$reportSB.AppendLine("<html><head><meta charset='utf-8'><title>$ReportTitle</title>")
        [void]$reportSB.AppendLine($Script:ReportCSS)
        [void]$reportSB.AppendLine("</head><body><div class='report-container'>")

        #region Custom Header
        if (-not [System.String]::IsNullOrEmpty($HeaderFilePath))
        {
            try
            {
                $headerContent = Get-Content $HeaderFilePath
                [void]$reportSB.AppendLine($headerContent)
            }
            catch
            {
                New-M365DSCLogEntry -Message 'Error while reading DSC configuration:' `
                    -Exception $_ `
                    -Source $($MyInvocation.MyCommand.Source) `
                    -TenantId $TenantId `
                    -Credential $Credential
            }
        }
        #endregion

        [void]$reportSB.AppendLine("<h1>$headerTitle</h1>")
        [void]$reportSB.AppendLine("<div class='logo-container'>")
        [void]$reportSB.AppendLine("<img src='" + (Get-IconPath -ResourceName 'Promo') + "' alt='Microsoft365DSC Slogan' width='500'  />")
        [void]$ReportSB.AppendLine('</div>')
        if (-not $IsBlueprintAssessment)
        {
            [void]$reportSB.AppendLine("<div class='comparison-text'>")
            [void]$reportSB.AppendLine('<p><strong>Comparison between the following configurations:</strong></p>')
            [void]$reportSB.AppendLine('<ul>')
            [void]$reportSB.AppendLine("<li><strong>Source: </strong>$Source</li>")
            [void]$reportSB.AppendLine("<li><strong>Destination: </strong>$Destination</li>")
            [void]$reportSB.AppendLine('</ul>')
            [void]$reportSB.AppendLine("<p>Report generated on: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>")
            [void]$reportSB.AppendLine('</div>')
        }

        [array]$resourcesMissingInSource = $Delta | Where-Object -FilterScript { $_.Properties.ParameterName -eq '_IsInConfiguration_' -and `
                $_.Properties.ValueInSource -eq 'Absent' }
        [array]$resourcesMissingInDestination = $Delta | Where-Object -FilterScript { $_.Properties.ParameterName -eq '_IsInConfiguration_' -and `
                $_.Properties.ValueInDestination -eq 'Absent' }
        [array]$resourcesInDrift = $Delta | Where-Object -FilterScript { $_.Properties.ParameterName -ne '_IsInConfiguration_' }

        if ($resourcesMissingInSource.Count -eq 0 -and $resourcesMissingInDestination.Count -eq 0 -and `
                $resourcesInDrift.Count -eq 0)
        {
            [void]$reportSB.AppendLine('<p class="no-discrepancies"><strong>No discrepancies have been found!</strong></p>')
        }
        elseif (-not $DriftOnly)
        {
            [void]$reportSB.AppendLine('<div class="toc">')
            [void]$reportSB.AppendLine('<h2>Table of Contents</h2>')
            [void]$reportSB.AppendLine('<ul>')
            if ($resourcesMissingInSource.Count -gt 0)
            {
                [void]$reportSB.AppendLine("<li><a href='#Source'>Resources Missing in the Source</a>")
                [void]$reportSB.AppendLine(" <strong>(</strong>$($resourcesMissingInSource.Count)<strong>)</strong></li>")
            }
            if ($resourcesMissingInDestination.Count -gt 0)
            {
                [void]$reportSB.AppendLine("<li><a href='#Destination'>Resources Missing in the Destination</a>")
                [void]$reportSB.AppendLine(" <strong>(</strong>$($resourcesMissingInDestination.Count)<strong>)</strong></li>")
            }
            if ($resourcesInDrift.Count -gt 0)
            {
                $groupedResourcesCount = $resourcesInDrift | Group-Object -Property KeyValue -NoElement | Measure-Object | Select-Object -ExpandProperty Count
                [void]$reportSB.AppendLine("<li><a href='#Drift'>Resources Configured Differently</a>")
                [void]$reportSB.AppendLine(" <strong>(</strong>$($groupedResourcesCount)<strong>)</strong></li>")
            }
            [void]$reportSB.AppendLine('</ul></div>')
        }

        if ($resourcesMissingInSource.Count -gt 0 -and -not $DriftOnly)
        {
            [void]$reportSB.AppendLine('<br /><hr /><br />')
            [void]$reportSB.AppendLine("<a id='Source'></a><h2>Resources missing in the source</h2>")

            $workloadSection = New-M365DSCWorkloadSection -Resources $resourcesMissingInSource -ResourceRenderer {
                param($resource)
                $sb = [System.Text.StringBuilder]::new()
                [void]$sb.AppendLine("<table class='resource-table'>")
                [void]$sb.AppendLine('<tr>')
                [void]$sb.AppendLine("<td class='resource-header'>")
                [void]$sb.AppendLine("<h3>$($resource.ResourceName) - $($resource.Key) = $($resource.KeyValue)</h3>")
                [void]$sb.AppendLine('</td>')
                [void]$sb.AppendLine('</tr>')
                $presence = $resource.Properties | Select-Object -First 1
                if ($null -ne $presence._Metadata_Level)
                {
                    $emoticon = switch ($presence._Metadata_Level)
                    {
                        'L1' { '&#x1F7E5;' }
                        'L2' { '&#x1F7E8;' }
                        'L3' { '&#x1F7E6;' }
                    }
                    [void]$sb.AppendLine("<tr><td><span class='emoticon'>$emoticon</span> $($presence._Metadata_Info)</td></tr>")
                }
                [void]$sb.AppendLine('</table>')
                return $sb.ToString()
            }
            [void]$reportSB.Append($workloadSection)
        }

        if ($resourcesMissingInDestination.Count -gt 0 -and -not $DriftOnly)
        {
            [void]$reportSB.AppendLine('<br /><hr /><br />')
            [void]$reportSB.AppendLine("<a id='Destination'></a><h2>Resources missing in the destination</h2>")

            $workloadSection = New-M365DSCWorkloadSection -Resources $resourcesMissingInDestination -ResourceRenderer {
                param($resource)
                $sb = [System.Text.StringBuilder]::new()
                [void]$sb.AppendLine("<table class='resource-table'>")
                [void]$sb.AppendLine('<tr>')
                [void]$sb.AppendLine("<td class='resource-header'>")
                [void]$sb.AppendLine("<h3>$($resource.ResourceName) - $($resource.Key) = $($resource.KeyValue)</h3>")
                [void]$sb.AppendLine('</td>')
                [void]$sb.AppendLine('</tr>')
                [void]$sb.AppendLine('</table>')
                return $sb.ToString()
            }
            [void]$reportSB.Append($workloadSection)
        }

        if ($resourcesInDrift.Count -gt 0)
        {
            # Combine resources instances together to make sure multiple drifts within the same resource don't appear as separate entries
            $combinedResourcesInDrift = [System.Collections.Generic.LinkedList[System.Object]]::new()
            $nodesByInstance = [System.Collections.Generic.Dictionary[System.String, System.Collections.Generic.LinkedListNode[System.Object]]]::new([System.StringComparer]::OrdinalIgnoreCase)
            foreach ($resource in $resourcesInDrift)
            {
                $instanceKey = "$($resource.ResourceName)|$($resource.ResourceInstanceName)"
                $existingNode = $null
                if ($nodesByInstance.TryGetValue($instanceKey, [ref] $existingNode))
                {
                    $existingInstance = $existingNode.Value
                    $combinedResourcesInDrift.Remove($existingNode)
                    $existingInstance.Properties += $resource.Properties
                    $nodesByInstance[$instanceKey] = $combinedResourcesInDrift.AddLast($existingInstance)
                }
                else
                {
                    $nodesByInstance[$instanceKey] = $combinedResourcesInDrift.AddLast($resource)
                }
            }
            $resourcesInDrift = @($combinedResourcesInDrift)

            [void]$reportSB.AppendLine('<br /><hr /><br />')
            [void]$reportSB.AppendLine("<a id='Drift'></a><h2>Resources with differences</h2>")

            $SourceLabel = 'Source Value'
            $DestinationLabel = 'Destination Value'
            if ($IsBlueprintAssessment)
            {
                $SourceLabel = "Tenant's Current Value"
                $DestinationLabel = "Blueprint's Value"
            }

            $workloadSection = New-M365DSCWorkloadSection -Resources $resourcesInDrift -ResourceRenderer {
                param($resource)
                $sb = [System.Text.StringBuilder]::new()
                [void]$sb.AppendLine("<table class='drift-table'>")
                [void]$sb.AppendLine('<tr>')
                [void]$sb.AppendLine("<td class='drift-header' colspan='3'>")
                [void]$sb.AppendLine("<h3>$($resource.ResourceName) - $($resource.ResourceInstanceName)</h3>")
                [void]$sb.AppendLine('</td></tr>')
                [void]$sb.AppendLine('<tr>')
                [void]$sb.AppendLine("<td class='drift-subheader'><strong>Property</strong></td>")
                [void]$sb.AppendLine("<td class='drift-subheader'><strong>$SourceLabel</strong></td>")
                [void]$sb.AppendLine("<td class='drift-subheader'><strong>$DestinationLabel</strong></td>")
                [void]$sb.AppendLine('</tr>')

                foreach ($drift in $resource.Properties)
                {
                    if ($drift.ParameterName -notlike '_metadata_*')
                    {
                        $cellStyle = ''
                        $emoticon = ''
                        if ($drift._Metadata_Level -eq 'L1')
                        {
                            $cellStyle = 'level-L1'
                            $emoticon = '&#x1F7E5;'
                        }
                        elseif ($drift._Metadata_Level -eq 'L2')
                        {
                            $cellStyle = 'level-L2'
                            $emoticon = '&#x1F7E8;'
                        }
                        elseif ($drift._Metadata_Level -eq 'L3')
                        {
                            $cellStyle = 'level-L3'
                            $emoticon = '&#x1F7E6;'
                        }

                        $additionalAttribute = ''
                        if ($drift.ContainsKey('DeltaValue'))
                        {
                            $additionalAttribute = 'rowspan="2"'
                        }
                        [void]$sb.AppendLine('<tr>')
                        [void]$sb.AppendLine("<td class='property-name' $additionalAttribute>")
                        [void]$sb.AppendLine("$($drift.ParameterName)</td>")
                        [void]$sb.AppendLine("<td class='value-cell $cellStyle'>")
                        [void]$sb.AppendLine("$($drift.ValueInSource)</td>")
                        [void]$sb.AppendLine("<td class='value-cell'>")
                        [void]$sb.AppendLine("$($drift.ValueInDestination)</td>")
                        [void]$sb.AppendLine('</tr>')

                        if ($null -ne $drift._Metadata_Level)
                        {
                            [void]$sb.AppendLine("<tr><td colspan='3'><span class='emoticon'>$emoticon</span> $($drift._Metadata_Info)</td></tr>")
                        }

                        if ($drift.ContainsKey('DeltaValue') -and $null -ne $drift.DeltaValue)
                        {
                            [System.String[]]$deltaValues = $drift.DeltaValue.Split("; ")
                            [System.String[]]$destinationValues = $deltaValues -like "*<=*" | Foreach-Object { $_.Replace('<= ', '') }
                            [System.String[]]$sourceValues = $deltaValues -like "*=>*" | Foreach-Object { $_.Replace('=> ', '') }
                            [void]$sb.AppendLine('<tr>')
                            [void]$sb.AppendLine("<td class='value-cell'>")
                            if ($sourceValues.Count -gt 0)
                            {
                                [void]$sb.AppendLine("<strong>Delta:</strong><ul><li>$($sourceValues -join '</li><li>')</li></ul>")
                            }
                            [void]$sb.AppendLine("</td>")
                            [void]$sb.AppendLine("<td class='value-cell'>")
                            if ($destinationValues.Count -gt 0)
                            {
                                [void]$sb.AppendLine("<strong>Delta:</strong><ul><li>$($destinationValues -join '</li><li>')</li></ul>")
                            }
                            [void]$sb.AppendLine("</td>")
                            [void]$sb.AppendLine('</tr>')
                        }
                    }
                }
                [void]$sb.AppendLine('</table><hr/>')
                return $sb.ToString()
            }
            [void]$reportSB.Append($workloadSection)
        }
        [void]$reportSB.AppendLine('</div></body></html>')
        if (-not [System.String]::IsNullOrEmpty($OutputPath))
        {
            $reportSB.ToString() | Out-File $OutputPath
        }
        else
        {
            return $reportSB.ToString()
        }
    }
    elseif ($Type -eq 'JSON')
    {
        if (-not [System.String]::IsNullOrEmpty($OutputPath))
        {
            ConvertTo-Json $Delta -Depth 25 | Out-File $OutputPath
        }
        else
        {
            return (ConvertTo-Json $Delta -Depth 25)
        }
    }
}

<#
.DESCRIPTION
    This function prepares the configuration for further parsing of the data

.FUNCTIONALITY
    Internal, Hidden
#>
function Initialize-M365DSCReporting
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ConfigurationPath,

        [Parameter()]
        [Switch]
        $IncludeComments,

        [Parameter()]
        [System.Object[]]
        $DscResourceInfo
    )

    if ((Test-Path -Path $ConfigurationPath) -eq $false)
    {
        Write-Error "Cannot find file specified in parameter Source: $ConfigurationPath. Please make sure the file exists!"
        return
    }

    Write-Verbose -Message "Loading file '$ConfigurationPath'"

    $fileContent = [System.IO.File]::ReadAllText($ConfigurationPath)
    try
    {
        $startPosition = $fileContent.IndexOf(' -ModuleVersion')
        if ($startPosition -gt 0)
        {
            $endPosition = $fileContent.IndexOf("`n", $startPosition)
            $fileContent = $fileContent.Remove($startPosition, $endPosition - $startPosition)
        }
    }
    catch
    {
        Write-Warning -Message "Error trying to remove Module Version: $($_.Exception | Out-String)"
    }

    $params = @{
        Content = $fileContent
    }

    if ($IncludeComments)
    {
        $params.Add('IncludeComments', $true)
    }

    if ($PSBoundParameters.ContainsKey('DscResourceInfo'))
    {
        $params.Add('DscResourceInfo', $DscResourceInfo)
    }
    $parsedContent = ConvertTo-DSCObject @params

    if ($null -eq $parsedContent)
    {
        Write-Warning -Message "No configuration found in $ConfigurationPath. Either the configuration was empty or the file was not a valid DSC configuration."
    }

    return $parsedContent
}

<#
.DESCRIPTION
    This function recursively converts a PowerShell object into an HTML list,
    flattening nested properties.

.FUNCTIONALITY
    Internal, Hidden
#>
function Convert-ObjectToHtmlList
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $InputObject,

        [Parameter()]
        [System.String]
        $ParentName = '',

        [Parameter()]
        [switch]
        $NoIndent
    )

    $output = ''
    if ($InputObject -is [array])
    {
        if (-not $NoIndent)
        {
            $output += '<ul>'
        }
        for ($i = 0; $i -lt $InputObject.Count; $i++)
        {
            $item = $InputObject[$i]
            $itemName = "$ParentName[$i]"
            if ($item -is [hashtable])
            {
                $output += Convert-ObjectToHtmlList -InputObject $item -ParentName $itemName -NoIndent
                $output += '<hr/>'
            }
            else
            {
                $output += "<li><strong>$($itemName):</strong> $($item | Out-String)</li>"
            }
        }
        $output = $output.TrimEnd('<hr/>')
        if (-not $NoIndent)
        {
            $output += '</ul>'
        }
    }
    elseif ($InputObject -is [hashtable])
    {
        if (-not $NoIndent)
        {
            $output += '<ul>'
        }
        foreach ($key in ($InputObject.Keys | Sort-Object))
        {
            if ($key -ne 'CIMInstance')
            {
                $value = $InputObject.$key
                $childName = if ([System.String]::IsNullOrEmpty($ParentName))
                {
                    $key
                }
                else
                {
                    "$ParentName.$key"
                }
                if ($value -is [hashtable] -or $value -is [array])
                {
                    $output += Convert-ObjectToHtmlList -InputObject $value -ParentName $childName -NoIndent
                }
                else
                {
                    $output += "<li><strong>$($childName):</strong> $($value | Out-String)</li>"
                }
            }
        }
        if (-not $NoIndent)
        {
            $output += '</ul>'
        }
    }
    else
    {
        $output = "$(if ($NoIndent) { '' } else { '<ul>' })<li>$($InputObject | Out-String)</li>$(if ($NoIndent) { '' } else { '</ul>' })"
    }
    return $output
}

Export-ModuleMember -Function @(
    'New-M365DSCDeltaReport',
    'New-M365DSCReportFromConfiguration',
    'Get-M365DSCCIMInstanceKey'
)
