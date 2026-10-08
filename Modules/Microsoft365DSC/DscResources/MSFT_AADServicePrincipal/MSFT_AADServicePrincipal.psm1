using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADServicePrincipal : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The unique identifier for the associated application.')]
    [System.String] $AppId

    [DscProperty()]
    [System.ComponentModel.Description('App role assignments for this app or service, granted to users, groups, and other service principals.')]
    [MSFT_AADServicePrincipalRoleAssignment[]] $AppRoleAssignedTo

    [DscProperty()]
    [System.ComponentModel.Description('The ObjectID of the ServicePrincipal')]
    [System.String] $ObjectID

    [DscProperty()]
    [System.ComponentModel.Description('Displayname of the ServicePrincipal.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The alternative names for this service principal')]
    [System.String[]] $AlternativeNames

    [DscProperty()]
    [System.ComponentModel.Description('True if the service principal account is enabled; otherwise, false.')]
    [System.Nullable[System.Boolean]] $AccountEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether an application role assignment is required.')]
    [System.Nullable[System.Boolean]] $AppRoleAssignmentRequired

    [DscProperty()]
    [System.ComponentModel.Description('Represents a claims policy that allows application admins to customize the claims emitted in tokens affected by this policy.')]
    [MSFT_AADServicePrincipalClaimsPolicy] $ClaimsPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Free text field to provide an internal end-user facing description of the service principal. End-user portals such MyApps displays the application description in this field. The maximum allowed size is 1,024 characters. Supports $filter (eq, ne, not, ge, le, startsWith) and $search.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the error URL of the ServicePrincipal.')]
    [System.String] $ErrorUrl

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the homepage of the ServicePrincipal.')]
    [System.String] $Homepage

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the URL where the service provider redirects the user to Microsoft Entra ID to authenticate.')]
    [System.String] $LoginUrl

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the LogoutURL of the ServicePrincipal.')]
    [System.String] $LogoutUrl

    [DscProperty()]
    [System.ComponentModel.Description('Notes associated with the ServicePrincipal.')]
    [System.String] $Notes

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the list of email addresses where Microsoft Entra ID sends a notification when the active certificate is near the expiration date. This is only for the certificates used to sign the SAML token issued for Microsoft Entra Gallery applications.')]
    [System.String[]] $NotificationEmailAddresses

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the PublisherName of the ServicePrincipal.')]
    [System.String] $PublisherName

    [DscProperty()]
    [System.ComponentModel.Description('List of the owners of the service principal.')]
    [System.String[]] $Owners

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the signle sign-on mode configured for this application.')]
    [System.String] $PreferredSingleSignOnMode

    [DscProperty()]
    [System.ComponentModel.Description('This property can be used on SAML applications (apps that have preferredSingleSignOnMode set to saml) to control which certificate is used to sign the SAML responses. For applications that aren''t SAML, don''t write or otherwise rely on this property.')]
    [System.String] $PreferredTokenSigningKeyThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('The URLs that user tokens are sent to for sign in with the associated application, or the redirect URIs that OAuth 2.0 authorization codes and access tokens are sent to for the associated application.')]
    [System.String[]] $ReplyUrls

    [DscProperty()]
    [System.ComponentModel.Description('The URL for the SAML metadata of the ServicePrincipal.')]
    [System.String] $SamlMetadataUrl

    [DscProperty()]
    [System.ComponentModel.Description('The collection for settings related to saml single sign-on.')]
    [MSFT_MicrosoftGraphsamlSingleSignOnSettings] $SamlSingleSignOnSettings

    [DscProperty()]
    [System.ComponentModel.Description('Specifies an array of service principal names. Based on the identifierURIs collection, plus the application''s appId property, these URIs are used to reference an application''s service principal.')]
    [System.String[]] $ServicePrincipalNames

    [DscProperty()]
    [System.ComponentModel.Description('The type of the service principal.')]
    [System.String] $ServicePrincipalType

    [DscProperty()]
    [System.ComponentModel.Description('Tags linked to this service principal.Note that if you intend for this service principal to show up in the All Applications list in the admin portal, you need to set this value to {WindowsAzureActiveDirectoryIntegratedApp}')]
    [System.String[]] $Tags

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the keyId of a public key from the keyCredentials collection. When configured, Microsoft Entra ID issues tokens for this application encrypted using the key specified by this property. The application code that receives the encrypted token must use the matching private key to decrypt the token before it can be used for the signed-in user.')]
    [System.String] $TokenEncryptionKeyId

    [DscProperty()]
    [System.ComponentModel.Description('The permission classifications for delegated permissions exposed by the app that this service principal represents.')]
    [MSFT_AADServicePrincipalDelegatedPermissionClassification[]] $DelegatedPermissionClassifications

    [DscProperty()]
    [System.ComponentModel.Description('The list of custom security attributes attached to this SPN')]
    [MSFT_AADServicePrincipalAttributeSet[]] $CustomSecurityAttributes

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Azure AD App should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Azure AD Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

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

    [DscProperty()]
    [System.ComponentModel.Description('The collection of password credentials associated with the service principal. Not nullable.')]
    [MSFT_MicrosoftGraphpasswordCredential[]] $PasswordCredentials

    [DscProperty()]
    [System.ComponentModel.Description('The collection of key credentials associated with the service principal. Not nullable. Supports $filter (eq, NOT, ge, le).')]
    [MSFT_MicrosoftGraphkeyCredential[]] $KeyCredentials

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    AADServicePrincipal() : base()
    {
        $this.ResourceCache['PropertiesToExport'] = 'AppDisplayName', 'AppId', 'Id', 'DisplayName', 'CustomSecurityAttributes', 'AlternativeNames', 'AccountEnabled', 'AppRoleAssignmentRequired', 'Description', 'ErrorUrl', 'Homepage', 'LoginUrl', 'LogoutUrl', 'Notes', 'NotificationEmailAddresses', 'PreferredSingleSignOnMode', 'PreferredTokenSigningKeyThumbprint', 'PublisherName', 'ReplyUrls', 'SamlMetadataUrl', 'SamlSingleSignOnSettings', 'ServicePrincipalNames', 'ServicePrincipalType', 'Tags', 'TokenEncryptionKeyId', 'KeyCredentials', 'PasswordCredentials'
        $this.ResourceCache['NavigationsToExpand'] = 'AppRoleAssignedTo'
    }

    [AADServicePrincipal] Get()
    {
        $permissionClassifications = $null
        $AADServicePrincipal = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADServicePrincipal]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AAD Service Principal with AppId {$($this.AppId)}"

        try
        {
            if (-not $this.ExportedInstance -or ($this.ExportedInstance.AppId -ne $this.AppId -and $this.ExportedInstance.DisplayName -ne $this.AppId))
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                if (-not [System.String]::IsNullOrEmpty($this.ObjectID))
                {
                    $AADServicePrincipal = Get-MgBetaServicePrincipal -ServicePrincipalId $this.ObjectId `
                        -Property $this.ResourceCache['PropertiesToExport'] `
                        -ExpandProperty $this.ResourceCache['NavigationsToExpand'] `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $AADServicePrincipal)
                {
                    if (-not [System.Guid]::TryParse($this.AppId, [ref][System.Guid]::Empty))
                    {
                        $AADServicePrincipal = [Array](Get-MgBetaServicePrincipal -Filter "DisplayName eq '$($this.AppId -replace "'", "''")'" `
                                -Property $this.ResourceCache['PropertiesToExport'] `
                                -Expand $this.ResourceCache['NavigationsToExpand'])
                        if ($null -ne $AADServicePrincipal -and $AADServicePrincipal.Count -gt 1)
                        {
                            throw "Multiple Service Principal with the DisplayName $($this.AppId) exist in the tenant."
                        }
                    }
                    else
                    {
                        $AADServicePrincipal = Get-MgBetaServicePrincipal -Filter "AppID eq '$($this.AppId)'" `
                            -Property $this.ResourceCache['PropertiesToExport'] `
                            -Expand $this.ResourceCache['NavigationsToExpand']
                    }
                }
                if ($null -eq $AADServicePrincipal)
                {
                    Write-Verbose -Message "Service Principal with AppId '$($this.AppId)' not found."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $AADServicePrincipal = $this.ExportedInstance
            }

            $batchRequests = @()
            $assignmentsValue = $this.ResolveExpandedNavigation($AADServicePrincipal, 'AppRoleAssignedTo')
            if ($null -eq $assignmentsValue)
            {
                $batchRequests += @{
                    id     = 'AppRoleAssignedTo'
                    method = 'GET'
                    url    = "/servicePrincipals/$($AADServicePrincipal.Id)/appRoleAssignedTo"
                }
            }
            $prefetched = $null
            $navigationCache = $this.ResourceCache['NavigationCache']
            if ($null -ne $navigationCache -and $navigationCache.ContainsKey($AADServicePrincipal.Id))
            {
                $prefetched = $navigationCache[$AADServicePrincipal.Id]
            }

            $ownersInfo = $null
            $permissionClassifications = $null
            $claimsPolicyBody = $null
            if ($null -ne $prefetched)
            {
                $ownersInfo = $prefetched.Owners
                $permissionClassifications = $prefetched.DelegatedPermissionClassifications
                $claimsPolicyBody = $prefetched.ClaimsPolicy
            }
            else
            {
                $batchRequests += @{
                    id     = 'Owners'
                    method = 'GET'
                    url    = "/servicePrincipals/$($AADServicePrincipal.Id)/owners"
                }
                $batchRequests += @{
                    id     = 'delegatedPermissionClassifications'
                    method = 'GET'
                    url    = "/servicePrincipals/$($AADServicePrincipal.Id)/delegatedPermissionClassifications"
                }
                $batchRequests += @{
                    id     = 'claimsPolicy'
                    method = 'GET'
                    url    = "/servicePrincipals/$($AADServicePrincipal.Id)/claimsPolicy"
                }
            }

            $batchResponse = @()
            if ($batchRequests.Count -gt 0)
            {
                $batchResponse = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests -ErrorAction SilentlyContinue
            }

            $AppRoleAssignedToValues = @()
            if ($null -eq $assignmentsValue)
            {
                $assignmentsValue = ($batchResponse | Where-Object -FilterScript { $_.id -eq 'AppRoleAssignedTo' }).body.value
            }
            foreach ($principal in $assignmentsValue)
            {
                $currentAssignment = @{
                    PrincipalType = $null
                    Identity      = $null
                }
                if ($principal.PrincipalType -eq 'User')
                {
                    $user = Get-MgUser -UserId $principal.PrincipalId
                    $currentAssignment.PrincipalType = 'User'
                    $currentAssignment.Identity = $user.UserPrincipalName
                    $AppRoleAssignedToValues += $currentAssignment
                }
                elseif ($principal.PrincipalType -eq 'Group')
                {
                    $group = Get-MgGroup -GroupId $principal.PrincipalId
                    $currentAssignment.PrincipalType = 'Group'
                    $currentAssignment.Identity = $group.DisplayName
                    $AppRoleAssignedToValues += $currentAssignment
                }
            }

            $ownersValues = @()
            if ($null -eq $ownersInfo)
            {
                $ownersInfo = ($batchResponse | Where-Object -FilterScript { $_.id -eq 'Owners' }).body.value
            }
            foreach ($ownerInfo in $ownersInfo)
            {
                if ($ownerInfo.'@odata.type' -eq '#microsoft.graph.user')
                {
                    $ownersValues += $ownerInfo.UserPrincipalName
                }
                else
                {
                    $ownersValues += $ownerInfo.DisplayName
                }
            }

            $claimsPolicyValue = $null
            if ($null -eq $claimsPolicyBody)
            {
                $claimsPolicyResponse = ($batchResponse | Where-Object -FilterScript { $_.id -eq 'claimsPolicy' })
                if ($claimsPolicyResponse -and $claimsPolicyResponse.status -eq 200 -and $claimsPolicyResponse.body)
                {
                    $claimsPolicyBody = $claimsPolicyResponse.body
                }
            }
            if ($null -ne $claimsPolicyBody)
            {
                $claimsPolicyValue = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $claimsPolicyBody
                $claimsPolicyValue.Remove('@odata.context') | Out-Null
                $claimsPolicyValue.Remove('id') | Out-Null
                $claimsPolicyValue = Rename-M365DSCCimInstanceParameter -Properties $claimsPolicyValue `
                    -KeyMapping @{ '@odata.type' = 'odataType' }
            }

            #Managed Identities in AzureGov return exception when pulling delegatedPermissionClassifications
            [Array]$complexDelegatedPermissionClassifications = @()
            try
            {
                if ($null -eq $permissionClassifications)
                {
                    $permissionClassifications = ($batchResponse | Where-Object -FilterScript { $_.id -eq 'delegatedPermissionClassifications' }).body.value
                }
            }
            catch
            {
                Write-Verbose -Message "Service Principal didn't return delegated permission classifications. Expected for Managed Identities."
            }

            foreach ($permissionClassification in $permissionClassifications)
            {
                $hashtable = @{
                    classification = $permissionClassification.Classification
                    permissionName = $permissionClassification.permissionName
                }
                $complexDelegatedPermissionClassifications += $hashtable
            }

            $complexKeyCredentials = @()
            foreach ($currentkeyCredentials in $AADServicePrincipal.keyCredentials)
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
            foreach ($currentpasswordCredentials in $AADServicePrincipal.passwordCredentials)
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

            $complexCustomSecurityAttributes = [Array]($this.GetCustomSecurityAttributes($AADServicePrincipal))
            if ($null -eq $complexCustomSecurityAttributes)
            {
                $complexCustomSecurityAttributes = @()
            }

            # If the App Id was passed in as a Guid, return it as a GUID. Otherwise return it as text.
            if (-not [System.String]::IsNullOrEmpty($this.AppId) -and [System.Guid]::TryParse($this.AppId, [ref][System.Guid]::Empty))
            {
                Write-Verbose -Message 'Returning AppId as GUID since the provided value was in GUID format.'
                $appIdToExport = $AADServicePrincipal.AppId
            }
            else
            {
                Write-Verbose -Message 'Returning AppId as Display Name since the provided value was NOT in GUID format.'
                $appIdToExport = $AADServicePrincipal.DisplayName
            }

            $tagsValue = @()
            if ($null -ne $AADServicePrincipal.Tags)
            {
                $tagsValue = [Array]($AADServicePrincipal.Tags)
            }

            $alternativeNamesValue = @()
            if ($null -ne $AADServicePrincipal.AlternativeNames)
            {
                $alternativeNamesValue = [Array]($AADServicePrincipal.AlternativeNames)
            }

            $replyUrlsValue = @()
            if ($null -ne $AADServicePrincipal.ReplyURLs)
            {
                $replyUrlsValue = [Array]($AADServicePrincipal.ReplyURLs)
            }

            $servicePrincipalNamesValue = @()
            if ($null -ne $AADServicePrincipal.ServicePrincipalNames)
            {
                $servicePrincipalNamesValue = [Array]($AADServicePrincipal.ServicePrincipalNames)
            }

            $notificationEmailAddressesValue = @()
            if ($null -ne $AADServicePrincipal.NotificationEmailAddresses)
            {
                $notificationEmailAddressesValue = Get-M365DSCArrayFromProperty -PropertyValue ($AADServicePrincipal.NotificationEmailAddresses) -ElementType ([System.String])
            }

            $samlSingleSignOnSettingsValue = $null
            if ($null -ne $AADServicePrincipal.SamlSingleSignOnSettings)
            {
                $samlSingleSignOnSettingsValue = @{
                    RelayState = $AADServicePrincipal.SamlSingleSignOnSettings.relayState
                }
            }

            $result = @{
                AppId                              = $appIdToExport
                AppRoleAssignedTo                  = $AppRoleAssignedToValues
                ObjectID                           = $AADServicePrincipal.Id
                DisplayName                        = $AADServicePrincipal.DisplayName
                AlternativeNames                   = $alternativeNamesValue
                AccountEnabled                     = [boolean]$AADServicePrincipal.AccountEnabled
                AppRoleAssignmentRequired          = $AADServicePrincipal.AppRoleAssignmentRequired
                ClaimsPolicy                       = $claimsPolicyValue
                CustomSecurityAttributes           = $complexCustomSecurityAttributes
                DelegatedPermissionClassifications = [Array]$complexDelegatedPermissionClassifications
                Description                        = $AADServicePrincipal.Description
                ErrorUrl                           = $AADServicePrincipal.ErrorUrl
                Homepage                           = $AADServicePrincipal.Homepage
                LoginUrl                           = $AADServicePrincipal.LoginUrl
                LogoutUrl                          = $AADServicePrincipal.LogoutUrl
                Notes                              = $AADServicePrincipal.Notes
                NotificationEmailAddresses         = $notificationEmailAddressesValue
                Owners                             = $ownersValues
                PreferredSingleSignOnMode          = $AADServicePrincipal.PreferredSingleSignOnMode
                PreferredTokenSigningKeyThumbprint = $AADServicePrincipal.PreferredTokenSigningKeyThumbprint
                PublisherName                      = $AADServicePrincipal.PublisherName
                ReplyURLs                          = $replyUrlsValue
                SamlMetadataURL                    = $AADServicePrincipal.SamlMetadataURL
                SamlSingleSignOnSettings           = $samlSingleSignOnSettingsValue
                ServicePrincipalNames              = $servicePrincipalNamesValue
                ServicePrincipalType               = $AADServicePrincipal.ServicePrincipalType
                Tags                               = $tagsValue
                TokenEncryptionKeyId               = $AADServicePrincipal.TokenEncryptionKeyId
                KeyCredentials                     = $complexKeyCredentials
                PasswordCredentials                = $complexPasswordCredentials
                Ensure                             = 'Present'
                Credential                         = $this.Credential
                ApplicationId                      = $this.ApplicationId
                ApplicationSecret                  = $this.ApplicationSecret
                TenantId                           = $this.TenantId
                CertificateThumbprint              = $this.CertificateThumbprint
                CertificatePath                    = $this.CertificatePath
                CertificatePassword                = $this.CertificatePassword
                ManagedIdentity                    = $this.ManagedIdentity
                AccessTokens                       = $this.AccessTokens
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
        $diffOwners = $null
        $IdentifierUris = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message 'Setting configuration of Azure AD ServicePrincipal'
        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentAADServicePrincipal = $this.Get().ToHashtable()
        $currentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $currentParameters.Remove('ClaimsPolicy') | Out-Null
        $currentParameters.Remove('ObjectId') | Out-Null
        $currentParameters.Remove('Owners') | Out-Null
        $currentParameters.Remove('KeyCredentials') | Out-Null
        $currentParameters.Remove('PasswordCredentials') | Out-Null
        $currentParameters.Remove('DelegatedPermissionClassifications') | Out-Null
        $AppRoleAssignedToSpecified = $currentParameters.ContainsKey('AppRoleAssignedTo')
        $currentParameters.Remove('AppRoleAssignedTo') | Out-Null
        $currentParameters.Remove('LogoutUrl') | Out-Null
        $appIdIsGuid = [System.Guid]::TryParse($this.AppId, [ref][System.Guid]::Empty)
        $resolvedAppId = $null
        $oldAppId = $null
        $servicePrincipalDetails = $null

        if ($appIdIsGuid)
        {
            $resolvedAppId = $this.AppId
        }

        # update the custom security attributes to be cmdlet comsumable
        if ($null -ne $currentParameters.CustomSecurityAttributes -and $currentParameters.CustomSecurityAttributes.Count -gt 0)
        {
            $currentSCAValue = $this.GetCustomSecurityAttributesAsCmdletHashtable($currentParameters.CustomSecurityAttributes)
            $currentParameters.Remove('CustomSecurityAttributes') | Out-Null
            $currentParameters.Add('customSecurityAttributes', $currentSCAValue)
        }
        else
        {
            $currentParameters.Remove('CustomSecurityAttributes')
        }

        if ($null -ne $currentParameters.SamlSingleSignOnSettings)
        {
            $currentParameters.SamlSingleSignOnSettings = Rename-M365DSCCimInstanceParameter -Properties $currentParameters.SamlSingleSignOnSettings
        }

        # ServicePrincipal should exist but it doesn't
        if ($this.Ensure -eq 'Present' -and $currentAADServicePrincipal.Ensure -eq 'Absent')
        {
            if (-not $appIdIsGuid)
            {
                Write-Verbose -Message 'AppId was provided as a DisplayName. Translating it to a GUID for service principal creation.'
                [Array]$matchedApplications = Get-MgApplication -Filter "DisplayName eq '$($this.AppId -replace "'", "''")'" -Property 'appId', 'identifierUris'
                if ($null -eq $matchedApplications -or $matchedApplications.Count -eq 0)
                {
                    throw "No application found with DisplayName matching '$($this.AppId)'."
                }
                if ($matchedApplications.Count -gt 1)
                {
                    throw "Multiple applications found with DisplayName '$($this.AppId)'. Please provide the AppId GUID instead."
                }
                $resolvedAppId = $matchedApplications[0].AppId
                $oldAppId = $this.AppId
                $currentParameters.ServicePrincipalNames = Get-M365DSCArrayFromProperty -PropertyValue $matchedApplications[0].IdentifierUris -ElementType ([System.String])
                $currentParameters.ServicePrincipalNames += $resolvedAppId
                Write-Verbose -Message "Translated DisplayName to AppId {$resolvedAppId}"
            }

            $currentParameters.AppId = $resolvedAppId
            Write-Verbose -Message 'Creating new Service Principal'
            $newSP = New-MgBetaServicePrincipal -BodyParameter $currentParameters
            Start-Sleep -Seconds 4

            # Assign Owners
            foreach ($owner in $this.Owners)
            {
                $userInfo = Get-MgUser -UserId $owner
                $body = @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/directoryObjects/$($userInfo.Id)"
                }
                Write-Verbose -Message "Adding new owner {$owner}"
                Invoke-M365DSCCommand -ScriptBlock { New-MgBetaServicePrincipalOwnerByRef -ServicePrincipalId $newSP.Id -BodyParameter $body -ErrorAction Stop } -RetryOnNotFoundError -MaxRetries 4
            }

            # Adding delegated permissions classifications
            if ($null -ne $this.DelegatedPermissionClassifications)
            {
                foreach ($permissionClassification in $this.DelegatedPermissionClassifications)
                {
                    $params = @{
                        classification = $permissionClassification.Classification
                        permissionName = $permissionClassification.permissionName
                    }
                    Invoke-M365DSCCommand -ScriptBlock { New-MgBetaServicePrincipalDelegatedPermissionClassification -ServicePrincipalId $newSP.Id -BodyParameter $params -ErrorAction Stop } -RetryOnNotFoundError -MaxRetries 4
                }
            }

            # Update AppRoleAssignedTo
            if ($AppRoleAssignedToSpecified)
            {
                Write-Verbose -Message 'Updating AppRoleAssignedTo value'
                foreach ($assignment in $this.AppRoleAssignedTo)
                {
                    if ($assignment.PrincipalType -eq 'User')
                    {
                        Write-Verbose -Message "Retrieving user {$($assignment.Identity)}"
                        $user = Get-MgUser -Filter "startswith(UserPrincipalName, '$($assignment.Identity)')"
                        $PrincipalIdValue = $user.Id
                    }
                    else
                    {
                        Write-Verbose -Message "Retrieving group {$($assignment.Identity)}"
                        $group = Get-MgGroup -Filter "DisplayName eq '$($assignment.Identity -replace "'", "''")'"
                        $PrincipalIdValue = $group.Id
                    }

                    $appRoleId = $this.GetAppRoleId($newSP.AppRoles, $assignment.PrincipalType)
                    $bodyParam = @{
                        principalId = $PrincipalIdValue
                        resourceId  = $newSP.Id
                        appRoleId   = $appRoleId
                    }
                    Write-Verbose -Message "Adding Service Principal AppRoleAssignedTo with values:`r`n$(ConvertTo-Json $bodyParam -Depth 3)"
                    Invoke-M365DSCCommand -ScriptBlock { New-MgBetaServicePrincipalAppRoleAssignedTo -ServicePrincipalId $newSP.Id -BodyParameter $bodyParam -ErrorAction Stop } -RetryOnNotFoundError -MaxRetries 4
                }
            }

            if ($this.GetBoundParameters().ContainsKey('ClaimsPolicy'))
            {
                Write-Verbose -Message 'Adding Claims Policy to the Service Principal'
                $claimsPolicyBody = Rename-M365DSCCimInstanceParameter -Properties $this.ClaimsPolicy
                Invoke-M365DSCCommand -ScriptBlock { Set-MgBetaServicePrincipalClaimPolicy -ServicePrincipalId $newSP.Id -BodyParameter $claimsPolicyBody -ErrorAction Stop } -RetryOnNotFoundError
            }
        }
        # ServicePrincipal should exist and will be configured to desired state
        elseif ($this.Ensure -eq 'Present' -and $currentAADServicePrincipal.Ensure -eq 'Present')
        {
            Write-Verbose -Message 'Updating existing Service Principal'
            $currentParameters.Remove('AppId') | Out-Null
            $currentParameters.Remove("ReplyUrls") | Out-Null
            Write-Verbose -Message "CurrentParameters: $($currentParameters | Out-String)"
            Write-Verbose -Message "ServicePrincipalID: $($currentAADServicePrincipal.ObjectID)"

            if ($this.PreferredSingleSignOnMode -eq 'saml')
            {
                if ($null -eq $servicePrincipalDetails)
                {
                    $servicePrincipalDetails = Get-MgBetaServicePrincipal -ServicePrincipalId $currentAADServicePrincipal.ObjectID -Property 'AppId'
                }
                $identifiersToExclude = @($this.AppId, $resolvedAppId, $oldAppId, $servicePrincipalDetails.AppId) | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) } | Select-Object -Unique
                $IdentifierUris = @($this.ServicePrincipalNames | Where-Object -FilterScript { $_ -notin $identifiersToExclude })
                $currentParameters.Remove('ServicePrincipalNames')
            }

            #removing the current custom security attributes
            if ($currentAADServicePrincipal.CustomSecurityAttributes.Count -gt 0)
            {
                $currentAADServicePrincipal.CustomSecurityAttributes = $this.GetCustomSecurityAttributesAsCmdletHashtable($currentAADServicePrincipal.CustomSecurityAttributes, $true)
                $CSAParams = @{
                    customSecurityAttributes = $currentAADServicePrincipal.CustomSecurityAttributes
                }
                Update-MgBetaServicePrincipal -ServicePrincipalId $currentAADServicePrincipal.ObjectID -BodyParameter $CSAParams
            }
            Update-MgBetaServicePrincipal -ServicePrincipalId $currentAADServicePrincipal.ObjectID -BodyParameter $currentParameters

            if ($this.GetBoundParameters().ContainsKey('ClaimsPolicy'))
            {
                Write-Verbose -Message 'Updating Claims Policy on the Service Principal'
                $claimsPolicyBody = Rename-M365DSCCimInstanceParameter -Properties $this.ClaimsPolicy
                $null = Set-MgBetaServicePrincipalClaimPolicy -ServicePrincipalId $currentAADServicePrincipal.ObjectID -BodyParameter $claimsPolicyBody
            }

            if ($IdentifierUris)
            {
                Write-Verbose -Message 'Updating the Application ID Uri on the application instance.'
                if ($null -eq $servicePrincipalDetails)
                {
                    $servicePrincipalDetails = Get-MgBetaServicePrincipal -ServicePrincipalId $currentAADServicePrincipal.ObjectID -Property 'AppId'
                }

                [Array]$matchedApplications = Get-MgApplication -Filter "AppId eq '$($servicePrincipalDetails.AppId)'"
                if ($null -eq $matchedApplications -or $matchedApplications.Count -eq 0)
                {
                    throw "Unable to resolve the application object for service principal '$($currentAADServicePrincipal.DisplayName)' while updating ServicePrincipalNames. This can happen for cross-tenant applications."
                }

                $IdentifierUris = Get-M365DSCArrayFromProperty -PropertyValue $IdentifierUris -ElementType ([System.String])
                Update-MgApplication -ApplicationId $matchedApplications[0].Id -BodyParameter @{
                    identifierUris = $IdentifierUris
                }
            }
            if ($AppRoleAssignedToSpecified)
            {
                Write-Verbose -Message 'Need to update AppRoleAssignedTo value'
                [Array]$currentPrincipals = $currentAADServicePrincipal.AppRoleAssignedTo.Identity
                [Array]$desiredPrincipals = $this.AppRoleAssignedTo.Identity

                if ($null -eq $currentPrincipals)
                {
                    $currentPrincipals = @()
                }
                if ($null -eq $desiredPrincipals)
                {
                    $desiredPrincipals = @()
                }

                [Array]$differences = Compare-Object -ReferenceObject $currentPrincipals -DifferenceObject $desiredPrincipals
                [Array]$membersToAdd = $differences | Where-Object -FilterScript { $_.SideIndicator -eq '=>' }
                [Array]$membersToRemove = $differences | Where-Object -FilterScript { $_.SideIndicator -eq '<=' }

                if ($differences.Count -gt 0)
                {
                    if ($membersToAdd.Count -gt 0)
                    {
                        $AppRoleAssignedToValues = @()
                        foreach ($assignment in $this.AppRoleAssignedTo)
                        {
                            $AppRoleAssignedToValues += @{
                                PrincipalType = $assignment.PrincipalType
                                Identity      = $assignment.Identity
                            }
                        }
                        foreach ($member in $membersToAdd)
                        {
                            $assignment = $AppRoleAssignedToValues | Where-Object -FilterScript { $_.Identity -eq $member.InputObject }
                            if ($assignment.PrincipalType -eq 'User')
                            {
                                Write-Verbose -Message "Retrieving user {$($assignment.Identity)}"
                                $user = Get-MgUser -Filter "startswith(UserPrincipalName, '$($assignment.Identity)')"
                                $PrincipalIdValue = $user.Id
                            }
                            else
                            {
                                Write-Verbose -Message "Retrieving group {$($assignment.Identity)}"
                                $group = Get-MgGroup -Filter "DisplayName eq '$($assignment.Identity -replace "'", "''")'"
                                $PrincipalIdValue = $group.Id
                            }

                            if ($null -eq $servicePrincipalDetails)
                            {
                                $servicePrincipalDetails = Get-MgBetaServicePrincipal -ServicePrincipalId $currentAADServicePrincipal.ObjectID -Property 'AppRoles'
                            }

                            $appRoleId = $this.GetAppRoleId($servicePrincipalDetails.AppRoles, $assignment.PrincipalType)
                            $bodyParam = @{
                                principalId = $PrincipalIdValue
                                resourceId  = $currentAADServicePrincipal.ObjectID
                                appRoleId   = $appRoleId
                            }
                            Write-Verbose -Message "Adding member {$($member.InputObject.ToString())}"
                            New-MgBetaServicePrincipalAppRoleAssignedTo -ServicePrincipalId $currentAADServicePrincipal.ObjectID `
                                -BodyParameter $bodyParam | Out-Null
                        }
                    }

                    if ($membersToRemove.Count -gt 0)
                    {
                        $AppRoleAssignedToValues = @()
                        foreach ($assignment in $currentAADServicePrincipal.AppRoleAssignedTo)
                        {
                            $AppRoleAssignedToValues += @{
                                PrincipalType = $assignment.PrincipalType
                                Identity      = $assignment.Identity
                            }
                        }
                        foreach ($member in $membersToRemove)
                        {
                            $assignment = $AppRoleAssignedToValues | Where-Object -FilterScript { $_.Identity -eq $member.InputObject }
                            if ($assignment.PrincipalType -eq 'User')
                            {
                                Write-Verbose -Message "Retrieving user {$($assignment.Identity)}"
                                $user = Get-MgUser -Filter "startswith(UserPrincipalName, '$($assignment.Identity)')"
                                $PrincipalIdValue = $user.Id
                            }
                            else
                            {
                                Write-Verbose -Message "Retrieving group {$($assignment.Identity)}"
                                $group = Get-MgGroup -Filter "DisplayName eq '$($assignment.Identity -replace "'", "''")'"
                                $PrincipalIdValue = $group.Id
                            }
                            Write-Verbose -Message "PrincipalID Value = '$PrincipalIdValue'"
                            Write-Verbose -Message "ServicePrincipalId = '$($currentAADServicePrincipal.ObjectID)'"
                            $allAssignments = Get-MgBetaServicePrincipalAppRoleAssignedTo -ServicePrincipalId $currentAADServicePrincipal.ObjectID -All
                            $assignmentToRemove = $allAssignments | Where-Object -FilterScript { $_.PrincipalId -eq $PrincipalIdValue }
                            Write-Verbose -Message "Removing member {$($member.InputObject.ToString())}"
                            Remove-MgBetaServicePrincipalAppRoleAssignedTo -ServicePrincipalId $currentAADServicePrincipal.ObjectID `
                                -AppRoleAssignmentId $assignmentToRemove.Id | Out-Null
                        }
                    }
                }
            }

            Write-Verbose -Message 'Checking if owners need to be updated...'

            if ($null -ne $this.Owners)
            {
                $diffOwners = Compare-Object -ReferenceObject $currentAADServicePrincipal.Owners -DifferenceObject $this.Owners
            }
            foreach ($diff in $diffOwners)
            {
                $ownerInfo = Get-MgUser -UserId $diff.InputObject -ErrorAction SilentlyContinue
                if ($null -eq $ownerInfo)
                {
                    $ownerInfo = Get-MgBetaServicePrincipal -Filter "displayName eq '$($diff.InputObject -replace "'", "''")'" -ErrorAction SilentlyContinue
                    if ($null -eq $ownerInfo)
                    {
                        throw "Owner {$($diff.InputObject)} was not found as a user or service principal in the tenant."
                    }
                }
                if ($diff.SideIndicator -eq '=>')
                {
                    $body = @{
                        '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/directoryObjects/$($ownerInfo.Id)"
                    }
                    Write-Verbose -Message "Adding owner {$($ownerInfo.Id)}"
                    New-MgBetaServicePrincipalOwnerByRef -ServicePrincipalId $currentAADServicePrincipal.ObjectId `
                        -BodyParameter $body | Out-Null
                }
                else
                {
                    Write-Verbose -Message "Removing owner {$($ownerInfo.Id)}"
                    Remove-MgBetaServicePrincipalOwnerDirectoryObjectByRef -ServicePrincipalId $currentAADServicePrincipal.ObjectId `
                        -DirectoryObjectId $ownerInfo.Id | Out-Null
                }
            }

            Write-Verbose -Message 'Checking if DelegatedPermissionClassifications need to be updated...'

            if ($null -ne $this.DelegatedPermissionClassifications)
            {
                # removing old perm classifications
                $permissionClassificationList = Get-MgBetaServicePrincipalDelegatedPermissionClassification -ServicePrincipalId $currentAADServicePrincipal.ObjectID
                foreach ($permissionClassification in $permissionClassificationList)
                {
                    Remove-MgBetaServicePrincipalDelegatedPermissionClassification `
                        -ServicePrincipalId $currentAADServicePrincipal.ObjectID `
                        -DelegatedPermissionClassificationId $permissionClassification.Id
                }

                # adding new perm classifications
                foreach ($permissionClassification in $this.DelegatedPermissionClassifications)
                {
                    $params = @{
                        classification = $permissionClassification.Classification
                        permissionName = $permissionClassification.permissionName
                    }
                    New-MgBetaServicePrincipalDelegatedPermissionClassification `
                        -ServicePrincipalId $currentAADServicePrincipal.ObjectID `
                        -BodyParameter $params
                }
            }
        }
        # ServicePrincipal exists but should not
        elseif ($this.Ensure -eq 'Absent' -and $currentAADServicePrincipal.Ensure -eq 'Present')
        {
            Write-Verbose -Message 'Removing Service Principal'
            Remove-MgBetaServicePrincipal -ServicePrincipalId $currentAADServicePrincipal.ObjectID
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

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        $dscContent = [System.Text.StringBuilder]::new()
        try
        {
            $i = 1
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            [array] $exportedInstances = Get-MgBetaServicePrincipal -All `
                -Filter $this.Filter `
                -Expand $this.ResourceCache['NavigationsToExpand'] `
                -Property $this.ResourceCache['PropertiesToExport'] `
                -ErrorAction Stop

            $navigationCache = @{}
            $navigationRequests = @()
            foreach ($AADServicePrincipal in $exportedInstances)
            {
                $navigationCache[$AADServicePrincipal.Id] = @{
                    Owners                             = @()
                    DelegatedPermissionClassifications = @()
                    ClaimsPolicy                       = $null
                }
                $navigationRequests += @{
                    id     = "$($AADServicePrincipal.Id)|Owners"
                    method = 'GET'
                    url    = "/servicePrincipals/$($AADServicePrincipal.Id)/owners"
                }
                $navigationRequests += @{
                    id     = "$($AADServicePrincipal.Id)|DelegatedPermissionClassifications"
                    method = 'GET'
                    url    = "/servicePrincipals/$($AADServicePrincipal.Id)/delegatedPermissionClassifications"
                }
                $navigationRequests += @{
                    id     = "$($AADServicePrincipal.Id)|ClaimsPolicy"
                    method = 'GET'
                    url    = "/servicePrincipals/$($AADServicePrincipal.Id)/claimsPolicy"
                }
            }
            if ($navigationRequests.Count -gt 0)
            {
                $navigationResponses = Invoke-M365DSCGraphBatchRequest -Requests $navigationRequests -ErrorAction SilentlyContinue
                foreach ($navigationResponse in $navigationResponses)
                {
                    if ($navigationResponse.status -ne 200 -or $null -eq $navigationResponse.body)
                    {
                        continue
                    }

                    $separatorIndex = ([System.String]$navigationResponse.id).LastIndexOf('|')
                    if ($separatorIndex -lt 0)
                    {
                        continue
                    }

                    $principalId = ([System.String]$navigationResponse.id).Substring(0, $separatorIndex)
                    $navigationName = ([System.String]$navigationResponse.id).Substring($separatorIndex + 1)
                    if (-not $navigationCache.ContainsKey($principalId))
                    {
                        continue
                    }

                    if ($navigationName -eq 'ClaimsPolicy')
                    {
                        $navigationCache[$principalId][$navigationName] = $navigationResponse.body
                    }
                    else
                    {
                        $navigationCache[$principalId][$navigationName] = @($navigationResponse.body.value)
                    }
                }
            }
            $this.ResourceCache['NavigationCache'] = $navigationCache

            $duplicateDisplayNames = @($exportedInstances | Group-Object -Property 'DisplayName' |
                Where-Object -FilterScript { $_.Count -gt 1 } |
                Select-Object -ExpandProperty 'Name')

            foreach ($AADServicePrincipal in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $appIdValue = $AADServicePrincipal.DisplayName
                if ($duplicateDisplayNames -contains $AADServicePrincipal.DisplayName)
                {
                    $appIdValue = $AADServicePrincipal.AppId
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($AADServicePrincipal.DisplayName)" -DeferWrite
                $Params = @{
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    ApplicationSecret     = $this.ApplicationSecret
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AppID                 = $appIdValue
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $AADServicePrincipal
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()
                if ($Results.Ensure -eq 'Present')
                {
                    if ($Results.AppRoleAssignedTo.Count -gt 0)
                    {
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.AppRoleAssignedTo `
                            -CIMInstanceName 'AADServicePrincipalRoleAssignment'
                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.AppRoleAssignedTo = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('AppRoleAssignedTo') | Out-Null
                        }
                    }
                    if ($null -ne $Results.ClaimsPolicy)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'claims'
                                CimInstanceName = 'AADServicePrincipalCustomClaim'
                                IsRequired      = $False
                            },
                            @{
                                Name            = 'groupFilter'
                                CimInstanceName = 'AADServicePrincipalClaimsPolicyGroupFilter'
                                IsRequired      = $False
                            },
                            @{
                                Name            = 'input'
                                CimInstanceName = 'MSFT_AADServicePrincipalTransformationAttribute'
                                IsRequired      = $False
                            },
                            @{
                                Name            = 'configurations'
                                CimInstanceName = 'AADServicePrincipalCustomClaimConfiguration'
                                IsRequired      = $False
                            },
                            @{
                                Name            = 'attribute'
                                CimInstanceName = 'AADServicePrincipalCustomClaimAttribute'
                                IsRequired      = $False
                            },
                            @{
                                Name            = 'condition'
                                CimInstanceName = 'AADServicePrincipalCustomClaimCondition'
                                IsRequired      = $False
                            },
                            @{
                                Name            = 'transformations'
                                CimInstanceName = 'AADServicePrincipalCustomClaimTransformation'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.ClaimsPolicy `
                            -CIMInstanceName 'AADServicePrincipalClaimsPolicy' `
                            -ComplexTypeMapping $complexMapping
                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.ClaimsPolicy = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('ClaimsPolicy') | Out-Null
                        }
                    }
                    if ($Results.DelegatedPermissionClassifications.Count -gt 0)
                    {
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.DelegatedPermissionClassifications `
                            -CIMInstanceName 'AADServicePrincipalDelegatedPermissionClassification' -IsArray:$true
                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.DelegatedPermissionClassifications = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('DelegatedPermissionClassifications') | Out-Null
                        }
                    }
                    if ($null -ne $Results.KeyCredentials)
                    {
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.KeyCredentials `
                            -CIMInstanceName 'MicrosoftGraphkeyCredential' -IsArray:$true
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
                            -CIMInstanceName 'MicrosoftGraphpasswordCredential' -IsArray:$true
                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.PasswordCredentials = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('PasswordCredentials') | Out-Null
                        }
                    }
                    if ($null -ne $Results.SamlSingleSignOnSettings)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'SamlSingleSignOnSettings'
                                CimInstanceName = 'MicrosoftGraphsamlSingleSignOnSettings'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.SamlSingleSignOnSettings `
                            -CIMInstanceName 'MicrosoftGraphsamlSingleSignOnSettings' `
                            -ComplexTypeMapping $complexMapping
                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.SamlSingleSignOnSettings = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('SamlSingleSignOnSettings') | Out-Null
                        }
                    }
                    if ($Results.CustomSecurityAttributes.Count -gt 0)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'CustomSecurityAttributes'
                                CimInstanceName = 'AADServicePrincipalAttributeSet'
                                IsRequired      = $False
                            },
                            @{
                                Name            = 'AttributeValues'
                                CimInstanceName = 'AADServicePrincipalAttributeValue'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.CustomSecurityAttributes `
                            -CIMInstanceName 'AADServicePrincipalAttributeSet' `
                            -ComplexTypeMapping $complexMapping `
                            -IsArray
                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.CustomSecurityAttributes = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('CustomSecurityAttributes') | Out-Null
                        }
                    }
                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential `
                        -NoEscape @('AppRoleAssignedTo', 'ClaimsPolicy', 'DelegatedPermissionClassifications', 'KeyCredentials', 'PasswordCredentials', 'CustomSecurityAttributes', 'SamlSingleSignOnSettings') `
                        -RawResults $rawResults

                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName

                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
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
            ExcludedProperties = @('ObjectId', 'KeyCredentials', 'PasswordCredentials', 'ReplyUrls', 'LogoutUrl')
        }
    }

    hidden [System.String] GetAppRoleId([System.Object[]] $AppRoles, [System.String] $PrincipalType)
    {
        $appRoleId = ($AppRoles | Where-Object -FilterScript { $_.DisplayName -eq $PrincipalType } | Select-Object -First 1).Id
        if ([System.String]::IsNullOrEmpty($appRoleId))
        {
            $appRoleId = '00000000-0000-0000-0000-000000000000'
        }

        return $appRoleId
    }

    hidden [System.Collections.Hashtable] NewAttributeValue([System.String] $AttributeName, [System.Object] $Value)
    {
        $attributeValue = @{
            AttributeName    = $AttributeName
            StringArrayValue = $null
            IntArrayValue    = $null
            StringValue      = $null
            IntValue         = $null
            BoolValue        = $null
        }

        # Handle different types of values
        if ($Value -is [string])
        {
            $attributeValue.StringValue = $Value
        }
        elseif ($Value -is [System.Int32] -or $Value -is [System.Int64])
        {
            $attributeValue.IntValue = $Value
        }
        elseif ($Value -is [bool])
        {
            $attributeValue.BoolValue = $Value
        }
        elseif ($Value -is [array])
        {
            if ($Value[0] -is [string])
            {
                $attributeValue.StringArrayValue = $Value
            }
            elseif ($Value[0] -is [System.Int32] -or $Value[0] -is [System.Int64])
            {
                $attributeValue.IntArrayValue = $Value
            }
        }

        return $attributeValue
    }

    hidden [System.Collections.Hashtable] GetCustomSecurityAttributesAsCmdletHashtable([System.Object] $CustomSecurityAttributes)
    {
        return $this.GetCustomSecurityAttributesAsCmdletHashtable($CustomSecurityAttributes, $false)
    }

    hidden [System.Collections.Hashtable] GetCustomSecurityAttributesAsCmdletHashtable([System.Object] $CustomSecurityAttributes, [System.Boolean] $GetForDelete)
    {
        $attributeValue = $null

        # logic to update the custom security attributes to be cmdlet comsumable
        $updatedCustomSecurityAttributes = @{}
        foreach ($attributeSet in $CustomSecurityAttributes)
        {
            $attributeSetKey = $attributeSet.AttributeSetName

            $valuesHashtable = @{}
            $valuesHashtable.Add('@odata.type', '#Microsoft.DirectoryServices.CustomSecurityAttributeValue')
            foreach ($attribute in $attributeSet.AttributeValues)
            {
                $attributeKey = $attribute.AttributeName
                # supply attributeName = $null in the body, if you want to delete this attribute
                if ($GetForDelete -eq $true)
                {
                    $valuesHashtable.Add($attributeKey, $null)
                    continue
                }

                $odataKey = $attributeKey + '@odata.type'

                if ($null -ne $attribute.StringArrayValue)
                {
                    $valuesHashtable.Add($odataKey, '#Collection(String)')
                    $attributeValue = $attribute.StringArrayValue
                }
                elseif ($null -ne $attribute.IntArrayValue)
                {
                    $valuesHashtable.Add($odataKey, '#Collection(Int32)')
                    $attributeValue = $attribute.IntArrayValue
                }
                elseif ($null -ne $attribute.StringValue)
                {
                    $valuesHashtable.Add($odataKey, '#String')
                    $attributeValue = $attribute.StringValue
                }
                elseif ($null -ne $attribute.IntValue)
                {
                    $valuesHashtable.Add($odataKey, '#Int32')
                    $attributeValue = $attribute.IntValue
                }
                elseif ($null -ne $attribute.BoolValue)
                {
                    $attributeValue = $attribute.BoolValue
                }

                $valuesHashtable.Add($attributeKey, $attributeValue)
            }
            $updatedCustomSecurityAttributes.Add($attributeSetKey, $valuesHashtable)
        }
        return $updatedCustomSecurityAttributes
    }

    hidden [System.Object[]] GetCustomSecurityAttributes([System.Object] $ServicePrincipal)
    {
        $existingAttributes = $ServicePrincipal.customSecurityAttributes
        $newCustomSecurityAttributes = @()

        foreach ($key in $existingAttributes.Keys)
        {
            $attributeSet = @{
                AttributeSetName = $key
                AttributeValues  = @()
            }

            foreach ($attribute in $existingAttributes[$key].Keys)
            {
                # Skip properties that end with '@odata.type'
                if ($attribute -like '*@odata.type')
                {
                    continue
                }

                $value = $existingAttributes[$key][$attribute]
                $attributeName = $attribute # Keep the attribute name as it is

                # Create the attribute value and add it to the set
                $attributeSet.AttributeValues += $this.NewAttributeValue($attributeName, $value)
            }

            #Add the attribute set to the final structure
            $newCustomSecurityAttributes += $attributeSet
        }

        return $newCustomSecurityAttributes
    }

    hidden [AADServicePrincipal] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADServicePrincipal])
        {
            return $Values
        }

        $result = [AADServicePrincipal]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADServicePrincipalRoleAssignment
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Type of principal. Accepted values are User or Group')]
    [ValidateSet('Group', 'User')]
    [System.String] $PrincipalType

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Unique identity representing the principal.')]
    [System.String] $Identity
}

class MSFT_AADServicePrincipalClaimsPolicy
{
    [DscProperty()]
    [System.ComponentModel.Description('If specified, it overrides the content of the audience claim for WS-Federation and SAML2 protocols. A custom signing key must be used for audienceOverride to be applied, otherwise, the audienceOverride value is ignored. The value provided must be in the format of an absolute URI.')]
    [System.String] $audienceOverride

    [DscProperty()]
    [System.ComponentModel.Description('Defines which claims are present in the tokens affected by the policy, in addition to the basic claim and the core claim set.')]
    [MSFT_AADServicePrincipalCustomClaim[]] $Claims

    [DscProperty()]
    [System.ComponentModel.Description('Defines which group filter is applied to the claim.')]
    [MSFT_AADServicePrincipalClaimsPolicyGroupFilter] $GroupFilter

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the application ID is added to the claim. It is relevant only for SAML2.0 and if a custom signing key is used. the default value is true. Optional.')]
    [System.Nullable[System.Boolean]] $includeApplicationIdInIssuer

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether the basic claim set is included in tokens affected by this policy. If set to true, all claims in the basic claim set are emitted in tokens affected by the policy. By default the basic claim set isn''t in the tokens unless they''re explicitly configured in this policy.')]
    [System.Nullable[System.Boolean]] $includeBasicClaimSet
}

class MSFT_AADServicePrincipalDelegatedPermissionClassification
{
    [DscProperty()]
    [System.ComponentModel.Description('Classification of the delegated permission')]
    [ValidateSet('low', 'medium', 'high')]
    [System.String] $Classification

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the permission')]
    [System.String] $PermissionName
}

class MSFT_AADServicePrincipalAttributeSet
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Attribute Set Name.')]
    [System.String] $AttributeSetName

    [DscProperty()]
    [System.ComponentModel.Description('List of attribute values.')]
    [MSFT_AADServicePrincipalAttributeValue[]] $AttributeValues
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

class MSFT_MicrosoftGraphsamlSingleSignOnSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('The relative URI the service provider would redirect to after completion of the single sign-on flow.')]
    [System.String] $RelayState
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

class MSFT_AADServicePrincipalCustomClaim
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.customClaim', '#microsoft.graph.samlNameIdClaim')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('One or more configurations that describe how the claim is sourced and under what conditions.')]
    [MSFT_AADServicePrincipalCustomClaimConfiguration[]] $configurations

    [DscProperty()]
    [System.ComponentModel.Description('The name of the claim to be emitted.')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('An optional namespace to be included as part of the claim name.')]
    [System.String] $namespace

    [DscProperty()]
    [System.ComponentModel.Description('If specified, it sets the nameFormat attribute associated with the claim in the SAML response. The possible values are: unspecified, uri, basic.')]
    [ValidateSet('unspecified', 'uri', 'basic')]
    [System.String] $samlAttributeNameFormat

    [DscProperty()]
    [System.ComponentModel.Description('List of token formats for which this claim should be emitted. The possible values are: saml,jwt.')]
    [ValidateSet('saml', 'jwt')]
    [System.String[]] $tokenFormat

    [DscProperty()]
    [System.ComponentModel.Description('Allows to specify the format of the saml nameID claim value. The possible values are: default, unspecified, emailAddress, windowsDomainQualifiedName, persistent, unknownFutureValue. Only applicable to samlNameIdClaim.')]
    [ValidateSet('default', 'unspecified', 'emailAddress', 'windowsDomainQualifiedName', 'persistent')]
    [System.String] $nameIdFormat

    [DscProperty()]
    [System.ComponentModel.Description('Allows the specification of a service provider name qualifier reflected in the sAML response. The value provided must match one of the service provider names configured for the application and is only applicable for IdP-initiated applications (the sign-on URL should be empty for the IdP-initiated applications), in all other cases this value is ignored. Only applicable to samlNameIdClaim.')]
    [System.String] $serviceProviderNameQualifier
}

class MSFT_AADServicePrincipalClaimsPolicyGroupFilter
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.groupClaimFilter')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('Selects the type of filter to apply to the attribute selected by the matchOn property. The possible values are: prefix, suffix, contains.')]
    [ValidateSet('prefix', 'suffix', 'contains')]
    [System.String] $type

    [DscProperty()]
    [System.ComponentModel.Description('Identifies the group attribute on which the filter would be applied. The possible values are: displayName, samAccountName.')]
    [ValidateSet('displayName', 'samAccountName')]
    [System.String] $matchOn

    [DscProperty()]
    [System.ComponentModel.Description('The value of the filter to be applied.')]
    [System.String] $value
}

class MSFT_AADServicePrincipalAttributeValue
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the Attribute')]
    [System.String] $AttributeName

    [DscProperty()]
    [System.ComponentModel.Description('If the attribute has a string array value')]
    [System.String[]] $StringArrayValue

    [DscProperty()]
    [System.ComponentModel.Description('If the attribute has a int array value')]
    [System.UInt32[]] $IntArrayValue

    [DscProperty()]
    [System.ComponentModel.Description('If the attribute has a string value')]
    [System.String] $StringValue

    [DscProperty()]
    [System.ComponentModel.Description('If the attribute has a int value')]
    [System.Nullable[System.UInt32]] $IntValue

    [DscProperty()]
    [System.ComponentModel.Description('If the attribute has a boolean value')]
    [System.Nullable[System.Boolean]] $BoolValue
}

class MSFT_AADServicePrincipalCustomClaimConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('The attribute on which we source this property.')]
    [MSFT_AADServicePrincipalCustomClaimAttribute] $attribute

    [DscProperty()]
    [System.ComponentModel.Description('The condition, if any, associated with this configuration.')]
    [MSFT_AADServicePrincipalCustomClaimCondition] $condition

    [DscProperty()]
    [System.ComponentModel.Description('An ordered list of transformations that are applied in sequence.')]
    [MSFT_AADServicePrincipalCustomClaimTransformation[]] $transformations
}

class MSFT_AADServicePrincipalCustomClaimAttribute
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.sourcedAttribute', '#microsoft.graph.valueBasedAttribute')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('The identifier of the attribute on the specified source. Only applicable for sourcedAttribute.')]
    [System.String] $id

    [DscProperty()]
    [System.ComponentModel.Description('A flag that indicates if the name specified is that of an extension attribute. Only applicable for sourcedAttribute.')]
    [System.Nullable[System.Boolean]] $isExtensionAttribute

    [DscProperty()]
    [System.ComponentModel.Description('The source where the claim is going to retrieve its value. Valid sources include user, application, resource, audience and company. Only applicable for sourcedAttribute.')]
    [System.String] $source

    [DscProperty()]
    [System.ComponentModel.Description('The static value to be used an the attribute. Only applicable for valueBasedAttribute.')]
    [System.String] $value
}

class MSFT_AADServicePrincipalCustomClaimCondition
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.customClaimCondition')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('A list of groups (GUIDs) to which the user/application must be a member for this condition to be applied.')]
    [System.String[]] $memberOf

    [DscProperty()]
    [System.ComponentModel.Description('The type of user this condition applies to. The possible values are: any, members, allGuests, aadGuests, externalGuests.')]
    [ValidateSet('any', 'members', 'allGuests', 'aadGuests', 'externalGuests')]
    [System.String] $userType
}

class MSFT_AADServicePrincipalCustomClaimTransformation
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.regexReplaceTransformation')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('The regular expression to be applied on the input directory attribute or constant.')]
    [System.String] $regex

    [DscProperty()]
    [System.ComponentModel.Description('The transformation output replacement pattern with regular expression output group and input parameter group reference.')]
    [System.String] $replacement

    [DscProperty()]
    [System.ComponentModel.Description('Additional attributes that can be referenced within the replacement string.')]
    [System.String[]] $additionalAttributes

    [DscProperty()]
    [System.ComponentModel.Description('The input attribute that provides the source for the transformation. This parameter is required if it''s the first or only transformation in the list of transformations to be applied. Subsequent transformations use the output of the prior transformation as input.')]
    [MSFT_AADServicePrincipalTransformationAttribute] $input
}

class MSFT_AADServicePrincipalTransformationAttribute
{
    [DscProperty()]
    [System.ComponentModel.Description('This flag is only relevant in the case where the attribute is multivalued. By default, transformations are only applied to the first element in a multi-valued claim, however setting this flag to true ensures the transformation is applied to all values, resulting in a multivalued output.')]
    [System.Nullable[System.Boolean]] $treatAsMultiValue

    [DscProperty()]
    [System.ComponentModel.Description('Attribute to be used as input for the transformation.')]
    [MSFT_AADServicePrincipalCustomClaimAttribute] $attribute
}
