using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAuthenticationStrengthPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name of the policy.')]
    [ValidateLength(1, 30)]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('A description of the policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The authentication method combinations allowed by this authentication strength policy.')]
    [System.String[]] $AllowedCombinations

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

    [AADAuthenticationStrengthPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADAuthenticationStrengthPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Azure AD Authentication Strength Policy for {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.DisplayName -ne $this.ExportedInstance.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaPolicyAuthenticationStrengthPolicy -AuthenticationStrengthPolicyId $this.Id -ErrorAction 'SilentlyContinue'
                }

                if ($null -eq $getValue)
                {
                    $getValue = Get-MgBetaPolicyAuthenticationStrengthPolicy | Where-Object -FilterScript { $_.DisplayName -eq $this.DisplayName } -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $results = @{
                Description           = $getValue.Description
                DisplayName           = $getValue.DisplayName
                Id                    = $getValue.Id
                AllowedCombinations   = $getValue.allowedCombinations
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

        Write-Verbose -Message "Setting the Azure AD Authentication Strength Policy for {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Azure AD AuthenticationStrengthPolicy {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null
            New-MgBetaPolicyAuthenticationStrengthPolicy -BodyParameter $createParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Authentication Strength Policy with DisplayName {$($this.DisplayName)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Id') | Out-Null
            $combinations = $updateParameters.AllowedCombinations
            $updateParameters.Remove('AllowedCombinations') | Out-Null

            # Need to retrieve the policy to make sure we are not trying to update a builtIn one.
            $policyObject = Get-MgBetaPolicyAuthenticationStrengthPolicy -AuthenticationStrengthPolicyId $currentInstance.Id
            if ($policyObject.PolicyType -eq 'builtIn')
            {
                throw "Authentication Strength Policy {$($this.DisplayName)} is a built-in and cannot be updated."
            }
            else
            {
                Update-MgBetaPolicyAuthenticationStrengthPolicy -AuthenticationStrengthPolicyId $currentInstance.Id -BodyParameter $updateParameters

                Write-Verbose -Message "Updating the Azure AD Authentication Strength Policy allowed combination with DisplayName {$($this.DisplayName)}"
                Update-MgBetaPolicyAuthenticationStrengthPolicyAllowedCombination -AuthenticationStrengthPolicyId $currentInstance.Id `
                    -AllowedCombinations $combinations
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Authentication Method Policy with Id {$($currentInstance.Id)}"
            Remove-MgBetaPolicyAuthenticationStrengthPolicy -AuthenticationStrengthPolicyId $currentInstance.Id
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
            $baseFilter = "policyType ne 'builtIn'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($baseFilter) and ($($this.Filter))"
            }
            [array]$getValue = Get-MgBetaPolicyAuthenticationStrengthPolicy `
                -All `
                -Filter $mergedFilter `
                -NoPageSize `
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
                    DisplayName           = $config.DisplayName
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

    hidden [AADAuthenticationStrengthPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADAuthenticationStrengthPolicy])
        {
            return $Values
        }

        $result = [AADAuthenticationStrengthPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
