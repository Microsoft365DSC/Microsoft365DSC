using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAgreement : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the agreement.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the agreement.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Whether the user is required to view the agreement document before accepting.')]
    [System.Nullable[System.Boolean]] $IsViewingBeforeAcceptanceRequired

    [DscProperty()]
    [System.ComponentModel.Description('Whether the agreement is per device or per user.')]
    [System.Nullable[System.Boolean]] $IsPerDeviceAcceptanceRequired

    [DscProperty()]
    [System.ComponentModel.Description('Duration after which the user must re-accept the terms of use. Must be in ISO 8601 duration format.')]
    [System.String] $UserReacceptRequiredFrequency

    [DscProperty()]
    [System.ComponentModel.Description('The content of the agreement file, either a base64-encoded PDF or the text of a PDF starting with %PDF-. Other text is UTF-8 encoded and only accepted when the agreement is created.')]
    [System.String] $FileData

    [DscProperty()]
    [System.ComponentModel.Description('The name of the agreement file for the language set in Language. Changing it publishes FileData as the new file of that language.')]
    [System.String] $FileName

    [DscProperty()]
    [System.ComponentModel.Description('The language of the agreement file, such as en-US.')]
    [System.String] $Language

    [DscProperty()]
    [System.ComponentModel.Description('Expiration schedule and frequency of the agreement for all users.')]
    [MSFT_TermsExpiration] $TermsExpiration

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the agreement should exist or not.')]
    [ValidateSet('Present', 'Absent')]
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

    [AADAgreement] Get()
    {
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADAgreement]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Azure AD Agreement with DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = @{
                    DisplayName = $this.DisplayName
                    Ensure      = 'Absent'
                }

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $instance = Get-MgBetaAgreement -AgreementId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Could not find Azure AD Agreement with ID {$($this.Id)}"
                    $instance = Get-MgBetaAgreement -All -Filter "displayName eq '$($this.DisplayName.Replace("'", "''"))'" -ErrorAction SilentlyContinue
                }

                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Could not find Azure AD Agreement with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            $localizations = (Invoke-M365DSCGraphRequest -Method GET `
                -Uri "/v1.0/identityGovernance/termsOfUse/agreements/$($instance.Id)/file/localizations" `
                -ErrorAction SilentlyContinue).value

            $file = $null
            if (-not [System.String]::IsNullOrEmpty($this.Language))
            {
                $file = $localizations | Where-Object -Property language -EQ $this.Language | Select-Object -First 1
            }

            if ($null -eq $file)
            {
                $file = $localizations | Where-Object -Property isDefault -EQ $true | Select-Object -First 1
            }

            $this.ResourceCache.AgreementFile = $file

            $complexTermsExpiration = $null
            if ($null -ne $instance.TermsExpiration)
            {
                $complexTermsExpiration = @{
                    Frequency = $instance.TermsExpiration.Frequency
                }

                if ($null -ne $instance.TermsExpiration.StartDateTime)
                {
                    $complexTermsExpiration.StartDateTime = $instance.TermsExpiration.StartDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ')
                }
            }

            # TODO: Recheck or possibly regenerate the resource entirely to include all supported properties with the correct structure
            $results = @{
                DisplayName                       = $instance.DisplayName
                Id                                = $instance.Id
                IsViewingBeforeAcceptanceRequired = $instance.IsViewingBeforeAcceptanceRequired
                IsPerDeviceAcceptanceRequired     = $instance.IsPerDeviceAcceptanceRequired
                UserReacceptRequiredFrequency     = $instance.UserReacceptRequiredFrequency
                FileName                          = $file.fileName
                Language                          = $file.language
                TermsExpiration                   = $complexTermsExpiration
                Ensure                            = 'Present'
                Credential                        = $this.Credential
                ApplicationId                     = $this.ApplicationId
                TenantId                          = $this.TenantId
                ApplicationSecret                 = $this.ApplicationSecret
                CertificateThumbprint             = $this.CertificateThumbprint
                CertificatePath                   = $this.CertificatePath
                CertificatePassword               = $this.CertificatePassword
                ManagedIdentity                   = $this.ManagedIdentity
                AccessTokens                      = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration for the Azure AD Agreement with DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $termsExpirationValue = $null
        if ($null -ne $this.TermsExpiration)
        {
            $termsExpirationValue = @{
                frequency     = $this.TermsExpiration.Frequency
                startDateTime = $this.TermsExpiration.StartDateTime
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            # Prepare the file content
            $fileContent = @()
            $fileContent += @{
                fileData  = @{
                    data = [AADAgreement]::ConvertToFileData($this.FileData)
                }
                fileName  = $this.FileName
                language  = $this.Language
                isDefault = $true
            }

            $createParameters = @{
                displayName                       = $this.DisplayName
                isViewingBeforeAcceptanceRequired = $this.IsViewingBeforeAcceptanceRequired
                isPerDeviceAcceptanceRequired     = $this.IsPerDeviceAcceptanceRequired
                userReacceptRequiredFrequency     = $this.UserReacceptRequiredFrequency
                termsExpiration                   = $termsExpirationValue
                files                             = $fileContent
            }

            $createParameters = Remove-NullEntriesFromHashtable -Hash $createParameters
            Write-Verbose -Message "Creating Azure AD Agreement with DisplayName {$($this.DisplayName)} with:`r`n$(ConvertTo-Json $createParameters -Depth 5)"

            New-MgBetaAgreement -BodyParameter $createParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $boundParameters = $this.GetBoundParameters()
            foreach ($propertyName in @('IsPerDeviceAcceptanceRequired', 'UserReacceptRequiredFrequency'))
            {
                if ($boundParameters.ContainsKey($propertyName) -and $boundParameters[$propertyName] -ne $currentInstance[$propertyName])
                {
                    Write-Warning -Message "Property {$propertyName} of the Azure AD Agreement {$($this.DisplayName)} can only be set at creation. Remove and re-create the agreement to change it."
                }
            }

            if ($null -ne $termsExpirationValue -and $null -ne $currentInstance.TermsExpiration -and
                ($termsExpirationValue.frequency -ne $currentInstance.TermsExpiration.Frequency -or
                -not [M365DSCResourceBase]::IsSameDateTime($termsExpirationValue.startDateTime, $currentInstance.TermsExpiration.StartDateTime)))
            {
                Write-Warning -Message "Property {TermsExpiration} of the Azure AD Agreement {$($this.DisplayName)} can only be set at creation. Remove and re-create the agreement to change it."
            }

            $viewingRequired = $currentInstance.IsViewingBeforeAcceptanceRequired
            if ($null -ne $this.IsViewingBeforeAcceptanceRequired)
            {
                $viewingRequired = $this.IsViewingBeforeAcceptanceRequired
            }

            $updateParameters = @{
                displayName                       = $this.DisplayName
                isViewingBeforeAcceptanceRequired = $viewingRequired
            }

            $updateParameters = Remove-NullEntriesFromHashtable -Hash $updateParameters
            Write-Verbose -Message "Updating Azure AD Agreement with ID {$($currentInstance.Id)} with:`r`n$(ConvertTo-Json $updateParameters -Depth 5)"
            Update-MgBetaAgreement -AgreementId $currentInstance.Id `
                -BodyParameter $updateParameters | Out-Null

            $targetFileName = $currentInstance.FileName
            if (-not [System.String]::IsNullOrEmpty($this.FileName))
            {
                $targetFileName = $this.FileName
            }

            $targetLanguage = $currentInstance.Language
            if (-not [System.String]::IsNullOrEmpty($this.Language))
            {
                $targetLanguage = $this.Language
            }

            if ($targetFileName -ne $currentInstance.FileName -or $targetLanguage -ne $currentInstance.Language)
            {
                $payload = [AADAgreement]::ConvertToFileData($this.FileData)
                if ([System.String]::IsNullOrEmpty($payload) -or -not $payload.StartsWith('JVBERi', [System.StringComparison]::Ordinal))
                {
                    Write-Warning -Message "Property {FileData} of the Azure AD Agreement {$($this.DisplayName)} must be a PDF document to publish the file {$targetFileName} for language {$targetLanguage}."
                }
                else
                {
                    $currentFile = $this.ResourceCache.AgreementFile
                    $fileParameters = @{
                        fileName       = $targetFileName
                        displayName    = $this.DisplayName
                        language       = $targetLanguage
                        isDefault      = ($null -ne $currentFile -and $currentFile.isDefault -eq $true -and $currentFile.language -eq $targetLanguage)
                        isMajorVersion = $false
                        fileData       = @{
                            data = $payload
                        }
                    }

                    Write-Verbose -Message "Publishing file {$targetFileName} for language {$targetLanguage} on Azure AD Agreement with ID {$($currentInstance.Id)}"
                    Invoke-M365DSCGraphRequest -Method POST `
                        -Uri "/v1.0/identityGovernance/termsOfUse/agreements/$($currentInstance.Id)/files" `
                        -Body $fileParameters | Out-Null
                }
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Azure AD Agreement with DisplayName {$($this.DisplayName)} with ID {$($currentInstance.Id)}"
            Remove-MgBetaAgreement -AgreementId $currentInstance.Id
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('FileData')
            PostProcessing     = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($null -ne $DesiredValues.TermsExpiration -and $null -ne $CurrentValues.TermsExpiration -and
                    [M365DSCResourceBase]::IsSameDateTime($DesiredValues.TermsExpiration.StartDateTime, $CurrentValues.TermsExpiration.StartDateTime))
                {
                    $DesiredValues.TermsExpiration.StartDateTime = $CurrentValues.TermsExpiration.StartDateTime
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
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
            [array] $exportedInstances = Get-MgBetaAgreement -Filter $this.Filter -All

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckmark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($config in $exportedInstances)
            {
                $displayedKey = $config.DisplayName
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite

                $params = @{
                    DisplayName           = $config.DisplayName
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

                if ($null -ne $Results.TermsExpiration)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.TermsExpiration `
                        -CIMInstanceName 'MSFT_TermsExpiration'

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.TermsExpiration = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('TermsExpiration') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('TermsExpiration')
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

    hidden static [System.String] ConvertToFileData([System.String] $Value)
    {
        if ([System.String]::IsNullOrEmpty($Value) -or $Value.StartsWith('JVBERi', [System.StringComparison]::Ordinal))
        {
            return $Value
        }

        return [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Value))
    }

    hidden [AADAgreement] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADAgreement])
        {
            return $Values
        }

        $result = [AADAgreement]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_TermsExpiration
{
    [DscProperty()]
    [System.ComponentModel.Description('The frequency at which the agreement expires for all users after the first expiration set in StartDateTime. Must be in ISO 8601 duration format.')]
    [System.String] $Frequency

    [DscProperty()]
    [System.ComponentModel.Description('The date and time on which the agreement first expires for all users.')]
    [System.String] $StartDateTime
}
