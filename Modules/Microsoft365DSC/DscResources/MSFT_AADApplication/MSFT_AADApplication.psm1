using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADApplication : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('DisplayName of the app')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('ObjectID of the app.')]
    [System.String] $ObjectId

    [DscProperty()]
    [System.ComponentModel.Description('AppId for the app.')]
    [System.String] $AppId

    [DscProperty()]
    [System.ComponentModel.Description('The default redirect URI. If specified and there''s no explicit redirect URI in the sign-in request for SAML and OIDC flows, Microsoft Entra ID sends the token to this redirect URI. Microsoft Entra ID also sends the token to this default URI in SAML IdP-initiated single sign-on. The value must match one of the configured redirect URIs for the application.')]
    [System.String] $DefaultRedirectUri

    [DscProperty()]
    [System.ComponentModel.Description('A free text field to provide a description of the application object to end users. The maximum allowed size is 1024 characters.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('A bitmask that configures the groups claim issued in a user or OAuth 2.0 access token that the application expects.')]
    [System.String] $GroupMembershipClaims

    [DscProperty()]
    [System.ComponentModel.Description('The URL to the application''s homepage.')]
    [System.String] $Homepage

    [DscProperty()]
    [System.ComponentModel.Description('User-defined URI(s) that uniquely identify a Web application within its Azure AD tenant, or within a verified custom domain.')]
    [System.String[]] $IdentifierUris

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether this application supports device authentication without a user. The default is false.')]
    [System.Nullable[System.Boolean]] $IsDeviceOnlyAuthSupported

    [DscProperty()]
    [System.ComponentModel.Description('Deactivate an app without deleting it. This configuration specifies whether the service principal of the app in a tenant or across tenants for multi-tenant apps can obtain new access tokens or access protected resources. When set to true, existing tokens remain valid until they expire based on their configured lifetimes, and the app stays visible in the Enterprise apps list but users cannot sign in.true if the application is deactivated (disabled); otherwise false. Learn more in Deactivate an app registration.')]
    [System.Nullable[System.Boolean]] $IsDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the fallback application type as public client, such as an installed application running on a mobile device. The default value is false, which means the fallback application type is confidential client such as web app. There are certain scenarios where Microsoft Entra ID cannot determine the client application type (for example, ROPC flow where it is configured without specifying a redirect URI). In those cases, Microsoft Entra ID will interpret the application type based on the value of this property.')]
    [System.Nullable[System.Boolean]] $IsFallbackPublicClient

    [DscProperty()]
    [System.ComponentModel.Description('Client applications that are tied to this resource application.')]
    [System.String[]] $KnownClientApplications

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the Native Authentication APIs are enabled for the application. The possible values are: noneand all. Default is none. For more information, see Native Authentication.')]
    [ValidateSet('none', 'all')]
    [System.String] $NativeAuthenticationApisEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Notes relevant for the management of the application.')]
    [System.String] $Notes

    [DscProperty()]
    [System.ComponentModel.Description('Application developers can configure optional claims in their Microsoft Entra applications to specify the claims that are sent to their application by the Microsoft security token service. For more information, see How to: Provide optional claims to your app.')]
    [MSFT_MicrosoftGraphoptionalClaims] $OptionalClaims

    [DscProperty()]
    [System.ComponentModel.Description('Specifies settings for an application that implements a web API.')]
    [MSFT_MicrosoftGraphapiApplication] $Api

    [DscProperty()]
    [System.ComponentModel.Description('The collection of breaking change behaviors related to token issuance that are configured for the application. Authentication behaviors are unset by default (null) and must be explicitly enabled or disabled. Nullable. Returned only on $select.  For more information about authentication behaviors, see Manage application authenticationBehaviors to avoid unverified use of email claims for user identification or authorization.')]
    [MSFT_MicrosoftGraphauthenticationBehaviors] $AuthenticationBehaviors

    [DscProperty()]
    [System.ComponentModel.Description('The collection of password credentials associated with the application. Not nullable.')]
    [MSFT_MicrosoftGraphpasswordCredential[]] $PasswordCredentials

    [DscProperty()]
    [System.ComponentModel.Description('The collection of key credentials associated with the application. Not nullable. Supports $filter (eq, not, ge, le).')]
    [MSFT_MicrosoftGraphkeyCredential[]] $KeyCredentials

    [DscProperty()]
    [System.ComponentModel.Description('The object that contains information urls.')]
    [MSFT_MicrosoftGraphInformationalUrl] $Info

    [DscProperty()]
    [System.ComponentModel.Description('The base64 encoded content of the logo.')]
    [System.String] $Logo

    [DscProperty()]
    [System.ComponentModel.Description('The collection of roles defined for the application. With app role assignments, these roles can be assigned to users, groups, or service principals associated with other applications. Not nullable.')]
    [MSFT_MicrosoftGraphappRole[]] $AppRoles

    [DscProperty()]
    [System.ComponentModel.Description('The logout url for this application.')]
    [System.String] $LogoutURL

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether this application is a public client (such as an installed application running on a mobile device). Default is false.')]
    [System.Nullable[System.Boolean]] $PublicClient

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the URLs that user tokens are sent to for sign in, or the redirect URIs that OAuth 2.0 authorization codes and access tokens are sent to.')]
    [System.String[]] $ReplyURLs

    [DscProperty()]
    [System.ComponentModel.Description('UPN or ObjectID values of the app''s owners.')]
    [System.String[]] $Owners

    [DscProperty()]
    [System.ComponentModel.Description('Represents the set of properties required for configuring Application Proxy for this application. Configuring these properties allows you to publish your on-premises application for secure remote access.')]
    [MSFT_AADApplicationOnPremisesPublishing] $OnPremisesPublishing

    [DscProperty()]
    [System.ComponentModel.Description('Identifier of the associated Application Template.')]
    [System.String] $ApplicationTemplateId

    [DscProperty()]
    [System.ComponentModel.Description('List of public clients redirect URIs.')]
    [System.String[]] $PublicClientRedirectUris

    [DscProperty()]
    [System.ComponentModel.Description('The URL where the service exposes SAML metadata for federation. This property is valid only for single-tenant applications. Nullable.')]
    [System.String] $SamlMetadataUrl

    [DscProperty()]
    [System.ComponentModel.Description('References application or service contact information from a Service or Asset Management database. Nullable.')]
    [System.String] $ServiceManagementReference

    [DscProperty()]
    [System.ComponentModel.Description('List of single page application settings.')]
    [MSFT_AADApplicationSpa] $Spa

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the Microsoft accounts that are supported for the current application. The possible values are: AzureADMyOrg (default), AzureADMultipleOrgs, AzureADandPersonalMicrosoftAccount, and PersonalMicrosoftAccount')]
    [ValidateSet('AzureADandPersonalMicrosoftAccount', 'AzureADMultipleOrgs', 'AzureADMyOrg', 'PersonalMicrosoftAccount')]
    [System.String] $SignInAudience

    [DscProperty()]
    [System.ComponentModel.Description('Custom strings that can be used to categorize and identify the application. Not nullable. Strings added here also appear in the tags property of any associated service principals.Supports $filter (eq, not, ge, le, startsWith) and $search.')]
    [System.String[]] $Tags

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the keyId of a public key from the keyCredentials collection. When configured, Microsoft Entra ID encrypts all the tokens it emits by using the key this property points to. The application code that receives the encrypted token must use the matching private key to decrypt the token before it can be used for the signed-in user.')]
    [System.String] $TokenEncryptionKeyId

    [DscProperty()]
    [System.ComponentModel.Description('The Token Lifetime Policy assigned to the application with its DisplayName.')]
    [System.String] $TokenLifetimePolicy

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Azure AD App should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials for the Microsoft Graph delegated permissions.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('API permissions for the Azure Active Directory Application.')]
    [MSFT_AADApplicationPermission[]] $RequiredResourceAccess

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Azure Active Directory application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    AADApplication() : base()
    {
        $this.ResourceCache['PropertiesToRetrieve'] = 'appRoles, defaultRedirectUri, info, identifierUris, displayName, description, groupMembershipClaims, optionalClaims, web, api, id, appId, spa, applicationTemplateId, serviceManagementReference, signInAudience, authenticationBehaviors, isFallbackPublicClient, publicClient, keyCredentials, passwordCredentials, requiredResourceAccess, isDeviceOnlyAuthSupported, isDisabled, nativeAuthenticationApisEnabled, notes, samlMetadataUrl, tags, tokenEncryptionKeyId'
    }

    [AADApplication] Get()
    {
        $logoResponse = $null
        $lifetimePolicy = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADApplication]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Azure AD Application '$($this.DisplayName)'"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'
                $AADApp = $null

                try
                {
                    if (-not [System.String]::IsNullOrEmpty($this.AppId))
                    {
                        [array]$AADApp = Get-MgBetaApplication `
                            -Filter "AppId eq '$($this.AppId)'" `
                            -Property $this.ResourceCache['PropertiesToRetrieve'] `
                            -ExpandProperty 'owners'
                    }
                }
                catch
                {
                    Write-Verbose -Message "Could not retrieve AzureAD Application by Application ID {$($this.AppId)}"
                }

                if ($null -eq $AADApp)
                {
                    Write-Verbose -Message "Attempting to retrieve Azure AD Application by DisplayName {$($this.DisplayName)}"
                    [array]$AADApp = Get-MgBetaApplication `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -Property $this.ResourceCache['PropertiesToRetrieve'] `
                            -ExpandProperty 'owners'
                }
                if ($null -ne $AADApp -and $AADApp.Count -gt 1)
                {
                    throw "Multiple AAD Apps with the Displayname $($this.DisplayName) exist in the tenant."
                }
                elseif ($null -eq $AADApp)
                {
                    Write-Verbose -Message 'Could not retrieve and instance of the Azure AD App in the Get() method.'
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $AADApp = $this.ExportedInstance
            }
            Write-Verbose -Message 'An instance of Azure AD App was retrieved.'

            $AADAppKeyCredentials = $AADApp.KeyCredentials

            $complexAuthenticationBehaviors = @{
                BlockAzureADGraphAccess    = 'Null'
                RemoveUnverifiedEmailClaim = 'Null'
            }
            if ($null -ne $AADApp.authenticationBehaviors.blockAzureADGraphAccess)
            {
                $complexAuthenticationBehaviors.BlockAzureADGraphAccess = $AADApp.authenticationBehaviors.blockAzureADGraphAccess.ToString()
            }
            if ($null -ne $AADApp.authenticationBehaviors.removeUnverifiedEmailClaim)
            {
                $complexAuthenticationBehaviors.RemoveUnverifiedEmailClaim = $AADApp.authenticationBehaviors.removeUnverifiedEmailClaim.ToString()
            }

            $complexOptionalClaims = [ordered]@{}
            $complexAccessToken = @()
            foreach ($currentAccessToken in $AADApp.optionalClaims.accessToken)
            {
                $myAccessToken = [ordered]@{}
                $myAccessToken.Add('Essential', $currentAccessToken.essential)
                $myAccessToken.Add('Name', $currentAccessToken.name)
                $myAccessToken.Add('Source', $currentAccessToken.source)
                if ($myAccessToken.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexAccessToken += $myAccessToken
                }
            }
            $complexOptionalClaims.Add('AccessToken', $complexAccessToken)
            $complexIdToken = @()
            foreach ($currentIdToken in $AADApp.optionalClaims.idToken)
            {
                $myIdToken = [ordered]@{}
                $myIdToken.Add('Essential', $currentIdToken.essential)
                $myIdToken.Add('Name', $currentIdToken.name)
                $myIdToken.Add('Source', $currentIdToken.source)
                if ($myIdToken.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexIdToken += $myIdToken
                }
            }
            $complexOptionalClaims.Add('IdToken', $complexIdToken)
            $complexSaml2Token = @()
            foreach ($currentSaml2Token in $AADApp.optionalClaims.saml2Token)
            {
                $mySaml2Token = [ordered]@{}
                $mySaml2Token.Add('Essential', $currentSaml2Token.essential)
                $mySaml2Token.Add('Name', $currentSaml2Token.name)
                $mySaml2Token.Add('Source', $currentSaml2Token.source)
                if ($mySaml2Token.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexSaml2Token += $mySaml2Token
                }
            }
            $complexOptionalClaims.Add('Saml2Token', $complexSaml2Token)
            if ($complexOptionalClaims.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexOptionalClaims = $null
            }

            $complexApi = [ordered]@{}
            $complexPreAuthorizedApplications = @()
            foreach ($currentPreAuthorizedApplications in $AADApp.api.preAuthorizedApplications)
            {
                $myPreAuthorizedApplications = [ordered]@{}
                $servicePrincipal = $null
                $servicePrincipalsByAppId = $this.ResourceCache['ServicePrincipalsByAppId']
                if ($null -ne $servicePrincipalsByAppId)
                {
                    if ($servicePrincipalsByAppId.ContainsKey([System.String]$currentPreAuthorizedApplications.appId))
                    {
                        $servicePrincipal = $servicePrincipalsByAppId[[System.String]$currentPreAuthorizedApplications.appId]
                    }
                }
                else
                {
                    $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$($currentPreAuthorizedApplications.appId)'" -Property "displayName"
                }
                if ($null -eq $servicePrincipal)
                {
                    Write-Warning -Message "Could not find service principal with AppId {$($currentPreAuthorizedApplications.appId)} for pre-authorized application. DisplayName will not be included in the configuration."
                    continue
                }
                $myPreAuthorizedApplications.Add('AppId', $servicePrincipal.displayName)
                $permissionIds = @()
                foreach ($permissionId in $currentPreAuthorizedApplications.PermissionIds)
                {
                    $permission = $AADApp.Api.Oauth2PermissionScopes | Where-Object -FilterScript { $_.Id -eq $permissionId }
                    if ($null -eq $permission)
                    {
                        Write-Warning -Message "Could not find existing permission with ID {$permissionId} in the application for pre-authorized application. DisplayName will not be included in the configuration."
                        continue
                    }
                    $permissionIds += $permission.Value
                }
                $myPreAuthorizedApplications.Add('PermissionIds', $permissionIds)
                if ($myPreAuthorizedApplications.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexPreAuthorizedApplications += $myPreAuthorizedApplications
                }
            }

            $complexOAuth2Scopes = @()
            foreach ($currentOAuth2Scope in $AADApp.api.Oauth2PermissionScopes)
            {
                $complexOAuth2Scopes += @{
                    adminConsentDescription = $currentOAuth2Scope.adminConsentDescription
                    adminConsentDisplayName = $currentOAuth2Scope.adminConsentDisplayName
                    id                      = $currentOAuth2Scope.id
                    isEnabled               = $currentOAuth2Scope.isEnabled
                    type                    = $currentOAuth2Scope.type
                    userConsentDescription  = $currentOAuth2Scope.userConsentDescription
                    userConsentDisplayName  = $currentOAuth2Scope.userConsentDisplayName
                    value                   = $currentOAuth2Scope.value
                }
            }

            $complexApi.Add('PreAuthorizedApplications', $complexPreAuthorizedApplications)
            $complexApi.Add('Oauth2PermissionScopes', $complexOAuth2Scopes)
            if ($complexApi.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexApi = $null
            }

            $complexKeyCredentials = @()
            foreach ($currentkeyCredentials in $AADAppKeyCredentials)
            {
                $mykeyCredentials = [ordered]@{}
                if ($null -ne $currentkeyCredentials.customKeyIdentifier)
                {
                    $mykeyCredentials.Add('CustomKeyIdentifier', $currentkeyCredentials.customKeyIdentifier)
                }
                $mykeyCredentials.Add('DisplayName', $currentkeyCredentials.displayName)
                if ($null -ne $currentkeyCredentials.endDateTime)
                {
                    $mykeyCredentials.Add('EndDateTime', ([DateTimeOffset]$currentkeyCredentials.endDateTime).ToString('o'))
                }
                $mykeyCredentials.Add('KeyId', $currentkeyCredentials.keyId)

                if ($null -ne $currentkeyCredentials.Key)
                {
                    $mykeyCredentials.Add('Key', $currentkeyCredentials.Key)
                }

                if ($null -ne $currentkeyCredentials.startDateTime)
                {
                    $mykeyCredentials.Add('StartDateTime', ([DateTimeOffset]$currentkeyCredentials.startDateTime).ToString('o'))
                }
                $mykeyCredentials.Add('Type', $currentkeyCredentials.type)
                $mykeyCredentials.Add('Usage', $currentkeyCredentials.usage)
                if ($mykeyCredentials.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexKeyCredentials += $mykeyCredentials
                }
            }

            $complexPasswordCredentials = @()
            foreach ($currentpasswordCredentials in $AADApp.passwordCredentials)
            {
                $mypasswordCredentials = [ordered]@{}
                $mypasswordCredentials.Add('DisplayName', $currentpasswordCredentials.displayName)
                if ($null -ne $currentpasswordCredentials.endDateTime)
                {
                    $mypasswordCredentials.Add('EndDateTime', ([DateTimeOffset]$currentpasswordCredentials.endDateTime).ToString('o'))
                }
                $mypasswordCredentials.Add('Hint', $currentpasswordCredentials.hint)
                $mypasswordCredentials.Add('KeyId', $currentpasswordCredentials.keyId)
                if ($null -ne $currentpasswordCredentials.startDateTime)
                {
                    $mypasswordCredentials.Add('StartDateTime', ([DateTimeOffset]$currentpasswordCredentials.startDateTime).ToString('o'))
                }
                if ($mypasswordCredentials.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexPasswordCredentials += $mypasswordCredentials
                }
            }

            $complexAppRoles = @()
            foreach ($currentappRoles in ($AADApp.appRoles | Sort-Object -Property 'id'))
            {
                $myappRoles = [ordered]@{}
                $myappRoles.Add('AllowedMemberTypes', $currentappRoles.allowedMemberTypes)
                $myappRoles.Add('Description', $currentappRoles.description)
                $myappRoles.Add('DisplayName', $currentappRoles.displayName)
                $myappRoles.Add('Id', $currentappRoles.id)
                $myappRoles.Add('IsEnabled', $currentappRoles.isEnabled)
                $myappRoles.Add('Origin', $currentappRoles.origin)
                $myappRoles.Add('Value', $(if ($null -eq $currentappRoles.value) { "" } else { $currentappRoles.value }))
                if ($myappRoles.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexAppRoles += $myappRoles
                }
            }

            #YK: Added Array typecasting
            [Array]$permissionsObj = $this.GetAzureADAppPermissions($AADApp)
            $isPublicClient = $false
            if (-not [System.String]::IsNullOrEmpty($AADApp.PublicClient) -and $AADApp.PublicClient -eq $true)
            {
                $isPublicClient = $true
            }

            $PublicClientRedirectUrisValue = $null
            if ($null -ne $AADApp.PublicClient -and $AADApp.PublicClient.RedirectUris.Length -gt 0)
            {
                $PublicClientRedirectUrisValue = $AADApp.PublicClient.RedirectUris
            }

            $OwnersValues = @()
            $appOwners = $this.ResolveExpandedNavigation($AADApp, 'Owners')
            if ($null -eq $appOwners)
            {
                $appOwners = Get-MgApplicationOwner -ApplicationId $AADApp.Id -All
            }
            foreach ($Owner in $($appOwners | Where-Object { -not $_.DeletedDateTime }))
            {
                if ($Owner.userPrincipalName)
                {
                    $OwnersValues += $Owner.userPrincipalName
                }
                else
                {
                    $OwnersValues += $Owner.displayName
                }
            }

            $IsFallbackPublicClientValue = $false
            if ($AADApp.IsFallbackPublicClient)
            {
                $IsFallbackPublicClientValue = $AADApp.IsFallbackPublicClient
            }

            #region OnPremisesPublishing & TokenLifetimePolicies
            $onPremisesPublishingValue = [ordered]@{}
            $oppInfo = $null

            try
            {
                $batchRequests = @(
                    @{
                        id     = 'onPremisesPublishing'
                        method = 'GET'
                        url    = "/applications/$($AADApp.Id)/onPremisesPublishing"
                    }
                    @{
                        id     = 'tokenLifetimePolicies'
                        method = 'GET'
                        url    = "/applications/$($AADApp.Id)/tokenLifetimePolicies"
                    }
                )
                $batchResponses = $null
                $navigationCache = $this.ResourceCache['NavigationCache']
                if ($null -ne $navigationCache -and $navigationCache.ContainsKey([System.String]$AADApp.Id))
                {
                    $batchResponses = $navigationCache[[System.String]$AADApp.Id]
                }
                if ($null -eq $batchResponses)
                {
                    $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests
                }

                $oppInfo = ($batchResponses | Where-Object -FilterScript { $_.id -eq 'onPremisesPublishing' }).body.value
                $lifetimePolicy = ($batchResponses | Where-Object -FilterScript { $_.id -eq 'tokenLifetimePolicies' }).body.value | Select-Object -First 1

                if (-not [System.String]::IsNullOrEmpty($AADApp.Info.LogoUrl))
                {
                    $logoResponse = Invoke-WebRequest -Uri $AADApp.Info.LogoUrl -Method Get -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
                    $logoResponse = [System.Convert]::ToBase64String($logoResponse.Content)
                }
            }
            catch
            {
                Write-Verbose -Message "On-premises publishing is not enabled for App {$($AADApp.DisplayName)}"
            }

            if ($null -ne $oppInfo)
            {
                $onPremisesPublishingValue = @{
                    alternateUrl                          = $oppInfo.alternateUrl
                    applicationServerTimeout              = $oppInfo.applicationServerTimeout
                    externalAuthenticationType            = $oppInfo.externalAuthenticationType
                    externalUrl                           = $oppInfo.externalUrl
                    internalUrl                           = $oppInfo.internalUrl
                    isBackendCertificateValidationEnabled = $oppInfo.isBackendCertificateValidationEnabled
                    isHttpOnlyCookieEnabled               = $oppInfo.isHttpOnlyCookieEnabled
                    isPersistentCookieEnabled             = $oppInfo.isPersistentCookieEnabled
                    isSecureCookieEnabled                 = $oppInfo.isSecureCookieEnabled
                    isStateSessionEnabled                 = $oppInfo.isStateSessionEnabled
                    isTranslateHostHeaderEnabled          = $oppInfo.isTranslateHostHeaderEnabled
                    isTranslateLinksInBodyEnabled         = $oppInfo.isTranslateLinksInBodyEnabled
                }

                # onPremisesApplicationSegments
                $segmentValues = @()
                foreach ($segment in $oppInfo.onPremisesApplicationSegments)
                {
                    $entry = @{
                        alternateUrl = $segment.AlternateUrl
                        externalUrl  = $segment.externalUrl
                        internalUrl  = $segment.internalUrl
                    }

                    $corsConfigurationValues = @()
                    foreach ($cors in $segment.corsConfigurations)
                    {
                        $corsEntry = @{
                            allowedHeaders  = [Array]($cors.allowedHeaders)
                            allowedMethods  = [Array]($cors.allowedMethods)
                            allowedOrigins  = [Array]($cors.allowedOrigins)
                            maxAgeInSeconds = $cors.maxAgeInSeconds
                            resource        = $cors.resource
                        }
                        $corsConfigurationValues += $corsEntry
                    }
                    $entry.Add('corsConfigurations', $corsConfigurationValues)
                    $segmentValues += $entry
                }
                $onPremisesPublishingValue.Add('onPremisesApplicationSegments', $segmentValues)

                # singleSignOnSettings
                $singleSignOnValues = @{
                    singleSignOnMode = $oppInfo.singleSignOnSettings.singleSignOnMode
                }
                if ($oppInfo.singleSignOnMode.kerberosSignOnSettings)
                {
                    $kerberosSignOnSettings = @{
                        kerberosServicePrincipalName       = $oppInfo.singleSignOnSettings.kerberosSignOnSettings.kerberosServicePrincipalName
                        kerberosSignOnMappingAttributeType = $oppInfo.singleSignOnSettings.kerberosSignOnSettings.kerberosSignOnMappingAttributeType
                    }
                    $singleSignOnValues.Add('kerberosSignOnSettings', $kerberosSignOnSettings)
                }
                $onPremisesPublishingValue.Add('singleSignOnSettings', $singleSignOnValues)
            }
            #endregion

            $IdentifierUrisValue = @()
            if ($null -ne $AADApp.IdentifierUris)
            {
                $IdentifierUrisValue = $AADApp.IdentifierUris
            }

            $TagsValue = @()
            if ($null -ne $AADApp.Tags)
            {
                $TagsValue = $AADApp.Tags
            }

            $complexInfoValue = $null
            if ($null -ne $AADApp.Info)
            {
                $complexInfoValue = @{
                    MarketingUrl        = $AADApp.Info.MarketingUrl
                    PrivacyStatementUrl = $AADApp.Info.PrivacyStatementUrl
                    SupportUrl          = $AADApp.Info.SupportUrl
                    TermsOfServiceUrl   = $AADApp.Info.TermsOfServiceUrl
                }
            }

            $spaValue = $null
            if ($null -ne $AADApp.Spa -and $AADApp.Spa.RedirectUris.Length -gt 0)
            {
                $spaValue = @{
                    RedirectUris = $AADApp.Spa.RedirectUris
                }
            }

            $result = @{
                Api                             = $complexApi
                AppId                           = $AADApp.AppId
                ApplicationTemplateId           = $AADApp.applicationTemplateId
                AppRoles                        = $complexAppRoles
                AuthenticationBehaviors         = $complexAuthenticationBehaviors
                DefaultRedirectUri              = $AADApp.DefaultRedirectUri
                Description                     = $AADApp.Description
                DisplayName                     = $AADApp.DisplayName
                GroupMembershipClaims           = $AADApp.GroupMembershipClaims
                Homepage                        = $AADApp.web.HomepageUrl
                IdentifierUris                  = $IdentifierUrisValue
                Info                            = $complexInfoValue
                IsDeviceOnlyAuthSupported       = $AADApp.IsDeviceOnlyAuthSupported
                IsDisabled                      = $AADApp.IsDisabled
                IsFallbackPublicClient          = $IsFallbackPublicClientValue
                KeyCredentials                  = $complexKeyCredentials
                KnownClientApplications         = $AADApp.Api.KnownClientApplications
                Logo                            = $logoResponse
                LogoutURL                       = $AADApp.web.LogoutURL
                NativeAuthenticationApisEnabled = $AADApp.NativeAuthenticationApisEnabled
                Notes                           = $AADApp.Notes
                ObjectId                        = $AADApp.Id
                OnPremisesPublishing            = $onPremisesPublishingValue
                OptionalClaims                  = $complexOptionalClaims
                Owners                          = $OwnersValues
                PasswordCredentials             = $complexPasswordCredentials
                RequiredResourceAccess          = $permissionsObj
                PublicClient                    = $isPublicClient
                PublicClientRedirectUris        = $PublicClientRedirectUrisValue
                ReplyURLs                       = $AADApp.web.RedirectUris
                SamlMetadataUrl                 = $AADApp.SamlMetadataUrl
                ServiceManagementReference      = $AADApp.ServiceManagementReference
                SignInAudience                  = $AADApp.SignInAudience
                Spa                             = $spaValue
                Tags                            = $TagsValue
                TokenEncryptionKeyId            = $AADApp.TokenEncryptionKeyId
                TokenLifetimePolicy             = $lifetimePolicy.displayName
                Ensure                          = 'Present'
                Credential                      = $this.Credential
                ApplicationId                   = $this.ApplicationId
                TenantId                        = $this.TenantId
                ApplicationSecret               = $this.ApplicationSecret
                CertificateThumbprint           = $this.CertificateThumbprint
                CertificatePath                 = $this.CertificatePath
                CertificatePassword             = $this.CertificatePassword
                ManagedIdentity                 = $this.ManagedIdentity
                AccessTokens                    = $this.AccessTokens
            }

            return $this.AsResult($result)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        $tries = $null
        $deletedApp = $null
        $appEntity = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of Azure AD Application '$($this.DisplayName)'"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        # Ensure we throw an error if PublicClient is set to $true and we're trying to also configure either RequiredResourceAccess
        # or IdentifierUris
        if ($this.PublicClient -and ($this.RequiredResourceAccess.Length -gt 0 -or $this.IdentifierUris.Length -gt 0))
        {
            $ErrorMessage = 'It is not possible to set RequiredResourceAccess or IdentifierUris when the PublicClient property is ' + `
                "set to `$true. Application will not be created. To fix this, modify the configuration to set the " + `
                "PublicClient property to `$false, or remove the RequiredResourceAccess and IdentifierUris properties from your configuration."
            Add-M365DSCEvent -Message $ErrorMessage -EntryType 'Error' `
                -EventID 1 -Source $($this.GetResourceName())
            throw $ErrorMessage
        }

        $currentAADApp = $this.Get().ToHashtable()
        $currentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $backCurrentOwners = @()
        if ($currentAADApp.Ensure -eq 'Present')
        {
            $backCurrentOwners = $currentAADApp.Owners
        }
        $currentParameters.Remove('Owners') | Out-Null

        if ($this.KnownClientApplications)
        {
            Write-Verbose -Message 'Checking if the known client applications already exist.'
            $testedKnownClientApplications = New-Object System.Collections.Generic.List[string]
            foreach ($KnownClientApplication in $this.KnownClientApplications)
            {
                $knownAADApp = $null
                $knownAADApp = Get-MgBetaApplication -Filter "AppID eq '$($KnownClientApplication)'"
                if ($null -ne $knownAADApp)
                {
                    $testedKnownClientApplications.Add($knownAADApp.AppId)
                }
                else
                {
                    Write-Verbose -Message "Could not find an existing app with the app ID $($KnownClientApplication)"
                }
            }
            $currentParameters.Remove('KnownClientApplications') | Out-Null
            $currentParameters.Add('KnownClientApplications', $testedKnownClientApplications)
        }

        # App should exist but it doesn't
        $needToUpdatePermissions = $false
        $needToUpdateKeyCredentials = $false
        $currentParameters.Remove('AppId') | Out-Null
        $currentParameters.Remove('Logo') | Out-Null
        $currentParameters.Remove('RequiredResourceAccess') | Out-Null
        $currentParameters.Remove('AuthenticationBehaviors') | Out-Null
        $currentParameters.Remove('KeyCredentials') | Out-Null
        $currentParameters.Remove('PasswordCredentials') | Out-Null
        if ($this.PasswordCredentials)
        {
            Write-Warning -Message 'PasswordCredentials is a readonly property and cannot be configured.'
        }

        $currentParameters.Remove('PublicClient') | Out-Null
        if ($this.PublicClientRedirectUris.Length -gt 0)
        {
            Write-Verbose -Message 'PublicClientRedirectUris were specified'
            $PublicClientValue = @{
                RedirectUris = $this.PublicClientRedirectUris
            }
            $currentParameters.Add('PublicClient', $PublicClientValue)
        }
        $currentParameters.Remove('PublicClientRedirectUris') | Out-Null

        #region API
        $apiValue = @{}
        if ($currentParameters.Api.KnownClientApplications)
        {
            $apiValue.Add('KnownClientApplications', $currentParameters.Api.KnownClientApplications)
        }
        if ($currentParameters.Api.Oauth2PermissionScopes)
        {
            Write-Verbose -Message 'Oauth2PermissionScopes specified and is not empty'
            $scopeValue = @()
            foreach ($scope in $currentParameters.Api.Oauth2PermissionScopes)
            {
                $scopeEntry = @{
                    adminConsentDescription = $scope.adminConsentDescription
                    adminConsentDisplayName = $scope.adminConsentDisplayName
                    isEnabled               = $scope.isEnabled
                    type                    = $scope.type
                    userConsentDescription  = $scope.userConsentDescription
                    userConsentDisplayName  = $scope.userConsentDisplayName
                    value                   = $scope.value
                }
                if (-not [System.String]::IsNullOrEmpty($scope.id))
                {
                    Write-Verbose -Message "Adding existing scope id {$($scope.id)}"
                    $scopeEntry.Add('id', $scope.id)
                }
                else
                {
                    Write-Verbose -Message "Retrieving Scope by Display Name {$($scope.value)}"

                    $existingScope = $currentAADApp.Api.Oauth2PermissionScopes | Where-Object -FilterScript { $_.Value -eq $scope.value }
                    $existingScopeId = (New-Guid).ToString()
                    if ($null -ne $existingScope)
                    {
                        $existingScopeId = $existingScope.Id
                        Write-Verbose -Message "Found existing scope with ID {$existingScopeId}"
                    }

                    Write-Verbose -Message "Adding scope ID {$existingScopeId}"
                    $scopeEntry.Add('id', $existingScopeId)
                }

                $scopeValue += $scopeEntry
            }
            $apiValue.Add('Oauth2PermissionScopes', $scopeValue)
        }

        # Pre-Authorized Applications
        if ($currentParameters.Api.PreAuthorizedApplications)
        {
            $PreAuthorizedApplicationsValue = @()

            foreach ($preAuthApp in $currentParameters.Api.PreAuthorizedApplications)
            {
                if ($preAuthApp.AppId -notmatch "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")
                {
                    $servicePrincipal = Get-MgServicePrincipal -Filter "DisplayName eq '$($preAuthApp.AppId)'" -Property "appId"
                    if ($null -eq $servicePrincipal)
                    {
                        throw "Could not find service principal with DisplayName {$($preAuthApp.AppId)} for pre-authorized application. Please make sure the app exists and the DisplayName is correct."
                    }
                    $preAuthApp.AppId = $servicePrincipal.appId
                }
                $PreAuthorizedApplicationsValue += @{
                    appId                  = $preAuthApp.AppId
                    delegatedPermissionIds = Get-M365DSCArrayFromProperty -PropertyValue ($preAuthApp.PermissionIds | Foreach-Object {
                        if ($_ -match "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")
                        {
                            $_
                        }
                        else
                        {
                            $permission = $currentAADApp.Api.Oauth2PermissionScopes | Where-Object -FilterScript { $_.Value -eq $_ }
                            if ($null -eq $permission)
                            {
                                throw "Could not find existing permission with DisplayName {$_.Value} in the application for pre-authorized application. Please make sure the permission exists and the DisplayName is correct."
                            }
                            $permission.Id
                        }
                    }) -ElementType ([System.String])
                }
            }
            $apiValue.Add('PreAuthorizedApplications', $PreAuthorizedApplicationsValue)
        }
        $currentParameters.Remove('KnownClientApplications') | Out-Null
        #endregion

        if ($currentParameters.ContainsKey('Api'))
        {
            Write-Verbose "Found existing API parameter. Updating with $(Convert-M365DscHashtableToString -Hashtable $apiValue)"
            $currentParameters.Api = $apiValue
        }
        else
        {
            Write-Verbose "Adding API parameter with $(Convert-M365DscHashtableToString -Hashtable $apiValue)"
            $currentParameters.Add('Api', $apiValue)
        }

        if ($this.GetBoundParameters().ContainsKey('ReplyUrls') -or `
            $this.GetBoundParameters().ContainsKey('LogoutURL') -or `
            $this.GetBoundParameters().ContainsKey('Homepage'))
        {
            $webValue = @{}
            if ($this.GetBoundParameters().ContainsKey('ReplyUrls'))
            {
                $webValue.Add('RedirectUris', $currentParameters.ReplyURLs)
            }
            if ($this.GetBoundParameters().ContainsKey('LogoutURL'))
            {
                $webValue.Add('LogoutUrl', $currentParameters.LogoutURL)
            }
            if ($this.GetBoundParameters().ContainsKey('Homepage'))
            {
                $webValue.Add('HomePageUrl', $currentParameters.Homepage)
            }

            $currentParameters.Add('web', $webValue)
        }
        $currentParameters.Remove('ReplyURLs') | Out-Null
        $currentParameters.Remove('LogoutURL') | Out-Null
        $currentParameters.Remove('Homepage') | Out-Null
        $currentParameters.Remove('OnPremisesPublishing') | Out-Null
        $currentParameters = Rename-M365DSCCimInstanceParameter -Properties $currentParameters

        $skipToUpdate = $false
        if ($this.Ensure -eq 'Present' -and $currentAADApp.Ensure -eq 'Absent')
        {
            # Before attempting to create a new instance, let's first check to see if there is already an existing instance that is soft deleted
            if (-not [System.String]::IsNullOrEmpty($this.AppId))
            {
                Write-Verbose "Trying to retrieve existing deleted Applications from soft delete by Id {$($this.AppId)}."
                [Array]$deletedApp = Get-MgBetaDirectoryDeletedItemAsApplication -DirectoryObjectId $this.AppId -ErrorAction SilentlyContinue
            }

            if ($null -eq $deletedApp)
            {
                Write-Verbose "Trying to retrieve existing deleted Applications from soft delete by DisplayName {$($this.DisplayName)}."
                [Array]$deletedApp = Get-MgBetaDirectoryDeletedItemAsApplication -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" -ErrorAction SilentlyContinue
            }

            if ($null -ne $deletedApp -and $deletedApp.Length -eq 1)
            {
                $deletedSinceInDays = [System.DateTime]::Now.Subtract($deletedApp[0].DeletedDateTime).Days
                if ($deletedSinceInDays -le 30)
                {
                    Write-Verbose -Message "Found existing deleted instance of {$($this.DisplayName)}. Restoring it instead of creating a new one. This could take a few minutes to complete."
                    Restore-MgBetaDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id
                    $skipToUpdate = $true
                    $currentAADApp = @{
                        AppId       = $deletedApp.AppId
                        Id          = $deletedApp.Id
                        DisplayName = $deletedApp.DisplayName
                        ObjectId    = $deletedApp.Id
                    }

                    $restoredApp = Get-MgBetaApplication -ApplicationId $currentAADApp.Id -ExpandProperty 'owners'
                    $ownersValues = @()
                    foreach ($owner in $($restoredApp.Owners | Where-Object { -not $_.DeletedDateTime }))
                    {
                        if ($owner.userPrincipalName)
                        {
                            $ownersValues += $owner.userPrincipalName
                        }
                        else
                        {
                            $ownersValues += $owner.displayName
                        }
                    }
                    $backCurrentOwners = $ownersValues
                }
                else
                {
                    Write-Verbose -Message "Found existing deleted instance of {$($this.DisplayName)}. However, the deleted date was over days ago and it cannot be restored. Will recreate a new instance instead."
                }
            }
            elseif ($deletedApp.Length -gt 1)
            {
                Write-Verbose -Message "Multiple instances of a deleted application with name {$($this.DisplayName)} wehre found. Creating a new instance since we can't determine what instance to restore."
            }
        }

        # Create from Template
        if ($this.Ensure -eq 'Present' -and $currentAADApp.Ensure -eq 'Absent' -and -not $skipToUpdate -and `
                -not [System.String]::IsNullOrEmpty($this.ApplicationTemplateId) -and `
                $this.ApplicationTemplateId -ne '8adf8e6e-67b2-4cf2-a259-e3dc5476c621')
        {
            $skipToUpdate = $true
            Write-Verbose -Message "Creating application {$($this.DisplayName)} from Application Template {$($this.ApplicationTemplateId)}"
            $newApp = Invoke-MgBetaInstantiateApplicationTemplate -DisplayName $this.DisplayName `
                -ApplicationTemplateId $this.ApplicationTemplateId
            $currentAADApp = @{
                AppId       = $newApp.Application.AppId
                Id          = $newApp.Application.Id
                DisplayName = $newApp.Application.DisplayName
                ObjectId    = $newApp.Application.Id
            }

            do
            {
                Write-Verbose -Message 'Waiting for 10 seconds'
                Start-Sleep -Seconds 10
                $appEntity = Get-MgBetaApplication -ApplicationId $currentAADApp.Id -ErrorAction SilentlyContinue
                $tries++
            } until ($null -ne $appEntity -or $tries -gt 12)
        }

        if ($this.Ensure -eq 'Present' -and $currentAADApp.Ensure -eq 'Absent' -and -not $skipToUpdate)
        {
            $currentParameters.Remove('ObjectId') | Out-Null
            $currentParameters.Remove('ApplicationTemplateId') | Out-Null
            $currentParameters.Remove('TokenLifetimePolicy') | Out-Null
            Write-Verbose -Message "Creating New AzureAD Application {$($this.DisplayName)} with values:`r`n$($currentParameters | Out-String)"

            Write-Verbose -Message "Parameters with API: $(ConvertTo-Json $currentParameters -Depth 10)"
            $currentAADApp = New-MgBetaApplication -BodyParameter $currentParameters
            $currentAADApp = @{
                AppId       = $currentAADApp.AppId
                Id          = $currentAADApp.Id
                DisplayName = $currentAADApp.DisplayName
                ObjectId    = $currentAADApp.Id
            }
            Write-Verbose -Message "Azure AD Application {$($this.DisplayName)} was successfully created"
            $needToUpdatePermissions = $true
            $needToUpdateKeyCredentials = $true

            $tries = 1
            $appEntity = $null
            do
            {
                Write-Verbose -Message 'Waiting for 10 seconds'
                Start-Sleep -Seconds 10
                $appEntity = Get-MgBetaApplication -ApplicationId $currentAADApp.Id -ErrorAction SilentlyContinue
                $tries++
            } until ($null -ne $appEntity -or $tries -gt 12)
        }
        # App should exist and will be configured to desired state
        elseif (($this.Ensure -eq 'Present' -and $currentAADApp.Ensure -eq 'Present') -or $skipToUpdate)
        {
            $currentParameters.Remove('ObjectId') | Out-Null
            $currentParameters.Remove('ApplicationTemplateId') | Out-Null
            $currentParameters.Remove('AppRoles') | Out-Null
            $currentParameters.Remove('TokenLifetimePolicy') | Out-Null

            Write-Verbose -Message "Updating existing AzureAD Application {$($this.DisplayName)} with values:`r`n$($currentParameters | Out-String)"
            Update-MgBetaApplication -ApplicationId $currentAADApp.ObjectId -BodyParameter $currentParameters

            if (-not $currentAADApp.ContainsKey('Id'))
            {
                $currentAADApp.Add('Id', $currentAADApp.ObjectId)
            }
            $needToUpdatePermissions = $true
            $needToUpdateKeyCredentials = $true

            # Update AppRoles
            if ($null -ne $this.AppRoles)
            {
                Write-Verbose -Message 'AppRoles were specified.'

                # Graph deletes only disabled roles. Disabling kept roles races the PATCH that re-enables them.
                $disabledRoles = @()
                $rolesToRemove = @()
                foreach ($currentRole in $currentAADApp.AppRoles)
                {
                    $associatedDesiredRoleEntry = $this.AppRoles | Where-Object -FilterScript { $_.DisplayName -eq $currentRole.DisplayName }
                    $disabledRoles += @{
                        allowedMemberTypes = $currentRole.AllowedMemberTypes
                        id                 = $currentRole.Id
                        isEnabled          = $currentRole.IsEnabled -and $null -ne $associatedDesiredRoleEntry
                        origin             = $currentRole.Origin
                        value              = $currentRole.Value
                        displayName        = $currentRole.DisplayName
                        description        = $currentRole.Description
                    }
                    if ($null -eq $associatedDesiredRoleEntry)
                    {
                        Write-Verbose -Message "Could not find matching AppRole entry in Desired values for {$($currentRole.DisplayName)}. Will remove role."
                        $rolesToRemove += $currentRole.DisplayName
                    }
                }

                if ($rolesToRemove.Count -gt 0)
                {
                    Write-Verbose -Message "Disabling the AppRoles to remove: {$($rolesToRemove -join ',')}"
                    Update-MgBetaApplication -ApplicationId $currentAADApp.ObjectId -AppRoles $disabledRoles
                }

                $resultingAppRoles = @()
                foreach ($currentAppRole in $this.AppRoles)
                {
                    $entry = @{
                        allowedMemberTypes = $currentAppRole.AllowedMemberTypes
                        id                 = $currentAppRole.Id
                        isEnabled          = $currentAppRole.IsEnabled
                        origin             = $currentAppRole.Origin
                        value              = $currentAppRole.Value
                        displayName        = $currentAppRole.DisplayName
                        description        = $currentAppRole.Description
                    }
                    $resultingAppRoles += $entry
                }
                Write-Verbose -Message 'Updating the AppRoles.'
                $this.UpdateAppRoles($currentAADApp.ObjectId, $resultingAppRoles)
            }
        }
        # App exists but should not
        elseif ($this.Ensure -eq 'Absent' -and $currentAADApp.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing AzureAD Application {$($this.DisplayName)} by ObjectID {$($currentAADApp.ObjectID)}"
            Remove-MgBetaApplication -ApplicationId $currentAADApp.ObjectID
        }

        if ($this.Ensure -ne 'Absent')
        {
            Write-Verbose -Message "Ensuring that the Azure AD Application {$($this.DisplayName)} has the correct Owners."
            $desiredOwnersValue = @()
            if ($this.Owners.Count -gt 0)
            {
                $desiredOwnersValue = $this.Owners
            }

            if (-not $backCurrentOwners)
            {
                $backCurrentOwners = @()
            }
            $ownersDiff = Compare-Object -ReferenceObject $backCurrentOwners -DifferenceObject $desiredOwnersValue
            foreach ($diff in $ownersDiff)
            {
                if ($diff.SideIndicator -eq '=>')
                {
                    Write-Verbose -Message "Adding new owner {$($diff.InputObject)} to AAD Application {$($this.DisplayName)}"
                    if ($diff.InputObject.Contains('@'))
                    {
                        $Type = 'users'
                        $ObjectUri = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + 'v1.0/{0}/{1}' -f $Type, $diff.InputObject
                    }
                    else
                    {
                        $Type = 'directoryObjects'
                        $resolvedObject = Get-MgServicePrincipal -Filter "DisplayName eq '$($diff.InputObject -replace "'", "''")'" -All -ErrorAction SilentlyContinue
                        if ($null -eq $resolvedObject)
                        {
                            throw "Could not find an existing object with DisplayName {$($diff.InputObject)} to add as an owner. Please make sure the object exists and the DisplayName is correct."
                        }
                        $ObjectUri = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + 'v1.0/{0}/{1}' -f $Type, $resolvedObject.Id
                    }
                    $ownerObject = @{
                        '@odata.id' = $ObjectUri
                    }
                    try
                    {
                        New-MgApplicationOwnerByRef -ApplicationId $currentAADApp.ObjectId -BodyParameter $ownerObject | Out-Null
                    }
                    catch
                    {
                        $this.LogError($_, 'Error updating data:')

                        throw
                    }
                }
                elseif ($diff.SideIndicator -eq '<=')
                {
                    Write-Verbose -Message "Removing new owner {$($diff.InputObject)} from AAD Application {$($this.DisplayName)}"
                    try
                    {
                        if ($diff.InputObject.Contains('@'))
                        {
                            $ownerObjectId = $(Get-MgUser -UserId $diff.InputObject -ErrorAction Stop).Id
                        }
                        else
                        {
                            $ownerObjectId = $diff.InputObject
                        }
                        Remove-MgApplicationOwnerDirectoryObjectByRef -ApplicationId $currentAADApp.ObjectId -DirectoryObjectId $ownerObjectId -ErrorAction Stop
                    }
                    catch
                    {
                        $this.LogError($_, 'Error updating data:')

                        throw
                    }
                }
            }
        }

        if ($this.GetBoundParameters().ContainsKey('Logo'))
        {
            Invoke-M365DSCGraphRequest -Uri "/beta/applications/$($currentAADApp.ObjectId)/logo" -Method PUT -Body ([System.Convert]::FromBase64String($this.Logo)) -ContentType 'image/*'
        }

        if ($needToUpdatePermissions -and $null -ne $this.RequiredResourceAccess)
        {
            Write-Verbose -Message "Will update permissions for Azure AD Application {$($currentAADApp.DisplayName)}"

            if ($this.RequiredResourceAccess.Length -eq 0)
            {
                Write-Verbose -Message 'Desired set of permissions is empty, removing all permissions on the app.'
                $allRequiredAccess = @()
            }
            else
            {
                $allSourceAPIs = $this.RequiredResourceAccess.SourceAPI | Select-Object -Unique
                $allRequiredAccess = @()

                foreach ($sourceAPI in $allSourceAPIs)
                {
                    Write-Verbose -Message "Adding permissions for API {$($sourceAPI)}"
                    $permissionsForcurrentAPI = $this.RequiredResourceAccess | Where-Object -FilterScript { $_.SourceAPI -eq $sourceAPI }
                    $apiPrincipal = Get-MgServicePrincipal -Filter "DisplayName eq '$($sourceAPI -replace "'", "''")'"
                    $currentAPIAccess = @{
                        resourceAppId  = $apiPrincipal.AppId
                        resourceAccess = @()
                    }
                    foreach ($permission in $permissionsForcurrentAPI)
                    {
                        if ($permission.Type -eq 'Delegated')
                        {
                            $scope = $apiPrincipal.Oauth2PermissionScopes | Where-Object -FilterScript { $_.Value -eq $permission.Name }
                            $scopeId = $null
                            if ($null -eq $scope)
                            {
                                if ([System.Guid]::TryParse($permission.Name, [ref][System.Guid]::Empty))
                                {
                                    $scopeId = $permission.Name
                                }
                            }
                            else
                            {
                                $scopeId = $scope.Id
                            }
                            Write-Verbose -Message "Adding Delegated Permission {$($scopeId)}"
                            $delPermission = @{
                                id   = $scopeId
                                type = 'Scope'
                            }
                            $currentAPIAccess.resourceAccess += $delPermission
                        }
                        elseif ($permission.Type -eq 'AppOnly')
                        {
                            $role = $apiPrincipal.AppRoles | Where-Object -FilterScript { $_.Value -eq $permission.Name }
                            $roleId = $null
                            if ($null -eq $role)
                            {
                                if ([System.Guid]::TryParse($permission.Name, [ref][System.Guid]::Empty))
                                {
                                    $roleId = $permission.Name
                                }
                            }
                            else
                            {
                                $roleId = $role.Id
                            }
                            if ([System.String]::IsNullOrEmpty($roleId))
                            {
                                throw "Could not find associated role {$($permission.Name)} for API {$($sourceAPI)}"
                            }
                            $appPermission = @{
                                id   = $roleId
                                type = 'Role'
                            }
                            $currentAPIAccess.resourceAccess += $appPermission
                        }
                    }
                    if ($null -ne $currentAPIAccess)
                    {
                        $allRequiredAccess += $currentAPIAccess
                    }
                }
            }

            Write-Verbose -Message "Updating permissions for Azure AD Application {$($currentAADApp.DisplayName)} with RequiredResourceAccess:`r`n$($allRequiredAccess | ConvertTo-Json -Depth 10)"
            Write-Verbose -Message "Current App Id: $($currentAADApp.AppId)"
            Write-Verbose -Message "Current ObjectId: $($currentAADApp.Id)"
            # Even if the property is named ApplicationId, we need to pass in the ObjectId
            Update-MgBetaApplication -ApplicationId ($currentAADApp.ObjectId) `
                -RequiredResourceAccess $allRequiredAccess | Out-Null
        }

        if ($this.GetBoundParameters().ContainsKey('AuthenticationBehaviors'))
        {
            Write-Verbose -Message "Updating for Azure AD Application {$($currentAADApp.DisplayName)} with AuthenticationBehaviors:`r`n$($this.AuthenticationBehaviors| Out-String)"
            Write-Verbose -Message "Current App Id: $($currentAADApp.AppId)"

            $IAuthenticationBehaviors = @{}
            if ($this.AuthenticationBehaviors.BlockAzureADGraphAccess -ne $currentAADApp.AuthenticationBehaviors.BlockAzureADGraphAccess)
            {
                $blockAzureADGraphAccessValue = if ($this.AuthenticationBehaviors.BlockAzureADGraphAccess -eq "Null") { $null } else { $this.AuthenticationBehaviors.BlockAzureADGraphAccess }
                $IAuthenticationBehaviors.Add('blockAzureADGraphAccess', $blockAzureADGraphAccessValue)
            }
            if ($this.AuthenticationBehaviors.RemoveUnverifiedEmailClaim -ne $currentAADApp.AuthenticationBehaviors.RemoveUnverifiedEmailClaim)
            {
                $removeUnverifiedEmailClaimValue = if ($this.AuthenticationBehaviors.RemoveUnverifiedEmailClaim -eq "Null") { $null } else { $this.AuthenticationBehaviors.RemoveUnverifiedEmailClaim }
                $IAuthenticationBehaviors.Add('removeUnverifiedEmailClaim', $removeUnverifiedEmailClaimValue)
            }

            if ($IAuthenticationBehaviors.Keys.Count -gt 0)
            {
                 Write-Verbose -Message "Updating AuthenticationBehaviors for Azure AD Application {$($currentAADApp.DisplayName)} with values:`r`n$($IAuthenticationBehaviors | Out-String)"
                Update-MgBetaApplication -ApplicationId $currentAADApp.ObjectId -BodyParameter @{
                    authenticationBehaviors = $IAuthenticationBehaviors
                } -ErrorAction SilentlyContinue
            }
        }

        if ($needToUpdateKeyCredentials -and $this.KeyCredentials)
        {
            Write-Verbose -Message "Updating for Azure AD Application {$($currentAADApp.DisplayName)} with KeyCredentials:`r`n$($this.KeyCredentials| Out-String)"

            if (($currentAADApp.KeyCredentials.Length -eq 0 -and $this.KeyCredentials.Length -eq 1) -or ($currentAADApp.KeyCredentials.Length -eq 1 -and $this.KeyCredentials.Length -eq 0))
            {
                Update-MgBetaApplication -ApplicationId $currentAADApp.ObjectId -KeyCredentials $this.KeyCredentials | Out-Null
            }
            else
            {
                Write-Warning -Message 'KeyCredentials cannot be updated for AAD Applications with more than one KeyCredentials due to technical limitation of Update-MgBetaApplication Cmdlet. Learn more at: https://learn.microsoft.com/en-us/graph/api/application-addkey'
            }
        }

        #region OnPremisesPublishing
        if ($null -ne $this.OnPremisesPublishing)
        {
            $oppInfo = $this.OnPremisesPublishing
            $onPremisesPublishingValue = @{
                alternateUrl                          = $oppInfo.alternateUrl
                applicationServerTimeout              = $oppInfo.applicationServerTimeout
                externalAuthenticationType            = $oppInfo.externalAuthenticationType
                #externalUrl                           = $oppInfo.externalUrl
                internalUrl                           = $oppInfo.internalUrl
                isBackendCertificateValidationEnabled = $oppInfo.isBackendCertificateValidationEnabled
                isHttpOnlyCookieEnabled               = $oppInfo.isHttpOnlyCookieEnabled
                isPersistentCookieEnabled             = $oppInfo.isPersistentCookieEnabled
                isSecureCookieEnabled                 = $oppInfo.isSecureCookieEnabled
                isStateSessionEnabled                 = $oppInfo.isStateSessionEnabled
                isTranslateHostHeaderEnabled          = $oppInfo.isTranslateHostHeaderEnabled
                isTranslateLinksInBodyEnabled         = $oppInfo.isTranslateLinksInBodyEnabled
            }

            # onPremisesApplicationSegments
            $segmentValues = @()
            foreach ($segment in $oppInfo.onPremisesApplicationSegments)
            {
                $entry = @{
                    alternateUrl = $segment.AlternateUrl
                    externalUrl  = $segment.externalUrl
                    internalUrl  = $segment.internalUrl
                }

                $corsConfigurationValues = @()
                foreach ($cors in $segment.corsConfigurations)
                {
                    $corsEntry = @{
                        allowedHeaders  = [Array]($cors.allowedHeaders)
                        allowedMethods  = [Array]($cors.allowedMethods)
                        allowedOrigins  = [Array]($cors.allowedOrigins)
                        maxAgeInSeconds = $cors.maxAgeInSeconds
                        resource        = $cors.resource
                    }
                    $corsConfigurationValues += $corsEntry
                }
                $entry.Add('corsConfigurations', $corsConfigurationValues)
                $segmentValues += $entry
            }
            $onPremisesPublishingValue.Add('onPremisesApplicationSegments', $segmentValues)

            # singleSignOnSettings
            $singleSignOnValues = @{
                kerberosSignOnSettings = @{
                    kerberosServicePrincipalName       = $oppInfo.singleSignOnSettings.kerberosSignOnSettings.kerberosServicePrincipalName
                    kerberosSignOnMappingAttributeType = $oppInfo.singleSignOnSettings.kerberosSignOnSettings.kerberosSignOnMappingAttributeType
                }
                singleSignOnMode       = $oppInfo.singleSignOnSettings.singleSignOnMode
            }
            if ($null -eq $singleSignOnValues.kerberosSignOnSettings.kerberosServicePrincipalName)
            {
                $singleSignOnValues.Remove('kerberosSignOnSettings') | Out-Null
            }

            $onPremisesPublishingValue.Add('singleSignOnSettings', $singleSignOnValues)
            $onPremisesPayload = ConvertTo-Json $onPremisesPublishingValue -Depth 10 -Compress
            Write-Verbose -Message "Updating the OnPremisesPublishing settings for application {$($currentAADApp.DisplayName)} with payload: $onPremisesPayload"

            $Uri = "/beta/applications/$($currentAADApp.ObjectId)/onPremisesPublishing"
            Invoke-M365DSCGraphRequest -Method 'PATCH' `
                -Uri $Uri `
                -Body $onPremisesPayload
        }
        #endregion

        if ($this.GetBoundParameters().ContainsKey('TokenLifetimePolicy'))
        {
            if (-not [System.String]::IsNullOrEmpty($currentAADApp.TokenLifetimePolicy) -and -not [System.String]::IsNullOrEmpty($this.TokenLifetimePolicy) -and $this.TokenLifetimePolicy -ne $currentAADApp.TokenLifetimePolicy)
            {
                $policyToRemove = $currentAADApp.TokenLifetimePolicy
                $policyToAdd = $this.TokenLifetimePolicy
            }
            elseif ([System.String]::IsNullOrEmpty($currentAADApp.TokenLifetimePolicy) -and -not [System.String]::IsNullOrEmpty($this.TokenLifetimePolicy))
            {
                $policyToRemove = $null
                $policyToAdd = $this.TokenLifetimePolicy
            }
            elseif (-not [System.String]::IsNullOrEmpty($currentAADApp.TokenLifetimePolicy) -and [System.String]::IsNullOrEmpty($this.TokenLifetimePolicy))
            {
                $policyToRemove = $currentAADApp.TokenLifetimePolicy
                $policyToAdd = $null
            }
            else
            {
                $policyToRemove = $null
                $policyToAdd = $null
            }

            $allTokenLifetimePolicies = Get-MgBetaPolicyTokenLifetimePolicy
            if ($null -ne $policyToRemove)
            {
                Write-Verbose -Message "Removing Token Lifetime Policy with DisplayName [$policyToRemove] from Application [$($currentAADApp.DisplayName)]"
                $policy = $allTokenLifetimePolicies | Where-Object { $_.DisplayName -eq $policyToRemove }
                Remove-MgApplicationTokenLifetimePolicyTokenLifetimePolicyByRef -ApplicationId $currentAADApp.Id -TokenLifetimePolicyId $policy.Id
            }

            if ($null -ne $policyToAdd)
            {
                Write-Verbose -Message "Adding Token Lifetime Policy with DisplayName [$policyToAdd] to Application [$($currentAADApp.DisplayName)]"
                $policy = $allTokenLifetimePolicies | Where-Object { $_.DisplayName -eq $policyToAdd }
                New-MgApplicationTokenLifetimePolicyByRef -ApplicationId $currentAADApp.Id -BodyParameter @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/policies/tokenLifetimePolicies/$($policy.Id)"
                }
            }
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        $dscContent = [System.Text.StringBuilder]::new()
        $i = 1
        Write-M365DSCHost -Message "`r`n" -DeferWrite
        try
        {
            [array] $exportedInstances = Get-MgBetaApplication `
                -Filter $this.Filter `
                -Property $this.ResourceCache['PropertiesToRetrieve'] `
                -ExpandProperty 'owners' `
                -All `
                -ErrorAction Stop

            $this.BuildServicePrincipalMap($exportedInstances)

            # Use a windowing approach to prefetch the next 250 instances to pre-load the next set of apps at once
            # instead of for one app at a time
            $windowIndex = 0
            foreach ($AADApp in $exportedInstances)
            {
                if (($windowIndex % 250) -eq 0)
                {
                    $this.PrefetchNavigationWindow($exportedInstances, $windowIndex, 250)
                }
                $windowIndex++

                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($AADApp.DisplayName)" -DeferWrite
                $Params = @{
                    ApplicationId         = $this.ApplicationId
                    AppId                 = $AADApp.AppId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    ApplicationSecret     = $this.ApplicationSecret
                    Description           = $AADApp.Description
                    DisplayName           = $AADApp.DisplayName
                    ObjectID              = $AADApp.Id
                    Credential            = $this.Credential
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }
                try
                {
                    $this.ExportedInstance = $AADApp
                    $Results = $this.GetForExport($Params)
                    $rawResults = $Results.Clone()
                    if ($Results.Ensure -eq 'Present')
                    {
                        if ($Results.RequiredResourceAccess.Count -gt 0)
                        {
                            $complexMapping = @(
                                @{
                                    Name            = 'RequiredResourceAccess'
                                    CimInstanceName = 'MSFT_AADApplicationPermission'
                                    IsRequired      = $False
                                }
                            )
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.RequiredResourceAccess `
                                -CIMInstanceName 'MSFT_AADApplicationPermission' `
                                -ComplexTypeMapping $complexMapping

                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.RequiredResourceAccess = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('RequiredResourceAccess') | Out-Null
                            }
                        }

                        if ($null -ne $Results.Api)
                        {
                            $complexMapping = @(
                                @{
                                    Name            = 'Api'
                                    CimInstanceName = 'MicrosoftGraphApiApplication'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'PreAuthorizedApplications'
                                    CimInstanceName = 'MicrosoftGraphPreAuthorizedApplication'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'Oauth2PermissionScopes'
                                    CimInstanceName = 'MSFT_MicrosoftGraphApiOauth2PermissionScopes'
                                    IsRequired      = $False
                                }
                            )
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.Api `
                                -CIMInstanceName 'MicrosoftGraphapiApplication' `
                                -ComplexTypeMapping $complexMapping

                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.Api = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('Api') | Out-Null
                            }
                        }

                        if ($null -ne $Results.AuthenticationBehaviors -and $Results.AuthenticationBehaviors.Length -gt 0)
                        {
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.AuthenticationBehaviors `
                                -CIMInstanceName 'MicrosoftGraphauthenticationBehaviors'
                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.AuthenticationBehaviors = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('AuthenticationBehaviors') | Out-Null
                            }
                        }

                        if ($null -ne $Results.Info)
                        {
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.Info `
                                -CIMInstanceName 'MicrosoftGraphInformationalUrl'
                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.Info = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('Info') | Out-Null
                            }
                        }

                        if ($null -ne $Results.Spa -and $Results.Spa.Length -gt 0)
                        {
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.Spa `
                                -CIMInstanceName 'AADApplicationSpa'
                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.Spa = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('Spa') | Out-Null
                            }
                        }

                        if ($null -ne $Results.OnPremisesPublishing.singleSignOnSettings)
                        {
                            $complexMapping = @(
                                @{
                                    Name            = 'singleSignOnSettings'
                                    CimInstanceName = 'AADApplicationOnPremisesPublishingSingleSignOnSetting'
                                    IsRequired      = $False
                                },
                                @{
                                    Name            = 'onPremisesApplicationSegments'
                                    CimInstanceName = 'AADApplicationOnPremisesPublishingSegment'
                                    IsRequired      = $False
                                },
                                @{
                                    Name            = 'kerberosSignOnSettings'
                                    CimInstanceName = 'AADApplicationOnPremisesPublishingSingleSignOnSettingKerberos'
                                    IsRequired      = $False
                                },
                                @{
                                    Name            = 'corsConfigurations'
                                    CimInstanceName = 'AADApplicationOnPremisesPublishingSegmentCORS'
                                    IsRequired      = $False
                                }
                            )
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.OnPremisesPublishing `
                                -CIMInstanceName 'AADApplicationOnPremisesPublishing' `
                                -ComplexTypeMapping $complexMapping
                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.OnPremisesPublishing = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('OnPremisesPublishing') | Out-Null
                            }
                        }
                        else
                        {
                            $Results.Remove('OnPremisesPublishing') | Out-Null
                        }

                        if ($null -ne $Results.OptionalClaims)
                        {
                            $complexMapping = @(
                                @{
                                    Name            = 'OptionalClaims'
                                    CimInstanceName = 'MicrosoftGraphOptionalClaims'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'AccessToken'
                                    CimInstanceName = 'MicrosoftGraphOptionalClaim'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'IdToken'
                                    CimInstanceName = 'MicrosoftGraphOptionalClaim'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'Saml2Token'
                                    CimInstanceName = 'MicrosoftGraphOptionalClaim'
                                    IsRequired      = $False
                                }
                            )
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.OptionalClaims `
                                -CIMInstanceName 'MicrosoftGraphoptionalClaims' `
                                -ComplexTypeMapping $complexMapping

                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.OptionalClaims = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('OptionalClaims') | Out-Null
                            }
                        }

                        if ($null -ne $Results.KeyCredentials)
                        {
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.KeyCredentials `
                                -CIMInstanceName 'MicrosoftGraphkeyCredential'
                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.KeyCredentials = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('KeyCredentials') | Out-Null
                            }
                        }

                        if ($null -ne $Results.PasswordCredentials)
                        {
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.PasswordCredentials `
                                -CIMInstanceName 'MicrosoftGraphpasswordCredential'
                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.PasswordCredentials = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('PasswordCredentials') | Out-Null
                            }
                        }

                        if ($null -ne $Results.AppRoles)
                        {
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.AppRoles `
                                -CIMInstanceName 'MicrosoftGraphAppRole' `
                                -IsArray
                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.AppRoles = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('AppRoles') | Out-Null
                            }
                        }

                        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                            -ConnectionMode $ConnectionMode `
                            -ModulePath $this.GetModulePath() `
                            -Results $Results `
                            -Credential $this.Credential `
                            -NoEscape @('Api', 'Info', 'RequiredResourceAccess', 'OptionalClaims', 'OnPremisesPublishing', 'AuthenticationBehaviors', 'KeyCredentials', 'PasswordCredentials', 'AppRoles', 'Spa') `
                            -RawResults $rawResults

                        [void]$dscContent.Append($currentDSCBlock)
                        Save-M365DSCPartialExport -Content $currentDSCBlock `
                            -FileName $Global:PartialExportFileName
                        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                        $i++
                    }
                }
                catch
                {
                    if ($_.Exception.Message -like '*Multiple AAD Apps with the Displayname*')
                    {
                        Write-M365DSCHost -Message "`r`n        $($Global:M365DSCEmojiYellowCircle)" -DeferWrite
                        Write-M365DSCHost -Message " Multiple app instances wth name {$($AADApp.DisplayName)} were found. We will skip exporting these instances." -CommitWrite
                    }
                    $this.LogError($_, 'Error during Export:')
                    Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
                    $i++
                }
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('AppId', 'ObjectId', 'ApplicationTemplateId', 'AdminConsentGranted', 'PasswordCredentials')
        }
    }

    hidden [void] BuildServicePrincipalMap([System.Object[]] $Instances)
    {
        $this.ResourceCache['ServicePrincipalsByAppId'] = $null
        if ($null -eq $Instances -or $Instances.Count -eq 0)
        {
            return
        }

        $distinctApiIds = [System.Collections.Generic.HashSet[System.String]]::new()
        $preAuthorizedCount = 0
        foreach ($instance in $Instances)
        {
            foreach ($requiredAccess in $instance.RequiredResourceAccess)
            {
                $null = $distinctApiIds.Add([System.String]$requiredAccess.ResourceAppId)
            }
            $preAuthorizedCount += @($instance.Api.PreAuthorizedApplications).Count
        }
        $lookupsSaved = $Instances.Count + $distinctApiIds.Count + $preAuthorizedCount
        if ($Instances.Count -lt 25)
        {
            Write-Verbose -Message "Skipping the service principal map: only $($Instances.Count) applications found."
            return
        }

        Write-Verbose -Message "Building the service principal map to serve $lookupsSaved lookups."
        $map = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new()
        try
        {
            $response = Invoke-M365DSCGraphRequest -Uri '/beta/servicePrincipals?$select=id,appId,displayName' -All
        }
        catch
        {
            Write-Verbose -Message 'Could not list the service principals in the tenant. Falling back to per-application lookups.'
            return
        }

        foreach ($servicePrincipal in $response.value)
        {
            $map[[System.String]$servicePrincipal.appId] = @{
                Id          = [System.String]$servicePrincipal.id
                DisplayName = [System.String]$servicePrincipal.displayName
            }
        }
        $this.ResourceCache['ServicePrincipalsByAppId'] = $map
    }

    hidden [void] PrefetchNavigationWindow([System.Object[]] $Instances, [System.Int32] $Start, [System.Int32] $Size)
    {
        $this.ResourceCache['NavigationCache'] = $null

        $servicePrincipalsByAppId = $this.ResourceCache['ServicePrincipalsByAppId']
        if ($null -eq $Instances -or $Instances.Count -eq 0)
        {
            return
        }

        $requests = [System.Collections.Generic.List[System.Object]]::new()
        $end = [System.Math]::Min($Start + $Size, $Instances.Count)
        for ($index = $Start; $index -lt $end; $index++)
        {
            $instance = $Instances[$index]
            $applicationKey = [System.String]$instance.Id
            $requests.Add(@{
                    id     = "$applicationKey|onPremisesPublishing"
                    method = 'GET'
                    url    = "/applications/$applicationKey/onPremisesPublishing"
                })
            $requests.Add(@{
                    id     = "$applicationKey|tokenLifetimePolicies"
                    method = 'GET'
                    url    = "/applications/$applicationKey/tokenLifetimePolicies"
                })

            if ($null -eq $servicePrincipalsByAppId -or -not $servicePrincipalsByAppId.ContainsKey([System.String]$instance.AppId))
            {
                continue
            }
            $servicePrincipalId = $servicePrincipalsByAppId[[System.String]$instance.AppId].Id
            $requests.Add(@{
                    id     = "$applicationKey|oAuth2grant"
                    method = 'GET'
                    url    = "/oauth2PermissionGrants?`$filter=clientId eq '$servicePrincipalId'"
                })
            $requests.Add(@{
                    id     = "$applicationKey|roleAssignments"
                    method = 'GET'
                    url    = "/servicePrincipals/$servicePrincipalId/appRoleAssignments"
                })
        }

        if ($requests.Count -eq 0)
        {
            return
        }

        $responses = $null
        try
        {
            $responses = Invoke-M365DSCGraphBatchRequest -Requests $requests.ToArray()
        }
        catch
        {
            Write-Verbose -Message 'Could not prefetch the navigation properties for this window. Falling back to per-application requests.'
            return
        }

        $cache = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new()
        foreach ($response in $responses)
        {
            $responseId = [System.String]$response.id
            $separator = $responseId.LastIndexOf('|')
            if ($separator -lt 0)
            {
                continue
            }
            $applicationKey = $responseId.Substring(0, $separator)
            $entry = $null
            if (-not $cache.TryGetValue($applicationKey, [ref] $entry))
            {
                $entry = [System.Collections.Generic.List[System.Object]]::new()
                $cache[$applicationKey] = $entry
            }
            $entry.Add(@{
                    id     = $responseId.Substring($separator + 1)
                    status = $response.status
                    body   = $response.body
                })
        }
        $this.ResourceCache['NavigationCache'] = $cache
    }

    hidden [void] UpdateAppRoles([System.String] $ObjectId, [System.Object[]] $AppRoles)
    {
        for ($attempt = 1; $attempt -le 6; $attempt++)
        {
            try
            {
                Update-MgBetaApplication -ApplicationId $ObjectId -AppRoles $AppRoles -ErrorAction Stop
                return
            }
            catch
            {
                if ($attempt -ge 6 -or "$($_.Exception.Message) $($_.ErrorDetails.Message)" -notlike '*CannotDeleteOrUpdateEnabledEntitlement*')
                {
                    throw
                }
                Start-Sleep -Seconds 10
            }
        }
    }

    hidden [System.Object] GetAzureADAppPermissions([System.Object] $App)
    {
        Write-Verbose -Message "Retrieving permissions for Azure AD Application {$($App.DisplayName)}"
        [array]$requiredAccesses = $App.RequiredResourceAccess

        $permissionResults = @()
        $oAuth2grant = $null
        $roleAssignments = $null
        $appServicePrincipal = $null
        $grantedAppRoleIds = [System.Collections.Generic.HashSet[System.String]]::new()

        if ($null -eq $this.ResourceCache['SourceApiNames'])
        {
            $this.ResourceCache['SourceApiNames'] = [System.Collections.Generic.Dictionary[System.String, System.String]]::new()
            $this.ResourceCache['SourceApiScopes'] = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new()
            $this.ResourceCache['SourceApiRoles'] = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new()
        }
        $apiNames = $this.ResourceCache['SourceApiNames']
        $apiScopes = $this.ResourceCache['SourceApiScopes']
        $apiRoles = $this.ResourceCache['SourceApiRoles']
        $servicePrincipalsByAppId = $this.ResourceCache['ServicePrincipalsByAppId']

        $batchRequests = [System.Collections.Generic.List[System.Object]]::new()
        $pendingApiIds = [System.Collections.Generic.List[System.String]]::new()
        if ($requiredAccesses.Length -gt 0)
        {
            $resolvedOwnServicePrincipal = $false
            if ($null -ne $servicePrincipalsByAppId -and $servicePrincipalsByAppId.ContainsKey([System.String]$App.AppId))
            {
                $resolvedOwnServicePrincipal = $true
                $appServicePrincipal = $servicePrincipalsByAppId[[System.String]$App.AppId]
            }
            else
            {
                $batchRequests.Add(@{
                        id     = 'AppServicePrincipal'
                        method = 'GET'
                        url    = "/servicePrincipals?`$filter=appId eq '$($App.AppId)'"
                    })
            }

            foreach ($requiredAccess in $requiredAccesses)
            {
                $sourceApiKey = [System.String]$requiredAccess.ResourceAppId
                if ($apiNames.ContainsKey($sourceApiKey) -or $pendingApiIds.Contains($sourceApiKey))
                {
                    continue
                }
                $pendingApiIds.Add($sourceApiKey)
                $batchRequests.Add(@{
                        id     = "SourceAPI|$sourceApiKey"
                        method = 'GET'
                        url    = "/servicePrincipals?`$filter=appId eq '$sourceApiKey'&`$select=displayName,appRoles,publishedPermissionScopes"
                    })
            }

            if ($batchRequests.Count -gt 0)
            {
                $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests.ToArray()
                if (-not $resolvedOwnServicePrincipal)
                {
                    $appServicePrincipal = ($batchResponses | Where-Object -FilterScript { $_.id -eq 'AppServicePrincipal' }).body.value
                }

                foreach ($pendingApiId in $pendingApiIds)
                {
                    $sourceApi = ($batchResponses | Where-Object -FilterScript { $_.id -eq "SourceAPI|$pendingApiId" }).body.value
                    if ([System.String]::IsNullOrEmpty($sourceApi))
                    {
                        Write-Warning -Message "Could not find the Service Principal for API with AppId {$pendingApiId}. Using ResourceAppId as the identifier in the exported configuration."
                        $sourceApi = @{
                            AppId       = $pendingApiId
                            DisplayName = $pendingApiId
                            Id          = $pendingApiId
                        }
                    }

                    $apiNames[$pendingApiId] = [System.String]$sourceApi.DisplayName

                    $scopesById = [System.Collections.Generic.Dictionary[System.String, System.String]]::new()
                    foreach ($publishedScope in $sourceApi.publishedPermissionScopes)
                    {
                        $scopesById[[System.String]$publishedScope.Id] = [System.String]$publishedScope.Value
                    }
                    $apiScopes[$pendingApiId] = $scopesById

                    $rolesById = [System.Collections.Generic.Dictionary[System.String, System.String]]::new()
                    foreach ($appRole in $sourceApi.AppRoles)
                    {
                        $rolesById[[System.String]$appRole.Id] = [System.String]$appRole.Value
                    }
                    $apiRoles[$pendingApiId] = $rolesById
                }
            }
        }

        if ($null -ne $appServicePrincipal)
        {
            $navigationResponses = $null
            $navigationCache = $this.ResourceCache['NavigationCache']
            if ($null -ne $navigationCache -and $navigationCache.ContainsKey([System.String]$App.Id))
            {
                $navigationResponses = $navigationCache[[System.String]$App.Id]
                if ($null -eq ($navigationResponses | Where-Object -FilterScript { $_.id -eq 'oAuth2grant' }))
                {
                    $navigationResponses = $null
                }
            }

            if ($null -eq $navigationResponses)
            {
                $batchRequests = @(
                    @{
                        id     = 'oAuth2grant'
                        method = 'GET'
                        url    = "/oauth2PermissionGrants?`$filter=clientId eq '$($appServicePrincipal.Id)'"
                    }
                    @{
                        id     = 'roleAssignments'
                        method = 'GET'
                        url    = "/servicePrincipals/$($appServicePrincipal.Id)/appRoleAssignments"
                    }
                )
                $navigationResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests
            }

            $oAuth2grant = ($navigationResponses | Where-Object -FilterScript { $_.id -eq 'oAuth2grant' }).body.value
            $roleAssignments = ($navigationResponses | Where-Object -FilterScript { $_.id -eq 'roleAssignments' }).body.value

            foreach ($roleAssignment in $roleAssignments)
            {
                $null = $grantedAppRoleIds.Add([System.String]$roleAssignment.AppRoleId)
            }
        }

        $i = 1
        foreach ($requiredAccess in $requiredAccesses)
        {
            Write-Verbose -Message "[$i/$($requiredAccesses.Length)]Obtaining information for App's Permission for {$($requiredAccess.ResourceAppId)}"
            $sourceApiKey = [System.String]$requiredAccess.ResourceAppId
            $sourceApiName = $apiNames[$sourceApiKey]
            $scopesById = $apiScopes[$sourceApiKey]
            $rolesById = $apiRoles[$sourceApiKey]

            foreach ($resourceAccess in $requiredAccess.ResourceAccess)
            {
                $currentPermission = @{}
                $currentPermission.Add('SourceAPI', $sourceApiName)
                if ($resourceAccess.Type -eq 'Scope')
                {
                    $scopeInfoValue = $null
                    if ($scopesById.ContainsKey([System.String]$resourceAccess.Id))
                    {
                        $scopeInfoValue = $scopesById[[System.String]$resourceAccess.Id]
                    }
                    elseif ([System.Guid]::TryParse($resourceAccess.Id, [ref][System.Guid]::Empty))
                    {
                        $scopeInfoValue = $resourceAccess.Id
                    }
                    $currentPermission.Add('Type', 'Delegated')
                    $currentPermission.Add('Name', $scopeInfoValue)
                    $currentPermission.Add('AdminConsentGranted', $false)

                    if ($null -ne $appServicePrincipal)
                    {
                        if ($oAuth2grant.Count -gt 0)
                        {
                            $scopes = ($oAuth2grant.Scope -join ' ').Split(' ')
                            if ($scopes.Contains($scopeInfoValue))
                            {
                                $currentPermission.AdminConsentGranted = $true
                            }
                        }
                    }
                }
                elseif ($resourceAccess.Type -eq 'Role' -or $resourceAccess.Type -eq 'Role,Scope')
                {
                    $currentPermission.Add('Type', 'AppOnly')
                    $roleValue = $null
                    if ($rolesById.ContainsKey([System.String]$resourceAccess.Id))
                    {
                        $roleValue = $rolesById[[System.String]$resourceAccess.Id]
                    }
                    elseif ([System.Guid]::TryParse($resourceAccess.Id, [ref][System.Guid]::Empty))
                    {
                        $roleValue = $resourceAccess.Id
                    }
                    $currentPermission.Add('Name', $roleValue)
                    $currentPermission.Add('AdminConsentGranted', $false)

                    if ($null -ne $appServicePrincipal)
                    {
                        if ($grantedAppRoleIds.Contains([System.String]$resourceAccess.Id))
                        {
                            $currentPermission.AdminConsentGranted = $true
                        }
                    }
                }
                $permissionResults += $currentPermission
            }
            $i++
        }

        if ($permissionResults.Count -eq 0)
        {
            return $null
        }

        return $permissionResults
    }

    hidden [AADApplication] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADApplication])
        {
            return $Values
        }

        $result = [AADApplication]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphoptionalClaims
{
    [DscProperty()]
    [System.ComponentModel.Description('The optional claims returned in the JWT access token.')]
    [MSFT_MicrosoftGraphOptionalClaim[]] $AccessToken

    [DscProperty()]
    [System.ComponentModel.Description('The optional claims returned in the JWT ID token.')]
    [MSFT_MicrosoftGraphOptionalClaim[]] $IdToken

    [DscProperty()]
    [System.ComponentModel.Description('The optional claims returned in the SAML token.')]
    [MSFT_MicrosoftGraphOptionalClaim[]] $Saml2Token
}

class MSFT_MicrosoftGraphapiApplication
{
    [DscProperty()]
    [System.ComponentModel.Description('Lists the client applications that are preauthorized with the specified delegated permissions to access this application''s APIs. Users aren''t required to consent to any preauthorized application (for the permissions specified). However, any other permissions not listed in preAuthorizedApplications (requested through incremental consent for example) will require user consent.')]
    [MSFT_MicrosoftGraphPreAuthorizedApplication[]] $PreAuthorizedApplications

    [DscProperty()]
    [System.ComponentModel.Description('List of associated API scopes.')]
    [MSFT_MicrosoftGraphAPIOauth2PermissionScopes[]] $Oauth2PermissionScopes
}

class MSFT_MicrosoftGraphauthenticationBehaviors
{
    [DscProperty()]
    [System.ComponentModel.Description('If false, allows the app to have extended access to Azure AD Graph until June 30, 2025 when Azure AD Graph is fully retired. For more information on Azure AD retirement updates, see June 2024 update on Azure AD Graph API retirement. Use ''Null'' to ensure the value is not configured.')]
    [ValidateSet('True', 'False', 'Null')]
    [System.String] $BlockAzureADGraphAccess

    [DscProperty()]
    [System.ComponentModel.Description('If true, removes the email claim from tokens sent to an application when the email address''s domain can''t be verified. Use ''Null'' to ensure the value is not configured.')]
    [ValidateSet('True', 'False', 'Null')]
    [System.String] $RemoveUnverifiedEmailClaim
}

class MSFT_MicrosoftGraphpasswordCredential
{
    [DscProperty()]
    [System.ComponentModel.Description('Friendly name for the password. Optional.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The date and time at which the password expires represented using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z. Optional.')]
    [System.String] $EndDateTime

    [DscProperty()]
    [System.ComponentModel.Description('Contains the first three characters of the password. Read-only.')]
    [System.String] $Hint

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for the password.')]
    [System.String] $KeyId

    [DscProperty()]
    [System.ComponentModel.Description('The date and time at which the password becomes valid. The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z. Optional.')]
    [System.String] $StartDateTime
}

class MSFT_MicrosoftGraphkeyCredential
{
    [DscProperty()]
    [System.ComponentModel.Description('A 40-character binary type that can be used to identify the credential. Optional. When not provided in the payload, defaults to the thumbprint of the certificate.')]
    [System.String] $CustomKeyIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('Friendly name for the key. Optional.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The date and time at which the credential expires. The DateTimeOffset type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z.')]
    [System.String] $EndDateTime

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier (GUID) for the key.')]
    [System.String] $KeyId

    [DscProperty()]
    [System.ComponentModel.Description('The certificate''s raw data in byte array converted to Base64 string.')]
    [System.String] $Key

    [DscProperty()]
    [System.ComponentModel.Description('The date and time at which the credential becomes valid.The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z.')]
    [System.String] $StartDateTime

    [DscProperty()]
    [System.ComponentModel.Description('The type of key credential for example, Symmetric, AsymmetricX509Cert.')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('A string that describes the purpose for which the key can be used for example, Verify.')]
    [System.String] $Usage
}

class MSFT_MicrosoftGraphInformationalUrl
{
    [DscProperty()]
    [System.ComponentModel.Description('Link to the application''s marketing page. For example, https://www.contoso.com/app/marketing')]
    [System.String] $MarketingUrl

    [DscProperty()]
    [System.ComponentModel.Description('Link to the application''s privacy statement. For example, https://www.contoso.com/app/privacy')]
    [System.String] $PrivacyStatementUrl

    [DscProperty()]
    [System.ComponentModel.Description('Link to the application''s support page. For example, https://www.contoso.com/app/support')]
    [System.String] $SupportUrl

    [DscProperty()]
    [System.ComponentModel.Description('Link to the application''s terms of service statement. For example, https://www.contoso.com/app/termsofservice')]
    [System.String] $TermsOfServiceUrl
}

class MSFT_MicrosoftGraphappRole
{
    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether this app role can be assigned to users and groups (by setting to ''User''), to other application''s (by setting to ''Application'', or both (by setting to ''User'', ''Application'')). App roles supporting assignment to other applications'' service principals are also known as application permissions. The ''Application'' value is only supported for app roles defined on application entities.')]
    [System.String[]] $AllowedMemberTypes

    [DscProperty()]
    [System.ComponentModel.Description('The description for the app role. This is displayed when the app role is being assigned and, if the app role functions as an application permission, during  consent experiences.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Display name for the permission that appears in the app role assignment and consent experiences.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Unique role identifier inside the appRoles collection. When creating a new app role, a new GUID identifier must be provided.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('When creating or updating an app role, this must be set to true (which is the default). To delete a role, this must first be set to false.  At that point, in a subsequent call, this role may be removed.')]
    [System.Nullable[System.Boolean]] $IsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if the app role is defined on the application object or on the servicePrincipal entity. Must not be included in any POST or PATCH requests. Read-only.')]
    [System.String] $Origin

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Specifies the value to include in the roles claim in ID tokens and access tokens authenticating an assigned user or service principal. Must not exceed 120 characters in length. Allowed characters are : ! # $ % & '' ( ) * + , - . / :   =       + _    } , and characters in the ranges 0-9, A-Z and a-z. Any other character, including the space character, aren''t allowed. May not begin with ..')]
    [System.String] $Value
}

class MSFT_AADApplicationOnPremisesPublishing
{
    [DscProperty()]
    [System.ComponentModel.Description('If you''re configuring a traffic manager in front of multiple App Proxy applications, the alternateUrl is the user-friendly URL that points to the traffic manager.')]
    [System.String] $alternateUrl

    [DscProperty()]
    [System.ComponentModel.Description('The duration the connector waits for a response from the backend application before closing the connection. Possible values are default, long.')]
    [System.String] $applicationServerTimeout

    [DscProperty()]
    [System.ComponentModel.Description('Details the pre-authentication setting for the application. Pre-authentication enforces that users must authenticate before accessing the app. Pass through doesn''t require authentication. Possible values are: passthru, aadPreAuthentication.')]
    [System.String] $externalAuthenticationType

    [DscProperty()]
    [System.ComponentModel.Description('The published external url for the application. For example, https://intranet-contoso.msappproxy.net/.')]
    [System.String] $externalUrl

    [DscProperty()]
    [System.ComponentModel.Description('The internal url of the application. For example, https://intranet/.')]
    [System.String] $internalUrl

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether backend SSL certificate validation is enabled for the application. For all new Application Proxy apps, the property is set to true by default. For all existing apps, the property is set to false.')]
    [System.Nullable[System.Boolean]] $isBackendCertificateValidationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if the HTTPOnly cookie flag should be set in the HTTP response headers. Set this value to true to have Application Proxy cookies include the HTTPOnly flag in the HTTP response headers. If using Remote Desktop Services, set this value to False. Default value is false.')]
    [System.Nullable[System.Boolean]] $isHttpOnlyCookieEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if the Persistent cookie flag should be set in the HTTP response headers. Keep this value set to false. Only use this setting for applications that can''t share cookies between processes. For more information about cookie settings, see Cookie settings for accessing on-premises applications in Microsoft Entra ID. Default value is false.')]
    [System.Nullable[System.Boolean]] $isPersistentCookieEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if the Secure cookie flag should be set in the HTTP response headers. Set this value to true to transmit cookies over a secure channel such as an encrypted HTTPS request. Default value is true.')]
    [System.Nullable[System.Boolean]] $isSecureCookieEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether validation of the state parameter when the client uses the OAuth 2.0 authorization code grant flow is enabled. This setting allows admins to specify whether they want to enable CSRF protection for their apps.')]
    [System.Nullable[System.Boolean]] $isStateSessionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if the application should translate urls in the response headers. Keep this value as true unless your application required the original host header in the authentication request. Default value is true.')]
    [System.Nullable[System.Boolean]] $isTranslateHostHeaderEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if the application should translate urls in the application body. Keep this value as false unless you have hardcoded HTML links to other on-premises applications and don''t use custom domains. For more information, see Link translation with Application Proxy. Default value is false.')]
    [System.Nullable[System.Boolean]] $isTranslateLinksInBodyEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Represents the collection of application segments for an on-premises wildcard application that''s published through Microsoft Entra application proxy.')]
    [MSFT_AADApplicationOnPremisesPublishingSegment[]] $onPremisesApplicationSegments

    [DscProperty()]
    [System.ComponentModel.Description('Represents the single sign-on configuration for the on-premises application.')]
    [MSFT_AADApplicationOnPremisesPublishingSingleSignOnSetting] $singleSignOnSettings
}

class MSFT_AADApplicationSpa
{
    [DscProperty()]
    [System.ComponentModel.Description('Single page application redirect URIs.')]
    [System.String[]] $RedirectUris
}

class MSFT_AADApplicationPermission
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the requested permission.')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the API from which the permission comes from.')]
    [System.String] $SourceAPI

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Type of permission.')]
    [ValidateSet('AppOnly', 'Delegated')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('Represented whether or not the Admin consent been granted on the app.')]
    [System.Nullable[System.Boolean]] $AdminConsentGranted
}

class MSFT_MicrosoftGraphOptionalClaim
{
    [DscProperty()]
    [System.ComponentModel.Description('If the value is true, the claim specified by the client is necessary to ensure a smooth authorization experience for the specific task requested by the end user. The default value is false.')]
    [System.Nullable[System.Boolean]] $Essential

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The name of the optional claim.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The source (directory object) of the claim. There are predefined claims and user-defined claims from extension properties. If the source value is null, the claim is a predefined optional claim. If the source value is user, the value in the name property is the extension property from the user object.')]
    [System.String] $Source
}

class MSFT_MicrosoftGraphPreAuthorizedApplication
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The unique identifier for the client application.')]
    [System.String] $AppId

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The unique identifier for the scopes the client application is granted.')]
    [System.String[]] $PermissionIds
}

class MSFT_MicrosoftGraphAPIOauth2PermissionScopes
{
    [DscProperty()]
    [System.ComponentModel.Description('A description of the delegated permissions, intended to be read by an administrator granting the permission on behalf of all users. This text appears in tenant-wide admin consent experiences.')]
    [System.String] $adminConsentDescription

    [DscProperty()]
    [System.ComponentModel.Description('The permission''s title, intended to be read by an administrator granting the permission on behalf of all users.')]
    [System.String] $adminConsentDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('A description of the delegated permissions, intended to be read by a user granting the permission on their own behalf. This text appears in consent experiences where the user is consenting only on behalf of themselves.')]
    [System.String] $userConsentDescription

    [DscProperty()]
    [System.ComponentModel.Description('A title for the permission, intended to be read by a user granting the permission on their own behalf. This text appears in consent experiences where the user is consenting only on behalf of themselves.')]
    [System.String] $userConsentDisplayName

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Specifies the value to include in the scp (scope) claim in access tokens. Must not exceed 120 characters in length.')]
    [System.String] $value

    [DscProperty()]
    [System.ComponentModel.Description('When you create or update a permission, this property must be set to true (which is the default). To delete a permission, this property must first be set to false. At that point, in a subsequent call, the permission may be removed.')]
    [System.Nullable[System.Boolean]] $isEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The possible values are: User and Admin. Specifies whether this delegated permission should be considered safe for non-admin users to consent to on behalf of themselves, or whether an administrator consent should always be required.')]
    [System.String] $type

    [DscProperty()]
    [System.ComponentModel.Description('Unique delegated permission identifier inside the collection of delegated permissions defined for a resource application.')]
    [System.String] $id
}

class MSFT_AADApplicationOnPremisesPublishingSegment
{
    [DscProperty()]
    [System.ComponentModel.Description('If you''re configuring a traffic manager in front of multiple App Proxy application segments, contains the user-friendly URL that will point to the traffic manager.')]
    [System.String] $alternateUrl

    [DscProperty()]
    [System.ComponentModel.Description('CORS Rule definition for a particular application segment.')]
    [MSFT_AADApplicationOnPremisesPublishingSegmentCORS[]] $corsConfigurations

    [DscProperty()]
    [System.ComponentModel.Description('The published external URL for the application segment; for example, https://intranet.contoso.com./')]
    [System.String] $externalUrl

    [DscProperty()]
    [System.ComponentModel.Description('The internal URL of the application segment; for example, https://intranet/.')]
    [System.String] $internalUrl
}

class MSFT_AADApplicationOnPremisesPublishingSingleSignOnSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('The preferred single-sign on mode for the application. Possible values are: none, onPremisesKerberos, aadHeaderBased,pingHeaderBased, oAuthToken.')]
    [System.String] $singleSignOnMode

    [DscProperty()]
    [System.ComponentModel.Description('The Kerberos Constrained Delegation settings for applications that use Integrated Window Authentication.')]
    [MSFT_AADApplicationOnPremisesPublishingSingleSignOnSettingKerberos] $kerberosSignOnSettings
}

class MSFT_AADApplicationOnPremisesPublishingSegmentCORS
{
    [DscProperty()]
    [System.ComponentModel.Description('The request headers that the origin domain may specify on the CORS request. The wildcard character * indicates that any header beginning with the specified prefix is allowed.')]
    [System.String[]] $allowedHeaders

    [DscProperty()]
    [System.ComponentModel.Description('The maximum amount of time that a browser should cache the response to the preflight OPTIONS request.')]
    [System.Nullable[System.UInt32]] $maxAgeInSeconds

    [DscProperty()]
    [System.ComponentModel.Description('Resource within the application segment for which CORS permissions are granted. / grants permission for whole app segment.')]
    [System.String] $resource

    [DscProperty()]
    [System.ComponentModel.Description('The HTTP request methods that the origin domain may use for a CORS request.')]
    [System.String[]] $allowedMethods

    [DscProperty()]
    [System.ComponentModel.Description('The origin domains that are permitted to make a request against the service via CORS. The origin domain is the domain from which the request originates. The origin must be an exact case-sensitive match with the origin that the user age sends to the service.')]
    [System.String[]] $allowedOrigins
}

class MSFT_AADApplicationOnPremisesPublishingSingleSignOnSettingKerberos
{
    [DscProperty()]
    [System.ComponentModel.Description('The Internal Application SPN of the application server. This SPN needs to be in the list of services to which the connector can present delegated credentials.')]
    [System.String] $kerberosServicePrincipalName

    [DscProperty()]
    [System.ComponentModel.Description('The Delegated Login Identity for the connector to use on behalf of your users. For more information, see Working with different on-premises and cloud identities . Possible values are: userPrincipalName, onPremisesUserPrincipalName, userPrincipalUsername, onPremisesUserPrincipalUsername, onPremisesSAMAccountName.')]
    [System.String] $kerberosSignOnMappingAttributeType
}
