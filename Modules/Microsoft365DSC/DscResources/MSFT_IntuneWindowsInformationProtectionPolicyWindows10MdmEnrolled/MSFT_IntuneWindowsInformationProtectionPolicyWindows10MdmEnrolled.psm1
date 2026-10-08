using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Policy display name.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to allow Azure RMS encryption for WIP')]
    [System.Nullable[System.Boolean]] $AzureRightsManagementServicesAllowed

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a recovery certificate that can be used for data recovery of encrypted files. This is the same as the data recovery agent(DRA) certificate for encrypting file system(EFS)')]
    [MSFT_MicrosoftGraphwindowsInformationProtectionDataRecoveryCertificate] $DataRecoveryCertificate

    [DscProperty()]
    [System.ComponentModel.Description('WIP enforcement level.See the Enum definition for supported values. Possible values are: noProtection, encryptAndAuditOnly, encryptAuditAndPrompt, encryptAuditAndBlock.')]
    [ValidateSet('noProtection', 'encryptAndAuditOnly', 'encryptAuditAndPrompt', 'encryptAuditAndBlock')]
    [System.String] $EnforcementLevel

    [DscProperty()]
    [System.ComponentModel.Description('Primary enterprise domain')]
    [System.String] $EnterpriseDomain

    [DscProperty()]
    [System.ComponentModel.Description('This is the comma-separated list of internal proxy servers. For example, ''157.54.14.28, 157.54.11.118, 10.202.14.167, 157.53.14.163, 157.69.210.59''. These proxies have been configured by the admin to connect to specific resources on the Internet. They are considered to be enterprise network locations. The proxies are only leveraged in configuring the EnterpriseProxiedDomains policy to force traffic to the matched domains through these proxies')]
    [MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection[]] $EnterpriseInternalProxyServers

    [DscProperty()]
    [System.ComponentModel.Description('Sets the enterprise IP ranges that define the computers in the enterprise network. Data that comes from those computers will be considered part of the enterprise and protected. These locations will be considered a safe destination for enterprise data to be shared to')]
    [MSFT_MicrosoftGraphwindowsInformationProtectionIPRangeCollection[]] $EnterpriseIPRanges

    [DscProperty()]
    [System.ComponentModel.Description('Boolean value that tells the client to accept the configured list and not to use heuristics to attempt to find other subnets. Default is false')]
    [System.Nullable[System.Boolean]] $EnterpriseIPRangesAreAuthoritative

    [DscProperty()]
    [System.ComponentModel.Description('This is the list of domains that comprise the boundaries of the enterprise. Data from one of these domains that is sent to a device will be considered enterprise data and protected These locations will be considered a safe destination for enterprise data to be shared to')]
    [MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection[]] $EnterpriseNetworkDomainNames

    [DscProperty()]
    [System.ComponentModel.Description('List of enterprise domains to be protected')]
    [MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection[]] $EnterpriseProtectedDomainNames

    [DscProperty()]
    [System.ComponentModel.Description('Contains a list of Enterprise resource domains hosted in the cloud that need to be protected. Connections to these resources are considered enterprise data. If a proxy is paired with a cloud resource, traffic to the cloud resource will be routed through the enterprise network via the denoted proxy server (on Port 80). A proxy server used for this purpose must also be configured using the EnterpriseInternalProxyServers policy')]
    [MSFT_MicrosoftGraphwindowsInformationProtectionProxiedDomainCollection[]] $EnterpriseProxiedDomains

    [DscProperty()]
    [System.ComponentModel.Description('This is a list of proxy servers. Any server not on this list is considered non-enterprise')]
    [MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection[]] $EnterpriseProxyServers

    [DscProperty()]
    [System.ComponentModel.Description('Boolean value that tells the client to accept the configured list of proxies and not try to detect other work proxies. Default is false')]
    [System.Nullable[System.Boolean]] $EnterpriseProxyServersAreAuthoritative

    [DscProperty()]
    [System.ComponentModel.Description('Exempt applications can also access enterprise data, but the data handled by those applications are not protected. This is because some critical enterprise applications may have compatibility problems with encrypted data.')]
    [MSFT_MicrosoftGraphwindowsInformationProtectionApp[]] $ExemptApps

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether overlays are added to icons for WIP protected files in Explorer and enterprise only app tiles in the Start menu. Starting in Windows 10, version 1703 this setting also configures the visibility of the WIP icon in the title bar of a WIP-protected app')]
    [System.Nullable[System.Boolean]] $IconsVisible

    [DscProperty()]
    [System.ComponentModel.Description('This switch is for the Windows Search Indexer, to allow or disallow indexing of items')]
    [System.Nullable[System.Boolean]] $IndexingEncryptedStoresOrItemsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('List of domain names that can used for work or personal resource')]
    [MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection[]] $NeutralDomainResources

    [DscProperty()]
    [System.ComponentModel.Description('Protected applications can access enterprise data and the data handled by those applications are protected with encryption')]
    [MSFT_MicrosoftGraphwindowsInformationProtectionApp[]] $ProtectedApps

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the protection under lock feature (also known as encrypt under pin) should be configured')]
    [System.Nullable[System.Boolean]] $ProtectionUnderLockConfigRequired

    [DscProperty()]
    [System.ComponentModel.Description('This policy controls whether to revoke the WIP keys when a device unenrolls from the management service. If set to 1 (Don''t revoke keys), the keys will not be revoked and the user will continue to have access to protected files after unenrollment. If the keys are not revoked, there will be no revoked file cleanup subsequently.')]
    [System.Nullable[System.Boolean]] $RevokeOnUnenrollDisabled

    [DscProperty()]
    [System.ComponentModel.Description('TemplateID GUID to use for RMS encryption. The RMS template allows the IT admin to configure the details about who has access to RMS-protected file and how long they have access')]
    [System.String] $RightsManagementServicesTemplateId

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a list of file extensions, so that files with these extensions are encrypted when copying from an SMB share within the corporate boundary')]
    [MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection[]] $SmbAutoEncryptedFileExtensions

    [DscProperty()]
    [System.ComponentModel.Description('The policy''s description.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolledPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
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

    [IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Windows Information Protection Policy for Windows10 Mdm Enrolled with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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

            #region resource generator code
            if (-not [string]::IsNullOrEmpty($this.Id))
            {
                $getValue = Get-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy -MdmWindowsInformationProtectionPolicyId $this.Id -ExpandProperty assignments -ErrorAction SilentlyContinue
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Intune Windows Information Protection Policy for Windows10 Mdm Enrolled with Id {$($this.Id)}"

                if (-not [string]::IsNullOrEmpty($this.DisplayName))
                {
                    [array]$getValue = Get-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy `
                        -All `
                        -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                        -ErrorAction SilentlyContinue
                    if ($getValue.Count -gt 1)
                    {
                        throw ("Error: Ensure the displayName {$($this.displayName)} is unique.")
                    }
                    if (-not [String]::IsNullOrEmpty($getValue.Id))
                    {
                        $getValue = Get-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy -MdmWindowsInformationProtectionPolicyId $getValue.id -ExpandProperty assignments
                    }
                }
            }
            #endregion

            if ([String]::IsNullOrEmpty($getValue.Id))
            {
                Write-Verbose -Message "Could not find an Intune Windows Information Protection Policy for Windows10 Mdm Enrolled with DisplayName {$($this.DisplayName)}"
                return $this.AsResult($nullResult)
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Windows Information Protection Policy for Windows10 Mdm Enrolled with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            #region resource generator code
            $complexDataRecoveryCertificate = [ordered]@{}
            $complexDataRecoveryCertificate.Add('Certificate', $getValue.DataRecoveryCertificate.certificate)
            $complexDataRecoveryCertificate.Add('Description', $getValue.DataRecoveryCertificate.description)
            if ($null -ne $getValue.DataRecoveryCertificate.expirationDateTime)
            {
                $complexDataRecoveryCertificate.Add('ExpirationDateTime', ([DateTimeOffset]$getValue.DataRecoveryCertificate.expirationDateTime).ToString('o'))
            }
            $complexDataRecoveryCertificate.Add('SubjectName', $getValue.DataRecoveryCertificate.subjectName)
            if ($complexDataRecoveryCertificate.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDataRecoveryCertificate = $null
            }

            $complexEnterpriseInternalProxyServers = @()
            foreach ($currentEnterpriseInternalProxyServers in $getValue.enterpriseInternalProxyServers)
            {
                $myEnterpriseInternalProxyServers = [ordered]@{}
                $myEnterpriseInternalProxyServers.Add('DisplayName', $currentEnterpriseInternalProxyServers.displayName)
                $myEnterpriseInternalProxyServers.Add('Resources', $currentEnterpriseInternalProxyServers.resources)
                if ($myEnterpriseInternalProxyServers.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexEnterpriseInternalProxyServers += $myEnterpriseInternalProxyServers
                }
            }

            $complexEnterpriseIPRanges = @()
            foreach ($currentEnterpriseIPRanges in $getValue.enterpriseIPRanges)
            {
                $myEnterpriseIPRanges = [ordered]@{}
                $myEnterpriseIPRanges.Add('DisplayName', $currentEnterpriseIPRanges.displayName)
                $complexRanges = @()
                foreach ($currentRanges in $currentEnterpriseIPRanges.ranges)
                {
                    $myRanges = [ordered]@{}
                    $myRanges.Add('CidrAddress', $currentRanges.cidrAddress)
                    $myRanges.Add('LowerAddress', $currentRanges.lowerAddress)
                    $myRanges.Add('UpperAddress', $currentRanges.upperAddress)
                    if ($null -ne $currentRanges.'@odata.type')
                    {
                        $myRanges.Add('odataType', $currentRanges.'@odata.type')
                    }
                    if ($myRanges.values.Where({ $null -ne $_ }).Count -gt 0)
                    {
                        $complexRanges += $myRanges
                    }
                }
                $myEnterpriseIPRanges.Add('Ranges', $complexRanges)
                if ($myEnterpriseIPRanges.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexEnterpriseIPRanges += $myEnterpriseIPRanges
                }
            }

            $complexEnterpriseNetworkDomainNames = @()
            foreach ($currentEnterpriseNetworkDomainNames in $getValue.enterpriseNetworkDomainNames)
            {
                $myEnterpriseNetworkDomainNames = [ordered]@{}
                $myEnterpriseNetworkDomainNames.Add('DisplayName', $currentEnterpriseNetworkDomainNames.displayName)
                $myEnterpriseNetworkDomainNames.Add('Resources', $currentEnterpriseNetworkDomainNames.resources)
                if ($myEnterpriseNetworkDomainNames.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexEnterpriseNetworkDomainNames += $myEnterpriseNetworkDomainNames
                }
            }

            $complexEnterpriseProtectedDomainNames = @()
            foreach ($currentEnterpriseProtectedDomainNames in $getValue.enterpriseProtectedDomainNames)
            {
                $myEnterpriseProtectedDomainNames = [ordered]@{}
                $myEnterpriseProtectedDomainNames.Add('DisplayName', $currentEnterpriseProtectedDomainNames.displayName)
                $myEnterpriseProtectedDomainNames.Add('Resources', $currentEnterpriseProtectedDomainNames.resources)
                if ($myEnterpriseProtectedDomainNames.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexEnterpriseProtectedDomainNames += $myEnterpriseProtectedDomainNames
                }
            }

            $complexEnterpriseProxiedDomains = @()
            foreach ($currentEnterpriseProxiedDomains in $getValue.enterpriseProxiedDomains)
            {
                $myEnterpriseProxiedDomains = [ordered]@{}
                $myEnterpriseProxiedDomains.Add('DisplayName', $currentEnterpriseProxiedDomains.displayName)
                $complexProxiedDomains = @()
                foreach ($currentProxiedDomains in $currentEnterpriseProxiedDomains.proxiedDomains)
                {
                    $myProxiedDomains = [ordered]@{}
                    $myProxiedDomains.Add('IpAddressOrFQDN', $currentProxiedDomains.ipAddressOrFQDN)
                    $myProxiedDomains.Add('Proxy', $currentProxiedDomains.proxy)
                    if ($myProxiedDomains.values.Where({ $null -ne $_ }).Count -gt 0)
                    {
                        $complexProxiedDomains += $myProxiedDomains
                    }
                }
                $myEnterpriseProxiedDomains.Add('ProxiedDomains', $complexProxiedDomains)
                if ($myEnterpriseProxiedDomains.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexEnterpriseProxiedDomains += $myEnterpriseProxiedDomains
                }
            }

            $complexEnterpriseProxyServers = @()
            foreach ($currentEnterpriseProxyServers in $getValue.enterpriseProxyServers)
            {
                $myEnterpriseProxyServers = [ordered]@{}
                $myEnterpriseProxyServers.Add('DisplayName', $currentEnterpriseProxyServers.displayName)
                $myEnterpriseProxyServers.Add('Resources', $currentEnterpriseProxyServers.resources)
                if ($myEnterpriseProxyServers.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexEnterpriseProxyServers += $myEnterpriseProxyServers
                }
            }

            $complexExemptApps = @()
            foreach ($currentExemptApps in $getValue.exemptApps)
            {
                $myExemptApps = [ordered]@{}
                $myExemptApps.Add('Denied', $currentExemptApps.denied)
                $myExemptApps.Add('Description', $currentExemptApps.description)
                $myExemptApps.Add('DisplayName', $currentExemptApps.displayName)
                $myExemptApps.Add('ProductName', $currentExemptApps.productName)
                $myExemptApps.Add('PublisherName', $currentExemptApps.publisherName)
                $myExemptApps.Add('BinaryName', $currentExemptApps.binaryName)
                $myExemptApps.Add('BinaryVersionHigh', $currentExemptApps.binaryVersionHigh)
                $myExemptApps.Add('BinaryVersionLow', $currentExemptApps.binaryVersionLow)
                if ($null -ne $currentExemptApps.'@odata.type')
                {
                    $myExemptApps.Add('odataType', $currentExemptApps.'@odata.type')
                }
                if ($myExemptApps.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexExemptApps += $myExemptApps
                }
            }

            $complexNeutralDomainResources = @()
            foreach ($currentNeutralDomainResources in $getValue.neutralDomainResources)
            {
                $myNeutralDomainResources = [ordered]@{}
                $myNeutralDomainResources.Add('DisplayName', $currentNeutralDomainResources.displayName)
                $myNeutralDomainResources.Add('Resources', $currentNeutralDomainResources.resources)
                if ($myNeutralDomainResources.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexNeutralDomainResources += $myNeutralDomainResources
                }
            }

            $complexProtectedApps = @()
            foreach ($currentProtectedApps in $getValue.protectedApps)
            {
                $myProtectedApps = [ordered]@{}
                $myProtectedApps.Add('Denied', $currentProtectedApps.denied)
                $myProtectedApps.Add('Description', $currentProtectedApps.description)
                $myProtectedApps.Add('DisplayName', $currentProtectedApps.displayName)
                $myProtectedApps.Add('ProductName', $currentProtectedApps.productName)
                $myProtectedApps.Add('PublisherName', $currentProtectedApps.publisherName)
                $myProtectedApps.Add('BinaryName', $currentProtectedApps.binaryName)
                $myProtectedApps.Add('BinaryVersionHigh', $currentProtectedApps.binaryVersionHigh)
                $myProtectedApps.Add('BinaryVersionLow', $currentProtectedApps.binaryVersionLow)
                if ($null -ne $currentProtectedApps.'@odata.type')
                {
                    $myProtectedApps.Add('odataType', $currentProtectedApps.'@odata.type')
                }
                if ($myProtectedApps.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexProtectedApps += $myProtectedApps
                }
            }

            $complexSmbAutoEncryptedFileExtensions = @()
            foreach ($currentSmbAutoEncryptedFileExtensions in $getValue.smbAutoEncryptedFileExtensions)
            {
                $mySmbAutoEncryptedFileExtensions = [ordered]@{}
                $mySmbAutoEncryptedFileExtensions.Add('DisplayName', $currentSmbAutoEncryptedFileExtensions.displayName)
                $mySmbAutoEncryptedFileExtensions.Add('Resources', $currentSmbAutoEncryptedFileExtensions.resources)
                if ($mySmbAutoEncryptedFileExtensions.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexSmbAutoEncryptedFileExtensions += $mySmbAutoEncryptedFileExtensions
                }
            }
            #endregion

            $results = @{
                #region resource generator code
                AzureRightsManagementServicesAllowed   = $getValue.AzureRightsManagementServicesAllowed
                DataRecoveryCertificate                = $complexDataRecoveryCertificate
                EnforcementLevel                       = $getValue.EnforcementLevel
                EnterpriseDomain                       = $getValue.EnterpriseDomain
                EnterpriseInternalProxyServers         = $complexEnterpriseInternalProxyServers
                EnterpriseIPRanges                     = $complexEnterpriseIPRanges
                EnterpriseIPRangesAreAuthoritative     = $getValue.EnterpriseIPRangesAreAuthoritative
                EnterpriseNetworkDomainNames           = $complexEnterpriseNetworkDomainNames
                EnterpriseProtectedDomainNames         = $complexEnterpriseProtectedDomainNames
                EnterpriseProxiedDomains               = $complexEnterpriseProxiedDomains
                EnterpriseProxyServers                 = $complexEnterpriseProxyServers
                EnterpriseProxyServersAreAuthoritative = $getValue.EnterpriseProxyServersAreAuthoritative
                ExemptApps                             = $complexExemptApps
                IconsVisible                           = $getValue.IconsVisible
                IndexingEncryptedStoresOrItemsBlocked  = $getValue.IndexingEncryptedStoresOrItemsBlocked
                NeutralDomainResources                 = $complexNeutralDomainResources
                ProtectedApps                          = $complexProtectedApps
                ProtectionUnderLockConfigRequired      = $getValue.ProtectionUnderLockConfigRequired
                RevokeOnUnenrollDisabled               = $getValue.RevokeOnUnenrollDisabled
                RightsManagementServicesTemplateId     = $getValue.RightsManagementServicesTemplateId
                SmbAutoEncryptedFileExtensions         = $complexSmbAutoEncryptedFileExtensions
                Description                            = $getValue.Description
                DisplayName                            = $getValue.DisplayName
                Id                                     = $getValue.Id
                RoleScopeTagIds                        = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Ensure                                 = 'Present'
                Credential                             = $this.Credential
                ApplicationId                          = $this.ApplicationId
                TenantId                               = $this.TenantId
                ApplicationSecret                      = $this.ApplicationSecret
                CertificateThumbprint                  = $this.CertificateThumbprint
                CertificatePath                        = $this.CertificatePath
                CertificatePassword                    = $this.CertificatePassword
                ManagedIdentity                        = $this.ManagedIdentity
                AccessTokens                           = $this.AccessTokens
                #endregion
            }
            if ($getValue.assignments.Count -gt 0)
            {
                [array]$assignmentsValues = $getValue.assignments | Where-Object -FilterScript { $_.source -eq 'direct' }
                $results.Add('Assignments', (ConvertFrom-IntunePolicyAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $false))
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters.Remove('Assignments') | Out-Null
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $this.RemoveForeignSubtypeProperties($boundParameters, @{
                '#microsoft.graph.iPv4Range'                                = @('lowerAddress', 'upperAddress')
                '#microsoft.graph.iPv6Range'                                = @('lowerAddress', 'upperAddress')
                '#microsoft.graph.iPv4CidrRange'                            = @('cidrAddress')
                '#microsoft.graph.iPv6CidrRange'                            = @('cidrAddress')
                '#microsoft.graph.windowsInformationProtectionStoreApp'     = @('denied', 'description', 'displayName', 'productName', 'publisherName')
                '#microsoft.graph.windowsInformationProtectionDesktopApp'   = @('binaryName', 'binaryVersionHigh', 'binaryVersionLow', 'denied', 'description', 'displayName', 'productName', 'publisherName')
            })

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Windows Information Protection Policy for Windows10 Mdm Enrolled with DisplayName {$($this.DisplayName)}"

            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $policy = New-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy -BodyParameter $createParameters
            #endregion

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments

            if ($policy.id)
            {
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceAppManagement/mdmWindowsInformationProtectionPolicies'
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Windows Information Protection Policy for Windows10 Mdm Enrolled with Id {$($currentInstance.Id)}"

            $updateParameters = $boundParameters
            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.MdmWindowsInformationProtectionPolicy')
            Update-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy `
                -MdmWindowsInformationProtectionPolicyId $currentInstance.Id `
                -BodyParameter $updateParameters
            #endregion

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentInstance.id `
                -Targets $assignmentsHash `
                -Repository 'deviceAppManagement/mdmWindowsInformationProtectionPolicies'
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Windows Information Protection Policy for Windows10 Mdm Enrolled with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy -MdmWindowsInformationProtectionPolicyId $currentInstance.Id
            #endregion
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $complexFunctions = $null
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
            $mergedFilter = $this.Filter
            if (-not [string]::IsNullOrEmpty($this.Filter))
            {
                $complexFunctions = Get-ComplexFunctionsFromFilterQuery -FilterQuery $this.Filter
                $mergedFilter = Remove-ComplexFunctionsFromFilterQuery -FilterQuery $this.Filter
            }
            [array]$getValue = Get-MgBetaDeviceAppManagementMdmWindowsInformationProtectionPolicy -Filter $mergedFilter -All -ErrorAction Stop
            $getValue = Find-GraphDataUsingComplexFunctions -ComplexFunctions $complexFunctions -Policies $getValue
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.DisplayName
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

                if ( $null -ne $Results.DataRecoveryCertificate)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DataRecoveryCertificate `
                        -CIMInstanceName 'MicrosoftGraphwindowsInformationProtectionDataRecoveryCertificate'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DataRecoveryCertificate = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DataRecoveryCertificate') | Out-Null
                    }
                }
                if ( $null -ne $Results.EnterpriseInternalProxyServers)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.EnterpriseInternalProxyServers `
                        -CIMInstanceName 'MicrosoftGraphwindowsInformationProtectionResourceCollection'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.EnterpriseInternalProxyServers = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('EnterpriseInternalProxyServers') | Out-Null
                    }
                }
                if ( $null -ne $Results.EnterpriseIPRanges)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'EnterpriseIPRanges'
                            CimInstanceName = 'MicrosoftGraphWindowsInformationProtectionIPRangeCollection'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'Ranges'
                            CimInstanceName = 'MicrosoftGraphIpRange'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.EnterpriseIPRanges `
                        -CIMInstanceName 'MicrosoftGraphwindowsInformationProtectionIPRangeCollection' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.EnterpriseIPRanges = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('EnterpriseIPRanges') | Out-Null
                    }
                }
                if ( $null -ne $Results.EnterpriseNetworkDomainNames)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.EnterpriseNetworkDomainNames `
                        -CIMInstanceName 'MicrosoftGraphwindowsInformationProtectionResourceCollection'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.EnterpriseNetworkDomainNames = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('EnterpriseNetworkDomainNames') | Out-Null
                    }
                }
                if ( $null -ne $Results.EnterpriseProtectedDomainNames)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.EnterpriseProtectedDomainNames `
                        -CIMInstanceName 'MicrosoftGraphwindowsInformationProtectionResourceCollection'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.EnterpriseProtectedDomainNames = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('EnterpriseProtectedDomainNames') | Out-Null
                    }
                }
                if ( $null -ne $Results.EnterpriseProxiedDomains)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'EnterpriseProxiedDomains'
                            CimInstanceName = 'MicrosoftGraphWindowsInformationProtectionProxiedDomainCollection'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'ProxiedDomains'
                            CimInstanceName = 'MicrosoftGraphProxiedDomain'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.EnterpriseProxiedDomains `
                        -CIMInstanceName 'MicrosoftGraphwindowsInformationProtectionProxiedDomainCollection' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.EnterpriseProxiedDomains = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('EnterpriseProxiedDomains') | Out-Null
                    }
                }
                if ( $null -ne $Results.EnterpriseProxyServers)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.EnterpriseProxyServers `
                        -CIMInstanceName 'MicrosoftGraphwindowsInformationProtectionResourceCollection'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.EnterpriseProxyServers = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('EnterpriseProxyServers') | Out-Null
                    }
                }
                if ( $null -ne $Results.ExemptApps)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ExemptApps `
                        -CIMInstanceName 'MicrosoftGraphwindowsInformationProtectionApp'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ExemptApps = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ExemptApps') | Out-Null
                    }
                }
                if ( $null -ne $Results.NeutralDomainResources)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.NeutralDomainResources `
                        -CIMInstanceName 'MicrosoftGraphwindowsInformationProtectionResourceCollection'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.NeutralDomainResources = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('NeutralDomainResources') | Out-Null
                    }
                }
                if ( $null -ne $Results.ProtectedApps)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ProtectedApps `
                        -CIMInstanceName 'MicrosoftGraphwindowsInformationProtectionApp'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ProtectedApps = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ProtectedApps') | Out-Null
                    }
                }
                if ( $null -ne $Results.SmbAutoEncryptedFileExtensions)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.SmbAutoEncryptedFileExtensions `
                        -CIMInstanceName 'MicrosoftGraphwindowsInformationProtectionResourceCollection'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.SmbAutoEncryptedFileExtensions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('SmbAutoEncryptedFileExtensions') | Out-Null
                    }
                }
                if ($Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolledPolicyAssignments
                    if ($complexTypeStringResult)
                    {
                        $Results.Assignments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Assignments') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('DataRecoveryCertificate', 'EnterpriseInternalProxyServers', 'EnterpriseIPRanges',
                    'EnterpriseNetworkDomainNames', 'EnterpriseProtectedDomainNames', 'EnterpriseProxiedDomains',
                    'EnterpriseProxyServers', 'ExemptApps', 'NeutralDomainResources', 'ProtectedApps',
                    'SmbAutoEncryptedFileExtensions', 'Assignments') `
                    -RawResults $rawResults

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
            if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                    $_.Exception -like '*Request not applicable to target tenant*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }

        # Every code path must return in a method with a declared return type.
        return ''
    }

    hidden [IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled])
        {
            return $Values
        }

        $result = [IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphwindowsInformationProtectionDataRecoveryCertificate
{
    [DscProperty()]
    [System.ComponentModel.Description('Data recovery Certificate')]
    [System.String] $Certificate

    [DscProperty()]
    [System.ComponentModel.Description('Data recovery Certificate description')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Data recovery Certificate expiration datetime')]
    [System.String] $ExpirationDateTime

    [DscProperty()]
    [System.ComponentModel.Description('Data recovery Certificate subject name')]
    [System.String] $SubjectName
}

class MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Display name')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Collection of resources')]
    [System.String[]] $Resources
}

class MSFT_MicrosoftGraphwindowsInformationProtectionIPRangeCollection
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Display name')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Collection of ip ranges')]
    [MSFT_MicrosoftGraphIpRange[]] $Ranges
}

class MSFT_MicrosoftGraphwindowsInformationProtectionProxiedDomainCollection
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Display name')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Collection of proxied domains')]
    [MSFT_MicrosoftGraphProxiedDomain[]] $ProxiedDomains
}

class MSFT_MicrosoftGraphwindowsInformationProtectionApp
{
    [DscProperty()]
    [System.ComponentModel.Description('If true, app is denied protection or exemption.')]
    [System.Nullable[System.Boolean]] $Denied

    [DscProperty()]
    [System.ComponentModel.Description('The app''s description.')]
    [System.String] $Description

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('App display name.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The product name.')]
    [System.String] $ProductName

    [DscProperty()]
    [System.ComponentModel.Description('The publisher name')]
    [System.String] $PublisherName

    [DscProperty()]
    [System.ComponentModel.Description('The binary name.')]
    [System.String] $BinaryName

    [DscProperty()]
    [System.ComponentModel.Description('The high binary version.')]
    [System.String] $BinaryVersionHigh

    [DscProperty()]
    [System.ComponentModel.Description('The lower binary version.')]
    [System.String] $BinaryVersionLow

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.windowsInformationProtectionDesktopApp', '#microsoft.graph.windowsInformationProtectionStoreApp')]
    [System.String] $odataType
}

class MSFT_IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolledPolicyAssignments
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the target assignment.')]
    [ValidateSet('#microsoft.graph.groupAssignmentTarget', '#microsoft.graph.allLicensedUsersAssignmentTarget', '#microsoft.graph.allDevicesAssignmentTarget', '#microsoft.graph.exclusionGroupAssignmentTarget', '#microsoft.graph.configurationManagerCollectionAssignmentTarget')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('The type of filter of the target assignment i.e. Exclude or Include. Possible values are:none, include, exclude.')]
    [ValidateSet('none', 'include', 'exclude')]
    [System.String] $deviceAndAppManagementAssignmentFilterType

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterId

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The group Id that is the target of the assignment.')]
    [System.String] $groupId

    [DscProperty()]
    [System.ComponentModel.Description('The group Display Name that is the target of the assignment.')]
    [System.String] $groupDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The collection Id that is the target of the assignment.(ConfigMgr)')]
    [System.String] $collectionId
}

class MSFT_MicrosoftGraphIpRange
{
    [DscProperty()]
    [System.ComponentModel.Description('CIDR address.')]
    [System.String] $CidrAddress

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Lower address.')]
    [System.String] $LowerAddress

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Upper address.')]
    [System.String] $UpperAddress

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.iPv4Range', '#microsoft.graph.iPv6Range')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphProxiedDomain
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The IP address or FQDN')]
    [System.String] $IpAddressOrFQDN

    [DscProperty()]
    [System.ComponentModel.Description('Proxy IP or FQDN')]
    [System.String] $Proxy
}
