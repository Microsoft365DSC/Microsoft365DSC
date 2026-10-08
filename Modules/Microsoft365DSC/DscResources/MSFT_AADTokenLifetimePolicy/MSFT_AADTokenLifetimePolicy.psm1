using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADTokenLifetimePolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name for this policy. Required.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('ObjectID of the Policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('A string collection containing a JSON string that defines the rules and settings for a policy. The syntax for the definition differs for each derived policy type. Required.')]
    [System.String[]] $Definition

    [DscProperty()]
    [System.ComponentModel.Description('If set to true, activates this policy. There can be many policies for the same policy type, but only one can be activated as the organization default. Optional, default value is false.')]
    [System.Nullable[System.Boolean]] $IsOrganizationDefault

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Azure AD Policy should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials for the Microsoft Graph delegated permissions.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
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

    [AADTokenLifetimePolicy] Get()
    {
        $Policy = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADTokenLifetimePolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AAD Token Lifetime Policy with DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'
                try
                {
                    if (-not [System.String]::IsNullOrEMpty($this.Id))
                    {
                        $Policy = Get-MgBetaPolicyTokenLifetimePolicy -TokenLifetimePolicyId $this.Id -ErrorAction SilentlyContinue
                    }
                }
                catch
                {
                    Write-Verbose -Message "Could not retrieve AzureAD Token Lifetime Policy by ID {$($this.Id)}"
                }
                if ($null -eq $Policy)
                {
                    try
                    {
                        $Policy = Get-MgBetaPolicyTokenLifetimePolicy -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" -ErrorAction SilentlyContinue
                    }
                    catch
                    {
                        $this.LogError($_, 'Error retrieving data:')
                    }
                }
                if ($null -eq $Policy)
                {
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $Policy = $this.ExportedInstance
            }

            Write-Verbose "Found existing AzureAD Policy {$($Policy.DisplayName)}"
            $Result = @{
                Id                    = $Policy.Id
                Definition            = $Policy.Definition
                DisplayName           = $Policy.DisplayName
                IsOrganizationDefault = $Policy.IsOrganizationDefault
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                ApplicationSecret     = $this.ApplicationSecret
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }

            return $this.AsResult($result)
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

        Write-Verbose -Message 'Setting configuration of Azure AD Policy'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentAADPolicy = $this.Get().ToHashtable()
        $currentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # Policy should exist but it doesn't
        if ($this.Ensure -eq 'Present' -and $currentAADPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new AzureAD Token Lifetime Policy {$($this.Displayname))}"
            Write-Verbose -Message "Parameters: $($currentParameters | Out-String)}"
            $currentParameters.Remove('Id') | Out-Null
            New-MgBetaPolicyTokenLifetimePolicy -BodyParameter $currentParameters
        }
        # Policy should exist and will be configured to desire state
        elseif ($this.Ensure -eq 'Present' -and $CurrentAADPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating existing AzureAD Policy {$($this.Displayname))}"
            $currentParameters.Remove('Id') | Out-Null
            Update-MgBetaPolicyTokenLifetimePolicy -TokenLifetimePolicyId $currentAADPolicy.ID -BodyParameter $currentParameters
        }
        # Policy exist but should not
        elseif ($this.Ensure -eq 'Absent' -and $CurrentAADPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing AzureAD Policy {$($this.Displayname))}"
            Remove-MgBetaPolicyTokenLifetimePolicy -TokenLifetimePolicyId $currentAADPolicy.ID
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

        $dscContent = [System.Text.StringBuilder]::new()
        $i = 1
        try
        {
            [array]$AADPolicies = Get-MgBetaPolicyTokenLifetimePolicy -All -Filter $this.Filter -ErrorAction Stop

            if ($AADPolicies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($AADPolicy in $AADPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AADPolicies.Count)] $($AADPolicy.DisplayName)" -DeferWrite
                $Params = @{
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    ApplicationSecret     = $this.ApplicationSecret
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    DisplayName           = $AADPolicy.DisplayName
                    ID                    = $AADPolicy.ID
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $AADPolicy
                $Results = $this.GetForExport($Params)

                if ($Results.Ensure -eq 'Present')
                {
                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName

                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    $i++
                }
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADTokenLifetimePolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADTokenLifetimePolicy])
        {
            return $Values
        }

        $result = [AADTokenLifetimePolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
