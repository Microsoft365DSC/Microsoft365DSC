using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOReportSubmissionPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the resource is a single instance, the value must be ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The DisableQuarantineReportingOption parameter allows or prevents users from reporting messages in quarantine.')]
    [System.Nullable[System.Boolean]] $DisableQuarantineReportingOption

    [DscProperty()]
    [System.ComponentModel.Description('The EnableCustomNotificationSender parameter specifies whether a custom sender email address is used for result messages after an admin reviews and marks the reported messages as junk, not junk, or phishing.')]
    [System.Nullable[System.Boolean]] $EnableCustomNotificationSender

    [DscProperty()]
    [System.ComponentModel.Description('The EnableOrganizationBranding parameter specifies whether to show the company logo in the footer of result messages that users receive after an admin reviews and marks the reported messages as junk, not junk, or phishing.')]
    [System.Nullable[System.Boolean]] $EnableOrganizationBranding

    [DscProperty()]
    [System.ComponentModel.Description('The EnableReportToMicrosoft parameter specifies whether Microsoft integrated reporting experience is enabled or disabled.')]
    [System.Nullable[System.Boolean]] $EnableReportToMicrosoft

    [DscProperty()]
    [System.ComponentModel.Description('The EnableThirdPartyAddress parameter specifies whether you''re using third-party reporting tools in Outlook instead of Microsoft tools to send messages to the reporting mailbox in Exchange Online.')]
    [System.Nullable[System.Boolean]] $EnableThirdPartyAddress

    [DscProperty()]
    [System.ComponentModel.Description('The EnableUserEmailNotification parameter species whether users receive result messages after an admin reviews and marks the reported messages as junk, not junk, or phishing.')]
    [System.Nullable[System.Boolean]] $EnableUserEmailNotification

    [DscProperty()]
    [System.ComponentModel.Description('The JunkReviewResultMessage parameter specifies the custom text to use in result messages after an admin reviews and marks the reported messages as junk.')]
    [System.String] $JunkReviewResultMessage

    [DscProperty()]
    [System.ComponentModel.Description('The NotJunkReviewResultMessage parameter specifies the custom text to use in result messages after an admin reviews and marks the reported messages as not junk.')]
    [System.String] $NotJunkReviewResultMessage

    [DscProperty()]
    [System.ComponentModel.Description('The NotificationFooterMessage parameter specifies the custom footer text to use in email notifications after an admin reviews and marks the reported messages as junk, not junk, or phishing.')]
    [System.String] $NotificationFooterMessage

    [DscProperty()]
    [System.ComponentModel.Description('The NotificationSenderAddress parameter specifies the sender email address to use in result messages after an admin reviews and marks the reported messages as junk, not junk, or phishing.')]
    [System.String] $NotificationSenderAddress

    [DscProperty()]
    [System.ComponentModel.Description('The PhishingReviewResultMessage parameter specifies the custom text to use in result messages after an admin reviews and marks the reported messages as phishing.')]
    [System.String] $PhishingReviewResultMessage

    [DscProperty()]
    [System.ComponentModel.Description('The PostSubmitMessage parameter specifies the custom pop-up message text to use in Outlook notifications after users report messages.')]
    [System.String] $PostSubmitMessage

    [DscProperty()]
    [System.ComponentModel.Description('The PostSubmitMessageEnabled parameter enables or disables the pop-up Outlook notifications that users see after they report messages using Microsoft reporting tools.')]
    [System.Nullable[System.Boolean]] $PostSubmitMessageEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The PostSubmitMessage parameter parameter specifies the custom pop-up message title to use in Outlook notifications after users report messages.')]
    [System.String] $PostSubmitMessageTitle

    [DscProperty()]
    [System.ComponentModel.Description('The PreSubmitMessage parameter specifies the custom pop-up message text to use in Outlook notifications before users report messages. ')]
    [System.String] $PreSubmitMessage

    [DscProperty()]
    [System.ComponentModel.Description('The PreSubmitMessageEnabled parameter enables or disables the pop-up Outlook notifications that users see before they report messages using Microsoft reporting tools.')]
    [System.Nullable[System.Boolean]] $PreSubmitMessageEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The PreSubmitMessage parameter parameter specifies the custom pop-up message title to use in Outlook notifications before users report messages.')]
    [System.String] $PreSubmitMessageTitle

    [DscProperty()]
    [System.ComponentModel.Description('The ReportJunkAddresses parameter specifies the email address of the reporting mailbox in Exchange Online to receive user reported messages in reporting in Outlook using Microsoft or third-party reporting tools in Outlook.')]
    [System.String[]] $ReportJunkAddresses

    [DscProperty()]
    [System.ComponentModel.Description('The ReportJunkToCustomizedAddress parameter specifies whether to send user reported messages from Outlook (using Microsoft or third-party reporting tools) to the reporting mailbox as part of reporting in Outlook. ')]
    [System.Nullable[System.Boolean]] $ReportJunkToCustomizedAddress

    [DscProperty()]
    [System.ComponentModel.Description('The ReportNotJunkAddresses parameter specifies the email address of the reporting mailbox in Exchange Online to receive user reported messages in reporting in Outlook using Microsoft or third-party reporting tools in Outlook.')]
    [System.String[]] $ReportNotJunkAddresses

    [DscProperty()]
    [System.ComponentModel.Description('The ReportNotJunkToCustomizedAddress parameter specifies whether to send user reported messages from Outlook (using Microsoft or third-party reporting tools) to the reporting mailbox as part of reporting in Outlook.')]
    [System.Nullable[System.Boolean]] $ReportNotJunkToCustomizedAddress

    [DscProperty()]
    [System.ComponentModel.Description('The ReportPhishAddresses parameter specifies the email address of the reporting mailbox in Exchange Online to receive user reported messages in reporting in Outlook using Microsoft or third-party reporting tools in Outlook.')]
    [System.String[]] $ReportPhishAddresses

    [DscProperty()]
    [System.ComponentModel.Description('The ReportPhishToCustomizedAddress parameter specifies whether to send user reported messages from Outlook (using Microsoft or third-party reporting tools) to the reporting mailbox as part of reporting in Outlook.')]
    [System.Nullable[System.Boolean]] $ReportPhishToCustomizedAddress

    [DscProperty()]
    [System.ComponentModel.Description('Use the ThirdPartyReportAddresses parameter to specify the email address of the reporting mailbox when you''re using a third-party product for user submissions instead of reporting in Outlook.')]
    [System.String[]] $ThirdPartyReportAddresses

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $ReportChatMessageEnabled

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $ReportChatMessageToCustomizedAddressEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this report submission policy should exist.')]
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

    [EXOReportSubmissionPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOReportSubmissionPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of ReportSubmissionPolicy'

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'
                $nullReturn.IsSingleInstance = 'Yes'

                $ReportSubmissionPolicy = Get-ReportSubmissionPolicy -ErrorAction SilentlyContinue
                if ($null -eq $ReportSubmissionPolicy)
                {
                    Write-Verbose -Message 'ReportSubmissionPolicy does not exist.'
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $ReportSubmissionPolicy = $this.ExportedInstance
            }

            Write-Verbose -Message 'Found ReportSubmissionPolicy'

            $result = @{
                IsSingleInstance                            = 'Yes'
                DisableQuarantineReportingOption            = $ReportSubmissionPolicy.DisableQuarantineReportingOption
                EnableCustomNotificationSender              = $ReportSubmissionPolicy.EnableCustomNotificationSender
                EnableOrganizationBranding                  = $ReportSubmissionPolicy.EnableOrganizationBranding
                EnableReportToMicrosoft                     = $ReportSubmissionPolicy.EnableReportToMicrosoft
                EnableThirdPartyAddress                     = $ReportSubmissionPolicy.EnableThirdPartyAddress
                EnableUserEmailNotification                 = $ReportSubmissionPolicy.EnableUserEmailNotification
                JunkReviewResultMessage                     = $ReportSubmissionPolicy.JunkReviewResultMessage
                NotJunkReviewResultMessage                  = $ReportSubmissionPolicy.NotJunkReviewResultMessage
                NotificationFooterMessage                   = $ReportSubmissionPolicy.NotificationFooterMessage
                NotificationSenderAddress                   = $ReportSubmissionPolicy.NotificationSenderAddress
                PhishingReviewResultMessage                 = $ReportSubmissionPolicy.PhishingReviewResultMessage
                PostSubmitMessage                           = $ReportSubmissionPolicy.PostSubmitMessage
                PostSubmitMessageEnabled                    = $ReportSubmissionPolicy.PostSubmitMessageEnabled
                PostSubmitMessageTitle                      = $ReportSubmissionPolicy.PostSubmitMessageTitle
                PreSubmitMessage                            = $ReportSubmissionPolicy.PreSubmitMessage
                PreSubmitMessageEnabled                     = $ReportSubmissionPolicy.PreSubmitMessageEnabled
                PreSubmitMessageTitle                       = $ReportSubmissionPolicy.PreSubmitMessageTitle
                ReportJunkAddresses                         = $ReportSubmissionPolicy.ReportJunkAddresses
                ReportJunkToCustomizedAddress               = $ReportSubmissionPolicy.ReportJunkToCustomizedAddress
                ReportNotJunkAddresses                      = $ReportSubmissionPolicy.ReportNotJunkAddresses
                ReportNotJunkToCustomizedAddress            = $ReportSubmissionPolicy.ReportNotJunkToCustomizedAddress
                ReportPhishAddresses                        = $ReportSubmissionPolicy.ReportPhishAddresses
                ReportPhishToCustomizedAddress              = $ReportSubmissionPolicy.ReportPhishToCustomizedAddress
                ThirdPartyReportAddresses                   = $ReportSubmissionPolicy.ThirdPartyReportAddresses
                ReportChatMessageEnabled                    = $ReportSubmissionPolicy.ReportChatMessageEnabled
                ReportChatMessageToCustomizedAddressEnabled = $ReportSubmissionPolicy.ReportChatMessageToCustomizedAddressEnabled
                Credential                                  = $this.Credential
                Ensure                                      = 'Present'
                ApplicationId                               = $this.ApplicationId
                CertificateThumbprint                       = $this.CertificateThumbprint
                CertificatePath                             = $this.CertificatePath
                CertificatePassword                         = $this.CertificatePassword
                ManagedIdentity                             = $this.ManagedIdentity
                TenantId                                    = $this.TenantId
                AccessTokens                                = $this.AccessTokens
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
        Write-Verbose -Message 'Setting configuration of ReportSubmissionPolicy'

        $currentReportSubmissionPolicy = $this.Get().ToHashtable()

        $ReportSubmissionPolicyParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $ReportSubmissionPolicyParams.Remove('IsSingleInstance') | Out-Null
        $ReportSubmissionPolicyParams.Add('Identity', 'DefaultReportSubmissionPolicy') | Out-Null

        if ($this.Ensure -eq 'Present' -and $currentReportSubmissionPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message 'Creating ReportSubmissionPolicy'

            New-ReportSubmissionPolicy
            Set-ReportSubmissionPolicy @ReportSubmissionPolicyParams -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Present' -and $currentReportSubmissionPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Setting ReportSubmissionPolicy with values: $(Convert-M365DscHashtableToString -Hashtable $ReportSubmissionPolicyParams)"
            Set-ReportSubmissionPolicy @ReportSubmissionPolicyParams -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentReportSubmissionPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message 'Removing ReportSubmissionPolicy'
            Remove-ReportSubmissionPolicy -Identity 'DefaultReportSubmissionPolicy'
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
            $ReportSubmissionPolicy = Get-ReportSubmissionPolicy -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $Params = @{
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                CertificatePath       = $this.CertificatePath
                IsSingleInstance      = 'Yes'
                AccessTokens          = $this.AccessTokens
            }
            $this.ExportedInstance = $ReportSubmissionPolicy
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

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOReportSubmissionPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOReportSubmissionPolicy])
        {
            return $Values
        }

        $result = [EXOReportSubmissionPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
