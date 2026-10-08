<#
    Quality checks over the files under Examples/Resources that need no DSC engine.

    The compile gate lives in Microsoft365DSC.Examples.Tests.ps1 and is skipped when the fast host
    is unavailable. These checks always run.

    Optional scoping, for verifying one batch of examples:

        Invoke-Pester -Container (New-PesterContainer `
            -Path ./Tests/QA/Microsoft365DSC.ExampleQuality.Tests.ps1 `
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
    $examplesRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../Examples/Resources'
    $hasExamples = Test-Path -Path $examplesRoot
}

Describe -Name 'Example quality' -Skip:(-not $hasExamples) {
    BeforeAll {
        $examplesRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../Examples/Resources' -Resolve
        $placeholderManifest = Join-Path -Path $PSScriptRoot -ChildPath 'ExamplePlaceholders.psd1' -Resolve

        $exampleFiles = [System.Collections.Generic.List[PSCustomObject]]::new()

        foreach ($exampleDirectory in (Get-ChildItem -Path $examplesRoot -Directory))
        {
            $friendlyName = $exampleDirectory.Name

            if ($Workload -and -not ($Workload | Where-Object -FilterScript { $friendlyName -like "$_*" }))
            {
                continue
            }

            if ($ResourceName -and -not ($ResourceName | Where-Object -FilterScript { $friendlyName -like $_ }))
            {
                continue
            }

            foreach ($exampleFile in (Get-ChildItem -Path $exampleDirectory.FullName -Filter '*.ps1'))
            {
                $exampleFiles.Add([PSCustomObject] @{
                        Resource = $friendlyName
                        Name     = $exampleFile.Name
                        FullName = $exampleFile.FullName
                    })
            }
        }

        # A placeholder is a lower kebab-case token in angle brackets, such as <client-secret>.
        $placeholderPattern = '<[a-z0-9]+(?:-[a-z0-9]+)+>'

        # Wording that reads as a project or test artefact rather than as customer data. 'integration'
        # is deliberately absent, because it is a legitimate word in a customer-facing system name and
        # the phrase 'integration test' is already caught by 'test'.
        $jargonPattern = '(?i)(m365dsc|microsoft365dsc|\bdsc\b|\btest\b|\btests\b|\btested\b|\btesting\b|\bexample\b|\bexamples\b|\bsample\b|\bdemo\b|placeholder|\bfake\b|\bfoo\b|\bbar\b|\bdummy\b)'

        # example.com and friends are RFC 2606 reserved and com.example.* is the documented bundle-id
        # convention, so neither is jargon.
        $legitimatePattern = '(?i)(example\.(com|org|net)|com\.example|@example\.|\.example\.com)'

        # DependsOn carries a resource instance label, which follows the <ResourceName>-Example
        # convention and is never renamed.
        $exemptProperties = @('DependsOn')

        $listedPlaceholders = (Import-PowerShellDataFile -Path $placeholderManifest).Placeholders

        $usedPlaceholders = @{}
        foreach ($exampleFile in $exampleFiles)
        {
            $content = [System.IO.File]::ReadAllText($exampleFile.FullName)
            foreach ($match in [regex]::Matches($content, $placeholderPattern))
            {
                if (-not $usedPlaceholders.ContainsKey($match.Value))
                {
                    $usedPlaceholders[$match.Value] = [System.Collections.Generic.List[System.String]]::new()
                }

                $usedPlaceholders[$match.Value].Add(('{0}/{1}' -f $exampleFile.Resource, $exampleFile.Name))
            }
        }
    }

    Context -Name 'Placeholder registry' {
        It 'Should register every placeholder used in an example' {
            $unregistered = @($usedPlaceholders.Keys |
                    Where-Object -FilterScript { $_ -notin $listedPlaceholders.Name } |
                    Sort-Object)

            $detail = ($unregistered |
                    ForEach-Object -Process { '{0} in {1}' -f $_, (($usedPlaceholders[$_] | Select-Object -Unique) -join ', ') }) -join "`n"

            $unregistered | Should -BeNullOrEmpty -Because "every placeholder needs an entry in ExamplePlaceholders.psd1:`n$detail"
        }

        It 'Should not list a placeholder that no example uses' {
            $unused = @($listedPlaceholders.Name |
                    Where-Object -FilterScript { -not $usedPlaceholders.ContainsKey($_) } |
                    Sort-Object)

            $unused | Should -BeNullOrEmpty -Because "these entries in ExamplePlaceholders.psd1 are no longer referenced: $($unused -join ', ')"
        }

        It 'Should give every registered placeholder a Sample' {
            $withoutSample = @($listedPlaceholders |
                    Where-Object -FilterScript { [System.String]::IsNullOrWhiteSpace($_.Sample) } |
                    ForEach-Object -Process { $_.Name } |
                    Sort-Object)

            $withoutSample | Should -BeNullOrEmpty -Because "a reader needs to see the shape of the value that was replaced: $($withoutSample -join ', ')"
        }
    }

    Context -Name 'Customer-facing wording' {
        It 'Should not contain project or test wording in any example value' {
            $offenders = [System.Collections.Generic.List[System.String]]::new()

            foreach ($exampleFile in $exampleFiles)
            {
                $number = 0
                foreach ($line in [System.IO.File]::ReadAllLines($exampleFile.FullName))
                {
                    $number++

                    if ($line -notmatch '^\s{8,}(?<Property>[A-Za-z_][A-Za-z0-9_]*)\s*=')
                    {
                        continue
                    }

                    if ($Matches.Property -in $exemptProperties)
                    {
                        continue
                    }

                    $value = $line -replace '^\s*[A-Za-z_][A-Za-z0-9_]*\s*=', ''
                    $value = $value -replace $legitimatePattern, ''

                    if ($value -notmatch $jargonPattern)
                    {
                        continue
                    }

                    $offenders.Add(('{0}/{1}:{2} {3}' -f $exampleFile.Resource, $exampleFile.Name, $number, $line.Trim()))
                }
            }

            $offenders | Should -BeNullOrEmpty -Because "example values are customer-facing documentation:`n$($offenders -join "`n")"
        }
    }

    Context -Name 'File shape' {
        It 'Should use a recognised example file name' {
            $offenders = @($exampleFiles |
                    Where-Object -FilterScript { $_.Name -notmatch '^\d+-[A-Za-z][A-Za-z0-9]*\.ps1$' } |
                    ForEach-Object -Process { '{0}/{1}' -f $_.Resource, $_.Name })

            $offenders | Should -BeNullOrEmpty -Because "an example file is named <Number>-<Scenario>.ps1 and anything else is skipped by the tooling: $($offenders -join ', ')"
        }

        It 'Should carry the drift marker only in an update example' {
            $offenders = [System.Collections.Generic.List[System.String]]::new()

            foreach ($exampleFile in $exampleFiles)
            {
                if ($exampleFile.Name -match '^2-[Uu]pdate\.ps1$')
                {
                    continue
                }

                $content = [System.IO.File]::ReadAllText($exampleFile.FullName)

                if ($content -match '#\s*Updated Property')
                {
                    $offenders.Add(('{0}/{1}' -f $exampleFile.Resource, $exampleFile.Name))
                }
            }

            $offenders | Should -BeNullOrEmpty -Because "the '# Updated Property' marker records drift and belongs in 2-Update.ps1 only: $($offenders -join ', ')"
        }
    }
}
