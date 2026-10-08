# Technical requirements

For Microsoft365DSC to function, you need to arrange the following components:

## PowerShell version

Microsoft365DSC requires PowerShell 7.6 or higher. Every cmdlet of the module such as `Export-M365DSCConfiguration`, has to be run from a PowerShell 7 console. You can download the latest release from [aka.ms/powershell-release](https://aka.ms/powershell-release).

**Please note:** Microsoft365DSC still requires to be installed in Windows PowerShell 5.1 if you want to use the Local Configuration Manager (LCM). Run `Update-M365DSCDependencies` in both Windows PowerShell and PowerShell 7 to install all dependencies.

Windows PowerShell 5.1 remains supported for a single scenario: compiling a configuration into a MOF file and applying or testing it through the LCM (`Start-DscConfiguration` and `Test-DscConfiguration`). The LCM only runs on Windows PowerShell, so in that case it relays the execution of every resource to a PowerShell 7 session on the same machine. This means PowerShell 7 still has to be installed, even when you drive the module through the LCM.

For additional details, please refer to our [PowerShell 7+ Guide for Microsoft365DSC](https://microsoft365dsc.com/user-guide/get-started/powershell7-support/).

## PowerShell Execution Policy

Microsoft365DSC consists of its own module and various PowerShell submodules. Allowing scripts to run is necessary for the successful execution of the functions. The command `Get-ExecutionPolicy` retrieves the current execution policy. Usually, it is enough if the value is set to RemoteSigned. If you encounter issues while loading scripts, set it to Unrestricted: `Set-ExecutionPolicy -ExecutionPolicy Unrestricted`

## Windows Remote Management (WinRM)

Microsoft365DSC uses the Local Configuration Manager (LCM). This requires PowerShell Remoting to be enabled. Please run either `winrm quickconfig -force` or `Enable-PSRemoting -Force -SkipNetworkProfileCheck` to enable it.

Run `Enable-PSRemoting -Force -SkipNetworkProfileCheck` from an elevated **PowerShell 7** console as well. This registers the `PowerShell.7` session configuration, which the LCM relay uses to hand the execution of the resources over to PowerShell 7.

## Tooling

To get the best experience running Microsoft365DSC cmdlets, it is recommended that you use the [Windows Terminal](https://www.microsoft.com/en-ca/p/windows-terminal/9n0dx20hk701). All screenshots provided in this article are using the Windows Terminal. This tool allows you to quickly switch between PowerShell versions and provide better support for icons and symbols that are used throughout Microsoft365DSC’s experience.

## Permissions

In order to connect to Microsoft 365, you need to make sure you have valid credentials (user **or** application credentials) with the correct permissions to the Microsoft 365 service. Microsoft365DSC offers several methods of authentication, depending on the used resources. Unfortunately, we are depending on the supported authentication methods used by the various PowerShell modules that are used.

Make sure you review the [Authentication and Permissions](authentication-and-permissions.md) article for more information on the available authentication methods and how to configure all required permissions.

## Experience and skills

Before you start using Microsoft365DSC, it is important that you also have the proper experience and skills on administering Microsoft 365. Microsoft365DSC is a powerful solution that can greatly streamline Microsoft 365 administration. But with great power comes great responsibility:

**If you don't know what exactly you are doing, using Microsoft365DSC you can also cause some serious damage.**

That is why it is important that you have the correct experience and skills. To use this module properly you should be very familiar with:

* [Microsoft 365 administration across all services / workloads](https://docs.microsoft.com/en-us/microsoft-365/admin/admin-overview/admin-center-overview)
* [PowerShell](https://docs.microsoft.com/en-us/powershell/)
* [PowerShell Desired State Configuration](https://docs.microsoft.com/en-us/powershell/dsc/getting-started/winGettingStarted?view=dsc-1.1)
* [Authentication methods and permission management in Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/develop/msal-authentication-flows)

Additionally it can be helpful, depending on the planned use of Microsoft365DSC, to have a good understanding of:

* [Azure DevOps](https://azure.microsoft.com/en-us/services/devops/)
* [Azure Automation](https://docs.microsoft.com/en-us/azure/automation/overview)

### Training resources

You can review the following training resources and certifications, for learning more about the above topics:

#### PowerShell Desired State Configuration

* [Get started with Desired State Configuration for Windows](https://docs.microsoft.com/en-us/powershell/dsc/getting-started/wingettingstarted)
* [Separating configuration and environment data](https://docs.microsoft.com/en-us/powershell/dsc/configurations/separatingenvdata)
* [Video series: "Getting Started with PowerShell Desired State Configuration"](https://docs.microsoft.com/en-us/shows/getting-started-with-powershell-dsc/)

#### Microsoft 365 Administration

* [About the Microsoft 365 admin center](https://docs.microsoft.com/en-us/microsoft-365/admin/admin-overview/about-the-admin-center)
* [Overview of the Microsoft 365 admin center](https://docs.microsoft.com/en-us/microsoft-365/admin/admin-overview/admin-center-overview)
* [About admin roles](https://docs.microsoft.com/en-us/microsoft-365/admin/add-users/about-admin-roles)
* [Video: Get an overview of the Microsoft 365 admin center](https://www.youtube.com/watch?v=aTkgF33C9hA)

#### Recommended Certification

* [Microsoft 365 Certified: Fundamentals (MS-900)](https://docs.microsoft.com/en-us/learn/certifications/microsoft-365-fundamentals/)
* [Microsoft 365 Certified: Enterprise Administrator Expert (MS-100 & MS-101)](https://docs.microsoft.com/en-us/learn/certifications/m365-enterprise-administrator/)
