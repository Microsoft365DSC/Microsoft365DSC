using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADNamedLocationPolicy : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Specifies the Odata Type of a Named Location object in Azure Active Directory')]
    [ValidateSet('#microsoft.graph.CountryNamedLocation', '#microsoft.graph.ipNamedLocation', '#microsoft.graph.compliantNetworkNamedLocation')]
    [System.String] $OdataType

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the ID of a Named Location in Azure Active Directory.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the Display Name of a Named Location in Azure Active Directory')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the IP ranges of the Named Location in Azure Active Directory')]
    [System.String[]] $IpRanges

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the isTrusted value for the Named Location (IP ranges only) in Azure Active Directory')]
    [System.Nullable[System.Boolean]] $IsTrusted

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the countries and regions for the Named Location in Azure Active Directory')]
    [System.String[]] $CountriesAndRegions

    [DscProperty()]
    [System.ComponentModel.Description('Determines what method is used to decide which country the user is located in. Possible values are clientIpAddress(default) and authenticatorAppGps.')]
    [ValidateSet('clientIpAddress', 'authenticatorAppGps')]
    [System.String] $CountryLookupMethod

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the includeUnknownCountriesAndRegions value for the Named Location in Azure Active Directory')]
    [System.Nullable[System.Boolean]] $IncludeUnknownCountriesAndRegions

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Azure AD Named Location should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials for the Microsoft Graph delegated permissions.')]
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

    [AADNamedLocationPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADNamedLocationPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AAD Named Location Policy with DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $NamedLocation = $null
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $NamedLocation = Get-MgBetaIdentityConditionalAccessNamedLocation -NamedLocationId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $NamedLocation)
                {
                    try
                    {
                        $NamedLocation = Get-MgBetaIdentityConditionalAccessNamedLocation -ErrorAction Stop | Where-Object -FilterScript { $_.DisplayName -eq $this.DisplayName }
                        if ($NamedLocation.Length -gt 1)
                        {
                            throw "More than one instance of a Named Location Policy with name {$($this.DisplayName)} was found. Please provide the ID parameter."
                        }
                    }
                    catch
                    {
                        $this.LogError($_, 'Error retrieving data:')

                        return $this.AsResult($nullReturn)
                    }
                }
                if ($null -eq $NamedLocation)
                {
                    Write-Verbose "No existing AAD Named Location found with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $NamedLocation = $this.ExportedInstance
            }
            Write-Verbose "Found existing AAD Named Location {$($NamedLocation.DisplayName)}"
            $Result = @{
                OdataType                         = $NamedLocation.'@odata.type'
                Id                                = $NamedLocation.Id
                DisplayName                       = $NamedLocation.DisplayName
                IpRanges                          = $NamedLocation.ipRanges.cidrAddress
                IsTrusted                         = $NamedLocation.isTrusted
                CountriesAndRegions               = [String[]]$NamedLocation.countriesAndRegions
                CountryLookupMethod               = $NamedLocation.countryLookupMethod
                IncludeUnknownCountriesAndRegions = $NamedLocation.includeUnknownCountriesAndRegions
                Ensure                            = 'Present'
                ApplicationSecret                 = $this.ApplicationSecret
                ApplicationId                     = $this.ApplicationId
                TenantId                          = $this.TenantId
                CertificateThumbprint             = $this.CertificateThumbprint
                Credential                        = $this.Credential
                ManagedIdentity                   = $this.ManagedIdentity
                AccessTokens                      = $this.AccessTokens
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
        $NamedLocation = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message 'Setting configuration of AAD Named Location'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        try
        {
            if ($this.Id)
            {
                $NamedLocation = Get-MgBetaIdentityConditionalAccessNamedLocation -NamedLocationId $this.Id -ErrorAction Stop
            }
        }
        catch
        {
            Write-Verbose -Message "Could not retrieve AAD Named Location by ID {$($this.Id)}"
        }
        if ($null -eq $NamedLocation)
        {
            $NamedLocation = Get-MgBetaIdentityConditionalAccessNamedLocation -ErrorAction SilentlyContinue | Where-Object -FilterScript { $_.DisplayName -eq $this.DisplayName }
            if ($NamedLocation.Length -gt 1)
            {
                throw "More than one instance of a Named Location Policy with name {$($this.DisplayName)} was found. Please provide the ID parameter."
            }
        }

        $currentAADNamedLocation = $this.Get().ToHashtable()

        $desiredValues = @{
            '@odata.type' = $this.OdataType
            displayName   = $this.DisplayName
        }
        if ($this.OdataType -eq '#microsoft.graph.ipNamedLocation')
        {
            $desiredValues.Add('isTrusted', $this.IsTrusted)
            $IpRangesValue = @()
            foreach ($IpRange in $this.IpRanges)
            {
                $ipRangeType = '#microsoft.graph.iPv4CidrRange'
                if ($IpRange.Contains(':'))
                {
                    $ipRangeType = '#microsoft.graph.iPv6CidrRange'
                }
                $IpRangesValue += @{
                    '@odata.type' = $ipRangeType
                    cidrAddress   = $IPRange
                }
            }
            if ($IpRangesValue)
            {
                $desiredValues.Add('ipRanges', $IpRangesValue)
            }
        }
        elseif ($this.OdataType -eq '#microsoft.graph.CountryNamedLocation')
        {
            $desiredValues.Add('includeUnknownCountriesAndRegions', $this.IncludeUnknownCountriesAndRegions)
            $desiredValues.Add('countriesAndRegions', $this.CountriesAndRegions)
            $desiredValues.Add('countryLookupMethod', $this.CountryLookupMethod)
        }

        # Named Location should exist but it doesn't
        if ($this.Ensure -eq 'Present' -and $currentAADNamedLocation.Ensure -eq 'Absent')
        {
            $VerboseAttributes = ($desiredValues | Out-String)
            Write-Verbose -Message "Creating New AAD Named Location {$($this.Displayname)} with attributes: $VerboseAttributes"

            New-MgBetaIdentityConditionalAccessNamedLocation -BodyParameter $desiredValues | Out-Null
        }
        # Named Location should exist and will be configured to desired state
        elseif ($this.Ensure -eq 'Present' -and $currentAADNamedLocation.Ensure -eq 'Present')
        {
            $VerboseAttributes = ($desiredValues | Out-String)
            Write-Verbose -Message "Updating existing AAD Named Location {$($this.Displayname)} with attributes: $VerboseAttributes"

            Update-MgBetaIdentityConditionalAccessNamedLocation -NamedLocationId $currentAADNamedLocation.Id `
                -BodyParameter $desiredValues | Out-Null
        }
        # Named Location exist but should not
        elseif ($this.Ensure -eq 'Absent' -and $CurrentAADNamedLocation.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing AAD Named Location {$($this.Displayname)} with id {$($currentAADNamedLocation.ID)}"

            $attempts = 1
            if ($currentAADNamedLocation.IsTrusted)
            {
                Update-MgBetaIdentityConditionalAccessNamedLocation -NamedLocationId $currentAADNamedLocation.Id `
                    -BodyParameter @{
                        '@odata.type' = $currentAADNamedLocation.OdataType
                        isTrusted     = $false
                    } | Out-Null
                $attempts = 6
            }

            for ($attempt = 1; $attempt -le $attempts; $attempt++)
            {
                try
                {
                    Remove-MgBetaIdentityConditionalAccessNamedLocation -NamedLocationId $currentAADNamedLocation.ID -ErrorAction Stop
                    break
                }
                catch
                {
                    if ($attempt -eq $attempts -or $_.Exception.Message -notlike '*marked as a Trusted location*')
                    {
                        throw
                    }
                    Start-Sleep -Seconds 5
                }
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

        $dscContent = [System.Text.StringBuilder]::new()
        $i = 1

        try
        {
            $AADNamedLocations = Get-MgBetaIdentityConditionalAccessNamedLocation -Filter $this.Filter -All -ErrorAction Stop
            if ($AADNamedLocations.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($AADNamedLocation in $AADNamedLocations)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AADNamedLocations.Count)] $($AADNamedLocation.DisplayName)" -DeferWrite
                $Params = @{
                    ApplicationSecret     = $this.ApplicationSecret
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    DisplayName           = $AADNamedLocation.DisplayName
                    ID                    = $AADNamedLocation.ID
                    Credential            = $this.Credential
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $AADNamedLocation
                $Results = $this.GetForExport($Params)
                if ($Results.Ensure -eq 'Present')
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
                    $i++
                }
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADNamedLocationPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADNamedLocationPolicy])
        {
            return $Values
        }

        $result = [AADNamedLocationPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
