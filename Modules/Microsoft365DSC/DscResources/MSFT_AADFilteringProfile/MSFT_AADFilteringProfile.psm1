using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADFilteringProfile : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Profile name.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Unique identifier for the profile.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Description of the profile.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('State of the profile.')]
    [System.String] $State

    [DscProperty()]
    [System.ComponentModel.Description('The priority used to order the profile for processing within a list.')]
    [System.Nullable[System.Int64]] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('List of filtering policy names associated with the profile.')]
    [MSFT_AADFilteringProfilePolicyLink[]] $Policies

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

    [AADFilteringProfile] Get()
    {
        $instance = $null
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADFilteringProfile]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Azure AD Filtering Profile with Id {$($this.Id)} and Name {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    Write-Verbose -Message "Retrieving profile by Id {$($this.Id)}"
                    $instance = Get-MgBetaNetworkAccessFilteringProfile -ExpandProperty Policies -FilteringProfileId $this.Id -ErrorAction SilentlyContinue
                }
                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Retrieving profile by Name {$($this.Name)}"
                    $instance = Get-MgBetaNetworkAccessFilteringProfile -All -ExpandProperty Policies | Where-Object -FilterScript { $_.Name -eq $this.Name }
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $PolicyValue = @()
            if ($null -ne $instance.Policies -and $instance.Policies.Length -gt 0)
            {
                $policyLinks = Get-MgBetaNetworkAccessFilteringProfilePolicy -FilteringProfileId $instance.Id -ExpandProperty Policy
                foreach ($link in $policyLinks)
                {
                    $policyInfo = Get-MgBetaNetworkAccessFilteringPolicy -FilteringPolicyId $link.Policy.Id
                    if ($null -ne $policyInfo)
                    {
                        $entry = [ordered]@{
                            PolicyName   = $policyInfo.Name
                            LoggingState = $link.loggingState
                            Priority     = $link.priority
                            State        = $link.State
                        }
                        $PolicyValue += $entry
                    }
                }
            }

            $results = @{
                Name                  = $instance.Name
                Id                    = $instance.Id
                Description           = $instance.Description
                State                 = $instance.State
                Priority              = $instance.Priority
                Policies              = $PolicyValue
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

        $instanceParams = @{
            description = $this.Description
            name        = $this.Name
            priority    = $this.Priority
            state       = $this.State
            policies    = @()
        }

        foreach ($policy in $this.Policies)
        {
            $policyInfo = Get-MgBetaNetworkAccessFilteringPolicy -All | Where-Object -FilterScript { $_.Name -eq $policy.PolicyName }
            if ($null -eq $policyInfo -and $this.Ensure -eq 'Present')
            {
                throw "Could not find filtering policy {$($policy.PolicyName)}."
            }

            $entry = @{
                '@odata.type' = '#microsoft.graph.networkaccess.filteringPolicyLink'
                loggingState  = $policy.LoggingState
                priority      = $policy.Priority
                state         = $policy.State
                policy        = @{
                    '@odata.type' = '#microsoft.graph.networkaccess.filteringPolicy'
                    id            = $policyInfo.Id
                }
            }
            $instanceParams.policies += $entry
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new filtering profile {$($this.Name)}"
            New-MgBetaNetworkAccessFilteringProfile -BodyParameter $instanceParams
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating filtering profile {$($this.Name)} by removing and recreating"
            Remove-MgBetaNetworkAccessFilteringProfile -FilteringProfileId $currentInstance.Id
            New-MgBetaNetworkAccessFilteringProfile -BodyParameter $instanceParams
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing filtering profile {$($this.Name)}"
            Remove-MgBetaNetworkAccessFilteringProfile -FilteringProfileId $currentInstance.Id
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
            [array] $exportedInstances = Get-MgBetaNetworkAccessFilteringProfile `
                -All `
                -ExpandProperty Policies `
                -Filter $this.Filter `
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

                $displayedKey = $config.Name
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Name                  = $config.Name
                    Id                    = $config.Id
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

                if ($Results.Policies)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Policies -CIMInstanceName AADFilteringProfilePolicyLink
                    if ($complexTypeStringResult)
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

    hidden [AADFilteringProfile] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADFilteringProfile])
        {
            return $Values
        }

        $result = [AADFilteringProfile]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADFilteringProfilePolicyLink
{
    [DscProperty()]
    [System.ComponentModel.Description('Logging state for the associated policy.')]
    [System.String] $LoggingState

    [DscProperty()]
    [System.ComponentModel.Description('Provides an integer priority level for each instance of a URL filtering policy linked to a profile. Required.')]
    [System.Nullable[System.Int64]] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('State of the associated policy.')]
    [System.String] $State

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the associated policy.')]
    [System.String] $PolicyName
}
