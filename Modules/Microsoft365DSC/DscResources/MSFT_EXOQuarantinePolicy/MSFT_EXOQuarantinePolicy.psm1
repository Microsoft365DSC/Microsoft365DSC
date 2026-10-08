using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOQuarantinePolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the QuarantinePolicy you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The EndUserQuarantinePermissionsValue parameter specifies the end-user permissions for the quarantine policy.')]
    [System.Nullable[System.UInt32]] $EndUserQuarantinePermissionsValue

    [DscProperty()]
    [System.ComponentModel.Description('The ESNEnabled parameter specifies whether to enable quarantine notifications (formerly known as end-user spam notifications) for the policy.')]
    [System.Nullable[System.Boolean]] $ESNEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The MultiLanguageCustomDisclaimer parameter specifies the custom disclaimer text to use near the bottom of quarantine notifications.')]
    [System.String[]] $MultiLanguageCustomDisclaimer

    [DscProperty()]
    [System.ComponentModel.Description('The MultiLanguageSenderName parameter specifies the email sender''s display name to use in quarantine notifications.')]
    [System.String[]] $MultiLanguageSenderName

    [DscProperty()]
    [System.ComponentModel.Description('The MultiLanguageSetting parameter specifies the language of quarantine notifications.')]
    [System.String[]] $MultiLanguageSetting

    [DscProperty()]
    [System.ComponentModel.Description('The OrganizationBrandingEnabled parameter enables or disables organization branding in the end-user quarantine notification messages.')]
    [System.Nullable[System.Boolean]] $OrganizationBrandingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this QuarantinePolicy should exist.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
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
    [System.ComponentModel.Description('The EndUserSpamNotificationFrequency parameter species how often quarantine notifications are sent to users. Valid values are: 04:00:00 (4 hours),1.00:00:00 (1 day),7.00:00:00 (7 days)')]
    [System.String] $EndUserSpamNotificationFrequency

    [DscProperty()]
    [System.ComponentModel.Description('The QuarantinePolicyType parameter filters the results by the specified quarantine policy type.')]
    [ValidateSet('PolicyQuarantineTag', 'GlobalQuarantineTag')]
    [System.String] $QuarantinePolicyType

    [DscProperty()]
    [System.ComponentModel.Description('This parameter is reserved for internal Microsoft use.')]
    [System.String] $EndUserSpamNotificationFrequencyInDays

    [DscProperty()]
    [System.ComponentModel.Description('This parameter is reserved for internal Microsoft use.')]
    [System.String] $CustomDisclaimer

    [DscProperty()]
    [System.ComponentModel.Description('The EndUserSpamNotificationCustomFromAddress specifies the email address of an existing internal sender to use as the sender for quarantine notifications. To set this parameter back to the default email address quarantine@messaging.microsoft.com, use the value $null.')]
    [System.String] $EndUserSpamNotificationCustomFromAddress

    [DscProperty()]
    [System.ComponentModel.Description('The EsnCustomSubject parameter specifies the text to use in the Subject field of quarantine notifications.This setting is available only in the built-in quarantine policy named DefaultGlobalTag that controls global quarantine policy settings.')]
    [System.String[]] $EsnCustomSubject

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    [EXOQuarantinePolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOQuarantinePolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of QuarantinePolicy for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                if ($this.QuarantinePolicyType -eq 'GlobalQuarantineTag')
                {
                    $QuarantinePolicy = Get-QuarantinePolicy -QuarantinePolicyType GlobalQuarantinePolicy -ErrorAction SilentlyContinue
                }
                else
                {
                    $QuarantinePolicy = Get-QuarantinePolicy -Identity $this.Identity -ErrorAction SilentlyContinue
                }
                if ($null -eq $QuarantinePolicy)
                {
                    Write-Verbose -Message "QuarantinePolicy $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $QuarantinePolicy = $this.ExportedInstance
            }

            Write-Verbose -Message "Found QuarantinePolicy with Identity {$($this.Identity)}"

            if ($QuarantinePolicy.QuarantinePolicyType -eq 'GlobalQuarantineTag')
            {
                $result = @{
                    CustomDisclaimer                         = $QuarantinePolicy.CustomDisclaimer
                    EndUserSpamNotificationFrequency         = $QuarantinePolicy.EndUserSpamNotificationFrequency
                    EndUserSpamNotificationFrequencyInDays   = $QuarantinePolicy.EndUserSpamNotificationFrequencyInDays
                    EndUserSpamNotificationCustomFromAddress = $QuarantinePolicy.EndUserSpamNotificationCustomFromAddress
                    MultiLanguageCustomDisclaimer            = $QuarantinePolicy.MultiLanguageCustomDisclaimer
                    EsnCustomSubject                         = $QuarantinePolicy.EsnCustomSubject
                    MultiLanguageSenderName                  = $QuarantinePolicy.MultiLanguageSenderName
                    MultiLanguageSetting                     = $QuarantinePolicy.MultiLanguageSetting
                    OrganizationBrandingEnabled              = $QuarantinePolicy.OrganizationBrandingEnabled
                    QuarantinePolicyType                     = $QuarantinePolicy.QuarantinePolicyType
                    Identity                                 = $this.Identity
                    Credential                               = $this.Credential
                    Ensure                                   = 'Present'
                    ApplicationId                            = $this.ApplicationId
                    CertificateThumbprint                    = $this.CertificateThumbprint
                    CertificatePath                          = $this.CertificatePath
                    CertificatePassword                      = $this.CertificatePassword
                    ManagedIdentity                          = $this.ManagedIdentity
                    TenantId                                 = $this.TenantId
                    AccessTokens                             = $this.AccessTokens
                }
            }
            else
            {
                $EndUserQuarantinePermissionsValueDecimal = 0
                if ($QuarantinePolicy.EndUserQuarantinePermissions)
                {
                    # Convert string output of EndUserQuarantinePermissions to binary value and then to decimal value
                    # needed for EndUserQuarantinePermissionsValue attribute of New-/Set-QuarantinePolicy cmdlet.
                    # This parameter uses a decimal value that's converted from a binary value.
                    # The binary value corresponds to the list of available permissions in a specific order.
                    # For each permission, the value 1 equals True and the value 0 equals False.

                    $EndUserQuarantinePermissionsBinary = ''
                    if ($QuarantinePolicy.EndUserQuarantinePermissions.Contains('PermissionToViewHeader: True'))
                    {
                        $PermissionToViewHeader = '1'
                    }
                    else
                    {
                        $PermissionToViewHeader = '0'
                    }
                    if ($QuarantinePolicy.EndUserQuarantinePermissions.Contains('PermissionToDownload: True'))
                    {
                        $PermissionToDownload = '1'
                    }
                    else
                    {
                        $PermissionToDownload = '0'
                    }
                    if ($QuarantinePolicy.EndUserQuarantinePermissions.Contains('PermissionToAllowSender: True'))
                    {
                        $PermissionToAllowSender = '1'
                    }
                    else
                    {
                        $PermissionToAllowSender = '0'
                    }
                    if ($QuarantinePolicy.EndUserQuarantinePermissions.Contains('PermissionToBlockSender: True'))
                    {
                        $PermissionToBlockSender = '1'
                    }
                    else
                    {
                        $PermissionToBlockSender = '0'
                    }
                    if ($QuarantinePolicy.EndUserQuarantinePermissions.Contains('PermissionToRequestRelease: True'))
                    {
                        $PermissionToRequestRelease = '1'
                    }
                    else
                    {
                        $PermissionToRequestRelease = '0'
                    }
                    if ($QuarantinePolicy.EndUserQuarantinePermissions.Contains('PermissionToRelease: True'))
                    {
                        $PermissionToRelease = '1'
                    }
                    else
                    {
                        $PermissionToRelease = '0'
                    }
                    if ($QuarantinePolicy.EndUserQuarantinePermissions.Contains('PermissionToPreview: True'))
                    {
                        $PermissionToPreview = '1'
                    }
                    else
                    {
                        $PermissionToPreview = '0'
                    }
                    if ($QuarantinePolicy.EndUserQuarantinePermissions.Contains('PermissionToDelete: True'))
                    {
                        $PermissionToDelete = '1'
                    }
                    else
                    {
                        $PermissionToDelete = '0'
                    }
                    # Concat values to binary value
                    $EndUserQuarantinePermissionsBinary = [System.String]::Concat($PermissionToViewHeader, $PermissionToDownload, $PermissionToAllowSender, $PermissionToBlockSender, $PermissionToRequestRelease, $PermissionToRelease, $PermissionToPreview, $PermissionToDelete)

                    # Convert to Decimal value
                    [int]$EndUserQuarantinePermissionsValueDecimal = [System.Convert]::ToByte($EndUserQuarantinePermissionsBinary, 2)
                }
                $result = @{
                    Identity                          = $this.Identity
                    QuarantinePolicyType              = $QuarantinePolicy.QuarantinePolicyType
                    EndUserQuarantinePermissionsValue = $EndUserQuarantinePermissionsValueDecimal
                    ESNEnabled                        = $QuarantinePolicy.ESNEnabled
                    MultiLanguageCustomDisclaimer     = $QuarantinePolicy.MultiLanguageCustomDisclaimer
                    MultiLanguageSenderName           = $QuarantinePolicy.MultiLanguageSenderName
                    MultiLanguageSetting              = $QuarantinePolicy.MultiLanguageSetting
                    OrganizationBrandingEnabled       = $QuarantinePolicy.OrganizationBrandingEnabled
                    Credential                        = $this.Credential
                    Ensure                            = 'Present'
                    ApplicationId                     = $this.ApplicationId
                    CertificateThumbprint             = $this.CertificateThumbprint
                    CertificatePath                   = $this.CertificatePath
                    CertificatePassword               = $this.CertificatePassword
                    ManagedIdentity                   = $this.ManagedIdentity
                    TenantId                          = $this.TenantId
                    AccessTokens                      = $this.AccessTokens
                }
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

        Write-Verbose -Message "Setting configuration of QuarantinePolicy for $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        if ($this.QuarantinePolicyType -eq 'GlobalQuarantineTag')
        {
            $QuarantinePolicy = Get-QuarantinePolicy -QuarantinePolicyType GlobalQuarantinePolicy
        }
        else
        {
            $QuarantinePolicy = Get-QuarantinePolicy -Identity $this.Identity -ErrorAction SilentlyContinue
        }
        $QuarantinePolicyParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $QuarantinePolicyParams.Remove('QuarantinePolicyType') | Out-Null

        if ($this.Ensure -eq 'Present' -and $null -eq $QuarantinePolicy)
        {
            Write-Verbose -Message "Creating QuarantinePolicy $($this.Identity)."
            $QuarantinePolicyParams.Add('Name', $this.Identity.Split('\')[-1])
            $QuarantinePolicyParams.Remove('Identity') | Out-Null
            New-QuarantinePolicy @QuarantinePolicyParams
        }
        elseif ($this.Ensure -eq 'Present' -and $null -ne $QuarantinePolicy)
        {
            Write-Verbose -Message "Setting QuarantinePolicy $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $QuarantinePolicyParams)"
            if ($this.QuarantinePolicyType -eq 'GlobalQuarantineTag')
            {
                $QuarantinePolicyParams.Remove('Identity') | Out-Null
                if ("$($QuarantinePolicy.Guid)" -eq [System.Guid]::Empty.ToString())
                {
                    New-QuarantinePolicy -Name 'DefaultGlobalTag' -QuarantinePolicyType 'GlobalQuarantinePolicy' @QuarantinePolicyParams
                }
                else
                {
                    $QuarantinePolicy | Set-QuarantinePolicy @QuarantinePolicyParams
                }
            }
            else
            {
                $IdentityValue = $this.Identity.Split('\')
                if ($IdentityValue.Length -gt 1)
                {
                    $IdentityValue = $IdentityValue[1]
                    $QuarantinePolicyParams.Identity = $IdentityValue
                }
                Set-QuarantinePolicy @QuarantinePolicyParams
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $null -ne $QuarantinePolicy)
        {
            Write-Verbose -Message "Removing QuarantinePolicy $($this.Identity)"
            Remove-QuarantinePolicy -Identity $this.Identity
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$QuarantinePolicies = Get-QuarantinePolicy -ErrorAction Stop
            [array]$QuarantinePolicies += Get-QuarantinePolicy -QuarantinePolicyType GlobalQuarantinePolicy -ErrorAction Stop
            if ($QuarantinePolicies.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            foreach ($QuarantinePolicy in $QuarantinePolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($QuarantinePolicies.Length)] $($QuarantinePolicy.Name)" -DeferWrite

                $Params = @{
                    Identity              = $QuarantinePolicy.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    QuarantinePolicyType  = $QuarantinePolicy.QuarantinePolicyType
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $QuarantinePolicy
                $Results = $this.GetForExport($Params)
                $keysToRemove = @()
                foreach ($key in $Results.Keys)
                {
                    if ([System.String]::IsNullOrEmpty($Results.$key))
                    {
                        $keysToRemove += $key
                    }
                }
                foreach ($key in $keysToRemove)
                {
                    $Results.Remove($key) | Out-Null
                }
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
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOQuarantinePolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOQuarantinePolicy])
        {
            return $Values
        }

        $result = [EXOQuarantinePolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
