using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADIdentityAPIConnector : M365DSCResourceBase
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The name of the API connector.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The URL of the API endpoint to call.')]
    [System.String] $TargetUrl

    [DscProperty(Key)]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The object which describes the authentication configuration details for calling the API.')]
    [MSFT_MicrosoftGraphApiAuthenticationConfigurationBase] $AuthenticationConfiguration

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

    [AADIdentityAPIConnector] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADIdentityAPIConnector]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Azure AD Identity API Connector with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                #region resource generator code
                $getValue = Get-MgBetaIdentityApiConnector -IdentityApiConnectorId $this.Id -ErrorAction SilentlyContinue

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Identity A P I Connector with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaIdentityApiConnector `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            #endregion
            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Azure AD Identity API Connector with DisplayName {$($this.DisplayName)}."
                return $this.AsResult($nullResult)
            }
            Write-Verbose -Message "An Azure AD Identity API Connector with Id {$($getValue.Id)} and DisplayName {$($this.DisplayName)} was found"

            #region resource generator code
            $currentPassword = $this.AuthenticationConfiguration.Password
            if ($null -ne $getValue.AuthenticationConfiguration.password)
            {
                $securePassword = ConvertTo-SecureString $getValue.AuthenticationConfiguration.password -AsPlainText -Force
                $currentPassword = New-Object System.Management.Automation.PSCredential ('Password', $securePassword)
            }

            $complexCertificates = @()
            foreach ($currentCertificate in $getValue.AuthenticationConfiguration.certificateList)
            {
                $myCertificate = [ordered]@{}
                $myCertificate.Add('Pkcs12Value', (New-Object System.Management.Automation.PSCredential('Pkcs12Value', (ConvertTo-SecureString ('Please insert a valid Pkcs12Value') -AsPlainText -Force))))
                $myCertificate.Add('Thumbprint', $currentCertificate.thumbprint)
                $myCertificate.Add('Password', (New-Object System.Management.Automation.PSCredential('Password', (ConvertTo-SecureString ('Please insert a valid Password for the certificate') -AsPlainText -Force))))
                $myCertificate.Add('IsActive', $currentCertificate.isActive)

                if ($myCertificate.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexCertificates += $myCertificate
                }
            }
            $complexAuthenticationConfiguration = [ordered]@{}
            $complexAuthenticationConfiguration.Add('dataType', $getValue.AuthenticationConfiguration.'@odata.type')
            $complexAuthenticationConfiguration.Add('Username', $getValue.AuthenticationConfiguration.username)
            $complexAuthenticationConfiguration.Add('Password', $currentPassword)
            $complexAuthenticationConfiguration.Add('CertificateList', $complexCertificates)
            if ($complexAuthenticationConfiguration.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexAuthenticationConfiguration = $null
            }
            #endregion

            $results = @{
                #region resource generator code
                DisplayName                 = $getValue.DisplayName
                TargetUrl                   = $getValue.TargetUrl
                Id                          = $getValue.Id
                AuthenticationConfiguration = $complexAuthenticationConfiguration
                Ensure                      = 'Present'
                Credential                  = $this.Credential
                ApplicationId               = $this.ApplicationId
                TenantId                    = $this.TenantId
                ApplicationSecret           = $this.ApplicationSecret
                CertificateThumbprint       = $this.CertificateThumbprint
                CertificatePath             = $this.CertificatePath
                CertificatePassword         = $this.CertificatePassword
                ManagedIdentity             = $this.ManagedIdentity
                #endregion
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

        $authentication = $this.AuthenticationConfiguration

        # If the certificate list is not empty, then we need to create a new instance
        $needToUpdateCertificates = $false
        if ($null -ne $authentication.CertificateList -and $authentication.CertificateList.Count -gt 0)
        {
            $needToUpdateCertificates = $true
        }

        if ($needToUpdateCertificates -eq $false)
        {
            if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating an Azure AD Identity API Connector with DisplayName {$($this.DisplayName)}"

                $createParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters
                $createParameters.Remove('Id') | Out-Null

                $createParameters.Remove('AuthenticationConfiguration') | Out-Null

                if ($null -ne $authentication.Username)
                {
                    $createParameters.Add('AuthenticationConfiguration', @{
                        '@odata.type' = 'microsoft.graph.basicAuthentication'
                        'password'    = $authentication.Password.GetNetworkCredential().Password
                        'username'    = $authentication.Username
                    })
                }

                $createParameters.Add('@odata.type', '#microsoft.graph.IdentityApiConnector')
                $policy = New-MgBetaIdentityApiConnector -BodyParameter $createParameters
            }
            elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Updating the Azure AD Identity API Connector with Id {$($currentInstance.Id)}"

                $updateParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

                $updateParameters.Remove('Id') | Out-Null

                $updateParameters.Remove('AuthenticationConfiguration') | Out-Null

                $updateParameters.Add('AuthenticationConfiguration', @{
                        '@odata.type' = 'microsoft.graph.basicAuthentication'
                        'password'    = $authentication.Password.GetNetworkCredential().Password
                        'username'    = $authentication.Username
                    })

                $updateParameters.Add('@odata.type', '#microsoft.graph.IdentityApiConnector')
                Update-MgBetaIdentityApiConnector `
                    -IdentityApiConnectorId $currentInstance.Id `
                    -BodyParameter $updateParameters
            }
            elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Removing the Azure AD Identity API Connector with Id {$($currentInstance.Id)}"
                Remove-MgBetaIdentityApiConnector -IdentityApiConnectorId $currentInstance.Id
            }
        }
        else
        {
            # Remove the existing instance if already present
            if ($currentInstance.Ensure -ne 'Absent')
            {
                Write-Verbose -Message "Removing the Azure AD Identity API Connector with Id {$($currentInstance.Id)}"
                Remove-MgBetaIdentityApiConnector -IdentityApiConnectorId $currentInstance.Id
            }

            # Create a new instance with the certificates
            Write-Verbose -Message "Creating an Azure AD Identity API Connector with DisplayName {$($this.DisplayName)}"

            $createParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters
            $createParameters.Remove('Id') | Out-Null

            $createParameters.Remove('AuthenticationConfiguration') | Out-Null

            # Get the active and inactive certificates
            $activeCertificates = @()
            $inactiveCertificates = @()
            foreach ($currentCertificate in $authentication.CertificateList)
            {
                $myCertificate = [ordered]@{}
                $myCertificate.Add('Pkcs12Value', ($currentCertificate.Pkcs12Value).Password)
                $myCertificate.Add('Password', ($currentCertificate.Password).Password)

                if ($currentCertificate.IsActive -eq $true)
                {
                    $activeCertificates += $myCertificate
                }
                else
                {
                    $inactiveCertificates += $myCertificate
                }
            }

            # Only one certificate can be active
            if ($activeCertificates.Count -ne 1)
            {
                throw 'There should be one active certificate'
            }

            if ($inactiveCertificates.Count -eq 0)
            {
                $createParameters.Add('AuthenticationConfiguration', @{
                        '@odata.type' = 'microsoft.graph.pkcs12Certificate'
                        'password'    = $activeCertificates[0].Password
                        'pkcs12Value' = $activeCertificates[0].Pkcs12Value
                    })
                $activeCertificates = $activeCertificates[1..$activeCertificates.Count]
            }
            else
            {
                $createParameters.Add('AuthenticationConfiguration', @{
                        '@odata.type' = 'microsoft.graph.pkcs12Certificate'
                        'password'    = $inactiveCertificates[0].Password
                        'pkcs12Value' = $inactiveCertificates[0].Pkcs12Value
                    })
                # remove the first element from the inactive certificates
                $inactiveCertificates = $inactiveCertificates[1..$inactiveCertificates.Count]
            }

            $createParameters.Add('@odata.type', '#microsoft.graph.IdentityApiConnector')
            $policy = New-MgBetaIdentityApiConnector -BodyParameter $createParameters

            # Upload the inactive certificates
            foreach ($currentCertificate in $inactiveCertificates)
            {
                $params = @{
                    pkcs12Value = $currentCertificate.Pkcs12Value
                    password    = $currentCertificate.Password
                }

                Invoke-MgBetaUploadIdentityApiConnectorClientCertificate -IdentityApiConnectorId $policy.Id -BodyParameter $params
            }

            # Upload active certificate
            foreach ($currentCertificate in $activeCertificates)
            {
                $params = @{
                    pkcs12Value = $currentCertificate.Pkcs12Value
                    password    = $currentCertificate.Password
                }

                Invoke-MgBetaUploadIdentityApiConnectorClientCertificate -IdentityApiConnectorId $policy.Id -BodyParameter $params
            }

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
            [array]$getValue = Get-MgBetaIdentityApiConnector `
                -Filter $this.Filter `
                -All `
                -ErrorAction Stop
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
                elseif (-not [string]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
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

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                if ($null -ne $Results.AuthenticationConfiguration)
                {
                    $Results.AuthenticationConfiguration = [ordered]@{
                        dataType        = $Results.AuthenticationConfiguration.dataType
                        Username        = $Results.AuthenticationConfiguration.Username
                        Password        = "New-Object System.Management.Automation.PSCredential('Password', (ConvertTo-SecureString ('Please insert a valid Password') -AsPlainText -Force));"
                        CertificateList = $Results.AuthenticationConfiguration.CertificateList
                    }

                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AuthenticationConfiguration `
                        -CIMInstanceName 'MicrosoftGraphApiAuthenticationConfigurationBase'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AuthenticationConfiguration = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AuthenticationConfiguration') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('AuthenticationConfiguration')

                # Replace the main password variable.
                $currentDSCBlock = $currentDSCBlock.Replace('"New-Object System.', 'New-Object System.').Replace(') -AsPlainText -Force));";', ') -AsPlainText -Force));')

                # Replace the certificate variables.
                $currentDSCBlock = $currentDSCBlock.Replace("'New-Object System.", 'New-Object System.').Replace(" -Force))'", ' -Force))')
                $currentDSCBlock = $currentDSCBlock.Replace("(ConvertTo-SecureString (''", "(ConvertTo-SecureString ('").Replace("''Password''", "'Password'").Replace("'') -AsPlainText", "') -AsPlainText")
                $currentDSCBlock = $currentDSCBlock.Replace(''') -AsPlainText -Force))"', "') -AsPlainText -Force))")

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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('Password', 'Pkcs12Value')
        }
    }

    hidden [AADIdentityAPIConnector] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADIdentityAPIConnector])
        {
            return $Values
        }

        $result = [AADIdentityAPIConnector]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphApiAuthenticationConfigurationBase
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the authentication configuration.')]
    [ValidateSet('#microsoft.graph.basicAuthentication', '#microsoft.graph.pkcs12Certificate')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('The username of the basic authentication configuration')]
    [System.String] $Username

    [DscProperty()]
    [System.ComponentModel.Description('The password of the basic authentication configuration')]
    [System.Management.Automation.PSCredential] $Password

    [DscProperty()]
    [System.ComponentModel.Description('The certificates uploaded to the API connector')]
    [MSFT_AADIdentityAPIConnectionCertificate[]] $CertificateList
}

class MSFT_AADIdentityAPIConnectionCertificate
{
    [DscProperty()]
    [System.ComponentModel.Description('Pkcs12Value of the certificate as a secure string in Base64 encoding')]
    [System.Management.Automation.PSCredential] $Pkcs12Value

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Thumbprint of the certificate in Base64 encoding')]
    [System.String] $Thumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Password of the certificate as a secure string')]
    [System.Management.Automation.PSCredential] $Password

    [DscProperty()]
    [System.ComponentModel.Description('Tells if the certificate is in use or not')]
    [System.Nullable[System.Boolean]] $IsActive
}
