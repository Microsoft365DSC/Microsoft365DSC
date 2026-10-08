using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCInsiderRiskEntityList : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name of the group or setting.')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The setting type.')]
    [System.String] $ListType

    [DscProperty()]
    [System.ComponentModel.Description('Description for the group or setting.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the group or setting.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('List of domains')]
    [MSFT_SCInsiderRiskEntityListDomain[]] $Domains

    [DscProperty()]
    [System.ComponentModel.Description('List of file paths.')]
    [System.String[]] $FilePaths

    [DscProperty()]
    [System.ComponentModel.Description('List of file types.')]
    [System.String[]] $FileTypes

    [DscProperty()]
    [System.ComponentModel.Description('List of keywords.')]
    [System.String[]] $Keywords

    [DscProperty()]
    [System.ComponentModel.Description('List of sensitive information types.')]
    [System.String[]] $SensitiveInformationTypes

    [DscProperty()]
    [System.ComponentModel.Description('List of sites.')]
    [MSFT_SCInsiderRiskEntityListSite[]] $Sites

    [DscProperty()]
    [System.ComponentModel.Description('List of trainable classifiers.')]
    [System.String[]] $TrainableClassifiers

    [DscProperty()]
    [System.ComponentModel.Description('List of keywords for exception.')]
    [System.String[]] $ExceptionKeyworkGroups

    [DscProperty()]
    [System.ComponentModel.Description('List of excluded trainable classifiers.')]
    [System.String[]] $ExcludedClassifierGroups

    [DscProperty()]
    [System.ComponentModel.Description('List of excluded domains.')]
    [System.String[]] $ExcludedDomainGroups

    [DscProperty()]
    [System.ComponentModel.Description('List of excluded file paths.')]
    [System.String[]] $ExcludedFilePathGroups

    [DscProperty()]
    [System.ComponentModel.Description('List of excluded file types.')]
    [System.String[]] $ExcludedFileTypeGroups

    [DscProperty()]
    [System.ComponentModel.Description('List of excluded keywords.')]
    [System.String[]] $ExcludedKeyworkGroups

    [DscProperty()]
    [System.ComponentModel.Description('List of excluded sensitive information types.')]
    [System.String[]] $ExcludedSensitiveInformationTypeGroups

    [DscProperty()]
    [System.ComponentModel.Description('List of excluded sites.')]
    [System.String[]] $ExcludedSiteGroups

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this entity should exist or not.')]
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

    [SCInsiderRiskEntityList] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCInsiderRiskEntityList]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SCInsiderRiskEntityList for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'
            }

            $instance = Invoke-M365DSCCommand -ScriptBlock { Get-InsiderRiskEntityList -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            # CustomDomainLists
            $DmnValues = @()
            if ($instance.ListType -eq 'CustomDomainLists' -or `
                    $instance.Name -eq 'IrmWhitelistDomains')
            {
                foreach ($entity in $instance.Entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $current = [ordered]@{
                        Dmn        = $entity.Dmn
                        isMLSubDmn = $entity.isMLSubDmn
                    }
                    $DmnValues += $current
                }
            }

            # CustomFilePathRegexLists
            $FilePathValues = @()
            if ($instance.ListType -eq 'CustomFilePathRegexLists' -or `
                    $instance.Name -eq 'IrmCustomExWinFilePaths')
            {
                foreach ($entity in $instance.Entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $FilePathValues += $entity.FlPthRgx
                }
            }

            # CustomFileTypeLists
            $FileTypeValues = @()
            if ($instance.ListType -eq 'CustomFileTypeLists')
            {
                foreach ($entity in $instance.Entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $FileTypeValues += $entity.Ext
                }
            }

            # CustomKeywordLists
            $KeywordValues = @()
            if ($instance.ListType -eq 'CustomKeywordLists' -or `
                    $instance.Name -eq 'IrmExcludedKeywords' -or $instance.Name -eq 'IrmNotExcludedKeywords')
            {
                foreach ($entity in $instance.Entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $KeywordValues += $entity.Name
                }
            }

            # CustomSensitiveInformationTypeLists
            $SITValues = @()
            if ($instance.ListType -eq 'CustomSensitiveInformationTypeLists' -or `
                    $instance.Name -eq 'IrmCustomExSensitiveTypes')
            {
                foreach ($entity in $instance.Entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $SITObject = Get-DLPSensitiveInformationType -Identity $entity.GUID
                    $SITValues += $SITObject.Name
                }
            }

            # CustomSiteLists
            $SiteValues = @()
            if ($instance.ListType -eq 'CustomSiteLists' -or `
                    $instance.Name -eq 'IrmExcludedSites')
            {
                foreach ($entity in $instance.Entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $site = [ordered]@{
                        Url  = $entity.Url
                        Name = $entity.Name
                        Guid = $entity.Guid
                    }
                    $SiteValues += $site
                }
            }

            # CustomMLClassifierTypeLists
            $TrainableClassifierValues = @()
            if ($instance.ListType -eq 'CustomMLClassifierTypeLists' -or $instance.Name -eq 'IrmCustomExMLClassifiers')
            {
                foreach ($entity in $instance.Entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $TrainableClassifierValues += $entity.Guid
                }
            }

            # Global Exclusions - Excluded Keyword Groups
            $excludedKeywordGroupValue = @()
            if ($instance.Name -eq 'IrmXSGExcludedKeywords')
            {
                $entities = $instance.Entities
                foreach ($entity in $entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $group = Invoke-M365DSCCommand -ScriptBlock { Get-InsiderRiskEntityList -Identity $entity.GroupId -ErrorAction Stop } -SuppressNotFoundError
                    if ($null -eq $group)
                    {
                        Write-Warning -Message "Could not find group with id $($entity.GroupId) for excluded keyword group in $($this.Name). Skipping group."
                        continue
                    }
                    $excludedKeywordGroupValue += $group.Name
                }
            }

            # Global Exclusions - Exception Keyword Groups
            $exceptionKeywordGroupValue = @()
            if ($instance.Name -eq 'IrmXSGExceptionKeywords')
            {
                $entities = $instance.Entities
                foreach ($entity in $entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $group = Invoke-M365DSCCommand -ScriptBlock { Get-InsiderRiskEntityList -Identity $entity.GroupId -ErrorAction Stop } -SuppressNotFoundError
                    if ($null -eq $group)
                    {
                        Write-Warning -Message "Could not find group with id $($entity.GroupId) for exception keyword group in $($this.Name). Skipping group."
                        continue
                    }

                    $exceptionKeywordGroupValue += $group.Name
                }
            }

            # Global Exclusions - Excluded Classifier Groups
            $excludedClassifierGroupValue = @()
            if ($instance.Name -eq 'IrmXSGMLClassifierTypes')
            {
                $entities = $instance.Entities
                foreach ($entity in $entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $group = Invoke-M365DSCCommand -ScriptBlock { Get-InsiderRiskEntityList -Identity $entity.GroupId -ErrorAction Stop } -SuppressNotFoundError
                    if ($null -eq $group)
                    {
                        Write-Warning -Message "Could not find group with id $($entity.GroupId) for excluded classifier group in $($this.Name). Skipping group."
                        continue
                    }
                    $excludedClassifierGroupValue += $group.Name
                }
            }

            # Global Exclusions - Excluded Domain Groups
            $excludedDomainGroupValue = @()
            if ($instance.Name -eq 'IrmXSGDomains')
            {
                $entities = $instance.Entities
                foreach ($entity in $entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $group = Invoke-M365DSCCommand -ScriptBlock { Get-InsiderRiskEntityList -Identity $entity.GroupId -ErrorAction Stop } -SuppressNotFoundError
                    if ($null -eq $group)
                    {
                        Write-Warning -Message "Could not find group with id $($entity.GroupId) for excluded domain group in $($this.Name). Skipping group."
                        continue
                    }

                    $excludedDomainGroupValue += $group.Name
                }
            }

            # Global Exclusions - Excluded File Path Groups
            $ExcludedFilePathGroupsValue = @()
            if ($instance.Name -eq 'IrmXSGFilePaths')
            {
                $entities = $instance.Entities
                foreach ($entity in $entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $group = Invoke-M365DSCCommand -ScriptBlock { Get-InsiderRiskEntityList -Identity $entity.GroupId -ErrorAction Stop } -SuppressNotFoundError
                    if ($null -eq $group)
                    {
                        Write-Warning -Message "Could not find group with id $($entity.GroupId) for excluded file path group in $($this.Name). Skipping group."
                        continue
                    }
                    $ExcludedFilePathGroupsValue += $group.Name
                }
            }

            # Global Exclusions - Excluded Site Groups
            $excludedSiteGroupValue = @()
            if ($instance.Name -eq 'IrmXSGSites')
            {
                $entities = $instance.Entities
                foreach ($entity in $entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $group = Invoke-M365DSCCommand -ScriptBlock { Get-InsiderRiskEntityList -Identity $entity.GroupId -ErrorAction Stop } -SuppressNotFoundError
                    if ($null -eq $group)
                    {
                        Write-Warning -Message "Could not find group with id $($entity.GroupId) for excluded site group in $($this.Name). Skipping group."
                        continue
                    }
                    $excludedSiteGroupValue += $group.Name
                }
            }

            # Global Exclusions - Excluded Sensitive Info Type Groups
            $excludedSITGroupValue = @()
            if ($instance.Name -eq 'IrmXSGSensitiveInfoTypes')
            {
                $entities = $instance.Entities
                foreach ($entity in $entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $group = Invoke-M365DSCCommand -ScriptBlock { Get-InsiderRiskEntityList -Identity $entity.GroupId -ErrorAction Stop } -SuppressNotFoundError
                    if ($null -eq $group)
                    {
                        Write-Warning -Message "Could not find group with id $($entity.GroupId) for excluded sensitive info type group in $($this.Name). Skipping group."
                        continue
                    }
                    $excludedSITGroupValue += $group.Name
                }
            }

            # Global Exclusions - Excluded File Type Groups
            $excludedFileTypeGroupValue = @()
            if ($instance.Name -eq 'IrmXSGFiletypes')
            {
                $entities = $instance.Entities
                foreach ($entity in $entities)
                {
                    $entity = ConvertFrom-Json $entity
                    $group = Invoke-M365DSCCommand -ScriptBlock { Get-InsiderRiskEntityList -Identity $entity.GroupId -ErrorAction Stop } -SuppressNotFoundError
                    if ($null -eq $group)
                    {
                        Write-Warning -Message "Could not find group with id $($entity.GroupId) for excluded file type group in $($this.Name). Skipping group."
                        continue
                    }

                    $excludedFileTypeGroupValue += $group.Name
                }
            }

            $results = @{
                DisplayName                            = $instance.DisplayName
                Name                                   = $instance.Name
                Description                            = $instance.Description
                ListType                               = $instance.ListType
                Domains                                = $DmnValues
                FilePaths                              = $FilePathValues
                FileTypes                              = $FileTypeValues
                Keywords                               = $KeywordValues
                SensitiveInformationTypes              = $SITValues
                Sites                                  = $SiteValues
                TrainableClassifiers                   = $TrainableClassifierValues
                ExcludedKeyworkGroups                  = $excludedKeywordGroupValue
                ExceptionKeyworkGroups                 = $exceptionKeywordGroupValue
                ExcludedClassifierGroups               = $excludedClassifierGroupValue
                ExcludedDomainGroups                   = $excludedDomainGroupValue
                ExcludedFilePathGroups                 = $ExcludedFilePathGroupsValue
                ExcludedSiteGroups                     = $excludedSiteGroupValue
                ExcludedSensitiveInformationTypeGroups = $excludedSITGroupValue
                ExcludedFileTypeGroups                 = $excludedFileTypeGroupValue
                Ensure                                 = 'Present'
                Credential                             = $this.Credential
                ApplicationId                          = $this.ApplicationId
                TenantId                               = $this.TenantId
                CertificateThumbprint                  = $this.CertificateThumbprint
                CertificatePath                        = $this.CertificatePath
                CertificatePassword                    = $this.CertificatePassword
                ManagedIdentity                        = $this.ManagedIdentity
                AccessTokens                           = $this.AccessTokens
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
        $classifier = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of SCInsiderRiskEntityList for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            # Create a new Domain Group
            if ($this.ListType -eq 'CustomDomainLists')
            {
                $value = @()
                foreach ($domain in $this.Domains)
                {
                    $value += "{`"Dmn`":`"$($domain.Dmn)`",`"isMLSubDmn`":$($domain.isMLSubDmn.ToString().ToLower())}"
                }
                Write-Verbose -Message "Creating new Domain Group {$($this.Name)} with values {$($value -join ',')}"
                New-InsiderRiskEntityList -Type 'CustomDomainLists' `
                    -Name $this.Name `
                    -DisplayName $this.DisplayName `
                    -Description $this.Description `
                    -Entities $value | Out-Null
            }
            elseif ($this.ListType -eq 'CustomFilePathRegexLists')
            {
                $value = @()
                foreach ($filePath in $this.FilePaths)
                {
                    $value += "{`"FlPthRgx`":`"$($filePath.Replace('\', '\\'))`",`"isSrc`":true,`"isTrgt`":true}"
                }
                Write-Verbose -Message "Creating new FilePath Group {$($this.Name)} with values {$($value -join ',')}"
                New-InsiderRiskEntityList -Type 'CustomFilePathRegexLists' `
                    -Name $this.Name `
                    -DisplayName $this.DisplayName `
                    -Description $this.Description `
                    -Entities $value | Out-Null
            }
            elseif ($this.ListType -eq 'CustomFileTypeLists')
            {
                $value = @()
                foreach ($fileType in $this.FileTypes)
                {
                    $value += "{`"Ext`":`"$fileType`"}"
                }
                Write-Verbose -Message "Creating new FileType Group {$($this.Name)} with values {$($value -join ',')}"
                New-InsiderRiskEntityList -Type 'CustomFileTypeLists' `
                    -Name $this.Name `
                    -DisplayName $this.DisplayName `
                    -Description $this.Description `
                    -Entities $value | Out-Null
            }
            elseif ($this.ListType -eq 'CustomKeywordLists')
            {
                $value = @()
                foreach ($keyword in $this.Keywords)
                {
                    $value += "{`"Name`":`"$keyword`"}"
                }
                Write-Verbose -Message "Creating new Keyword Group {$($this.Name)} with values {$($value -join ',')}"
                New-InsiderRiskEntityList -Type 'CustomKeywordLists' `
                    -Name $this.Name `
                    -DisplayName $this.DisplayName `
                    -Description $this.Description `
                    -Entities $value | Out-Null
            }
            elseif ($this.ListType -eq 'CustomSensitiveInformationTypeLists')
            {
                $value = @()
                foreach ($sit in $this.SensitiveInformationTypes)
                {
                    $value += "{`"Guid`":`"$sit`"}"
                }
                Write-Verbose -Message "Creating new SIT Group {$($this.Name)} with values {$($value -join ',')}"
                New-InsiderRiskEntityList -Type 'CustomSensitiveInformationTypeLists' `
                    -Name $this.Name `
                    -DisplayName $this.DisplayName `
                    -Description $this.Description `
                    -Entities $value | Out-Null
            }
            elseif ($this.ListType -eq 'CustomSiteLists')
            {
                $value = @()
                foreach ($site in $this.Sites)
                {
                    $value += "{`"Url`":`"$($site.Url.ToString())`",`"Name`":`"$($site.Name.ToString())`",`"Guid`":`"$((New-Guid).ToString())`"}"
                }
                Write-Verbose -Message "Creating new Site Group {$($this.Name)} with values {$($value)}"
                New-InsiderRiskEntityList -Type 'CustomSiteLists' `
                    -Name $this.Name `
                    -DisplayName $this.DisplayName `
                    -Description $this.Description `
                    -Entities $value | Out-Null
            }
            elseif ($this.ListType -eq 'CustomMLClassifierTypeLists')
            {
                $value = @()
                foreach ($clasifier in $this.TrainableClassifiers)
                {
                    $value += "{`"Guid`":`"$($classifier)`"}"
                }
                Write-Verbose -Message "Creating new Trainable classifier Group {$($this.Name)} with values {$($value)}"
                New-InsiderRiskEntityList -Type 'CustomMLClassifierTypeLists' `
                    -Name $this.Name `
                    -DisplayName $this.DisplayName `
                    -Description $this.Description `
                    -Entities $value | Out-Null
            }
            else
            {
                throw "Couldn't not identify operation to perform on {$($this.Name)}"
            }
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            # Update Domain Group
            if ($this.ListType -eq 'CustomDomainLists' -or $this.Name -eq 'IrmWhitelistDomains')
            {
                $entitiesToAdd = @()
                $entitiesToRemove = @()
                $differences = Compare-Object -ReferenceObject $currentInstance.Domains.Dmn -DifferenceObject $this.Domains.Dmn
                foreach ($diff in $differences)
                {
                    if ($diff.SideIndicator -eq '=>')
                    {
                        $instance = $this.Domains | Where-Object -FilterScript { $_.Dmn -eq $diff.InputObject }
                        $entitiesToAdd += "{`"Dmn`":`"$($instance.Dmn)`",`"isMLSubDmn`":$($instance.isMLSubDmn.ToString().ToLower())}"
                    }
                    else
                    {
                        $instance = $currentInstance.Domains | Where-Object -FilterScript { $_.Dmn -eq $diff.InputObject }
                        $entitiesToRemove += "{`"Dmn`":`"$($instance.Dmn)`",`"isMLSubDmn`":$($instance.isMLSubDmn.ToString().ToLower())}"
                    }
                }

                Write-Verbose -Message "Updating Domain Group {$($this.Name)}"
                Write-Verbose -Message "Adding entities: $($entitiesToAdd -join ',')"
                Write-Verbose -Message "Removing entities: $($entitiesToRemove -join ',')"

                Set-InsiderRiskEntityList -Identity $this.Name `
                    -DisplayName $this.DisplayName `
                    -Description $this.Description `
                    -AddEntities $entitiesToAdd `
                    -RemoveEntities $entitiesToRemove | Out-Null
            }
            # Update File Path Group
            elseif ($this.ListType -eq 'CustomFilePathRegexLists' -or $this.Name -eq 'IrmCustomExWinFilePaths' -or `
                    $this.Name -eq 'IrmDsbldSysExWinFilePaths')
            {
                $entitiesToAdd = @()
                $entitiesToRemove = @()
                $differences = Compare-Object -ReferenceObject $currentInstance.FilePaths -DifferenceObject $this.FilePaths
                foreach ($diff in $differences)
                {
                    if ($diff.SideIndicator -eq '=>')
                    {
                        $entitiesToAdd += "{`"FlPthRgx`":`"$($diff.InputObject.Replace('\', '\\'))`",`"isSrc`":true,`"isTrgt`":true}"
                    }
                    else
                    {
                        $entitiesToRemove += "{`"FlPthRgx`":`"$($diff.InputObject.Replace('\', '\\'))`",`"isSrc`":true,`"isTrgt`":true}"
                    }
                }

                Write-Verbose -Message "Updating File Path Group {$($this.Name)}"
                Write-Verbose -Message "Adding entities: $($entitiesToAdd -join ',')"
                Write-Verbose -Message "Removing entities: $($entitiesToRemove -join ',')"

                Set-InsiderRiskEntityList -Identity $this.Name `
                    -DisplayName $this.DisplayName `
                    -Description $this.Description `
                    -AddEntities $entitiesToAdd `
                    -RemoveEntities $entitiesToRemove | Out-Null
            }
            # Update File Type Group
            elseif ($this.ListType -eq 'CustomFileTypeLists')
            {
                $entitiesToAdd = @()
                $entitiesToRemove = @()
                $differences = Compare-Object -ReferenceObject $currentInstance.FileTypes -DifferenceObject $this.FileTypes
                foreach ($diff in $differences)
                {
                    if ($diff.SideIndicator -eq '=>')
                    {
                        $entitiesToAdd += "{`"Ext`":`"$($diff.InputObject)`"}"
                    }
                    else
                    {
                        $entitiesToRemove += "{`"Ext`":`"$($diff.InputObject)`"}"
                    }
                }

                Write-Verbose -Message "Updating File Type Group {$($this.Name)}"
                Write-Verbose -Message "Adding entities: $($entitiesToAdd -join ',')"
                Write-Verbose -Message "Removing entities: $($entitiesToRemove -join ',')"

                Set-InsiderRiskEntityList -Identity $this.Name `
                    -DisplayName $this.DisplayName `
                    -Description $this.Description `
                    -AddEntities $entitiesToAdd `
                    -RemoveEntities $entitiesToRemove | Out-Null
            }
            # Update Keywords Group
            elseif ($this.ListType -eq 'CustomKeywordLists' -or $this.Name -eq 'IrmExcludedKeywords' -or $this.Name -eq 'IrmNotExcludedKeywords')
            {
                $entitiesToAdd = @()
                $entitiesToRemove = @()
                $differences = Compare-Object -ReferenceObject $currentInstance.Keywords -DifferenceObject $this.Keywords
                foreach ($diff in $differences)
                {
                    if ($diff.SideIndicator -eq '=>')
                    {
                        $entitiesToAdd += "{`"Name`":`"$($diff.InputObject)`"}"
                    }
                    else
                    {
                        $entitiesToRemove += "{`"Name`":`"$($diff.InputObject)`"}"
                    }
                }

                Write-Verbose -Message "Updating Keyword Group {$($this.Name)}"
                Write-Verbose -Message "Adding entities: $($entitiesToAdd -join ',')"
                Write-Verbose -Message "Removing entities: $($entitiesToRemove -join ',')"

                Set-InsiderRiskEntityList -Identity $this.Name `
                    -DisplayName $this.DisplayName `
                    -Description $this.Description `
                    -AddEntities $entitiesToAdd `
                    -RemoveEntities $entitiesToRemove | Out-Null
            }
            # Update SIT Group
            elseif ($this.ListType -eq 'CustomSensitiveInformationTypeLists' -or $this.Name -eq 'IrmCustomExSensitiveTypes' -or `
                    $this.Name -eq 'IrmDsbldSysExSensitiveTypes')
            {
                $entitiesToAdd = @()
                $entitiesToRemove = @()
                $differences = Compare-Object -ReferenceObject $currentInstance.SensitiveInformationTypes -DifferenceObject $this.SensitiveInformationTypes
                foreach ($diff in $differences)
                {
                    if ($diff.SideIndicator -eq '=>')
                    {
                        $entitiesToAdd += "{`"Guid`":`"$($diff.InputObject)`"}"
                    }
                    else
                    {
                        $entitiesToRemove += "{`"Guid`":`"$($diff.InputObject)`"}"
                    }
                }

                Write-Verbose -Message "Updating SIT Group {$($this.Name)}"
                Write-Verbose -Message "Adding entities: $($entitiesToAdd -join ',')"
                Write-Verbose -Message "Removing entities: $($entitiesToRemove -join ',')"

                Set-InsiderRiskEntityList -Identity $this.Name `
                    -DisplayName $this.DisplayName `
                    -Description $this.Description `
                    -AddEntities $entitiesToAdd `
                    -RemoveEntities $entitiesToRemove | Out-Null
            }
            # Update Sites Group
            elseif ($this.ListType -eq 'CustomSiteLists' -or $this.Name -eq 'IrmExcludedSites')
            {
                Write-Verbose -Message 'Calculating the difference in the Site list.'
                $entitiesToAdd = @()
                $entitiesToRemove = @()
                $differences = Compare-Object -ReferenceObject $currentInstance.Sites.Url -DifferenceObject $this.Sites.Url
                foreach ($diff in $differences)
                {
                    if ($diff.SideIndicator -eq '=>')
                    {
                        $entry = $this.Sites | Where-Object -FilterScript { $_.Url -eq $diff.InputObject }
                        $guid = $entry.Guid
                        if ([System.String]::IsNullOrEmpty($guid))
                        {
                            $guid = (New-Guid).ToString()
                        }
                        $entitiesToAdd += "{`"Url`":`"$($entry.Url)`",`"Name`":`"$($entry.Name)`",`"Guid`":`"$($guid)`"}"
                    }
                    else
                    {
                        $entry = $currentInstance.Sites | Where-Object -FilterScript { $_.Url -eq $diff.InputObject }
                        $entitiesToRemove += "{`"Url`":`"$($entry.Url)`",`"Name`":`"$($entry.Name)`",`"Guid`":`"$($entry.Guid)`"}"
                    }
                }

                Write-Verbose -Message "Updating Sites Group {$($this.Name)}"
                Write-Verbose -Message "Adding entities: $($entitiesToAdd -join ',')"
                Write-Verbose -Message "Removing entities: $($entitiesToRemove -join ',')"

                Set-InsiderRiskEntityList -Identity $this.Name `
                    -DisplayName $this.DisplayName `
                    -Description $this.Description `
                    -AddEntities $entitiesToAdd `
                    -RemoveEntities $entitiesToRemove | Out-Null
            }
            # Update Trainable Classifiers Group
            elseif ($this.ListType -eq 'CustomMLClassifierTypeLists' -or $this.Name -eq 'IrmCustomExMLClassifiers' -or `
                    $this.Name -eq 'IrmDsbldSysExMLClassifiers')
            {
                $entitiesToAdd = @()
                $entitiesToRemove = @()
                $differences = Compare-Object -ReferenceObject $currentInstance.Sites.Url -DifferenceObject $this.Sites.Url
                foreach ($diff in $differences)
                {
                    if ($diff.SideIndicator -eq '=>')
                    {
                        $entitiesToAdd += "{`"Guid`":`"$($diff.InputObject)`"}"
                    }
                    else
                    {
                        $entitiesToRemove += "{`"Guid`":`"$($diff.InputObject)`"}"
                    }
                }

                Write-Verbose -Message "Updating Sites Group {$($this.Name)}"
                Write-Verbose -Message "Adding entities: $($entitiesToAdd -join ',')"
                Write-Verbose -Message "Removing entities: $($entitiesToRemove -join ',')"

                Set-InsiderRiskEntityList -Identity $this.Name `
                    -DisplayName $this.DisplayName `
                    -Description $this.Description `
                    -AddEntities $entitiesToAdd `
                    -RemoveEntities $entitiesToRemove | Out-Null
            }

            <################## Group Exclusions #############>
            if ($null -ne $this.ExcludedDomainGroups -and $this.ExcludedDomainGroups.Length -gt 0)
            {
                $this.SetInsiderRiskExclusionGroup($currentInstance.ExcludedDomainGroups, $this.ExcludedDomainGroups, 'IrmXSGDomains')
            }
            elseif ($null -ne $this.ExcludedFilePathGroups -and $this.ExcludedFilePathGroups.Length -gt 0)
            {
                $this.SetInsiderRiskExclusionGroup($currentInstance.ExcludedFilePathGroups, $this.ExcludedFilePathGroups, 'IrmXSGFilePaths')
            }
            elseif ($null -ne $this.ExcludedFileTypeGroups -and $this.ExcludedFileTypeGroups.Length -gt 0)
            {
                $this.SetInsiderRiskExclusionGroup($currentInstance.ExcludedFileTypeGroups, $this.ExcludedFileTypeGroups, 'IrmXSGFiletypes')
            }
            elseif ($null -ne $this.ExceptionKeyworkGroups -and $this.ExceptionKeyworkGroups.Length -gt 0)
            {
                $this.SetInsiderRiskExclusionGroup($currentInstance.ExceptionKeyworkGroups, $this.ExceptionKeyworkGroups, 'IrmXSGExceptionKeywords')
            }
            elseif ($null -ne $this.ExcludedKeyworkGroups -and $this.ExcludedKeyworkGroups.Length -gt 0)
            {
                $this.SetInsiderRiskExclusionGroup($currentInstance.ExcludedKeyworkGroups, $this.ExcludedKeyworkGroups, 'IrmXSGExcludedKeywords')
            }
            elseif ($null -ne $this.ExcludedSensitiveInformationTypeGroups -and $this.ExcludedSensitiveInformationTypeGroups.Length -gt 0)
            {
                $this.SetInsiderRiskExclusionGroup($currentInstance.ExcludedSensitiveInformationTypeGroups, $this.ExcludedSensitiveInformationTypeGroups, 'IrmXSGSensitiveInfoTypes')
            }
            elseif ($null -ne $this.ExcludedSiteGroups -and $this.ExcludedSiteGroups.Length -gt 0)
            {
                $this.SetInsiderRiskExclusionGroup($currentInstance.ExcludedSiteGroups, $this.ExcludedSiteGroups, 'IrmXSGSites')
            }
            elseif ($null -ne $this.ExcludedClassifierGroups -and $this.ExcludedClassifierGroups.Length -gt 0)
            {
                $this.SetInsiderRiskExclusionGroup($currentInstance.ExcludedClassifierGroups, $this.ExcludedClassifierGroups, 'IrmXSGMLClassifierTypes')
            }
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing group {$($this.Name)}"
            Remove-InsiderRiskEntityList -Identity $this.Name -ForceDeletion
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
            [array] $exportedInstances = @()
            $availableTypes = @('HveLists', 'DomainLists', 'CriticalAssetLists', 'WindowsFilePathRegexLists', 'SensitiveTypeLists', 'SiteLists', 'KeywordLists', `
                    'CustomDomainLists', 'CustomSiteLists', 'CustomKeywordLists', 'CustomFileTypeLists', 'CustomFilePathRegexLists', `
                    'CustomSensitiveInformationTypeLists', 'CustomMLClassifierTypeLists', 'GlobalExclusionSGMapping', 'DlpPolicyLists')

            # Retrieve entries for each type
            foreach ($listType in $availableTypes)
            {
                $exportedInstances += Get-InsiderRiskEntityList -Type $listType -ErrorAction Stop
            }

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }
                $displayedKey = $config.ListType + ' - ' + $config.Name
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    DisplayName           = $config.DisplayName
                    Name                  = $config.Name
                    ListType              = $config.ListType
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                if ($null -ne $Results.Domains -and $Results.Domains.Length -gt 0 -and `
                    ($Results.ListType -eq 'CustomDomainLists' -or $Results.ListType -eq 'DomainLists'))
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Domains `
                        -CIMInstanceName 'SCInsiderRiskEntityListDomain'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Domains = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Domains') | Out-Null
                    }
                }

                if ($null -ne $Results.Sites -and $Results.Sites.Length -gt 0 -and `
                    ($Results.ListType -eq 'CustomSiteLists' -or $Results.ListType -eq 'SiteLists'))
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Sites `
                        -CIMInstanceName 'SCInsiderRiskEntityListSite'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Sites = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Sites') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Domains', 'Sites')

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

    hidden [void] SetInsiderRiskExclusionGroup([System.String[]] $CurrentValues, [System.String[]] $DesiredValues, [System.String] $Name)
    {
        $entitiesToAdd = @()
        $entitiesToRemove = @()
        $differences = Compare-Object -ReferenceObject $CurrentValues -DifferenceObject $DesiredValues
        foreach ($diff in $differences)
        {
            if ($diff.SideIndicator -eq '=>')
            {
                $entitiesToAdd += "{`"GroupId`":`"$($diff.InputObject)`"}"
            }
            else
            {
                $entitiesToRemove += "{`"GroupId`":`"$($diff.InputObject)`"}"
            }
        }

        Write-Verbose -Message "Updating Group Exclusions for {$Name}"
        Write-Verbose -Message "Adding entities: $($entitiesToAdd -join ',')"
        Write-Verbose -Message "Removing entities: $($entitiesToRemove -join ',')"

        Set-InsiderRiskEntityList -Identity $Name `
            -AddEntities $entitiesToAdd `
            -RemoveEntities $entitiesToRemove | Out-Null
    }

    hidden [SCInsiderRiskEntityList] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCInsiderRiskEntityList])
        {
            return $Values
        }

        $result = [SCInsiderRiskEntityList]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_SCInsiderRiskEntityListDomain
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Domain name.')]
    [System.String] $Dmn

    [DscProperty()]
    [System.ComponentModel.Description('Defines if the entry should include multi-level subdomains or not.')]
    [System.Nullable[System.Boolean]] $isMLSubDmn
}

class MSFT_SCInsiderRiskEntityListSite
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Url of the site.')]
    [System.String] $Url

    [DscProperty()]
    [System.ComponentModel.Description('Name of the site.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Unique identifier of the site.')]
    [System.String] $Guid
}
