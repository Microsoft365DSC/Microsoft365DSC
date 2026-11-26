# Web Content Filtering Policy

## Description

The **AADGSAWebContentFilteringPolicy** resource manages Web Content Filtering Policies
in Microsoft Entra Global Secure Access, against the `networkAccess/webFilteringPolicies`
Graph endpoint. These policies define the traffic filtering rules used to allow or block
access to specific URLs and web content categories. The `Rules` property is fully
declarative: any policy rule that exists in the tenant but is not listed in the
configuration is removed on the next `Set`.

## Azure AD Permissions

To use this resource the following permissions are required:

| Type        | Permissions                  |
|-------------|------------------------------|
| Delegated   | NetworkAccess.ReadWrite.All  |
| Application | NetworkAccess.ReadWrite.All  |
