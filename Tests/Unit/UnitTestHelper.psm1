function New-M365DscUnitTestHelper
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $StubModule,

        [Parameter(Mandatory = $true, ParameterSetName = 'DscResource')]
        [String]
        $DscResource,

        [Parameter(Mandatory = $true, ParameterSetName = 'SubModule')]
        [String]
        $SubModulePath,

        [Parameter()]
        [Switch]
        $ExcludeInvokeHelper,

        [Parameter()]
        [System.String]
        $GenericStubModule
    )

    $repoRoot = Join-Path -Path $PSScriptRoot -ChildPath "../../" -Resolve
    $moduleRoot = Join-Path -Path $repoRoot -ChildPath "Modules/Microsoft365DSC"

    $mainModule = Join-Path -Path $moduleRoot -ChildPath "Microsoft365DSC.psd1"
    Remove-Module -Name "AzureAD" -Force -ErrorAction SilentlyContinue
    Import-Module -Name $mainModule -Global
    if ($null -ne ('Microsoft365DSC.Intune.SettingTemplateCache' -as [System.Type]))
    {
        [Microsoft365DSC.Intune.SettingTemplateCache]::Reset()
    }

    if ($PSBoundParameters.ContainsKey("SubModulePath") -eq $true)
    {
        $describeHeader = "Sub-module '$SubModulePath'"
        $moduleToLoad = Join-Path -Path $moduleRoot -ChildPath $SubModulePath
        $moduleName = (Get-Item -Path $moduleToLoad).BaseName
    }

    if ($PSBoundParameters.ContainsKey("DscResource") -eq $true)
    {
        $describeHeader = "DSC Resource '$DscResource'"
        $moduleName = Get-M365DSCResourceModuleName -ResourceName $DscResource

        if ([System.String]::IsNullOrEmpty($moduleName))
        {
            throw ("Could not resolve the class module for resource '$DscResource'. " +
                'Confirm the module was built (Utilities/Build-Microsoft365DSC.ps1) and that the ' +
                'resource is registered by one of the Classes/Part*.psm1 files.')
        }

        $moduleToLoad = $null
    }

    $Global:IsTestEnvironment = $true

    # Only the sub-module case has a file of its own to load; a DSC resource is already in memory.
    if (-not [System.String]::IsNullOrEmpty($moduleToLoad))
    {
        Import-Module -Name $moduleToLoad -Global -Force
    }

    $resourceImport = ''
    if (-not [System.String]::IsNullOrEmpty($moduleToLoad))
    {
        $resourceImport = "Import-Module -Name `"$moduleToLoad`""
    }

    $initScript = @"
            Remove-Module -Name "AzureAD" -Force -ErrorAction SilentlyContinue
            Import-Module -Name "$StubModule" -WarningAction SilentlyContinue -Global
            Import-Module -Name "$GenericStubModule" -WarningAction SilentlyContinue
            $resourceImport
"@

    return @{
        DescribeHeader = $describeHeader
        ModuleName = $moduleName
        CurrentStubModulePath = $StubModule
        InitializeScript = [ScriptBlock]::Create($initScript)
        RepoRoot = $repoRoot
        CleanupScript = [ScriptBlock]::Create(@"
            `$global:DSCMachineStatus = 0
"@)
    }
}
