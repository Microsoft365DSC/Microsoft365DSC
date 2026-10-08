using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADEntitlementManagementAccessPackageCatalogResource : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the resource, such as the application name, group name or site name.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Id of the access package catalog resource.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The unique ID or the display name of the access package catalog.')]
    [System.String] $CatalogId

    [DscProperty()]
    [System.ComponentModel.Description('The name of the user or application that first added this resource. Read-only.')]
    [System.String] $AddedBy

    [DscProperty()]
    [System.ComponentModel.Description('The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z. Read-only.')]
    [System.String] $AddedOn

    [DscProperty()]
    [System.ComponentModel.Description('Contains information about the attributes to be collected from the requestor and sent to the resource application.')]
    [MSFT_MicrosoftGraphaccesspackageresourceattribute[]] $Attributes

    [DscProperty()]
    [System.ComponentModel.Description('A description for the resource.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('True if the resource is not yet available for assignment. Read-only.')]
    [System.Nullable[System.Boolean]] $IsPendingOnboarding

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the resource in the origin system. In the case of an Azure AD group, this is the identifier of the group.')]
    [System.String] $OriginId

    [DscProperty()]
    [System.ComponentModel.Description('The type of the resource in the origin system.')]
    [System.String] $OriginSystem

    [DscProperty()]
    [System.ComponentModel.Description('The type of the resource.')]
    [System.String] $ResourceType

    [DscProperty()]
    [System.ComponentModel.Description('A unique resource locator for the resource, such as the URL for signing a user into an application.')]
    [System.String] $Url

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
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

    [AADEntitlementManagementAccessPackageCatalogResource] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADEntitlementManagementAccessPackageCatalogResource]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AzureAD Entitlement Management Access Package Catalog Resource for DisplayName {$($this.DisplayName)}"

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $getValue = $null
            $CatalogIdValue = $this.catalogId
            $resolvedCatalogId = $this.CatalogId
            if (-not [System.String]::IsNullOrEmpty($this.CatalogId))
            {
                if (-not [System.Guid]::TryParse($this.CatalogId, [ref][System.Guid]::Empty))
                {
                    $catalogInstance = Get-MgBetaEntitlementManagementAccessPackageCatalog -Filter "DisplayName eq '$($this.catalogId -replace "'", "''")'"
                    $resolvedCatalogId = $catalogInstance.Id
                    $CatalogIdValue = $catalogInstance.DisplayName
                }

                $getValue = Get-MgBetaEntitlementManagementAccessPackageCatalogAccessPackageResource `
                    -AccessPackageCatalogId $resolvedCatalogId `
                    -Filter "Id eq '$($this.Id)'" -ErrorAction SilentlyContinue

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Retrieving Resource by Display Name {$($this.DisplayName)}"
                    $getValue = Get-MgBetaEntitlementManagementAccessPackageCatalogAccessPackageResource `
                        -AccessPackageCatalogId $resolvedCatalogId `
                        -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" -ErrorAction SilentlyContinue
                }
            }
            else
            {
                Write-Verbose -Message "No CatalogId was specified. Searching all catalogs for resource {$($this.DisplayName)}."
                foreach ($catalog in (Get-MgBetaEntitlementManagementAccessPackageCatalog -All -ErrorAction Stop))
                {
                    [Array] $catalogMatches = Get-MgBetaEntitlementManagementAccessPackageCatalogAccessPackageResource `
                        -AccessPackageCatalogId $catalog.Id `
                        -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                        -ErrorAction SilentlyContinue

                    if ($catalogMatches.Count -eq 0)
                    {
                        continue
                    }

                    if ($null -ne $getValue)
                    {
                        throw "The access package resource {$($this.DisplayName)} exists in more than one catalog. Specify the CatalogId."
                    }

                    $getValue = $catalogMatches[0]
                    $resolvedCatalogId = $catalog.Id
                    $CatalogIdValue = $catalog.DisplayName
                }
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "The access package resource with id {$($this.id)} was NOT found in catalog {$($resolvedCatalogId)}."
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "The access package resource {$($this.DisplayName)} was found in catalog {$($resolvedCatalogId)}."
            $hashAttributes = @()
            foreach ($attribute in ([Array]$getValue.attributes))
            {
                $hashAttribute = @{
                    AttributeName                  = $attribute.attributeName
                    IsEditable                     = $attribute.isEditable
                    IsPersistedOnAssignmentRemoval = $attribute.isPersistedOnAssignmentRemoval
                    AttributeSource                = @{
                        odataType = '#microsoft.graph.accessPackageResourceAttributeQuestion'
                        Question  = @{
                            odataType               = $attribute.attributeSource.question.'@odata.type'
                            Id                      = $attribute.attributeSource.question.id
                            IsRequired              = $attribute.attributeSource.question.isRequired
                            SequencePosition        = $attribute.attributeSource.question.sequence
                            IsSingleLine            = $attribute.attributeSource.question.isSingleLine
                            QuestionText            = Get-M365DSCDRGComplexTypeToHashtable -ComplexObject ($attribute.attributeSource.question.text)
                            AllowsMultipleSelection = $attribute.attributeSource.question.allowsMultipleSelection
                            Choices                 = Get-M365DSCDRGComplexTypeToHashtable -ComplexObject ([Array]$attribute.attributeSource.question.choices)
                        }
                    }
                    AttributeDestination           = @{
                        odataType = '#microsoft.graph.accessPackageUserDirectoryAttributeStore'
                    }
                }
                $hashAttributes += $hashAttribute
            }

            $originIdValue = Get-M365DSCAccessPackageResourceOriginDisplayName -OriginId $getValue.OriginId `
                -OriginSystem $getValue.OriginSystem

            $results = @{
                Id                    = $getValue.Id
                CatalogId             = $CatalogIdValue
                Attributes            = $hashAttributes
                AddedBy               = $getValue.addedBy #Read-Only
                AddedOn               = $getValue.addedOn #Read-Only
                Description           = $getValue.description
                DisplayName           = $getValue.displayName
                IsPendingOnboarding   = $getValue.isPendingOnboarding #Read-Only
                OriginId              = $originIdValue
                OriginSystem          = $getValue.originSystem
                ResourceType          = $getValue.resourceType
                Url                   = $getValue.url
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

        Write-Verbose -Message "Setting configuration of AzureAD Entitlement Management Access Package Catalog Resource for DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters.Remove('AddedBy') | Out-Null
        $boundParameters.Remove('AddedOn') | Out-Null
        $boundParameters.Remove('IsPendingOnboarding') | Out-Null

        $resource = $boundParameters
        if ($this.OriginSystem -eq 'AADGroup' -and `
                -not [System.Guid]::TryParse($this.OriginId, [ref][System.Guid]::Empty))
        {
            Write-Verbose -Message "The Group reference was provided by name {$($this.OriginId)}. Retrieving associated id."
            $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($this.OriginId -replace "'", "''")'" -All
            if ($null -ne $groupInfo)
            {
                $resource.OriginId = $groupInfo.Id
            }
        }
        if ($this.OriginSystem -eq 'AadApplication' -and `
                -not [System.Guid]::TryParse($this.OriginId, [ref][System.Guid]::Empty))
        {
            Write-Verbose -Message "The Application reference was provided by name {$($this.OriginId)}. Retrieving associated id."
            $appInfo = Get-MgServicePrincipal -Filter "DisplayName eq '$($this.OriginId -replace "'", "''")'" -All
            if ($null -ne $appInfo)
            {
                $resource.OriginId = $appInfo.Id
            }
        }

        $catalogIdValue = $this.CatalogId
        if ([System.String]::IsNullOrEmpty($catalogIdValue))
        {
            $catalogIdValue = $currentInstance.CatalogId
        }

        $resolvedCatalogId = $catalogIdValue
        if (-not [System.Guid]::TryParse($catalogIdValue, [ref][System.Guid]::Empty))
        {
            Write-Verbose -Message 'Retrieving Catalog by Display Name'
            $catalogInstance = Get-MgBetaEntitlementManagementAccessPackageCatalog -Filter "DisplayName eq '$($catalogIdValue -replace "'", "''")'"
            if ($catalogInstance)
            {
                $resolvedCatalogId = $catalogInstance.Id
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Assigning resource {$($this.DisplayName)} to catalog {$($resolvedCatalogId)}"

            $resource.Remove('Id') | Out-Null
            $resource.Remove('CatalogId') | Out-Null

            $mapping = @{
                odataType    = '@odata.type'
                questionText = 'text'
                sequencePosition = 'sequence'
            }
            $resource = Rename-M365DSCCimInstanceParameter -Properties $resource `
                -KeyMapping $mapping

            #Preparing parameter splat
            $resourceRequest = @{
                catalogId             = $resolvedCatalogId
                requestType           = 'AdminAdd'
                accessPackageResource = $resource
            }
            #region resource generator code
            Write-Verbose -Message "Creating a new AAD Entitlement Management Access Package Catalog Resource"
            New-MgBetaEntitlementManagementAccessPackageResourceRequest -BodyParameter $resourceRequest

            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating resource {$($this.DisplayName)} in catalog {$($resolvedCatalogId)}"

            $updateParameters = $boundParameters
            $resource = ([Hashtable]$updateParameters).Clone()
            $resource.Remove('Id') | Out-Null
            $resource.Remove('CatalogId') | Out-Null

            $mapping = @{
                odataType    = '@odata.type'
                questionText = 'text'
                sequencePosition = 'sequence'
            }
            $resource = Rename-M365DSCCimInstanceParameter -Properties $resource `
                -KeyMapping $mapping

            #region resource generator code
            $resourceRequest = @{
                catalogId             = $resolvedCatalogId
                requestType           = 'AdminUpdate'
                accessPackageResource = $resource
            }
            #region resource generator code
            New-MgBetaEntitlementManagementAccessPackageResourceRequest -BodyParameter $resourceRequest
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing resource {$($this.DisplayName)} from catalog {$($resolvedCatalogId)}"
            $resourceRequest = @{
                catalogId             = $resolvedCatalogId
                requestType           = 'AdminRemove'
                accessPackageResource = @{
                    id = $currentInstance.Id
                }
            }
            New-MgBetaEntitlementManagementAccessPackageResourceRequest -BodyParameter $resourceRequest
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
            $catalogs = @()
            $catalogs += Get-MgBetaEntitlementManagementAccessPackageCatalog -All -Filter $this.Filter -ErrorAction Stop
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($catalogs.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($catalog in $catalogs)
            {
                $displayedKey = $catalog.id
                if (-not [String]::IsNullOrEmpty($catalog.displayName))
                {
                    $displayedKey = $catalog.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($catalogs.Count)] $displayedKey" -DeferWrite

                [array]$resources = Get-MgBetaEntitlementManagementAccessPackageCatalogAccessPackageResource -AccessPackageCatalogId $catalog.Id -ErrorAction Stop

                $j = 1

                if ($resources.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }

                foreach ($resource in $resources)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "        |---[$j/$($resources.Count)] $($resource.DisplayName)" -DeferWrite

                    $params = @{
                        Id                    = $resource.id
                        DisplayName           = $resource.displayName
                        CatalogId             = $catalog.Id
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

                    $Results = $this.GetForExport($Params)
                    $rawResults = $Results.Clone()
                    if ($null -ne $Results.Attributes)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'AttributeDestination'
                                CimInstanceName = 'MicrosoftGraphaccesspackageresourceattributedestination'
                            }
                            @{
                                Name            = 'AttributeSource'
                                CimInstanceName = 'MicrosoftGraphaccesspackageresourceattributesource'
                            }
                            @{
                                Name            = 'Question'
                                CimInstanceName = 'MicrosoftGraphaccessPackageResourceAttributeQuestion'
                            }
                            @{
                                Name            = 'QuestionText'
                                CimInstanceName = 'MicrosoftGraphaccessPackageLocalizedContent'
                            }
                            @{
                                Name            = 'Choices'
                                CimInstanceName = 'MicrosoftGraphaccessPackageAnswerChoice'
                            }
                            @{
                                Name            = 'LocalizedTexts'
                                CimInstanceName = 'MicrosoftGraphaccessPackageLocalizedText'
                            }
                            @{
                                Name            = 'DisplayValue'
                                CimInstanceName = 'MicrosoftGraphaccessPackageLocalizedContent'
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ([Array]$Results.Attributes) `
                            -CIMInstanceName MicrosoftGraphaccesspackageresourceattribute `
                            -ComplexTypeMapping $complexMapping

                        $Results.Attributes = $complexTypeStringResult

                        if ([String]::IsNullOrEmpty($complexTypeStringResult))
                        {
                            $Results.Remove('Attributes') | Out-Null
                        }
                    }

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential `
                        -NoEscape @('Attributes') `
                        -RawResults $rawResults
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName

                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    $j++
                }

                $i++
            }

            # Removing comma between items in cim instance array
            $dscContent = $dscContent.Replace("            ,`r`n", '')
            return $dscContent.ToString()
        }
        catch
        {
            if ($_.ErrorDetails.Message -like '*User is not authorized to perform the operation.*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) Tenant does not meet license requirement to extract this component."
                return ''
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('AddedBy', 'AddedOn', 'IsPendingOnboarding')
            PostProcessing     = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)
                if ([M365DSCResourceBase]::IsReportContext($PostProcessingArgs) -or
                    [System.String]::IsNullOrEmpty($DesiredValues.OriginId))
                {
                    return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
                }

                $DesiredValues.OriginId = Get-M365DSCAccessPackageResourceOriginDisplayName -OriginId $DesiredValues.OriginId `
                    -OriginSystem $DesiredValues.OriginSystem

                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [AADEntitlementManagementAccessPackageCatalogResource] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADEntitlementManagementAccessPackageCatalogResource])
        {
            return $Values
        }

        $result = [AADEntitlementManagementAccessPackageCatalogResource]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphaccesspackageresourceattribute
{
    [DscProperty()]
    [System.ComponentModel.Description('Information about how to set the attribute, currently a accessPackageUserDirectoryAttributeStore object type.')]
    [MSFT_MicrosoftGraphaccesspackageresourceattributedestination] $AttributeDestination

    [DscProperty()]
    [System.ComponentModel.Description('The name of the attribute in the end system.')]
    [System.String] $AttributeName

    [DscProperty()]
    [System.ComponentModel.Description('Information about how to populate the attribute value when an accessPackageAssignmentRequest is being fulfilled, currently a accessPackageResourceAttributeQuestion object type.')]
    [MSFT_MicrosoftGraphaccesspackageresourceattributesource] $AttributeSource

    [DscProperty()]
    [System.ComponentModel.Description('Id of the access package resource attribute.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether or not an existing attribute value can be edited by the requester.')]
    [System.Nullable[System.Boolean]] $IsEditable

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the attribute will remain in the end system after an assignment ends.')]
    [System.Nullable[System.Boolean]] $IsPersistedOnAssignmentRemoval
}

class MSFT_MicrosoftGraphaccesspackageresourceattributedestination
{
    [DscProperty()]
    [System.ComponentModel.Description('Type of the access package resource attribute destination.')]
    [ValidateSet('#microsoft.graph.accessPackageUserDirectoryAttributeStore')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphaccesspackageresourceattributesource
{
    [DscProperty()]
    [System.ComponentModel.Description('Type of the access package resource attribute source.')]
    [ValidateSet('#microsoft.graph.accessPackageResourceAttributeQuestion')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('The question asked in order to get the value of the attribute.')]
    [MSFT_MicrosoftGraphaccessPackageResourceAttributeQuestion] $Question
}

class MSFT_MicrosoftGraphaccessPackageResourceAttributeQuestion
{
    [DscProperty()]
    [System.ComponentModel.Description('Type of the access package resource attribute question.')]
    [ValidateSet('#microsoft.graph.accessPackageTextInputQuestion', '#microsoft.graph.accessPackageMultipleChoiceQuestion')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('Id of the access package resource attribute question.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the requestor is required to supply an answer or not.')]
    [System.Nullable[System.Boolean]] $IsRequired

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the answer will be in single or multiple line format.')]
    [System.Nullable[System.Boolean]] $IsSingleLine

    [DscProperty()]
    [System.ComponentModel.Description('This is the regex pattern that the corresponding text answer must follow.')]
    [System.String] $RegexPattern

    [DscProperty()]
    [System.ComponentModel.Description('Relative position of this question when displaying a list of questions to the requestor.')]
    [System.Nullable[System.UInt32]] $SequencePosition

    [DscProperty()]
    [System.ComponentModel.Description('The text of the question to show to the requestor.')]
    [MSFT_MicrosoftGraphaccessPackageLocalizedContent] $QuestionText

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether requestor can select multiple choices as their answer.')]
    [System.Nullable[System.Boolean]] $AllowsMultipleSelection

    [DscProperty()]
    [System.ComponentModel.Description('List of answer choices.')]
    [MSFT_MicrosoftGraphaccessPackageAnswerChoice[]] $Choices
}

class MSFT_MicrosoftGraphaccessPackageLocalizedContent
{
    [DscProperty()]
    [System.ComponentModel.Description('The fallback string, which is used when a requested localization is not available. Required.')]
    [System.String] $DefaultText

    [DscProperty()]
    [System.ComponentModel.Description('Content represented in a format for a specific locale.')]
    [MSFT_MicrosoftGraphaccessPackageLocalizedText[]] $LocalizedTexts
}

class MSFT_MicrosoftGraphaccessPackageAnswerChoice
{
    [DscProperty()]
    [System.ComponentModel.Description('The actual value of the selected choice. This is typically a string value which is understandable by applications. Required.')]
    [System.String] $ActualValue

    [DscProperty()]
    [System.ComponentModel.Description('The localized display values shown to the requestor and approvers. Required.')]
    [MSFT_MicrosoftGraphaccessPackageLocalizedContent] $displayValue
}

class MSFT_MicrosoftGraphaccessPackageLocalizedText
{
    [DscProperty()]
    [System.ComponentModel.Description('The text in the specific language. Required.')]
    [System.String] $Text

    [DscProperty()]
    [System.ComponentModel.Description('The ISO code for the intended language. Required.')]
    [System.String] $LanguageCode
}
