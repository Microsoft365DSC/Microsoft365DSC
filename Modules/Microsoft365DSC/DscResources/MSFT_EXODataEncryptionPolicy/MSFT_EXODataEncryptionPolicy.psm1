using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXODataEncryptionPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the data encryption policy that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The AzureKeyIDs parameter specifies the URI values of the Azure Key Vault keys to associate with the data encryption policy.')]
    [System.String[]] $AzureKeyIDs

    [DscProperty()]
    [System.ComponentModel.Description('The Description parameter specifies an optional description for the data encryption policy')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The Enabled parameter enables or disable the data encryption policy.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The Name parameter specifies the unique name for the data encryption policy.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The PermanentDataPurgeContact parameter specifies a contact for the purge of all data that''s encrypted by the data encryption policy.')]
    [System.String] $PermanentDataPurgeContact

    [DscProperty()]
    [System.ComponentModel.Description('The PermanentDataPurgeReason parameter specifies a descriptive reason for the purge of all data that''s encrypted by the data encryption policy')]
    [System.String] $PermanentDataPurgeReason

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this policy should exist.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
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

    [EXODataEncryptionPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXODataEncryptionPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Data encryption policy for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $DataEncryptionPolicy = Get-DataEncryptionPolicy -Identity $this.Identity -ErrorAction SilentlyContinue

                if ($null -eq $DataEncryptionPolicy)
                {
                    Write-Verbose -Message "Data encryption policy $($this.Identity) does not exist."
                    $nullReturn.Identity = $null
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $DataEncryptionPolicy = $this.ExportedInstance
            }

            Write-Verbose -Message "Found Data encryption policy $($this.Identity)"

            $result = @{
                Identity                  = $this.Identity
                AzureKeyIDs               = [System.String[]]$DataEncryptionPolicy.AzureKeyIDs
                Description               = $DataEncryptionPolicy.Description
                Enabled                   = $DataEncryptionPolicy.Enabled
                Name                      = $DataEncryptionPolicy.Name
                PermanentDataPurgeContact = $DataEncryptionPolicy.PermanentDataPurgeContact
                PermanentDataPurgeReason  = $DataEncryptionPolicy.PermanentDataPurgeReason
                Credential                = $this.Credential
                Ensure                    = 'Present'
                ApplicationId             = $this.ApplicationId
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
                TenantId                  = $this.TenantId
                AccessTokens              = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of Data encryption policy for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $DataEncryptionPolicies = Get-DataEncryptionPolicy
        $DataEncryptionPolicy = $DataEncryptionPolicies | Where-Object -FilterScript { $_.Identity -eq $this.Identity }
        $DataEncryptionPolicyParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $null -eq $DataEncryptionPolicy)
        {
            Write-Verbose -Message "Creating Data encryption policy $($this.Identity)."
            $DataEncryptionPolicyParams.Remove('Identity') | Out-Null
            $DataEncryptionPolicyParams.Remove('PermanentDataPurgeContact') | Out-Null
            $DataEncryptionPolicyParams.Remove('PermanentDataPurgeReason') | Out-Null
            New-DataEncryptionPolicy @DataEncryptionPolicyParams
            Write-Verbose -Message 'Data encryption policy created successfully.'
        }
        elseif ($this.Ensure -eq 'Present' -and $null -ne $DataEncryptionPolicy)
        {
            $DataEncryptionPolicyParams.Remove('AzureKeyIDs') | Out-Null
            $verboseMessage = "Setting Data encryption policy $($this.Identity) with values:" + `
                " $(Convert-M365DscHashtableToString -Hashtable $DataEncryptionPolicyParams)"
            Write-Verbose -Message $verboseMessage
            Set-DataEncryptionPolicy @DataEncryptionPolicyParams -Confirm:$false
            Write-Verbose -Message 'Data encryption policy updated successfully.'
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        #Ensure the proper dependencies are installed in the current environment.
        Confirm-M365DSCDependencies

        #region Telemetry
        $this.AddTelemetry('Export')

        #endregion
        try
        {
            [Array]$DataEncryptionPolicies = Get-DataEncryptionPolicy -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()

            if ($DataEncryptionPolicies.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($DataEncryptionPolicy in $DataEncryptionPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($DataEncryptionPolicies.Count)] $($DataEncryptionPolicy.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $DataEncryptionPolicy.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $DataEncryptionPolicy
                $Results = $this.GetForExport($Params)
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
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXODataEncryptionPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXODataEncryptionPolicy])
        {
            return $Values
        }

        $result = [EXODataEncryptionPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
