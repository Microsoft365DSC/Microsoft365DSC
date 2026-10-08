using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCAutoSensitivityLabelRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the Rule.')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the associated Policy.')]
    [System.String] $Policy

    [DscProperty()]
    [System.ComponentModel.Description('The AccessScope parameter specifies a condition for the auto-labeling policy rule that''s based on the access scope of the content. The rule is applied to content that matches the specified access scope. Valid values are: InOrganization, NotInOrganization, None')]
    [ValidateSet('InOrganization', 'NotInOrganization', 'None')]
    [System.String] $AccessScope

    [DscProperty()]
    [System.ComponentModel.Description('The AnyOfRecipientAddressContainsWords parameter specifies a condition for the auto-labeling policy rule that looks for words or phrases in recipient email addresses. You can specify multiple words or phrases separated by commas.')]
    [ValidateLength(0, 128)]
    [System.String] $AnyOfRecipientAddressContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The AnyOfRecipientAddressMatchesPatterns parameter specifies a condition for the auto-labeling policy rule that looks for text patterns in recipient email addresses by using regular expressions.')]
    [ValidateLength(0, 128)]
    [System.String] $AnyOfRecipientAddressMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The ContentContainsSensitiveInformation parameter specifies a condition for the rule that''s based on a sensitive information type match in content. The rule is applied to content that contains the specified sensitive information type.')]
    [MSFT_SCDLPContainsSensitiveInformation] $ContentContainsSensitiveInformation

    [DscProperty()]
    [System.ComponentModel.Description('The ContentExtensionMatchesWords parameter specifies a condition for the auto-labeling policy rule that looks for words in file name extensions. You can specify multiple words separated by commas.')]
    [System.String] $ContentExtensionMatchesWords

    [DscProperty()]
    [System.ComponentModel.Description('The Disabled parameter specifies whether the auto-labeling policy rule is enabled or disabled.')]
    [System.Nullable[System.Boolean]] $Disabled

    [DscProperty()]
    [System.ComponentModel.Description('The DocumentIsPasswordProtected parameter specifies a condition for the auto-labeling policy rule that looks for password protected files (because the contents of the file can''t be inspected). Password detection only works for Office documents and .zip files. ')]
    [System.Nullable[System.Boolean]] $DocumentIsPasswordProtected

    [DscProperty()]
    [System.ComponentModel.Description('The DocumentIsUnsupported parameter specifies a condition for the auto-labeling policy rule that looks for files that can''t be scanned.')]
    [System.Nullable[System.Boolean]] $DocumentIsUnsupported

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAccessScopeAccessScope parameter specifies an exception for the auto-labeling policy rule that''s based on the access scope of the content. The rule isn''t applied to content that matches the specified access scope. Valid values are: InOrganization, NotInOrganization, None')]
    [ValidateSet('InOrganization', 'NotInOrganization', 'None')]
    [System.String] $ExceptIfAccessScope

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAnyOfRecipientAddressContainsWords parameter specifies an exception for the auto-labeling policy rule that looks for words or phrases in recipient email addresses. You can specify multiple words separated by commas.')]
    [ValidateLength(0, 128)]
    [System.String] $ExceptIfAnyOfRecipientAddressContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfAnyOfRecipientAddressMatchesPatterns parameter specifies an exception for the auto-labeling policy rule that looks for text patterns in recipient email addresses by using regular expressions. ')]
    [ValidateLength(0, 128)]
    [System.String] $ExceptIfAnyOfRecipientAddressMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfContentContainsSensitiveInformation parameter specifies an exception for the auto-labeling policy rule that''s based on a sensitive information type match in content. The rule isn''t applied to content that contains the specified sensitive information type.')]
    [MSFT_SCDLPContainsSensitiveInformation] $ExceptIfContentContainsSensitiveInformation

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfContentExtensionMatchesWords parameter specifies an exception for the auto-labeling policy rule that looks for words in file name extensions. You can specify multiple words separated by commas.')]
    [System.String[]] $ExceptIfContentExtensionMatchesWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfDocumentIsPasswordProtected parameter specifies an exception for the auto-labeling policy rule that looks for password protected files (because the contents of the file can''t be inspected). Password detection only works for Office documents and .zip files. ')]
    [System.Nullable[System.Boolean]] $ExceptIfDocumentIsPasswordProtected

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfDocumentIsUnsupported parameter specifies an exception for the auto-labeling policy rule that looks for files that can''t be scanned.')]
    [System.Nullable[System.Boolean]] $ExceptIfDocumentIsUnsupported

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfFrom parameter specifies an exception for the auto-labeling policy rule that looks for messages from specific senders. You can use any value that uniquely identifies the sender.')]
    [System.String[]] $ExceptIfFrom

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfFromAddressContainsWords parameter specifies an exception for the auto-labeling policy rule that looks for words or phrases in the sender''s email address. You can specify multiple words or phrases separated by commas.')]
    [ValidateLength(0, 128)]
    [System.String] $ExceptIfFromAddressContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfFromAddressMatchesPatterns parameter specifies an exception for the auto-labeling policy rule that looks for text patterns in the sender''s email address by using regular expressions. ')]
    [ValidateLength(0, 128)]
    [System.String] $ExceptIfFromAddressMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfFromMemberOf parameter specifies an exception for the auto-labeling policy rule that looks for messages sent by group members. You identify the group members by their email addresses. You can enter multiple values separated by commas.')]
    [System.String[]] $ExceptIfFromMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfHeaderMatchesPatterns parameter specifies an exception for the auto-labeling policy rule that looks for text patterns in a header field by using regular expressions.')]
    [MSFT_SCHeaderPattern] $ExceptIfHeaderMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfProcessingLimitExceeded parameter specifies an exception for the auto-labeling policy rule that looks for files where scanning couldn''t complete.')]
    [System.Nullable[System.Boolean]] $ExceptIfProcessingLimitExceeded

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfRecipientDomainIs parameter specifies an exception for the auto-labeling policy rule that looks for recipients with email address in the specified domains. You can specify multiple domains separated by commas.')]
    [System.String[]] $ExceptIfRecipientDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSenderDomainIs parameter specifies an exception for the auto-labeling policy rule that looks for messages from senders with email address in the specified domains. You can specify multiple values separated by commas.')]
    [System.String[]] $ExceptIfSenderDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSenderIpRanges parameter specifies an exception for the auto-labeling policy rule that looks for senders whose IP addresses matches the specified value, or fall within the specified ranges.')]
    [System.String[]] $ExceptIfSenderIPRanges

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSentTo parameter specifies an exception for the auto-labeling policy rule that looks for recipients in messages. You can use any value that uniquely identifies the recipient. ')]
    [System.String[]] $ExceptIfSentTo

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSentToMemberOf parameter specifies an exception for the auto-labeling policy rule that looks for messages sent to members of distribution groups, dynamic distribution groups, or mail-enabled security groups. You identify the groups by email address. You can specify multiple values separated by commas.')]
    [System.String[]] $ExceptIfSentToMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The ExceptIfSubjectMatchesPatterns parameter specifies an exception for the auto-labeling policy rule that looks for text patterns in the Subject field of messages by using regular expressions.')]
    [ValidateLength(0, 128)]
    [System.String] $ExceptIfSubjectMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The FromAddressContainsWords parameter specifies a condition for the auto-labeling policy rule that looks for words or phrases in the sender''s email address. You can specify multiple words or phrases separated by commas.')]
    [ValidateLength(0, 128)]
    [System.String] $FromAddressContainsWords

    [DscProperty()]
    [System.ComponentModel.Description('The FromAddressMatchesPatterns parameter specifies a condition for the auto-labeling policy rule that looks for text patterns in the sender''s email address by using regular expressions.')]
    [ValidateLength(0, 128)]
    [System.String] $FromAddressMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The HeaderMatchesPatterns parameter specifies a condition for the auto-labeling policy rule that looks for text patterns in a header field by using regular expressions.')]
    [MSFT_SCHeaderPattern] $HeaderMatchesPatterns

    [DscProperty()]
    [System.ComponentModel.Description('The ProcessingLimitExceeded parameter specifies a condition for the auto-labeling policy rule that looks for files where scanning couldn''t complete. You can use this condition to create rules that work together to identify and process messages where the content couldn''t be fully scanned.')]
    [System.Nullable[System.Boolean]] $ProcessingLimitExceeded

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientDomainIs parameter specifies a condition for the auto-labeling policy rule that looks for recipients with email address in the specified domains. You can specify multiple domains separated by commas.')]
    [System.String[]] $RecipientDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('The ReportSeverityLevel parameter specifies the severity level of the incident report for content detections based on the rule. Valid values are: None, Low, Medium, High')]
    [ValidateSet('None', 'Low', 'Medium', 'High')]
    [System.String] $ReportSeverityLevel

    [DscProperty()]
    [System.ComponentModel.Description('The RuleErrorAction parameter specifies what to do if an error is encountered during the evaluation of the rule. Valid values are: Ignore, RetryThenBlock, *blank*')]
    [ValidateSet('Ignore', 'RetryThenBlock', '')]
    [System.String] $RuleErrorAction

    [DscProperty()]
    [System.ComponentModel.Description('The SenderDomainIs parameter specifies a condition for the auto-labeling policy rule that looks for messages from senders with email address in the specified domains. ')]
    [System.String[]] $SenderDomainIs

    [DscProperty()]
    [System.ComponentModel.Description('The SenderIpRanges parameter specifies a condition for the auto-sensitivity policy rule that looks for senders whose IP addresses matches the specified value, or fall within the specified ranges.')]
    [System.String[]] $SenderIPRanges

    [DscProperty()]
    [System.ComponentModel.Description('The SentTo parameter specifies a condition for the auto-sensitivity policy rule that looks for recipients in messages. You can use any value that uniquely identifies the recipient.')]
    [System.String[]] $SentTo

    [DscProperty()]
    [System.ComponentModel.Description('The SentToMemberOf parameter specifies a condition for the auto-labeling policy rule that looks for messages sent to members of distribution groups, dynamic distribution groups, or mail-enabled security groups. You identify the groups by email address.')]
    [System.String[]] $SentToMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('The SubjectMatchesPatterns parameter specifies a condition for the auto-labeling policy rule that looks for text patterns in the Subject field of messages by using regular expressions.')]
    [ValidateLength(0, 128)]
    [System.String] $SubjectMatchesPatterns

    [DscProperty(Key)]
    [System.ComponentModel.Description('Workload the rule is associated with. Value can be: Exchange, SharePoint, OneDriveForBusiness, Applications, Azure, AWS and PowerBI')]
    [ValidateSet('Exchange', 'SharePoint', 'OneDriveForBusiness', 'Applications', 'Azure', 'AWS', 'PowerBI')]
    [System.String] $Workload

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this rule should exist or not.')]
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

    [SCAutoSensitivityLabelRule] Get()
    {
        $anyOfRecipientAddressContainsWordsValue = $null
        $anyOfRecipientAddressMatchesPatternsValue = $null
        $contentExtensionMatchesWordsValue = $null
        $exceptIfContentExtensionMatchesWordsValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCAutoSensitivityLabelRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of DLPCompliancePolicy for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'
                $PolicyRule = Invoke-M365DSCCommand -ScriptBlock { Get-AutoSensitivityLabelRule -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $PolicyRule -or $PolicyRule.Mode -eq 'PendingDeletion')
                {
                    Write-Verbose -Message "AutoSensitivityLabelRule $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $PolicyRule = $this.ExportedInstance
            }

            Write-Verbose "Found existing AutoSensitivityLabelRule $($this.Name)"

            if ($null -ne $PolicyRule.AnyOfRecipientAddressContainsWords -and $PolicyRule.AnyOfRecipientAddressContainsWords.Count -gt 0)
            {
                $anyOfRecipientAddressContainsWordsValue = $PolicyRule.AnyOfRecipientAddressContainsWords.Replace(' ', '').Split(',')
            }

            if ($null -ne $PolicyRule.AnyOfRecipientAddressMatchesPatterns -and $PolicyRule.AnyOfRecipientAddressMatchesPatterns.Count -gt 0)
            {
                $anyOfRecipientAddressMatchesPatternsValue = $PolicyRule.AnyOfRecipientAddressMatchesPatterns
            }

            if ($null -ne $PolicyRule.ContentExtensionMatchesWords -and $PolicyRule.ContentExtensionMatchesWords.Count -gt 0)
            {
                $contentExtensionMatchesWordsValue = $PolicyRule.ContentExtensionMatchesWords.Replace(' ', '').Split(',')
            }

            if ($null -ne $PolicyRule.ExceptIfContentExtensionMatchesWords -and $PolicyRule.ExceptIfContentExtensionMatchesWords.Count -gt 0)
            {
                $exceptIfContentExtensionMatchesWordsValue = $PolicyRule.ExceptIfContentExtensionMatchesWords.Replace(' ', '').Split(',')
            }
            $result = @{
                Name                                         = $PolicyRule.Name
                Policy                                       = $PolicyRule.ParentPolicyName
                Workload                                     = $this.Workload
                AccessScope                                  = $PolicyRule.AccessScope
                AnyOfRecipientAddressContainsWords           = $anyOfRecipientAddressContainsWordsValue
                AnyOfRecipientAddressMatchesPatterns         = $anyOfRecipientAddressMatchesPatternsValue
                Comment                                      = $PolicyRule.Comment
                ContentContainsSensitiveInformation          = $this.ConvertToContainsSensitiveInformation($PolicyRule.ContentContainsSensitiveInformation)
                ContentExtensionMatchesWords                 = $contentExtensionMatchesWordsValue
                Disabled                                     = $PolicyRule.Disabled
                DocumentIsPasswordProtected                  = $PolicyRule.DocumentIsPasswordProtected
                DocumentIsUnsupported                        = $PolicyRule.DocumentIsUnsupported
                ExceptIfAccessScope                          = $PolicyRule.ExceptIfAccessScope
                ExceptIfAnyOfRecipientAddressContainsWords   = $PolicyRule.ExceptIfAnyOfRecipientAddressContainsWords
                ExceptIfAnyOfRecipientAddressMatchesPatterns = $PolicyRule.ExceptIfAnyOfRecipientAddressMatchesPatterns
                ExceptIfContentContainsSensitiveInformation  = $this.ConvertToContainsSensitiveInformation($PolicyRule.ExceptIfContentContainsSensitiveInformation)
                ExceptIfContentExtensionMatchesWords         = $exceptIfContentExtensionMatchesWordsValue
                ExceptIfDocumentIsPasswordProtected          = $PolicyRule.ExceptIfDocumentIsPasswordProtected
                ExceptIfDocumentIsUnsupported                = $PolicyRule.ExceptIfDocumentIsUnsupported
                ExceptIfFrom                                 = $PolicyRule.ExceptIfFrom
                ExceptIfFromAddressContainsWords             = $PolicyRule.ExceptIfFromAddressContainsWords
                ExceptIfFromAddressMatchesPatterns           = $PolicyRule.ExceptIfFromAddressMatchesPatterns
                ExceptIfFromMemberOf                         = $PolicyRule.ExceptIfFromMemberOf
                ExceptIfHeaderMatchesPatterns                = [SCAutoSensitivityLabelRule]::GetHeaderPattern($PolicyRule.ExceptIfHeaderMatchesPatterns)
                ExceptIfProcessingLimitExceeded              = $PolicyRule.ExceptIfProcessingLimitExceeded
                ExceptIfRecipientDomainIs                    = $PolicyRule.ExceptIfRecipientDomainIs
                ExceptIfSenderDomainIs                       = $PolicyRule.ExceptIfSenderDomainIs
                ExceptIfSenderIPRanges                       = $PolicyRule.ExceptIfSenderIPRanges
                ExceptIfSentTo                               = $PolicyRule.ExceptIfSentTo
                ExceptIfSentToMemberOf                       = $PolicyRule.ExceptIfSentToMemberOf
                ExceptIfSubjectMatchesPatterns               = $PolicyRule.ExceptIfSubjectMatchesPatterns
                FromAddressContainsWords                     = $PolicyRule.FromAddressContainsWords
                FromAddressMatchesPatterns                   = $PolicyRule.FromAddressMatchesPatterns
                HeaderMatchesPatterns                        = [SCAutoSensitivityLabelRule]::GetHeaderPattern($PolicyRule.HeaderMatchesPatterns)
                ProcessingLimitExceeded                      = $PolicyRule.ProcessingLimitExceeded
                RecipientDomainIs                            = $PolicyRule.RecipientDomainIs
                ReportSeverityLevel                          = $PolicyRule.ReportSeverityLevel
                RuleErrorAction                              = $PolicyRule.RuleErrorAction
                SenderDomainIs                               = $PolicyRule.SenderDomainIs
                SenderIPRanges                               = $PolicyRule.SenderIPRanges
                SentTo                                       = $PolicyRule.SentTo
                SentToMemberOf                               = $PolicyRule.SentToMemberOf
                SubjectMatchesPatterns                       = $PolicyRule.SubjectMatchesPatterns
                Ensure                                       = 'Present'
                Credential                                   = $this.Credential
                ApplicationId                                = $this.ApplicationId
                TenantId                                     = $this.TenantId
                CertificateThumbprint                        = $this.CertificateThumbprint
                CertificatePath                              = $this.CertificatePath
                CertificatePassword                          = $this.CertificatePassword
                ManagedIdentity                              = $this.ManagedIdentity
                AccessTokens                                 = $this.AccessTokens
            }

            $paramsToRemove = @()
            foreach ($paramName in $result.Keys)
            {
                if ($null -eq $result[$paramName] -or '' -eq $result[$paramName] -or @() -eq $result[$paramName])
                {
                    $paramsToRemove += $paramName
                }
            }

            foreach ($paramName in $paramsToRemove)
            {
                $result.Remove($paramName)
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

        Write-Verbose -Message "Setting configuration of DLPComplianceRule for $($this.Name)"

        #region Telemetry
        $this.AddTelemetry('Set')
        #endregion

        $CurrentRule = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $CurrentRule.Ensure -eq 'Absent')
        {
            Write-Verbose "Rule {$($CurrentRule.Name)} doesn't exists but need to. Creating Rule."
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            if ([System.String]::IsNullOrEmpty($CreationParams.RuleErrorAction))
            {
                $CreationParams.RuleErrorAction = $null
            }
            if ($null -ne $CreationParams.ContentContainsSensitiveInformation)
            {
                $value = @()
                foreach ($item in $CreationParams.ContentContainsSensitiveInformation)
                {
                    if ($null -ne $item.groups)
                    {
                        $value += [SCAutoSensitivityLabelRule]::GetSCDLPSensitiveInformationGroups($item)
                    }
                    else
                    {
                        $value += [SCAutoSensitivityLabelRule]::GetSCDLPSensitiveInformation($item)
                    }
                }
                $CreationParams.ContentContainsSensitiveInformation = $value
            }

            if ($null -ne $CreationParams.ExceptIfContentContainsSensitiveInformation)
            {
                $value = @()
                foreach ($item in $CreationParams.ExceptIfContentContainsSensitiveInformation)
                {
                    if ($null -ne $item.groups)
                    {
                        $value += [SCAutoSensitivityLabelRule]::GetSCDLPSensitiveInformationGroups($item)
                    }
                    else
                    {
                        $value += [SCAutoSensitivityLabelRule]::GetSCDLPSensitiveInformation($item)
                    }
                }
                $CreationParams.ExceptIfContentContainsSensitiveInformation = $value
            }

            Write-Verbose -Message 'Flipping the parent policy to Mode = TestWithoutNotification while we create the rule'
            $parentPolicy = Get-AutoSensitivityLabelPolicy -Identity $this.Policy
            $currentMode = $parentPolicy.Mode
            Set-AutoSensitivityLabelPolicy -Identity $this.Policy -Mode 'TestWithoutNotifications'

            foreach ($key in @('HeaderMatchesPatterns', 'ExceptIfHeaderMatchesPatterns'))
            {
                if ($CreationParams.ContainsKey($key))
                {
                    $CreationParams.$key = [SCAutoSensitivityLabelRule]::NewHeaderPatternParameter($CreationParams.$key)
                }
            }

            Write-Verbose -Message "Calling New-AutoSensitivityLabelRule with Values: $(Convert-M365DscHashtableToString -Hashtable $CreationParams)"
            New-AutoSensitivityLabelRule @CreationParams

            Write-Verbose -Message "Flipping the parent policy back to Mode $currentMode while we create the rule"
            Set-AutoSensitivityLabelPolicy -Identity $this.Policy -Mode $currentMode
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentRule.Ensure -eq 'Present')
        {
            Write-Verbose "Rule {$($CurrentRule.Name)} already exists and needs to. Updating Rule."
            $UpdateParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            if ([System.String]::IsNullOrEmpty($UpdateParams.RuleErrorAction))
            {
                $UpdateParams.RuleErrorAction = $null
            }

            if ($null -ne $UpdateParams.ContentContainsSensitiveInformation)
            {
                $value = @()
                foreach ($item in $UpdateParams.ContentContainsSensitiveInformation)
                {
                    if ($null -ne $item.groups)
                    {
                        $value += [SCAutoSensitivityLabelRule]::GetSCDLPSensitiveInformationGroups($item)
                    }
                    else
                    {
                        $value += [SCAutoSensitivityLabelRule]::GetSCDLPSensitiveInformation($item)
                    }
                }
                $UpdateParams.ContentContainsSensitiveInformation = $value
            }

            if ($null -ne $UpdateParams.ExceptIfContentContainsSensitiveInformation)
            {
                $value = @()
                foreach ($item in $UpdateParams.ExceptIfContentContainsSensitiveInformation)
                {
                    if ($null -ne $item.groups)
                    {
                        $value += [SCAutoSensitivityLabelRule]::GetSCDLPSensitiveInformationGroups($item)
                    }
                    else
                    {
                        $value += [SCAutoSensitivityLabelRule]::GetSCDLPSensitiveInformation($item)
                    }
                }
                $UpdateParams.ExceptIfContentContainsSensitiveInformation = $value
            }

            $UpdateParams.Remove('Name') | Out-Null
            $UpdateParams.Remove('Policy') | Out-Null
            $UpdateParams.Add('Identity', $this.Name)

            Write-Verbose -Message 'Flipping the parent policy to Mode = TestWithoutNotification while we editing the rule'
            $parentPolicy = Get-AutoSensitivityLabelPolicy -Identity $this.Policy
            $currentMode = $parentPolicy.Mode
            Set-AutoSensitivityLabelPolicy -Identity $this.Policy -Mode 'TestWithoutNotifications'

            foreach ($key in @('HeaderMatchesPatterns', 'ExceptIfHeaderMatchesPatterns'))
            {
                if ($UpdateParams.ContainsKey($key))
                {
                    $UpdateParams.$key = [SCAutoSensitivityLabelRule]::NewHeaderPatternParameter($UpdateParams.$key)
                }
            }
            Set-AutoSensitivityLabelRule @UpdateParams

            Write-Verbose -Message "Flipping the parent policy to Mode back to $currentMode while we create the rule"
            Set-AutoSensitivityLabelPolicy -Identity $this.Policy -Mode $currentMode
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentRule.Ensure -eq 'Present')
        {
            Write-Verbose "Rule {$($CurrentRule.Name)} already exists but shouldn't. Deleting Rule."
            Remove-AutoSensitivityLabelRule -Identity $CurrentRule.Name -Confirm:$false
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)
                $logDrift = -not [M365DSCResourceBase]::IsReportContext($PostProcessingArgs)
                foreach ($key in @('ContentContainsSensitiveInformation', 'ExceptIfContentContainsSensitiveInformation'))
                {
                    if ($null -ne $DesiredValues[$key])
                    {
                        if ($null -ne $DesiredValues[$key].groups)
                        {
                            $contentSITS = [SCAutoSensitivityLabelRule]::GetSCDLPSensitiveInformationGroups($DesiredValues[$key])
                            $currentSITS = [SCAutoSensitivityLabelRule]::GetSCDLPSensitiveInformationGroups($CurrentValues[$key])
                            $desiredState = [SCAutoSensitivityLabelRule]::TestContainsSensitiveInformationGroups($contentSITS, $currentSITS, $logDrift)
                        }
                        else
                        {
                            $contentSITS = [SCAutoSensitivityLabelRule]::GetSCDLPSensitiveInformation($DesiredValues[$key])
                            $currentSITS = [SCAutoSensitivityLabelRule]::GetSCDLPSensitiveInformation($CurrentValues[$key])
                            $desiredState = [SCAutoSensitivityLabelRule]::TestContainsSensitiveInformation($contentSITS, $currentSITS, $logDrift)
                        }

                        if ($desiredState)
                        {
                            $DesiredValues.Remove($key)
                            $CurrentValues.Remove($key)
                            $ValuesToCheck.Remove($key)
                        }
                        else
                        {
                            # Sentinel strings force the comparer to flag drift on this key.
                            $DesiredValues[$key] = 'SIT-Drift-Desired'
                            $CurrentValues[$key] = 'SIT-Drift-Current'
                            $ValuesToCheck[$key] = 'SIT-Drift-Desired'
                        }
                    }
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        #region Telemetry
        $this.AddTelemetry('Export')
        #endregion

        try
        {
            [array]$rules = Get-AutoSensitivityLabelRule -ErrorAction Stop | Where-Object { $_.Mode -ne 'PendingDeletion' }

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($rules.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($rule in $rules)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($rules.Length)] $($rule.Name)" -DeferWrite
                $this.ExportedInstance = $rule
                $Results = $this.GetForExport(@{ Name = $rule.name; Policy = $rule.ParentPolicyName; Workload = $rule.LogicalWorkload })
                $rawResults = $Results.Clone()

                if ($null -ne $Results.ContentContainsSensitiveInformation)
                {
                    $complexTypeMapping = @(
                        @{
                            Name            = 'ContentContainsSensitiveInformation'
                            CimInstanceName = 'SCDLPContainsSensitiveInformation'
                        },
                        @{
                            Name            = 'Groups'
                            CimInstanceName = 'SCDLPContainsSensitiveInformationGroup'
                            IsArray         = $true
                        },
                        @{
                            Name            = 'SensitiveInformation'
                            CimInstanceName = 'SCDLPSensitiveInformation'
                            IsArray         = $true
                        },
                        @{
                            Name            = 'Labels'
                            CimInstanceName = 'SCDLPLabel'
                            IsArray         = $true
                        }
                    )

                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ContentContainsSensitiveInformation `
                        -CIMInstanceName 'SCDLPContainsSensitiveInformation' `
                        -ComplexTypeMapping $complexTypeMapping
                    if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                    {
                        $Results.ContentContainsSensitiveInformation = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ContentContainsSensitiveInformation') | Out-Null
                    }
                }

                if ($null -ne $Results.ExceptIfContentContainsSensitiveInformation)
                {
                    $complexTypeMapping = @(
                        @{
                            Name            = 'ExceptIfContentContainsSensitiveInformation'
                            CimInstanceName = 'SCDLPContainsSensitiveInformation'
                        },
                        @{
                            Name            = 'Groups'
                            CimInstanceName = 'SCDLPContainsSensitiveInformationGroup'
                            IsArray         = $true
                        },
                        @{
                            Name            = 'SensitiveInformation'
                            CimInstanceName = 'SCDLPSensitiveInformation'
                            IsArray         = $true
                        },
                        @{
                            Name            = 'Labels'
                            CimInstanceName = 'SCDLPLabel'
                            IsArray         = $true
                        }
                    )

                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ExceptIfContentContainsSensitiveInformation `
                        -CIMInstanceName 'SCDLPContainsSensitiveInformation' `
                        -ComplexTypeMapping $complexTypeMapping
                    if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                    {
                        $Results.ExceptIfContentContainsSensitiveInformation = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ExceptIfContentContainsSensitiveInformation') | Out-Null
                    }
                }

                foreach ($key in @('HeaderMatchesPatterns', 'ExceptIfHeaderMatchesPatterns'))
                {
                    if ($null -ne $Results.$key -and $null -ne $Results.$key.Name)
                    {
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.$key `
                            -CIMInstanceName 'SCHeaderPattern'
                        if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                        {
                            $Results.$key = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove($key) | Out-Null
                        }
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('ContentContainsSensitiveInformation', 'ExceptIfContentContainsSensitiveInformation', 'HeaderMatchesPatterns', 'ExceptIfHeaderMatchesPatterns') `
                    -RawResults $rawResults

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
            if ($_.Exception.Message -like '*is not recognized as the name of a cmdlet*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for this feature."
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

    hidden [System.Collections.Hashtable] ConvertToContainsSensitiveInformation([System.Object] $SensitiveInformation)
    {
        if ($null -eq $SensitiveInformation)
        {
            return $null
        }

        if ($null -ne $SensitiveInformation.groups)
        {
            $shapedGroups = @()
            foreach ($group in $SensitiveInformation.groups)
            {
                $shapedGroup = @{}
                foreach ($key in $group.Keys)
                {
                    $shapedGroup[$key] = $group[$key]
                }

                $shapedTypes = @()
                foreach ($sensitiveType in $group.sensitivetypes)
                {
                    $shapedType = @{}
                    foreach ($key in $sensitiveType.Keys)
                    {
                        if ($key -in @('confidencelevel', 'rulePackId'))
                        {
                            continue
                        }
                        $shapedType[$key] = $sensitiveType[$key]
                    }
                    $shapedTypes += $shapedType
                }

                $shapedGroup.Remove('sensitivetypes') | Out-Null
                if ($shapedTypes.Count -gt 0)
                {
                    $shapedGroup.SensitiveInformation = [array]$shapedTypes
                }
                $shapedGroups += $shapedGroup
            }

            return @{
                Groups   = [array]$shapedGroups
                Operator = $SensitiveInformation.operator
            }
        }

        $shapedInformation = @()
        foreach ($item in $SensitiveInformation)
        {
            $shapedItem = @{}
            foreach ($key in $item.Keys)
            {
                if ($key -in @('confidencelevel', 'rulePackId'))
                {
                    continue
                }
                $shapedItem[$key] = $item[$key]
            }
            $shapedInformation += $shapedItem
        }

        if ($shapedInformation.Count -eq 0)
        {
            return $null
        }

        return @{
            SensitiveInformation = [array]$shapedInformation
        }
    }

    hidden static [System.Collections.Hashtable] GetHeaderPattern([System.Object] $Patterns)
    {
        if ($null -eq $Patterns -or $null -eq $Patterns.Keys)
        {
            return $null
        }

        foreach ($headerName in $Patterns.Keys)
        {
            return @{
                Name  = [System.String]$headerName
                Value = [System.String]$Patterns[$headerName]
            }
        }

        return $null
    }

    hidden static [System.Collections.Hashtable] NewHeaderPatternParameter([System.Object] $Pattern)
    {
        if ($null -eq $Pattern -or [System.String]::IsNullOrEmpty($Pattern.Name))
        {
            return $null
        }

        return @{
            $Pattern.Name = $Pattern.Value
        }
    }

    hidden static [System.Collections.Hashtable] NewMemberLookup([System.Object] $Items, [System.String] $MemberName)
    {
        $lookup = @{}
        foreach ($item in @($Items))
        {
            if ($null -eq $item)
            {
                continue
            }

            $key = [System.String] $item.$MemberName
            if (-not $lookup.ContainsKey($key))
            {
                $lookup[$key] = $item
            }
        }

        return $lookup
    }

    hidden static [System.Boolean] TestContainsSensitiveInformationGroups([System.Object[]] $DesiredValues, [System.Object[]] $CurrentValues, [System.Boolean] $LogDrift)
    {
        $desiredOperator = $DesiredValues.operator
        $currentOperator = $CurrentValues.operator
        if ([System.String] $desiredOperator -ne [System.String] $currentOperator)
        {
            if ($LogDrift)
            {
                $EventMessage = "DLP Compliance Rule was not in the desired state.`r`n" + `
                    "DLP Compliance Rule has invalid value for property operator. " + `
                    "Current value is {$currentOperator} and is expected to be {$desiredOperator}."
                Add-M365DSCEvent -Message $EventMessage -EntryType 'Warning' `
                    -EventID 1 -Source 'SCAutoSensitivityLabelRule'
            }
            return $false
        }

        $currentGroups = [SCAutoSensitivityLabelRule]::NewMemberLookup($CurrentValues.groups, 'name')
        foreach ($group in @($DesiredValues.groups))
        {
            if ($null -eq $group)
            {
                continue
            }

            $groupName = [System.String] $group.name
            $matchingExistingGroup = $currentGroups[$groupName]
            if ($null -eq $matchingExistingGroup)
            {
                Write-Verbose -Message "Sensitive Information Action {$groupName} was not found"
                if ($LogDrift)
                {
                    $EventMessage = "DLP Compliance Rule was not in the desired state.`r`n" + `
                        "An action on {$groupName} Sensitive Information Type is missing."
                    Add-M365DSCEvent -Message $EventMessage -EntryType 'Warning' `
                        -EventID 1 -Source 'SCAutoSensitivityLabelRule'
                }
                return $false
            }

            Write-Verbose -Message "ContainsSensitiveInformationGroup {$groupName} was found"
            $desiredGroupOperator = $group.operator
            $currentGroupOperator = $matchingExistingGroup.operator
            if ([System.String] $desiredGroupOperator -ne [System.String] $currentGroupOperator)
            {
                if ($LogDrift)
                {
                    $EventMessage = "DLP Compliance Rule was not in the desired state.`r`n" + `
                        "Group {$groupName} has invalid value for property operator. " + `
                        "Current value is {$currentGroupOperator} and is expected to be {$desiredGroupOperator}."
                    Add-M365DSCEvent -Message $EventMessage -EntryType 'Warning' `
                        -EventID 1 -Source 'SCAutoSensitivityLabelRule'
                }
                return $false
            }

            $desiredTypes = $group.sensitivetypes
            if ($null -ne $desiredTypes)
            {
                $desiredState = [SCAutoSensitivityLabelRule]::TestContainsSensitiveInformation($desiredTypes, $matchingExistingGroup.sensitivetypes, $LogDrift)
                if ($desiredState -eq $false)
                {
                    return $false
                }
            }

            $desiredLabels = $group.labels
            if ($null -ne $desiredLabels)
            {
                $desiredState = [SCAutoSensitivityLabelRule]::TestContainsSensitiveInformationLabels($desiredLabels, $matchingExistingGroup.labels, $LogDrift)
                if ($desiredState -eq $false)
                {
                    return $false
                }
            }
        }

        return $true
    }

    hidden static [System.Object[]] GetSCDLPSensitiveInformation([System.Object[]] $SensitiveInformationItems)
    {
        $returnValue = @()

        foreach ($item in $SensitiveInformationItems.SensitiveInformation)
        {
            $result = [ordered]@{
                name = $item.name
            }

            if ($null -ne $item.id)
            {
                $result.Add('id', $item.id)
            }

            if ($null -ne $item.maxconfidence)
            {
                $result.Add('maxconfidence', $item.maxconfidence)
            }

            if ($null -ne $item.minconfidence)
            {
                $result.Add('minconfidence', $item.minconfidence)
            }

            if ($null -ne $item.classifiertype)
            {
                $result.Add('classifiertype', $item.classifiertype)
            }

            if ($null -ne $item.mincount)
            {
                $result.Add('mincount', $item.mincount)
            }

            if ($null -ne $item.maxcount)
            {
                $result.Add('maxcount', $item.maxcount)
            }
            $returnValue += $result
        }
        return $returnValue
    }

    hidden static [System.Boolean] TestContainsSensitiveInformationLabels([System.Object[]] $DesiredValues, [System.Object[]] $CurrentValues, [System.Boolean] $LogDrift)
    {
        $currentItems = [SCAutoSensitivityLabelRule]::NewMemberLookup($CurrentValues, 'name')
        foreach ($sit in @($DesiredValues))
        {
            if ($null -eq $sit)
            {
                continue
            }

            $sitName = [System.String] $sit.name
            Write-Verbose -Message "Trying to find existing Sensitive Information labels matching name {$sitName}"
            $matchingExistingRule = $currentItems[$sitName.Replace("''", "'")]
            if ($null -eq $matchingExistingRule)
            {
                Write-Verbose -Message "Sensitive Information label {$sitName} was not found"
                if ($LogDrift)
                {
                    $EventMessage = "DLP Compliance Rule was not in the desired state.`r`n" + `
                        "An action on {$sitName} Sensitive Information label is missing."
                    Add-M365DSCEvent -Message $EventMessage -EntryType 'Warning' `
                        -EventID 1 -Source 'SCAutoSensitivityLabelRule'
                }
                return $false
            }

            Write-Verbose -Message "Sensitive Information label {$sitName} was found"
            foreach ($property in @('id', 'type'))
            {
                $desiredValue = $sit.$property
                $currentValue = $matchingExistingRule.$property
                if ([System.String] $desiredValue -ne [System.String] $currentValue)
                {
                    Write-Verbose -Message "Property {$property} is set to {$currentValue} and is expected to be {$desiredValue}."
                    if ($LogDrift)
                    {
                        $EventMessage = "DLP Compliance Rule was not in the desired state.`r`n" + `
                            "Sensitive Information Action {$sitName} has invalid value for property {$property}. " + `
                            "Current value is {$currentValue} and is expected to be {$desiredValue}."
                        Add-M365DSCEvent -Message $EventMessage -EntryType 'Warning' `
                            -EventID 1 -Source 'SCAutoSensitivityLabelRule'
                    }
                    return $false
                }
            }
        }

        return $true
    }

    hidden static [System.Object[]] GetSCDLPSensitiveInformationGroups([System.Object[]] $SensitiveInformationGroups)
    {
        $returnValue = @()
        $sits = @()
        $groups = @()

        $result = @{
            operator = $SensitiveInformationGroups.operator
        }

        foreach ($group in $SensitiveInformationGroups.groups)
        {
            $myGroup = [ordered]@{
                name = $group.name
            }
            if ($null -ne $group.operator)
            {
                $myGroup.Add('operator', $group.operator)
            }
            $sits = @()
            foreach ($item in $group.SensitiveInformation)
            {
                $sit = [ordered]@{
                    name = $item.name
                }

                if ($null -ne $item.id)
                {
                    $sit.Add('id', $item.id)
                }

                if ($null -ne $item.maxconfidence)
                {
                    $sit.Add('maxconfidence', $item.maxconfidence)
                }

                if ($null -ne $item.minconfidence)
                {
                    $sit.Add('minconfidence', $item.minconfidence)
                }

                if ($null -ne $item.classifiertype)
                {
                    $sit.Add('classifiertype', $item.classifiertype)
                }

                if ($null -ne $item.mincount)
                {
                    $sit.Add('mincount', $item.mincount)
                }

                if ($null -ne $item.maxcount)
                {
                    $sit.Add('maxcount', $item.maxcount)
                }
                $sits += $sit
            }
            if ($sits.Length -gt 0)
            {
                $myGroup.Add('sensitivetypes', $sits)
            }
            $labels = @()
            foreach ($item in $group.labels)
            {
                $label = [ordered]@{
                    name = $item.name
                }

                if ($null -ne $item.id)
                {
                    $label.Add('id', $item.id)
                }

                if ($null -ne $item.type)
                {
                    $label.Add('type', $item.type)
                }
                $labels += $label
            }
            if ($labels.Length -gt 0)
            {
                $myGroup.Add('labels', $labels)
            }
            $groups += $myGroup
        }
        $result.Add('groups', $groups)
        $returnValue += $result
        return $returnValue
    }

    hidden static [System.Boolean] TestContainsSensitiveInformation([System.Object[]] $DesiredValues, [System.Object[]] $CurrentValues, [System.Boolean] $LogDrift)
    {
        $currentItems = [SCAutoSensitivityLabelRule]::NewMemberLookup($CurrentValues, 'name')
        foreach ($sit in @($DesiredValues))
        {
            if ($null -eq $sit)
            {
                continue
            }

            $sitName = [System.String] $sit.name
            Write-Verbose -Message "Trying to find existing Sensitive Information Action matching name {$sitName}"
            $matchingExistingRule = $currentItems[$sitName.Replace("''", "'")]
            if ($null -eq $matchingExistingRule)
            {
                Write-Verbose -Message "Sensitive Information Action {$sitName} was not found"
                if ($LogDrift)
                {
                    $EventMessage = "DLP Compliance Rule was not in the desired state.`r`n" + `
                        "An action on {$sitName} Sensitive Information Type is missing."
                    Add-M365DSCEvent -Message $EventMessage -EntryType 'Warning' `
                        -EventID 1 -Source 'SCAutoSensitivityLabelRule'
                }
                return $false
            }

            Write-Verbose -Message "Sensitive Information Action {$sitName} was found"
            foreach ($property in @('id', 'maxconfidence', 'minconfidence', 'classifiertype', 'mincount', 'maxcount'))
            {
                $desiredValue = $sit.$property
                $currentValue = $matchingExistingRule.$property
                if ([System.String] $desiredValue -ne [System.String] $currentValue)
                {
                    Write-Verbose -Message "Property {$property} is set to {$currentValue} and is expected to be {$desiredValue}."
                    if ($LogDrift)
                    {
                        $EventMessage = "DLP Compliance Rule was not in the desired state.`r`n" + `
                            "Sensitive Information Action {$sitName} has invalid value for property {$property}. " + `
                            "Current value is {$currentValue} and is expected to be {$desiredValue}."
                        Add-M365DSCEvent -Message $EventMessage -EntryType 'Warning' `
                            -EventID 1 -Source 'SCAutoSensitivityLabelRule'
                    }
                    return $false
                }
            }
        }

        return $true
    }

    hidden [SCAutoSensitivityLabelRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCAutoSensitivityLabelRule])
        {
            return $Values
        }

        $result = [SCAutoSensitivityLabelRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_SCDLPContainsSensitiveInformation
{
    [DscProperty()]
    [System.ComponentModel.Description('Sensitive Information Content Types')]
    [MSFT_SCDLPSensitiveInformation[]] $SensitiveInformation

    [DscProperty()]
    [System.ComponentModel.Description('Groups of sensitive information types.')]
    [MSFT_SCDLPContainsSensitiveInformationGroup[]] $Groups

    [DscProperty()]
    [System.ComponentModel.Description('Operator')]
    [ValidateSet('And', 'Or')]
    [System.String] $Operator
}

class MSFT_SCHeaderPattern
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the header pattern')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Regular expression the header value must match')]
    [System.String] $Value
}

class MSFT_SCDLPSensitiveInformation
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the Sensitive Information Content')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Sensitive Information Content')]
    [System.String] $id

    [DscProperty()]
    [System.ComponentModel.Description('Maximum Confidence level value for the Sensitive Information')]
    [System.String] $maxconfidence

    [DscProperty()]
    [System.ComponentModel.Description('Minimum Confidence level value for the Sensitive Information')]
    [System.String] $minconfidence

    [DscProperty()]
    [System.ComponentModel.Description('Type of Classifier value for the Sensitive Information')]
    [System.String] $classifiertype

    [DscProperty()]
    [System.ComponentModel.Description('Minimum Count value for the Sensitive Information')]
    [System.String] $mincount

    [DscProperty()]
    [System.ComponentModel.Description('Maximum Count value for the Sensitive Information')]
    [System.String] $maxcount
}

class MSFT_SCDLPContainsSensitiveInformationGroup
{
    [DscProperty()]
    [System.ComponentModel.Description('Sensitive Information Content Types')]
    [MSFT_SCDLPSensitiveInformation[]] $SensitiveInformation

    [DscProperty()]
    [System.ComponentModel.Description('Sensitive Information Labels')]
    [MSFT_SCDLPLabel[]] $Labels

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the group')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Operator')]
    [ValidateSet('And', 'Or')]
    [System.String] $Operator
}

class MSFT_SCDLPLabel
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the Sensitive Label')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Sensitive Information label')]
    [System.String] $id

    [DscProperty()]
    [System.ComponentModel.Description('Type of the Sensitive Information label')]
    [System.String] $type
}
