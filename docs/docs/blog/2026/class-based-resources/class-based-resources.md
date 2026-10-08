---
date: 2026-09-14
---

# From Script-Based to Class-Based: Rebuilding Every Microsoft365DSC Resource (Part 1)

<img src="../../../images/FabienTschanz.jpg" style="width:75px;border-radius:50%;border:3px solid black;float:left;" />
<div style="position:inherit;padding-top:15px;"><span style="float:left;padding-left:15px;"><b>by <a href="https://www.linkedin.com/in/fabien-tschanz">Fabien Tschanz</a><br />
September 14th, 2026</b></span></div>

<br/>
<br/>

## Introduction

Microsoft365DSC ships more than 530 resource types across a dozen workloads, and until this release, every single one of them was a script-based DSC resource: a `.psm1` file with `Get-TargetResource`, `Set-TargetResource` and `Test-TargetResource` functions, plus a (semi-)hand-written `.schema.mof` file describing the schema. That design served the project for over seven years. With the October 2026 release, that is about to change: all 530+ resources are now class-based DSC resources, the MOF schema files have been deleted, and the module is ready for the PowerShell 7 and DSCv3 world.

This was the largest architectural change in the history of the project. It touched more than 1,500 files with ~400,000 lines of resource code, removed roughly 122,000 of them, and surfaced defects that had been sitting invisibly in the module for years. It also made two things noticeably slower: First, importing the module, and second, compiling a configuration. Getting those times back to where they belong turned into a second project of its own. So this story comes in three parts:

- **Part 1 (this post)** is about why we made the change, how we approached an automated conversion at this scale, the traps we ran into with the DSC engine, and what the conversion found in our own code.
- **[Part 2](./class-based-resources-part-2.md)** is about making the module and it's surroundings fast again. Import time, resource discovery, the DSCParser rewrite and the comparison engine, along with every layout we evaluated and rejected on the way.
- **[Part 3](./class-based-resources-part-3.md)** is about compiling configurations. Why MOF compilation broke, the fast compile host we built along with the tricks behind it, the rebuilt examples, what DSCv3 makes of all this, and the final numbers.

For everybody intimidated by the complex introduction, don't sweat it. Even if you have never written a class-based DSC resource before, we will start gradually so you'll understand the concepts step by step.

## Table of Contents

1. [What is the difference, actually?](#what-is-the-difference-actually)
2. [Why we did it](#why-we-did-it)
3. [Discussions in the community](#discussions-in-the-community)
4. [The engineering approach: measure before migrating](#the-engineering-approach-measure-before-migrating)
5. [Issue #1: How DSC actually discovers class-based resources](#issue-1-how-dsc-actually-discovers-class-based-resources)
6. [Issue #2: Import time explodes at scale](#issue-2-import-time-explodes-at-scale)
7. [Issue #3: There is no $PSBoundParameters in a class](#issue-3-there-is-no-psboundparameters-in-a-class)
8. [Issue #4: The bug that passed every test](#issue-4-the-bug-that-passed-every-test)
9. [Keeping the LCM alive](#keeping-the-lcm-alive)
10. [Converting 530+ resources without going insane](#converting-530-resources-without-going-insane)
11. [What the conversion found in our own code](#what-the-conversion-found-in-our-own-code)
12. [The rest of the toolchain](#the-rest-of-the-toolchain)
13. [Where part 1 leaves us](#where-part-1-leaves-us)
14. [The effort behind it](#the-effort-behind-it)

## What is the difference, actually?

A script-based DSC resource is really two files that have to agree with each other. The `.schema.mof` file declares the schema in MOF syntax - a language most PowerShell people never touch outside of DSC. Outside of PowerShell, it's mainly used to write WMI or CIM definitions:

```mof
[ClassVersion("1.0.0.1"), FriendlyName("AADAttributeSet")]
class MSFT_AADAttributeSet : OMI_BaseResource
{
    [Key, Description("Identifier for the attribute set...")] String Id;
    [Write, Description("Maximum number of custom security attributes...")] UInt32 MaxAttributesPerSet;
    [Write, Description("Present ensures the policy exists..."), ValueMap{"Present","Absent"}, Values{"Present","Absent"}] string Ensure;
    ...
};
```

Based off of the schema file, the `.psm1` file then declares the *same* properties again - three times, once per function - as parameters of `Get-TargetResource`, `Set-TargetResource` and `Test-TargetResource`. For `AADAttributeSet`, a resource with 13 properties, that means 467 lines of code, most of it repeated parameter blocks. Nothing except discipline keeps the MOF and the three parameter blocks in sync. When they drift apart, DSC believes the MOF and the code believes the parameters, and you get bugs you didn't think were possible. For that exact reason, we implemented a CI pipeline check to let us know if those two files differed in any way. But of course it's easier if you don't have to maintain two separate files.

That's where class-based resources come into play. Such a resource collapses all of that into one definition. The class *is* the schema:

```powershell
[DscResource()]
class AADAttributeSet : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identifier for the attribute set that is unique within a tenant...')]
    [System.String] $Id

    [DscProperty()]
    [ValidateRange(1, 500)]
    [System.Nullable[System.UInt32]] $MaxAttributesPerSet

    [DscProperty()]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    # ... authentication properties ...

    [AADAttributeSet] Get() { ... }

    [void] Set() { ... }

    [bool] Test() { ... }
}
```

Each property is declared exactly once. Validations like `[ValidateRange(1, 500)]` live on the property. The property description - which feeds our generated documentation - lives on the property too, as a `[System.ComponentModel.Description]` attribute. The same resource is now 282 lines instead of 467, and there is no MOF file that can drift out of sync, because there is no MOF file to begin with.

## Why we did it

There were three main problems that drove this, and all three came out of GitHub issues rather than architectural aesthetics.

**The nested CIM problem.** Issue [CIM inference not working through LCM and DSCv3 #6120](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/6120) documented that `Get-DscConfiguration` fails for any of our resources with nested complex properties, both through the classic LCM and through DSCv3, with `Could not infer CimType from the provided .NET type`. Script-based resources return plain hashtables, and the CIM serializer cannot infer types from them if the nesting level is greater than 2. Or it may omit those nested hashtables altogether. Class-based resources return typed instances, and the problem disappears structurally.

**Triple property definitions.** As raised in the original proposal ([Proposal - Change to class based resources #6202](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/6202)), every property was defined four times: once in the MOF and once per `*-TargetResource` function. Beyond the maintenance burden, this is where an entire class of "MOF and psm1 drifted apart" bugs came from - more on what we found later in this post.

**The PowerShell 7 and DSCv3 future.** DSCv3 has no Local Configuration Manager, but it can drive class-based PowerShell resources through its PowerShell adapter (`Microsoft.Adapter/PowerShell` since DSC v3.2) running on PowerShell 7. Script-based MOF resources only run through the Windows PowerShell adapter there, which needs an elevated Windows PowerShell 5.1 and WinRM. Combined with our Docker images and the C# core engine we shipped earlier this year, class-based resources are the piece that lets the whole module run cross-platform on PowerShell 7 - the ultimate goal we strived for with this release. How far DSCv3 actually gets with the module today is a story of its own (see part 3).

## Discussions in the community

This decision was not made by just one person alone. The discussion stretched over almost two years and three long issue threads, and I think it is worth showing both sides, because the raised concerns around the entire thing were legitimate.

The debate started in issue [Update-M365DSCDependencies: ... does not support PowerShell Core #5433](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/5433) in late 2024, which began as a dependency-installation bug and turned into a 42-comment strategy thread about the PowerShell 5.1 dependency. Users running PowerShell 7-only pipelines told us that being pulled back to Windows PowerShell was "perplexing". At the same time, [@Borgquite](https://github.com/borgquite) - whose deep knowledge of the DSC platform shaped much of this discussion - made the strongest case *against* a rewrite:

> "Switching from script-based to class-based is a classic time-consuming sink hole of programmers' time - a lot of work for no real benefit at the end for actual end-user SysOps / DevOps roles."

He also insisted on retaining support for the classic LCM, because for hybrid environments that combine Microsoft 365 with on-premises Active Directory and Exchange, the PowerShell 5.1 LCM is "the only officially supported game out there", and DSCv3 includes only a fraction of its orchestration features. Both points were correct. My own position at the time was somewhere in the middle: "Rewriting everything to class-based resources would be a real pain, but it probably needs to happen sooner or later."

The formal proposal came in June 2025 with issue [#6202](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/6202). Early concerns got resolved one by one: [@ykuijs](https://github.com/ykuijs) raised Pester testability of classes, which Borgquite confirmed is solved in Pester 5. [@salbeck-sit](https://github.com/salbeck-sit) raised the inability to distinguish "explicitly set to `$null`" from "not set" - a real limitation we accepted as a niche case, and I will explain why in the `$PSBoundParameters` section. In August 2025, after weeks of prototyping, I was finally able to get a working prototype, and [@indented-automation](https://github.com/indented-automation) then contributed a detailed code review of the base class that improved the design that shipped (the per-type initialization tracking in `M365DSCResourceInfo` is a direct result of that review).

There was even a late twist: in February 2026, the question came up whether Microsoft's new unified Tenant Configuration Management API would make all of this moot. Our conclusion, shared by the people in the thread, was that it does not: it covers roughly 300 resource types against our 530+, requires a single app registration with no workload separation, and offers no arbitrary delta reporting. Microsoft365DSC stays, meaning it was still worth investing in its foundation.

## The engineering approach: measure before migrating

You do not convert so many resources just like that. The project was structured in phases, and the first phase was a series of spikes, each designed to kill the project cheaply if a hard blocker existed:

```mermaid
flowchart TD
    P0["Phase 0 - Spikes<br/>scale, discovery, back-compat,<br/>PS 5.1 dispatch"] --> G{Gate:<br/>all blockers retired?}
    G -- no --> STOP["Stop, keep script-based"]
    G -- yes --> P1["Phase 1 - Foundation<br/>base class, build system, factory"]
    P1 --> P2["Phase 2 - Proof of concept<br/>4 hand-converted resources"]
    P2 --> P3["Phase 3 - Converter<br/>AST-based, tested against the 4 fixtures"]
    P3 --> P4["Phase 4 - Bulk conversion<br/>all resources, workload by workload"]
    P4 --> P5["Phase 5 - Ecosystem<br/>export engine, docs, QA, CI"]
    P5 --> P6["Phase 6 - Cutover<br/>delete all MOF files, major version"]
    P6 --> P7["Phase 7 - Performance<br/>import, compile, compare, DSCv3<br/>(parts 2 and 3)"]
```

The four proof-of-concept resources in Phase 2 were chosen to span the difficulty range: `AADAttributeSet` (simple), `AADGroup` (complex types), `AADAccessReviewDefinition` (deeply nested complex types) and `IntuneSettingCatalogCustomPolicyWindows10` (the settings catalog shape). The converter in Phase 3 was then built against those four known-good outputs as fixtures, where every converter change had to reproduce them byte-for-byte before it was allowed near the other resources.

The spikes earned their keep immediately, because two of them invalidated the original design. Let's take a look at the four biggest issues in the order we hit them.

## Issue #1: How DSC actually discovers class-based resources

Our first attempt placed each class in its own file under `DscResources/MSFT_<Name>/`, mirroring the script-based layout, which felt like the natural thing to do and took about an hour to set up. But `Get-DscResource` found nothing. Not an error, not a warning, just zero resources, and I remember staring at that empty output for a good while before I believed it.

The reason lives in the PowerShell engine source (`CimDSCParser.cs`): DSC only looks for `[DscResource()]` classes in a module's `RootModule` and in the entries of `NestedModules`, exactly one level deep. There is no filesystem walk for classes, very much unlike with mof files. The `DscResources\*` directory scan that does exist only ever looks for `.schema.mof` files. On top of that, `DscResourcesToExport` in the manifest is mandatory - if it is absent, discovery returns immediately with zero resources and each file is parsed in complete isolation, so a class in file A cannot see a class in file B at discovery time.

One more discovery rule cost us the most debugging time of the entire project: **if your module manifest has an explicit `FunctionsToExport` list, every class-based resource silently disappears from `Get-DscResource`.** Not an error, not a warning, just zero resources, on both PowerShell editions. The key must be absent or `'*'`. Of course we verified this:

| `FunctionsToExport` | `Get-DscResource` result |
| --- | --- |
| key absent | all resources found |
| `'*'` | all resources found |
| an explicit list | **0 resources, no error** |

Because it was so absurd we couldn't believe it at first, we went back to it a couple of weeks ago with the engine source open. The reason was that an explicit export list is one of the things every module author is told to write, and it makes `Get-Module -ListAvailable` a lot faster. The mechanism, the cost of leaving the key out, and why `Get-DscResourceV2` does not rescue you either from this strange issue, are in [part 2](./class-based-resources-part-2.md#the-functionstoexport-trap-revisited).

![Screenshot of a terminal showing `Get-DscResource -Module Microsoft365DSC` returning nothing, next to the manifest's `FunctionsToExport` line.](Get-DscResourceV2_FunctionsToExport_No_Results.png)

### The second manifest trap: `ScriptsToProcess`

There is a second manifest key that breaks class-based resources, and it is even nastier than the first one, because it leaves discovery completely intact. **If your manifest declares `ScriptsToProcess`, the LCM cannot instantiate your class-based resources.** `Get-DscResource` still lists every resource, so by every check you would think to run, the module looks healthy. Then you apply a configuration and get:

```text
Could not find the type of DSC resource class IntuneAccountProtectionLocalUserGroupMembershipPolicy.
    + FullyQualifiedErrorId : ClassTypeNotFound
```

or, through `Invoke-DscResource`, the equally unhelpful:

```text
The property 'DisplayName' cannot be found on this object. Verify that the property exists and can be set.
```

Reduced to a minimal two-class module, the two keys fail in completely different places:

| manifest key | `Get-DscResource` | `Invoke-DscResource` / LCM |
| --- | --- | --- |
| neither key present | all resources found | works |
| `FunctionsToExport` = explicit list | **0 resources, no error** | resource not found |
| `ScriptsToProcess` = any script | all resources found | **fails - "The property '&lt;Name&gt;' cannot be found on this object"** |

![Test-DscConfiguration Failing With ScriptsToProcess](Test-DscConfiguration_Failing_With_ScriptsToProcess.png)

It's worth understanding the mechanism because the error message points nowhere near the cause. To run a class-based resource, DSC builds a small script in a fresh runspace that boils down to `using module "<path to your .psd1>"` followed by `[YourResource]::new()`, and takes the first object that comes back. With `ScriptsToProcess` present, that `using module` no longer surfaces the module's classes - the type does not resolve, nothing is returned, and DSC then dutifully assigns your configuration's property values onto `$null`. Hence a message about a missing property when the real failure was that the class was never even instantiated.

The fix is to stop using the key. `ScriptsToProcess` only exists to run something in the caller's session before the module loads. Instead, a nested module listed first does the same job without breaking class visibility:

![Test-DscConfiguration Succeeds Without ScriptsToProcess](Test-DscConfiguration_Succeeds_Without_ScriptsToProcess.png)

```powershell
# Microsoft365DSC.psd1
#
# ScriptsToProcess = @(                          # breaks class instantiation under the LCM
#   'Import-M365DSCDllLoaderModule.ps1',
#   'Show-PwshWarning.ps1',
#   'Update-MaximumFunctionCount.ps1'
# )

NestedModules = @(
    'Modules/M365DSCInit.psm1',                  # runs the three scripts instead
    ...
)
```

with `M365DSCInit.psm1` doing nothing more than invoking them in order:

```powershell
& (Join-Path $PSScriptRoot '../Import-M365DSCDllLoaderModule.ps1' -Resolve)
& (Join-Path $PSScriptRoot '../Show-PwshWarning.ps1' -Resolve)
& (Join-Path $PSScriptRoot '../Update-MaximumFunctionCount.ps1' -Resolve)
```

For our case, the ordering matters: it has to be the first entry, because the DLL loader has to run before any class module that depends on the compiled assemblies is parsed.

The frustrating part is that every cheap check passes. The module imports, `Get-DscResource` lists all 530+ resources, configurations compile to MOF without complaint - and then the LCM reports a missing class or a missing property. If you are building a class-based module and see `ClassTypeNotFound` for a resource you can plainly see in `Get-DscResource`, check your manifest for `ScriptsToProcess` before you look anywhere else.

## Issue #2: Import time explodes at scale

The original plan concatenated all 530+ classes into one big root module at build time. Spike 1 generated a sample with all resources plus more than 470 complex-type classes with stub bodies, and measured a cold `Import-Module`:

| Layout | Import time | Discovery time |
| --- | --- | --- |
| Current, MOF-based (baseline) | **4.50 s** | 12.90 s |
| One consolidated module, PowerShell 7 | **41.1 s** | 13.3 s |
| One consolidated module, Windows PowerShell 5.1 | 39.6 s | 16.9 s |
| Split across 4 nested modules | 7.44 s | 10.10 s |
| **Split across 16 nested modules** | **6.95 s** | 11.95 s |
| Split across 32 nested modules | 8.92 s | 16.52 s |

41 seconds to import the module was obviously unshippable, and for a day or two it looked like the whole project might end right there. Profiling showed the time was not parsing, which took 0.47 s for the full set, but .NET type creation, and that grows roughly with the *cube* of the number of classes in a single parse unit: 522 classes in one file import in 5.4 s, 772 in 21 s, 1007 in 41 s. We tried the obvious diets first, like dropping every description attribute, which only saved 9 of the 41 seconds, dropping `[ValidateSet]` saved nothing, and removing the base class saved nothing either. The only lever that works is splitting the parse unit.

So the shipping layout splits the generated classes across nested modules, grouped by workload, which lands at 6.95 s against the 4.50 s script-based baseline. An import time increase of rougly 50% is a price we considered acceptable for what we get in return:

```mermaid
flowchart LR
    subgraph Source["Source (in git, per resource)"]
        R1["DscResources/MSFT_AADGroup/<br/>MSFT_AADGroup.psm1"]
        R2["DscResources/MSFT_EXO.../<br/>MSFT_EXO....psm1"]
        R3["... 535 resource files ..."]
        B["DscResources/_Base/<br/>M365DSCResourceBase.psm1"]
    end
    BUILD["Build-Microsoft365DSC.ps1<br/>(AST extraction, dedup, ordering)"]
    subgraph Shipped["Generated (shipped in the module)"]
        S["Classes/_Shared.psm1<br/>base class + factory"]
        T["Classes/_Types00..NN.psm1<br/>complex types, one bucket per component group"]
        P0["Classes/Part00.psm1"]
        P1["Classes/Part01.psm1"]
        PN["... one part per workload ..."]
        M["Microsoft365DSC.psd1<br/>NestedModules + DscResourcesToExport"]
    end
    R1 --> BUILD
    R2 --> BUILD
    R3 --> BUILD
    B --> BUILD
    BUILD --> S
    BUILD --> T
    BUILD --> P0
    BUILD --> P1
    BUILD --> PN
    BUILD --> M
    P0 -. "using module" .-> S
    P1 -. "using module" .-> S
    PN -. "using module" .-> S
    P0 -. "using module" .-> T
    P1 -. "using module" .-> T
    PN -. "using module" .-> T
```

The per-resource source files stay in git, so diffs, history and pull requests remain per-resource, just like before. Only the shipped part files are generated. If you contribute a resource, you still edit one file in one folder, and the build system does the rest.

## Issue #3: There is no $PSBoundParameters in a class

A script-based resource gets `$PSBoundParameters` for free: the set of parameters the caller actually passed. Microsoft365DSC leans on that heavily, with almost 7,000 call sites across the module depending on it, because drift detection must only compare the properties a configuration specifies. A class has no such thing. PowerShell materializes *every* property on instantiation: value types become `0` (for integers) or `$false` (for booleans), reference types become `$null`. The class cannot natively tell "the user did not specify `MaxAttributesPerSet`" (which is an Int32) apart from "the user specified `0`".

I managed to get a workaround going, with my first working prototype tracking assignments through PowerShell script properties. It worked very well in every test I could think of, right up until the real LCM executed it and got back empty objects every single time. It took weeks of the summer of 2025 to isolate the reason: **DSCv1.1 (the LCM) populates class-resource instances by writing the CLR backing fields directly through reflection.** The PowerShell member layer, where any of my tracking logic would live, is simply never invoked. Once we understood that reflection is the transport, we managed to find a way around it.

The shipping mechanism now has two halves:

1. **Value-type properties are nullable.** Every `[System.Boolean]` became `[System.Nullable[System.Boolean]]`, every `[UInt32]` became `[System.Nullable[System.UInt32]]`. Reflection cannot be observed, so nullability carries the signal instead: a property that is `$null` was not specified, anything else was. DSC accepts `Nullable[T]` on both editions and still reports the property as its underlying type. There is one exception though, and the DSC engine enforces it the moment the class is defined: A `[DscProperty(Key)]` cannot be nullable (which should be self-explanatory).

2. **`GetBoundParameters()` on the base class** returns every DSC property that is not `$null`, which behaves identically whether the value arrived through reflection (from the LCM) or through direct assignment (from our export engine or tests). It is the drop-in replacement for `$PSBoundParameters` at all 7,000 call sites.

One trade-off @salbeck-sit called out in the proposal thread however is that you can no longer say "ensure this attribute is explicitly `$null`", because `$null` now means "not specified". We didn't have any resource that needed to distinguish between these two states, so we accepted it.

## Issue #4: The bug that passed every test

Our 530+ converted unit test suites all run inside the module's scope, since PowerShell class types are not visible outside the module that defines them. During the conversion, every suite was green, and for a happy afternoon everything looked done. Then we ran a single resource through `Invoke-DscResource`, the way the real engine does, and got back empty strings for every property. Every single one.

The cause was the interaction from Issue #3: an intermediate version of the base class still routed property access through a private backing store. Called from inside the module, the PowerShell member layer was engaged and everything worked. Called by the DSC engine, reflection wrote the CLR fields directly - a place the class never read - and read them back from a place the class never wrote:

| Path | Result of `Invoke-DscResource -Method Get` |
| --- | --- |
| Called from inside the module (like every unit test) | `Id='abc-123' DisplayName='resolved'` |
| Called through the DSC engine | `Id='' DisplayName=''` |

Every converted resource was silently non-functional under the LCM while passing its entire test suite. The fix was to make the property layer write through to the real CLR properties with no private store.

There is a related lesson for anyone writing tests against generated modules. Pester loads the *built* `Classes/Part*.psm1` files, not the per-resource sources under `DscResources`. Edit a resource, forget to build, and you are testing last week's code with a green result. Our test helper now refuses to run against a stale build.

## Keeping the LCM alive

The classic LCM runs on Windows PowerShell 5.1 only, but our module code targets PowerShell 7-only. To get everything moving, we implemented a forwarding mechanism in the base class:

```mermaid
sequenceDiagram
    participant LCM as LCM (Windows PowerShell 5.1)
    participant R as AADGroup instance (5.1)
    participant PS7 as PowerShell 7 session
    LCM->>R: Get() via reflection
    R->>R: RequiresPowerShellCore() -> true
    R->>PS7: InvokeInPowerShellCore('Get')<br/>parameters as hashtable
    PS7->>PS7: real Get() body runs<br/>against Microsoft Graph
    PS7-->>R: result flattened with ToHashtable()
    R->>R: FromHashtable(result)
    R-->>LCM: typed AADGroup instance
```

Each generated method opens with a small guard: on PowerShell 7 it falls straight through to the real body with zero overhead, and on 5.1 it relays into a PowerShell 7 session, rebuilding the typed result from a hashtable. Why hashtables on the wire? Because a class instance does not survive PowerShell remoting serialization because it comes back as a `Deserialized.AADGroup` that cannot be cast back. Serializing the full reflection graph of an instance actually threw `OutOfMemoryException` at depth 16 in our spikes. The flattened hashtable is a couple of hundred characters and depth-insensitive.

We also verified that **existing configurations compile unchanged**. A `Configuration` block written against the old resources, including the MOF-style embedded instance syntax for complex properties, compiles identically against the class-based resources on both PowerShell editions:

```powershell
AADGroup 'MyGroup'
{
    DisplayName = 'Finance'
    Owners      = @(
        'owner-1'
    )
    ...
}
```

## Converting 530 resources without going insane

Hand-converting 530 resources was never an option. Even at 10 resources a day, it would take almost two months, so `Utilities\Convert-M365DSCResourceToClass.ps1` handles the conversion through the PowerShell abstract syntax tree.

An earlier regex-based prototype appeared to work until we checked the output line by line and found silent failures. The property regex read MOF array markers on the type instead of the name, so every array property quietly became a scalar. The variable rewrite from `$ApplicationId` to `$this.ApplicationId` had no word boundary, meaning that `$ApplicationIdValue` silently became `$this.ApplicationIdValue`.

Two defects like these warn against the approach, not just the individual bugs. The AST converter walks real language elements, so a `VariableExpressionAst` with a schema-property name becomes a `$this.` member access and the telemetry region becomes `$this.AddTelemetry('Get')`. The 2,130 shim blocks then become one base-class guard. Anything the converter does not recognize lands in a per-resource JSON report for dedicated review instead of being guessed at.

The AST approach matters most in details like `Get-TargetResource`, which appears in three distinct shapes and must convert differently. The export path calls it with a per-item key through `Get-TargetResource @params` inside a loop over tenant groups. Rewriting that to a bare `$this.Get()` would make 18 resources silently export with a `$null` key and query the workload with nothing, so the converter identifies this shape and emits `$this.GetForExport($params)` where the loop context needs it.

Every resource source file also opens with:

```powershell
using module ..\_Base\M365DSCResourceBase.psm1
```

Without it, opening a resource in VS Code shows parser errors throughout the file. These come from the parser, not PSScriptAnalyzer, and no editor setting can suppress them. With the line, a converted file parses with zero errors. The build structurally strips it by emitting only the class text. A QA test enforces the zero-error parse for every source file.

![Parsing difference between resources with using module line and without it](Parse_Resource_Error_Difference_Using_Module.png)

## What the conversion found in our own code

The conversion also became the most effective audit the codebase has ever had. A MOF silently tolerates almost anything, while a class either compiles and validates or it does not. Once the converter made that distinction unavoidable, it surfaced defects that had shipped for years, including some from before I joined the project:

- **16 resources could never say "Absent".** Their MOF declared `ValueMap{"Present"}` for `Ensure`, while their code assigns `'Absent'` on the not-found path. Function resources did not validate values assigned to their result hashtables, so this worked by accident. The class property immediately triggered `[ValidateSet]`. The MOFs were wrong and the code was right, so we fixed the MOFs (or rather the allowed values for the `Ensure` property).
- **Two resources were silently invisible.** Our MOF-parsing schema generator split quoted ValueMap entries on internal commas. `ValueMap{"companyPortal,email"}` produced duplicate values, and DSC silently drops the entire resource from `Get-DscResource` when it finds a duplicate `[ValidateSet]`. `IntuneDerivedCredential` had this defect.
- **112 unit tests constructed the wrong type.** Tests built complex values with `New-CimInstance -ClientOnly`, which validates neither the class name nor the property names. In 112 places, the class name in the test did not match the type the property actually declares. Nobody noticed because nobody ever checked it (we all assumed it as correct since it was working). A typed class cast checks.
- **93 drift tests were passing for the wrong reason.** Before the comparison-engine conversion, 93 tests asserted "drift detected" and got `$true` because complex-object drift was not detected at all. The comparer fell through on unknown types and reported whatever the test expected. After the conversion and comparer fixes, that number is 0.

## The rest of the toolchain

A conversion of this size pulls a lot of supporting parts along with it. These are a few that mattered most:

**Schema generation reflects instead of parsing.** `SchemaDefinition.json` feeds the drift report and generated documentation. It used to come from a regular-expression walk over `.schema.mof` files. Since those files no longer exist, `Utilities/New-M365DSCSchemaFromClasses.ps1` instead reflects over the built classes in a child process. The metadata cannot drift from the code like a hand-maintained MOF could.

**Relations moved into C#.** Export dependency handling used to walk PowerShell objects and scaled quadratically with exported instances. It now lives in the `Microsoft365DSC.Relations` assembly with `DependsOn` injection and generated-configuration rewriting. We added new relations between resources, support for `like` and `notlike` in relation conditions, and `$_` as a condition subject for values inside simple arrays. The work also exposed other defects, including relations resolving without `-IncludeDependencies` and hashtable-valued properties never matching because they were walked as sequences.

**Helper functions became class methods.** A converted resource with private helper functions kept them at module scope, a namespace shared by every resource in the generated part file. The helpers are moving to hidden class methods, where they belong to the instance and can reach `$this`. `Get-CompareParameters` moved too, and every call site now follows the class. Part 2 measures what those hidden methods cost at import time.

**CI knows about the build.** Every workflow that touches the module builds the class modules, C# assemblies, and schema cache in that order. Validation also gained two guards the QA suite could not provide: no `.schema.mof` file may reappear under `DscResources`, and every resource file must declare a `[DscResource()]` class with no `*-TargetResource` functions. The old MOF-based wiki workflow can finally be retired.

**New properties land in one place.** Adding `EwsAllowedAppIDs` to `EXOOrganizationConfig` or `CustomSecurityAttributes` to `AADUser` used to require a MOF edit plus three parameter blocks. It now needs one property declaration and, for a complex type, a small class next to the resource. There are no longer three copies to synchronize or three places for a typo.

## Where part 1 leaves us

At the end of the cutover, the module was *correct*. Every resource was a class, every unit test suite was green for the right reasons, the LCM round trip worked, and existing configurations compiled. But after the first benchmark, it revealed two things we could not ignore:

- `Import-Module Microsoft365DSC` took about 5 seconds on PowerShell 7 and closer to 6 on Windows PowerShell, against 1.7 and 2.0 seconds for the last script-based release. Worse, every additional runspace paid roughly 3 seconds again, and the LCM opens one per resource call.
- Compiling a configuration went from a few seconds to somewhere between 30 and 55 seconds for a real tenant export, and to 40 to 50 seconds even for a single-resource example. The DSC engine now had to create 1,000 .NET types before it could parse a single resource statement.

Both made the module unshippable as it stood, both needed engineering beyond tuning. [Part 2](./class-based-resources-part-2.md) and [part 3](./class-based-resources-part-3.md) follow those paths.

## The effort behind it

From the first PowerShell Core thread comment in November 2024 to this release took just under two years of discussion, prototyping, and implementation. The proposal itself dates from June 20th, 2025, but much of that time was not spent writing the converter. The spikes that rejected the consolidated-module layout, the weeks spent isolating why the LCM received empty objects, and the discovery that `FunctionsToExport` and `ScriptsToProcess` silently break class-based resources in different ways each took days or weeks. Once the foundation was measured and solid, the conversion moved from its first hand-converted resource to all 530 converting and running cleanly within just a couple of weeks.

The community really shaped this work. Borgquite's insistence on LCM support guided the dispatch design. ykuijs and salbeck-sit stress-tested the proposal early. indented-automation's review improved the base class. ricmestre root-caused and fixed a DSCv3 adapter bug upstream. This is what an open-source project looks like.

That's all for this part. Stick around and continue with [part 2: making the class-based module fast again](./class-based-resources-part-2.md).
