using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class ADOSecurityPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name of the Azure DevOPS Organization.')]
    [System.String] $OrganizationName

    [DscProperty()]
    [System.ComponentModel.Description('Controls the external guest access.')]
    [System.Nullable[System.Boolean]] $DisallowAadGuestUserAccess

    [DscProperty()]
    [System.ComponentModel.Description('Controls the Third-party application access via OAuth.')]
    [System.Nullable[System.Boolean]] $DisallowOAuthAuthentication

    [DscProperty()]
    [System.ComponentModel.Description('Controls SSH Authentication.')]
    [System.Nullable[System.Boolean]] $DisallowSecureShell

    [DscProperty()]
    [System.ComponentModel.Description('Controls Log Audit Events.')]
    [System.Nullable[System.Boolean]] $LogAuditEvents

    [DscProperty()]
    [System.ComponentModel.Description('Controls the Allow public projects setting.')]
    [System.Nullable[System.Boolean]] $AllowAnonymousAccess

    [DscProperty()]
    [System.ComponentModel.Description('Controls the Additional protections when using public package registries setting.')]
    [System.Nullable[System.Boolean]] $ArtifactsExternalPackageProtectionToken

    [DscProperty()]
    [System.ComponentModel.Description('Controls the Enable IP Conditional Access policy validation setting.')]
    [System.Nullable[System.Boolean]] $EnforceAADConditionalAccess

    [DscProperty()]
    [System.ComponentModel.Description('Controls the Allow team and project administrators to invite new user setting.')]
    [System.Nullable[System.Boolean]] $AllowTeamAdminsInvitationsAccessToken

    [DscProperty()]
    [System.ComponentModel.Description('Controls the Request access setting.')]
    [System.Nullable[System.Boolean]] $AllowRequestAccessToken

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the workload''s Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

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
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [ADOSecurityPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [ADOSecurityPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of ADO Security Policy for organization $($this.OrganizationName)"

        try
        {
            $null = $this.Connect('AzureDevOPS')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.DisallowAadGuestUserAccess?defaultValue"
            $DisallowAadGuestUserAccessValue = (Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri).Value

            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.DisallowOAuthAuthentication?defaultValue"
            $DisallowOAuthAuthenticationValue = (Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri).Value
            if ([System.String]::IsNullOrEmpty($DisallowOAuthAuthenticationValue))
            {
                $DisallowOAuthAuthenticationValue = $true
            }

            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.DisallowSecureShell?defaultValue"
            $DisallowSecureShellValue = (Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri).Value
            if ([System.String]::IsNullOrEmpty($DisallowSecureShellValue))
            {
                $DisallowSecureShellValue = $false
            }

            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.LogAuditEvents?defaultValue"
            $LogAuditEventsValue = (Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri).Value
            if ([System.String]::IsNullOrEmpty($LogAuditEventsValue))
            {
                $LogAuditEventsValue = $false
            }

            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.AllowAnonymousAccess?defaultValue"
            $AllowAnonymousAccessValue = (Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri).Value
            if ([System.String]::IsNullOrEmpty($AllowAnonymousAccessValue))
            {
                $AllowAnonymousAccessValue = $false
            }

            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.ArtifactsExternalPackageProtectionToken?defaultValue"
            $ArtifactsExternalPackageProtectionTokenValue = (Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri).Value
            if ([System.String]::IsNullOrEmpty($ArtifactsExternalPackageProtectionTokenValue))
            {
                $ArtifactsExternalPackageProtectionTokenValue = $true
            }

            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.EnforceAADConditionalAccess?defaultValue"
            $EnforceAADConditionalAccessValue = (Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri).Value
            if ([System.String]::IsNullOrEmpty($EnforceAADConditionalAccessValue))
            {
                $EnforceAADConditionalAccessValue = $false
            }

            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.AllowTeamAdminsInvitationsAccessToken?defaultValue"
            $AllowTeamAdminsInvitationsAccessTokenValue = (Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri).Value
            if ([System.String]::IsNullOrEmpty($AllowTeamAdminsInvitationsAccessTokenValue))
            {
                $AllowTeamAdminsInvitationsAccessTokenValue = $true
            }

            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.AllowRequestAccessToken?defaultValue"
            $AllowRequestAccessTokenValue = (Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri).Value
            if ([System.String]::IsNullOrEmpty($AllowRequestAccessTokenValue))
            {
                $AllowRequestAccessTokenValue = $true
            }

            $results = @{
                OrganizationName                        = $this.OrganizationName
                DisallowAadGuestUserAccess              = [Boolean]::Parse($DisallowAadGuestUserAccessValue)
                DisallowOAuthAuthentication             = [Boolean]::Parse($DisallowOAuthAuthenticationValue)
                DisallowSecureShell                     = [Boolean]::Parse($DisallowSecureShellValue)
                LogAuditEvents                          = [Boolean]::Parse($LogAuditEventsValue)
                AllowAnonymousAccess                    = [Boolean]::Parse($AllowAnonymousAccessValue)
                ArtifactsExternalPackageProtectionToken = [Boolean]::Parse($ArtifactsExternalPackageProtectionTokenValue)
                EnforceAADConditionalAccess             = [Boolean]::Parse($EnforceAADConditionalAccessValue)
                AllowTeamAdminsInvitationsAccessToken   = [Boolean]::Parse($AllowTeamAdminsInvitationsAccessTokenValue)
                AllowRequestAccessToken                 = [Boolean]::Parse($AllowRequestAccessTokenValue)
                Credential                              = $this.Credential
                ApplicationId                           = $this.ApplicationId
                TenantId                                = $this.TenantId
                CertificateThumbprint                   = $this.CertificateThumbprint
                CertificatePath                         = $this.CertificatePath
                CertificatePassword                     = $this.CertificatePassword
                ManagedIdentity                         = $this.ManagedIdentity
                AccessTokens                            = $this.AccessTokens
            }
            return $this.AsResult($results)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of ADO Security Policy for organization $($this.OrganizationName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('AzureDevOPS')

        if ($this.GetBoundParameters().ContainsKey('DisallowAadGuestUserAccess'))
        {
            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.DisallowAadGuestUserAccess?api-version=5.0-preview"
            $body = "[{`"from`":`"`",`"op`":2,`"path`":`"/Value`",`"value`":`"$($this.DisallowAadGuestUserAccess.ToString().ToLower())`"}]"
            Write-Verbose -Message "Updating DisallowAadGuestUserAccess policy with values: $($body)"

            Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri -Method 'PATCH' -Body $body
        }

        if ($this.GetBoundParameters().ContainsKey('DisallowOAuthAuthentication'))
        {
            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.DisallowOAuthAuthentication?api-version=5.0-preview"
            $body = "[{`"from`":`"`",`"op`":2,`"path`":`"/Value`",`"value`":`"$($this.DisallowOAuthAuthentication.ToString().ToLower())`"}]"
            Write-Verbose -Message "Updating DisallowOAuthAuthentication policy with values: $($body)"

            Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri -Method 'PATCH' -Body $body
        }

        if ($this.GetBoundParameters().ContainsKey('DisallowSecureShell'))
        {
            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.DisallowSecureShell?api-version=5.0-preview"
            $body = "[{`"from`":`"`",`"op`":2,`"path`":`"/Value`",`"value`":`"$($this.DisallowSecureShell.ToString().ToLower())`"}]"
            Write-Verbose -Message "Updating DisallowSecureShell policy with values: $($body)"

            Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri -Method 'PATCH' -Body $body
        }

        if ($this.GetBoundParameters().ContainsKey('LogAuditEvents'))
        {
            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.LogAuditEvents?api-version=5.0-preview"
            $body = "[{`"from`":`"`",`"op`":2,`"path`":`"/Value`",`"value`":`"$($this.LogAuditEvents.ToString().ToLower())`"}]"
            Write-Verbose -Message "Updating LogAuditEvents policy with values: $($body)"

            Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri -Method 'PATCH' -Body $body
        }

        if ($this.GetBoundParameters().ContainsKey('AllowAnonymousAccess'))
        {
            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.AllowAnonymousAccess?api-version=5.0-preview"
            $body = "[{`"from`":`"`",`"op`":2,`"path`":`"/Value`",`"value`":`"$($this.AllowAnonymousAccess.ToString().ToLower())`"}]"
            Write-Verbose -Message "Updating AllowAnonymousAccess policy with values: $($body)"

            Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri -Method 'PATCH' -Body $body
        }

        if ($this.GetBoundParameters().ContainsKey('ArtifactsExternalPackageProtectionToken'))
        {
            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.ArtifactsExternalPackageProtectionToken?api-version=5.0-preview"
            $body = "[{`"from`":`"`",`"op`":2,`"path`":`"/Value`",`"value`":`"$($this.ArtifactsExternalPackageProtectionToken.ToString().ToLower())`"}]"
            Write-Verbose -Message "Updating ArtifactsExternalPackageProtectionToken policy with values: $($body)"

            Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri -Method 'PATCH' -Body $body
        }

        if ($this.GetBoundParameters().ContainsKey('EnforceAADConditionalAccess'))
        {
            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.EnforceAADConditionalAccess?api-version=5.0-preview"
            $body = "[{`"from`":`"`",`"op`":2,`"path`":`"/Value`",`"value`":`"$($this.EnforceAADConditionalAccess.ToString().ToLower())`"}]"
            Write-Verbose -Message "Updating EnforceAADConditionalAccess policy with values: $($body)"

            Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri -Method 'PATCH' -Body $body
        }

        if ($this.GetBoundParameters().ContainsKey('AllowTeamAdminsInvitationsAccessToken'))
        {
            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.AllowTeamAdminsInvitationsAccessToken?api-version=5.0-preview"
            $body = "[{`"from`":`"`",`"op`":2,`"path`":`"/Value`",`"value`":`"$($this.AllowTeamAdminsInvitationsAccessToken.ToString().ToLower())`"}]"
            Write-Verbose -Message "Updating AllowTeamAdminsInvitationsAccessToken policy with values: $($body)"

            Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri -Method 'PATCH' -Body $body
        }

        if ($this.GetBoundParameters().ContainsKey('AllowRequestAccessToken'))
        {
            $uri = "https://dev.azure.com/$($this.OrganizationName)/_apis/OrganizationPolicy/Policies/Policy.AllowRequestAccessToken?api-version=5.0-preview"
            $body = "[{`"from`":`"`",`"op`":2,`"path`":`"/Value`",`"value`":`"$($this.AllowRequestAccessToken.ToString().ToLower())`"}]"
            Write-Verbose -Message "Updating AllowRequestAccessToken policy with values: $($body)"

            Invoke-M365DSCAzureDevOPSWebRequest -Uri $uri -Method 'PATCH' -Body $body
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

        $ConnectionMode = $this.Connect('AzureDevOPS')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $devOpsProfile = Invoke-M365DSCAzureDevOPSWebRequest -Uri 'https://app.vssps.visualstudio.com/_apis/profile/profiles/me?api-version=5.1'
            $accounts = Invoke-M365DSCAzureDevOPSWebRequest -Uri "https://app.vssps.visualstudio.com/_apis/accounts?api-version=7.1-preview.1&memberId=$($devOpsProfile.id)"

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($accounts.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($account in $accounts.Value)
            {
                $organization = $account.accountName
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $organization
                Write-M365DSCHost -Message "    |---[$i/$($accounts.Value.Count)] $displayedKey" -DeferWrite
                $params = @{
                    OrganizationName      = $organization
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $Results = $this.GetForExport($Params)

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [ADOSecurityPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [ADOSecurityPolicy])
        {
            return $Values
        }

        $result = [ADOSecurityPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
