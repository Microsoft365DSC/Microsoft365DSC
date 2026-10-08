using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCDLPSensitiveInformationTypeRulePackage : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies a name for the sensitive information type rule package. The value must be less than 256 characters.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Unique identifier of the Sensitive Information Type Rule Package.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The XML file data for the Sensitive Information Type Rule Package.')]
    [System.String] $XmlFileData

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
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [SCDLPSensitiveInformationTypeRulePackage] Get()
    {
        $CertificatePassword = $null
        $CertificatePath = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCDLPSensitiveInformationTypeRulePackage]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of DLPSensitiveInformationTypeRulePackage for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $SIT = Invoke-M365DSCCommand -ScriptBlock { Get-DlpSensitiveInformationTypeRulePackage -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $SIT)
                {
                    Write-Verbose -Message "DLPSensitiveInformationTypeRulePackage $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $SIT = $this.ExportedInstance
            }

            Write-Verbose "Found existing DLPSensitiveInformationTypeRulePackage $($this.Name)"

            $result = @{
                Ensure                = 'Present'
                Name                  = $SIT.RuleCollectionName
                Identity              = $SIT.Identity
                XmlFileData           = $SIT.ClassificationRuleCollectionXml -replace "lastModifiedTime=`".*?`"", '' # Remove last modified time as it is not relevant to the configuration and causes noise in diffs
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $CertificatePath
                CertificatePassword   = $CertificatePassword
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a new DLPSensitiveInformationTypeRulePackage with RuleCollectionName $($this.Name)"
            New-DLPSensitiveInformationTypeRulePackage -FileData ([System.Text.Encoding]::Unicode.GetBytes($this.XmlFileData))
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating a DLPSensitiveInformationTypeRulePackage with RuleCollectionName $($this.Name)"
            Set-DLPSensitiveInformationTypeRulePackage -FileData ([System.Text.Encoding]::Unicode.GetBytes($this.XmlFileData))
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing a DLPSensitiveInformationTypeRulePackage with RuleCollectionName $($this.Name)"
            Remove-DLPSensitiveInformationTypeRulePackage -Identity $currentInstance.Identity
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $rules = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$SITs = Get-DLPSensitiveInformationTypeRulePackage -ErrorAction Stop | Where-Object {
                $null -ne $_.Identity
            }

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($rules.Length -eq 0)
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

                Write-M365DSCHost -Message "    |---[$i/$($SITs.Length)] $($SIT.RuleCollectionName)" -DeferWrite

                $this.ExportedInstance = $SIT
                $Results = $this.GetForExport(@{ Name = $SIT.RuleCollectionName; XmlFileData = 'temp' })

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
            ExcludedProperties = @('Identity')
        }
    }

    hidden [SCDLPSensitiveInformationTypeRulePackage] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCDLPSensitiveInformationTypeRulePackage])
        {
            return $Values
        }

        $result = [SCDLPSensitiveInformationTypeRulePackage]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
