# Installing Microsoft365DSC

While the source code of the solution is open-sourced on [GitHub](https://GitHub.com/Microsoft/Microsoft365DSC), the releases of the solutions are being published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/Microsoft365DSC/). This means that the tool can be installed onto any machine by running the following PowerShell command:

```powershell
Install-Module Microsoft365DSC -Force
```

<figure markdown>
   ![Installing Microsoft365DSC](../../Images/InstallingM365DSC.png)
  <figcaption>Installing Microsoft365DSC</figcaption>
</figure>

Executing this command can take a minute or two to complete, after which the base Microsoft365DSC module has been installed.

> **NOTE:** Make sure you run the above command in an elevated **Windows PowerShell 5.1** window. In a regular window the module will be installed in the Current User scope, which will not work!

## Dependencies

However, Microsoft365DSC depends on several other modules to function properly. For example, it uses the [MSCloudLoginAssistant](https://www.powershellgallery.com/packages/MSCloudLoginAssistant/) module to delegate all authentication logic to the various workloads and many more modules from the PowerShell Gallery. When you install the Microsoft365DSC module, you only get the core component after which you have to download all prerequisite modules as well. It is our recommendation that you run the following command to update all dependencies on the system after installing the module, in both Windows PowerShell and PowerShell 7:

```powershell
Update-M365DSCDependencies
```

<figure markdown>
   ![Installing Microsoft365DSC Dependencies](../../Images/InstallingDependencies.png)
  <figcaption>Installing Microsoft365DSC Dependencies</figcaption>
</figure>

Running the above command will automatically read the list of dependencies from the [Module Root]/Dependencies/Manifest.psd1 file, check to see if the proper version of these modules are installed on the machine, and (if not) automatically download them from the PowerShell Gallery and install on the local computer.

Depending on your configuration and the version of PowerShell you are using, the installed modules may be put in different locations. The process of installing a PowerShell module from the PowerShell Gallery really just comes down to downloading the files from the gallery as a zip, extracting them and copying to a location on the system that is associated with PowerShell via environment variables. The following command will allow you to view the version of any given PowerShell module on a system along with its associated version:

```powershell
Get-Module Microsoft365DSC -ListAvailable | select ModuleBase, Version
```

<figure markdown>
   ![Viewing Installed Microsoft365DSC module](../../Images/GetModuleM365DSC.png)
  <figcaption>Viewing Installed Microsoft365DSC module</figcaption>
</figure>

## Updating To A Newer Version

To update an older version of Microsoft365DSC, use the **Update-M365DSCModule** cmdlet. This will update the current version of Microsoft365DSC and all dependencies in one go as well as uninstalling all outdated versions.

```powershell
Update-M365DSCModule
```

## More Information

More information about installing modules:

* [Installing a PowerShell module](https://docs.microsoft.com/en-us/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7.2)
* [Find-Module cmdlet](https://docs.microsoft.com/en-us/powershell/module/powershellget/find-module?view=powershell-7.2)
* [Install-Module cmdlet](https://docs.microsoft.com/en-us/powershell/module/powershellget/install-module?view=powershell-7.2)
* [Update-M365DSCModule cmdlet](https://microsoft365dsc.com/user-guide/cmdlets/Update-M365DSCModule/)
* [Save-Module cmdlet](https://docs.microsoft.com/en-us/powershell/module/powershellget/save-module?view=powershell-7.2)
* [About PSModulePath](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath?view=powershell-7.2)
