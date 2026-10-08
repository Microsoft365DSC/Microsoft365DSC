using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADUserFlowAttribute : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('User flow attribute Id.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the user flow attribute.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the user flow attribute.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Defines the user flow attribute data type.')]
    [System.String] $DataType

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Azure AD role setting should exist or not.')]
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

    [AADUserFlowAttribute] Get()
    {
        $UserFlowAttribute = $null
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADUserFlowAttribute]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the AAD User Flow Attribute with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Write-Verbose -Message 'Getting configuration of user flow attribute'

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $UserFlowAttribute = Get-MgBetaIdentityUserFlowAttribute -IdentityUserFlowAttributeId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $UserFlowAttribute -and -not [System.String]::IsNullOrEmpty($this.DisplayName))
                {
                    $UserFlowAttribute = Get-MgBetaIdentityUserFlowAttribute -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'"
                }
            }
            else
            {
                $UserFlowAttribute = $this.ExportedInstance
            }

            if ($null -eq $UserFlowAttribute)
            {
                return $this.AsResult($nullReturn)
            }
            Write-Verbose -Message "Found configuration of user flow attribute $($this.DisplayName)"
            $result = @{
                Id                    = $UserFlowAttribute.Id
                DisplayName           = $UserFlowAttribute.DisplayName
                Description           = $UserFlowAttribute.Description
                DataType              = $UserFlowAttribute.DataType
                Ensure                = 'Present'
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                ApplicationSecret     = $this.ApplicationSecret
                Credential            = $this.Credential
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

        Write-Verbose -Message "Setting configuration of user flow attribute: $($this.DisplayName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentUserFlowAttribute = $this.Get().ToHashtable()

        # doesn't exist but it should
        if ($this.Ensure -eq 'Present' -and $currentUserFlowAttribute.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "The user flow attribute '$($this.DisplayName)' does not exist but it should. Creating it."

            try
            {
                New-MgBetaIdentityUserFlowAttribute -DataType $this.DataType -Description $this.Description -DisplayName $this.DisplayName
            }
            catch
            {
                throw
            }
        }
        #exists but shouldn't
        elseif ($this.Ensure -eq 'Absent' -and $currentUserFlowAttribute.Ensure -eq 'Present')
        {
            Write-Verbose -Message "User flow attribute '$($this.DisplayName)' exists but shouldn't. Removing it."
            Remove-MgBetaIdentityUserFlowAttribute -IdentityUserFlowAttributeId $currentUserFlowAttribute.Id
        }
        elseif ($this.Ensure -eq 'Present' -and $currentUserFlowAttribute.Ensure -eq 'Present')
        {
            Write-Verbose -Message "User flow attribute '$($this.DisplayName)' already exists. Updating settings"

            if ($currentUserFlowAttribute.DisplayName -ne $this.DisplayName -or $currentUserFlowAttribute.DataType -ne $this.DataType)
            {
                Write-Warning -Message "There is a deviation in display name and data type for the resource with ID '$($currentUserFlowAttribute.Id)' but these values are not settable so cannot update them."
            }

            Write-Verbose -Message "Updating description of user flow attribute with display name '$($this.DisplayName)'"
            Update-MgBetaIdentityUserFlowAttribute -IdentityUserFlowAttributeId $currentUserFlowAttribute.Id -Description $this.Description
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
            [array] $exportedInstances = Get-MgBetaIdentityUserFlowAttribute -Filter "userFlowAttributeType ne 'builtIn'" -Sort DisplayName -ErrorAction Stop
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($userFlowAttribute in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($userFlowAttribute.DisplayName)" -DeferWrite
                $Params = @{
                    Id                    = $userFlowAttribute.Id
                    DisplayName           = $userFlowAttribute.DisplayName
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    ApplicationSecret     = $this.ApplicationSecret
                    Credential            = $this.Credential
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $userFlowAttribute
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
                }
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
            }
            return $dscContent.ToString()
        }

        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADUserFlowAttribute] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADUserFlowAttribute])
        {
            return $Values
        }

        $result = [AADUserFlowAttribute]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
