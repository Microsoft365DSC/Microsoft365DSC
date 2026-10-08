using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADActivityBasedTimeoutPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name for this policy. Required.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Id of the policy')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Timeout value in hh:mm:ss for c44b4083-3bb0-49c1-b47d-974e53cbdf3c: applies the policy to the Azure portal.')]
    [System.String] $AzurePortalTimeOut

    [DscProperty()]
    [System.ComponentModel.Description('Timeout value in hh:mm:ss for default: applies the policy to all applications that support activity-based timeout functionality but don''t have application-specific override.')]
    [System.String] $DefaultTimeOut

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

    [AADActivityBasedTimeoutPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADActivityBasedTimeoutPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Activity Based Timeout Policy '$($this.DisplayName)'"

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
                #region resource generator code
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaPolicyActivityBasedTimeoutPolicy -ActivityBasedTimeoutPolicyId $this.Id `
                        -ErrorAction SilentlyContinue
                }
                if ($null -eq $getValue)
                {
                    $getValue = Get-MgBetaPolicyActivityBasedTimeoutPolicy -All -ErrorAction SilentlyContinue |
                        Where-Object -FilterScript { $_.DisplayName -eq $this.DisplayName }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Activity Based Timeout Policy with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            Write-Verbose -Message "An Azure AD Activity Based Timeout Policy with Id {$($getValue.Id)} and DisplayName {$($this.DisplayName)} was found."

            #Azure portal timeout
            $timeout = $getValue.Definition | ConvertFrom-Json
            $azurePortalTimeOutValue = ($timeout.ActivityBasedTimeoutPolicy.ApplicationPolicies | Where-Object { $_.ApplicationId -match 'c44b4083-3bb0-49c1-b47d-974e53cbdf3c' }).WebSessionIdleTimeout
            $defaultTimeOutValue = ($timeout.ActivityBasedTimeoutPolicy.ApplicationPolicies | Where-Object { $_.ApplicationId -match 'default' }).WebSessionIdleTimeout

            $results = @{
                #region resource generator code
                DisplayName           = $getValue.displayName
                Id                    = $getValue.Id
                AzurePortalTimeOut    = $azurePortalTimeOutValue
                DefaultTimeOut        = $defaultTimeOutValue
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

        Write-Verbose -Message "Setting configuration for Activity Based Timeout Policy '$($this.DisplayName)'"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $AzurePortalTimeOutexist = $false
        $DefaultTimeOutexistst = $false
        if ($boundParameters.ContainsKey('AzurePortalTimeOut') `
                -and $null -ne $boundParameters.AzurePortalTimeOut `
                -and -not [System.String]::IsNullOrEmpty($boundParameters.AzurePortalTimeOut))
        {
            $AzurePortalTimeOutexist = $true
        }
        if ($boundParameters.ContainsKey('DefaultTimeOut') `
                -and $null -ne $boundParameters.DefaultTimeOut `
                -and -not [System.String]::IsNullOrEmpty($boundParameters.DefaultTimeOut))
        {
            $DefaultTimeOutexistst = $true
        }
        $ApplicationPolicies = @()
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Azure AD Activity Based Timeout Policy with DisplayName {$($this.DisplayName)}"
            if ($AzurePortalTimeOutexist)
            {
                $ApplicationPolicies += @{
                    ApplicationId         = 'c44b4083-3bb0-49c1-b47d-974e53cbdf3c'
                    WebSessionIdleTimeout = "$($this.AzurePortalTimeOut)"
                }
            }
            if ($DefaultTimeOutexistst)
            {
                $ApplicationPolicies += @{
                    ApplicationId         = 'default'
                    WebSessionIdleTimeout = "$($this.DefaultTimeOut)"
                }
            }
            if ($null -eq $ApplicationPolicies)
            {
                throw 'At least one of the parameters AzurePortalTimeOut or DefaultTimeOut must be specified'
            }
            elseif ($AzurePortalTimeOutexist -or $DefaultTimeOutexistst)
            {
                $policy = @{
                    ActivityBasedTimeoutPolicy = @{
                        Version             = 1
                        ApplicationPolicies = @(
                            $ApplicationPolicies
                        )
                    }
                }

                $json = $policy | ConvertTo-Json -Depth 10 -Compress
                $params = @{
                    definition            = @(
                        "$json"
                    )
                    displayName           = $this.DisplayName
                    isOrganizationDefault = $true
                }

                New-MgBetaPolicyActivityBasedTimeoutPolicy -BodyParameter $params
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating an Azure AD Activity Based Timeout Policy with DisplayName {$($this.DisplayName)}"
            if ($AzurePortalTimeOutexist)
            {
                $ApplicationPolicies += @{
                    ApplicationId         = 'c44b4083-3bb0-49c1-b47d-974e53cbdf3c'
                    WebSessionIdleTimeout = "$($this.AzurePortalTimeOut)"
                }
            }
            if ($DefaultTimeOutexistst)
            {
                $ApplicationPolicies += @{
                    ApplicationId         = 'default'
                    WebSessionIdleTimeout = "$($this.DefaultTimeOut)"
                }
            }
            if ($null -eq $ApplicationPolicies)
            {
                throw 'At least one of the parameters AzurePortalTimeOut or DefaultTimeOut must be specified'
            }
            elseif ($AzurePortalTimeOutexist -or $DefaultTimeOutexistst)
            {
                $policy = @{
                    ActivityBasedTimeoutPolicy = @{
                        Version             = 1
                        ApplicationPolicies = @(
                            $ApplicationPolicies
                        )
                    }
                }

                $json = $policy | ConvertTo-Json -Depth 10 -Compress
                $params = @{
                    definition            = @(
                        "$json"
                    )
                    displayName           = $this.DisplayName
                    isOrganizationDefault = $true
                }

                Update-MgBetaPolicyActivityBasedTimeoutPolicy -ActivityBasedTimeoutPolicyId $currentInstance.Id -BodyParameter $params
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Activity Based Timeout Policy with Id {$($currentInstance.Id)}"
            Remove-MgBetaPolicyActivityBasedTimeoutPolicy -ActivityBasedTimeoutPolicyId $currentInstance.Id
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
            [array]$getValue = Get-MgBetaPolicyActivityBasedTimeoutPolicy -Filter $this.Filter `
                -All `
                -ErrorAction Stop
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

                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
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

    hidden [AADActivityBasedTimeoutPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADActivityBasedTimeoutPolicy])
        {
            return $Values
        }

        $result = [AADActivityBasedTimeoutPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
