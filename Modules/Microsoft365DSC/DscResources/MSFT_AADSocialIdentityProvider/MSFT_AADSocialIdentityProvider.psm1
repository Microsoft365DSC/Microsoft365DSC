using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADSocialIdentityProvider : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The client identifier for the application obtained when registering the application with the identity provider.')]
    [System.String] $ClientId

    [DscProperty()]
    [System.ComponentModel.Description('The client secret for the application that is obtained when the application is registered with the identity provider. This is write-only. A read operation returns ****.')]
    [System.String] $ClientSecret

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the identity provider.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('For a B2B scenario, possible values: Google, Facebook. For a B2C scenario, possible values: Microsoft, Google, Amazon, LinkedIn, Facebook, GitHub, Twitter, Weibo, QQ, WeChat.')]
    [ValidateSet('AADSignup', 'EmailOTP', 'Microsoft', 'MicrosoftAccount', 'Google', 'Amazon', 'LinkedIn', 'Facebook', 'GitHub', 'Twitter', 'Weibo', 'QQ', 'WeChat')]
    [System.String] $IdentityProviderType

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

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [AADSocialIdentityProvider] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADSocialIdentityProvider]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Social Identity Provider with Client Id {$($this.ClientId)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.ClientId)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = Get-MgBetaIdentityProvider -Filter "Id eq '$($this.ClientId)' and isof('microsoft.graph.socialIdentityProvider')" -ErrorAction SilentlyContinue
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find Social Identity Provider Client Id {$($this.ClientId)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            Write-Verbose -Message "Social Identity Provider with ClientId {$($this.ClientId)} was found."

            $ClientSecretValue = $null
            if ($getValue.clientSecret)
            {
                $ClientSecretValue = $getValue.clientSecret
            }
            $results = @{
                ClientId              = $getValue.Id
                ClientSecret          = $ClientSecretValue
                DisplayName           = $getValue.DisplayName
                IdentityProviderType  = $getValue.identityProviderType
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $boundParameters.Add('@odata.type', 'microsoft.graph.socialIdentityProvider')
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Social Identity Provider with Client Id {$($this.ClientId)}"
            $createParameters = $boundParameters
            New-MgBetaIdentityProvider -BodyParameter $createParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $updateParameters = $boundParameters
            $updateParameters.Remove('IdentityProviderType') | Out-Null
            Write-Verbose -Message "Updating the Social Identity Provider with Client Id {$($this.ClientId)}"
            Update-MgBetaIdentityProvider -IdentityProviderBaseId $this.ClientId -BodyParameter $updateParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Social Identity Provider with Client Id {$($this.ClientId)}"
            Remove-MgBetaIdentityProvider -IdentityProviderBaseId $this.ClientId | Out-Null
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
            $baseFilter = "isof('microsoft.graph.socialIdentityProvider')"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($baseFilter) and ($($this.Filter))"
            }
            [array]$getValue = Get-MgBetaIdentityProvider `
                -All `
                -Filter $mergedFilter `
                -NoPageSize `
                -ErrorAction Stop

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

                $displayedKey = $config.DisplayName

                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    ClientId              = $config.Id
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('ClientSecret')
        }
    }

    hidden [AADSocialIdentityProvider] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADSocialIdentityProvider])
        {
            return $Values
        }

        $result = [AADSocialIdentityProvider]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
