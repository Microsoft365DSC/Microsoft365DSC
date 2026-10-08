# Troubleshooting / Known Issues

## Error "Device code terminal timed-out after 120 seconds. Please try again."

### ISSUE

When you are using Credentials and Delegated Authentication (for more info, see: <a href="../../get-started/authentication-and-permissions/#microsoft-graph-permissions" target="_blank">Delegated Permissions</a>), it is possible that you receive the following error:

```powershell
Device code terminal timed-out after 120 seconds. Please try again.
+ CategoryInfo : NotSpecified: (:) [], CimException
+ FullyQualifiedErrorId : Microsoft.Graph.PowerShell.Authentication.Cmdlets.ConnectMgGraph
+ PSComputerName : localhost
```

### CAUSE

This is caused by the fact that the delegated Graph application has not been given consent to use the assigned permissions and therefore prompts for consent. However, since the deployment process runs in a non-interactive process, you will never see this prompt. After 120 seconds it will time out and throw the above error.

### RESOLUTION

This issue can be resolved by granting and consenting the correct permissions. You can do this via the Azure Admin Portal or by running using the <a href="../../cmdlets/Update-M365DSCAllowedGraphScopes/" target="_blank">Update-M365DSCAllowedGraphScopes</a> cmdlet. More information about that process can be found <a href="../authentication-and-permissions/#providing-consent-for-graph-permissions" target="_blank">here</a>.

## Error "The WMI service or the WMI provider returned an unknown error: HRESULT 0x80041033" when running Exchange workload

### ISSUE

When you are running a configuration apply or test with many Exchange workload resources, it is possible that the WMI provider throws an error and high memory usage is detected.

```powershell
The WS-Management service cannot process the request. The WMI service or the WMI provider returned an unknown error: HRESULT 0x80041033
+ CategoryInfo : ResourceUnavailable: (root/Microsoft/...gurationManager:String) [], CimException
+ FullyQualifiedErrorId : HRESULT 0x80041033
+ PSComputerName : localhost
```

### CAUSE

This is caused by the `ExchangeOnlineManagement` PowerShell module consuming more memory than what is available to the wmiprvse.exe process (WMI Provider Host). The default is 4GB of memory on a Windows 11 computer. If those 4GB of memory are not enough, the WMI Provider Host will crash and might restart or not.

### RESOLUTION

This issue can be resolved by allowing the WMI Provider Host to allocate more than the default 4GB of memory.

```powershell
$quotaConfiguration = Get-CimInstance -Namespace Root -ClassName "__ProviderHostQuotaConfiguration"
$quotaConfiguration.MemoryAllHosts = 4 * 4GB # Adjust the memory for all processes combined
$quotaConfiguration.MemoryPerHost  = 3 * 4GB # Adjust the memory for a single wmiprvse.exe process
Set-CimInstance -InputObject $quotaConfiguration
```

If you want all memory of the computer to be available to the WMI Provider Host, you can do that as well, but a customized amount is most likely better suited:

```powershell
$computerSystem = Get-CimInstance -ClassName "Win32_ComputerSystem"
$quotaConfiguration.MemoryAllHosts = $computerSystem.TotalPhysicalMemory
$quotaConfiguration.MemoryPerHost  = $computerSystem.TotalPhysicalMemory
```

Optionally, for improved performance, you can increase the handles and threads per host (wmiprvse.exe process) as well:

```powershell
$quotaConfiguration.HandlesPerHost = 8192
$quotaConfiguration.ThreadsPerHost = 512
```

## Error "InvalidOperation: Cannot index into a null array" when creating a report from configuration

### ISSUE

When creating a report from either running `New-M365DSCDeltaReport` or `New-M365DSCReportFromConfiguration`, you might receive the following error and the generated report is empty:

```powershell
Cannot index into a null array.
At C:\Program Files\WindowsPowerShell\Modules\DSCParser\2.0.0.5\Modules\DSCParser.psm1:**456** char:9
+         $resourceType         = $resource.CommandElements[0].Value
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
    + FullyQualifiedErrorId : NullArray
```

### CAUSE

This issue might occur if there are multiple versions of Microsoft365DSC present on the current machine and the configuration contains nested objects.
The nested objects are resolved from their CIM definitions, and if multiple versions of Microsoft365DSC are present, multiple versions of these CIM definitions exist.

### RESOLUTION

Update and install to the latest supported version of Microsoft365DSC using `Update-M365DSCModule`. This will uninstall all outdated versions and dependencies and update to the latest version available on the PowerShell Gallery.

## Error during configuration compilation or report generation

### ISSUE

When compiling configuration or creating a report from an existing configuration, Unicode characters might not be properly parsed, resulting in an error similar to the following.
The example contains an "en-dash" character in the `DisplayName` property.

```powershell
New-M365DSCReportFromConfiguration -ConfigurationPath D:\testbed\M365TenantConfig.ps1 -Type HTML -OutputPath D:\testbed\report.html
Error parsing configuration: At line:40 char:63
+             DisplayName                            = "Groupâ€“name";
+                                                               ~~~~~~
Unexpected token 'name";
            EmailAddresses                         = @("");
            HiddenFromAddressListsEnabled          = $False;
            HiddenFromExchangeClientsEnabled       = $False;
            Id                                     = "Test";
            InformationBarrierMode                 = "Open";
            Language                               = "en-US";
            MaxReceiveSize                         = "36' in expression or statement.
At C:\Program Files\WindowsPowerShell\Modules\DSCParser\2.0.0.15\Modules\DSCParser.psm1:472 char:9
+         throw "$($errorPrefix)Error parsing configuration: $parseErro ...
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Error parsing c...n or statement.:String) [], RuntimeException
    + FullyQualifiedErrorId : Error parsing configuration: At line:40 char:63
+             DisplayName                            = "Groupâ€“name";
```

### RESOLUTION

Microsoft365DSC will output a warning message if the current PowerShell session is not configured to use UTF-8 as its default encoding.
Follow the suggestions presented in the warning message, restart the PowerShell session and try again.

```powershell
WARNING: The code page of the current session is not set to UTF-8. This may cause issues with Unicode characters.
         To change the code page to UTF-8, you have the following options:
         * Using the control panel: intl.cpl --> Administrative --> Change system locale --> Beta: Use Unicode UTF-8 for worldwide language support
         * Using PowerShell: Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage" -Name "ACP" -Value 65001
         After that, you need to restart the PowerShell session.
```

## Error "WSManPluginReceiveResult error 14 / OutOfMemoryException" when running Start, Test, or Get-DscConfiguration

### ISSUE

When running a Local Configuration Manager (LCM) related cmdlet, Start, Test, or Get-DscConfiguration e.g. `Test-DscConfiguration -ReferenceConfiguration <path>\localhost.mof -Verbose`, especially inside a container, you might receive the following errors and the DSC Operational log shows an `OutOfMemoryException`:

```powershell
OperationStopped: Processing data for a remote command failed with the following error message: Error with error code 14 occurred while calling method WSManPluginReceiveResult. For more information, see the about_Remote_Troubleshooting Help topic.
OperationStopped: Starting a command on the remote server failed with the following error message : The I/O operation has been aborted because of either a thread exit or an application request. For more information, see the about_Remote_Troubleshooting Help topic.
OperationStopped: Index was out of range. Must be non-negative and less than the size of the collection.
Parameter name: index
InvalidOperation: The PowerShell DSC resource '[AADUser]AADUser...' with SourceInfo '...AADUser.ps1::16::9::AADUser' threw one or more non-terminating errors while running the Test functionality. These errors are logged to the ETW channel called Microsoft-Windows-DSC/Operational. Refer to this channel for more details.
```

### CAUSE

The `wsmprovhost.exe` process hosting the DSC resource runs out of memory while loading the Microsoft365DSC module and its Graph dependencies. The default WSMan per-shell memory quota combined with a small container (the default is 1GB of RAM) is not enough, so the host terminates mid-Test. The aborted I/O channel then surfaces as the follow-on `Index was out of range` style errors.

### RESOLUTION

Raise the WSMan per-shell memory quota:

```powershell
Set-Item -Path WSMan:\localhost\Plugin\PowerShell.7\Quotas\MaxMemoryPerShellMB -Value 2048
Restart-Service WinRM
```
