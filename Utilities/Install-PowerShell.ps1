[CmdletBinding()]
Param(
    [Parameter()]
    [Switch]
    $IsSDK
)

$PSVersion = "7.6.6"
$isWindowsPlatform = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform(
    [System.Runtime.InteropServices.OSPlatform]::Windows)

if ($IsSDK.IsPresent)
{
    Write-Output "Adding symbolic link from repository folder to module path"
    $Parameters = @{
        ItemType = "SymbolicLink"
        Force    = [Switch]$true
    }
    if ($isWindowsPlatform)
    {
        $Parameters.Add("Path", "C:\Program Files\WindowsPowerShell\Modules\Microsoft365DSC")
        $Parameters.Add("Target", "C:\DSC\Modules\Microsoft365DSC")
    }
    else
    {
        $PSVersion = [System.String]$PSVersionTable.PSVersion
        $SDK = dotnet --list-sdks
        if ($LASTEXITCODE -ne 0)
        {
            throw "Could not get .NET SDK version"
        }
        $SDKVersion = $SDK.Split(' ')[0].SubString(0, 4)
        $destinationPath = "/usr/share/powershell/.store/powershell.linux.x64/{0}/powershell.linux.x64/{1}/tools/net{2}/any/Modules/Microsoft365DSC" `
            -f $PSVersion, $PSVersion, $SDKVersion
        $Parameters.Add("Path", $destinationPath)
        $Parameters.Add("Target", "/DSC/Modules/Microsoft365DSC")
    }
    $null = New-Item @Parameters
}

if ($isWindowsPlatform)
{
    $ProgressPreference = 'SilentlyContinue'
    Write-Output "Installing PowerShell 7"
    Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v$PSVersion/PowerShell-$PSVersion-win-x64.zip" -OutFile "PowerShell-$PSVersion-win-x64.zip"
    Unblock-File "PowerShell-$PSVersion-win-x64.zip"
    $null = New-Item -ItemType Directory -Path "C:\Program Files\PowerShell\7" -Force
    Expand-Archive "PowerShell-$PSVersion-win-x64.zip" -DestinationPath "C:\Program Files\PowerShell\7"
    Remove-Item "PowerShell-$PSVersion-win-x64.zip" -Force
    [System.Environment]::SetEnvironmentVariable('PATH', "C:\Program Files\PowerShell\7;" + $env:PATH, [System.EnvironmentVariableTarget]::Machine)
    $env:PATH = "C:\Program Files\PowerShell\7;" + $env:PATH
}
