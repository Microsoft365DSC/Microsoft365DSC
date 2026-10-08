[CmdletBinding()]
param(
    [Parameter()]
    [Switch]
    $IsSDK
)

$isWindowsPlatform = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform(
    [System.Runtime.InteropServices.OSPlatform]::Windows)

try
{
    Write-Output "Detecting current platform"
    $message = "Platform detected: "
    if ($isWindowsPlatform)
    {
        $message += "Windows"
    }
    else
    {
        $message += "Other"
    }
    if ($IsSDK.IsPresent)
    {
        $message += " (.NET SDK)"
    }
    else
    {
        $message += " (.NET Runtime)"
    }
    Write-Output $message

    if ($isWindowsPlatform)
    {
        Write-Output "Installing Microsoft365DSC module dependencies in PowerShell 7"
        if ($IsSDK.IsPresent)
        {
            Update-M365DSCDependencies -Development

            Write-Output "Configuring PowerShell 7 environment"
            Write-Output "Copying pwrshplugin.dll to PowerShell 7 module path"
            $PSVersion = [System.String]$PSVersionTable.PSVersion
            $SDK = dotnet --list-sdks
            if ($LASTEXITCODE -ne 0)
            {
                throw "Could not get .NET SDK version"
            }
            $SDKVersion = $SDK.Split(' ')[0].SubString(0, 4)
            $destinationPath = "C:\Program Files\PowerShell\.store\powershell.windows.x64\{0}\powershell.windows.x64\{1}\tools\net{2}\any" `
                -f $PSVersion, $PSVersion, $SDKVersion
            $path = Join-Path -Path $destinationPath -ChildPath "runtimes\win-x64\native\pwrshplugin.dll"
            Copy-Item -Path $path -Destination $destinationPath -Force

            $null = Enable-PSRemoting -Force -SkipNetworkProfileCheck

            $remotePowerShellConfig = @"
PSHOMEDIR=C:\Program Files\PowerShell\7
CORECLRDIR=C:\Program Files\PowerShell\7
"@
            $remotePowerShellConfigPath = "C:\Windows\System32\PowerShell\{0}\RemotePowerShellConfig.txt" -f $PSVersion
            Set-Content -Path $remotePowerShellConfigPath -Value $remotePowerShellConfig -Force
        }
        else
        {
            Update-M365DSCDependencies

            $null = Enable-PSRemoting -Force -SkipNetworkProfileCheck
        }

        $RemoveAliases = @"
Write-Output "Removing aliases gacfg and sacfg if they exist and importing PSDesiredStateConfiguration module"
if (Get-Alias gacfg -ErrorAction SilentlyContinue) {
    Remove-Item Alias:gacfg -Force
}
if (Get-Alias sacfg -ErrorAction SilentlyContinue) {
    Remove-Item Alias:sacfg -Force
}
Import-Module PSDesiredStateConfiguration -Force
"@

        $profileFolderPath = "C:\Users\ContainerAdministrator\Documents\PowerShell"
        $profileFilePath = Join-Path -Path $profileFolderPath -ChildPath "Microsoft.PowerShell_profile.ps1"
        if (-not (Test-Path -Path $profileFolderPath))
        {
            $message = "Creating PowerShell 7 profile folder at {0}" -f $profileFolderPath
            Write-Output $message
            $null = New-Item -ItemType Directory -Path $profileFolderPath -Force
        }
        Write-Output "Setting `$PROFILE for PowerShell 7"
        Set-Content -Path $profileFilePath -Value $RemoveAliases -Force

        Write-Output "Configuring Windows PowerShell environment"
        Set-ExecutionPolicy Unrestricted -Force

        Get-ChildItem "C:\Program Files\WindowsPowerShell\Modules" -Recurse | Unblock-File
        Set-Item -Path WSMan:\localhost\MaxEnvelopeSizekb -Value 1039440 -Force

        $computerSystem = Get-CimInstance -ClassName "Win32_ComputerSystem"
        $totalPhysicalMemory = $computerSystem.TotalPhysicalMemory
        $quotaConfiguration = Get-CimInstance -Namespace Root -ClassName "__ProviderHostQuotaConfiguration"
        $quotaConfiguration.MemoryAllHosts = $totalPhysicalMemory # Adjust the memory for all processes combined
        $quotaConfiguration.MemoryPerHost  = $totalPhysicalMemory # Adjust the memory for a single wmiprvse.exe process
        Set-CimInstance -InputObject $quotaConfiguration
        # WSMan caps each remote shell below the working set the Microsoft365DSC modules reach during import. A higher cap keeps the remote Test host responsive
        Set-Item -Path WSMan:\localhost\Plugin\PowerShell.7\Quotas\MaxMemoryPerShellMB -Value 2048 -Force

        [System.Environment]::SetEnvironmentVariable('M365DSCTelemetryEnabled', $false, [System.EnvironmentVariableTarget]::Machine)
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "ACP" -Value 65001 -Force
        $null = New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
    }
    else
    {
        Write-Output "Installing Microsoft365DSC module dependencies"
        if ($IsSDK.IsPresent)
        {
            Update-M365DSCDependencies -Development
        }
        else
        {
            Update-M365DSCDependencies
        }

        Write-Output "Configuring OS environment"
        [System.Environment]::SetEnvironmentVariable('M365DSCTelemetryEnabled', $false, [System.EnvironmentVariableTarget]::Process)
    }
}
catch
{
    throw $_
}

Write-Output ' '
$message = "Finished installing Microsoft365DSC, dependencies and configuration " + `
    "successfully {0}" -f [Char]::ConvertFromUtf32(0x2705)
Write-Output $message
