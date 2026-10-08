using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAuthenticationRequirement : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The state of the MFA enablement for the user. Possible values are: enabled, disabled.')]
    [ValidateSet('enabled', 'disabled')]
    [System.String] $PerUserMfaState

    [DscProperty(Key)]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $UserPrincipalName

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
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

    [AADAuthenticationRequirement] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADAuthenticationRequirement]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Azure AD Authentication Requirement for {$($this.UserPrincipalName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.UserPrincipalName -ne $this.UserPrincipalName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $getValue = Get-MgBetaUserAuthenticationRequirement -UserId $this.UserPrincipalName

                if ($null -eq $getValue)
                {
                    throw "Could not find an Azure AD Authentication Requirement for user with UPN {$($this.UserPrincipalName)}"
                }
            }
            else
            {
                $getValue = $null
                $requirementCache = $this.ResourceCache['AuthenticationRequirements']
                if ($null -ne $requirementCache -and $requirementCache.ContainsKey($this.UserPrincipalName))
                {
                    $getValue = $requirementCache[$this.UserPrincipalName]
                }

                if ($null -eq $getValue)
                {
                    $getValue = Get-MgBetaUserAuthenticationRequirement -UserId $this.UserPrincipalName
                }
            }

            Write-Verbose -Message "An Azure AD Authentication Method Policy Requirement for a user with UPN {$($this.UserPrincipalName)} was found."

            $results = @{
                PerUserMfaState       = $getValue.perUserMfaState
                UserPrincipalName     = $this.UserPrincipalName
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
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

        Write-Verbose -Message "Setting the Azure AD Authentication Requirement for {$($this.UserPrincipalName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $params = @{}
        if ($this.PerUserMfaState -eq 'enabled' -and $currentInstance.PerUserMfaState -eq 'disabled')
        {
            $params = @{
                'perUserMfaState' = 'enabled'
            }
        }
        elseif ($this.PerUserMfaState -eq 'disabled' -and $currentInstance.PerUserMfaState -eq 'enabled')
        {
            $params = @{
                'perUserMfaState' = 'disabled'
            }
        }

        Update-MgBetaUserAuthenticationRequirement -UserId $this.UserPrincipalName -BodyParameter $params
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

        try
        {
            [array]$getValue = Get-MgUser -Filter "userType eq 'member'" -All -Property 'id', 'userPrincipalName', 'displayName' -ErrorAction Stop | Where-Object -FilterScript {
                $null -ne $_.Id -and $_.UserPrincipalName -notlike '*#EXT#*'
            }

            $requirementCache = @{}
            $requirementRequests = @()
            foreach ($config in $getValue)
            {
                $requirementRequests += @{
                    id     = $config.UserPrincipalName
                    method = 'GET'
                    url    = "/users/$($config.Id)/authentication/requirements"
                }
            }
            if ($requirementRequests.Count -gt 0)
            {
                $requirementResponses = Invoke-M365DSCGraphBatchRequest -Requests $requirementRequests -ErrorAction SilentlyContinue
                foreach ($requirementResponse in $requirementResponses)
                {
                    if ($requirementResponse.status -eq 200 -and $null -ne $requirementResponse.body)
                    {
                        $requirementCache[[System.String]$requirementResponse.id] = $requirementResponse.body
                    }
                }
            }
            $this.ResourceCache['AuthenticationRequirements'] = $requirementCache

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.DisplayName))
                {
                    $displayedKey = $config.DisplayName
                }

                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    UserPrincipalName     = $config.UserPrincipalName
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($params)
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

    hidden [AADAuthenticationRequirement] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADAuthenticationRequirement])
        {
            return $Values
        }

        $result = [AADAuthenticationRequirement]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
