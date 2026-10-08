using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOSearchManagedProperty : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name of the Managed Property')]
    [System.String] $Name

    [DscProperty(Key)]
    [System.ComponentModel.Description('The Type of the Managed Property')]
    [ValidateSet('Text', 'Integer', 'Decimal', 'DateTime', 'YesNo', 'Double', 'Binary')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Managed Property')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Enables querying against the content of the managed property.  The content of this managed property is included in the full-text index. For example, if the property is ''author'', a simple query for ''Smith'' returns items containing the word ''Smith'' and items whose author property contains ''Smith''.')]
    [System.Nullable[System.Boolean]] $Searchable

    [DscProperty()]
    [System.ComponentModel.Description('Defines which full-text index the Managed Property is stored in.')]
    [System.String] $FullTextIndex

    [DscProperty()]
    [System.ComponentModel.Description('Defines the context of a managed property within its full-text index.')]
    [System.Nullable[System.UInt32]] $FullTextContext

    [DscProperty()]
    [System.ComponentModel.Description('Enables querying against the specific Managed Property. The Managed Property field name must be included in the query, either specified in the query itself or included in the query programmatically. If the Managed Property is ''author'', the query must contain ''author:Smith''.')]
    [System.Nullable[System.Boolean]] $Queryable

    [DscProperty()]
    [System.ComponentModel.Description('Enables the content of this managed property to be returned in search results. Enable this setting for managed properties that are relevant to present in search results.')]
    [System.Nullable[System.Boolean]] $Retrievable

    [DscProperty()]
    [System.ComponentModel.Description('Allow multiple values of the same type in this managed property. For example, if this is the ''author'' managed property, and a document has multiple authors, each author name will be stored as a separate value in this managed property.')]
    [System.Nullable[System.Boolean]] $AllowMultipleValues

    [DscProperty()]
    [System.ComponentModel.Description('Yes: Enables using the property as a refiner for search results in the front end. You must manually configure the refiner in the web part. Yes - latent: Enables switching refinable to active later, without having to do a full re-crawl when you switch. Both options require a full crawl to take effect.')]
    [ValidateSet('No', 'Yes - latent', 'Yes')]
    [System.String] $Refinable

    [DscProperty()]
    [System.ComponentModel.Description('Yes: Enables sorting the result set based on the property before the result set is returned. Use for example for large result sets that cannot be sorted and retrieved at the same time. Yes - latent: Enables switching sortable to active later, without having to do a full re-crawl when you switch. Both options require a full crawl to take effect.')]
    [ValidateSet('No', 'Yes - latent', 'Yes')]
    [System.String] $Sortable

    [DscProperty()]
    [System.ComponentModel.Description('Enables this managed property to be returned for queries executed by anonymous users. Enable this setting for managed properties that do not contain sensitive information and are appropriate for anonymous users to view.')]
    [System.Nullable[System.Boolean]] $Safe

    [DscProperty()]
    [System.ComponentModel.Description('Define an alias for a managed property if you want to use the alias instead of the managed property name in queries and in search results. Use the original managed property and not the alias to map to a crawled property. Use an alias if you don''t want to or don''t have permission to create a new managed property.')]
    [System.String[]] $Aliases

    [DscProperty()]
    [System.ComponentModel.Description('Enable to return results independent of letter casing and diacritics(for example accented characters) used in the query.')]
    [System.Nullable[System.Boolean]] $TokenNormalization

    [DscProperty()]
    [System.ComponentModel.Description('By default, search returns partial matches between queries against this managed property and its content. Select Complete Matching for search to return exact matches instead. If a managed property ''Title'' contains ''Contoso Sites'', only the query Title: ''Contoso Sites'' will give a result.')]
    [System.Nullable[System.Boolean]] $CompleteMatching

    [DscProperty()]
    [System.ComponentModel.Description('By default, search depends on language when it breaks queries and content into parts (tokenization). Select language neutral tokenization if you have multilingual content and this managed property contains tags that are based on metadata term sets or other identifiers.')]
    [System.Nullable[System.Boolean]] $LanguageNeutralTokenization

    [DscProperty()]
    [System.ComponentModel.Description('By default, search tokenizes queries coarser than content. If a managed property ''ID'' contains the string ''1-23-456#7'', and you query ID:''1-23'', you might not get a partial match because search didn''t break the query into small enough parts. Consider selecting finer query tokenization if the content of this managed property contains separators such as dots and dashes. Finer query tokenization makes queries against this managed property slower.')]
    [System.Nullable[System.Boolean]] $FinerQueryTokenization

    [DscProperty()]
    [System.ComponentModel.Description('Names of the crawled properties that are mapped to this managed property')]
    [System.String[]] $MappedCrawledProperties

    [DscProperty()]
    [System.ComponentModel.Description('Enables the system to extract company name entities from the managed property when crawling new or updated items. Afterwards, the extracted entities can be used to set up refiners in the web part.')]
    [System.Nullable[System.Boolean]] $CompanyNameExtraction

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the Search Managed Property exists.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the account to authenticate with.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
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

    [SPOSearchManagedProperty] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOSearchManagedProperty]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Managed Property instance $($this.Name)"

        try
        {
            if (-not $this.ResourceCache['exportMode'])
            {
                $null = $this.Connect('PnP')

                $null = $this.Connect('PnP', (Get-MSCloudLoginConnectionProfile -Workload PnP).AdminUrl)

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = @{
                    Name   = $this.Name
                    Type   = $this.Type
                    Ensure = 'Absent'
                }
                $this.ResourceCache['RecentMPExtract'] = [Xml] (Get-PnPSearchConfiguration -Scope Subscription)
            }
            $property = $this.ResourceCache['RecentMPExtract'].SearchConfigurationSettings.SearchSchemaConfigurationSettings.ManagedProperties.dictionary.KeyValueOfstringManagedPropertyInfoy6h3NzC8 `
            | Where-Object -FilterScript { $_.Value.Name -eq $this.Name }

            [System.Xml.XmlElement]$aliasesValue = $this.ResourceCache['RecentMPExtract'].SearchConfigurationSettings.SearchSchemaConfigurationSettings.Aliases.dictionary.KeyValueOfstringAliasInfoy6h3NzC8 `
            | Where-Object -FilterScript { $_.Value.ManagedPid -eq $property.Value.Pid }

            if ($null -eq $property)
            {
                Write-Verbose -Message "The specified Managed Property {$($this.Name)} doesn't already exist."
                return $this.AsResult($nullReturn)
            }

            $companyNameExtractionValue = $false
            if ($property.Value.EntityExtractorBitMap -eq '4161')
            {
                $companyNameExtractionValue = $true
            }
            $fullTextIndexValue = $null
            if ([System.String] $property.Value.FullTextIndex -ne 'System.Xml.XmlElement')
            {
                $fullTextIndexValue = [System.String] $property.Value.FullTextIndex
            }

            # Get Mapped Crawled Properties
            $currentManagedPID = [System.String] $property.Value.Pid
            $mappedProperties = $this.ResourceCache['RecentMPExtract'].SearchConfigurationSettings.SearchSchemaConfigurationSettings.Mappings.dictionary.KeyValueOfstringMappingInfoy6h3NzC8 `
            | Where-Object -FilterScript { $_.Value.ManagedPid -eq $currentManagedPID }

            $mappings = @()
            foreach ($mappedProperty in $mappedProperties)
            {
                $mappings += $mappedProperty.Value.CrawledPropertyName.ToString()
            }

            $fixedRefinable = 'No'
            if ([System.Boolean]::Parse($property.Value.Refinable))
            {
                $fixedRefinable = 'Yes'
            }

            $fixedSortable = 'No'
            if ([System.Boolean]::Parse($property.Value.Sortable))
            {
                $fixedSortable = 'Yes'
            }
            Write-Verbose -Message 'Retrieved Property'
            return $this.AsResult(@{
                Name                        = [System.String] $property.Value.Name
                Type                        = [System.String] $property.Value.ManagedType
                Description                 = [System.String] $property.Value.Description
                Searchable                  = [System.Boolean]::Parse($property.Value.Searchable)
                FullTextIndex               = $fullTextIndexValue
                FullTextContext             = [UInt32] $property.Value.Context
                Queryable                   = [System.Boolean]::Parse($property.Value.Queryable)
                Retrievable                 = [System.Boolean]::Parse($property.Value.Retrievable)
                AllowMultipleValues         = [System.Boolean]::Parse($property.Value.HasMultipleValues)
                Refinable                   = $fixedRefinable
                Sortable                    = $fixedSortable
                Safe                        = [System.Boolean]::Parse($property.Value.SafeForAnonymous)
                Aliases                     = $aliasesValue.Value.Name
                TokenNormalization          = [System.Boolean]::Parse($property.Value.TokenNormalization)
                CompleteMatching            = [System.Boolean]::Parse($property.Value.CompleteMatching)
                LanguageNeutralTokenization = [System.Boolean]::Parse($property.Value.LanguageNeutralWordBreaker)
                FinerQueryTokenization      = [System.Boolean]::Parse($property.Value.ExpandSegments)
                MappedCrawledProperties     = $mappings
                CompanyNameExtraction       = $companyNameExtractionValue
                Ensure                      = 'Present'
                Credential                  = $this.Credential
                ApplicationId               = $this.ApplicationId
                TenantId                    = $this.TenantId
                ApplicationSecret           = $this.ApplicationSecret
                CertificateThumbprint       = $this.CertificateThumbprint
                CertificatePath             = $this.CertificatePath
                CertificatePassword         = $this.CertificatePassword
                ManagedIdentity             = $this.ManagedIdentity
                AccessTokens                = $this.AccessTokens
            })
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

        $null = $this.Connect('PnP')
        $null = $this.Connect('PnP', (Get-MSCloudLoginConnectionProfile -Workload PnP).AdminUrl)

        if ($this.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Removing SPOSearchManagedProperty {$($this.Name)}"
            Remove-PnPSearchConfiguration -Configuration $this.Name -Scope Subscription
            return
        }
        $SearchConfigTemplatePath = Join-Path -Path $this.GetModulePath() `
            -ChildPath './Dependencies/SearchConfigurationSettings.xml' `
            -Resolve
        $SearchConfigXML = [Xml] (Get-Content $SearchConfigTemplatePath -Raw)

        # Get the managed property back if it already exists.
        if ($null -eq $this.ResourceCache['RecentMPExtract'])
        {
            $this.ResourceCache['RecentMPExtract'] = [XML] (Get-PnPSearchConfiguration -Scope Subscription)
        }

        $property = $this.ResourceCache['RecentMPExtract'].SearchConfigurationSettings.SearchSchemaConfigurationSettings.ManagedProperties.dictionary.KeyValueOfstringManagedPropertyInfoy6h3NzC8 `
        | Where-Object -FilterScript { $_.Value.Name -eq $this.Name }
        if ($null -ne $property)
        {
            $currentPID = $property.Value.Pid
        }
        else
        {
            if ($this.Type -notin @('Text', 'YesNo') -or `
                (-not [System.String]::IsNullOrEmpty($this.Refinable) -and $this.Refinable -ne 'No') -or `
                (-not [System.String]::IsNullOrEmpty($this.Sortable) -and $this.Sortable -ne 'No'))
            {
                throw "SharePoint Online only creates managed properties of type Text or YesNo that are neither refinable nor sortable. Use one of the built-in Refinable managed properties with an alias for {$($this.Name)} instead."
            }

            $randomizer = [System.Random]::new()
            $currentPID = $randomizer.Next(1000, 9999)
        }

        $prop = $SearchConfigXml.ChildNodes[0].SearchSchemaConfigurationSettings.ManagedProperties.dictionary
        $newManagedPropertyElement = $SearchConfigXML.CreateElement('d4p1:KeyValueOfstringManagedPropertyInfoy6h3NzC8', `
                'http://schemas.microsoft.com/2003/10/Serialization/Arrays')
        $keyNode = $SearchConfigXML.CreateElement('d4p1:Key', `
                'http://schemas.microsoft.com/2003/10/Serialization/Arrays')
        $keyNode.InnerText = $this.Name
        $newManagedPropertyElement.AppendChild($keyNode) | Out-Null

        $valueNode = $SearchConfigXML.CreateElement('d4p1:Value', `
                'http://schemas.microsoft.com/2003/10/Serialization/Arrays')

        $node = $SearchConfigXML.CreateElement('d3p1:Name', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $this.Name
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:CompleteMatching', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $this.CompleteMatching.ToString().Replace('$', '').ToLower()
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:Context', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $this.FullTextContext.ToString()
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:DeleteDisallowed', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = 'false'
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:Description', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')

        $node.InnerText = $this.Description
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:EnabledForScoping', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = 'false'
        $valueNode.AppendChild($node) | Out-Null

        #region EntiryExtractionBitMap
        $node = $SearchConfigXML.CreateElement('d3p1:EntityExtractorBitMap', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')

        if ($this.CompanyNameExtraction)
        {
            $node.InnerText = '4161'
        }
        else
        {
            $node.InnerText = '0'
        }
        $valueNode.AppendChild($node) | Out-Null
        #endregion

        $node = $SearchConfigXML.CreateElement('d3p1:ExpandSegments', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $this.FinerQueryTokenization.ToString().Replace('$', '').ToLower()
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:FullTextIndex', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $this.FullTextIndex
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:HasMultipleValues', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $this.AllowMultipleValues.ToString().Replace('$', '').ToLower()
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:IndexOptions', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = '0'
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:IsImplicit', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = 'false'
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:IsReadOnly', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = 'false'
        $valueNode.AppendChild($node) | Out-Null

        #region LanguageNeutralWordBreaker
        if ($this.LanguageNeutralTokenization -and $this.CompleteMatching)
        {
            throw 'You cannot have CompleteMatching set to True if LanguageNeutralTokenization is set to True'
        }
        $node = $SearchConfigXML.CreateElement('d3p1:LanguageNeutralWordBreaker', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $this.LanguageNeutralTokenization.ToString().Replace('$', '').ToLower()
        $valueNode.AppendChild($node) | Out-Null
        #endregion

        $node = $SearchConfigXML.CreateElement('d3p1:ManagedType', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $this.Type
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:MappingDisallowed', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = 'false'
        $valueNode.AppendChild($node) | Out-Null

        #region PID
        if ($null -ne $currentPID)
        {
            $node = $SearchConfigXML.CreateElement('d3p1:Pid', `
                    'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
            $node.InnerText = $currentPid
            $valueNode.AppendChild($node) | Out-Null
        }
        #endregion

        $node = $SearchConfigXML.CreateElement('d3p1:Queryable', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $this.Queryable.ToString().Replace('$', '').ToLower()
        $valueNode.AppendChild($node) | Out-Null

        #region Refinable
        $value = $false
        if ($this.Refinable -eq 'Yes')
        {
            $value = $true
        }
        $node = $SearchConfigXML.CreateElement('d3p1:Refinable', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $value.ToString().Replace('$', '').ToLower()
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:RefinerConfiguration', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')

        $subNode = $SearchConfigXML.CreateElement('d3p1:Anchoring', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $subNode.InnerText = 'Auto'
        $node.AppendChild($subNode) | Out-Null

        $subNode = $SearchConfigXML.CreateElement('d3p1:CutoffMaxBuckets', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $subNode.InnerText = '1000'
        $node.AppendChild($subNode) | Out-Null

        $subNode = $SearchConfigXML.CreateElement('d3p1:Divisor', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $subNode.InnerText = '1'
        $node.AppendChild($subNode) | Out-Null

        $subNode = $SearchConfigXML.CreateElement('d3p1:Intervals', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $subNode.InnerText = '4'
        $node.AppendChild($subNode) | Out-Null

        $subNode = $SearchConfigXML.CreateElement('d3p1:Resolution', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $subNode.InnerText = '1'
        $node.AppendChild($subNode) | Out-Null

        $subNode = $SearchConfigXML.CreateElement('d3p1:Type', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $subNode.InnerText = 'Deep'
        $node.AppendChild($subNode) | Out-Null

        $valueNode.AppendChild($node) | Out-Null
        #endregion

        $node = $SearchConfigXML.CreateElement('d3p1:RemoveDuplicates', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = 'true'
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:RespectPriority', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = 'false'
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:Retrievable', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $this.Retrievable.ToString().Replace('$', '').ToLower()
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:SafeForAnonymous', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $this.Safe.ToString().Replace('$', '').ToLower()
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:Searchable', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $this.Searchable.ToString().Replace('$', '').ToLower()
        $valueNode.AppendChild($node) | Out-Null

        #region Sortable
        $value = $false
        if ($this.Sortable -eq 'Yes')
        {
            $value = $true
        }
        $node = $SearchConfigXML.CreateElement('d3p1:Sortable', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $value.ToString().Replace('$', '').ToLower()
        $valueNode.AppendChild($node) | Out-Null
        #endregion

        $node = $SearchConfigXML.CreateElement('d3p1:SortableType', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = 'Enabled'
        $valueNode.AppendChild($node) | Out-Null

        $node = $SearchConfigXML.CreateElement('d3p1:TokenNormalization', `
                'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
        $node.InnerText = $this.TokenNormalization.ToString().Replace('$', '').ToLower()
        $valueNode.AppendChild($node) | Out-Null

        $newManagedPropertyElement.AppendChild($valueNode)
        $prop.AppendChild($newManagedPropertyElement) | Out-Null

        $tempPath = Join-Path -Path $ENV:TEMP `
            -ChildPath ((New-Guid).ToString().Split('-')[0] + '.config')
        $SearchConfigXML.OuterXml | Out-File $tempPath

        # Create the Managed Property if it doesn't already exist
        Write-Verbose -Message "Updating core properties for Search Managed Property {$($this.Name)}"
        Set-PnPSearchConfiguration -Scope 'Subscription' -Path $tempPath -ErrorAction Stop

        #region Aliases
        if ($null -ne $this.Aliases)
        {
            $aliasesArray = $this.Aliases.Split(';')
            if ([System.String]::IsNullOrEmpty($currentPID))
            {
                # Get the managed property back. This is the only way to ensure we have the right PID
                $currentConfigXML = [XML] (Get-PnPSearchConfiguration -Scope Subscription)
                [System.Xml.XmlElement]$property = $currentConfigXML.SearchConfigurationSettings.SearchSchemaConfigurationSettings.ManagedProperties.dictionary.KeyValueOfstringManagedPropertyInfoy6h3NzC8 `
                | Where-Object -FilterScript { $_.Value.Name -eq $this.Name }

                $currentPID = $property.Value.Pid
                Write-Verbose -Message "Found current Pid {$currentPID}"

                $node = $SearchConfigXML.CreateElement('d3p1:Pid', `
                        'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
                $node.InnerText = $currentPID

                # The order in which we list the properties matters. Pid is to appear right after MappingDisallowed.
                $namespaceMgr = New-Object System.Xml.XmlNamespaceManager($SearchConfigXML.NameTable)
                $namespaceMgr.AddNamespace('d3p1', 'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
                $previousNode = $SearchConfigXML.SelectSingleNode('//d3p1:MappingDisallowed', $namespaceMgr)
                $previousNode.ParentNode.InsertAfter($node, $previousNode) | Out-Null
            }

            foreach ($alias in $aliasesArray)
            {
                $mainNode = $SearchConfigXML.CreateElement('d4p1:KeyValueOfstringAliasInfoy6h3NzC8', `
                        'http://schemas.microsoft.com/2003/10/Serialization/Arrays')
                $keyNode = $SearchConfigXML.CreateElement('d4p1:Key', `
                        'http://schemas.microsoft.com/2003/10/Serialization/Arrays')
                $keyNode.InnerText = $alias

                $valueNode = $SearchConfigXML.CreateElement('d4p1:Value', `
                        'http://schemas.microsoft.com/2003/10/Serialization/Arrays')
                $node = $SearchConfigXML.CreateElement('d3p1:Name', `
                        'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
                $node.InnerText = $alias
                $valueNode.AppendChild($node) | Out-Null

                $node = $SearchConfigXML.CreateElement('d3p1:ManagedPid', `
                        'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
                $node.InnerText = $currentPID
                $valueNode.AppendChild($node) | Out-Null

                $node = $SearchConfigXML.CreateElement('d3p1:SchemaId', `
                        'http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration')
                $node.InnerText = '794'
                $valueNode.AppendChild($node) | Out-Null

                $mainNode.AppendChild($keyNode) | Out-Null
                $mainNode.AppendChild($valueNode) | Out-Null
                $SearchConfigXml.ChildNodes[0].SearchSchemaConfigurationSettings.Aliases.dictionary.AppendChild($mainNode) | Out-Null
            }

            $tempPath = Join-Path -Path $ENV:TEMP `
                -ChildPath ((New-Guid).ToString().Split('-')[0] + '.config')
            $SearchConfigXML.OuterXml | Out-File $tempPath
            Write-Verbose -Message 'Configuring SPO Search Schema with the following XML Document'
            Write-Verbose $SearchConfigXML.OuterXML

            # Create the aliases on the Managed Property
            Write-Verbose -Message "Updating Aliases for Search Managed Property {$($this.Name)}"
            Set-PnPSearchConfiguration -Scope Subscription -Path $tempPath
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [System.String] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [System.String] $this.InvokeInPowerShellCore('Export')
        }

        try
        {
            $ConnectionMode = $this.Connect('PnP')

            $ConnectionMode = $this.Connect('PnP', (Get-MSCloudLoginConnectionProfile -Workload PnP).AdminUrl)

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Export')
            #endregion

            $SearchConfig = [Xml] (Get-PnPSearchConfiguration -Scope Subscription -ErrorAction Stop)
            [array]$properties = $SearchConfig.SearchConfigurationSettings.SearchSchemaConfigurationSettings.ManagedProperties.dictionary.KeyValueOfstringManagedPropertyInfoy6h3NzC8
            $this.ResourceCache['RecentMPExtract'] = $SearchConfig
            $this.ResourceCache['exportMode'] = $true

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1

            if ($properties.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($property in $properties)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($properties.Length)] $($property.Value.Name)" -DeferWrite
                $Params = @{
                    Credential            = $this.Credential
                    Name                  = $property.Value.Name
                    Type                  = $property.Value.ManagedType
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
                if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 2)
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
                }
                else
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
                }

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

    hidden [SPOSearchManagedProperty] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOSearchManagedProperty])
        {
            return $Values
        }

        $result = [SPOSearchManagedProperty]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
