using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsMeetingBroadcastConfiguration : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a URL where broadcast event attendees can find support information or FAQs specific to that event. The URL will be displayed to the attendees during the broadcast.')]
    [System.String] $SupportURL

    [DscProperty()]
    [System.ComponentModel.Description('If set to $true, Teams meeting broadcast streams are enabled to take advantage of the network and bandwidth management capabilities of your Software Defined Network (SDN) provider.')]
    [System.Nullable[System.Boolean]] $AllowSdnProviderForBroadcastMeeting

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the Software Defined Network (SDN) provider''s name. This parameter is only required if AllowSdnProviderForBroadcastMeeting is set to $true.')]
    [System.String] $SdnProviderName

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the Software Defined Network (SDN) license identifier. This is required and provided by some SDN providers. This parameter is only required if AllowSdnProviderForBroadcastMeeting is set to $true.')]
    [System.String] $SdnLicenseId

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the Software Defined Network (SDN) provider''s HTTP API endpoint. This information is provided to you by the SDN provider. This parameter is only required if AllowSdnProviderForBroadcastMeeting is set to $true.')]
    [System.String] $SdnApiTemplateUrl

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the Software Defined Network (SDN) provider''s authentication token which is required to use their SDN license. This is required by some SDN providers who will give you the required token. This parameter is only required if AllowSdnProviderForBroadcastMeeting is set to $true.')]
    [System.String] $SdnApiToken

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
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

    [TeamsMeetingBroadcastConfiguration] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsMeetingBroadcastConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of Teams Meeting Broadcast'

        try
        {
            $null = $this.Connect('MicrosoftTeams')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $config = Get-CsTeamsMeetingBroadcastConfiguration -ExposeSDNConfigurationJsonBlob:$true `
                -ErrorAction Stop

            return $this.AsResult(@{
                AllowSdnProviderForBroadcastMeeting = $config.AllowSdnProviderForBroadcastMeeting
                SdnProviderName                     = $config.SdnName
                SdnLicenseId                        = $config.SdnLicenseId
                SdnApiTemplateUrl                   = $config.SdnApiTemplateUrl
                SdnApiToken                         = $config.SdnApiToken
                SupportURL                          = $config.SupportURL
                IsSingleInstance                    = 'Yes'
                Credential                          = $this.Credential
                ApplicationId                       = $this.ApplicationId
                TenantId                            = $this.TenantId
                CertificateThumbprint               = $this.CertificateThumbprint
                CertificatePath                     = $this.CertificatePath
                CertificatePassword                 = $this.CertificatePassword
                ManagedIdentity                     = $this.ManagedIdentity
                AccessTokens                        = $this.AccessTokens
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

        Write-Verbose -Message 'Setting configuration of Teams Meeting Broadcast'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('MicrosoftTeams')

        $SetParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $SetParams.Add('Identity', 'Global')
        $SetParams.Remove('IsSingleInstance') | Out-Null
        Set-CsTeamsMeetingBroadcastConfiguration @SetParams
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

        $ConnectionMode = $this.Connect('MicrosoftTeams')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $dscContent = [System.Text.StringBuilder]::new()
            $params = @{
                IsSingleInstance      = 'Yes'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }
            $Results = $this.GetForExport($Params)
            if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $results.SdnApiToken = '**********'

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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($DesiredValues.SdnApiToken -eq '**********' -or $CurrentValues.SdnApiToken -eq '**********')
                {
                    $ValuesToCheck.Remove('SdnApiToken') | Out-Null
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [TeamsMeetingBroadcastConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsMeetingBroadcastConfiguration])
        {
            return $Values
        }

        $result = [TeamsMeetingBroadcastConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
