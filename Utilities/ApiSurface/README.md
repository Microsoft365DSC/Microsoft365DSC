# API surface drift, and how to apply a finding

The weekly check compares the vendor API surface against what the resources declare and writes
`api-drift.json`. A maintainer approves findings in the tracking Issue and the apply run turns the
approved ones into a pull request.

Two ways to run it: from GitHub, which is the normal path, or from a working copy, which is the only
way to reach the manual categories.

## What the module exports

| Function | What it does |
| --- | --- |
| `Get-M365DSCApiSurface` | Takes the snapshot. Returns the object and writes nothing. |
| `Compare-M365DSCApiSurface` | The differ. Pure: no file, no network, no module import. |
| `Invoke-M365DSCApiSurfaceCheck` | The entry point. Acquires, compares, writes `api-drift.json`, the Markdown report and the Issue body. |
| `Update-M365DSCResourceFromDrift` | Applies ONE finding to the resource it names, verifies it, reverts it on failure. |
| `Invoke-M365DSCApiSurfaceUpdate` | Applies a set of approved findings, branches, tests, commits and opens the pull request. |

## Before anything else, build

The check reads `Modules/Microsoft365DSC/DscSchemaCache.json`, which is gitignored and produced by
the build. Without it the check throws and names the two scripts to run.

```powershell
& ./Utilities/Build-Microsoft365DSC.ps1 -SkipSchemaCache
& ./Utilities/New-M365DSCDscSchemaCache.ps1
```

Budget about 4 minutes for the first and about 30 seconds for the second.

The same rule applies after an apply. The unit tests read the built classes under
`Modules/Microsoft365DSC/Classes`, never the resource sources the applier edits, so a test run
between the edit and a rebuild proves nothing.

## Running the check locally

```powershell
$MaximumFunctionCount = 32767
Import-Module ./Utilities/ApiSurface/M365DSCApiSurface.psd1 -Force

Invoke-M365DSCApiSurfaceCheck -MarkdownPath ./api-drift.md
```

About 70 seconds offline, about 95 seconds more when the gallery is queried for newer dependency
versions. `-SkipGalleryLookup` removes that.

A run without `-IncludeTenantConnected` captures Graph CSDL types, Graph SDK cmdlets, the shim and
the statically declared workload modules. Exchange Online, Security and Compliance and the Intune
settings catalog need a tenant and are recorded in `completeness.skippedWorkloads` when it is
absent, which is what stops the differ reading their absence as a removal.

## Running the check against a tenant

```powershell
Invoke-M365DSCApiSurfaceCheck -IncludeTenantConnected `
    -ApplicationId $clientIdIntune `
    -TenantId $tenantIdName `
    -CertificateThumbprint $certThumbprintIntune `
    -WorkloadAuthentication @{
        ExchangeOnline           = @{ ApplicationId = $clientIdEXO;  CertificateThumbprint = $certThumbprintEXO }
        SecurityComplianceCenter = @{ ApplicationId = $clientIdSC;   CertificateThumbprint = $certThumbprintSC }
    }
```

Three things to know.

- **`TenantId` is the domain name**, `contoso.onmicrosoft.com`, never the GUID. The connection
  builder rejects a GUID with a message saying so.
- **One application registration rarely serves every workload.** Exchange Online and Security and
  Compliance normally hold separate ones. A registration without the rights for a workload connects
  without an error and produces no proxy, which the probe reports as a skipped workload rather than
  as an empty one. `-WorkloadAuthentication` carries the per-workload override, keyed by workload
  name, and `MicrosoftGraph` is a valid key for the settings catalog capture.
- **A connection failure downgrades the run, it does not fail it.** The message lands in
  `completeness.tenantError` and is rendered above everything else in both reports.
- **The settings catalog is fetched over the `MicrosoftGraph` connection, not the `Intune` one.**
  Whatever registration answers for `MicrosoftGraph` must therefore hold
  `DeviceManagementConfiguration.Read.All`. A registration without it returns 403, the capture
  drops `settingsCatalog` into `completeness.skippedWorkloads` without failing, and
  `-UpdateBaseline` then refuses to write because the run saw less than the committed baseline.
  The symptom is the message `This run saw less than the committed baseline: settingsCatalog`.
  A directory-only registration is the usual cause: point the `MicrosoftGraph` key at the Intune
  registration, or grant the permission to the one you already pass.

### Permissions the application registration needs

| Workload | What it needs |
| --- | --- |
| Microsoft Graph and Intune | `DeviceManagementConfiguration.Read.All` application permission. The settings catalog capture reads `/beta/deviceManagement/configurationPolicyTemplates` and each template's `settingTemplates?$expand=settingDefinitions`. |
| Exchange Online | The `Exchange.ManageAsApp` application permission plus a directory role that can read the configuration, for example Global Reader or Exchange Administrator. |
| Security and Compliance | The same application permission, plus a compliance role. This is usually a second registration. |

The certificate has to be installed in `Cert:\CurrentUser\My` or `Cert:\LocalMachine\My` on the
machine that runs the check, and its thumbprint registered on the application.

Nothing else needs a tenant. The Graph CSDL, the SDK cmdlet metadata and the shim are read from
disk or from the public metadata endpoint.

### Regenerate the shim before you capture a baseline

The shim re-exports every Graph SDK cmdlet the resources declare, and the baseline records the
cmdlet surface it sees. Two rules follow, and getting either wrong produces findings that describe
the tooling rather than the vendor.

1. **A change to any resource's cmdlet set needs `Utilities/New-M365DSCGraphShimModule.ps1` re-run.**
   Switching a resource to a beta cmdlet noun leaves the old wrappers behind and the new ones
   absent, which the check reports as `SHIM-MISSING` at `breaking` severity. The QA test
   *Every declared Graph cmdlet has a shim wrapper* fails first, so run the QA suite before the
   check. The generator now warns with the list of cmdlets it could not map.
2. **Regenerate the shim before `-UpdateBaseline`, never after.** A baseline captured against the
   old cmdlet surface disagrees with the regenerated `function-signatures.json` on every parameter
   type, which surfaces as a wave of `VND-PARAM-TYPECHANGED` and `VND-CMDLET-REMOVED` that clears
   on the next capture.

## Applying findings from a working copy

`Update-M365DSCResourceFromDrift` takes one finding at a time and is the function to reach for when
you want to watch what happens.

```powershell
$drift = Get-Content ./Utilities/ApiSurface/api-drift.json -Raw | ConvertFrom-Json

foreach ($finding in ($drift.findings | Where-Object { $_.autoFixable }))
{
    Update-M365DSCResourceFromDrift -Finding $finding -SkipUnitTest
}

& ./Utilities/Build-Microsoft365DSC.ps1 -SkipSchemaCache
```

`-SkipUnitTest` plus one rebuild afterwards is the right shape for a batch. Without it every finding
pays for its own Pester run against classes that are one rebuild out of date.

`Invoke-M365DSCApiSurfaceUpdate` is the whole path: it selects the findings, creates the branch,
applies, rebuilds once, runs the unit test of every touched resource, rolls back the resources whose
tests fail, commits, and opens the pull request.

```powershell
Invoke-M365DSCApiSurfaceUpdate -FindingId 'RES-ENUM-STALE:AADFilteringPolicy:Action' -NoPullRequest
```

`-NoPullRequest` stops after the commit. `-Interactive` asks before each finding.

## What may be applied without a human

Only two shapes, and only when the finding carries `autoFixable: true`:

- `RES-ENUM-STALE`, a `ValidateSet` that is a strict subset of the vendor enum. The fix is
  **append only**. A declared member the vendor dropped is kept and no member is recased, because
  removing one would reject a configuration that works today.
- `RES-PROP-MISSING` for a scalar or enum property. Two edits, both required: the `[DscProperty()]`
  declaration and the matching entry in the `Get()` result hashtable. A declaration without the
  hashtable entry exports as null forever, so the verification refuses it.

## Properties below the entity

A resource that flattens a complex type declares its members as scalars, so `GrantControlOperator`
carries `grantControls.operator`. The comparison used to look at the entity level only, which left
a member the vendor added inside such a container invisible to every resource level finding.

`RES-PROP-NESTED` closes that. The walk descends into a container the resource has proven it
flattens, meaning two of its members matched a declared property, and reports the unmatched
siblings. Two matches rather than one is deliberate: a resource that resolves a related object by
display name matches exactly one member of it and flattens nothing, and one match would then drag
in every property of the related entity.

The finding is never auto-fixable, because the name a resource would give a flattened member
cannot be derived. It carries `info`, rising to `warning` when the baseline did not hold the
property, and its id concatenates the whole path, so `sessionControls.signInFrequency.frequency`
reads as `SessionControlsSignInFrequencyFrequency`. A complex member is a container rather than a
setting and is not reported, nor is one the service owns.

Two things keep work that is already done out of the section.

- **A member another resource on the same vendor type declares.** Two resources over
  `deviceManagement` each cover part of `settings`, and neither should read the other's half as a
  gap. Every resource bound to a type contributes its declared names to one set the nested branch
  consults.
- **A `vendorPath` on an `excludedProperties` entry.** A resource that renames a flattened member
  beyond what the name matcher can derive states the path on the entry, and the comparison then
  treats it as matched. `AADConditionalAccessPolicy` needs it for the three flattened session and
  application members it carries under unrelated names.

```json
{
  "name": "SignInFrequencyInterval",
  "reason": "Accepted",
  "vendorPath": "sessionControls.signInFrequency.frequencyInterval",
  "note": "Flattened from sessionControls.signInFrequency.frequencyInterval"
}
```

Three things take auto-fixability away from a finding that would otherwise carry it.

- **A `Deferred` entry in the resource's `excludedProperties`.** The finding stays on the report at
  `info` and is listed under `Needs a decision`, never offered for a tick.
- **A match below the entity.** `Resolve-PropertyName` accepts a suffix of a flattened path, so a
  declared `State` can land on `reportSuspiciousActivitySettings.state`. That is a guess about
  which container the resource flattened. The evidence carries `match.level` and `match.rule` so
  the guess can be read.
- **A read-only vendor property.** `match.isReadOnly` says so, and appending its enum members to a
  `ValidateSet` would widen a property the service owns.

Everything else needs `-AllowNonAutomatic` and produces a scaffold a human finishes:
`RES-PROP-ORPHANED` marks the property deprecated and comments out its `Get()` entry rather than
deleting it, and `RES-TYPE-MISMATCH` re-renders the declaration from the vendor model.

`VND-CMDLET-REMOVED`, `VND-CMDLET-REROUTED` and every `CAT-` code are refused even under the
override. A cmdlet change is resource-level rework a scaffold cannot help with, and a settings
catalog resource is written by a template: pointing the property splicer at one corrupts it, so
`Update-M365DSCResourceFromDrift` throws and names `New-M365DSCResource` instead.

**`-AllowNonAutomatic` is local only.** It throws when `GITHUB_ACTIONS` is set, and the apply
workflow never passes it.

## Read-only properties

`RES-PROP-READONLY` names a vendor property the CSDL annotates read only, or one the
`serviceManagedProperties` list claims. Neither is a gap a resource can close, and 561 of them
were on the report before they were written down.

`globalReadOnlyProperties` in `exclusions.json` drops the names that behave the same way on
every type carrying them: the timestamps and author stamps the directory writes, the content
version pair the app upload sequence owns, and `SupportsScopeTags`, which Graph computes from
whether the underlying configuration accepts a scope tag assignment. The suppression is gated on
the code, so the same name still reads as a gap on a type whose CSDL leaves it writable.

Everything else is a per-resource judgement and lands in that resource `excludedProperties` under
reason `ReadOnly`, noted with the type it was read off.

## Two properties held back

Both stay on the report on purpose. Neither is a mistake in the checker, and neither fits a
one-line note in `excludedProperties`.

`OnPremisesSyncEnabled` on `AADTenantDetails` is writable, and Microsoft documents
`Update-MgOrganization` with `onPremisesSyncEnabled = $false` as the supported way to turn
directory synchronization off. The blast radius is what disqualifies it as an ordinary property.
Sending false converts every synced user and group to cloud only, clears `DnsDomainName`,
`NetBiosName`, `OnPremisesDistinguishedName`, `OnPremisesSamAccountName` and
`OnPremisesUserPrincipalName`, and locks the tenant out of re-enabling synchronization for 72
hours. The resource is a singleton that sends every bound property in one PATCH, so an export
taken after synchronization was turned off carries false into any configuration built from that
tenant. Sending true only stamps the flag, since synchronization itself starts when Entra Connect
or Cloud Sync runs. Whatever shape an implementation takes needs an explicit opt-in a normal
export cannot produce, and it has to keep the value out of exported configurations.

The `O365Group` members are the second. `O365Group` and `AADGroup` both sit on the `group`
entity and their property sets overlap, so deciding which resource owns a member, and whether a
mail-enabled group even exposes it, is a question about the split between the two resources
rather than about any single property.

## The GitHub path

### The weekly check

`.github/workflows/API Surface Check.yml` runs on `0 0 * * 6`, the night from Friday to Saturday,
and on demand through `workflow_dispatch`. It installs the pinned dependencies, builds, generates
the schema cache, downloads the previous run's `api-drift` artifact so `firstSeen` carries forward,
runs the check, uploads the new artifact and then creates or edits one Issue labeled `api-drift`.

It needs `contents: read`, `issues: write` and `actions: read`, and it only runs in the
`Microsoft365DSC/Microsoft365DSC` repository.

The body is rewritten in place on every run, and a run with no upstream change leaves it byte
identical. Nothing in it carries a timestamp, a run number or a run URL; those go to the run
summary. Ticks survive a rewrite as long as the finding is still reported.

### Repository secrets

Three, the same ones the integration workflows already use. Without them the check still runs and
downgrades to the offline capture, with a warning at the top of the Issue.

| Secret | Value |
| --- | --- |
| `RUNNERAPPID` | The application (client) id of the registration. |
| `RUNNERTENANTID` | The tenant **domain name**. |
| `RUNNERCERTIFICATETHUMBPRINT` | The thumbprint of a certificate installed in `Cert:\LocalMachine\My` on the runner. |

The check probes for that certificate first and records the result in the environment, so a missing
certificate is a downgrade rather than a failed job.

### Approving and applying

The first section of the Issue is the approval interface:

```markdown
## Auto-fixable  (tick, then comment /apply-drift)  (2)
- [ ] `RES-ENUM-STALE:AADFilteringPolicy:Action`
- [ ] `RES-PROP-MISSING:O365ExternalConnection:ConnectorId`
```

Tick the boxes, then comment `/apply-drift` on the Issue. Only the ticked ids are applied: the id is
the approval token, which is why it is deterministic and must never carry a date or an index.

Coverage is two lists rather than one. `COV-NO-RESOURCE` names a Graph cmdlet noun with full CRUD
that no resource covers. `COV-NO-SUBTYPE` names a concrete OData subtype of an entity type a
resource already models, which the noun list can never show: one noun serves every subtype of a
polymorphic entity. Both are delta scoped against `coverage.json`, the standing roadmap that
`-UpdateBaseline` rewrites, and both read `coverage-ignore.json`, where `modules` and `uriRoots`
retire a noun and `odataSubtypes` retires a subtype.

Everything below that first section sits in a collapsed block and is informational: what needs a
decision, the shim, the Intune settings catalog, read-only suggestions, coverage, vendor changes,
newer dependency versions and the unaccepted breaking findings. A finding that carries an
auto-fixable code but not the `autoFixable` flag, a `RES-PROP-MISSING` for a complex property for
example, is listed under `Needs a decision` rather than offered for a tick.

`.github/workflows/API Surface Apply.yml` requires **both** conditions, never either: the comment
carries `/apply-drift`, and the Issue carries the `api-drift` label. It then checks that the
commenter has `admin`, `write` or `maintain` permission, re-reads the Issue body at comment time
rather than trusting the artifact, downloads the drift report from the last successful check run,
applies, and opens the pull request. It needs `contents: write`, `issues: write`,
`pull-requests: write` and `actions: read`.

`workflow_dispatch` takes an `issue_number`, a comma separated `finding_id`, or both. A dispatch
naming neither is refused.

## What to take into account before you run it

- **Build first, and rebuild between an edit and a test.** Both are easy to forget and both make the
  result meaningless rather than wrong.
- **A scalar addition normally reverts itself.** The applier writes the declaration and the `Get()`
  entry and nothing else. The resource unit test needs the new property in the API mock and in every
  `Context`, and `Tests/QA/Microsoft365DSC.ExampleQuality.Tests.ps1` needs an `Examples/Resources`
  entry. Neither is something a splice can decide, so verification fails and the finding is reported
  as scaffold and review. That is the intended outcome, and it means the scalar path is not truly
  unattended.
- **Sixteen of the 531 resources cannot take a new property automatically.** Fourteen resolve no
  `Get()` result hashtable and two resolve two candidates. They are refused with a message naming
  the reason rather than guessed at.
- **`isReadOnly` is a floor, not an answer.** Only a small number of CSDL properties carry the
  annotation, while many descriptions say "Read-only." in prose and carry none. A `RES-PROP-MISSING`
  for a property that is really read-only is possible, and reading the vendor description before
  approving is worth the minute it costs.
- **Run the check against a tenant before `-UpdateBaseline`.** The committed baseline carries the
  Exchange Online, Security and Compliance and settings catalog sections. Updating it from an
  offline run drops them and the next comparison reads the gap as removals. `-UpdateBaseline`
  refuses to write when this run skipped a workload the baseline holds, and names it. `-Force`
  overrides that, which is almost never what you want.
- **Do not build while a capture is connecting.** `Build-Microsoft365DSC.ps1` rewrites the class
  modules and the manifest, and a connect that imports Microsoft365DSC at that moment fails with
  `The given assembly name was invalid` and downgrades the run to offline.
- **`api-drift.json` and `api-drift.md` are run outputs**, gitignored. Both are written on every
  run, which is what keeps the Markdown from describing an older comparison than the JSON beside
  it. In CI they survive only as the `api-drift` artifact, which is where `firstSeen` is carried
  forward from.
