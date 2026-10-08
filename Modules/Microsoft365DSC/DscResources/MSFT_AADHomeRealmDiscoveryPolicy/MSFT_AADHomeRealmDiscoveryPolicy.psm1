using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADHomeRealmDiscoveryPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name for this policy. Required.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('A string collection containing a complex object array that defines the rules and settings for a policy. The syntax for the definition differs for each derived policy type. Required.')]
    [MSFT_AADHomeRealDiscoveryPolicyDefinition[]] $Definition

    [DscProperty()]
    [System.ComponentModel.Description('If set to true, activates this policy. There can be many policies for the same policy type, but only one can be activated as the organization default. Optional, default value is false.')]
    [System.Nullable[System.Boolean]] $IsOrganizationDefault

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

    [AADHomeRealmDiscoveryPolicy] Get()
    {
        $Id = $null
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADHomeRealmDiscoveryPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Azure AD Home Realm Discovery Policy with Id {$Id} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                #region resource generator code
                $getValue = Get-MgBetaPolicyHomeRealmDiscoveryPolicy `
                    -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'"
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            #endregion
            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Azure AD Home Realm Discovery Policy with DisplayName {$($this.DisplayName)}."
                return $this.AsResult($nullResult)
            }
            # if multiple objects with same name exist
            if ($getValue -is [array])
            {
                Write-Verbose -Message "Multiple Azure AD Home Realm Discovery Policy with DisplayName {$($this.DisplayName)} found. Skipping Operation."
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "An Azure AD Home Realm Discovery Policy with DisplayName {$($this.DisplayName)} was found"

            $DefinitionArray = @()
            foreach ($definitionValue in $getValue.definition)
            {
                $value = ConvertFrom-Json $definitionValue
                $DefinitionArray += @{
                    AccelerateToFederatedDomain  = $value.HomeRealmDiscoveryPolicy.AccelerateToFederatedDomain
                    AllowCloudPasswordValidation = $value.HomeRealmDiscoveryPolicy.AllowCloudPasswordValidation
                    PreferredDomain              = $value.HomeRealmDiscoveryPolicy.PreferredDomain
                    AlternateIdLogin             = @{
                        Enabled = $value.HomeRealmDiscoveryPolicy.AlternateIdLogin.Enabled
                    }
                }
            }

            $results = @{
                #region resource generator code
                Definition            = [Array]$DefinitionArray
                IsOrganizationDefault = $getValue.isOrganizationDefault
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # to get the id parameter
        $getValue = Get-MgBetaPolicyHomeRealmDiscoveryPolicy `
            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'"

        $newDefinitions = @()
        foreach ($Def in $this.Definition)
        {
            $HomeRealmDiscoveryPolicy = @{}
            if ($null -ne $Def.AccelerateToFederatedDomain)
            {
                $HomeRealmDiscoveryPolicy.Add('AccelerateToFederatedDomain', $Def.AccelerateToFederatedDomain)
            }
            if ($null -ne $Def.AllowCloudPasswordValidation)
            {
                $HomeRealmDiscoveryPolicy.Add('AllowCloudPasswordValidation', $Def.AllowCloudPasswordValidation)
            }
            if ($null -ne $Def.PreferredDomain)
            {
                $HomeRealmDiscoveryPolicy.Add('PreferredDomain', $Def.PreferredDomain)
            }
            if ($null -ne $Def.AlternateIdLogin.Enabled)
            {
                $HomeRealmDiscoveryPolicy.Add('AlternateIdLogin', @{Enabled = $Def.AlternateIdLogin.Enabled })
            }
            $temp = @{
                HomeRealmDiscoveryPolicy = $HomeRealmDiscoveryPolicy
            }
            $newDefinitions += ConvertTo-Json $temp -Depth 10 -Compress
        }

        $boundParameters.Definition = $newDefinitions

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Azure AD Home Realm Discovery Policy with DisplayName {$($this.DisplayName)}"

            $createParameters = $boundParameters
            #region resource generator code
            $policy = New-MgBetaPolicyHomeRealmDiscoveryPolicy -BodyParameter $createParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Home Realm Discovery Policy with DisplayName {$($currentInstance.DisplayName)}"

            $updateParameters = $boundParameters
            #region resource generator code
            Update-MgBetaPolicyHomeRealmDiscoveryPolicy `
                -HomeRealmDiscoveryPolicyId $getValue.Id `
                -BodyParameter $updateParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Home Realm Discovery Policy with DisplayName {$($currentInstance.DisplayName)}"
            #region resource generator code
            Remove-MgBetaPolicyHomeRealmDiscoveryPolicy -HomeRealmDiscoveryPolicyId $getValue.Id
            #endregion
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
            [array]$getValue = Get-MgBetaPolicyHomeRealmDiscoveryPolicy `
                -Filter $this.Filter `
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

                $displayedKey = $config.DisplayName
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                elseif (-not [string]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    DisplayName           = $config.DisplayName
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
                if ($null -ne $Results.Definition)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'Definition'
                            CimInstanceName = 'AADHomeRealDiscoveryPolicyDefinition'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'AlternateIdLogin'
                            CimInstanceName = 'AADHomeRealDiscoveryPolicyDefinitionAlternateIdLogin'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Definition `
                        -CIMInstanceName 'AADHomeRealDiscoveryPolicyDefinition' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Definition = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Definition') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Definition')

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

    hidden [AADHomeRealmDiscoveryPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADHomeRealmDiscoveryPolicy])
        {
            return $Values
        }

        $result = [AADHomeRealmDiscoveryPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADHomeRealDiscoveryPolicyDefinition
{
    [DscProperty()]
    [System.ComponentModel.Description('Accelerate to Federated Domain.')]
    [System.Nullable[System.Boolean]] $AccelerateToFederatedDomain

    [DscProperty()]
    [System.ComponentModel.Description('Allow cloud password validation.')]
    [System.Nullable[System.Boolean]] $AllowCloudPasswordValidation

    [DscProperty()]
    [System.ComponentModel.Description('AlternateIdLogin complex object.')]
    [MSFT_AADHomeRealDiscoveryPolicyDefinitionAlternateIdLogin] $AlternateIdLogin

    [DscProperty()]
    [System.ComponentModel.Description('Preffered Domain value.')]
    [System.String] $PreferredDomain
}

class MSFT_AADHomeRealDiscoveryPolicyDefinitionAlternateIdLogin
{
    [DscProperty()]
    [System.ComponentModel.Description('Boolean for whether AlternateIdLogin is enabled.')]
    [System.Nullable[System.Boolean]] $Enabled
}
