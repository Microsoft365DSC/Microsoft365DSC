# AADServicePrincipal

## Description

This resource configures an Azure Active Directory ServicePrincipal.

**Please note:** When configuring a service principal for a SAML authentication, the `ServicePrincipalNames` property must contain at least two entries:

- The Id of the corresponding App Registration (GUID, not Display Name)
- A unique identifier that is not the name of the service principal or it's AppId

The unique identifier is used to configure `IdentifierUris` on the App Registration object.

**Please note:** `TokenEncryptionKeyId` names the `keyId` of an entry in the `KeyCredentials` collection of the service principal. This resource does not write key credentials. The certificate must already be present on the service principal before a configuration can reference it.
