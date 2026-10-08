using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class PPPowerAppsEnvironment : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name for the PowerApps environment')]
    [System.String] $DisplayName

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Location of the PowerApps environment.')]
    [ValidateSet('canada', 'unitedstates', 'europe', 'asia', 'australia', 'india', 'japan', 'unitedkingdom', 'unitedstatesfirstrelease', 'southamerica', 'france', 'usgov', 'unitedarabemirates', 'germany', 'switzerland', 'norway', 'korea', 'southafrica')]
    [System.String] $Location

    [DscProperty()]
    [System.ComponentModel.Description('Type of environment.')]
    [System.String] $EnvironmentType

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('SKU associated with the environment.')]
    [ValidateSet('Production', 'Standard', 'Trial', 'Sandbox', 'SubscriptionBasedTrial', 'Teams', 'Developer', 'Basic', 'Default')]
    [System.String] $EnvironmentSKU

    [DscProperty()]
    [System.ComponentModel.Description('The switch to provision a Dataverse database when creating the environment. If set, LanguageName and CurrencyName are mandatory to pass as arguments.')]
    [System.Nullable[System.Boolean]] $ProvisionDatabase

    [DscProperty()]
    [System.ComponentModel.Description('The default languages for the database, use Get-AdminPowerAppCdsDatabaseLanguages to get the support values.')]
    [ValidateSet('1033', '1025', '1069', '1026', '1027', '3076', '2052', '1028', '1050', '1029', '1030', '1043', '1061', '1035', '1036', '1110', '1031', '1032', '1037', '1081', '1038', '1040', '1041', '1087', '1042', '1062', '1063', '1044', '1045', '1046', '2070', '1048', '1049', '2074', '1051', '1060', '3082', '1053', '1054', '1055', '1058', '1066', '3098', '1086', '1057')]
    [System.String] $LanguageName

    [DscProperty()]
    [System.ComponentModel.Description('The default currency for the database, use Get-AdminPowerAppCdsDatabaseCurrencies to get the supported values.')]
    [ValidateSet('KZT', 'ZAR', 'ETB', 'AED', 'BHD', 'DZD', 'EGP', 'IQD', 'JOD', 'KWD', 'LBP', 'LYD', 'MAD', 'OMR', 'QAR', 'SAR', 'SYP', 'TND', 'YER', 'CLP', 'INR', 'AZN', 'RUB', 'BYN', 'BGN', 'NGN', 'BDT', 'CNY', 'EUR', 'BAM', 'USD', 'CZK', 'GBP', 'DKK', 'CHF', 'MVR', 'BTN', 'XCD', 'AUD', 'BZD', 'CAD', 'HKD', 'IDR', 'JMD', 'MYR', 'NZD', 'PHP', 'SGD', 'TTD', 'XDR', 'ARS', 'BOB', 'COP', 'CRC', 'CUP', 'DOP', 'GTQ', 'HNL', 'MXN', 'NIO', 'PAB', 'PEN', 'PYG', 'UYU', 'VES', 'IRR', 'XOF', 'CDF', 'XAF', 'HTG', 'ILS', 'HUF', 'AMD', 'ISK', 'JPY', 'GEL', 'KHR', 'KRW', 'KGS', 'LAK', 'MKD', 'MNT', 'BND', 'MMK', 'NOK', 'NPR', 'PKR', 'PLN', 'AFN', 'BRL', 'MDL', 'RON', 'RWF', 'SEK', 'LKR', 'SOS', 'ALL', 'RSD', 'KES', 'TJS', 'THB', 'ERN', 'TMT', 'BWP', 'TRY', 'UAH', 'UZS', 'VND', 'MOP', 'TWD')]
    [System.String] $CurrencyName

    [DscProperty()]
    [System.ComponentModel.Description('Only accepted value is ''Present''.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Power Platform Admin')]
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
    [System.ComponentModel.Description('Access tokens used for authentication in scenarios requiring multiple tokens.')]
    [System.String[]] $AccessTokens

    [PPPowerAppsEnvironment] Get()
    {
        $nullReturn = $null
        $environment = $null
        $LanguageNameparam = $null
        $ProvisionDatabaseparam = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [PPPowerAppsEnvironment]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for PowerApps Environment {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.properties.displayName -ne $this.DisplayName)
            {
                $null = $this.Connect('PowerPlatformREST')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $environment = $this.FindEnvironment()
            }
            else
            {
                $environment = $this.ExportedInstance
            }

            if ($null -eq $environment)
            {
                Write-Verbose -Message "Could not find PowerApps Environment {$($this.DisplayName)}"
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found PowerApps Environment {$($this.DisplayName)}"
            if ($null -ne $environment.properties.linkedEnvironmentMetadata)
            {
                $ProvisionDatabaseparam = $true
                $LanguageNameparam = $environment.properties.linkedEnvironmentMetadata.baseLanguage
            }

            $envSku = $environment.properties.EnvironmentSKU
            if ($envSku -eq 'Notspecified')
            {
                $envSku = 'Teams'
            }
            return $this.AsResult(@{
                DisplayName           = $this.DisplayName
                Location              = $environment.location
                EnvironmentType       = $environment.properties.EnvironmentType
                EnvironmentSKU        = $envSku
                ProvisionDatabase     = $ProvisionDatabaseparam
                LanguageName          = $LanguageNameparam
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

        Write-Verbose -Message "Setting configuration for PowerApps Environment {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            # DEPRECATED
            if ($this.EnvironmentSKU -in @('Basic', 'Standard'))
            {
                throw "EnvironmentSKU {$($this.EnvironmentSKU)} is a legacy type and cannot be used to create new environments."
            }

            Write-Verbose -Message "Creating new PowerApps environment {$($this.DisplayName)}"
            try
            {
                $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                    '/providers/Microsoft.BusinessAppPlatform/environments?api-version=2020-08-01&id=/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments'

                $newParameters = @{
                    location   = $this.Location
                    properties = @{
                        displayName     = $this.DisplayName
                        description     = ''
                        environmentSku  = $this.EnvironmentSku
                        environmentType = $this.EnvironmentType
                    }
                }

                if ($this.ProvisionDatabase)
                {
                    if ([System.String]::IsNullOrEmpty($this.CurrencyName) -or [System.String]::IsNullOrEmpty($this.LanguageName))
                    {
                        throw "Provisioning a Dataverse database for {$($this.DisplayName)} requires CurrencyName and LanguageName."
                    }

                    $newParameters.properties['linkedEnvironmentMetadata'] = @{
                        baseLanguage = $this.LanguageName
                        currency     = @{
                            code = $this.CurrencyName
                        }
                    }
                    $newParameters.properties['databaseType'] = 'CommonDataService'
                }
                if ($this.EnvironmentSku -eq 'Developer' -and -not $this.ProvisionDatabase)
                {
                    throw 'Developer environments must always include Dataverse provisioning parameters.'
                }
                Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'POST' -Body $newParameters
            }
            catch
            {
                Write-Verbose -Message "An error occured trying to create new PowerApps Environment {$($this.DisplayName)}"
                throw $_
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Warning -Message "Resource doesn't support updating existing environments. Please delete and recreate {$($this.DisplayName)}"
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing existing instance of PowerApps environment {$($this.DisplayName)}"
            $environment = $this.FindEnvironment()
            $environmentUri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                "/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/$($environment.name)"

            Invoke-M365DSCPowerPlatformRESTWebRequest -Uri "$environmentUri/validateDelete?api-version=2018-01-01" -Method 'POST'
            Invoke-M365DSCPowerPlatformRESTWebRequest -Uri "$environmentUri`?api-version=2018-01-01" -Method 'DELETE'
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

        $ConnectionMode = $this.Connect('PowerPlatformREST')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                "/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments?`$expand=permissions&api-version=2016-11-01"

            [array]$environments = Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'GET'
            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1

            if ($environments.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($environment in $environments.value)
            {
                if ($environment.properties.environmentType -ne 'Default')
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "    |---[$i/$($environments.value.Count)] $($environment.properties.displayName)" -DeferWrite
                    $environmentTypeValue = $environment.properties.environmentType
                    if ($environmentTypeValue -eq 'Notspecified')
                    {
                        $environmentTypeValue = 'Teams'
                    }
                    $Params = @{
                        DisplayName           = $environment.properties.displayName
                        Location              = $environment.location
                        EnvironmentSku        = $environmentTypeValue
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

                    $this.ExportedInstance = $environment
                    $Results = $this.GetForExport($Params)

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
                    Write-M365DSCHost -Message "    |---[$i/$($environments.Count)] Skipping Default Environment $($environment.DisplayName)" -DeferWrite
                    Write-M365DSCHost -Message $Global:M365DSCEmojiInformation
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('CurrencyName')
        }
    }

    hidden [System.Object] FindEnvironment()
    {
        $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
            "/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments?`$expand=permissions&api-version=2016-11-01"

        $environments = (Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'GET').value
        foreach ($environmentInfo in $environments)
        {
            if ($environmentInfo.properties.displayName -eq $this.DisplayName)
            {
                return $environmentInfo
            }
        }

        return $null
    }

    hidden [PPPowerAppsEnvironment] AsResult([System.Object] $Values)
    {
        if ($Values -is [PPPowerAppsEnvironment])
        {
            return $Values
        }

        $result = [PPPowerAppsEnvironment]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
