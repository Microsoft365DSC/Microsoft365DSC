using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOOMEConfiguration : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the OME Configuration policy that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The BackgroundColor parameter specifies the background color')]
    [System.String] $BackgroundColor

    [DscProperty()]
    [System.ComponentModel.Description('The DisclaimerText parameter specifies the disclaimer text in the email that contains the encrypted message')]
    [System.String] $DisclaimerText

    [DscProperty()]
    [System.ComponentModel.Description('The EmailText parameter specifies the default text that accompanies encrypted email messages.')]
    [System.String] $EmailText

    [DscProperty()]
    [System.ComponentModel.Description('The ExternalMailExpiryInDays parameter specifies the number of days that the encrypted message is available to external recipients in the Microsoft 365 portal. A valid value is an integer from 0 to 730.')]
    [System.Nullable[System.UInt32]] $ExternalMailExpiryInDays

    [DscProperty()]
    [System.ComponentModel.Description('The IntroductionText parameter specifies the default text that accompanies encrypted email messages.')]
    [System.String] $IntroductionText

    [DscProperty()]
    [System.ComponentModel.Description('The OTPEnabled parameter specifies whether to allow recipients to use a one-time passcode to view encrypted messages.')]
    [System.Nullable[System.Boolean]] $OTPEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The PortalText parameter specifies the text that appears at the top of the encrypted email viewing portal.')]
    [System.String] $PortalText

    [DscProperty()]
    [System.ComponentModel.Description('The PrivacyStatementUrl parameter specifies the Privacy Statement link in the encrypted email notification message.')]
    [System.String] $PrivacyStatementUrl

    [DscProperty()]
    [System.ComponentModel.Description('The ReadButtonText parameter specifies the text that appears on the ''Read the message'' button. ')]
    [System.String] $ReadButtonText

    [DscProperty()]
    [System.ComponentModel.Description('The SocialIdSignIn parameter specifies whether a user is allowed to view an encrypted message in the Microsoft 365 admin center using their own social network id (Google, Yahoo, and Microsoft account).')]
    [System.Nullable[System.Boolean]] $SocialIdSignIn

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this Outbound connector should exist.')]
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
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    [EXOOMEConfiguration] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOOMEConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting OME Configuration for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                #Get-OMEConfiguration do NOT accept ErrorAction parameter
                $OMEConfiguration = Get-OMEConfiguration -Identity $this.Identity 2>&1
                $errorRecord = @($OMEConfiguration | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] })
                if ($errorRecord.Count -gt 0)
                {
                    if (Test-M365DSCNotFoundError -ErrorRecord $errorRecord[0])
                    {
                        Write-Verbose -Message "OMEConfiguration $($this.Identity) does not exist."
                        return $this.AsResult($nullReturn)
                    }

                    throw $OMEConfiguration
                }

                if ($null -eq $OMEConfiguration)
                {
                    Write-Verbose -Message "OMEConfiguration $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $OMEConfiguration = $this.ExportedInstance
            }

            Write-Verbose -Message "Found OME Configuration $($this.Identity)"

            $result = @{
                Identity                 = $this.Identity
                BackgroundColor          = $OMEConfiguration.BackgroundColor
                DisclaimerText           = $OMEConfiguration.DisclaimerText
                EmailText                = $OMEConfiguration.EmailText
                ExternalMailExpiryInDays = $OMEConfiguration.ExternalMailExpiryInterval.Days
                #                Image                        = $OMEConfiguration.Image
                IntroductionText         = $OMEConfiguration.IntroductionText
                OTPEnabled               = $OMEConfiguration.OTPEnabled
                PortalText               = $OMEConfiguration.PortalText
                PrivacyStatementUrl      = $OMEConfiguration.PrivacyStatementUrl
                ReadButtonText           = $OMEConfiguration.ReadButtonText
                SocialIdSignIn           = $OMEConfiguration.SocialIdSignIn
                Credential               = $this.Credential
                Ensure                   = 'Present'
                ApplicationId            = $this.ApplicationId
                CertificateThumbprint    = $this.CertificateThumbprint
                CertificatePath          = $this.CertificatePath
                CertificatePassword      = $this.CertificatePassword
                ManagedIdentity          = $this.ManagedIdentity
                TenantId                 = $this.TenantId
                AccessTokens             = $this.AccessTokens
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        Write-Verbose -Message "Setting configuration of OME Configuration for $($this.Identity)"

        $null = $this.Connect('ExchangeOnline')

        $OMEConfigurations = Get-OMEConfiguration
        $OMEConfiguration = $OMEConfigurations | Where-Object -FilterScript { $_.Identity -eq $this.Identity }
        $OMEConfigurationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        #ExternalMailExpiryInDays cannot be updated in the default OME configuration
        if ('OME Configuration' -eq $this.Identity)
        {
            $OMEConfigurationParams.Remove('ExternalMailExpiryInDays') | Out-Null
        }
        if ($this.Ensure -eq 'Present' -and $null -eq $OMEConfiguration)
        {
            throw "OME Configuration {$($this.Identity)} does not exist. Exchange Online offers no " + `
                'cmdlet to create one. Only the configuration provided by the service can be managed.'
        }
        elseif ($this.Ensure -eq 'Present' -and $null -ne $OMEConfiguration)
        {
            Write-Verbose -Message "Setting OME Configuration $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $OMEConfigurationParams)"
            Set-OMEConfiguration @OMEConfigurationParams -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Absent' -and $null -ne $OMEConfiguration)
        {
            Write-Verbose -Message "Removing OME Configuration $($this.Identity)"
            Remove-OMEConfiguration -Identity $this.Identity -Confirm:$false
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

        #Ensure the proper dependencies are installed in the current environment.
        Confirm-M365DSCDependencies

        #region Telemetry
        $this.AddTelemetry('Export')

        #endregion
        try
        {
            #Using 2>&1 to redirect Error stream to variable because Set-Perimeter do not inlude ErrorAction
            $OMEConfigurations = Get-OMEConfiguration 2>&1
            if ($null -ne ($OMEConfigurations | Where-Object { $_.GetType().Name -like '*ErrorRecord*' }))
            {
                throw $OMEConfigurations
            }

            [Array]$OMEConfigurations = $OMEConfigurations
            $dscContent = [System.Text.StringBuilder]::new()

            if ($OMEConfigurations.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($OMEConfiguration in $OMEConfigurations)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($OMEConfigurations.Length)] $($OMEConfiguration.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $OMEConfiguration.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $OMEConfiguration
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

    hidden [EXOOMEConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOOMEConfiguration])
        {
            return $Values
        }

        $result = [EXOOMEConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
