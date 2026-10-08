# Developing new resources

Before getting ready to contribute a resource to the project, make sure you've read and followed the steps described in [Setting up your Environment to Contribute to the Project](getting-started.md).

## Select the Resource to Add

DSC resources need to support CRUD operations, meaning that we need to be able to read them, create (or set) instances of them, update them and sometimes remove them. In that regards, your first step in selecting a resource to add should be to make sure there are associated PowerShell cmdlets (or APIs) available to support your resource.

For example, the SCComplianceCase resource has the following cmdlets available in the Security and Compliance Powershell module: **New-ComplianceCase**, **Set-ComplianceCase**, **Get-ComplianceCase** and **Remove-ComplianceCase**. It is therefore a candidate to be added as a resource to the project.

A few rules also apply to your resource selection:

* Some cmdlets in the Exchange and Security and Compliance modules are only available to certain SKUs. You will need to make sure that executing a configuration that uses your resource against a SKU that doesn't support its underlying cmdlets or API is gracefully handled, and does not throw a blocking error.

## Create the Resource Files

The best way to get started here is to simply copy an existing resource, and then to rename and modify it. All resources are found under **/Modules/Microsoft365DSC/DscResources**. Each resource is represented by a folder containing a .psm1 file which holds the resource class, and a readme.md file which describes what the resource is for.

The folder and module files need to be named based on the following pattern:

* Need to start with **MSFT_** to indicate that this is for a project under the Microsoft organization.
* Need to then contain letters representing the workload associated to the resource (EXO for Exchange Online, SPO for SharePoint Online, OD for OneDrive, SC for Security and Compliance, TEAMS for teams, and O365 for generic admin resources).
* The rest of the name should normally follow the same naming convention as the cmdlet it represents. For example, because the cmdlet to create a new compliance case is New-ComplianceCase, the associated resource would be named **MSFT_SCComplianceCase**.

The class inside the file carries the same name without the **MSFT_** prefix, and derives from **M365DSCResourceBase**:

```powershell
using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCComplianceCase : M365DSCResourceBase
{
}
```

## Start with the Properties

Now that you've identified what resource you wish to work on, take a look at the documentation for the associated cmdlets or APIs. For example, the MSFT_SCComplianceCase cmdlet information is found at [https://docs.microsoft.com/en-us/powershell/module/exchange/policy-and-compliance-ediscovery/new-compliancecase?view=exchange-ps](https://docs.microsoft.com/en-us/powershell/module/exchange/policy-and-compliance-ediscovery/new-compliancecase?view=exchange-ps).

Take a look at the list of parameters and figure out which one should be implemented by your resource. For the Compliance Case example, the documentation lists the following properties:

```powershell
New-ComplianceCase
   [-Name] String
   [-Confirm]
   [-Description] String
   [-DomainController]FQDN
   [-Sources] Object[]
   [-WhatIf]
   [CommonParameters]
```

Some of these parameters can be ignored since they do not make sense to implement in a resource or for Office 365 altogether. From the list of parameters above, we can see that parameter **Name** should be our key indicator. We can also see that we won't need to implement the Confirm, WhatIf and CommonParameters properties in our resources since they don't make sense in the context of DSC. On top of that, if we read through the documentation, we can see that the **DomainController** and **Sources** properties are reserved for internal Microsoft use. Therefore we won't be implementing them within our resource.

The list of properties is not yet complete at this point. If we take a look at the update cmdlet **Set-ComplianceCase**, we can see from its documentation that it accepts a **-Close** and **-Reopen** property to define if a case is opened or closed. We will add this property to our resource as **Status** and will accept **Active** or **Closed** as values.

The properties are declared on the class, and they *are* the schema - there is no separate file to keep in sync. Each one needs:

* **`[DscProperty()]`**, or **`[DscProperty(Key)]`** for a unique identifier. There can be more than one key property; any given configuration cannot define duplicates of the same combination of key values. Use **`[DscProperty(Mandatory)]`** for a property that is required but is not a key.
* **`[System.ComponentModel.Description('...')]`**, ending with a period. Ideally you should simply copy the description of the property from the official documentation on [docs.microsoft.com](https://docs.microsoft.com). These descriptions are what generate the documentation pages, so they are not optional.
* **`[ValidateSet(...)]`** when the property accepts a restricted set of values.

In the Compliance Case example, the properties translate to the following:

```powershell
[DscProperty(Key)]
[System.ComponentModel.Description('The Name parameter specifies the unique name of the compliance case.')]
[System.String] $Name

[DscProperty()]
[System.ComponentModel.Description('The description of the case.')]
[System.String] $Description

[DscProperty()]
[System.ComponentModel.Description('Status for the case. Can either be ''Active'' or ''Closed''')]
[ValidateSet('Active', 'Closed')]
[System.String] $Status
```

Note that single quotes inside a description are escaped by doubling them.

On top of these resource specific properties, each resource should define **Ensure** when it supports removing instances of the resource. Every resource is also required to define **Credential**:

```powershell
[DscProperty()]
[System.ComponentModel.Description('Specify if this case should exist or not.')]
[ValidateSet('Present', 'Absent')]
[System.String] $Ensure

[DscProperty()]
[System.ComponentModel.Description('Credentials of the Global Admin Account')]
[System.Management.Automation.PSCredential] $Credential
```

Other authentication properties should be added if the resource supports it:

* `ApplicationId` - The client id of the app registration
* `ApplicationSecret` - The client secret used for authentication with the app registration
* `CertificateThumbprint` - Alternative to client secret. Thumbprint of the certificate used for authentication with the app registration
* `TenantId` - The tenant name to be managed
* `ManagedIdentity` - If the resource supports managed identity for authentication
* `AccessTokens` - Access tokens passed to the authentication

```powershell
[DscProperty()]
[System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
[System.String] $ApplicationId

[DscProperty()]
[System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
[System.Management.Automation.PSCredential] $ApplicationSecret

[DscProperty()]
[System.ComponentModel.Description('Thumbprint of the Azure Active Directory application''s authentication certificate to use for authentication.')]
[System.String] $CertificateThumbprint

[DscProperty()]
[System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
[System.String] $TenantId

[DscProperty()]
[System.ComponentModel.Description('Managed ID being used for authentication.')]
[System.Nullable[System.Boolean]] $ManagedIdentity

[DscProperty()]
[System.ComponentModel.Description('Access token used for authentication.')]
[System.String[]] $AccessTokens
```

Use `[System.Nullable[System.Boolean]]` rather than `[System.Boolean]` for optional booleans, and the same for other value types such as `[System.Nullable[System.UInt32]]`. A plain value type cannot distinguish "not specified" from "specified as `$false`" or `0`.

A property that the export needs but that is not part of the schema - most commonly `$Filter` - is declared without the `[DscProperty()]` attribute:

```powershell
# Export-only. Not part of the resource schema.
[System.String] $Filter
```

## Write the Methods

Every resource implements four methods:

```powershell
[SCComplianceCase] Get() { }
[void] Set() { }
[bool] Test() { }
[string] Export() { }
```

Each starts by handing off to PowerShell Core when required, then connects and records telemetry:

```powershell
[SCComplianceCase] Get()
{
    if ($this.RequiresPowerShellCore())
    {
        $remote = [SCComplianceCase]::new()
        $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
        return $remote
    }

    $null = $this.Connect('SecurityComplianceCenter')

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $this.AddTelemetry('Get')
    #endregion
    ...
}
```

Read the configured values off `$this` (`$this.Name`, `$this.Ensure`), and use `$this.GetBoundParameters()` when you need to know which properties the configuration actually set. `Get()` builds a hashtable of results and hands it to `$this.AsResult()`, which produces the typed instance the method has to return. `Set()` reads the current state with `$this.Get().ToHashtable()`.

`Test()` is declared on every resource, but most of them just hand off to the base class, which implements the standard comparison:

```powershell
[bool] Test()
{
    return ([M365DSCResourceBase] $this).Test()
}
```

Write a real body only when the comparison itself is non-standard. If all you need is to exclude a property or post-process values before comparing, keep the delegation and override `GetCompareParameters()` instead.

Microsoft365DSC also supports [ReverseDSC](https://github.com/Microsoft/ReverseDSC) natively, which is what `Export()` provides. It loops through each instance of your resource in the tenant and converts them into DSC strings. For each instance, assign it to `$this.ExportedInstance` and call `$this.GetForExport($Params)` - that populates the instance and runs `Get()` without a second round trip to the service. `Export()` must honour the `$Filter` property. Please refer to existing resources to better understand the logic of this method.

Anything the class cannot express as a method - a conversion or comparison used in several places - goes into a module scope function below the class, in the same file. All resources share one module scope once built, so prefix the function name with the resource name: `Get-SCComplianceCaseSomething`, not `Get-Something`. Those functions have no `$this`; if one needs to cache, give it a `[System.Collections.Hashtable] $Cache` parameter and pass `$this.ResourceCache`.

Some things that work in a normal function do not work inside a class method:

* `$Script:` variables. All resources share one module scope, so per-resource state goes on `$this.ResourceCache['<Key>']`, seeded in a `SCComplianceCase() : base() { }` constructor.
* Automatic and global variables. Write `$Global:PSVersionTable`, `$Global:M365DSCEmojiGreenCheckMark`.
* `$this` inside a nested script block. Read the value into a local first.
* A local with the same name as a property. `$name` collides with `$Name`.
* Assigning a variable for the first time inside an `if` branch. Declare it as `$null` before the branch.

## Build and Test

`DscResources/` is source. Compile it before the module can be imported:

```powershell
./Utilities/Build-Microsoft365DSC.ps1
```

The build reports how many resources it found and discovered - your new resource should appear in both counts. It also updates `Microsoft365DSC.psd1`, so commit that file along with your resource.

Add a unit test at `Tests/Unit/Microsoft365DSC/Microsoft365DSC.<ResourceName>.Tests.ps1`, modelled on an existing one for the same workload, then run it:

```powershell
Invoke-Pester -Path Tests/Unit/Microsoft365DSC/Microsoft365DSC.SCComplianceCase.Tests.ps1
```
