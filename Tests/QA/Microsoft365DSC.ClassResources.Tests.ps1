<#
    Guards the editor experience for class-based resources.

    A converted resource declares `class <Name> : M365DSCResourceBase`, and the base class lives in
    a different file. Parsed on its own - which is exactly what an editor does - the file cannot
    resolve the base and raises two errors:

        TypeNotFound                 Unable to find type [M365DSCResourceBase].
        DscResourceMissingTestMethod The DSC resource '<Name>' is missing a Test method ...

    Both are artefacts of isolated parsing; the built module is fine. Neither can be suppressed
    through editor settings, because they come from the PARSER rather than from PSScriptAnalyzer.
    The fix is a `using module` statement at the top of each resource file, which
    Build-Microsoft365DSC.ps1 does not carry into the shipped module.
#>

BeforeDiscovery {
    $resourcesPath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/Microsoft365DSC/DscResources'

    # Only converted resources. Script-based ones have no class and are not in scope.
    $classResourceFiles = @(
        Get-ChildItem -Path $resourcesPath -Filter 'MSFT_*.psm1' -File -Recurse |
            Where-Object { (Get-Content -Path $_.FullName -Raw) -match '(?m)^\s*\[DscResource\(\)\]' } |
            ForEach-Object {
                @{
                    ResourceName = $_.Directory.Name
                    FullName     = $_.FullName
                }
            }
    )

    # Invoke-DscResource drives the Local Configuration Manager over WinRM/CIM: it exists only on
    # Windows, and it refuses to run without elevation. Everywhere else the round-trip cannot be
    # attempted at all, so the check is skipped rather than reported as a failure.
    $onWindows = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform(
        [System.Runtime.InteropServices.OSPlatform]::Windows)

    $canInvokeDscResource = $false
    if ($onWindows)
    {
        $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $canInvokeDscResource = ([Security.Principal.WindowsPrincipal] $currentIdentity).IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator)
    }
}

BeforeAll {
    $script:ExpectedUsingStatement = 'using module ..\_Base\M365DSCResourceBase.psm1'
}

Describe 'Class-based resource sources' {

    # Pester fails discovery outright when -ForEach gets an empty collection, so this has to be
    # guarded until the first resource is converted. Remove the branch once conversion has started.
    if ($classResourceFiles.Count -eq 0)
    {
        It 'has no class-based resources yet' {
            Set-ItResult -Skipped -Because 'no resource under DscResources declares [DscResource()] yet'
        }

        return
    }

    Context 'When a resource has been converted to a class' -ForEach $classResourceFiles {

        It "'<ResourceName>' declares the base-class using statement" {
            $firstStatement = @(Get-Content -Path $FullName |
                    Where-Object { $_.Trim() -ne '' -and -not $_.Trim().StartsWith('#') } |
                    Select-Object -First 1)[0]

            $firstStatement.Trim() | Should -Be $script:ExpectedUsingStatement -Because (
                'without it, opening the file in an editor reports TypeNotFound on ' +
                '[M365DSCResourceBase] and a spurious missing Test method')
        }

        It "'<ResourceName>' parses with no errors" {
            $parseErrors = $null
            $null = [System.Management.Automation.Language.Parser]::ParseFile(
                $FullName, [ref] $null, [ref] $parseErrors)

            $messages = @($parseErrors | ForEach-Object {
                    "$($_.ErrorId) line $($_.Extent.StartLineNumber): $($_.Message)"
                }) -join '; '

            $parseErrors.Count | Should -Be 0 -Because (
                "a contributor opening this file must see no red underlines. Errors: $messages")
        }
    }
}

Describe 'Generated class modules' {
    BeforeAll {
        $script:classesPath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/Microsoft365DSC/Classes'
    }

    It 'does not ship the editor-only using statement' -Skip:(-not (Test-Path -Path (
                Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/Microsoft365DSC/Classes'))) {

        # The generated parts legitimately open with `using module .\_Shared.psm1` plus one
        # `using module .\_Types<NN>.psm1` per complex-type bucket they reference. Any OTHER using
        # statement - _Base above all - means the build started carrying source-only lines into the
        # shipped module. This mirrors the guard Build-Microsoft365DSC.ps1 applies to each part.
        $offenders = @(Get-ChildItem -Path $script:classesPath -Filter 'Part*.psm1' -File |
                Where-Object { (Get-Content -Path $_.FullName -Raw) -match '(?m)^\s*using module (?!\.\\(?:_Shared|_Types\d{2})\.psm1)' })

        $offenders.Name -join ', ' | Should -BeNullOrEmpty -Because (
            'Build-Microsoft365DSC.ps1 emits class extents only, and a file-level using statement is never inside one')
    }
}
