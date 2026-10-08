using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADFeatureRolloutPolicy : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates the DisplayName of the groups the policy is assigned to.')]
    [System.String[]] $AppliesTo

    [DscProperty()]
    [System.ComponentModel.Description('A description for this feature rollout policy.')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name for this  feature rollout policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Possible values are: passthroughAuthentication, seamlessSso, passwordHashSync, emailAsAlternateId, unknownFutureValue, certificateBasedAuthentication. You must use the Prefer: include-unknown-enum-members request header to get the following value or values in this evolvable enum: certificateBasedAuthentication. For more information about the prerequisites for the enabled features, see Prerequisites for enabled features.')]
    [ValidateSet('passthroughAuthentication', 'seamlessSso', 'passwordHashSync', 'emailAsAlternateId', 'unknownFutureValue', 'certificateBasedAuthentication')]
    [System.String] $Feature

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether this feature rollout policy should be applied to the entire organization.')]
    [System.Nullable[System.Boolean]] $IsAppliedToOrganization

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the feature rollout is enabled.')]
    [System.Nullable[System.Boolean]] $IsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

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

    [AADFeatureRolloutPolicy] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADFeatureRolloutPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Azure AD Policy Feature Rollout Policy with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
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
                    $getValue = Get-MgBetaPolicyFeatureRolloutPolicy `
                        -FeatureRolloutPolicyId $this.Id `
                        -ExpandProperty 'AppliesTo' `
                        -ErrorAction SilentlyContinue
                }
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Policy Feature Rollout Policy with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaPolicyFeatureRolloutPolicy `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ExpandProperty 'AppliesTo' `
                            -ErrorAction SilentlyContinue
                    }
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            #endregion

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Azure AD Policy Feature Rollout Policy with DisplayName {$($this.DisplayName)}."
                return $this.AsResult($nullResult)
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Azure AD Policy Feature Rollout Policy with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

            $batchRequests = @()
            foreach ($group in $getValue.AppliesTo)
            {
                $batchRequests += @{
                    id     = $group.Id
                    method = 'GET'
                    url    = "/groups/$($group.Id)?`$select=id,displayName"
                }
            }
            $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests
            $groupDisplayNames = @($batchResponses.body.displayName | Sort-Object)

            $results = @{
                #region resource generator code
                AppliesTo               = $groupDisplayNames
                Description             = $getValue.Description
                DisplayName             = $getValue.DisplayName
                Feature                 = $getValue.Feature
                IsAppliedToOrganization = $getValue.IsAppliedToOrganization
                IsEnabled               = $getValue.IsEnabled
                Id                      = $getValue.Id
                Ensure                  = 'Present'
                Credential              = $this.Credential
                ApplicationId           = $this.ApplicationId
                TenantId                = $this.TenantId
                ApplicationSecret       = $this.ApplicationSecret
                CertificateThumbprint   = $this.CertificateThumbprint
                CertificatePath         = $this.CertificatePath
                CertificatePassword     = $this.CertificatePassword
                ManagedIdentity         = $this.ManagedIdentity
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

        if ($this.GetBoundParameters().ContainsKey('AppliesTo'))
        {
            $boundParameters.Remove('AppliesTo') | Out-Null
            $delta = Compare-Object -ReferenceObject $this.AppliesTo -DifferenceObject $currentInstance.AppliesTo
            $groupsToRemove = $delta | Where-Object { $_.SideIndicator -eq '=>' }
            $groupsToAdd = $delta | Where-Object { $_.SideIndicator -eq '<=' }

            $batchRequestsToRemove = @()
            foreach ($groupDisplayName in $groupsToRemove.InputObject)
            {
                $batchRequestsToRemove += @{
                    id     = $groupDisplayName
                    method = 'GET'
                    url    = "/groups?`$filter=displayName eq '$($groupDisplayName -replace "'", "''")'&`$select=id"
                }
            }
            $batchResponsesToRemove = Invoke-M365DSCGraphBatchRequest -Requests $batchRequestsToRemove
            $groupIdsToRemove = $batchResponsesToRemove.body.value.id
            foreach ($groupToRemove in $groupIdsToRemove)
            {
                Write-Verbose -Message "Removing Group with Id [$groupToRemove] from AAD Feature Rollout Policy [$($this.DisplayName)]"
                Remove-MgBetaPolicyFeatureRolloutPolicyApplyToDirectoryObjectByRef `
                    -FeatureRolloutPolicyId $currentInstance.Id `
                    -DirectoryObjectId $groupToRemove
            }

            $batchRequestsToAdd = @()
            foreach ($groupDisplayName in $groupsToAdd.InputObject)
            {
                $batchRequestsToAdd += @{
                    id     = $groupDisplayName
                    method = 'GET'
                    url    = "/groups?`$filter=displayName eq '$($groupDisplayName -replace "'", "''")'&`$select=id"
                }
            }
            $batchResponsesToAdd = Invoke-M365DSCGraphBatchRequest -Requests $batchRequestsToAdd
            $groupIdsToAdd = $batchResponsesToAdd.body.value.id
            foreach ($groupToAdd in $groupIdsToAdd)
            {
                Write-Verbose -Message "Adding Group with Id [$groupToAdd] to AAD Feature Rollout Policy [$($this.DisplayName)]"
                New-MgBetaPolicyFeatureRolloutPolicyApplyToByRef `
                    -FeatureRolloutPolicyId $currentInstance.Id `
                    -BodyParameter @{
                        '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/directoryObjects/$groupToAdd"
                    }
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Azure AD Policy Feature Rollout Policy with DisplayName {$($this.DisplayName)}"

            $createParameters = ([Hashtable]$boundParameters).Clone()
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $policy = New-MgBetaPolicyFeatureRolloutPolicy -BodyParameter $createParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Policy Feature Rollout Policy with Id {$($currentInstance.Id)}"

            $updateParameters = ([Hashtable]$boundParameters).Clone()
            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Remove('Feature') | Out-Null
            $updateParameters.Remove('IsAppliedToOrganization') | Out-Null

            #region resource generator code
            Update-MgBetaPolicyFeatureRolloutPolicy `
                -FeatureRolloutPolicyId $currentInstance.Id `
                -BodyParameter $updateParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Policy Feature Rollout Policy with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaPolicyFeatureRolloutPolicy -FeatureRolloutPolicyId $currentInstance.Id
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
            [array]$getValue = Get-MgBetaPolicyFeatureRolloutPolicy `
                -Filter $this.Filter `
                -ExpandProperty 'AppliesTo' `
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
                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }

                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
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
                $rawResults = $Results.Clone()

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
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

    hidden [AADFeatureRolloutPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADFeatureRolloutPolicy])
        {
            return $Values
        }

        $result = [AADFeatureRolloutPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
