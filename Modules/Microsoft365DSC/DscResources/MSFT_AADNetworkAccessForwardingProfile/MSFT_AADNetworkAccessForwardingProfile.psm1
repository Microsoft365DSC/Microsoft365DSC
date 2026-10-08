using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADNetworkAccessForwardingProfile : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Profile Name. Required.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Id of the profile. Unique Identifier')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('status of the profile')]
    [System.String] $State

    [DscProperty()]
    [System.ComponentModel.Description('Traffic forwarding policies associated with this profile.')]
    [MSFT_MicrosoftGraphNetworkaccessPolicyLink[]] $Policies

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

    [AADNetworkAccessForwardingProfile] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADNetworkAccessForwardingProfile]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the AAD Network Access Forwarding Policy with Id {$($this.Id)} and Name {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()

                $getValue = $null
                #region resource generator code
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaNetworkAccessForwardingProfile -ForwardingProfileId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Network Access Forwarding Profile with  Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.Name))
                    {
                        $getValue = Get-MgBetaNetworkAccessForwardingProfile -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $this.Name }
                    }
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id

            #endregion
            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Azure AD Network Access Forwarding Profile with  name {$($this.Name)}."
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "An Azure AD Network Access Forwarding Profile with  {$($resolvedId)} and  {$($this.Name)} was found"

            $forwardingProfilePolicies = Get-MgBetaNetworkAccessForwardingProfilePolicy -ForwardingProfileId $getValue.Id -ErrorAction SilentlyContinue

            if ($null -ne $forwardingProfilePolicies)
            {
                Write-Verbose -Message "An Azure AD Network Access Forwarding Profile Policy with  $($forwardingProfilePolicies.Id) and  $($forwardingProfilePolicies.Name) was found"
            }

            $complexPolicies = @()
            foreach ($currentPolicy in $forwardingProfilePolicies)
            {
                $myPolicies = [ordered]@{}
                $myPolicies.Add('Name', $currentPolicy.Policy.Name)
                $myPolicies.Add('State', $currentPolicy.State)
                $myPolicies.Add('PolicyLinkId', $currentPolicy.Id)
                if ($myPolicies.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexPolicies += $myPolicies
                }
            }

            $results = @{
                Name                  = $getValue.Name
                Id                    = $getValue.Id
                State                 = $getValue.State
                Policies              = $complexPolicies
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
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

        # Ensure the proper dependencies are installed in the current environment.
        Confirm-M365DSCDependencies

        #region Telemetry
        $this.AddTelemetry('Set')
        #endregion

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($null -ne $currentInstance)
        {
            Write-Verbose -Message "Updating the Azure AD Network Access Forwarding Profile with  {$($currentInstance.Id)}"

            $updateParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters
            $updateParameters.Remove('Id') | Out-Null

            Write-Verbose -Message "Updating the Azure AD Network Access Forwarding Profile with  {$($currentInstance.Id)} {$($currentInstance.Name)} State"
            Update-MgBetaNetworkAccessForwardingProfile `
                -ForwardingProfileId $currentInstance.Id `
                -State $updateParameters.State

            $currentPolicies = $currentInstance.Policies
            $updatedPolicies = $updateParameters.Policies

            # update the current policy's state with the updated policy's state.
            foreach ($currentPolicy in $currentPolicies)
            {
                $updatedPolicy = $updatedPolicies | Where-Object { $_.Name -eq $currentPolicy.Name }
                if ($null -ne $updatedPolicy)
                {
                    Write-Verbose -Message "Updating the Azure AD Network Access Forwarding Profile Policy with  Id {$($currentPolicy.PolicyLinkId)} {$($currentPolicy.Name)}"
                    Update-MgBetaNetworkAccessForwardingProfilePolicy `
                        -ForwardingProfileId $currentInstance.Id `
                        -PolicyLinkId $currentPolicy.PolicyLinkId `
                        -State $updatedPolicy.State
                }
            }
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
            [array]$getValue = Get-MgBetaNetworkAccessForwardingProfile `
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
                $displayedKey = $config.Id
                if (-not [string]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    Name                  = $config.Name
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
                $rawResults = $Results.Clone()

                if ($null -ne $Results.Policies)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'Policies'
                            CimInstanceName = 'MicrosoftGraphNetworkaccessPolicyLink'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Policies `
                        -CIMInstanceName 'MicrosoftGraphNetworkaccessPolicyLink' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Policies = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Policies') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Policies') `
                    -RawResults $rawResults

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

    hidden [AADNetworkAccessForwardingProfile] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADNetworkAccessForwardingProfile])
        {
            return $Values
        }

        $result = [AADNetworkAccessForwardingProfile]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphNetworkaccessPolicyLink
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Policy Name. Required')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Policy Link Id')]
    [System.String] $PolicyLinkId

    [DscProperty()]
    [System.ComponentModel.Description('status')]
    [System.String] $state
}
