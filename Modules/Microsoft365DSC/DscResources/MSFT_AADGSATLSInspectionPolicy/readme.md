# AADGSATLSInspectionPolicy

## Description

Manages TLS Inspection Policies in Global Secure Access, including the default action for unmatched traffic and the policy's rules. The `Rules` property is fully declarative: any policy rule that exists in the tenant but is not listed in the configuration is removed on the next `Set`. The two rules Global Secure Access auto-creates on every policy ("System Bypass TLS inspection rule" and "Recommended TLS inspection bypass categories rule") are ignored entirely and never appear in `Get`/export output or get removed.
