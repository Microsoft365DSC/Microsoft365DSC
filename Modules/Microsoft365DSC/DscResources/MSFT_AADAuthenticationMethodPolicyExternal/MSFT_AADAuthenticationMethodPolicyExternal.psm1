using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAuthenticationMethodPolicyExternal : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Displayname of the groups of users that are excluded from a policy.')]
    [MSFT_AADAuthenticationMethodPolicyExternalExcludeTarget[]] $ExcludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('Displayname of the groups of users that are included from a policy.')]
    [MSFT_AADAuthenticationMethodPolicyExternalIncludeTarget[]] $IncludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('Open ID Connection settings used by this external authentication method.')]
    [MSFT_AADAuthenticationMethodPolicyExternalOpenIdConnectSetting] $OpenIdConnectSetting

    [DscProperty()]
    [System.ComponentModel.Description('The state of the policy. Possible values are: enabled, disabled.')]
    [ValidateSet('enabled', 'disabled')]
    [System.String] $State

    [DscProperty()]
    [System.ComponentModel.Description('The appId for the app registration in Microsoft Entra ID representing the integration with the external provider.')]
    [System.String] $AppId

    [DscProperty(Key)]
    [System.ComponentModel.Description('The displayName of the authentication policy configuration. Read-only.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

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

    [AADAuthenticationMethodPolicyExternal] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADAuthenticationMethodPolicyExternal]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Azure AD Authentication Method Policy External with Id {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null

                if (-not [string]::IsNullOrEmpty($this.DisplayName))
                {
                    $getValue = (Get-MgBetaPolicyAuthenticationMethodPolicy).AuthenticationMethodConfigurations |
                        Where-Object -FilterScript { $_.DisplayName -eq $this.DisplayName }
                }

                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Authentication Method Policy External with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            Write-Verbose -Message "An Azure AD Authentication Method Policy External with displayName {$($this.DisplayName)} was found."

            #region resource generator code
            $complexExcludeTargets = @()
            foreach ($currentExcludeTargets in $getValue.excludeTargets)
            {
                $myExcludeTargets = [ordered]@{}
                if ($currentExcludeTargets.id -ne 'all_users')
                {
                    $myExcludeTargetsDisplayName = Get-M365DSCGroupDisplayNameById -GroupId $currentExcludeTargets.id
                    if ($null -eq $myExcludeTargetsDisplayName)
                    {
                        continue
                    }
                    $myExcludeTargets.Add('Id', $myExcludeTargetsDisplayName)
                }
                else
                {
                    $myExcludeTargets.Add('Id', $currentExcludeTargets.id)
                }

                if ($null -ne $currentExcludeTargets.targetType)
                {
                    $myExcludeTargets.Add('TargetType', $currentExcludeTargets.targetType)
                }

                if ($myExcludeTargets.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexExcludeTargets += $myExcludeTargets
                }
            }
            #endregion

            $complexincludeTargets = @()
            foreach ($currentincludeTargets in $getValue.includeTargets)
            {
                $myincludeTargets = [ordered]@{}
                if ($currentIncludeTargets.id -ne 'all_users')
                {
                    $myIncludeTargetsDisplayName = Get-M365DSCGroupDisplayNameById -GroupId $currentIncludeTargets.id
                    if ($null -eq $myIncludeTargetsDisplayName)
                    {
                        continue
                    }
                    $myincludeTargets.Add('Id', $myIncludeTargetsDisplayName)
                }
                else
                {
                    $myIncludeTargets.Add('Id', $currentIncludeTargets.id)
                }

                if ($null -ne $currentincludeTargets.targetType)
                {
                    $myincludeTargets.Add('TargetType', $currentincludeTargets.targetType)
                }

                if ($myincludeTargets.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexincludeTargets += $myincludeTargets
                }
            }

            $complexOpenIdConnectSetting = @{
                clientId     = $getValue.OpenIdConnectSetting.ClientId
                discoveryUrl = $getValue.OpenIdConnectSetting.DiscoveryUrl
            }

            $results = @{
                #region resource generator code
                ExcludeTargets        = $complexExcludeTargets
                IncludeTargets        = $complexincludeTargets
                OpenIdConnectSetting  = $complexOpenIdConnectSetting
                State                 = $getValue.State
                AppId                 = $getValue.appId
                DisplayName           = $getValue.displayName
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
                #endregion
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

        Write-Verbose -Message "Setting the Azure AD Authentication Method Policy External with Id {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $params = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        Update-M365DSCAuthenticationTargets -Targets $params.ExcludeTargets
        Update-M365DSCAuthenticationTargets -Targets $params.IncludeTargets

        $params.Add('@odata.type', '#microsoft.graph.externalAuthenticationMethodConfiguration')

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating the Azure AD Authentication Method Policy External with name {$($this.DisplayName)}"
            $null = New-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -BodyParameter $params
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Authentication Method Policy External with name {$($currentInstance.displayName)}"
            $getValue = (Get-MgBetaPolicyAuthenticationMethodPolicy).AuthenticationMethodConfigurations |
                Where-Object -FilterScript { $_.displayName -eq $currentInstance.displayName }

            $params.Remove('displayName') | Out-Null
            Update-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
                -AuthenticationMethodConfigurationId $getValue.Id `
                -BodyParameter $params
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Authentication Method Policy External with Id {$($currentInstance.displayName)}"
            $getValue = (Get-MgBetaPolicyAuthenticationMethodPolicy).AuthenticationMethodConfigurations |
                Where-Object -FilterScript { $_.displayName -eq $currentInstance.displayName }
            Remove-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId $getValue.Id
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

        try
        {
            #region resource generator code
            $desiredType = '#microsoft.graph.externalAuthenticationMethodConfiguration'
            $getValue = (Get-MgBetaPolicyAuthenticationMethodPolicy).AuthenticationMethodConfigurations |
                Where-Object -FilterScript { $_.'@odata.type' -eq $desiredType }
            #endregion

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

                $displayedKey = $config.displayName

                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    DisplayName           = $config.displayName
                    Ensure                = 'Present'
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
                $Results = $this.GetForExport($Params)
                if ($null -ne $Results.ExcludeTargets)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ExcludeTargets `
                        -CIMInstanceName 'AADAuthenticationMethodPolicyExternalExcludeTarget'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ExcludeTargets = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ExcludeTargets') | Out-Null
                    }
                }

                if ($null -ne $Results.IncludeTargets)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.IncludeTargets `
                        -CIMInstanceName 'AADAuthenticationMethodPolicyExternalIncludeTarget'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.IncludeTargets = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('IncludeTargets') | Out-Null
                    }
                }

                if ($null -ne $Results.OpenIdConnectSetting)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.OpenIdConnectSetting `
                        -CIMInstanceName 'AADAuthenticationMethodPolicyExternalOpenIdConnectSetting'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.OpenIdConnectSetting = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('OpenIdConnectSetting') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('ExcludeTargets', 'IncludeTargets', 'OpenIdConnectSetting')

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

    hidden [AADAuthenticationMethodPolicyExternal] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADAuthenticationMethodPolicyExternal])
        {
            return $Values
        }

        $result = [AADAuthenticationMethodPolicyExternal]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADAuthenticationMethodPolicyExternalExcludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The object identifier of an Azure AD group.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The type of the authentication method target. Possible values are: group and unknownFutureValue.')]
    [ValidateSet('group', 'unknownFutureValue')]
    [System.String] $TargetType
}

class MSFT_AADAuthenticationMethodPolicyExternalIncludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The object identifier of an Azure AD group.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The type of the authentication method target. Possible values are: group and unknownFutureValue.')]
    [ValidateSet('group', 'unknownFutureValue')]
    [System.String] $TargetType
}

class MSFT_AADAuthenticationMethodPolicyExternalOpenIdConnectSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('The Microsoft Entra ID''s client ID as generated by the provider or admin to identify Microsoft Entra ID.')]
    [System.String] $ClientId

    [DscProperty()]
    [System.ComponentModel.Description('The host URL of the external identity provider''s OIDC discovery endpoint.')]
    [System.String] $DiscoveryUrl
}
