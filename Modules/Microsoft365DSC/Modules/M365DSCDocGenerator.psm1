if (-not ([System.Management.Automation.PSTypeName]'WikiExampleBlockType').Type)
{
    $typeDefinition = @'
    public enum WikiExampleBlockType
    {
        None,
        PSScriptInfo,
        Configuration,
        ExampleCommentHeader
    }
'@
    Add-Type -TypeDefinition $typeDefinition
}

<#
.Description
Get-DscResourceSchemaPropertyContent is used to generate the parameter content
for the wiki page.

.Parameter Property
The parameter definitions of a class, as returned in the Parameters property of
an entry in SchemaDefinition.json.

.Parameter UseMarkdown
If certain text should be output as markdown, for example values of the
hashtable property ValueMap.

.Example
$content = Get-DscResourceSchemaPropertyContent -Property @(
        [PSCustomObject] @{
            Name        = 'StringProperty'
            CIMType     = 'String'
            Option      = 'Key'
            Description = 'Any description'
            ValueMap    = $null
        }
    )

Returns the parameter content based on the passed array of parameter metadata.

.Functionality
Internal,Hidden
#>
function Get-DscResourceSchemaPropertyContent
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $Property,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $UseMarkdown
    )

    $stringArray = [System.String[]] @()

    $stringArray += '| Parameter | Attribute | DataType | Description | Allowed Values |'
    $stringArray += '| --- | --- | --- | --- | --- |'

    foreach ($currentProperty in $Property)
    {
        $dataType = $currentProperty.CIMType -replace 'MSFT_Credential', 'PSCredential'

        $propertyLine = "| **$($currentProperty.Name)** " + `
            "| $($currentProperty.Option) " + `
            "| $dataType |"

        if (-not [System.String]::IsNullOrEmpty($currentProperty.Description))
        {
            $description = $currentProperty.Description
            $description = $description.Replace('<', '&lt;').Replace('>', '&gt;')
            $propertyLine += ' ' + $description
        }

        $propertyLine += ' |'

        if (-not [System.String]::IsNullOrEmpty($currentProperty.ValueMap))
        {
            $valueMap = $currentProperty.ValueMap

            if ($UseMarkdown.IsPresent)
            {
                $valueMap = $valueMap | ForEach-Object -Process {
                    '`{0}`' -f $_
                }
            }

            $propertyLine += ' ' + ($valueMap -join ', ')
        }

        $propertyLine += ' |'

        $stringArray += $propertyLine
    }

    return (, $stringArray)
}

<#
.Description
The function will read the example PS1 file and convert the
help header into the description text for the example. It will
also surround the example configuration with code marks to
indication it is powershell code.

.Parameter ExamplePath
The path to the example file.

.Parameter ExampleNumber
The (order) number of the example.

.Example
Get-DscResourceWikiExampleContent -ExamplePath 'C:\repos\NetworkingDsc\Examples\Resources\DhcpClient\1-DhcpClient_EnableDHCP.ps1' -ExampleNumber 1

Reads the content of 'C:\repos\NetworkingDsc\Examples\Resources\DhcpClient\1-DhcpClient_EnableDHCP.ps1'
and converts it to markdown in preparation for being added to a resource wiki page.

.Functionality
Internal,Hidden
#>

function Get-DscResourceWikiExampleContent
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ExamplePath,

        [Parameter(Mandatory = $true)]
        [System.Int32]
        $ExampleNumber
    )

    $exampleContent = Get-Content -Path $ExamplePath

    # Use a string builder to assemble the example description and code
    $exampleDescriptionStringBuilder = New-Object -TypeName System.Text.StringBuilder
    $exampleCodeStringBuilder = New-Object -TypeName System.Text.StringBuilder

    <#
        Step through each line in the source example and determine
        the content and act accordingly:
        \<#PSScriptInfo...#\> - Drop block
        \#Requires - Drop Line
        \<#...#\> - Drop .EXAMPLE, .SYNOPSIS and .DESCRIPTION but include all other lines
        Configuration ... - Include entire block until EOF
    #>
    $blockType = [WikiExampleBlockType]::None

    foreach ($exampleLine in $exampleContent)
    {
        Write-Debug -Message ('Processing Line: {0}' -f $exampleLine)

        # Determine the behavior based on the current block type
        switch ($blockType.ToString())
        {
            'PSScriptInfo'
            {
                Write-Debug -Message 'PSScriptInfo Block Processing'

                # Exclude PSScriptInfo block from any output
                if ($exampleLine -eq '#>')
                {
                    Write-Debug -Message 'PSScriptInfo Block Ended'

                    # End of the PSScriptInfo block
                    $blockType = [WikiExampleBlockType]::None
                }
            }

            'Configuration'
            {
                Write-Debug -Message 'Configuration Block Processing'

                # Include all lines in the configuration block in the code output
                $null = $exampleCodeStringBuilder.AppendLine($exampleLine)
            }

            'ExampleCommentHeader'
            {
                Write-Debug -Message 'ExampleCommentHeader Block Processing'

                # Include all lines in Example Comment Header block except for headers
                $exampleLine = $exampleLine.TrimStart()

                if ($exampleLine -notin ('.SYNOPSIS', '.DESCRIPTION', '.EXAMPLE', '#>'))
                {
                    # Not a header so add this to the output
                    $null = $exampleDescriptionStringBuilder.AppendLine($exampleLine)
                }

                if ($exampleLine -eq '#>')
                {
                    Write-Debug -Message 'ExampleCommentHeader Block Ended'

                    # End of the Example Comment Header block
                    $blockType = [WikiExampleBlockType]::None
                }
            }

            default
            {
                Write-Debug -Message 'Not Currently Processing Block'

                # Check the current line
                if ($exampleLine.TrimStart() -eq '<#PSScriptInfo')
                {
                    Write-Debug -Message 'PSScriptInfo Block Started'

                    $blockType = [WikiExampleBlockType]::PSScriptInfo
                }
                elseif ($exampleLine -match 'Configuration')
                {
                    Write-Debug -Message 'Configuration Block Started'

                    $null = $exampleCodeStringBuilder.AppendLine($exampleLine)
                    $blockType = [WikiExampleBlockType]::Configuration
                }
                elseif ($exampleLine.TrimStart() -eq '<#')
                {
                    Write-Debug -Message 'ExampleCommentHeader Block Started'

                    $blockType = [WikiExampleBlockType]::ExampleCommentHeader
                }
            }
        }
    }

    # Assemble the final output
    $null = $exampleStringBuilder = New-Object -TypeName System.Text.StringBuilder
    $null = $exampleStringBuilder.AppendLine("### Example $ExampleNumber")
    $null = $exampleStringBuilder.AppendLine()
    $null = $exampleStringBuilder.AppendLine($exampleDescriptionStringBuilder)
    $null = $exampleStringBuilder.AppendLine('```powershell')
    $null = $exampleStringBuilder.Append($exampleCodeStringBuilder)
    $null = $exampleStringBuilder.Append('```')

    # ALways return CRLF as line endings to work cross platform.
    return ($exampleStringBuilder.ToString() -replace '\r?\n', "`r`n")
}

<#
.Description
Get-M365DSCSchemaDefinition reads SchemaDefinition.json and returns a hashtable
that maps the name of every resource and complex type to its schema entry.

.Parameter SourcePath
The path to the root of the DSC resource module, where SchemaDefinition.json is
located.

.Example
$schema = Get-M365DSCSchemaDefinition -SourcePath C:\repos\Microsoft365DSC\Modules\Microsoft365DSC

This example reads the schema of every class in the module.

.Functionality
Internal,Hidden
#>
function Get-M365DSCSchemaDefinition
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SourcePath
    )

    $schemaPath = Join-Path -Path $SourcePath -ChildPath 'SchemaDefinition.json'

    if ((Test-Path -Path $schemaPath) -eq $false)
    {
        throw "Schema definition '$schemaPath' not found. Build the module before generating the documentation."
    }

    $schema = @{}

    foreach ($class in (Get-Content -Path $schemaPath -Raw | ConvertFrom-Json))
    {
        $schema[$class.ClassName] = $class
    }

    return $schema
}

<#
.DESCRIPTION
    Get-DscResourceEmbeddedClass returns the schema of every complex type a class
    embeds, including the ones that are only reachable through another complex type.

.PARAMETER ClassName
    The name of the class whose embedded complex types should be returned.

.PARAMETER Schema
    The hashtable of class schemas returned by Get-M365DSCSchemaDefinition.

.EXAMPLE
    PS> $embeddedClasses = Get-DscResourceEmbeddedClass -ClassName 'MSFT_AADGroup' -Schema $schema

This example returns the complex types embedded in the AADGroup resource.

.FUNCTIONALITY
    Internal,Hidden
#>
function Get-DscResourceEmbeddedClass
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ClassName,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Schema
    )

    $embeddedClasses = [System.Collections.Generic.List[Object]]::new()
    $visited = [System.Collections.Generic.HashSet[String]]::new()
    $pending = [System.Collections.Generic.Queue[String]]::new()

    $null = $visited.Add($ClassName)
    $pending.Enqueue($ClassName)

    while ($pending.Count -gt 0)
    {
        $currentClassName = $pending.Dequeue()

        foreach ($parameter in $Schema[$currentClassName].Parameters)
        {
            $embeddedName = $parameter.CIMType -replace '\[\]$'

            if ($embeddedName -notlike 'MSFT_*' -or $embeddedName -eq 'MSFT_Credential')
            {
                continue
            }

            if ($visited.Add($embeddedName) -eq $false)
            {
                continue
            }

            if ($Schema.ContainsKey($embeddedName) -eq $false)
            {
                Write-Warning -Message ("Complex type '{0}' of class '{1}' is missing from the schema definition." -f $embeddedName, $currentClassName)
                continue
            }

            $embeddedClasses.Add($Schema[$embeddedName])
            $pending.Enqueue($embeddedName)
        }
    }

    return $embeddedClasses.ToArray()
}

<#
.DESCRIPTION
    Get-ResourceExampleAsMarkdown gathers all examples for a resource and returns
    them as string build object in markdown format.

.PARAMETER Path
    The path to the source folder, the path will be recursively searched for *.ps1
    files. All found files will be assumed that they are examples and that
    documentation should be generated for them.

.EXAMPLE
    PS> $examplesMarkdown = Get-ResourceExampleAsMarkdown -Path 'c:\MyProject\source\Examples\Resources\MyResourceName'

    This example fetches all examples from the folder 'c:\MyProject\source\Examples\Resources\MyResourceName'
    and returns them as a single string in markdown format.

.FUNCTIONALITY
    Internal,Hidden
#>
function Get-ResourceExampleAsMarkdown
{
    [CmdletBinding()]
    [OutputType([System.Text.StringBuilder])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    $filePath = Join-Path -Path $Path -ChildPath '*.ps1'

    $exampleFiles = @(Get-ChildItem -Path $filePath -File -Recurse -ErrorAction 'SilentlyContinue')

    if ($exampleFiles.Count -gt 0)
    {
        $outputExampleMarkDown = New-Object -TypeName 'System.Text.StringBuilder'

        Write-Verbose -Message ('Found {0} examples.' -f $exampleFiles.Count)

        $null = $outputExampleMarkDown.AppendLine('## Examples')

        $exampleCount = 1

        foreach ($exampleFile in $exampleFiles)
        {
            $exampleContent = Get-DscResourceWikiExampleContent `
                -ExamplePath $exampleFile.FullName `
                -ExampleNumber ($exampleCount++)

            $null = $outputExampleMarkDown.AppendLine()
            $null = $outputExampleMarkDown.AppendLine($exampleContent)
        }
    }
    else
    {
        Write-Warning -Message 'No Example files found.'
    }

    return $outputExampleMarkDown
}

<#
.DESCRIPTION
    The New-DscClassResourceWikiPage cmdlet will review all of the class-based
    resources in a specified module directory and will output the Markdown files to
    the specified directory. These help files include details on the property types
    for each resource, as well as a text description and examples where they exist.

.PARAMETER OutputPath
    Where should the files be saved to.

.PARAMETER SourcePath
    The path to the root of the DSC resource module (where the PSD1 file is found,
    not the folder for and individual DSC resource).

.PARAMETER Force
    Overwrites any existing file when outputting the generated content.

.EXAMPLE
    PS> New-DscClassResourceWikiPage `
        -SourcePath C:\repos\MyResource\source `
        -OutputPath C:\repos\MyResource\output\WikiContent

    This example shows how to generate wiki documentation for a specific module.

.FUNCTIONALITY
    Internal,Hidden
#>
function New-DscClassResourceWikiPage
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $OutputPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SourcePath,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    $schema = Get-M365DSCSchemaDefinition -SourcePath $SourcePath

    $resourcesPath = Join-Path -Path $SourcePath -ChildPath 'DscResources'
    $resourceFolders = @(Get-ChildItem -Path $resourcesPath -Directory -Filter 'MSFT_*')

    Write-Verbose -Message ("Found {0} resources in path '{1}'." -f $resourceFolders.Count, $resourcesPath)

    foreach ($resourceFolder in $resourceFolders)
    {
        $dscResourceName = $resourceFolder.Name
        $resourceName = $dscResourceName -replace '^MSFT_'

        if ($schema.ContainsKey($dscResourceName) -eq $false)
        {
            Write-Warning -Message ("No schema definition found for '{0}', skipping." -f $resourceName)
            continue
        }

        $resourceSchema = $schema[$dscResourceName]

        [System.Array] $readmeFile = Get-ChildItem -Path $resourceFolder.FullName |
            Where-Object -FilterScript {
                $_.Name -like 'readme.md'
            }

        if ($readmeFile.Count -eq 1)
        {
            Write-Verbose -Message ("Generating wiki page for '{0}'." -f $resourceName)

            $output = New-Object -TypeName System.Text.StringBuilder

            $null = $output.AppendLine("# $resourceName")
            $null = $output.AppendLine('')
            $null = $output.AppendLine('## Parameters')
            $null = $output.AppendLine('')

            $propertyContent = Get-DscResourceSchemaPropertyContent -Property $resourceSchema.Parameters -UseMarkdown

            foreach ($line in $propertyContent)
            {
                $null = $output.AppendLine($line)
            }

            $embeddedSchemas = @(Get-DscResourceEmbeddedClass -ClassName $dscResourceName -Schema $schema)

            if ($embeddedSchemas.Count -gt 0)
            {
                $null = $output.AppendLine()
                $null = $output.AppendLine("## Embedded Instances")
            }

            foreach ($embeddedSchema in $embeddedSchemas)
            {
                $null = $output.AppendLine()
                $null = $output.AppendLine("### $($embeddedSchema.ClassName)")
                $null = $output.AppendLine('')
                $null = $output.AppendLine('#### Parameters')
                $null = $output.AppendLine('')

                $propertyContent = Get-DscResourceSchemaPropertyContent -Property $embeddedSchema.Parameters -UseMarkdown

                foreach ($line in $propertyContent)
                {
                    $null = $output.AppendLine($line)
                }
            }

            $descriptionContent = Get-Content -Path $readmeFile.FullName -Raw

            # Removing first two lines with resource name, which will else be added in the middle of the page
            $descriptionContent = $descriptionContent -replace "^\s*#\s+.+\r?\n\r?\n", ''
            $null = $output.AppendLine()
            $null = $output.AppendLine($descriptionContent)

            # Add required permissions information
            $settingsJson = Get-M365DSCResourceSetting -ResourceName $resourceName

            $permissionsContent = New-Object -TypeName System.Text.StringBuilder

            if ($null -ne $settingsJson)
            {
                $null = $permissionsContent.AppendLine('## Permissions')

                $workloads = @('exchange', 'purview')
                foreach ($workload in $workloads)
                {
                    if ($null -ne $settingsJson.permissions.$workload)
                    {
                        $workloadNameUpper = $workload.Substring(0, 1).ToUpper() + $workload.Substring(1, $workload.Length - 1)
                        $null = $permissionsContent.AppendLine()
                        $null = $permissionsContent.AppendLine("### $workloadNameUpper")
                        $null = $permissionsContent.AppendLine()
                        $null = $permissionsContent.AppendLine("To authenticate with Microsoft $workloadNameUpper, this resource requires the following permissions:")
                        $null = $permissionsContent.AppendLine()
                        $null = $permissionsContent.AppendLine('#### Roles')
                        $null = $permissionsContent.AppendLine()
                        $null = $permissionsContent.AppendLine('* **Read**')
                        $null = $permissionsContent.AppendLine("  * $($settingsJson.permissions.$workload.requiredroles.read -join ', ')")
                        $null = $permissionsContent.AppendLine('* **Update**')
                        $null = $permissionsContent.AppendLine("  * $($settingsJson.permissions.$workload.requiredroles.update -join ', ')")
                        $null = $permissionsContent.AppendLine()
                        $null = $permissionsContent.AppendLine('#### Role Groups')
                        $null = $permissionsContent.AppendLine()
                        $null = $permissionsContent.AppendLine('* **Read**')
                        if ($settingsJson.permissions.$workload.requiredrolegroups.read.Count -ne 0)
                        {
                            $roleGroups = $settingsJson.permissions.$workload.requiredrolegroups.read -join ', '
                        }
                        else
                        {
                            $roleGroups = 'None'
                        }
                        $null = $permissionsContent.AppendLine("  * $roleGroups")
                        $null = $permissionsContent.AppendLine('* **Update**')
                        if ($settingsJson.permissions.$workload.requiredrolegroups.update.Count -ne 0)
                        {
                            $roleGroups = $settingsJson.permissions.$workload.requiredrolegroups.update -join ', '
                        }
                        else
                        {
                            $roleGroups = 'None'
                        }
                        $null = $permissionsContent.AppendLine("  * $roleGroups")
                    }
                }

                $otherApis = $settingsJson.permissions.psobject.properties.Name | Where-Object { $_ -notin $workloads }
                foreach ($otherApi in $otherApis)
                {
                    $otherApiUpper = $otherApi.Substring(0, 1).ToUpper() + $otherApi.Substring(1, $otherApi.Length - 1)
                    if ($null -ne $settingsJson.permissions.$otherapi)
                    {
                        $null = $permissionsContent.AppendLine()
                        $null = $permissionsContent.AppendLine("### $otherApiUpper")
                        $null = $permissionsContent.AppendLine()
                        $null = $permissionsContent.AppendLine("To authenticate with the $otherApiUpper API, this resource requires the following permissions:")
                        $null = $permissionsContent.AppendLine()
                        $null = $permissionsContent.AppendLine('#### Delegated permissions')
                        $null = $permissionsContent.AppendLine()
                        $null = $permissionsContent.AppendLine('* **Read**')

                        if ($settingsJson.permissions.$otherApi.delegated.read.Count -eq 0)
                        {
                            $delegatedRead = 'None'
                        }
                        else
                        {
                            $delegatedRead = $settingsJson.permissions.$otherApi.delegated.read.name -join ', '
                        }
                        $null = $permissionsContent.AppendLine("  * $delegatedRead")

                        $null = $permissionsContent.AppendLine()
                        $null = $permissionsContent.AppendLine('* **Update**')

                        if ($settingsJson.permissions.$otherApi.delegated.update.Count -eq 0)
                        {
                            $delegatedUpdate = 'None'
                        }
                        else
                        {
                            $delegatedUpdate = $settingsJson.permissions.$otherApi.delegated.update.name -join ', '
                        }
                        $null = $permissionsContent.AppendLine("  * $delegatedUpdate")

                        $null = $permissionsContent.AppendLine()
                        $null = $permissionsContent.AppendLine('#### Application permissions')
                        $null = $permissionsContent.AppendLine()
                        $null = $permissionsContent.AppendLine('* **Read**')

                        if ($settingsJson.permissions.$otherApi.application.read.Count -eq 0)
                        {
                            $applicationRead = 'None'
                        }
                        else
                        {
                            $applicationRead = $settingsJson.permissions.$otherApi.application.read.name -join ', '
                        }
                        $null = $permissionsContent.AppendLine("  * $applicationRead")

                        $null = $permissionsContent.AppendLine()
                        $null = $permissionsContent.AppendLine('* **Update**')

                        if ($settingsJson.permissions.$otherApi.application.update.Count -eq 0)
                        {
                            $applicationUpdate = 'None'
                        }
                        else
                        {
                            $applicationUpdate = $settingsJson.permissions.$otherApi.application.update.name -join ', '
                        }
                        $null = $permissionsContent.AppendLine("  * $applicationUpdate")
                    }
                }
            }
            else
            {
                $null = $permissionsContent.AppendLine()
                $null = $permissionsContent.AppendLine('No permission information available')
            }

            $null = $output.AppendLine($permissionsContent)

            # Adding examples
            $examplesPath = Join-Path -Path $SourcePath -ChildPath ('../../Examples/Resources/{0}' -f $resourceName)

            $examplesOutput = Get-ResourceExampleAsMarkdown -Path $examplesPath

            if ($examplesOutput.Length -gt 0)
            {
                $null = $output.Append($examplesOutput)
            }

            $outputFileName = "$resourceName.md"
            $savePath = Join-Path -Path $OutputPath -ChildPath $outputFileName

            Write-Verbose -Message ("Outputting wiki page to '{0}'." -f $savePath)

            $null = Out-File `
                -InputObject ($output.ToString() -replace '\r?\n', "`r`n") `
                -FilePath $savePath `
                -Encoding utf8 `
                -Force:$Force `
                -NoNewline
        }
        elseif ($readmeFile.Count -gt 1)
        {
            Write-Warning -Message ("{1} README.md description files found for '{0}', skipping." -f $resourceName, $readmeFile.Count)
        }
        else
        {
            Write-Warning -Message ("No README.md description file found for '{0}', skipping." -f $resourceName)
        }
    }
}

<#
.DESCRIPTION
    The Update-M365DSCResourceDocumentationPage cmdlet will review all of the
    class-based resources in a specified module directory and will output the
    Markdown files to the specified directory. These help files include details on
    the property types for each resource, as well as a text description and examples
    where they exist.

.PARAMETER SourcePath
    The path to the root of the DSC resource module (where the PSD1 file is found,
    not the folder for an individual DSC resource).

.PARAMETER Force
    Overwrites any existing file when outputting the generated content.

.EXAMPLE
    PS> Update-M365DSCResourceDocumentationPage `
        -SourcePath C:\repos\MyResource\source

    This example shows how to generate wiki documentation for a specific module.

.FUNCTIONALITY
    Internal
#>
function Update-M365DSCResourceDocumentationPage
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SourcePath,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    Write-Output -InputObject 'Generating Resource Documentation pages'

    $tempPath = Join-Path -Path $env:TEMP -ChildPath 'ResourceMarkdown'

    if ((Test-Path -Path $tempPath) -eq $false)
    {
        $null = New-Item -Path $tempPath -ItemType 'Directory'
    }

    $newDscClassResourceWikiPageParameters = @{
        OutputPath = $tempPath
        SourcePath = $SourcePath
        Force      = $Force
    }

    New-DscClassResourceWikiPage @newDscClassResourceWikiPageParameters

    $resourceDocsRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../docs/docs/resources'

    Write-Output -InputObject '  - Moving generated pages to the Docs folder'

    $files = Get-ChildItem -Path $tempPath
    foreach ($file in $files)
    {
        switch -Wildcard ($file.BaseName)
        {
            'AAD*'
            {
                $targetFolder = 'azure-ad'
            }
            'ADO*'
            {
                $targetFolder = 'azure-devops'
            }
            'Azure*'
            {
                $targetFolder = 'azure'
            }
            'Commerce*'
            {
                $targetFolder = 'commerce'
            }
            'Defender*'
            {
                $targetFolder = 'defender'
            }
            'EXO*'
            {
                $targetFolder = 'exchange'
            }
            'Fabric*'
            {
                $targetFolder = 'fabric'
            }
            'Intune*'
            {
                $targetFolder = 'intune'
            }
            'M365DSC*'
            {
                $targetFolder = 'general'
            }
            'O365*'
            {
                $targetFolder = 'office365'
            }
            'OD*'
            {
                $targetFolder = 'onedrive'
            }
            'Planner*'
            {
                $targetFolder = 'planner'
            }
            'PP*'
            {
                $targetFolder = 'power-platform'
            }
            'SC*'
            {
                $targetFolder = 'security-compliance'
            }
            'Sentinel*'
            {
                $targetFolder = 'sentinel'
            }
            'SH*'
            {
                $targetFolder = 'services-hub'
            }
            'SPO*'
            {
                $targetFolder = 'sharepoint'
            }
            'Teams*'
            {
                $targetFolder = 'teams'
            }
            'Viva*'
            {
                $targetFolder = 'viva'
            }
            default
            {
                throw "Unknown resource prefix for file '$($file.Name)'. Cannot determine target folder."
            }
        }
        $destinationFolder = Join-Path -Path $resourceDocsRoot -ChildPath $targetFolder
        if ((Test-Path -Path $destinationFolder) -eq $false)
        {
            $null = New-Item -Path $destinationFolder -ItemType 'Directory'
        }
        Move-Item -Path $file.FullName -Destination $destinationFolder -Force
    }

    Remove-Item -Path $tempPath -Force -Confirm:$false

    Write-Output -InputObject 'Generation of Resource Documentation pages completed'
}

Export-ModuleMember -Function @(
    'Update-M365DSCResourceDocumentationPage'
)
