# PowerShell 7+ support

Microsoft365DSC requires PowerShell 7.6 or higher to be installed on the machine. The module and all of its resources are written against PowerShell 7, and every cmdlet of the module has to be run from a PowerShell 7 console. You can download the latest release from [aka.ms/powershell-release](https://aka.ms/powershell-release).

If you start a session with an older PowerShell version, or with Windows PowerShell, the module emits a warning at import time telling you which version is running and what is supported in that session.

## Windows PowerShell and the Local Configuration Manager

There is one scenario in which Windows PowerShell 5.1 is still involved: compiling a configuration into a MOF file and applying or testing it through the Local Configuration Manager, using `Start-DscConfiguration` and `Test-DscConfiguration`. The classic LCM only runs on Windows PowerShell.

In that case, the resources do not execute on Windows PowerShell. Each resource method detects the edition it runs on and relays the call into a PowerShell 7 session on the same machine, then rebuilds the typed result from what comes back. PowerShell 7 therefore still has to be installed and reachable, even when the LCM drives the module.

Two things have to be in place for the relay to work:

* WinRM has to be configured, and the `PowerShell.7` session configuration has to be registered. Run `Enable-PSRemoting -Force -SkipNetworkProfileCheck` from an elevated **PowerShell 7** console to register it.
* The LCM resolves the module through the Windows PowerShell module path. If you drive the module through the LCM, Microsoft365DSC has to be available under `C:\Program Files\WindowsPowerShell\Modules\Microsoft365DSC` as well.

Everything else, including `Export-M365DSCConfiguration`, `Update-M365DSCDependencies`, `New-M365DSCDeltaReport` and `Assert-M365DSCBlueprint`, runs directly on PowerShell 7 and needs no Windows PowerShell at all.

!!! note
    If your configuration contains empty arrays, it still has to be compiled in Windows PowerShell 5.1. Otherwise, the affected properties might be omitted from the resulting MOF file. This is a limitation of the MOF compiler, not of Microsoft365DSC.

## Installing the module and its dependencies

Install Microsoft365DSC and its prerequisites from an elevated Windows PowerShell console:

```powershell
Install-Module Microsoft365DSC -Force
Update-M365DSCDependencies
```

Then, in a second elevated PowerShell 7 console, run the same command to make sure the module is available in that edition as well:

```powershell
Update-M365DSCDependencies
```

`Update-M365DSCDependencies` reads the dependency list that ships with the module and installs the pinned versions. Run it after every update of the module. If you plan to use the LCM, install the module for all users so that both PowerShell 7 and Windows PowerShell can resolve it.
