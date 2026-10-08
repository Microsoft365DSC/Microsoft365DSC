# Deploying Configurations

This section explains how you can take a Microsoft365DSC configuration file you have written (or captured using the snapshot feature) and apply the settings it defines onto a Microsoft 365 tenant. It is very important to understand that at this stage, we are using PowerShell Desired State (DSC) out-of-the-box and that the process of applying a DSC configuration is not something specific to Microsoft365DSC.

## Creating your own DSC Configuration

Microsoft365DSC is built on top of the PowerShell Desired State Configuration framework. Therefore, before you get started with Microsoft365DSC, it is important to know the basics and best practices of [PowerShell Desired State Configuration](https://docs.microsoft.com/en-us/powershell/dsc/overview/dscforengineers?view=dsc-1.1) (DSC). Here is a small introduction to PowerShell DSC:

PowerShell DSC is a declarative approach for configuring servers and environments. It is based on the [Open Management Infrastructure](https://en.wikipedia.org/wiki/Open_Management_Infrastructure) (implemented in Windows as WMI). PowerShell offers a way to declare a desired state in PowerShell syntax, compile this to what's known as a _MOF_ (Managed Object Framework) file, and publish that to a target machine.

On that target machine the [LCM (Local Configuration Manager)](https://docs.microsoft.com/en-us/powershell/dsc/managing-nodes/metaconfig?view=dsc-1.1) will do the heavy lifting and make sure your server **gets into the desired state**, detects when the server **deviates from the desired state** or even automatically **corrects and brings the server back to its desired state**.

By default PowerShell offers several [resources](https://docs.microsoft.com/en-us/powershell/dsc/resources/resources?view=dsc-1.1#windows-built-in-resources) out-of-the-box, but these can be extended by [installing modules](https://docs.microsoft.com/en-us/powershell/dsc/configurations/install-additional-dsc-resources?view=dsc-1.1) like Microsoft365DSC.

To create and deploy your own Desired State:

1. You create a [DSC Configuration](https://docs.microsoft.com/en-us/powershell/dsc/configurations/configurations?view=dsc-1.1)
2. You compile your PowerShell configuration [to a MOF file](https://docs.microsoft.com/en-us/powershell/dsc/configurations/write-compile-apply-configuration?view=dsc-1.1#compile-the-configuration) (see <a href="#compiling-and-validating-the-configuration">paragraph below</a>)
3. Finally, you [apply the MOF file](https://docs.microsoft.com/en-us/powershell/dsc/configurations/write-compile-apply-configuration?view=dsc-1.1#apply-the-configuration) to your target server (see [paragraph below](#deploying-the-configuration))

We highly recommend that you watch the [Getting Started with PowerShell Desired State Configuration](https://docs.microsoft.com/en-us/shows/getting-started-with-powershell-dsc) training on Microsoft Learn.

For more information and more advanced topics, please make sure you review the following articles:

* [Add Parameters to a Configuration](https://docs.microsoft.com/en-us/powershell/dsc/configurations/add-parameters-to-a-configuration?view=dsc-1.1)
* [Separating configuration and environment data](https://docs.microsoft.com/en-us/powershell/dsc/configurations/separatingenvdata?view=dsc-1.1)
* [Using configuration data in DSC](https://docs.microsoft.com/en-us/powershell/dsc/configurations/configdata?view=dsc-1.1)
* [Want to secure credentials in Windows PowerShell Desired State Configuration?](https://devblogs.microsoft.com/powershell/want-to-secure-credentials-in-windows-powershell-desired-state-configuration)
* [Securing the MOF File](https://docs.microsoft.com/en-us/powershell/dsc/pull-server/securemof?view=dsc-1.1)
* [Securing your Compiled Configuration](securing-configurations.md) (Next chapter in this guide)

## Compiling and Validating the Configuration

The first step in trying to deploy a DSC configuration is to compile the configuration file into a MOF file. Doing so simply involves executing the .ps1 file that contains your configuration. The process of compiling your configuration will also perform some level of validation on the configuration, such as ensuring that every component defined in the file has all of their mandatory parameters defined, and that there are no typos in components or property names. If the compilation process is successful, you should see a message indicating that the MOF file was created. By default, this file is created in the same path your configuration file is located, and will create a new subfolder based on the name of the configuration object defined within your file.

**Attention: If your configuration contains empty arrays, then it must be compiled in Windows PowerShell (5.1). Otherwise, the affected properties might be omitted in the result file.**

Compiling a configuration and applying it with `Start-DscConfiguration` (or testing using `Test-DscConfiguration`) are the only Microsoft365DSC scenarios that involve Windows PowerShell because the Local Configuration Manager does not work with PowerShell > 5.1. The resources themselves still execute on PowerShell 7: the LCM relays every resource call into a PowerShell 7 session on the same machine. PowerShell 7.6 or higher therefore has to be installed, and the `PowerShell.7` remoting endpoint has to be registered. See [PowerShell 7+ Support](powershell7-support.md) for the details.

<figure markdown>
  ![Running a configuration compilation](../../Images/CompileConfiguration.png)
  <figcaption>Running a configuration compilation</figcaption>
</figure>

<figure markdown>
  ![Created configuration folder](../../Images/CompileConfigurationFolderView.png)
  <figcaption>Created configuration folder</figcaption>
</figure>

<figure markdown>
  ![Created MOF file in the folder](../../Images/CompileConfigurationCreatedMOF.png)
  <figcaption>Created MOF file</figcaption>
</figure>

## Deploying the Configuration

To initiate the deployment of a MOF file onto a Microsoft 365 tenant, you need to use the out-of-the-box cmdlet provided by PowerShell DSC called [Start-DSCConfiguration](https://docs.microsoft.com/en-us/powershell/module/psdesiredstateconfiguration/start-dscconfiguration?view=dsc-1.1). By default, this cmdlet will execute as an asynchronous background job. If you wish to monitor the execution of the process, you need to use the **-Wait** switch, which will make the execution synchronous. We also recommend using the **-Verbose** switch with the command to get additional details on the operation of the deployment process. The cmdlet takes as input the path to the folder containing the compiled MOF file. For example:

```powershell
Start-DSCConfiguration -Path C:\DemoM365DSC\M365TenantConfig -Wait -Verbose -Force
```

Executing the cmdlet will automatically authenticate against the affected workload using the authentication parameters provided at compilation time and will apply the configuration settings defined in the file.

<figure markdown>
  ![Initiating a MOF deployment](../../Images/DeployMOFFile.png)
  <figcaption>Initiating a MOF deployment</figcaption>
</figure>

It is normal for this process to take several minutes (if not hours) to complete, based on how many components are defined in your configuration. It is important to understand that once the configuration completes its deployment, this will configure the PowerShell DSC engine (LCM) on the current system to perform frequent repeated  checks against your Microsoft 365 tenant to test for configuration drifts. By default, the engine will wake up every 15 minutes (the minimum value possible). For more details on how to configure this, please refer to [Configuring the Local Configuration Manager](https://docs.microsoft.com/en-us/powershell/dsc/managing-nodes/metaconfig?view=dsc-1.1).

If you simply want to apply the configuration on the tenant as a one-off and prevent the system from running subsequent checks for configuration drifts, you can  remove the configuration you have applied by afterwards running the following PowerShell commands:

```powershell
Stop-DSCConfiguration -Force
Remove-DSCConfigurationDocument -Stage Current
```

<figure markdown>
  ![Stopping a DSC configuration deployment](../../Images/StopDSCConfiguration.png))
  <figcaption>Stopping a DSC configuration deployment</figcaption>
</figure>
