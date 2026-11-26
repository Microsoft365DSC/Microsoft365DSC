# Configuration Fast Compile Host

## Table of contents

1. [Introduction](#introduction)
2. [The two compile paths](#the-two-compile-paths)
3. [Components](#components)

    1. [On the Microsoft365DSC side](#on-the-microsoft365dsc-side)
    2. [On the engine side](#on-the-engine-side)
    3. [The module name claim](#the-module-name-claim)

4. [The configuration document](#the-configuration-document)
5. [End to end flow](#end-to-end-flow)
6. [Stage 1: Wrapper and engine resolution](#stage-1-wrapper-and-engine-resolution)
7. [Stage 2: Text transformation](#stage-2-text-transformation)

    1. [Masking instead of parsing](#masking-instead-of-parsing)
    2. [Stripping the imports](#stripping-the-imports)
    3. [Joining next line braces](#joining-next-line-braces)
    4. [Rewriting bodies to hashtable literals](#rewriting-bodies-to-hashtable-literals)

8. [Stage 3: Schema cache and keyword registration](#stage-3-schema-cache-and-keyword-registration)

    1. [Module resolution](#module-resolution)
    2. [Resolution order](#resolution-order)
    3. [Cache content](#cache-content)
    4. [Registration](#registration)

9. [Stage 4: Execution](#stage-4-execution)

    1. [The adapter](#the-adapter)
    2. [The driver](#the-driver)

10. [Stage 5: Document assembly and MOF emission](#stage-5-document-assembly-and-mof-emission)
11. [Stage timing](#stage-timing)
12. [Difference to the classic PSDesiredStateConfiguration path](#difference-to-the-classic-psdesiredstateconfiguration-path)
13. [Fallback](#fallback)
14. [Building and shipping the schema cache](#building-and-shipping-the-schema-cache)
15. [What to take into account](#what-to-take-into-account)
16. [Running it by hand](#running-it-by-hand)

    1. [Compile an export](#compile-an-export)
    2. [Compile a script that only declares a configuration](#compile-a-script-that-only-declares-a-configuration)
    3. [Keep the cache up-to-date](#keep-the-cache-up-to-date)
    4. [When something looks wrong](#when-something-looks-wrong)

## Introduction

A tenant export is one PowerShell script. `M365TenantConfig.ps1` declares a single `Configuration`
block, and inside it sit as many resource instances as the tenant happens to have, which for a real
customer is regularly several hundred. Between that script and anything the Local Configuration
Manager can act on stands one step: compiling it into MOF documents.

Almost nothing about that step is genuinely hard work. Writing a few hundred instances of MOF text is
milliseconds. What costs real time is DSC resource discovery. Before the parser can accept
`AADGroup 'MyGroup' { ... }` as a resource statement, somebody has to have told the engine what an
`AADGroup` is, and the classic way of telling it is to import all 531 class based resources of
Microsoft365DSC. The engine does that while parsing, then the `Configuration` function does it again
at runtime, and a compile of a 726 instance export takes 30 to 55 seconds, 16 to 22 of them in the
parser alone.

The fast compile host removes that cost by never asking the question. It reads the keyword
definitions out of a line based JSON cache that was written once at build time, keeps the resource
module out of the process entirely, and produces MOF that is equivalent to the classic path after
normalization. The same 726 instance export compiles in 5 to 7 seconds in a fresh process and in 2 to
6 seconds in a session that has compiled before, with a working set of 190 to 320 MB instead of 0.5
to 1.2 GB. `Invoke-M365DSCConfigurationBuild` is the command Microsoft365DSC exposes for it, and it
picks the fast path on its own when the engine is installed.

This document follows a configuration document from that command to the written `.mof`, names the
component that owns each step, and points out where the fast path and the classic one part ways. It
does not walk through individual functions.

## The two compile paths

Both paths run the same compiler and end in the same MOF writer. The one thing they disagree about is
where resource keywords come from, and everything else in the table follows from that.

| | Classic path | Fast compile path |
| --- | --- | --- |
| Keyword source | Live import of every class based resource in the module | Line based JSON schema cache holding the same keyword definitions, one keyword deserialized on first use |
| Parse time cost | The parser sees `Import-DscResource` and imports the module while parsing, 16 to 22 seconds for Microsoft365DSC | The statement is removed before the text is ever parsed for real |
| Runtime cost | The `Configuration` function imports the same modules a second time | No import at all |
| Resource statement | A real `DynamicKeyword` the parser recognizes | An ordinary command call routed to an adapter function |
| Property block | The parser reads it as a hashtable, because the keyword declares `BodyMode = Hashtable` | Rewritten to a hashtable literal in the text |
| MOF validation | `ValidateInstanceText` runs against the live CIM classes | Skipped unless `-ValidateMof` is passed |
| Wall clock, 726 instances | 30 to 55 seconds | 5.2 seconds on PowerShell 7 and 7.4 seconds on Windows PowerShell in a fresh process, 2.1 and 5.6 seconds in a warm session |
| Wall clock, one instance | 40 to 50 seconds | 0.9 to 1.3 seconds in a fresh process, 0.2 seconds in a warm session |

**Important.** The saving has nothing to do with MOF generation. Producing the text is not the
expensive part. The saving is in never paying for resource discovery, which in a module of this size
dwarfs everything else a compile does, and which the classic path pays twice per run. What remains
on the fast path is the keyword driver, which runs the same code on both paths and costs the same
per instance.

## Components

```mermaid
flowchart TB
    subgraph m365["Microsoft365DSC"]
        wrapper["Modules/M365DSCConfigurationCompiler.psm1<br/><i>Invoke-M365DSCConfigurationBuild</i>"]
        cachejson["DscSchemaCache.json<br/><i>ships in the package</i>"]
        builder["Utilities/New-M365DSCDscSchemaCache.ps1"]
        resources["DscResources/MSFT_*<br/><i>class based resources</i>"]
    end
    subgraph engine["M365DSC.PSDesiredStateConfiguration"]
        psm1["M365DSC.PSDesiredStateConfiguration.psm1<br/><i>Configuration, Node, MOF writer</i>"]
        fast["FastHost.ps1<br/><i>Invoke-DscFastCompile, stripping, adapters</i>"]
        cachecode["SchemaCache.ps1<br/><i>Export/Test/Get-DscSchemaCache</i>"]
        driver["CimKeywordImplementationFunction.ps1<br/><i>per resource driver</i>"]
        compat["Compat/PSDesiredStateConfiguration<br/><i>name claim</i>"]
    end
    sma[["System.Management.Automation<br/><i>DscClassCache, DynamicKeyword, Parser</i>"]]

    wrapper -->|"resolves and imports"| psm1
    wrapper -->|"Invoke-DscFastCompile"| fast
    builder -->|"Export-DscSchemaCache"| cachecode
    builder -->|"writes"| cachejson
    resources -->|"discovered once"| cachecode
    cachejson -->|"read per compile"| fast
    fast --> psm1
    psm1 --> driver
    compat -.->|"re-exports"| psm1
    cachecode --> sma
    psm1 --> sma
```

### On the Microsoft365DSC side

`Modules/Microsoft365DSC/Modules/M365DSCConfigurationCompiler.psm1` is a nested module of the
Microsoft365DSC manifest and it is deliberately thin. `Test-M365DSCFastCompileAvailable` answers
whether a capable engine is installed, and `Invoke-M365DSCConfigurationBuild` compiles a script,
through the fast host when it can and through the standard pipeline when it cannot. Neither command
knows anything about MOF. They resolve an engine, hand the work over and pass the results back.

The keyword cache the fast host reads, `Modules/Microsoft365DSC/DscSchemaCache.json`, is generated at
build time by `Utilities/New-M365DSCDscSchemaCache.ps1`. It is gitignored, so a working tree that was
never built does not carry one and a compile against that tree pays for a live generation instead.

### On the engine side

The engine package holds the compiler plus a compatibility module of the same version that exists
only to own a name.

| File | Responsibility |
| --- | --- |
| `M365DSC.PSDesiredStateConfiguration.psm1` | `Configuration` and `Node` keywords, node state, MOF instance text, document assembly, file writing |
| `FastHost.ps1` | `Invoke-DscFastCompile`, `Get-DscFastCompileTiming`, module resolution, text transformation, keyword registration, adapter functions |
| `SchemaCache.ps1` | `Export-DscSchemaCache`, `Test-DscSchemaCache`, line based cache reader, cache lookup and fingerprinting |
| `CimKeywordImplementationFunction.ps1` | The driver that validates and canonicalizes one resource instance and emits its MOF text |
| `Compat/PSDesiredStateConfiguration` | Carries the legacy module name and forwards to the engine |

None of it is compiled code. All resource discovery is delegated to `DscClassCache`, which already
ships inside `System.Management.Automation` on Windows PowerShell 5.1 and PowerShell 7 alike, so the
same script serves both editions.

### The module name claim

**Important.** Which module compiles your configuration is not decided by which module you imported.
The parser rewrites `Configuration Foo { ... }` into a function whose body the engine generates, and
that generated body opens with `Import-Module PSDesiredStateConfiguration` and closes with a call to
the module qualified name `PSDesiredStateConfiguration\Configuration`. Both are resolved by module
name at the moment the configuration runs. Whoever holds the name at that moment owns the compile.

The engine takes the name twice, because those two lines resolve through different mechanisms.
`Assert-DscConfigurationShim` assigns the engine's own `Configuration` function to the global function
name `PSDesiredStateConfiguration\Configuration`, and re-asserts it after every parse, because parsing
a configuration statement makes the engine load the inbox module by file path and quietly take the
name back. The prologue import is covered differently. Importing the engine also imports the bundled
compatibility module and prepends its `Compat` folder to `$env:PSModulePath`, so
`Import-Module PSDesiredStateConfiguration` finds a module that forwards to the engine already in
memory rather than the inbox 1.1 or gallery 2.x module.

A consumer that overwrites `$env:PSModulePath` after importing the engine has to put that folder
back. Nothing errors when it is missing. The compile simply falls through to the other module, gets
slow again and writes MOF that no longer compares byte for byte.

## The configuration document

`Export-M365DSCConfiguration` writes a script of this shape:

```powershell
param ()

Configuration M365TenantConfig
{
    param ()

    $OrganizationName = $ConfigurationData.NonNodeData.OrganizationName

    Import-DscResource -ModuleName 'Microsoft365DSC'

    Node localhost
    {
        AADGroup 'MyGroup'
        {
            DisplayName   = 'My Group'
            MailNickname  = 'mygroup'
            Ensure        = 'Present'
            ApplicationId = $ConfigurationData.NonNodeData.ApplicationId
        }
    }
}

M365TenantConfig -ConfigurationData .\ConfigurationData.psd1
```

Three details of that shape drive everything the fast host does. The `Import-DscResource` statement
is the line that makes the classic path expensive, and it is the first thing to go. Resource
statements put their opening brace on the next line, which is fine while the parser knows the keyword
and a problem the moment it does not. And the script ends by invoking its own configuration, so the
script performs the compilation, not the caller. That last one is easy to miss and it changes how the
wrapper's parameters behave.

The sibling `ConfigurationData.psd1` carries `AllNodes` together with the `NonNodeData` values the
export substituted for tenant identifiers.

## End to end flow

```mermaid
sequenceDiagram
    autonumber
    participant U as Caller
    participant W as Invoke-M365DSCConfigurationBuild
    participant F as Invoke-DscFastCompile
    participant S as Schema cache
    participant C as Configuration function
    participant A as Adapter function
    participant D as Driver function
    participant M as MOF writer

    U->>W: -Path .\M365TenantConfig.ps1
    W->>W: resolve engine by M365DSCFastHost tag
    W->>F: path, configuration data, parameters
    F->>F: mask, parse the copy once, collect Import-DscResource
    F->>F: resolve each module by a PSModulePath manifest scan
    F->>S: resolve cache per module
    alt no valid cache
        S->>S: generate live once, persist to user cache
    end
    F->>F: register keyword names and adapters
    F->>F: one edit pass: strip imports, join braces, insert @
    F->>C: create scriptblock and dot source it
    Note over C: no Import-DscResource left,<br/>so no module import fires
    C->>C: merge adapters into functionsToDefine
    C->>C: InvokeWithContext(body, variables)
    loop each resource statement
        C->>A: plain command call
        A->>A: read hashtable body, build SourceInfo
        A->>D: KeywordData, Name, Value, SourceMetadata
        D->>D: DependsOn, duplicates, canonicalization
        D->>M: ConvertTo-MOFInstance
    end
    C->>M: assemble node documents, fix up DependsOn
    M-->>U: FileInfo of the written .mof files
```

## Stage 1: Wrapper and engine resolution

`Invoke-M365DSCConfigurationBuild` normalizes the inputs and decides which path to take.

```mermaid
flowchart TB
    start(["Invoke-M365DSCConfigurationBuild -Path"]) --> resolve["resolve path,<br/>default ConfigurationData.psd1<br/>next to the script"]
    resolve --> splat["build invoke parameters:<br/>Parameters, Credential, CertificatePassword"]
    splat --> mode{"-Engine"}
    mode -->|FastHost| import["import engine, required"]
    mode -->|Auto| probe{"engine with<br/>M365DSCFastHost tag<br/>installed?"}
    mode -->|Standard| std["standard pipeline"]
    probe -->|yes| import
    probe -->|no| warn["warn, standard pipeline"] --> std
    import --> fast["Invoke-DscFastCompile"]
    fast --> mof([".mof files"])
    std --> mof
```

An engine qualifies when its manifest carries the PSData tag `M365DSCFastHost`. The wrapper takes the
highest installed version and imports it by manifest path with `-Force -Global`, after removing any
instance already loaded from a different module base. Two live instances would each keep their own
keyword table and fast host state, and the compile would silently run against whichever one won the
name claim.

The standard branch just runs the script. It pushes into the script directory first so the relative
paths in the trailer resolve, and it sets `$Global:PSDscFastCompileActive` for the duration, which is
the flag anything wrapping a build can read to tell that a compile is in progress.

`-ConfigurationName` selects the branch that dot sources the script and then invokes the named
configuration itself. That is the shape of the example files under `Examples/`, which declare a
configuration and stop there.

**Important.** For an exported script, the trailer wins, not your parameters. The last line of
`M365TenantConfig.ps1` is a complete compile command in its own right:

```powershell
M365TenantConfig -ConfigurationData .\ConfigurationData.psd1
```

The fast host dot sources the script, that line runs, the configuration compiles with the arguments
written on it, and MOF files come back. Seeing files, the fast host returns them straight to the
caller and never invokes anything itself, so `-OutputPath`, `-ConfigurationData` and `-Parameters`
from the wrapper are never applied and the documents land where the trailer put them, in
`.\M365TenantConfig\localhost.mof`. Adding `-ConfigurationName` does not change this, because the
self invocation has already produced the files by the time that parameter would be read. To send an
export somewhere else, edit its trailer, for example to
`M365TenantConfig -ConfigurationData .\ConfigurationData.psd1 -OutputPath .\out`. The wrapper's own
parameters reach the configuration only for scripts that declare one without invoking it.

## Stage 2: Text transformation

The fast host never hands the original text to the parser as a configuration. It parses a masked
copy once, collects every edit that copy calls for, and applies all of them to the original text in a
single pass.

```mermaid
flowchart LR
    src["original text"] --> mask1["mask 'Configuration'<br/>in a copy"]
    mask1 --> parse1["Parser.ParseInput<br/><i>0.3 to 0.5 s for 726 instances</i>"]
    parse1 --> collect["collect configuration names,<br/>Import-DscResource ASTs,<br/>module specs"]
    collect --> edits["ConvertTo-FastHostCompileText<br/><i>edit list: import extents,<br/>brace gaps, @ prefixes</i>"]
    edits --> apply["Invoke-FastHostTextEdit<br/><i>one StringBuilder pass</i>"]
    apply --> sb["scriptblock::Create"]
```

`ConvertTo-FastHostCompileText` takes the text, the masked AST, the import statements and the set of
known keyword names, and returns the compile text. Every edit is a start offset, a length and a
replacement. `Invoke-FastHostTextEdit` sorts the edits by offset, throws on an overlap, and copies
the untouched stretches between them with `Substring` into one `StringBuilder`. The `Substring`
call matters on PowerShell 7, where `StringBuilder.Append(string, int, int)` binds to the `char[]`
overload and copies the whole text on every call. `Merge-FastHostResourceStatements` and
`Convert-FastHostBodyToHashtable` are wrappers over the same function that apply one edit kind each.
The whole rewrite stage takes 0.4 to 0.9 seconds for a 726 instance export.

### Masking instead of parsing

**Important.** There is no way to look at a configuration script without triggering the import.
`Parser.ParseInput`, `Parser.ParseFile`, `[scriptblock]::Create` and even the legacy
`PSParser.Tokenize` all fire it, the last one measured at 23 seconds for a Microsoft365DSC
configuration. This is PowerShell behaving as designed, on both Windows PowerShell and PowerShell 7,
and not something a parameter can turn off. Any tool that wants the AST of a configuration first has
to make the text stop looking like one.

Masking does exactly that, and it does it without moving a single character. Every occurrence of the
word `Configuration` becomes `C0nfiguration` in a **copy** of the text. The parser no longer sees a
configuration statement, so no import runs and the parse costs milliseconds for a small script and
0.3 to 0.5 seconds for a 726 instance export. The replacement is the same length as the original,
which is the whole trick: every extent offset the AST reports for the masked copy points at exactly
the same character in the untouched original. `Get-FastHostMaskedAst` produces that AST, and the
same AST steers the import collection and every later edit, so the text is parsed once per compile.

### Stripping the imports

From that masked AST, `Get-StrippedConfigurationText` picks up the names of the declared
configurations and every `Import-DscResource` command. Each import contributes its `-Name`,
`-ModuleName` and `-ModuleVersion`, positionally or named, and only constant values count, meaning
string literals and array literals of string literals. A computed module name would have to be
executed to be known, and executing the script is what this whole path avoids, so such a script falls
back instead.

Each import statement becomes an edit that replaces its extent with nothing. The result holds the
module specifications, the configuration names, the AST and the import statements, so the later
stages work from the same parse. What remains after the edit pass is a script with no DSC specific
syntax left in it at all.

### Joining next line braces

Now that the parser no longer knows the keywords, the export style below stops being one statement:

```powershell
AADGroup 'MyGroup'
{
    DisplayName = 'My Group'
}
```

The parser reads a command call, then an unrelated scriptblock, and the resource is lost. The merge
edit finds those statement pairs in every statement block of the masked AST, checks that the first
statement names a known keyword and the second is a lone scriptblock or hashtable expression, and
replaces the gap between them with a single space, which makes the block the last argument of the
command again. Two shapes qualify. One is the resource statement `KeywordName [InstanceName]`. The other is a nested CIM
instance inside a resource body, written as `PropertyName = KeywordName`, which despite the equals
sign is not an assignment at all but a single command whose three elements are the property name, a
literal `=` and the keyword.

### Rewriting bodies to hashtable literals

**Important.** DSC registers resource keywords with `BodyMode = Hashtable`, so on the classic path
the parser reads a resource body as a hashtable and a property is free to be called `User`,
`Settings` or `Script`. Leave that same body as a scriptblock and those names are live built in
keywords again, which turns an ordinary property assignment into a syntax error.

The convert edit closes that gap by inserting an `@` in front of every scriptblock that is the last
element of a command whose name is a known keyword, turning `{ ... }` into `@{ ... }` and adding a
separator where the source had none, because `MSFT_Type@{` does not parse. A body that the merge
edit joined gets its prefix in the same pass, and a start offset is edited at most once. The result
is a script the parser can take at face value, in which every resource is a command call whose last
argument happens to be a hashtable literal.

## Stage 3: Schema cache and keyword registration

For each module named by a stripped import, the fast host resolves a module and then a cache.

```mermaid
flowchart TB
    q(["module spec from Import-DscResource"]) --> res{"Resolve-FastHostModule:<br/>manifest on PSModulePath<br/>and version matches?"}
    res -->|no| fb1["fallback"]
    res -->|yes| comp{"DscResources contains<br/>*.schema.psm1?"}
    comp -->|yes| fb2["fallback:<br/>composite resources"]
    comp -->|no| reg{"module and version<br/>registered in this session<br/>and no -Force?"}
    reg -->|yes| use(["keywords available"])
    reg -->|no| a{"-SchemaCachePath given<br/>and valid?"}
    a -->|yes| use
    a -->|no| b{"ModuleBase DscSchemaCache.json<br/>format, name, version,<br/>fingerprint match?"}
    b -->|yes| use
    b -->|no| c{"user cache under<br/>LOCALAPPDATA matches?"}
    c -->|yes| use
    c -->|no| gen["Export-DscSchemaCache:<br/>one time live discovery, about 10 s"]
    gen --> persist["persist to the user cache"] --> use
```

### Module resolution

`Resolve-FastHostModule` walks every entry of `PSModulePath` and looks for `<Name>\<Name>.psd1` and
`<Name>\<version>\<Name>.psd1`. It reads `ModuleVersion` from each manifest with
`Import-PowerShellDataFile`, drops candidates whose folder or manifest version differs from a
requested `-ModuleVersion`, and keeps the highest version. The result carries the name, the version,
the module base and the manifest path. It is cached per module specification for the life of the
session, so the scan runs once per process. `Get-Module -ListAvailable` is not used on this path,
because it analyzes all 54 nested modules of Microsoft365DSC and costs 1.1 to 1.3 seconds per call.
The resolution stage measures 10 to 90 milliseconds.

### Resolution order

1. Paths given through `-SchemaCachePath`.
2. `<ModuleBase>\DscSchemaCache.json`, shipped inside the resource module package.
3. `%LOCALAPPDATA%\M365DSC.PSDesiredStateConfiguration\SchemaCache\<Name>_<Version>_<fingerprint>.json`,
   written after a live generation, with the colons of the fingerprint replaced by underscores.
4. Live generation, then persisted to 3.

`-Force` skips steps 1 to 3 and regenerates the user cache.

A cache has to earn its place before any of its keywords are used. Its format version has to be 2,
its module name and version have to match, and so does its fingerprint. That fingerprint is
`fileCount:totalBytes:hash`, where the hash is the first eight bytes of a SHA-256 over the sorted
lower cased relative paths and sizes of every `*.psm1`, `*.psd1` and `*.mof` file below the module
base, one `path|length` per line. It carries no write times, so the cache shipped in the package
stays valid after `Install-Module` or a plain copy. When the fingerprint of the module tree differs,
the reader recomputes it over the files the cache recorded and accepts the cache when that matches,
so a file that appears next to the module later does not invalidate it. When accuracy matters more
than speed, `Test-DscSchemaCache -Detailed` re-hashes every recorded file against the SHA-256 the
cache stores, which is what belongs in a CI drift gate. Without `-Detailed` it checks the format
version, the module version and the presence of every recorded file.

### Cache content

The cache holds one JSON document per line.

| Line | Content |
| --- | --- |
| 1 | Header: `formatVersion`, `generator` with the engine and PowerShell versions, `module` with name, version and fingerprint, `resourceCount`, `keywordCount`, and `index`, a map from keyword name to the zero based line number that holds it |
| 2 | Sources: relative path of every fingerprinted file with its `length` and `sha256` |
| 3 and later | One keyword each |

`resourceCount` counts the keywords whose name mode is `NameRequired`, which are the resources. Each
keyword line is a serialization of the very `DynamicKeyword` definition a live import would have
produced. It records the keyword name, the resource name, the implementing module and version, the
name and body modes, and for every property its type constraint, its key and mandatory flags, its
allowed values and its value map. Embedded complex types sit in the same flat list as ordinary no
name keywords. Value maps are arrays of key and value pairs rather than JSON objects, because DSC
permits an empty string as a map key and no JSON object can carry that portably. Keywords of
`*.schema.mof` resources under `DscResources` are in the same list, imported through
`ImportCimKeywordsFromModule` at generation time.

The reader loads the file with `ReadAllLines`, parses line 1, and keeps the rest as text. A keyword
is deserialized the first time a compile asks for it by name, through the index. The file is
written as UTF-8 without a byte order mark.

For Microsoft365DSC the shipped cache is 3.7 MB and covers 531 resources in 999 keywords on 1001
lines. Reading it and registering its names costs 0.2 to 0.3 seconds per process.

### Registration

`Register-DscSchemaCache` adds the cache object to the keyword source list and registers the
adapters. Every name in the index gets the same shared adapter scriptblock, registered twice, under
the bare name and under the `Microsoft365DSC\<Keyword>` qualified name, because a configuration body
may call it either way. `Get-FastHostKeyword` looks a name up in a case insensitive dictionary
first, then in the index of each registered cache, deserializes the line on a hit and stores the
`DynamicKeyword` in the dictionary. `Get-FastHostKeywordName` returns the union of both as a case
insensitive set, which is what the text rewrite uses to recognize resource statements.

Registration is remembered per module name and version for the life of the session, so a second
compile in the same process skips the cache stage and reuses the keywords built so far. `-Force`
bypasses that memory.

**Important.** These keywords live only in the fast host's own dictionary. They never enter the
parser keyword table, and no CIM classes are registered with the MI layer. Two consequences follow
from that and both show up later in this document. `ConvertTo-MOFInstance` has to consult the fast
host dictionary before falling back to `[DynamicKeyword]::GetKeyword()`, and MOF validation has
nothing to validate against, so it is skipped.

## Stage 4: Execution

`Invoke-DscFastCompileBody` creates a scriptblock from the transformed text and dot sources it inside
the script directory. A scriptblock built from text carries no file name, which would leave every
`SourceInfo` in the document pointing nowhere, so the real script path is handed to the fast host
separately and the adapter uses it instead.

Because the trailer of an exported configuration invokes the configuration itself, the dot source is
what performs the compile, and `FileInfo` objects come back from it. Only when nothing comes back
does the fast host resolve a configuration name, from `-ConfigurationName` or from the single declared
configuration, and invoke it with the caller's parameters, configuration data and output path.

Inside the engine's `Configuration` function the fast path is the classic path with two edits. The
import loop finds `ResourceModuleTuplesToImport` empty and does nothing, since the statements that
would have filled it were removed. And when the fast host is active, its adapters plus four accessor
functions are merged into `functionsToDefine`, the same dictionary real keywords would have been
added to, which is then handed to `Body.InvokeWithContext` together with `ConfigurationData`,
`AllNodes`, `MyTypeName`, `IsMetaConfig` and the configuration parameters.

Everything after that point is shared code. Node state, `DependsOn` fix up, conflict detection,
credential encryption and document assembly do not know which path fed them.

### The adapter

```mermaid
sequenceDiagram
    autonumber
    participant B as Configuration body
    participant A as Adapter function
    participant K as Keyword table
    participant D as Driver function

    B->>A: AADGroup 'MyGroup' @{ ... }
    A->>A: keyword name from MyInvocation.InvocationName
    A->>K: Get-FastHostKeyword
    K-->>A: DynamicKeyword
    A->>A: last argument is the hashtable body
    A->>A: first argument is the instance name<br/>when NameMode is NameRequired
    A->>A: SourceInfo is file, line, offset, keyword
    A->>D: KeywordData, Name, Value, SourceMetadata
```

The property block arrives at the adapter as a hashtable PowerShell has already evaluated in the
caller's scope, which is why `$ConfigurationData`, `$AllNodes`, `$Node`, script parameters and user
variables behave exactly as they do on the classic path. The adapter validates nothing beyond the
shape of its arguments. Its entire job is to turn a command call back into the argument set a keyword
driver expects.

### The driver

`CimKeywordImplementationFunction.ps1` is the single driver both paths use. Per resource instance it:

1. Builds the resource id `[Keyword]InstanceName` and records `SourceInfo`, `ModuleName` and
   `ModuleVersion`.
2. Validates the `DependsOn` references, merges them with an outer composite resource's `DependsOn`,
   and registers them in the per node resource table.
3. Rejects a duplicate resource id in the same node.
4. Merges `PsDscRunAsCredential` from the configuration, and errors when both sides set it.
5. Copies every user supplied value into a new hashtable with canonically cased property names,
   checking allowed values, ranges and mandatory properties, and translating value map entries to
   their MOF representation.
6. Accumulates the key property values and runs conflict detection across instances that share them.
7. Calls `ConvertTo-MOFInstance`, which produces the MOF text for the instance and returns its alias.

Problems are reported through the configuration error counter rather than by throwing, so one compile
tells you about every broken resource instead of only the first one.

## Stage 5: Document assembly and MOF emission

When the top level `Configuration` invocation ends, the engine turns the collected instances into
documents. It rewrites `DependsOn` into instance aliases, checks that every referenced resource
exists, resolves module versions, hunts for dependency cycles, appends the
`OMI_ConfigurationDocument` instance and writes one document per node.

`Write-NodeMOFFile` calls `Test-MofInstanceText` before writing. On the fast path that call returns
immediately unless `-ValidateMof` was passed, because MI validation needs the live CIM classes this
path never registers. `-ValidateMof` brings the check back at the price of the import the fast path
exists to avoid, which makes it a diagnostic switch rather than something to leave on.

The file goes through a single writer as UTF-16LE with a byte order mark, which is the encoding the
MI MOF parser expects. A document without the mark is decoded as Latin-1 and every non-ASCII
character in it is corrupted. The document body carries LF line endings because the instance text is
assembled with `\n`, and the writer appends one CRLF at the end. There is no generated by banner and
there are no `Author`, `GenerationDate` or `GenerationHost` fields. Together that makes the
same configuration compile to the same bytes on every run, machine, user and PowerShell edition,
which is what allows the two paths to be compared against each other at all. Property order inside an
instance is the one thing that still moves, since it follows hashtable enumeration.

Compilation state is torn down in a `finally` block. The fast host flags are cleared and
`[DynamicKeyword]::Reset()` runs, so a session that compiles one configuration after another does not
accumulate keyword state from the previous run.

## Stage timing

`Invoke-DscFastCompile` records the wall clock of each stage in milliseconds, and
`Get-DscFastCompileTiming` returns them as an ordered dictionary for the last compile in the session.

| Key | Covers |
| --- | --- |
| `parse` | Masking, the single parse, import collection |
| `resolve` | Module resolution and the composite resource check |
| `cache` | Cache lookup or generation, registration |
| `rewrite` | The edit pass |
| `compile` | Dot sourcing the compile text, the configuration run, document assembly and the MOF write |
| `total` | Everything above |

Medians of three for a 726 instance Exchange Online export, one Microsoft365DSC version on
`PSModulePath`, in seconds.

| Stage | Windows PowerShell, fresh process | Windows PowerShell, warm session | PowerShell 7, fresh process | PowerShell 7, warm session |
| --- | --- | --- | --- | --- |
| `parse` | 0.33 | 0.25 | 0.46 | 0.31 |
| `resolve` | 0.09 | 0.04 | 0.05 | 0.01 |
| `cache` | 0.27 | 0.00 | 0.19 | 0.00 |
| `rewrite` | 0.82 | 0.66 | 0.72 | 0.42 |
| `compile` | 5.88 | 4.66 | 3.78 | 1.32 |
| `total` | 7.39 | 5.61 | 5.20 | 2.06 |

The `compile` stage is the keyword driver plus the MOF writer, the same code the classic path runs
after its imports. A single instance script measures 0.9 to 1.3 seconds in a fresh process and 0.2
seconds warm.

## Difference to the classic PSDesiredStateConfiguration path

```mermaid
sequenceDiagram
    autonumber
    participant U as User script
    participant E as PowerShell engine
    participant C as Configuration function
    participant D as Driver function
    participant M as MOF writer

    U->>E: parse the configuration statement
    E->>E: import every resource of every Import-DscResource module<br/>16 to 22 s for Microsoft365DSC
    U->>C: invoke through PSDesiredStateConfiguration\Configuration
    C->>E: ImportClassResourcesFromModule, highest version only
    C->>C: InvokeWithContext(body, functionsToDefine)
    loop each resource statement
        C->>D: generated keyword driver call
        D->>M: ConvertTo-MOFInstance
    end
    C->>M: assemble node documents
    M->>U: .mof files
```

The classic path is not a second compiler. It is the same `Configuration` function, the same driver
and the same writer, reached with keywords that came from a live import instead of a cache. Four
things differ.

- **Discovery happens twice.** Once while the parser processes the configuration statement, and once
  when the `Configuration` function walks `ResourceModuleTuplesToImport`.
- **Keywords are real parser keywords.** The parser knows `AADGroup`, accepts the next line brace and
  reads the body as a hashtable by itself, so none of the text transformation is needed.
- **CIM classes are registered**, which is what lets `ValidateInstanceText` check the assembled
  document.
- **Composite resources work.** They rely on the engine's own import. The fast path takes that
  away. Script based resources with a `*.schema.mof` compile on both paths, because the cache holds
  their keywords too.

Run the same script on the inbox 1.1 or gallery 2.x module and it still compiles, at the same cost,
but that module has no fast host, no schema cache and no deterministic writer, and its documents
arrive stamped with a banner and volatile metadata fields. Which module you get is settled by the
name claim described earlier, not by which module you imported last. The gallery 2.0.7 module on
PowerShell 7 also drops properties whose value is an empty array, where the inbox 1.1 module and this
engine both write `Prop = { }`.

## Fallback

The fast host would rather be slow than be wrong. Whenever it cannot guarantee that its result
matches what the classic path would have produced, it degrades to standard compilation and warns with
the reason.

| Trigger | Reason |
| --- | --- |
| `Import-DscResource` with non constant arguments | The module set cannot be determined without executing the script |
| `-Name` without `-ModuleName` | Would require scanning every installed module |
| The named module has no manifest on `PSModulePath`, or not in the requested version | Nothing to resolve a cache against |
| The module contains `*.schema.psm1` under `DscResources` | Composite resources need the engine's own import |
| No usable schema cache and none can be generated | Nothing to register keywords from |

`-NoFallback` turns each of these into a terminating error. Continuous integration should use it,
because a stale cache that quietly degrades into a 90 second compile still passes, and nobody looks
at a passing job. The QA example gate takes the same stance by asserting
`Test-M365DSCFastCompileAvailable` and passing `-Engine FastHost`.

## Building and shipping the schema cache

```mermaid
flowchart LR
    build["Utilities/Build-Microsoft365DSC.ps1"] --> gen["Utilities/New-M365DSCDscSchemaCache.ps1"]
    gen --> stage["stage the built module<br/>under a version folder"]
    stage --> child["child pwsh process:<br/>import engine,<br/>Export-DscSchemaCache"]
    child --> json["Modules/Microsoft365DSC/DscSchemaCache.json"]
    json --> verify{"ResourceCount equals<br/>DscResourcesToExport?"}
    verify -->|no| fail["throw"]
    verify -->|yes| ship["ships in the package"]
```

`Export-DscSchemaCache` resets the keyword state, snapshots the default keywords, imports the
module's class based resources once through `DscClassCache::ImportClassResourcesFromModule`, imports
every `DscResources\<Name>\<Name>.schema.mof` through `ImportCimKeywordsFromModule`, and serializes
everything that was not already a default. It then hashes every fingerprinted file for the sources
line. That discovery costs about 10 seconds for Microsoft365DSC. This is a build step during the
module build, not a compile step on the local machine.

Two decisions in the build wrapper are worth knowing about. It runs the export in a **child process**
whose `PSModulePath` contains nothing but the staged module, so the one time import neither pollutes
the calling session nor accidentally discovers an installed Microsoft365DSC from somewhere else on
the machine. And it compares the reported `ResourceCount` against the number of resources the
manifest exports and throws when they disagree, which is what catches a cache generated against a
half built module tree.

**Important.** Generate the cache **after** any build step that adds or trims files in the module
tree. The fingerprint is a file count, the total size and a hash of the path and size list, so a
file added or resized later invalidates a cache that was perfectly correct when it was written, and
the next compile quietly regenerates it instead of using the shipped one.

## What to take into account

**The cache is the contract, not the resource files.** The fast host compiles against
`DscSchemaCache.json`. A property that exists in the source tree but not in the cache does not exist
as far as compilation is concerned, and the fingerprint check is the only thing keeping the two
honest.

**Validation is traded away deliberately.** MOF validation is off by default. `-ValidateMof` brings
it back for a diagnostic run, and the real coverage comes from compiling every example in CI rather
than from validating each document.

**One engine instance per session.** The wrapper removes a mismatched instance before importing. Two
loaded copies mean two keyword tables and two sets of fast host state, and the compile runs against
whichever one won the name claim, which is not a thing you want to debug.

**Determinism is a feature to preserve.** Reintroduce a volatile field, a banner or a platform
dependent encoding and the two paths stop comparing byte for byte, which removes the main evidence
that the fast path is still equivalent to the slow one. `Compare-M365DSCMofDocument` in
`Utilities/M365DSCBuildHelpers.psm1` compares two documents after normalizing whitespace, property
and block order, character case, the `MSFT_` class prefix, `ModuleVersion` and `SourceInfo`, which
is the comparison the benchmark harness runs against the inbox engine.

**The first compile in a process pays for the module.** A fresh process reads the cache and
deserializes each keyword the configuration uses on first touch, which is the difference between
the fresh process and warm session columns in the timing table. A fresh copy or installation of
Microsoft365DSC also carries new write times, and the first `Import-Module` after that re-analyzes
all nested modules, which does not affect the fast host because it never imports the module.

**Composite resources stay on the classic path.** Every other resource kind, class based or
`*.schema.mof` based, compiles from the cache.

## Running it by hand

### Compile an export

```powershell
Test-M365DSCFastCompileAvailable

Invoke-M365DSCConfigurationBuild -Path .\M365TenantConfig.ps1
```

The documents land in `.\M365TenantConfig\localhost.mof`, because the trailer of the exported script
does not name an output path and the engine defaults it to the configuration name. Change the trailer
when you want them elsewhere. Add `-Engine Standard` to force the classic path, which is worth doing
once when a compile produces something you did not expect, since a result that differs between the
two paths is a genuine bug and a result that matches is not.

### Compile a script that only declares a configuration

This is the shape the example files use. You can use it with the wrapper's own parameters.

```powershell
Invoke-M365DSCConfigurationBuild -Path .\Example.ps1 `
    -ConfigurationName 'Example' `
    -ConfigurationData $configurationData `
    -OutputPath .\out `
    -Engine FastHost
```

### Keep the cache up-to-date

```powershell
# Needed once for a module that ships without a cache.
Export-DscSchemaCache -ModuleName Microsoft365DSC

# Catches a module that changed after its cache was written.
Test-DscSchemaCache -ModulePath $moduleBase -CachePath $cacheJson -Detailed

# Fails instead of degrading to a slow compile.
Invoke-DscFastCompile -Path .\M365TenantConfig.ps1 -NoFallback

# Regenerates the user cache and ignores the shipped one.
Invoke-DscFastCompile -Path .\M365TenantConfig.ps1 -Force

# Stage split of the last compile in this session, in milliseconds.
Get-DscFastCompileTiming
```

In this repository the cache is a build artifact. After changing a resource class or a
`settings.json`, run `Utilities/Build-Microsoft365DSC.ps1`, which regenerates
`DscSchemaCache.json` as part of the build. Compiling against a tree you have not rebuilt is the most
common reason a property you just added does not show up in the MOF.

### When something looks wrong

| Symptom | Cause |
| --- | --- |
| Compiles are slow and the MOF carries `GenerationDate` | Compilation went through the inbox or gallery module. `(Get-Module PSDesiredStateConfiguration).Path` must point at the engine's `Compat` folder |
| `Falling back to standard compilation` | See the fallback table. The warning names the trigger |
| A resource property change is ignored | Stale schema cache. Rebuild the module, or pass `-Force` |
| Every compile in a fresh process reports a live cache generation | No cache matches the module tree. `Test-DscSchemaCache -Detailed` names the file that differs |
| `compile` dominates `Get-DscFastCompileTiming` | Expected. The keyword driver costs the same per instance on both paths |
| `Undefined DSC resource` inside the fast host | The configuration uses a statement shape the transformation does not cover. A fallback warning normally precedes this |
| `-OutputPath` had no effect | The script invokes its own configuration, so the trailer decided. Edit the trailer, or compile a script that only declares the configuration |
