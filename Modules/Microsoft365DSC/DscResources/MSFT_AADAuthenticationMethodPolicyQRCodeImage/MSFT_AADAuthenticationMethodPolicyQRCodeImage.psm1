using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAuthenticationMethodPolicyQRCodeImage : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Displayname of the groups of users that are excluded from a policy.')]
    [MSFT_AADAuthenticationMethodPolicyQRCodeImageExcludeTarget[]] $ExcludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('Displayname of the groups of users that are included from a policy.')]
    [MSFT_AADAuthenticationMethodPolicyQRCodeImageIncludeTarget[]] $IncludeTargets

    [DscProperty()]
    [System.ComponentModel.Description('The state of the policy. Possible values are: enabled, disabled.')]
    [ValidateSet('enabled', 'disabled')]
    [System.String] $State

    [DscProperty()]
    [System.ComponentModel.Description('Lifetime in days of the qr code.')]
    [System.Nullable[System.UInt32]] $StandardQRCodeLifetimeInDays

    [DscProperty()]
    [System.ComponentModel.Description('Length of the PIN.')]
    [ValidateRange(8, 20)]
    [System.Nullable[System.UInt32]] $PinLength

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Absent', 'Present')]
    [System.String] $Ensure

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

    [AADAuthenticationMethodPolicyQRCodeImage] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADAuthenticationMethodPolicyQRCodeImage]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Azure AD Authentication Method Policy QR Code with Id {$($this.Id)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
                    -AuthenticationMethodConfigurationId 'qrCodePin' `
                    -ErrorAction SilentlyContinue
            }
            else
            {
                $instance = $this.ExportedInstance | Where-Object -FilterScript { $_.Id -eq $this.Id }
            }
            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            #region resource generator code
            $complexExcludeTargets = @()
            foreach ($currentExcludeTargets in $instance.excludeTargets)
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

            $complexIncludeTargets = @()
            foreach ($currentIncludeTargets in $instance.includeTargets)
            {
                $myIncludeTargets = [ordered]@{}
                if ($currentIncludeTargets.id -ne 'all_users')
                {
                    $myIncludeTargetsDisplayName = Get-M365DSCGroupDisplayNameById -GroupId $currentIncludeTargets.Id
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
                Id                           = $instance.Id
                State                        = $instance.State
                ExcludeTargets               = $complexExcludeTargets
                IncludeTargets               = $complexIncludeTargets
                StandardQRCodeLifetimeInDays = $instance.StandardQRCodeLifetimeInDays
                PinLength                    = $instance.PinLength
                Ensure                       = 'Present'
                Credential                   = $this.Credential
                ApplicationId                = $this.ApplicationId
                TenantId                     = $this.TenantId
                CertificateThumbprint        = $this.CertificateThumbprint
                CertificatePath              = $this.CertificatePath
                CertificatePassword          = $this.CertificatePassword
                ManagedIdentity              = $this.ManagedIdentity
                AccessTokens                 = $this.AccessTokens
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

        Write-Verbose -Message "Setting the Azure AD Authentication Method Policy QR Code with Id {$($this.Id)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Authentication Method Policy QR Code Image with Id {$($currentInstance.Id)}"

            $updateParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters
            $updateParameters.Remove('Id') | Out-Null

            Update-M365DSCAuthenticationTargets -Targets $updateParameters.ExcludeTargets
            Update-M365DSCAuthenticationTargets -Targets $updateParameters.IncludeTargets

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.qrCodePinAuthenticationMethodConfiguration')
            Update-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
                -AuthenticationMethodConfigurationId $currentInstance.Id `
                -BodyParameter $updateParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Authentication Method Policy QR Code Image with Id {$($currentInstance.Id)}"
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
            [array] $exportedInstances = Get-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
                -AuthenticationMethodConfigurationId 'qrCodePin' `
                -ErrorAction Stop
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Id
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
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
                        -CIMInstanceName 'AADAuthenticationMethodPolicyQRCodeImageExcludeTarget'
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
                        -CIMInstanceName 'AADAuthenticationMethodPolicyQRCodeImageIncludeTarget'
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

    hidden [AADAuthenticationMethodPolicyQRCodeImage] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADAuthenticationMethodPolicyQRCodeImage])
        {
            return $Values
        }

        $result = [AADAuthenticationMethodPolicyQRCodeImage]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADAuthenticationMethodPolicyQRCodeImageExcludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The object identifier of an Azure AD group.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The type of the authentication method target. Possible values are: group and unknownFutureValue.')]
    [ValidateSet('group', 'unknownFutureValue')]
    [System.String] $TargetType
}

class MSFT_AADAuthenticationMethodPolicyQRCodeImageIncludeTarget
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The object identifier of an Azure AD group.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The type of the authentication method target. Possible values are: group and unknownFutureValue.')]
    [ValidateSet('group', 'unknownFutureValue')]
    [System.String] $TargetType
}
