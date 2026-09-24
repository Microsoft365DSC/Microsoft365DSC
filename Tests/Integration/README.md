# Microsoft365DSC Integration Testing Framework

## Overview

This framework provides automated end-to-end deployment testing for **all** Microsoft365DSC
resources. It goes beyond unit tests by:

1. **Deploying** each resource configuration to a real M365 tenant
2. **Exporting** the tenant state back using `Export-M365DSCConfiguration`
3. **Asserting** drift-free state via `Assert-M365DSCBlueprint`
4. **Cleaning up** the tenant to a baseline state for the next run
5. **Testing** each resource with every authentication method it supports

## Architecture

```
Tests/Integration/
├── README.md                         # This file
├── M365DSCTestEngine.psm1            # Original test engine (preserved)
├── M365DSCDeploymentTestEngine.psm1  # NEW: Full deployment + drift test engine
├── Config/
│   ├── TestTenants.config.json       # Tenant connection configuration (secrets via env vars)
│   ├── ResourceTestMatrix.json       # Which resources to test + auth methods
│   └── KnownIssues.json              # Resources with known deployment issues
├── Helpers/
│   ├── Invoke-TenantCleanup.ps1      # Resets tenant to baseline
│   ├── Get-ResourceAuthMethods.ps1   # Discovers auth methods per resource
│   └── New-TestReport.ps1            # Generates HTML/JSON test report
└── Microsoft365DSC/                  # Generated test scripts (auto-created)
```

## Quick Start

### 1. Configure Test Tenant(s)

Copy `Config/TestTenants.config.json` and set environment variables for secrets:

```powershell
$env:M365DSC_TEST_APPID           = '<your-app-registration-id>'
$env:M365DSC_TEST_TENANTID        = '<your-tenant-id>'
$env:M365DSC_TEST_CERTTHUMBPRINT  = '<certificate-thumbprint>'
$env:M365DSC_TEST_APPSECRET       = '<app-secret>'  # Optional
$env:M365DSC_TEST_CREDENTIAL_USER = '<admin-upn>'    # Optional for credential auth
$env:M365DSC_TEST_CREDENTIAL_PASS = '<admin-pass>'   # Optional for credential auth
```

### 2. Run All Tests (Single Workload)

```powershell
Import-Module './Tests/Integration/M365DSCDeploymentTestEngine.psm1'
Invoke-M365DSCDeploymentTest -Workload 'AAD' -AuthMethod 'CertificateThumbprint'
```

### 3. Run All Tests (All Workloads, All Auth Methods)

```powershell
Invoke-M365DSCDeploymentTest -All
```

### 4. Run a Single Resource

```powershell
Invoke-M365DSCDeploymentTest -ResourceName 'AADApplication' -AuthMethod 'CertificateThumbprint'
```

## Authentication Methods

Each resource is tested with every auth method it supports. The engine auto-detects
supported methods by inspecting the resource schema (`.schema.mof`):

| Method                | Schema Property        | Env Var Required                         |
|-----------------------|------------------------|------------------------------------------|
| `Credential`          | `Credential`           | `M365DSC_TEST_CREDENTIAL_USER/PASS`      |
| `CertificateThumbprint` | `CertificateThumbprint` | `M365DSC_TEST_APPID/TENANTID/CERTTHUMBPRINT` |
| `ApplicationSecret`   | `ApplicationSecret`    | `M365DSC_TEST_APPID/TENANTID/APPSECRET`  |
| `ManagedIdentity`     | `ManagedIdentity`      | Requires Azure VM/ACI runner             |
| `AccessTokens`        | `AccessTokens`         | `M365DSC_TEST_ACCESSTOKEN`               |

## Test Flow per Resource

```
┌─────────────────┐
│  Parse Example   │  Read Examples/Resources/<Resource>/1-Create.ps1
│  Configuration   │
└────────┬────────┘
         │
┌────────▼────────┐
│  Deploy Config   │  Start-DscConfiguration with auth params
│  (Create)        │
└────────┬────────┘
         │
┌────────▼────────┐
│  Export Tenant   │  Export-M365DSCConfiguration for the resource
│  State           │
└────────┬────────┘
         │
┌────────▼────────────────┐
│  Assert-M365DSCBlueprint │  Compare deployed config vs export
│  (Drift Detection)       │
└────────┬────────────────┘
         │
┌────────▼────────┐
│  Deploy Update   │  Run 2-Update.ps1 example if available
│  Config          │
└────────┬────────┘
         │
┌────────▼────────┐
│  Re-Assert       │  Verify update applied without drift
│  Blueprint       │
└────────┬────────┘
         │
┌────────▼────────┐
│  Remove Config   │  Run 3-Remove.ps1 example if available
│  (Cleanup)       │
└────────┬────────┘
         │
┌────────▼────────┐
│  Generate Report │  Pass/Fail + drift details per resource+auth
└─────────────────┘
```

## Known Issues

Resources with known deployment failures are tracked in `Config/KnownIssues.json`.
These are **not skipped** by default but are flagged in reports. Use
`-SkipKnownIssues` to skip them:

```powershell
Invoke-M365DSCDeploymentTest -Workload 'Intune' -SkipKnownIssues
```

## CI/CD Integration

GitHub Actions workflows are provided in `.github/workflows/`:

- `deployment-tests-aad.yml`  – AAD workload
- `deployment-tests-exo.yml`  – Exchange Online workload
- `deployment-tests-intune.yml` – Intune workload
- etc.

Each workflow runs on a self-hosted runner with access to a dedicated test tenant.
