using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCComplianceTag : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name of the complaiance tag.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this rule should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The EventType parameter specifies the retention rule that''s associated with the label.')]
    [System.String] $EventType

    [DscProperty()]
    [System.ComponentModel.Description('The IsRecordLabel parameter specifies whether the label is a record label.')]
    [System.Nullable[System.Boolean]] $IsRecordLabel

    [DscProperty()]
    [System.ComponentModel.Description('The Notes parameter specifies an optional note. If you specify a value that contains spaces, enclose the value in quotation marks, for example: ''This is a user note''')]
    [System.String] $Notes

    [DscProperty()]
    [System.ComponentModel.Description('Regulatory description')]
    [System.Nullable[System.Boolean]] $Regulatory

    [DscProperty()]
    [System.ComponentModel.Description('The FilePlanProperty parameter specifies the file plan properties to include in the label.')]
    [MSFT_SCFilePlanProperty] $FilePlanProperty

    [DscProperty()]
    [System.ComponentModel.Description('The ReviewerEmail parameter specifies the email address of a reviewer for Delete and KeepAndDelete retention actions. You can specify multiple email addresses separated by commas.')]
    [System.String[]] $ReviewerEmail

    [DscProperty()]
    [System.ComponentModel.Description('The RetentionDuration parameter specifies the hold duration for the retention rule. Valid values are: An integer - The hold duration in days, Unlimited - The content is held indefinitely.')]
    [System.String] $RetentionDuration

    [DscProperty()]
    [System.ComponentModel.Description('The RetentionAction parameter specifies the action for the label. Valid values are: Delete, Keep or KeepAndDelete.')]
    [ValidateSet('Delete', 'Keep', 'KeepAndDelete')]
    [System.String] $RetentionAction

    [DscProperty()]
    [System.ComponentModel.Description('The RetentionType parameter specifies whether the retention duration is calculated from the content creation date, tagged date, or last modification date. Valid values are: CreationAgeInDays, EventAgeInDays,ModificationAgeInDays, or TaggedAgeInDays.')]
    [ValidateSet('CreationAgeInDays', 'EventAgeInDays', 'ModificationAgeInDays', 'TaggedAgeInDays')]
    [System.String] $RetentionType

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

    [SCComplianceTag] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCComplianceTag]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of ComplianceTag for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                #Ensure the proper dependencies are installed in the current environment.
                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $tagObject = Invoke-M365DSCCommand -ScriptBlock { Get-ComplianceTag -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $tagObject)
                {
                    Write-Verbose -Message "ComplianceTag $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $tagObject = $this.ExportedInstance
            }

            $eventTypeName = $null
            if (-not [System.String]::IsNullOrEmpty($tagObject.EventTypeId))
            {
                $eventTypeObject = Invoke-M365DSCCommand -ScriptBlock { Get-ComplianceTagEventType -Identity $tagObject.EventTypeId -ErrorAction Stop } -SuppressNotFoundError
                if ($null -ne $eventTypeObject)
                {
                    $eventTypeName = $eventTypeObject.Name
                }
            }

            Write-Verbose "Found existing ComplianceTag $($this.Name)"
            $result = @{
                Name                  = $tagObject.Name
                Comment               = $tagObject.Comment
                RetentionDuration     = $tagObject.RetentionDuration
                IsRecordLabel         = $tagObject.IsRecordLabel
                Regulatory            = $tagObject.Regulatory
                Notes                 = $tagObject.Notes
                ReviewerEmail         = $tagObject.ReviewerEmail
                RetentionAction       = $tagObject.RetentionAction
                EventType             = $eventTypeName
                RetentionType         = $tagObject.RetentionType
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }

            if (-not [System.String]::IsNullOrEmpty($tagObject.FilePlanMetadata))
            {
                $ConvertedFilePlanProperty = $this.GetFilePlanProperty($tagObject.FilePlanMetadata)
                $result.Add('FilePlanProperty', $ConvertedFilePlanProperty)
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

        Write-Verbose -Message "Setting configuration of ComplianceTag for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentTag = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $CurrentTag.Ensure -eq 'Absent')
        {
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            #Convert File plan to JSON before Set
            if ($this.FilePlanProperty)
            {
                Write-Verbose -Message 'Converting FilePlan to JSON'
                $FilePlanPropertyJSON = ConvertTo-Json ($this.GetFilePlanPropertyObject($this.FilePlanProperty))
                $CreationParams.FilePlanProperty = $FilePlanPropertyJSON
            }
            Write-Verbose "Creating new Compliance Tag $($this.Name) calling the New-ComplianceTag cmdlet."
            New-ComplianceTag @CreationParams
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentTag.Ensure -eq 'Present')
        {
            $SetParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            # Remove unused parameters for Set-ComplianceTag cmdlet
            $SetParams.Remove('Name')
            $SetParams.Remove('IsRecordLabel')
            $SetParams.Remove('Regulatory')
            $SetParams.Remove('RetentionAction')
            $SetParams.Remove('RetentionType')

            # Once set, a label can't be removed;
            if ($SetParams.IsRecordLabel -eq $false -and $CurrentTag.IsRecordLabel -eq $true)
            {
                throw "Can't remove label on the existing Compliance Tag {$($this.Name)}. " + `
                    'You will need to delete the tag and recreate it.'
            }

            if ($null -ne $this.GetBoundParameters()['Regulatory'] -and
                $this.Regulatory -ne $CurrentTag.Regulatory)
            {
                throw "SPComplianceTag can't change the Regulatory property on " + `
                    "existing tags {$($this.Name)} from $($this.Regulatory) to $($CurrentTag.Regulatory)." + `
                    ' You will need to delete the tag and recreate it.'
            }

            if ($this.RetentionAction -ne $CurrentTag.RetentionAction)
            {
                throw "SPComplianceTag can't change the RetentionAction property on " + `
                    "existing tags {$($this.Name)} from $($this.RetentionAction) to $($CurrentTag.RetentionAction)." + `
                    ' You will need to delete the tag and recreate it.'
            }

            if ($this.RetentionType -ne $CurrentTag.RetentionType)
            {
                throw "SPComplianceTag can't change the RetentionType property on " + `
                    "existing tags {$($this.Name)} from $($this.RetentionType) to $($CurrentTag.RetentionType)." + `
                    ' You will need to delete the tag and recreate it.'
            }

            #Convert File plan to JSON before Set
            if ($this.FilePlanProperty)
            {
                Write-Verbose -Message 'Converting FilePlan properties to JSON'
                $FilePlanPropertyJSON = ConvertTo-Json ($this.GetFilePlanPropertyObject($this.FilePlanProperty))
                $SetParams['FilePlanProperty'] = $FilePlanPropertyJSON
            }
            Set-ComplianceTag @SetParams -Identity $this.Name
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentTag.Ensure -eq 'Present')
        {
            # If the Rule exists and it shouldn't, simply remove it;
            Remove-ComplianceTag -Identity $this.Name -Confirm:$false
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
            [array]$tags = Get-ComplianceTag -ErrorAction Stop

            $totalTags = $tags.Length
            if ($null -eq $totalTags)
            {
                $totalTags = 1
            }
            $i = 1
            if ($tags.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            foreach ($tag in $tags)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($totalTags)] $($tag.Name)" -DeferWrite
                $this.ExportedInstance = $tag
                $Results = $this.GetForExport(@{ Name = $tag.Name })
                $rawResults = $Results.Clone()
                if ($Results.FilePlanProperty)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.FilePlanProperty `
                        -CIMInstanceName 'SCFilePlanProperty'
                    if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                    {
                        $Results.FilePlanProperty = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('FilePlanProperty') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('FilePlanProperty') `
                    -RawResults $rawResults
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

    hidden [System.Collections.Hashtable] GetFilePlanPropertyObject([System.Object] $Properties)
    {
        if ($null -eq $Properties)
        {
            return $null
        }

        $result = @{
            Settings = @(
                @{Key = 'FilePlanPropertyDepartment'; Value = $Properties.FilePlanPropertyDepartment },
                @{Key = 'FilePlanPropertyCategory'; Value = $Properties.FilePlanPropertyCategory },
                @{Key = 'FilePlanPropertySubcategory'; Value = $Properties.FilePlanPropertySubcategory },
                @{Key = 'FilePlanPropertyCitation'; Value = $Properties.FilePlanPropertyCitation },
                @{Key = 'FilePlanPropertyReferenceId'; Value = $Properties.FilePlanPropertyReferenceId },
                @{Key = 'FilePlanPropertyAuthority'; Value = $Properties.FilePlanPropertyAuthority }
            )
        }

        return $result
    }

    hidden [System.Collections.Hashtable] GetFilePlanProperty([System.String] $Metadata)
    {
        if ($null -eq $Metadata)
        {
            return $null
        }
        $JSONObject = ConvertFrom-Json $Metadata

        $result = @{}

        foreach ($item in $JSONObject.Settings)
        {
            $result.Add($item.Key, $item.Value)
        }

        return $result
    }

    hidden [SCComplianceTag] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCComplianceTag])
        {
            return $Values
        }

        $result = [SCComplianceTag]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_SCFilePlanProperty
{
    [DscProperty()]
    [System.ComponentModel.Description('File plan department. Can get list by running Get-FilePlanPropertyDepartment.')]
    [System.String] $FilePlanPropertyDepartment

    [DscProperty()]
    [System.ComponentModel.Description('File plan Authority. Can get list by running Get-FilePlanPropertyAuthority.')]
    [System.String] $FilePlanPropertyAuthority

    [DscProperty()]
    [System.ComponentModel.Description('File plan category. Can get a list by running Get-FilePlanPropertyCategory.')]
    [System.String] $FilePlanPropertyCategory

    [DscProperty()]
    [System.ComponentModel.Description('File plan citation. Can get a list by running Get-FilePlanPropertyCitation.')]
    [System.String] $FilePlanPropertyCitation

    [DscProperty()]
    [System.ComponentModel.Description('File plan reference id. Can get a list by running Get-FilePlanPropertyReferenceId.')]
    [System.String] $FilePlanPropertyReferenceId

    [DscProperty()]
    [System.ComponentModel.Description('File plan subcategory. Can get a list by running Get-FilePlanPropertySubCategory.')]
    [System.String] $FilePlanPropertySubCategory
}
