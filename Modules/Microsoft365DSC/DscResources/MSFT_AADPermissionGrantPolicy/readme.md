# AADPermissionGrantPolicy

## Description

This resource configures an Entra Permission Grant Policy with its associated include and exclude condition sets.

Permission Grant Policies allow organizations to delegate admin consent capabilities for specific Microsoft Graph permissions to non-Global Administrator users and groups.

This resource combines the parent policy and its condition sets into a single configuration, managing:
- The parent permission grant policy properties (Id, DisplayName, Description)
- Include condition sets as an embedded CIM instance array
- Exclude condition sets as an embedded CIM instance array
