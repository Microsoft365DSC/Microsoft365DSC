using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOSafeLinksPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the SafeLinks policy that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this policy should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The AdminDisplayName parameter specifies a description for the policy.')]
    [System.String] $AdminDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The AllowClickThrough parameter specifies whether to allow users to click through to the original URL on warning pages.')]
    [System.Nullable[System.Boolean]] $AllowClickThrough

    [DscProperty()]
    [System.ComponentModel.Description('The custom notification text specifies the customized notification text to show to users.')]
    [System.String] $CustomNotificationText

    [DscProperty()]
    [System.ComponentModel.Description('The DeliverMessageAfterScan parameter specifies whether to deliver email messages only after Safe Links scanning is complete. Valid values are: $true: Wait until Safe Links scanning is complete before delivering the message. $false: If Safe Links scanning can''t complete, deliver the message anyway. This is the default value.')]
    [System.Nullable[System.Boolean]] $DeliverMessageAfterScan

    [DscProperty()]
    [System.ComponentModel.Description('The DoNotRewriteUrls parameter specifies a URL that''s skipped by Safe Links scanning. You can specify multiple values separated by commas.')]
    [System.String[]] $DoNotRewriteUrls

    [DscProperty()]
    [System.ComponentModel.Description('The EnableForInternalSenders parameter specifies whether the Safe Links policy is applied to messages sent between internal senders and internal recipients within the same Exchange Online organization.')]
    [System.Nullable[System.Boolean]] $EnableForInternalSenders

    [DscProperty()]
    [System.ComponentModel.Description('The EnableOrganizationBranding parameter specifies whether your organization''s logo is displayed on Safe Links warning and notification pages.')]
    [System.Nullable[System.Boolean]] $EnableOrganizationBranding

    [DscProperty()]
    [System.ComponentModel.Description('The EnableSafeLinksForOffice parameter specifies whether to enable Safe Links protection for supported Office desktop, mobile, or web apps.')]
    [System.Nullable[System.Boolean]] $EnableSafeLinksForOffice

    [DscProperty()]
    [System.ComponentModel.Description('The EnableSafeLinksForTeams parameter specifies whether Safe Links is enabled for Microsoft Teams. Valid values are: $true: Safe Links is enabled for Teams. If a protected user clicks a malicious link in a Teams conversation, group chat, or from channels, a warning page will appear in the default web browser. $false: Safe Links isn''t enabled for Teams. This is the default value.')]
    [System.Nullable[System.Boolean]] $EnableSafeLinksForTeams

    [DscProperty()]
    [System.ComponentModel.Description('The EnableSafeLinksForEmail parameter specifies whether to enable Safe Links protection for email messages. Valid values are: $true: Safe Links is enabled for email. When a user clicks a link in an email, the link is checked by Safe Links. If the link is found to be malicious, a warning page appears in the default web browser. $false: Safe Links isn''t enabled for email. This is the default value.')]
    [System.Nullable[System.Boolean]] $EnableSafeLinksForEmail

    [DscProperty()]
    [System.ComponentModel.Description('The DisableUrlRewrite parameter specifies whether to rewrite (wrap) URLs in email messages. Valid values are: $true: URLs in messages are not rewritten, but messages are still scanned by Safe Links prior to delivery. Time of click checks on links are done using the Safe Links API in supported Outlook clients (currently, Outlook for Windows and Outlook for Mac). Typically, we don''t recommend using this value. $false: URLs in messages are rewritten. API checks still occur on unwrapped URLs in supported clients if the user is in a valid Safe Links policy. This is the default value.')]
    [System.Nullable[System.Boolean]] $DisableUrlRewrite

    [DscProperty()]
    [System.ComponentModel.Description('The ScanUrls parameter specifies whether to enable or disable the scanning of links in email messages. Valid values are: $true: Scanning links in email messages is enabled. $false: Scanning links in email messages is disabled. This is the default value.')]
    [System.Nullable[System.Boolean]] $ScanUrls

    [DscProperty()]
    [System.ComponentModel.Description('The TrackClicks parameter specifies whether to track user clicks related to Safe Links protection of links.')]
    [System.Nullable[System.Boolean]] $TrackClicks

    [DscProperty()]
    [System.ComponentModel.Description('The UseTranslatedNotificationText specifies whether to use Microsoft Translator to automatically localize the custom notification text that you specified with the CustomNotificationText parameter.')]
    [System.Nullable[System.Boolean]] $UseTranslatedNotificationText

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

    [EXOSafeLinksPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOSafeLinksPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SafeLinksPolicy for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $SafeLinksPolicy = Get-SafeLinksPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $SafeLinksPolicy)
                {
                    Write-Verbose -Message "SafeLinksPolicy $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $SafeLinksPolicy = $this.ExportedInstance
            }

            Write-Verbose -Message "Found existing instance of SafeLinksPolicy $($this.Identity)"

            $result = @{
                Identity                   = $SafeLinksPolicy.Identity
                AdminDisplayName           = $SafeLinksPolicy.AdminDisplayName
                AllowClickThrough          = $SafeLinksPolicy.AllowClickThrough
                CustomNotificationText     = $SafeLinksPolicy.CustomNotificationText
                DeliverMessageAfterScan    = $SafeLinksPolicy.DeliverMessageAfterScan
                DoNotRewriteUrls           = $SafeLinksPolicy.DoNotRewriteUrls
                EnableForInternalSenders   = $SafeLinksPolicy.EnableForInternalSenders
                EnableOrganizationBranding = $SafeLinksPolicy.EnableOrganizationBranding
                EnableSafeLinksForTeams    = $SafeLinksPolicy.EnableSafeLinksForTeams
                EnableSafeLinksForEmail    = $SafeLinksPolicy.EnableSafeLinksForEmail
                EnableSafeLinksForOffice   = $SafeLinksPolicy.EnableSafeLinksForOffice
                DisableUrlRewrite          = $SafeLinksPolicy.DisableUrlRewrite
                ScanUrls                   = $SafeLinksPolicy.ScanUrls
                TrackClicks                = $SafeLinksPolicy.TrackClicks
                # The Get-SafeLinksPolicy no longer returns this property
                # UseTranslatedNotificationText = $SafeLinksPolicy.UseTranslatedNotificationText
                Ensure                     = 'Present'
                Credential                 = $this.Credential
                ApplicationId              = $this.ApplicationId
                CertificateThumbprint      = $this.CertificateThumbprint
                CertificatePath            = $this.CertificatePath
                CertificatePassword        = $this.CertificatePassword
                ManagedIdentity            = $this.ManagedIdentity
                TenantId                   = $this.TenantId
                AccessTokens               = $this.AccessTokens
            }

            Write-Verbose -Message "Found SafeLinksPolicy $($this.Identity)"
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

        Write-Verbose -Message "Setting configuration of SafeLinksPolicy for $($this.Identity)"
        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $SafeLinksPolicy = Get-SafeLinksPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
        $SafeLinksPolicyParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ('Present' -eq $this.Ensure -and $null -eq $SafeLinksPolicy)
        {
            $SafeLinksPolicyParams += @{
                Name = $SafeLinksPolicyParams.Identity
            }
            $SafeLinksPolicyParams.Remove('Identity') | Out-Null
            Write-Verbose -Message "Creating SafeLinksPolicy $($this.Identity)"

            New-SafeLinksPolicy @SafeLinksPolicyParams
        }
        elseif ('Present' -eq $this.Ensure -and $null -ne $SafeLinksPolicy)
        {
            Write-Verbose -Message "Setting SafeLinksPolicy $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $SafeLinksPolicyParams)"

            Set-SafeLinksPolicy @SafeLinksPolicyParams -Confirm:$false
        }
        elseif ('Absent' -eq $this.Ensure -and $null -ne $SafeLinksPolicy)
        {
            Write-Verbose -Message "Removing SafeLinksPolicy $($this.Identity) "
            Remove-SafeLinksPolicy -Identity $this.Identity -Confirm:$false
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

        $dscContent = [System.Text.StringBuilder]::new()

        try
        {
            if (Confirm-ImportedCmdletIsAvailable -CmdletName Get-SafeLinksPolicy)
            {
                [array]$SafeLinksPolicies = Get-SafeLinksPolicy

                if ($SafeLinksPolicies.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }
                $i = 1
                foreach ($SafeLinksPolicy in $SafeLinksPolicies)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "    |---[$i/$($SafeLinksPolicies.Length)] $($SafeLinksPolicy.Name)" -DeferWrite
                    $Params = @{
                        Credential            = $this.Credential
                        Identity              = $SafeLinksPolicy.Identity
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        CertificatePath       = $this.CertificatePath
                        AccessTokens          = $this.AccessTokens
                    }
                    $this.ExportedInstance = $SafeLinksPolicy
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
            }
            else
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle)The current tenant is not registered to allow for Safe Attachment Rules."
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
            ExcludedProperties = @('UseTranslatedNotificationText')
        }
    }

    hidden [EXOSafeLinksPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOSafeLinksPolicy])
        {
            return $Values
        }

        $result = [EXOSafeLinksPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
