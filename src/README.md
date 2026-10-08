# Microsoft365DSC C# Assemblies

This directory contains C# assemblies for Microsoft365DSC operations.

## Current Components

### Microsoft365DSC.Compare

C# library targeting netstandard2.0 for accelerating configuration comparison and drift detection operations.

### Microsoft365DSC.Converter

C# library target netstandard2.0 for quick type conversions.

### Microsoft365DSC.Reporting

C# library targeting netstandard2.0 that converts parsed configurations into reports. Every output format is an `IReportConverter` registered in `ReportConverterRegistry`. The Markdown converter reports the properties a configuration sets, and builds the layout of each document from the schema, readme and permission files the module ships.

### Microsoft365DSC.Utilities

Utilities library for internal usage.

**Performance Impact:**

- 30-50% faster hashtable cloning for large configurations
- Significant speedup for array matching with 10+ elements
- Reduced memory allocations through optimized algorithms

## Building

### Prerequisites

- .NET SDK 6.0 or higher (for build tools)
- Targets .NET Standard 2.0 (compatible with .NET Framework 4.7.2+ and .NET Core 2.0+)

### Local Build

```powershell
# From repository root
.\Utilities\Build-DllFiles.ps1

# Or manually
cd src\Microsoft365DSC.<any project>
dotnet build -c Release
```

### CI/CD Build

The Azure Pipeline automatically builds the assembly during module packaging. See `azure-pipeline.yml` for details.

## Future Optimization Candidates

The following areas have been identified as potential candidates for C# acceleration in future releases:

### 1. Parallel Configuration Export Processing

**Current State:** Sequential export of resources
**Opportunity:** Use `Parallel.ForEach` or `Task.WhenAll` for concurrent resource export
**Expected Impact:** 3-10x faster exports for tenants with 100+ resources
**Complexity:** Medium (requires thread-safe PowerShell runspace management)

### 2. SIMD-Accelerated String Comparisons

**Current State:** Standard string comparison and normalization
**Opportunity:** Use `System.Numerics.Vectors` for bulk string operations
**Expected Impact:** 20-40% faster string-heavy comparisons (descriptions, policies)
**Complexity:** High (requires careful algorithm design and platform detection)

### 3. Bulk Microsoft Graph Query Batching

**Current State:** Individual Graph API calls per resource
**Opportunity:** Batch multiple queries using Graph JSON batching endpoints
**Expected Impact:** 50-80% reduction in API roundtrips, faster exports
**Complexity:** Medium (requires request aggregation and response demultiplexing)

### 4. Large Report Generation with Streaming

**Current State:** In-memory HTML/JSON report generation
**Opportunity:** Streaming report generation using `StreamWriter` and incremental rendering
**Expected Impact:** 50-70% lower memory usage for reports >10MB
**Complexity:** Low (straightforward refactoring of report generation functions)

### 5. Advanced Caching with Memory-Mapped Files

**Current State:** In-memory schema and resource definition caching
**Opportunity:** Use memory-mapped files for persistent schema cache across PowerShell sessions
**Expected Impact:** Instant schema loading (0ms vs 1-3s), reduced cold start time
**Complexity:** High (requires careful cache invalidation and cross-platform support)

### 6. Differential Configuration Export

**Current State:** Full configuration export every time
**Opportunity:** Track changes and export only modified resources
**Expected Impact:** 80-95% faster subsequent exports for large tenants
**Complexity:** High (requires change tracking database and API version management)

## Extension Guidelines

When adding new C# accelerators:

1. **Target netstandard2.0** - Ensures compatibility with both Framework and Core
2. **Use latest C# language features** - Already configured in .csproj
3. **Include XML documentation** - Enable IntelliSense for PowerShell developers
4. **Add unit tests** - Place in `Tests/Unit/Microsoft365DSC/`
5. **Benchmark before/after** - Use `Tests/Performance/` benchmark suite
6. **Fail fast on errors** - Throw descriptive exceptions instead of returning null
7. **Cache aggressively** - Schema and reflection caches provide significant wins
8. **Consider PowerShell interop costs** - Use C# only when benefit exceeds marshalling overhead

## Contributing

C# accelerator contributions should follow these steps:

1. Identify performance bottleneck via profiling
2. Propose C# solution with expected impact
3. Implement with unit tests and benchmarks
4. Submit PR with before/after performance data
5. Update documentation with architecture details

For questions, open an issue on the [Microsoft365DSC GitHub repository](https://github.com/microsoft/Microsoft365DSC).
