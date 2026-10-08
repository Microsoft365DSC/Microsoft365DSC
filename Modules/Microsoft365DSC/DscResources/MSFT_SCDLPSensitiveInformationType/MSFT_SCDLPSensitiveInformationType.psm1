using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCDLPSensitiveInformationType : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies a name for the sensitive information type rule. The value must be less than 256 characters.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Unique identifier of the Sensitive Information Type.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The Description parameter specifies a description for the sensitive information type rule.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The fingerprint file data for the Sensitive Information Type.')]
    [System.String] $FileData

    [DscProperty()]
    [System.ComponentModel.Description('The Locale parameter specifies the language that''s associated with the sensitive information type rule.')]
    [System.String] $Locale

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

    [SCDLPSensitiveInformationType] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCDLPSensitiveInformationType]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of DLPSensitiveInformationType for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $SIT = Invoke-M365DSCCommand -ScriptBlock { Get-DlpSensitiveInformationType -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $SIT)
                {
                    Write-Verbose -Message "DLPSensitiveInformationType $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $SIT = $this.ExportedInstance
            }

            Write-Verbose "Found existing DLPSensitiveInformationType $($this.Name)"

            $fileDataValue = $null
            if ($null -ne $SIT.FingerPrints)
            {
                $fileDataValue = (ConvertFrom-Json $SIT.FingerPrints[0]).Value
            }
            $result = @{
                Ensure                = 'Present'
                Name                  = $SIT.Name
                Identity              = $SIT.Id
                Description           = $SIT.Description
                Locale                = $SIT.DefaultCulture.ToString()
                FileData              = $fileDataValue
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                AccessTokens          = $this.AccessTokens
            }

            $paramsToRemove = @()
            foreach ($paramName in $result.Keys)
            {
                if ($null -eq $result[$paramName] -or '' -eq $result[$paramName] -or @() -eq $result[$paramName])
                {
                    $paramsToRemove += $paramName
                }
            }

            foreach ($paramName in $paramsToRemove)
            {
                $result.Remove($paramName)
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($null -ne $setParameters.FileData)
        {
            $setParameters.FileData = [System.Text.Encoding]::UTF8.GetBytes($setParameters.FileData)
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a DLPSensitiveInformationType with Name {$($this.Name)}"
            $setParameters.Remove('Identity') | Out-Null
            New-DLPSensitiveInformationType @setParameters
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the DLPSensitiveInformationType with Name {$($this.Name)}"
            $setParameters.Identity = $currentInstance.Identity
            $setParameters.Remove('Name') | Out-Null
            Set-DLPSensitiveInformationType @setParameters
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the DLPSensitiveInformationType with Name {$($this.Name)}"
            Remove-DLPSensitiveInformationType -Identity $currentInstance.Identity
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

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$SITs = Get-DLPSensitiveInformationType -ErrorAction Stop | Where-Object {
                # Only use information types that are not part of a rule package
                # as those are handled in the SCDLPSensitiveInformationTypeRulePackage resource.
                $_.RulePackId -like "0000*"
            }

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($SITs.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($SIT in $SITs)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($SITS.Length)] $($SIT.Name)" -DeferWrite

                $this.ExportedInstance = $SIT
                $Results = $this.GetForExport(@{ Name = $SIT.name; FileData = 'temp' })

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @()

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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('Identity', 'FileData')
        }
    }

    hidden [SCDLPSensitiveInformationType] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCDLPSensitiveInformationType])
        {
            return $Values
        }

        $result = [SCDLPSensitiveInformationType]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
