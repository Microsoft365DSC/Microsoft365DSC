using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXODataClassification : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the data classification rule that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The Description parameter specifies a description for the data classification rule. You use the Description parameter with the Locale and Name parameters to specify descriptions for the data classification rule in different languages. ')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The Fingerprints parameter specifies the byte-encoded document files that are used as fingerprints by the data classification rule.')]
    [System.String[]] $Fingerprints

    [DscProperty()]
    [System.ComponentModel.Description('IsDefault is used with the Locale parameter to specify the default language for the data classification rule.')]
    [System.Nullable[System.Boolean]] $IsDefault

    [DscProperty()]
    [System.ComponentModel.Description('The Locale parameter adds or removes languages that are associated with the data classification rule.')]
    [System.String] $Locale

    [DscProperty()]
    [System.ComponentModel.Description('The Name parameter specifies a name for the data classification rule. The value must be less than 256 characters.')]
    [System.String] $Name

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

    [EXODataClassification] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXODataClassification]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Data classification policy with Identity $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $DataClassification = Get-DataClassification -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $DataClassification)
                {
                    if (-not [System.String]::IsNullOrEmpty($this.Name))
                    {
                        Write-Verbose -Message "Couldn't retrieve data classification by Identity. Trying by Name {$($this.Name)}."
                        $DataClassification = Get-DataClassification -Identity $this.Name
                    }

                    if ($null -eq $DataClassification)
                    {
                        Write-Verbose -Message "Data classification $($this.Identity) does not exist."
                        return $this.AsResult($nullReturn)
                    }
                }
            }
            else
            {
                $DataClassification = $this.ExportedInstance
            }

            $currentDefaultCultureName = ([System.Globalization.CultureInfo]$DataClassification.DefaultCulture).Name
            $DataClassificationLocale = $currentDefaultCultureName
            $DataClassificationIsDefault = $false
            if (([String]::IsNullOrEmpty($this.Locale)) -or ($this.Locale -eq $currentDefaultCultureName))
            {
                $DataClassificationIsDefault = $true
            }

            $result = @{
                Identity              = $this.Identity
                Description           = $DataClassification.Description
                Fingerprints          = [System.String[]]$DataClassification.Fingerprints
                IsDefault             = $DataClassificationIsDefault
                Locale                = $DataClassificationLocale
                Name                  = $DataClassification.Name
                Credential            = $this.Credential
                Ensure                = 'Present'
                ApplicationId         = $this.ApplicationId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                TenantId              = $this.TenantId
                AccessTokens          = $this.AccessTokens
            }

            Write-Verbose -Message "Found Data classification policy $($this.Identity)"
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

        Write-Verbose -Message "Setting configuration of Data classification policy for $($this.Identity)"

        $null = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $DataClassification = Get-DataClassification -Identity $this.Identity -ErrorAction SilentlyContinue
        $DataClassificationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $null -eq $DataClassification)
        {
            Write-Verbose -Message 'Data Classification in Exchange Online are now deprecated in favor of Sensitive Information Types in Purview.'
        }
        elseif ($this.Ensure -eq 'Present' -and $null -ne $DataClassification)
        {
            $verboseMessage = "Setting Data classification policy $($this.Identity) with values:" + `
                " $(Convert-M365DscHashtableToString -Hashtable $DataClassificationParams)"
            Write-Verbose -Message $verboseMessage
            if (-not [String]::IsNullOrEmpty($this.Locale))
            {
                $DataClassificationParams.Locale = New-Object system.globalization.cultureinfo($this.Locale)
            }
            $DataClassificationParams.Remove('IsDefault') | Out-Null
            $isDefaultValue = $false
            if ($null -ne $this.IsDefault)
            {
                $isDefaultValue = $this.IsDefault
            }
            Set-DataClassification @DataClassificationParams -IsDefault:$isDefaultValue -Confirm:$false
            Write-Verbose -Message 'Data classification policy updated successfully.'
        }
        elseif ($this.Ensure -eq 'Absent' -and $null -ne $DataClassification)
        {
            Write-Verbose -Message "Removing Data classification policy $($this.Identity)"
            Remove-DataClassification -Identity $this.Identity -Confirm:$false
            Write-Verbose -Message 'Data classification policy removed successfully.'
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
            #region resource generator code
            [array] $exportedInstances = Get-DataClassification -ErrorAction SilentlyContinue | Sort-Object -Property Name
            $dscContent = [System.Text.StringBuilder]::new()

            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($DataClassification in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Length)] $($DataClassification.Name)" -DeferWrite

                $Params = @{
                    Identity              = $DataClassification.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $DataClassification
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

    hidden [EXODataClassification] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXODataClassification])
        {
            return $Values
        }

        $result = [EXODataClassification]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
