using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADTenantDetails : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Telephone number for the organization. Although this property is a string collection, only one number can be set.')]
    [System.String[]] $BusinessPhones

    [DscProperty()]
    [System.ComponentModel.Description('City name of the address for the organization.')]
    [System.String] $City

    [DscProperty()]
    [System.ComponentModel.Description('Email-addresses from the people who should receive Marketing Notifications')]
    [System.String[]] $MarketingNotificationEmails

    [DscProperty()]
    [System.ComponentModel.Description('Postal code of the address for the organization.')]
    [System.String] $PostalCode

    [DscProperty()]
    [System.ComponentModel.Description('The preferred language for the organization. Should follow ISO 639-1 code, for example, en.')]
    [System.String] $PreferredLanguage

    [DscProperty()]
    [System.ComponentModel.Description('The privacy profile of an organization.')]
    [MSFT_privacyProfile] $PrivacyProfile

    [DscProperty()]
    [System.ComponentModel.Description('Email-addresses from the people who should receive Security Compliance Notifications')]
    [System.String[]] $SecurityComplianceNotificationMails

    [DscProperty()]
    [System.ComponentModel.Description('Phone Numbers from the people who should receive Security Notifications')]
    [System.String[]] $SecurityComplianceNotificationPhones

    [DscProperty()]
    [System.ComponentModel.Description('State name of the address for the organization.')]
    [System.String] $State

    [DscProperty()]
    [System.ComponentModel.Description('Street name of the address for organization.')]
    [System.String] $Street

    [DscProperty()]
    [System.ComponentModel.Description('Email-addresses from the people who should receive Technical Notifications')]
    [System.String[]] $TechnicalNotificationMails

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Azure Active Directory Admin')]
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

    [AADTenantDetails] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADTenantDetails]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of AzureAD Tenant Details'

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $aadTenantDetails = Get-MgBetaOrganization -ErrorAction Stop

            Write-Verbose -Message 'Found existing AzureAD Tenant Details'

            $complexPrivacyProfile = [ordered]@{}
            $complexPrivacyProfile.Add('ContactEmail', $aadTenantDetails.PrivacyProfile.ContactEmail)
            $complexPrivacyProfile.Add('StatementUrl', $aadTenantDetails.PrivacyProfile.StatementUrl)
            if ($complexPrivacyProfile.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexPrivacyProfile = $null
            }

            $result = @{
                IsSingleInstance                     = 'Yes'
                BusinessPhones                       = $aadTenantDetails.BusinessPhones
                City                                 = $aadTenantDetails.City
                MarketingNotificationEmails          = $aadTenantDetails.MarketingNotificationEmails
                PostalCode                           = $aadTenantDetails.PostalCode
                PreferredLanguage                    = $aadTenantDetails.PreferredLanguage
                PrivacyProfile                       = $complexPrivacyProfile
                SecurityComplianceNotificationMails  = $aadTenantDetails.SecurityComplianceNotificationMails
                SecurityComplianceNotificationPhones = $aadTenantDetails.SecurityComplianceNotificationPhones
                State                                = $aadTenantDetails.State
                Street                               = $aadTenantDetails.Street
                TechnicalNotificationMails           = $aadTenantDetails.TechnicalNotificationMails
                Credential                           = $this.Credential
                ApplicationId                        = $this.ApplicationId
                TenantId                             = $this.TenantId
                ApplicationSecret                    = $this.ApplicationSecret
                CertificateThumbprint                = $this.CertificateThumbprint
                CertificatePath                      = $this.CertificatePath
                CertificatePassword                  = $this.CertificatePassword
                ManagedIdentity                      = $this.ManagedIdentity
                AccessTokens                         = $this.AccessTokens
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

        Write-Verbose -Message 'Setting configuration of AzureAD Tenant Details'

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $currentParameters.Remove('IsSingleInstance') | Out-Null

        if ($null -ne $this.PrivacyProfile)
        {
            $currentParameters.PrivacyProfile = Rename-M365DSCCimInstanceParameter -Properties $this.PrivacyProfile
        }

        try
        {
            Write-Verbose -Message 'Calling Update-MGBetaOrganization with parameters:'
            Write-Verbose -Message "$(Convert-M365DscHashtableToString -Hashtable $currentParameters)"
            Update-MgBetaOrganization -OrganizationId (Get-MgBetaOrganization).Id -BodyParameter $currentParameters
        }
        catch
        {
            Write-Verbose -Message 'Cannot Set AzureAD Tenant Details'
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
        try
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $aadTenantDetails = Get-MgBetaOrganization -ErrorAction Stop

            $Params = @{
                MarketingNotificationEmails          = $aadTenantDetails.MarketingNotificationEmails
                SecurityComplianceNotificationMails  = $aadTenantDetails.SecurityComplianceNotificationMails
                SecurityComplianceNotificationPhones = $aadTenantDetails.SecurityComplianceNotificationPhones
                TechnicalNotificationMails           = $aadTenantDetails.TechnicalNotificationMails
                IsSingleInstance                     = 'Yes'
                Credential                           = $this.Credential
                ApplicationId                        = $this.ApplicationId
                TenantId                             = $this.TenantId
                ApplicationSecret                    = $this.ApplicationSecret
                CertificateThumbprint                = $this.CertificateThumbprint
                CertificatePath                      = $this.CertificatePath
                CertificatePassword                  = $this.CertificatePassword
                ManagedIdentity                      = $this.ManagedIdentity
                AccessTokens                         = $this.AccessTokens
            }

            $Results = $this.GetForExport($Params)
            if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
            {
                if ($null -ne $Results.PrivacyProfile)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'PrivacyProfile'
                            CimInstanceName = 'privacyProfile'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.PrivacyProfile `
                        -CIMInstanceName 'privacyProfile' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.PrivacyProfile = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('PrivacyProfile') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('PrivacyProfile')
                [void]$dscContent.Append($currentDSCBlock)

                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
            }

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADTenantDetails] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADTenantDetails])
        {
            return $Values
        }

        $result = [AADTenantDetails]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_privacyProfile
{
    [DscProperty()]
    [System.ComponentModel.Description('A valid smtp email address for the privacy statement contact. Not required.')]
    [System.String] $ContactEmail

    [DscProperty()]
    [System.ComponentModel.Description('A valid URL format that begins with http:// or https://. Maximum length is 255 characters. The URL that directs to the company''s privacy statement. Not required.')]
    [System.String] $StatementUrl
}
