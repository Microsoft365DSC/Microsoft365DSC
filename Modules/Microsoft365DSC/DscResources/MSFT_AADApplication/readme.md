# AADApplication

## Description

This resource configures an Azure Active Directory Application.

**Please note:** When configuring `IdentifierUris`, be aware of schema restrictions. Please visit [Restrictions on identifier URIs of Microsoft Entra applications](https://learn.microsoft.com/en-us/entra/identity-platform/identifier-uri-restrictions) for further information.

**Please note:** `TokenEncryptionKeyId` names the `keyId` of an entry in the `KeyCredentials` collection of the application, and the service only accepts a key whose `Usage` is `Encrypt` and whose `Type` is `AsymmetricX509Cert`. This resource writes key credentials after the application itself. The key must already be present before a configuration can reference it.
