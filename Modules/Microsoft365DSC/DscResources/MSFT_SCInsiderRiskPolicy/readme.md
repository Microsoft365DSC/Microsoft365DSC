# SCInsiderRiskPolicy

## Description

Configures Insider Risk Policies in Purview.

The `TenantSetting` scenario configures the tenant-wide insider risk settings, which live in a single
policy that the service creates when Insider Risk Management is turned on. The indicator, notification,
adaptive protection and analytics properties apply to this scenario.

Every other scenario manages a regular policy, which supports the indicator properties,
`HistoricTimeSpan` and `InScopeTimeSpan`.
