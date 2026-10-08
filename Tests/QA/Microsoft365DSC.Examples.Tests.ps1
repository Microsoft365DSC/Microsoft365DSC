<#
    Optional scoping, for verifying one batch of examples without compiling all of them.
    Pester expands the <Placeholder> in a test name after filtering, so -FullNameFilter cannot
    select by resource; pass these through a container instead:

        Invoke-Pester -Container (New-PesterContainer `
            -Path ./Tests/QA/Microsoft365DSC.Examples.Tests.ps1 `
            -Data @{ Workload = 'AAD' })
#>
param
(
    [Parameter()]
    [System.String[]]
    $Workload,

    [Parameter()]
    [System.String[]]
    $ResourceName
)

BeforeDiscovery {
    $examplesPath = Join-Path -Path $PSScriptRoot -ChildPath '../../Examples'

    # If there are no Examples folder, exit.
    if (-not (Test-Path -Path $examplesPath))
    {
        return
    }

    $exampleFiles = @(Get-ChildItem -Path $examplesPath -Filter '*.ps1' -Recurse)

    if ($Workload)
    {
        $exampleFiles = @($exampleFiles | Where-Object -FilterScript {
                $folder = Split-Path -Path $_.Directory -Leaf
                $Workload | Where-Object -FilterScript { $folder -like "$_*" }
            })
    }

    if ($ResourceName)
    {
        $exampleFiles = @($exampleFiles | Where-Object -FilterScript {
                $folder = Split-Path -Path $_.Directory -Leaf
                $ResourceName | Where-Object -FilterScript { $folder -like $_ }
            })
    }

    $exampleToTest = @()

    foreach ($exampleFile in $exampleFiles)
    {
        $exampleToTest += @{
            ExampleFile            = $exampleFile
            ExampleDescriptiveName = Join-Path -Path (Split-Path $exampleFile.Directory -Leaf) -ChildPath (Split-Path $exampleFile -Leaf)
            ResourceName           = Split-Path $exampleFile.Directory -Leaf
        }
    }

    $resourcesPath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/Microsoft365DSC/DscResources'

    # If there are no Examples folder, exit.
    if (-not (Test-Path -Path $resourcesPath))
    {
        return
    }

    $resourceFolders = Get-ChildItem -Path $resourcesPath -Directory -Filter 'MSFT_*'

    if ($Workload)
    {
        $resourceFolders = @($resourceFolders | Where-Object -FilterScript {
                $friendlyName = $_.BaseName -replace '^MSFT_', ''
                $Workload | Where-Object -FilterScript { $friendlyName -like "$_*" }
            })
    }

    if ($ResourceName)
    {
        $resourceFolders = @($resourceFolders | Where-Object -FilterScript {
                $friendlyName = $_.BaseName -replace '^MSFT_', ''
                $ResourceName | Where-Object -FilterScript { $friendlyName -like $_ }
            })
    }

    $allResources = @()

    foreach ($resourceFolder in $resourceFolders)
    {
        $allResources += @{
            ResourceFolder = $resourceFolder.FullName
            ResourceName   = $resourceFolder.BaseName -replace '^MSFT_', ''
        }
    }

    $compilerModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/Microsoft365DSC/Modules/M365DSCConfigurationCompiler.psm1'
    Import-Module -Name $compilerModulePath -Force
    $fastCompileAvailable = Test-M365DSCFastCompileAvailable
}

Describe -Name 'Successfully compile examples' {
    BeforeAll {
        Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/Microsoft365DSC/Modules/M365DSCConfigurationCompiler.psm1') -Force

        function Get-PublishFileName
        {
            [CmdletBinding()]
            [OutputType([System.String])]
            param
            (
                [Parameter(Mandatory = $true)]
                [System.String]
                $Path
            )

            # Get the filename without extension.
            $filenameWithoutExtension = (Get-Item -Path $Path).BaseName

            return $filenameWithoutExtension -replace '^[0-9]+-'
        }

        function Get-ExampleConfigurationInfo
        {
            [CmdletBinding()]
            [OutputType([System.Object])]
            param
            (
                [Parameter(Mandatory = $true)]
                [System.String]
                $Path
            )

            # Masking the Configuration keyword before parsing to prevent resolution of
            # Import-DscResource for each of the resources
            $text = [System.IO.File]::ReadAllText($Path)
            $masked = [regex]::Replace($text, '(?i)\bConfiguration\b', 'C0nfiguration')
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($masked, [ref] $null, [ref] $null)

            $names = @()
            $configurationEnd = -1
            $commands = $ast.FindAll(
                { $args[0] -is [System.Management.Automation.Language.CommandAst] },
                $true)

            foreach ($command in $commands)
            {
                if ($command.GetCommandName() -ne 'C0nfiguration' -or $command.CommandElements.Count -lt 2)
                {
                    continue
                }

                $element = $command.CommandElements[1] -as [System.Management.Automation.Language.StringConstantExpressionAst]
                if ($null -ne $element)
                {
                    $names += $element.Value
                }

                if ($configurationEnd -lt 0)
                {
                    $configurationEnd = $command.Extent.EndOffset
                }
            }

            $parameters = @()
            $paramBlock = $null
            if ($configurationEnd -ge 0)
            {
                $body = $ast.FindAll(
                    { $args[0] -is [System.Management.Automation.Language.ScriptBlockExpressionAst] },
                    $true) |
                    Where-Object -FilterScript { $_.Extent.StartOffset -ge $configurationEnd } |
                    Sort-Object -Property { $_.Extent.StartOffset } |
                    Select-Object -First 1

                if ($null -ne $body)
                {
                    $paramBlock = $body.ScriptBlock.ParamBlock
                }
            }

            if ($null -ne $paramBlock)
            {
                foreach ($parameter in $paramBlock.Parameters)
                {
                    $attribute = $parameter.Attributes | Where-Object -FilterScript {
                        $_ -is [System.Management.Automation.Language.AttributeAst] -and $_.TypeName.Name -eq 'Parameter'
                    }

                    $isMandatory = $false
                    foreach ($named in @($attribute.NamedArguments))
                    {
                        if ($named.ArgumentName -eq 'Mandatory' -and $named.Argument.Extent.Text -ne '$false')
                        {
                            $isMandatory = $true
                        }
                    }

                    $parameters += [PSCustomObject] @{
                        Name        = $parameter.Name.VariablePath.UserPath
                        Type        = $parameter.StaticType
                        IsMandatory = $isMandatory
                    }
                }
            }

            return [PSCustomObject] @{
                Names      = $names
                Parameters = $parameters
            }
        }

        $mockPassword = ConvertTo-SecureString '&iPm%M5q3K$Hhq=wcEK' -AsPlainText -Force
        $script:MockCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @('tenantadmin@contoso.onmicrosoft.com', $mockPassword)

        $script:MockConfigurationData = @{
            AllNodes = @(
                @{
                    NodeName                    = 'localhost'
                    PsDscAllowPlainTextPassword = $true
                }
            )
        }
    }

    It 'Should have an M365DSCFastHost-capable engine available' {
        Test-M365DSCFastCompileAvailable | Should -BeTrue -Because 'the examples are compiled through Invoke-M365DSCConfigurationBuild, which needs M365DSC.PSDesiredStateConfiguration installed; without it every example falls back to the legacy pipeline at 30-90 seconds each'
    }

    It "Should compile example '<ExampleDescriptiveName>' correctly" -TestCases $exampleToTest -Skip:(-not $fastCompileAvailable) {
        {
            $info = Get-ExampleConfigurationInfo -Path $ExampleFile.FullName

            $candidateNames = @(
                'Example'
                    (Get-PublishFileName -Path $ExampleFile.FullName)
            )

            $configurationName = $info.Names | Where-Object -FilterScript { $_ -in $candidateNames } | Select-Object -First 1

            if (-not $configurationName)
            {
                throw ('The example ''{0}'' does not contain a configuration named ''{1}''.' -f $ExampleDescriptiveName, ($candidateNames -join "', or '"))
            }

            $exampleParameters = @{}

            foreach ($parameter in $info.Parameters)
            {
                if ($parameter.Name -eq 'PsDscRunAsCredential')
                {
                    continue
                }

                if ($parameter.Type -eq [System.Management.Automation.PSCredential])
                {
                    $exampleParameters.Add($parameter.Name, $script:MockCredential)
                }
                elseif ($parameter.IsMandatory)
                {
                    $exampleParameters.Add($parameter.Name, ('1' -as $parameter.Type))
                }
                elseif ($parameter.Name -eq 'TenantId')
                {
                    $exampleParameters.Add('TenantId', (New-Guid).ToString())
                }
            }

            $outputPath = Join-Path -Path $TestDrive -ChildPath ('{0}-{1}' -f $ResourceName, $ExampleFile.BaseName)

            $buildParameters = @{
                Path              = $ExampleFile.FullName
                ConfigurationName = $configurationName
                ConfigurationData = $script:MockConfigurationData
                OutputPath        = $outputPath
                Engine            = 'FastHost'
                ErrorAction       = 'Stop'
                WarningAction     = 'SilentlyContinue'
            }

            if ($exampleParameters.Count -gt 0)
            {
                $buildParameters.Add('Parameters', $exampleParameters)
            }

            $null = Invoke-M365DSCConfigurationBuild @buildParameters
        } | Should -Not -Throw
    }
}

Describe -Name 'Check examples for all resources' {
    BeforeAll {
        $examplesPath = Join-Path -Path $PSScriptRoot -ChildPath '../../Examples'

        # If there are no Examples folder, exit.
        if (-not (Test-Path -Path $examplesPath))
        {
            return
        }

        $exampleFiles = @(Get-ChildItem -Path $examplesPath -Filter '*.ps1' -Recurse)

        $exampleToTest = @()

        foreach ($exampleFile in $exampleFiles)
        {
            $exampleToTest += @{
                ExampleFile            = $exampleFile
                ExampleDescriptiveName = Join-Path -Path (Split-Path $exampleFile.Directory -Leaf) -ChildPath (Split-Path $exampleFile -Leaf)
                ResourceName           = Split-Path $exampleFile.Directory -Leaf
            }
        }
    }

    It "An example for '<ResourceName>' should exist" -TestCases $allResources {
        [Array]$res = $exampleToTest | Where-Object -FilterScript { $_.ResourceName -eq $ResourceName }
        $res.Count | Should -BeGreaterOrEqual 1
    }
}
