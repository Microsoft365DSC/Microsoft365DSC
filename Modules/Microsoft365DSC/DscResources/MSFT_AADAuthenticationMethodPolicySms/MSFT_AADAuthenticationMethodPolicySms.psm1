using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAuthenticationMethodPolicySms : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Displayname of the groups of users that are excluded from a policy.')]
    [MSFT_AADAuthenticationMethodPolicySmsExcludeTarget[]] $ExcludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('Displayname of the groups of users that are included from a policy.')]
    [MSFT_AADAuthenticationMethodPolicySmsIncludeTarget[]] $IncludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('The state of the policy. Possible values are: enabled, disabled.')]
    [ValidateSet('enabled', 'disabled')]
    [System.String] $State

    [DscProperty(Key)]
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

    [AADAuthenticationMethodPolicySms] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADAuthenticationMethodPolicySms]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Azure AD Authentication Method Policy Sms with Id {$($this.Id)}"

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
                $getValue = Get-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId $this.Id -ErrorAction SilentlyContinue

                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Authentication Method Policy Sms with id {$($this.id)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Azure AD Authentication Method Policy Sms with Id {$($resolvedId)} was found."

            #region resource generator code
            Write-Verbose -Message 'Processing ExcludeTargets'
            $complexExcludeTargets = @()
            foreach ($currentExcludeTargets in $getValue.excludeTargets)
            {
                $myExcludeTargets = [ordered]@{}
                if ($currentExcludeTargets.id -ne 'all_users')
                {
                    $myExcludeTargetsDisplayName = Get-M365DSCGroupDisplayNameById -GroupId $currentExcludeTargets.Id
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

            Write-Verbose -Message 'Processing IncludeTargets'
            $complexIncludeTargets = @()
            foreach ($currentIncludeTargets in $getValue.includeTargets)
            {
                $myIncludeTargets = [ordered]@{}
                if ($currentIncludeTargets.id -ne 'all_users')
                {
                    $myIncludeTargetsDisplayName = Get-M365DSCGroupDisplayNameById -GroupId $currentIncludeTargets.id
                    if ($null -eq $myIncludeTargetsDisplayName)
                    {
                        continue
                    }
                    $myIncludeTargets.Add('Id', $myIncludeTargetsDisplayName)
                }
                else
                {
                    $myIncludeTargets.Add('Id', $currentIncludeTargets.id)
                }

                if ($null -ne $currentIncludeTargets.targetType)
                {
                    $myIncludeTargets.Add('TargetType', $currentIncludeTargets.targetType)
                }

                if ($myIncludeTargets.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexIncludeTargets += $myIncludeTargets
                }
            }
            $results = @{
                #region resource generator code
                ExcludeTargets        = $complexExcludeTargets
                IncludeTargets        = $complexIncludeTargets
                State                 = $getValue.State
                Id                    = $getValue.Id
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

        Write-Verbose -Message "Setting the Azure AD Authentication Method Policy Sms with Id {$($this.Id)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Authentication Method Policy Sms with Id {$($currentInstance.Id)}"

            $updateParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters
            $updateParameters.Remove('Id') | Out-Null

            Update-M365DSCAuthenticationTargets -Targets $updateParameters.ExcludeTargets
            Update-M365DSCAuthenticationTargets -Targets $updateParameters.IncludeTargets

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.smsAuthenticationMethodConfiguration')
            Update-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
                -AuthenticationMethodConfigurationId $currentInstance.Id `
                -BodyParameter $updateParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Authentication Method Policy Sms with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId $currentInstance.Id
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
            [array]$getValue = Get-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
                -AuthenticationMethodConfigurationId sms `
                -ErrorAction Stop | Where-Object -FilterScript { $null -ne $_.Id }
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
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
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
                        -CIMInstanceName 'AADAuthenticationMethodPolicySmsExcludeTarget'
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
                        -CIMInstanceName 'AADAuthenticationMethodPolicySmsIncludeTarget'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.IncludeTargets = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('IncludeTargets') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('ExcludeTargets', 'IncludeTargets')
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

    hidden [AADAuthenticationMethodPolicySms] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADAuthenticationMethodPolicySms])
        {
            return $Values
        }

        $result = [AADAuthenticationMethodPolicySms]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADAuthenticationMethodPolicySmsExcludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The object identifier of an Azure AD group.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The type of the authentication method target. Possible values are: group and unknownFutureValue.')]
    [ValidateSet('group', 'unknownFutureValue')]
    [System.String] $TargetType
}

class MSFT_AADAuthenticationMethodPolicySmsIncludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The object identifier of an Azure AD group.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The type of the authentication method target. Possible values are: group and unknownFutureValue.')]
    [ValidateSet('group', 'unknownFutureValue')]
    [System.String] $TargetType
}
