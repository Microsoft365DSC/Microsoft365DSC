using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADGSAPrivateAccessApplication : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the Private Access application.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The type of private application.')]
    [ValidateSet('nonwebapp', 'quickaccessapp')]
    [System.String] $ApplicationType

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the application is accessible via the Zero Trust Network Access client.')]
    [System.Nullable[System.Boolean]] $IsAccessibleViaZTNAClient

    [DscProperty()]
    [System.ComponentModel.Description('The name of the connector group assigned to this application.')]
    [System.String] $ConnectorGroupName

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether private DNS resolution is enabled. Applicable to Quick Access apps only.')]
    [System.Nullable[System.Boolean]] $IsDnsResolutionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('List of application segments defining the private network destinations.')]
    [MSFT_AADGSAPrivateAccessApplicationSegment[]] $Segments

    [DscProperty()]
    [System.ComponentModel.Description('The object ID of the underlying Azure AD application. Used for efficient lookups after initial creation.')]
    [System.String] $ObjectId

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the workload''s Admin.')]
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
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword.')]
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

    hidden static [System.String] $PrivateAccessTemplateId = '8adf8e6e-67b2-4cf2-a259-e3dc5476c621'

    [AADGSAPrivateAccessApplication] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADGSAPrivateAccessApplication]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AAD GSA Private Access Application {$($this.DisplayName)}"

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            Confirm-M365DSCDependencies

            $this.AddTelemetry('Get')

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $getValue = $null
            if (-not $this.ExportedInstance -or $this.ExportedInstance.displayName -ne $this.DisplayName)
            {
                $baseUrl = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl

                if (-not [System.String]::IsNullOrEmpty($this.ObjectId))
                {
                    try
                    {
                        # onPremisesPublishing is not returned on a bare GET and must be explicitly selected.
                        $getValue = Invoke-MgGraphRequest -Method GET `
                            -Uri ($baseUrl + "beta/applications/$($this.ObjectId)?`$select=id,appId,displayName,onPremisesPublishing") `
                            -ErrorAction Stop
                    }
                    catch
                    {
                        # Invoke-MgGraphRequest throws a terminating error on 404 even with -ErrorAction SilentlyContinue, so fall back to the DisplayName lookup below.
                        $getValue = $null
                    }
                }

                if ($null -eq $getValue)
                {
                    $filterQuery = "applicationTemplateId eq '$([AADGSAPrivateAccessApplication]::PrivateAccessTemplateId)' and displayName eq '$($this.DisplayName -replace "'", "''")'"
                    try
                    {
                        $response = Invoke-MgGraphRequest -Method GET `
                            -Uri ($baseUrl + "beta/applications?`$filter=$filterQuery&`$select=id,appId,displayName,onPremisesPublishing") `
                            -ErrorAction Stop
                        if ($null -ne $response -and $response.value.Count -gt 0)
                        {
                            $getValue = $response.value[0]
                        }
                    }
                    catch
                    {
                        $getValue = $null
                    }
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find AAD GSA Private Access Application {$($this.DisplayName)}"
                return $this.AsResult($nullResult)
            }

            $appId = $getValue.id
            $baseUrl = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl
            $onPremPub = $getValue.onPremisesPublishing

            $resolvedConnectorGroupName = $null
            try
            {
                # An application with no connector group assigned returns a 404 here, which is expected.
                $connectorGroupResponse = Invoke-MgGraphRequest -Method GET `
                    -Uri ($baseUrl + "beta/applications/$appId/connectorGroup") `
                    -ErrorAction Stop
                if ($null -ne $connectorGroupResponse -and -not [System.String]::IsNullOrEmpty($connectorGroupResponse.name))
                {
                    $resolvedConnectorGroupName = $connectorGroupResponse.name
                }
            }
            catch
            {
                $resolvedConnectorGroupName = $null
            }

            $complexSegments = @()
            $segmentsResponse = $null
            try
            {
                $segmentsResponse = Invoke-MgGraphRequest -Method GET `
                    -Uri ($baseUrl + "beta/applications/$appId/onPremisesPublishing/segmentsConfiguration/microsoft.graph.ipSegmentConfiguration/applicationSegments") `
                    -ErrorAction Stop
            }
            catch
            {
                $segmentsResponse = $null
            }
            if ($null -ne $segmentsResponse -and $null -ne $segmentsResponse.value)
            {
                foreach ($seg in $segmentsResponse.value)
                {
                    $complexSegments += @{
                        Id              = $seg.id
                        DestinationHost = $seg.destinationHost
                        DestinationType = [AADGSAPrivateAccessApplication]::ConvertFromDestinationTypeGraphValue($seg.destinationType)
                        Ports           = [System.String[]]$seg.ports
                        Protocol        = $seg.protocol
                    }
                }
            }

            $results = @{
                DisplayName               = $getValue.displayName
                ApplicationType           = $onPremPub.applicationType
                IsAccessibleViaZTNAClient = $onPremPub.isAccessibleViaZTNAClient
                ConnectorGroupName        = $resolvedConnectorGroupName
                IsDnsResolutionEnabled    = $onPremPub.isDnsResolutionEnabled
                Segments                  = [Array] $complexSegments
                ObjectId                  = $appId
                Ensure                    = 'Present'
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

        Write-Verbose -Message "Setting configuration of AAD GSA Private Access Application {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('MicrosoftGraph')

        $currentInstance = $this.Get().ToHashtable()
        $baseUrl = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating AAD GSA Private Access Application {$($this.DisplayName)}"

            $instantiateBody = @{
                displayName = $this.DisplayName
            }
            $newApp = Invoke-MgGraphRequest -Method POST `
                -Uri ($baseUrl + "beta/applicationTemplates/$([AADGSAPrivateAccessApplication]::PrivateAccessTemplateId)/instantiate") `
                -Body $instantiateBody

            # The beta instantiate response exposes the application's id as 'objectId', not 'id' like v1.0 does.
            $appId = $newApp.application.objectId
            if ([System.String]::IsNullOrEmpty($appId))
            {
                $appId = $newApp.application.id
            }

            $onPremBody = @{
                applicationType           = $this.ApplicationType
                isAccessibleViaZTNAClient = $this.IsAccessibleViaZTNAClient
                trafficRoutingMethod      = 'none'
            }
            $null = $this.InvokeGraphRequestWithRetry('PATCH', ($baseUrl + "beta/applications/$appId/onPremisesPublishing"), $onPremBody, ($baseUrl + "beta/applications/$appId"))

            if (-not [System.String]::IsNullOrEmpty($this.ConnectorGroupName))
            {
                $this.SetConnectorGroup($appId, $this.ConnectorGroupName, $baseUrl)
            }

            if ($null -ne $this.Segments -and $this.Segments.Count -gt 0)
            {
                foreach ($segment in $this.Segments)
                {
                    $this.AddSegment($appId, $segment, $baseUrl)
                }
            }

            if ($this.IsDnsResolutionEnabled)
            {
                $dnsBody = @{
                    isDnsResolutionEnabled = $true
                }
                $null = $this.InvokeGraphRequestWithRetry('PATCH', ($baseUrl + "beta/applications/$appId/onPremisesPublishing"), $dnsBody, $null)
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $appId = $currentInstance.ObjectId
            Write-Verbose -Message "Updating AAD GSA Private Access Application {$($this.DisplayName)} with Id {$appId}"

            $onPremBody = @{}
            $onPremUpdated = $false

            if ($this.GetBoundParameters().ContainsKey('ApplicationType') -and $this.ApplicationType -ne $currentInstance.ApplicationType)
            {
                $onPremBody.applicationType = $this.ApplicationType
                $onPremUpdated = $true
            }
            if ($this.GetBoundParameters().ContainsKey('IsAccessibleViaZTNAClient') -and $this.IsAccessibleViaZTNAClient -ne $currentInstance.IsAccessibleViaZTNAClient)
            {
                $onPremBody.isAccessibleViaZTNAClient = $this.IsAccessibleViaZTNAClient
                $onPremUpdated = $true
            }
            if ($this.GetBoundParameters().ContainsKey('IsDnsResolutionEnabled') -and $this.IsDnsResolutionEnabled -ne $currentInstance.IsDnsResolutionEnabled)
            {
                $onPremBody.isDnsResolutionEnabled = $this.IsDnsResolutionEnabled
                $onPremUpdated = $true
            }

            if ($onPremUpdated)
            {
                $null = $this.InvokeGraphRequestWithRetry('PATCH', ($baseUrl + "beta/applications/$appId/onPremisesPublishing"), $onPremBody, $null)
            }

            if ($this.GetBoundParameters().ContainsKey('ConnectorGroupName') -and $this.ConnectorGroupName -ne $currentInstance.ConnectorGroupName)
            {
                $this.SetConnectorGroup($appId, $this.ConnectorGroupName, $baseUrl)
            }

            if ($this.GetBoundParameters().ContainsKey('Segments'))
            {
                $currentSegments = @()
                if ($null -ne $currentInstance.Segments)
                {
                    $currentSegments = $currentInstance.Segments
                }
                $this.SyncSegments($appId, $this.Segments, $currentSegments, $baseUrl)
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            $appId = $currentInstance.ObjectId
            Write-Verbose -Message "Removing AAD GSA Private Access Application {$($this.DisplayName)} with Id {$appId}"
            Invoke-MgGraphRequest -Method DELETE `
                -Uri ($baseUrl + "v1.0/applications/$appId") | Out-Null
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            CompareRules = @(
                @{ Type = 'IgnoreNested'; Paths = @('Segments[].Id') }
            )
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
            $baseUrl = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl
            $filterQuery = "applicationTemplateId eq '$([AADGSAPrivateAccessApplication]::PrivateAccessTemplateId)'"
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $filterQuery = "$filterQuery and $($this.Filter)"
            }
            # Graph rejects $select combined with $filter for onPremisesPublishing on this collection, so the per-item GET in Get() must be used to retrieve it.
            $response = Invoke-MgGraphRequest -Method GET `
                -Uri ($baseUrl + "beta/applications?`$filter=$filterQuery") `
                -ErrorAction Stop
            [array] $exportedInstances = $response.value

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

                $displayedKey = $config.displayName
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $Params = @{
                    DisplayName = $config.displayName
                }

                # $config from the list query lacks onPremisesPublishing (not selectable on this collection), so Get() always performs its own fresh, correctly-selected GET for this resource.
                $Results = $this.GetForExport($Params)

                if ($null -ne $Results.Segments -and $Results.Segments.Count -gt 0)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Segments `
                        -CIMInstanceName 'AADGSAPrivateAccessApplicationSegment'

                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Segments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Segments') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Segments')

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

    hidden [System.Object] InvokeGraphRequestWithRetry([System.String] $Method, [System.String] $Uri, [System.Collections.Hashtable] $Body, [System.String] $PrimeGetUri)
    {
        $retryCount = 0
        $maxRetries = 5
        do
        {
            try
            {
                if (-not [System.String]::IsNullOrEmpty($PrimeGetUri))
                {
                    # The application proxy backend needs the application to have been read at least once before it accepts writes to onPremisesPublishing, matching the GSA portal's own request pattern.
                    $null = Invoke-MgGraphRequest -Method GET -Uri $PrimeGetUri -ErrorAction SilentlyContinue
                }
                $requestParams = @{
                    Method      = $Method
                    Uri         = $Uri
                    ErrorAction = 'Stop'
                }
                if ($null -ne $Body)
                {
                    $requestParams.Body = $Body
                }
                return Invoke-MgGraphRequest @requestParams
            }
            catch
            {
                $retryCount++
                if ($retryCount -ge $maxRetries)
                {
                    throw
                }
                # A newly instantiated application's onPremisesPublishing sub-resource is not immediately available and returns transient errors until provisioning completes.
                Write-Verbose -Message "Request to {$Uri} failed, retrying in 10 seconds ($retryCount/$maxRetries)"
                Start-Sleep -Seconds 10
            }
        } while ($true)

        return $null
    }

    hidden [void] SetConnectorGroup([System.String] $AppId, [System.String] $GroupName, [System.String] $BaseUrl)
    {
        $groupResponse = Invoke-MgGraphRequest -Method GET `
            -Uri ($BaseUrl + "beta/onPremisesPublishingProfiles/applicationProxy/connectorGroups?`$filter=name eq '$($GroupName -replace "'", "''")'") `
            -ErrorAction Stop

        if ($null -eq $groupResponse -or $groupResponse.value.Count -eq 0)
        {
            throw "Could not find connector group with name: $GroupName"
        }

        $connectorGroupId = $groupResponse.value[0].id
        $refBody = @{
            '@odata.id' = $BaseUrl + "beta/onPremisesPublishingProfiles/applicationproxy/connectorGroups/$connectorGroupId"
        }
        $null = $this.InvokeGraphRequestWithRetry('PUT', ($BaseUrl + "beta/applications/$AppId/connectorGroup/`$ref"), $refBody, $null)
    }

    hidden [void] AddSegment([System.String] $AppId, [System.Object] $Segment, [System.String] $BaseUrl)
    {
        $segmentBody = @{
            destinationHost = $Segment.DestinationHost
            destinationType = [AADGSAPrivateAccessApplication]::ConvertToDestinationTypeGraphValue($Segment.DestinationType)
        }
        if ($null -ne $Segment.Ports -and $Segment.Ports.Count -gt 0)
        {
            $segmentBody.ports = [System.Collections.ArrayList]@($Segment.Ports)
        }
        if (-not [System.String]::IsNullOrEmpty($Segment.Protocol))
        {
            $segmentBody.protocol = $Segment.Protocol
        }

        $null = $this.InvokeGraphRequestWithRetry('POST', ($BaseUrl + "beta/applications/$AppId/onPremisesPublishing/segmentsConfiguration/microsoft.graph.ipSegmentConfiguration/applicationSegments"), $segmentBody, $null)
    }

    hidden [void] SyncSegments([System.String] $AppId, [System.Object[]] $DesiredSegments, [System.Object[]] $CurrentSegments, [System.String] $BaseUrl)
    {
        $matchedCurrentIds = @()

        foreach ($desired in $DesiredSegments)
        {
            $desiredHost = $desired.DestinationHost
            $desiredType = $desired.DestinationType
            $matchFound = $false

            foreach ($current in $CurrentSegments)
            {
                if ($current.Id -notin $matchedCurrentIds -and
                    $current.DestinationHost -eq $desiredHost -and
                    $current.DestinationType -eq $desiredType)
                {
                    $matchedCurrentIds += $current.Id
                    $matchFound = $true

                    $updateBody = @{}
                    if ($null -ne $desired.Ports -and $desired.Ports.Count -gt 0)
                    {
                        $updateBody.ports = [System.Collections.ArrayList]@($desired.Ports)
                    }
                    if (-not [System.String]::IsNullOrEmpty($desired.Protocol))
                    {
                        $updateBody.protocol = $desired.Protocol
                    }
                    if ($updateBody.Count -gt 0)
                    {
                        Invoke-MgGraphRequest -Method PATCH `
                            -Uri ($BaseUrl + "beta/applications/$AppId/onPremisesPublishing/segmentsConfiguration/microsoft.graph.ipSegmentConfiguration/applicationSegments/$($current.Id)") `
                            -Body $updateBody | Out-Null
                    }
                    break
                }
            }

            if (-not $matchFound)
            {
                $this.AddSegment($AppId, $desired, $BaseUrl)
            }
        }

        foreach ($current in $CurrentSegments)
        {
            if ($current.Id -notin $matchedCurrentIds)
            {
                Invoke-MgGraphRequest -Method DELETE `
                    -Uri ($BaseUrl + "beta/applications/$AppId/onPremisesPublishing/segmentsConfiguration/microsoft.graph.ipSegmentConfiguration/applicationSegments/$($current.Id)") | Out-Null
            }
        }
    }

    hidden static [System.String] ConvertToDestinationTypeGraphValue([System.String] $DestinationType)
    {
        # The Global Secure Access API accepts 'ip' on the wire for the documented 'ipAddress' value.
        if ($DestinationType -eq 'ipAddress')
        {
            return 'ip'
        }
        return $DestinationType
    }

    hidden static [System.String] ConvertFromDestinationTypeGraphValue([System.String] $DestinationType)
    {
        if ($DestinationType -eq 'ip')
        {
            return 'ipAddress'
        }
        return $DestinationType
    }
}

class MSFT_AADGSAPrivateAccessApplicationSegment
{
    [DscProperty()]
    [System.ComponentModel.Description('The destination host for the segment, such as an FQDN or IP address.')]
    [System.String] $DestinationHost

    [DscProperty()]
    [System.ComponentModel.Description('The destination type for the segment.')]
    [ValidateSet('ipAddress', 'ipRange', 'ipRangeCidr', 'fqdn', 'dnsSuffix')]
    [System.String] $DestinationType

    [DscProperty()]
    [System.ComponentModel.Description('List of port ranges for the segment (e.g., ''445-445'', ''3389-3389'').')]
    [System.String[]] $Ports

    [DscProperty()]
    [System.ComponentModel.Description('The protocol for the segment.')]
    [ValidateSet('tcp', 'udp', 'tcp,udp')]
    [System.String] $Protocol

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the segment. Read-only.')]
    [System.String] $Id
}
