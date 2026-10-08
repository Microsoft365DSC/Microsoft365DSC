---
applyTo: "Examples/**/*.ps1"
description: "Authoring rules for Microsoft365DSC resource examples"
---

# Microsoft365DSC example authoring

The files under `Examples/Resources/` are the public showcase for every resource.
`M365DSCDocGenerator` publishes them verbatim to the wiki, and the integration suite applies them to
a live tenant. They must exercise as much of a resource as is simultaneously valid, using values a
real tenant would plausibly hold.

## Files

Each resource has its own folder at `Examples/Resources/<ResourceName>/`. The numbered trio is
mandatory.

| File | Contents |
| --- | --- |
| `1-Create.ps1` | every configurable non-authentication property, with realistic values |
| `2-Update.ps1` | the same coverage, differing from Create in at least one property |
| `3-Remove.ps1` | keys, mandatory properties, authentication properties and `Ensure = 'Absent'`, nothing else |

Additional files named `N-<Scenario>.ps1` are permitted for a distinct scenario that the trio cannot
express. `IntuneRoleAssignment` and `FabricAdminTenantSettings` both use this form.

A singleton resource has no `1-Create.ps1` or `3-Remove.ps1`. Update-only is the correct shape there
and is not a defect.

## Schema

The schema is the class at
`Modules/Microsoft365DSC/DscResources/MSFT_<ResourceName>/MSFT_<ResourceName>.psm1`. Read it before
editing an example.

Properties are declared as `[DscProperty()]`, `[DscProperty(Key)]` or `[DscProperty(Mandatory)]`,
often with a `[ValidateSet(...)]` and a `[System.ComponentModel.Description(...)]` that states what
the property means. `[System.Nullable[T]]` is a value type and nothing more. A property with no
`[DscProperty()]` attribute is export-only and must never appear in an example. Complex types are
the plain `class MSFT_*` declarations further down the same file.

## What to configure

`1-Create.ps1` and `2-Update.ps1` configure every configurable non-authentication property, with two
exceptions. Skip a property that conflicts with a value already chosen, such as `MembershipRule`
when `MembershipType` is `'Assigned'`. Skip a non-key service-generated identifier, and never invent
a GUID for one. Delete any all-zero GUID already present. Never write a comment explaining why a
property was skipped.

`2-Update.ps1` differs from `1-Create.ps1` in at least one property. Where it already differs in two
or more, leave that drift alone and only extend coverage. Where it differs in none, introduce
exactly one difference. Every differing line carries a trailing `# Updated Property` comment, and
that marker appears in no other file.

Never drift a key or anything else that changes which object the example targets. Prefer a scalar
free-text property such as a description.

`3-Remove.ps1` carries keys, mandatory properties, the authentication properties and
`Ensure = 'Absent'`. Nothing else belongs in it.

Keys must be byte-identical across all files in the folder. The integration suite applies Create,
then Update, then Remove against a single tenant, so a drifted key makes Update target an object
that Create never made.

## What never to change

The header comment block, the `Configuration Example` line, the `param(...)` block,
`Import-DscResource`, `Node localhost` and the resource instance name all stay as they are. Do not
create or delete files, and do not reorder or re-align existing lines.

## Values

| Type | Form |
| --- | --- |
| `System.String` | double-quoted and realistic, a name a real policy would have |
| `String` with `[ValidateSet]` | an exact member in its exact casing |
| `System.String[]` | one line, `@("a", "b")` |
| `Nullable[Boolean]` | `$true` or `$false`, lowercase and never quoted |
| `Nullable[Int32/Int64/UInt32/UInt64/Byte]` | a bare integer |
| `Nullable[Single/Double]` | a bare decimal |
| DateTime-shaped string | `"2026-01-01T00:00:00.0000000Z"` |
| Duration-shaped string | `"P30D"`, and a time of day as `"02:00:00"` |
| GUID-shaped string | a quoted lowercase GUID, stable within the resource |
| `PSCredential` | only where the resource class supports nothing else |

`$TenantId`, `$ApplicationId` and `$CertificateThumbprint` interpolate inside double quotes, as in
`"admin@$TenantId"`. Any other `$` or `"` inside a literal is backtick-escaped.

## Complex properties

Complex properties use the CIM block form, which is the only form that compiles inside a
`Configuration`.

```powershell
            ScopeValue = MSFT_MicrosoftGraphAccessReviewScope{
                Query     = "./members/microsoft.graph.user/"
                QueryType = "MicrosoftGraph"
            };
            Reviewers  = @(
                MSFT_AADAccessReviewDefinitionReviewer{
                    Type = "Owner"
                }
            );
```

The class name is the exact `MSFT_`-prefixed type from the resource's own `.psm1`. That prefix is
load-bearing, because `Tests/Integration/M365DSCTestEngine.psm1:74` filters stitched blocks on it
and a block without it is promoted to a top-level resource, which breaks the whole workload's
integration compile.

The opening brace sits on the same line as the type name with no space before it. This is a
deliberate exception to the "opening braces on a new line" style in
[powershell.instructions.md](./powershell.instructions.md), and it matches every existing example.
No semicolons appear inside a CIM block, and only the members actually being set are emitted.

## Write for the customer

Every value is documentation. The reader is an administrator configuring their own tenant, and they
copy what they see.

No free-text value may contain `DSC`, `M365DSC`, `Microsoft365DSC` or the project name in any form.
None may contain the words `test`, `testing`, `integration test`, `example`, `sample`, `demo` or
`placeholder`. None may explain why the value was chosen or state that it exists to be changed. This
applies to `Description`, `Comments`, `Notes`, `Justification`, `DisplayName`, `Name` and every
other free-text property.

| Instead of | Write |
| --- | --- |
| `Description = "DSC Testing 1"` | `Description = "Blocks attachments over 10 MB"` |
| `DisplayName = "DSCGroup"` | `DisplayName = "Sales Team"` |
| `Name = "M365DSC-RetentionPolicy"` | `Name = "Finance Records Retention"` |
| `Comments = "Updated by integration test"` | `Comments = "Reviewed annually by the compliance team"` |

Names still have to be distinct from what other examples create, because two examples must not fight
over the same object. Make them distinct the way a real tenant would, by naming different things
rather than by adding a marker.

The resource instance label is the one exception. It follows the repository-wide
`<ResourceName>-Example` convention and is never renamed.

## Authentication

A certificate thumbprint is the encouraged default, so every example authenticates the same way.

```powershell
    param
    (
        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )
```

The resource block ends with the three matching lines in that order.

```powershell
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
```

Use a `PSCredential` parameter only when the resource class declares no `CertificateThumbprint`
property. Never reference a variable that the `param()` block does not declare. A body referencing
`$Credscredential`, `$Credentials` or `$OrganizationName` compiles perfectly and authenticates as
nothing.

Never hard-code a tenant. A domain belongs in the example as `"user@$TenantId"` rather than
`"user@contoso.onmicrosoft.com"`, so the example can be lifted from one tenant to another.

## Tenant safety

Examples are applied to a live tenant as one merged configuration per step. Use no wildcard scopes.
Give any `All` target an accompanying exclusion. A Conditional Access policy is always
`State = "disabled"`. Make no auth-method policy change on the tenant-wide target. Use no
destructive retention or DLP action, no licence assignment and no hardware-dependent value.

## Placeholders

A value the reader has to supply themselves is written as an angle-bracket placeholder in lower
kebab case, such as `"<client-secret>"`, `"<base64-encoded-certificate>"` or `"<onboarding-blob>"`.

That covers two kinds of value. The first is secrets, meaning passwords, client secrets, pre-shared
keys, API keys, certificates and their private keys, and onboarding or configuration blobs. The
second is values that exist in one tenant only and cannot be looked up from the example, such as an
Azure subscription ID, the resource ID of a workspace or storage account, or a key vault URI.

It does not cover ordinary tenant data a reader would happily invent, such as display names,
descriptions, group names, UPNs on `contoso.com`, file names or URLs.

Every placeholder is registered in `Tests/QA/ExamplePlaceholders.psd1` with `Name`, `Meaning`,
`Sample` and `Properties`, sorted by `Name`. `Sample` is a realistic instance of the value that was
replaced so a reader can see its shape, and is never a live credential. Reuse an existing
placeholder wherever one fits, and invent a new name only when none of them means the same thing.
`Tests/QA/Microsoft365DSC.ExampleQuality.Tests.ps1` fails the build when an example uses an
unregistered placeholder or when a registered placeholder appears in no example.

A placeholder is not a drift value. Where Create and Update must differ on a secret, use `<thing>`
and `<thing-updated>`.

## Known limits

Some resources cannot reach full coverage, and forcing them to would produce a configuration that
contradicts itself. Recognise these four shapes and leave them alone.

- The uncovered properties are `Add*` or `Remove*` delta variants that the resource's own `Set()`
  strips whenever the absolute property is set. `SCAutoSensitivityLabelPolicy` and `SCLabelPolicy`
  are the clearest cases.
- The key pins a parameter set, so the properties of every other set are invalid. An
  `EXOMigrationEndpoint` using IMAP excludes the Outlook Anywhere and remote-move properties, and an
  IP-based `AADNamedLocationPolicy` excludes the country properties.
- The remaining properties are service-generated identifiers that must never be invented.
  `PlannerBucket` and `IntuneDeviceConfigurationWiredNetworkPolicyWindows10` are examples, the
  latter because its certificate references resolve through `GetCertificateId`, which throws unless
  the value already matches a certificate profile in the tenant.
- Drift is impossible by construction, because every non-key property would retarget the object.
  `EXORecipientPermission` and `EXOSmtpDaneInbound` are in this group, as is `IntuneAppCategory`,
  whose only configurable property is `DisplayName`.

## Editing mechanics

Read and write example files with `[System.IO.File]::ReadAllText` and `WriteAllText`, using a
`UTF8Encoding` whose BOM flag matches the original. Never use `sed -i`, which rewrites CRLF to LF
across the whole file and makes the diff unreviewable.

Use `-ceq` rather than `-eq` for any comparison that depends on casing, because `-eq` on strings is
case-insensitive and a pass whose only change is casing will silently write nothing.

Find a CIM block's closing brace by counting brace depth from its own opening brace. A CIM block can
contain another CIM block, so scanning for the next line that is just `}` stops at the nested
block's brace and splices into the wrong place.

`DependsOn` occurs exactly once in the whole example set, in `EXOOnPremisesOrganization/1-Create.ps1`,
where it points at `[EXOOutboundConnector]EXOOutboundConnector-Example`. Renaming that instance
label breaks it, and only the compile gate catches it.

Property names collide with built-in DSC keywords in 19 places, including `User`, `Settings`,
`Script`, `Node` and `Configuration`, and `SCProtectionAlert` has a `Filter` property that parses as
a filter declaration inside a scriptblock. The fast host handles all of these, so a hand-rolled
`[scriptblock]::Create` check produces false positives. The compile gate is the authority.

## Checking your work

The coverage analyzer reports how much of a resource's schema its examples configure.

```powershell
./Utilities/Measure-M365DSCExampleCoverage.ps1 -ResourceName '<Name>' | Format-List
```

`Verdict` must be `Compliant`, or the remaining `Reasons` must be ones the Known limits section
justifies. `UnknownProperties` and `InvalidEnumValues` are hard errors and must both be empty.
Note that the analyzer reads only the first line of a multi-line value, so drift buried inside a
multi-line script or payload scores `DriftCount = 0`. Move the drift onto a single-line scalar
rather than arguing with the count.

Then confirm the examples still compile and still pass the quality checks.

```powershell
$env:PSModulePath = (Resolve-Path ./Modules).Path + [IO.Path]::PathSeparator + $env:PSModulePath
$container = New-PesterContainer -Path ./Tests/QA/Microsoft365DSC.Examples.Tests.ps1 -Data @{ ResourceName = '<Name>' }
Invoke-Pester -Container $container -Output Detailed
Invoke-Pester -Path ./Tests/QA/Microsoft365DSC.ExampleQuality.Tests.ps1 -Output Detailed
```

Pass scope through `-Data` rather than `-FullNameFilter`, because Pester expands the test-name
placeholders after filtering and a name filter matches nothing. `-Data` accepts `Workload` and
`ResourceName`, each a string or an array, with wildcards allowed.
