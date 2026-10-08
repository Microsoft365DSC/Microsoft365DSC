using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class O365ExternalConnection : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The name of the external connector.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the external connector.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The description of the external connector.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('A collection of application IDs for registered Microsoft Entra apps that are allowed to manage the externalConnection and to index content in the externalConnection.')]
    [System.String[]] $AuthorizedAppIds

    [DscProperty()]
    [System.ComponentModel.Description('Collects configurable settings related to activities involving connector content.')]
    [MSFT_MicrosoftGraphActivitySettings] $ActivitySettings

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the domain category of the content associated with the external connection. This property helps Microsoft Graph optimize relevance, ranking, and semantic understanding by signaling the nature of the ingested content. For example, setting this value correctly ensures better query interpretation and improves Copilot experiences. The possible values are: uncategorized, knowledgeBase, wikis, fileRepository, qna, crm, dashboard, people, media, email, messaging, meetingTranscripts, taskManagement, learningManagement. Optional. The default value is uncategorized.')]
    [ValidateSet('uncategorized', 'knowledgeBase', 'wikis', 'fileRepository', 'qna', 'crm', 'dashboard', 'people', 'media', 'email', 'messaging', 'meetingTranscripts', 'taskManagement', 'learningManagement')]
    [System.String] $ContentCategory

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

    [O365ExternalConnection] Get()
    {
        $instance = $null
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [O365ExternalConnection]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for O365ExternalConnection with Name {$($this.Name)} and Id {$($this.Id)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $instance = Get-MgBetaExternalConnection -ExternalConnectionId $this.Id -ErrorAction SilentlyContinue
                }
                if ($null -eq $instance)
                {
                    $instance = Get-MgBetaExternalConnection -All -ErrorAction Stop | Where-Object -Property Name -EQ $this.Name
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $callerAppId = (Get-MgContext).ClientId
            $AuthorizedAppIdsValue = @()
            foreach ($app in $instance.Configuration.AuthorizedAppIds)
            {
                $appInstance = Get-MgApplication -Filter "AppId eq '$app'" -ErrorAction SilentlyContinue
                if ($null -eq $appInstance)
                {
                    $appInstance = Get-MgServicePrincipal -Filter "AppId eq '$app'" -ErrorAction SilentlyContinue
                }
                if ($null -eq $appInstance)
                {
                    throw "Could not find referenced application or service principal {$app} in the tenant."
                }
                if ($app -eq $callerAppId -and $this.AuthorizedAppIds -notcontains $appInstance.DisplayName)
                {
                    continue
                }
                $AuthorizedAppIdsValue += $appInstance.DisplayName
            }

            $activitySettingsValue = $null
            if ($null -ne $instance.ActivitySettings)
            {
                $resolversValue = @()
                foreach ($resolver in $instance.ActivitySettings.UrlToItemResolvers)
                {
                    $urlMatchInfoValue = $null
                    if ($null -ne $resolver.UrlMatchInfo)
                    {
                        $urlMatchInfoValue = @{
                            BaseUrls   = [System.String[]]$resolver.UrlMatchInfo.BaseUrls
                            UrlPattern = $resolver.UrlMatchInfo.UrlPattern
                        }
                    }
                    $resolversValue += @{
                        ItemId       = $resolver.ItemId
                        Priority     = $resolver.Priority
                        UrlMatchInfo = $urlMatchInfoValue
                    }
                }
                $activitySettingsValue = @{
                    UrlToItemResolvers = [Array]$resolversValue
                }
            }

            $results = @{
                Name                  = $instance.Name
                Id                    = $instance.id
                Description           = $instance.Description
                AuthorizedAppIds      = $AuthorizedAppIdsValue
                ActivitySettings      = $activitySettingsValue
                ContentCategory       = $instance.ContentCategory
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

        Write-Verbose -Message "Setting configuration for O365ExternalConnection with Name {$($this.Name)} and Id {$($this.Id)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $AuthorizedAppIdsValue = @()
        if ($null -ne $this.AuthorizedAppIds)
        {
            foreach ($app in $this.AuthorizedAppIds)
            {
                $appFilter = "DisplayName eq '$($app -replace "'", "''")'"
                $appInstance = Get-MgApplication -Filter $appFilter -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($null -eq $appInstance)
                {
                    $appInstance = Get-MgServicePrincipal -Filter $appFilter -ErrorAction SilentlyContinue | Select-Object -First 1
                }
                if ($null -eq $appInstance)
                {
                    throw "Could not find referenced application or service principal {$app} in the tenant."
                }
                $AuthorizedAppIdsValue += $appInstance.AppId
            }
        }
        $body = @{
            id            = $this.Id
            name          = $this.Name
            description   = $this.Description
            configuration = @{
                authorizedAppIds = $AuthorizedAppIdsValue
            }
        }
        if (-not [System.String]::IsNullOrEmpty($this.ContentCategory))
        {
            $body.Add('contentCategory', $this.ContentCategory)
        }
        if ($null -ne $this.ActivitySettings)
        {
            $resolversBody = @()
            foreach ($resolver in $this.ActivitySettings.UrlToItemResolvers)
            {
                # itemIdResolver is the only concrete type behind the abstract urlToItemResolverBase
                # and Graph rejects an element that does not name it.
                $resolverBody = @{
                    '@odata.type' = '#microsoft.graph.externalConnectors.itemIdResolver'
                    itemId        = $resolver.ItemId
                }
                if ($null -ne $resolver.Priority)
                {
                    $resolverBody.Add('priority', $resolver.Priority)
                }
                if ($null -ne $resolver.UrlMatchInfo)
                {
                    $resolverBody.Add('urlMatchInfo', @{
                            '@odata.type' = 'microsoft.graph.externalConnectors.urlMatchInfo'
                            baseUrls      = [System.Collections.ArrayList]@($resolver.UrlMatchInfo.BaseUrls)
                            urlPattern    = $resolver.UrlMatchInfo.UrlPattern
                        })
                }
                $resolversBody += $resolverBody
            }
            $body.Add('activitySettings', @{
                    urlToItemResolvers = [System.Collections.ArrayList]$resolversBody
                })
        }
        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new external connection {$($this.Name)}"
            New-MgBetaExternalConnection -BodyParameter $body
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating new external connection {$($this.Name)}"
            $body.Remove('Id') | Out-Null
            Update-MgBetaExternalConnection -ExternalConnectionId $currentInstance.Id -BodyParameter $body
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing external connection {$($this.Name)}"
            Remove-MgBetaExternalConnection -ExternalConnectionId $currentInstance.Id
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
            [array] $exportedInstances = Get-MgBetaExternalConnection -ErrorAction Stop

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
                $displayedKey = $config.Id
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Name                  = $config.Name
                    Id                    = $config.Id
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

                if ($null -ne $Results.ActivitySettings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'ActivitySettings'
                            CimInstanceName = 'MicrosoftGraphActivitySettings'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'UrlToItemResolvers'
                            CimInstanceName = 'MicrosoftGraphUrlToItemResolverBase'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'UrlMatchInfo'
                            CimInstanceName = 'MicrosoftGraphUrlMatchInfo'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ActivitySettings `
                        -CIMInstanceName 'MicrosoftGraphActivitySettings' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ActivitySettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ActivitySettings') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('ActivitySettings')
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

    hidden [O365ExternalConnection] AsResult([System.Object] $Values)
    {
        if ($Values -is [O365ExternalConnection])
        {
            return $Values
        }

        $result = [O365ExternalConnection]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphActivitySettings
{
    [DscProperty()]
    [System.ComponentModel.Description('Specifies configurations to identify an externalItem based on a shared URL.')]
    [MSFT_MicrosoftGraphUrlToItemResolverBase[]] $UrlToItemResolvers
}

class MSFT_MicrosoftGraphUrlToItemResolverBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Pattern that specifies how to form the ID of the external item that the URL represents. The named groups from the regular expression in urlPattern within the urlMatchInfo can be referenced by inserting the group name inside curly brackets.')]
    [System.String] $ItemId

    [DscProperty()]
    [System.ComponentModel.Description('The priority which defines the sequence in which the urlToItemResolverBase instances are evaluated.')]
    [System.Nullable[System.Int32]] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('Configurations to match and resolve URL.')]
    [MSFT_MicrosoftGraphUrlMatchInfo] $UrlMatchInfo
}

class MSFT_MicrosoftGraphUrlMatchInfo
{
    [DscProperty()]
    [System.ComponentModel.Description('A list of the URL prefixes that must match URLs to be processed by this URL-to-item-resolver.')]
    [System.String[]] $BaseUrls

    [DscProperty()]
    [System.ComponentModel.Description('A regular expression that will be matched towards the URL that is processed by this URL-to-item-resolver. The ECMAScript specification for regular expressions (ECMA-262) is used for the evaluation. The named groups defined by the regular expression will be used later to extract values from the URL.')]
    [System.String] $UrlPattern
}
