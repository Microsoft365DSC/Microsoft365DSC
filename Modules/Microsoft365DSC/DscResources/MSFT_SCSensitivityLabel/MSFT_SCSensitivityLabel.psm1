using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCSensitivityLabel : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name for the sensitivity label. The maximum length is 64 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this rule should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The AdvancedSettings parameter enables client-specific features and capabilities on the sensitivity label. The settings that you configure with this parameter only affect apps that are designed for the setting.')]
    [MSFT_SCLabelSetting[]] $AdvancedSettings

    [DscProperty()]
    [System.ComponentModel.Description('The DisplayName parameter specifies the display name for the sensitivity label. The display name appears in the Microsoft Office and is used by Outlook users to select the appropriate sensitivity label before they send a message.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The LocaleSettings parameter specifies one or more localized label name or label Tooltips in different languages. Regions include all region codes supported in Office Client applications.')]
    [MSFT_SCLabelLocaleSettings[]] $LocaleSettings

    [DscProperty()]
    [System.ComponentModel.Description('The ParentId parameter specifies the parent label that you want this label to be under (a sublabel). You can use any value that uniquely identifies the parent sensitivity label for example name.')]
    [System.String] $ParentId

    [DscProperty()]
    [System.ComponentModel.Description('The Priority parameter specifies a priority value for the sensitivity label that determines the order of label processing. A lower integer value indicates a higher priority.')]
    [System.Nullable[System.UInt32]] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('The ToolTip parameter specifies the default tooltip and sensitivity label description that''s seen by users. It the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $Tooltip

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyContentMarkingFooterAlignment parameter specifies the footer alignment.')]
    [ValidateSet('Left', 'Center', 'Right')]
    [System.String] $ApplyContentMarkingFooterAlignment

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyContentMarkingFooterEnabled parameter specifies whether to enable or disable the sensitivity label.')]
    [System.Nullable[System.Boolean]] $ApplyContentMarkingFooterEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyContentMarkingFooterFontColor parameter specifies the color of the footer text. This parameter accepts a hexadecimal color code value in the format #xxxxxx. The default value is #000000.')]
    [System.String] $ApplyContentMarkingFooterFontColor

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyContentMarkingFooterFontSize parameter specifies the font size (in points) of the footer text.')]
    [System.Nullable[System.Int32]] $ApplyContentMarkingFooterFontSize

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyContentMarkingFooterMargin parameter specifies the size (in points) of the footer margin.')]
    [System.Nullable[System.Int32]] $ApplyContentMarkingFooterMargin

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyContentMarkingFooterText parameter specifies the footer text. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $ApplyContentMarkingFooterText

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyContentMarkingHeaderAlignment parameter specifies the header alignment.')]
    [ValidateSet('Left', 'Center', 'Right')]
    [System.String] $ApplyContentMarkingHeaderAlignment

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyContentMarkingHeaderEnabled parameter enables or disables the Apply Content Marking Header action for the label.')]
    [System.Nullable[System.Boolean]] $ApplyContentMarkingHeaderEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyContentMarkingHeaderFontColor parameter specifies the color of the header text. This parameter accepts a hexadecimal color code value in the format #xxxxxx. The default value is #000000.')]
    [System.String] $ApplyContentMarkingHeaderFontColor

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyContentMarkingHeaderFontSize parameter specifies the font size (in points) of the header text.')]
    [System.Nullable[System.Int32]] $ApplyContentMarkingHeaderFontSize

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyContentMarkingHeaderMargin parameter specifies the size (in points) of the header margin.')]
    [System.Nullable[System.Int32]] $ApplyContentMarkingHeaderMargin

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyContentMarkingHeaderText parameter specifies the header text. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $ApplyContentMarkingHeaderText

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyWaterMarkingEnabled parameter enables or disables the Apply Watermarking Header action for the label.')]
    [System.Nullable[System.Boolean]] $ApplyWaterMarkingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyWaterMarkingFontColor parameter specifies the color of the watermark text. This parameter accepts a hexadecimal color code value in the format #xxxxxx.')]
    [System.String] $ApplyWaterMarkingFontColor

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyWaterMarkingFontSize parameter specifies the font size (in points) of the watermark text.')]
    [System.Nullable[System.Int32]] $ApplyWaterMarkingFontSize

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyWaterMarkingAlignment parameter specifies the watermark alignment.')]
    [ValidateSet('Horizontal', 'Diagonal')]
    [System.String] $ApplyWaterMarkingLayout

    [DscProperty()]
    [System.ComponentModel.Description('The ApplyWaterMarkingText parameter specifies the watermark text. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $ApplyWaterMarkingText

    [DscProperty()]
    [System.ComponentModel.Description('The ContentType parameter specifies where the sensitivity label can be applied.')]
    [ValidateSet('File', 'Email', 'Site', 'UnifiedGroup', 'PurviewAssets', 'Teamwork', 'SchematizedData')]
    [System.String[]] $ContentType

    [DscProperty()]
    [System.ComponentModel.Description('The EncryptionContentExpiredOnDateInDaysOrNever parameter specifies when the encrypted content expires. Valid values are integer or never.')]
    [System.String] $EncryptionContentExpiredOnDateInDaysOrNever

    [DscProperty()]
    [System.ComponentModel.Description('The EncryptionDoNotForward parameter specifies whether the Do Not Forward template is applied.')]
    [System.Nullable[System.Boolean]] $EncryptionDoNotForward

    [DscProperty()]
    [System.ComponentModel.Description('The EncryptionEncryptOnly parameter specifies whether the encrypt-only template is applied.')]
    [System.Nullable[System.Boolean]] $EncryptionEncryptOnly

    [DscProperty()]
    [System.ComponentModel.Description('The EncryptionEnabled parameter specifies whether encryption in enabled.')]
    [System.Nullable[System.Boolean]] $EncryptionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The EncryptionOfflineAccessDays parameter specifies the number of days that offline access is allowed.')]
    [System.Nullable[System.Int32]] $EncryptionOfflineAccessDays

    [DscProperty()]
    [System.ComponentModel.Description('The EncryptionPromptUser parameter specifies whether to set the label with user defined permission in Word, Excel, and PowerPoint.')]
    [System.Nullable[System.Boolean]] $EncryptionPromptUser

    [DscProperty()]
    [System.ComponentModel.Description('The EncryptionProtectionType parameter specifies the protection type for encryption.')]
    [ValidateSet('Template', 'RemoveProtection', 'UserDefined')]
    [System.String] $EncryptionProtectionType

    [DscProperty()]
    [System.ComponentModel.Description('The EncryptionRightsDefinitions parameter specifies the rights users have when accessing protected. This parameter uses the syntax Identity1:Rights1,Rights2;Identity2:Rights3,Rights4. For example, john@contoso.com:VIEW,EDIT;microsoft.com:VIEW.')]
    [System.String] $EncryptionRightsDefinitions

    [DscProperty()]
    [System.ComponentModel.Description('The EncryptionRightsUrl parameter specifies the URL for hold your own key (HYOK) protection.')]
    [System.String] $EncryptionRightsUrl

    [DscProperty()]
    [System.ComponentModel.Description('The SiteAndGroupProtectionAllowAccessToGuestUsers parameter enables or disables access to guest users.')]
    [System.Nullable[System.Boolean]] $SiteAndGroupProtectionAllowAccessToGuestUsers

    [DscProperty()]
    [System.ComponentModel.Description('The SiteAndGroupProtectionAllowEmailFromGuestUsers parameter enables or disables email from guest users.')]
    [System.Nullable[System.Boolean]] $SiteAndGroupProtectionAllowEmailFromGuestUsers

    [DscProperty()]
    [System.ComponentModel.Description('The SiteAndGroupProtectionAllowFullAccess parameter enables or disables full access.')]
    [System.Nullable[System.Boolean]] $SiteAndGroupProtectionAllowFullAccess

    [DscProperty()]
    [System.ComponentModel.Description('The SiteAndGroupProtectionAllowLimitedAccess parameter enables or disables limited access.')]
    [System.Nullable[System.Boolean]] $SiteAndGroupProtectionAllowLimitedAccess

    [DscProperty()]
    [System.ComponentModel.Description('The SiteAndGroupProtectionBlockAccess parameter blocks access.')]
    [System.Nullable[System.Boolean]] $SiteAndGroupProtectionBlockAccess

    [DscProperty()]
    [System.ComponentModel.Description('The SiteAndGroupProtectionEnabled parameter enables or disables the Site and Group Protection action for the labels.')]
    [System.Nullable[System.Boolean]] $SiteAndGroupProtectionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SiteAndGroupProtectionPrivacy parameter specifies the privacy level for the label.')]
    [ValidateSet('Public', 'Private', 'Unspecified')]
    [System.String] $SiteAndGroupProtectionPrivacy

    [DscProperty()]
    [System.ComponentModel.Description('The SiteAndGroupExternalSharingControlType parameter specifies the external user sharing setting for the label.')]
    [ValidateSet('ExternalUserAndGuestSharing', 'ExternalUserSharingOnly', 'ExistingExternalUserSharingOnly', 'Disabled')]
    [System.String] $SiteAndGroupExternalSharingControlType

    [DscProperty()]
    [System.ComponentModel.Description('The AutoLabelingSettings parameter specifies the conditions for label to be automatically applied to files and emails.')]
    [MSFT_SCSLAutoLabelingSettings] $AutoLabelingSettings

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

    SCSensitivityLabel() : base()
    {
        $this.ResourceCache['allTrainableClassifiers'] = @(
            @{ Name = 'Actuary reports'; Id = 'b27df2ee-fd14-4ce9-b02f-4070a5d68132' }
            @{ Name = 'Agreements'; Id = '7f12e403-5335-4da8-a91e-6c2210b7a2b1' }
            @{ Name = 'Asset Management'; Id = '716fb550-90cd-493b-b29b-ceed41ee8a6f' }
            @{ Name = 'Bank statement'; Id = 'f426bd16-e42e-4397-824b-f17dedc5bb1c' }
            @{ Name = 'Budget'; Id = '6f207592-f71e-4b4f-8c07-ebc4bd4965b9' }
            @{ Name = 'Business Context'; Id = '08b772df-bf93-457f-be23-b5cbf02005fd' }
            @{ Name = 'Business plan'; Id = '693f8221-ae4e-4612-80f5-746efee167c3' }
            @{ Name = 'Completion Certificates'; Id = 'b2580781-286b-4ad2-ab47-84e84ff331e5' }
            @{ Name = 'Compliance policies'; Id = 'fdad8089-651b-4877-8b66-be105b2e57da' }
            @{ Name = 'Construction specifications'; Id = 'bfde18ef-b4b9-4f30-9965-ef8d00861a2c' }
            @{ Name = 'Control System and SCADA files'; Id = '59f1f471-687d-453b-a73e-0b0e9f350812' }
            @{ Name = 'Corporate Sabotage'; Id = 'd88960c3-6101-43d9-9250-8c43c71d638a' }
            @{ Name = 'Credit Report'; Id = '07ce7d30-690a-4a1c-a331-8df9c944f1ab' }
            @{ Name = 'Customer Complaints'; Id = '8137d8fc-fb7a-40db-9009-284f962fde96' }
            @{ Name = 'Customer Files'; Id = 'fdff9df2-03ba-4372-be97-82c0d2515118' }
            @{ Name = 'Discrimination'; Id = 'a65c4ab6-a155-11eb-921c-6c0b84aa8ea5' }
            @{ Name = 'Employee disciplinary action files'; Id = '769d56c1-e737-4fc1-8673-8c99bbe24a07' }
            @{ Name = 'Employee Insurance files'; Id = 'fa982a9f-9454-4885-a2bf-94a155df2f33' }
            @{ Name = 'Employee Pension Records'; Id = 'f9ae0bbc-a1e0-4b7e-a96a-eb60b26b4434' }
            @{ Name = 'Employee Stocks and Financial Bond Records'; Id = 'a67b2b59-c5f0-4c66-a6c4-ca6973adfd94' }
            @{ Name = 'Employment Agreement'; Id = '2a2baab7-b82c-4166-bbe4-55f9d3fd1129' }
            @{ Name = 'Enterprise Risk Management'; Id = 'eed09aae-6f32-47c7-9c99-9d17bad48783' }
            @{ Name = 'Environmental permits and clearances'; Id = '1b7d3e51-0ecf-41bd-9794-966c94a889ba' }
            @{ Name = 'Facility Permits'; Id = '914c5379-9d05-47cb-98f0-f5a2be059b5a' }
            @{ Name = 'factory Incident Investigation reports'; Id = '86186144-d507-4603-bac7-50b56ba05c70' }
            @{ Name = 'Finance'; Id = '1771481d-a337-4dbf-8e64-af8da0cc3ee9' }
            @{ Name = 'Finance policies and procedures'; Id = '6556c5eb-0819-4618-ba2e-59925925655e' }
            @{ Name = 'Financial Audit Reports'; Id = 'b04b2a4e-22f8-4024-8adc-e2caaad1c2e2' }
            @{ Name = 'Financial statement'; Id = 'c31bfef9-8045-4a35-88a3-74b8681615c2' }
            @{ Name = 'Freight Documents'; Id = '785917ed-db01-43c7-8153-8a6fc393efa3' }
            @{ Name = 'Garnishment'; Id = '65e827c3-f8e8-4bc8-b08c-c31e3132b832' }
            @{ Name = 'Gifts \u0026 entertainment'; Id = '3b3d817a-9190-465b-af2d-9e856f894059' }
            @{ Name = 'Health/Medical forms'; Id = '7cc60f30-9e96-4d51-b26f-3d7a9df56338' }
            @{ Name = 'Healthcare'; Id = 'dcbada08-65bf-4561-b140-25d8fee4d143' }
            @{ Name = 'HR'; Id = '11631f87-7ffe-4052-b173-abda16b231f3' }
            @{ Name = 'Invoice'; Id = 'bf7df7c3-fce4-4ffd-ab90-26f6463f3a00' }
            @{ Name = 'IP'; Id = '495fad07-d6e4-4da4-9c64-5b9b109a5f59' }
            @{ Name = 'IT'; Id = '77a140be-c29f-4155-9dc4-c3e247e47560' }
            @{ Name = 'IT Infra and Network Security Documents'; Id = 'bc55de38-cb72-43e6-952f-8422f584f229' }
            @{ Name = 'Lease Deeds'; Id = '841f54ad-3e31-4ddd-aea0-e7f0cd6b3d18' }
            @{ Name = 'Legal Affairs'; Id = 'ba38aa0f-8c86-4c73-87db-95147a0f4420' }
            @{ Name = 'Legal Agreements'; Id = 'bee9cefb-88bd-410f-ab3e-67cab21cef46' }
            @{ Name = 'Letter of Credits'; Id = 'fd85acd5-59dd-49b2-a4c3-df7075885a82' }
            @{ Name = 'License agreement'; Id = 'b399eb17-c9c4-4205-951b-43f38eb8dffe' }
            @{ Name = 'Loan agreements and offer letters'; Id = '5771fa57-34a1-48b3-93df-778b304daa54' }
            @{ Name = 'M&A Files'; Id = 'eeffbf7c-fd04-40ef-a156-b37bf61832f7' }
            @{ Name = 'Manufacturing batch records'; Id = '834b2353-509a-4605-b4f1-fc2172a0d97c' }
            @{ Name = 'Marketing Collaterals'; Id = 'fcaa6d2a-601c-4bdc-947e-af1178a646ac' }
            @{ Name = 'Meeting notes'; Id = 'e7ff9a9e-4689-4192-b927-e6c6bdf099fc' }
            @{ Name = 'Money laundering'; Id = 'adbbb20e-b175-46e7-8ba2-cf3f3179d0ed' }
            @{ Name = 'MoU Files (Memorandum of understanding)'; Id = 'cb37c277-4b88-49c6-81fb-2eeca8c52bb9' }
            @{ Name = 'Network Design files'; Id = '12587d70-9596-4c21-b09f-f1abe9d6ca13' }
            @{ Name = 'Non disclosure agreement'; Id = '8dfd10db-0c72-4be4-a4f2-f615fe7aeb1c' }
            @{ Name = 'OSHA records'; Id = 'b11b771e-7dd1-4434-873a-d648a16e969e' }
            @{ Name = 'Paystub'; Id = '31c11384-2d64-4635-9335-018295c64268' }
            @{ Name = 'Personal Financial Information'; Id = '6901c616-5857-432f-b3da-f5234fa1d342' }
            @{ Name = 'Procurement'; Id = '8fa64a47-6e77-4b4c-91a5-0f67525cebf5' }
            @{ Name = 'Profanity'; Id = '4b0aa61d-37dc-4596-a1f1-fc5a5b21d56b' }
            @{ Name = 'Project documents'; Id = 'e062df90-816c-47ca-8913-db647510d3b5' }
            @{ Name = 'Quality assurance files'; Id = '97b1e0d3-7788-4dd4-bb18-48ea77796743' }
            @{ Name = 'Quotation'; Id = '3882e681-c437-42d8-ac75-1f9b7481fe13' }
            @{ Name = 'Regulatory Collusion'; Id = '911b7815-6883-4022-a882-9cbe9462f114' }
            @{ Name = 'Resume'; Id = '14b2da41-0427-47e9-a11b-c924e1d05689' }
            @{ Name = 'Safety Records'; Id = '938fb100-5b1f-4bbb-aba7-73d9c89d086f' }
            @{ Name = 'Sales and revenue'; Id = '9d6b864d-28c6-4be3-a9d0-cd40434a847f' }
            @{ Name = 'Software Product Development Files'; Id = '813aa6d8-0727-48d8-acb7-06e1819ee339' }
            @{ Name = 'Source code'; Id = '8aef6743-61aa-44b9-9ae5-3bb3d77df535' }
            @{ Name = 'Standard Operating Procedures and Manuals'; Id = '32f23ad4-2ca1-4495-8048-8dc567891644' }
            @{ Name = 'Statement of Accounts'; Id = 'fe3676a6-0f5d-4990-bb46-9b2b31d7746a' }
            @{ Name = 'Statement of Work'; Id = '611c95f9-b1ef-4253-8b36-d8ae19d02fb0' }
            @{ Name = 'Stock manipulation'; Id = '1140cd79-ad87-4043-a562-c768acacc6ba' }
            @{ Name = 'Strategic planning documents'; Id = '9332b317-2ca4-413a-b983-92a1bd88c6f3' }
            @{ Name = 'Targeted Harassment'; Id = 'a02ddb8e-3c93-44ac-87c1-2f682b1cb78e' }
            @{ Name = 'Tax'; Id = '9722b51a-f920-4a81-8390-b188a0692840' }
            @{ Name = 'Threat'; Id = 'ef2edb64-6982-4648-b0ad-c0d8a861501b' }
            @{ Name = 'Unauthorized disclosure'; Id = '839aecf8-c67b-4270-8aaf-378127b23b7f' }
            @{ Name = 'Wire transfer'; Id = '05fc5ed0-58ef-4306-b65c-11b0a43895c2' }
            @{ Name = 'Work Schedules'; Id = '25bb9d2d-a5b5-45b1-882e-b2581a183873' }
        )
    }

    [SCSensitivityLabel] Get()
    {
        $localeSettingsValue = $null
        $siteAndGroupBlockAccess = $null
        $EncryptionRightsDefinitionsValue = $null
        $siteAndGroupAllowFullAccess = $null
        $contentExpiredOnDateValue = $null
        $advancedSettingsValue = $null
        $footerEnabledValue = $null
        $offlineAccessDaysValue = $null
        $encryptionEncryptOnlyValue = $null
        $protectionTypeValue = $null
        $headerEnabledValue = $null
        $siteAndGroupAllowLimitedAccess = $null
        $encryptionEnabledValue = $null
        $watermarkEnabledValue = $null
        $encryptionDoNotForwardValue = $null
        $siteAndGroupAccessToGuestUsersValue = $null
        $siteAndGroupEnabledValue = $null
        $encryptionPromptUserValue = $null
        $siteAndGroupAllowEmailFromGuestUsers = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCSensitivityLabel]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Sensitivity Label for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                try
                {
                    if ($null -eq $this.ResourceCache['AllLabels'])
                    {
                        [array]$this.ResourceCache['AllLabels'] = Invoke-M365DSCCommand -ScriptBlock { Get-Label -IncludeDetailedLabelActions }
                    }
                    $label = $this.ResourceCache['AllLabels'] | Where-Object { $_.Name -eq $this.Name }

                    if ($null -eq $label)
                    {
                        $label = Invoke-M365DSCCommand -ScriptBlock { Get-Label -Identity $this.Name -IncludeDetailedLabelActions -ErrorAction Stop } -SuppressNotFoundError
                    }
                }
                catch
                {
                    throw $_
                }

                if ($null -eq $label)
                {
                    Write-Verbose -Message "Sensitivity label $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $label = $this.ExportedInstance
            }

            $parentLabelID = $null
            if ($null -ne $label.ParentId)
            {
                $parentLabel = $this.ResourceCache['AllLabels'] | Where-Object { "$($_.Guid)" -eq "$($label.ParentId)" -or "$($_.ImmutableId)" -eq "$($label.ParentId)" -or $_.Name -eq $label.ParentId }
                if ($null -eq $parentLabel)
                {
                    $parentLabel = Get-Label -Identity $label.ParentId -IncludeDetailedLabelActions -ErrorAction SilentlyContinue
                    $this.ResourceCache['AllLabels'] += $parentLabel
                }
                $parentLabelID = $parentLabel.Name
            }
            if ($null -ne $label.LocaleSettings)
            {
                $localeSettingsValue = $this.ConvertJSONToLocaleSettings($label.LocaleSettings)
            }
            if ($null -ne $label.Settings)
            {
                [array]$advancedSettingsValue = $this.ConvertStringToAdvancedSettings($label.Settings)
            }
            Write-Verbose "Found existing Sensitivity Label $($this.Name)"

            [Array]$labelActions = $label.LabelActions
            $actions = @()
            foreach ($labelAction in $labelActions)
            {
                $action = ConvertFrom-Json ($labelAction | Out-String)
                $actions += $action
            }

            $encryption = ($actions | Where-Object -FilterScript { $_.Type -eq 'encrypt' }).Settings
            $header = ($actions | Where-Object -FilterScript { $_.Type -eq 'applycontentmarking' -and $_.Subtype -eq 'header' }).Settings
            $footer = ($actions | Where-Object -FilterScript { $_.Type -eq 'applycontentmarking' -and $_.Subtype -eq 'footer' }).Settings
            $watermark = ($actions | Where-Object -FilterScript { $_.Type -eq 'applywatermarking' }).Settings
            $protectgroup = ($actions | Where-Object -FilterScript { $_.Type -eq 'protectgroup' }).Settings
            $protectsite = ($actions | Where-Object -FilterScript { $_.Type -eq 'protectsite' }).Settings

            $ApplyContentMarkingFooterTextValue = $null
            $footerText = ($footer | Where-Object -FilterScript { $_.Key -eq 'text' }).Value
            if ([System.String]::IsNullOrEmpty($footerText) -eq $false)
            {
                $ApplyContentMarkingFooterTextValue = $footerText.Replace('$', '`$')
            }

            $ApplyContentMarkingHeaderTextValue = $null
            $headerText = ($header | Where-Object -FilterScript { $_.Key -eq 'text' }).Value
            if ([System.String]::IsNullOrEmpty($headerText) -eq $false)
            {
                $ApplyContentMarkingHeaderTextValue = $headerText.Replace('$', '`$')
            }

            $ApplyWaterMarkingTextValue = $null
            $watermarkText = ($watermark | Where-Object -FilterScript { $_.Key -eq 'text' }).Value
            if ([System.String]::IsNullOrEmpty($watermarkText) -eq $false)
            {
                $ApplyWaterMarkingTextValue = $watermarkText.Replace('$', '`$')
            }

            $currentContentType = @()
            switch -Regex ($label.ContentType)
            {
                'PurviewAssets'
                {
                    $currentContentType += 'PurviewAssets'
                }
                'Teamwork'
                {
                    $currentContentType += 'Teamwork'
                }
                'SchematizedData'
                {
                    $currentContentType += 'SchematizedData'
                }
                'File'
                {
                    $currentContentType += 'File'
                }
                'Email'
                {
                    $currentContentType += 'Email'
                }
                'Site'
                {
                    $currentContentType += 'Site'
                }
                'UnifiedGroup'
                {
                    $currentContentType += 'UnifiedGroup'
                }
            }

            # Encryption
            $entry = $encryption | Where-Object -FilterScript { $_.Key -eq 'disabled' }
            if ($null -ne $entry)
            {
                $encryptionEnabledValue = -not [Boolean]::Parse($entry.Value)
            }

            $entry = $encryption | Where-Object -FilterScript { $_.Key -eq 'contentexpiredondateindaysornever' }
            if ($null -ne $entry)
            {
                $contentExpiredOnDateValue = $entry.Value
            }

            $entry = $encryption | Where-Object -FilterScript { $_.Key -eq 'protectiontype' }
            if ($null -ne $entry)
            {
                $protectionTypeValue = $entry.Value
            }

            $entry = $encryption | Where-Object -FilterScript { $_.Key -eq 'offlineaccessdays' }
            if ($null -ne $entry)
            {
                $offlineAccessDaysValue = $entry.Value
            }

            $entry = $encryption | Where-Object -FilterScript { $_.Key -eq 'rightsdefinitions' }
            if ($null -ne $entry)
            {
                $EncryptionRightsDefinitionsValue = $this.ConvertEncryptionRightDefinition($entry.Value)
            }

            $entry = $encryption | Where-Object -FilterScript { $_.Key -eq 'donotforward' }
            if ($null -ne $entry)
            {
                $encryptionDoNotForwardValue = [Boolean]::Parse($entry.Value)
            }

            $entry = $encryption | Where-Object -FilterScript { $_.Key -eq 'encryptonly' }
            if ($null -ne $entry)
            {
                $encryptionEncryptOnlyValue = [Boolean]::Parse($entry.Value)
            }

            $entry = $encryption | Where-Object -FilterScript { $_.Key -eq 'promptuser' }
            if ($null -ne $entry)
            {
                $encryptionPromptUserValue = [Boolean]::Parse($entry.Value)
            }

            # Watermark
            $entry = $watermark | Where-Object -FilterScript { $_.Key -eq 'disabled' }
            if ($null -ne $entry)
            {
                $watermarkEnabledValue = -not [Boolean]::Parse($entry.Value)
            }

            # Watermark Footer
            $entry = $footer | Where-Object -FilterScript { $_.Key -eq 'disabled' }
            if ($null -ne $entry)
            {
                $footerEnabledValue = -not [Boolean]::Parse($entry.Value)
            }

            # Watermark Header
            $entry = $header | Where-Object -FilterScript { $_.Key -eq 'disabled' }
            if ($null -ne $entry)
            {
                $headerEnabledValue = -not [Boolean]::Parse($entry.Value)
            }

            # Site and Group
            $entry = $protectgroup | Where-Object -FilterScript { $_.Key -eq 'disabled' }
            if ($null -ne $entry)
            {
                $siteAndGroupEnabledValue = -not [Boolean]::Parse($entry.Value)
            }

            $entry = $protectgroup | Where-Object -FilterScript { $_.Key -eq 'allowaccesstoguestusers' }
            if ($null -ne $entry)
            {
                $siteAndGroupAccessToGuestUsersValue = [Boolean]::Parse($entry.Value)
            }

            $entry = $protectgroup | Where-Object -FilterScript { $_.Key -eq 'allowemailfromguestusers' }
            if ($null -ne $entry)
            {
                $siteAndGroupAllowEmailFromGuestUsers = [Boolean]::Parse($entry.Value)
            }

            $entry = $protectsite | Where-Object -FilterScript { $_.Key -eq 'allowfullaccess' }
            if ($null -ne $entry)
            {
                $siteAndGroupAllowFullAccess = [Boolean]::Parse($entry.Value)
            }

            $entry = $protectsite | Where-Object -FilterScript { $_.Key -eq 'allowlimitedaccess' }
            if ($null -ne $entry)
            {
                $siteAndGroupAllowLimitedAccess = [Boolean]::Parse($entry.Value)
            }

            $entry = $protectsite | Where-Object -FilterScript { $_.Key -eq 'blockaccess' }
            if ($null -ne $entry)
            {
                $siteAndGroupBlockAccess = [Boolean]::Parse($entry.Value)
            }

            # Auto Labelling Conditions
            $getConditions = $null
            if ([System.String]::IsNullOrEmpty($label.Conditions) -eq $false)
            {
                $currConditions = $label.Conditions | ConvertFrom-Json

                $getConditions = [ordered]@{
                    Groups   = @()
                    Operator = ''
                }

                $operator = $currConditions.PSObject.Properties.Name
                $getConditions.Operator = $operator

                $autoApplyType = ''
                $policyTip = ''
                [array]$groups = foreach ($group in $currConditions.$($operator))
                {
                    $grpObject = [ordered]@{
                        Name     = ''
                        Operator = ''
                    }

                    $grpOperator = $group.PSObject.Properties.Name
                    $grpObject.Operator = $grpOperator

                    $grpName = ''
                    [array]$sensitiveInformationTypes = foreach ($item in $group.$grpOperator | Where-Object { $_.Key -eq 'CCSI' })
                    {
                        if ([String]::IsNullOrEmpty($grpName))
                        {
                            $grpName = ($item.Settings | Where-Object { $_.Key -eq 'groupname' }).Value
                        }

                        if ([String]::IsNullOrEmpty($policyTip))
                        {
                            $policyTip = ($item.Settings | Where-Object { $_.Key -eq 'policytip' }).Value
                        }

                        if ([String]::IsNullOrEmpty($autoApplyType))
                        {
                            $autoApplyType = ($item.Settings | Where-Object { $_.Key -eq 'autoapplytype' }).Value
                        }

                        $settingsObject = [ordered]@{
                            name            = ($item.Settings | Where-Object { $_.Key -eq 'name' }).Value
                            confidencelevel = ($item.Settings | Where-Object { $_.Key -eq 'confidencelevel' }).Value
                            mincount        = ($item.Settings | Where-Object { $_.Key -eq 'mincount' }).Value
                            maxcount        = ($item.Settings | Where-Object { $_.Key -eq 'maxcount' }).Value
                        }

                        if ($null -ne ($item.Settings | Where-Object { $_.Key -eq 'classifiertype' }))
                        {
                            $settingsObject.classifiertype = ($item.Settings | Where-Object { $_.Key -eq 'classifiertype' }).Value
                        }

                        # return the settings object as output to the sensitiveInformationTypes array
                        $settingsObject
                    }

                    [array]$trainableClassifiers = foreach ($item in $group.$grpOperator | Where-Object { $_.Key -eq 'ContentMatchesModule' })
                    {
                        if ([String]::IsNullOrEmpty($grpName))
                        {
                            $grpName = ($item.Settings | Where-Object { $_.Key -eq 'groupname' }).Value
                        }

                        [ordered]@{
                            name = ($item.Settings | Where-Object { $_.Key -eq 'name' }).Value
                            id   = $item.Value
                        }
                    }

                    $grpObject.Name = $grpName
                    $grpObject.SensitiveInformationType = $sensitiveInformationTypes
                    $grpObject.TrainableClassifier = $trainableClassifiers

                    # return the group object as output to the groups array
                    $grpObject
                }
                $getConditions.Groups = $groups
                if ([System.String]::IsNullOrEmpty($policyTip) -eq $false)
                {
                    $getConditions.PolicyTip = $policyTip
                }
                if ([System.String]::IsNullOrEmpty($autoApplyType) -eq $false)
                {
                    $getConditions.AutoApplyType = $autoApplyType
                }
                else
                {
                    $getConditions.AutoApplyType = 'Automatic'
                }
            }

            $result = @{
                Name                                           = $label.Name
                Comment                                        = $label.Comment
                ParentId                                       = $parentLabelID
                AdvancedSettings                               = $advancedSettingsValue
                DisplayName                                    = $label.DisplayName
                LocaleSettings                                 = $localeSettingsValue
                Priority                                       = $label.Priority
                Tooltip                                        = $label.Tooltip
                Ensure                                         = 'Present'
                ApplyContentMarkingFooterAlignment             = ($footer | Where-Object { $_.Key -eq 'alignment' }).Value
                ApplyContentMarkingFooterEnabled               = $footerEnabledValue
                ApplyContentMarkingFooterFontColor             = ($footer | Where-Object { $_.Key -eq 'fontcolor' }).Value
                ApplyContentMarkingFooterFontSize              = ($footer | Where-Object { $_.Key -eq 'fontsize' }).Value
                ApplyContentMarkingFooterMargin                = ($footer | Where-Object { $_.Key -eq 'margin' }).Value
                ApplyContentMarkingFooterText                  = $ApplyContentMarkingFooterTextValue
                ApplyContentMarkingHeaderAlignment             = ($header | Where-Object { $_.Key -eq 'alignment' }).Value
                ApplyContentMarkingHeaderEnabled               = $headerEnabledValue
                ApplyContentMarkingHeaderFontColor             = ($header | Where-Object { $_.Key -eq 'fontcolor' }).Value
                ApplyContentMarkingHeaderFontSize              = ($header | Where-Object { $_.Key -eq 'fontsize' }).Value
                ApplyContentMarkingHeaderMargin                = ($header | Where-Object { $_.Key -eq 'margin' }).Value
                #TODO ADD HEADER PLACEMENT?
                ApplyContentMarkingHeaderText                  = $ApplyContentMarkingHeaderTextValue
                ApplyWaterMarkingEnabled                       = $watermarkEnabledValue
                ApplyWaterMarkingFontColor                     = ($watermark | Where-Object { $_.Key -eq 'fontcolor' }).Value
                ApplyWaterMarkingFontSize                      = ($watermark | Where-Object { $_.Key -eq 'fontsize' }).Value
                ApplyWaterMarkingLayout                        = ($watermark | Where-Object { $_.Key -eq 'layout' }).Value
                ApplyWaterMarkingText                          = $ApplyWaterMarkingTextValue
                AutoLabelingSettings                           = $getConditions
                ContentType                                    = $currentContentType
                EncryptionContentExpiredOnDateInDaysOrNever    = $contentExpiredOnDateValue
                EncryptionDoNotForward                         = $encryptionDoNotForwardValue
                EncryptionEncryptOnly                          = $encryptionEncryptOnlyValue
                EncryptionEnabled                              = $encryptionEnabledValue
                EncryptionOfflineAccessDays                    = $offlineAccessDaysValue
                EncryptionPromptUser                           = $encryptionPromptUserValue
                EncryptionProtectionType                       = $protectionTypeValue
                EncryptionRightsDefinitions                    = $EncryptionRightsDefinitionsValue
                EncryptionRightsUrl                            = ($encryption | Where-Object { $_.Key -eq 'doublekeyencryptionurl' }).Value
                SiteAndGroupProtectionAllowAccessToGuestUsers  = $siteAndGroupAccessToGuestUsersValue
                SiteAndGroupProtectionAllowEmailFromGuestUsers = $siteAndGroupAllowEmailFromGuestUsers
                SiteAndGroupProtectionPrivacy                  = ($protectgroup | Where-Object { $_.Key -eq 'privacy' }).Value
                SiteAndGroupProtectionAllowFullAccess          = $siteAndGroupAllowFullAccess
                SiteAndGroupProtectionAllowLimitedAccess       = $siteAndGroupAllowLimitedAccess
                SiteAndGroupProtectionBlockAccess              = $siteAndGroupBlockAccess
                SiteAndGroupProtectionEnabled                  = $siteAndGroupEnabledValue
                SiteAndGroupExternalSharingControlType         = ($protectsite | Where-Object { $_.Key -eq 'externalsharingcontroltype' }).Value
                Credential                                     = $this.Credential
                ApplicationId                                  = $this.ApplicationId
                TenantId                                       = $this.TenantId
                CertificateThumbprint                          = $this.CertificateThumbprint
                CertificatePath                                = $this.CertificatePath
                CertificatePassword                            = $this.CertificatePassword
                ManagedIdentity                                = $this.ManagedIdentity
                AccessTokens                                   = $this.AccessTokens
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
        $desiredAutoLabelingSettings = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of Sensitivity label for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $label = $this.Get().ToHashtable()

        if (($this.SiteAndGroupProtectionAllowFullAccess -and $this.SiteAndGroupProtectionAllowLimitedAccess) -or `
            ($this.SiteAndGroupProtectionAllowFullAccess -and $this.SiteAndGroupProtectionBlockAccess) -or `
            ($this.SiteAndGroupProtectionBlockAccess -and $this.SiteAndGroupProtectionAllowLimitedAccess))
        {
            throw '[ERROR] Only one of these values can be set to true: SiteAndGroupProtectionAllowFullAccess, SiteAndGroupProtectionAllowLimitedAccess, SiteAndGroupProtectionBlockAccess'
        }

        if ($this.GetBoundParameters().ContainsKey('EncryptionProtectionType') -and `
            ($this.EncryptionProtectionType -ne 'UserDefined' -and `
                ($this.GetBoundParameters().ContainsKey('EncryptionDoNotForward') -or `
                        $this.GetBoundParameters().ContainsKey('EncryptionEncryptOnly') -or `
                        $this.GetBoundParameters().ContainsKey('EncryptionPromptUser'))))
        {
            Write-Warning -Message "You have specified EncryptionDoNotForward, EncryptionEncryptOnly or EncryptionPromptUser, but EncryptionProtectionType isn't set to UserDefined."
        }

        if ('Present' -eq $this.Ensure -and $this.GetBoundParameters().ContainsKey('AutoLabelingSettings'))
        {
            Write-Verbose 'Generating required JSON string for AutoLabelingSettings'

            Write-Verbose 'Retrieving all existing Sensitive Information Types'
            $existingSITs = Get-DlpSensitiveInformationType | Select-Object -Property Name, Id, RulePackId

            # Convert the AutoLabelingSettings to the correct JSON format, ready to be inserted into the label cmdlets
            $autoLabelingSettingsHT = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.AutoLabelingSettings

            Write-Verbose 'Processing all setting groups'
            [array]$grps = foreach ($group in $autoLabelingSettingsHT.Groups)
            {
                $groupCollection = @()
                Write-Verbose 'Processing all Sensitive Information Types'
                foreach ($sit in $group.SensitiveInformationType)
                {
                    $currentSIT = $existingSITs | Where-Object { $_.Name -eq $sit.Name }
                    if ($null -eq $currentSIT)
                    {
                        throw "[ERROR] Provided Sensitive Information Type $($sit.Name) doesn't exist."
                    }

                    [array]$settingsCollection = foreach ($setting in ($sit.Keys | Where-Object { $_ -ne 'id' }))
                    {
                        @{
                            Key   = $setting
                            Value = $sit[$setting]
                        }
                    }
                    $settingsCollection += @{
                        Key   = 'rulepackage'
                        Value = $currentSIT.RulePackId
                    }
                    $settingsCollection += @{
                        Key   = 'groupname'
                        Value = $group.Name
                    }

                    if ($autoLabelingSettingsHT.ContainsKey('PolicyTip'))
                    {
                        $settingsCollection += @{
                            Key   = 'policytip'
                            Value = $autoLabelingSettingsHT.PolicyTip
                        }
                    }

                    if ($autoLabelingSettingsHT.ContainsKey('AutoApplyType') -and $autoLabelingSettingsHT.AutoApplyType -eq 'Recommend')
                    {
                        $settingsCollection += @{
                            Key   = 'autoapplytype'
                            Value = $autoLabelingSettingsHT.AutoApplyType
                        }
                    }

                    $groupCollection += @{
                        Key        = 'CCSI'
                        Value      = $currentSIT.Id
                        Properties = $null
                        Settings   = $settingsCollection
                    }
                }

                Write-Verbose 'Processing all Trainable Classifiers'
                foreach ($trainableClassifier in $group.TrainableClassifier)
                {
                    $currentTrainableClassifier = $this.ResourceCache['allTrainableClassifiers'] | Where-Object { $_.Name -eq $trainableClassifier.name }
                    if ($null -ne $currentTrainableClassifier)
                    {
                        if ([String]::IsNullOrEmpty($trainableClassifier.id) -eq $false -and `
                                $trainableClassifier.id -ne $currentTrainableClassifier.Id)
                        {
                            Write-Verbose ("[WARNING] Provided ID ($($trainableClassifier.id)) does not match the known " + `
                                    "ID ($($currentTrainableClassifier.id)) for trainable classifier '$($trainableClassifier.name)'.")
                        }
                        $requiredId = $currentTrainableClassifier.Id
                    }
                    else
                    {
                        if ([String]::IsNullOrEmpty($trainableClassifier.id))
                        {
                            throw "[ERROR] Trainable classifier $($trainableClassifier.name) isn't a default classifier and no ID was provided."
                        }
                        $requiredId = $trainableClassifier.id
                    }

                    [array]$settingsCollection = foreach ($key in ($trainableClassifier.Keys | Where-Object { $_ -ne 'id' }))
                    {
                        @{
                            Key   = $key
                            Value = $trainableClassifier[$key]
                        }
                    }
                    $settingsCollection += @{
                        Key   = 'groupname'
                        Value = $group.Name
                    }

                    if ($autoLabelingSettingsHT.ContainsKey('PolicyTip'))
                    {
                        $settingsCollection += @{
                            Key   = 'policytip'
                            Value = $autoLabelingSettingsHT.PolicyTip
                        }
                    }

                    if ($autoLabelingSettingsHT.ContainsKey('AutoApplyType') -and $autoLabelingSettingsHT.AutoApplyType -eq 'Recommend')
                    {
                        $settingsCollection += @{
                            Key   = 'autoapplytype'
                            Value = $autoLabelingSettingsHT.AutoApplyType
                        }
                    }

                    $groupCollection += @{
                        Key        = 'ContentMatchesModule'
                        Value      = $requiredId
                        Properties = $null
                        Settings   = $settingsCollection
                    }
                }

                @{
                    $group.Operator = $groupCollection
                }
            }

            $desiredAutoLabelingSettings = @{
                $autoLabelingSettingsHT.Operator = $grps
            }
            Write-Verbose 'Completed generating required JSON string for AutoLabelingSettings'
        }

        if ($this.Ensure -eq 'Present' -and $label.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Label {$($this.Name)} doesn't already exist, creating it"
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            if ($this.GetBoundParameters().ContainsKey('AdvancedSettings'))
            {
                $advanced = $this.ConvertCIMToAdvancedSettings($this.AdvancedSettings)
                $CreationParams['AdvancedSettings'] = $advanced
                $isLabelGroup = $null -ne ($this.AdvancedSettings | Where-Object -FilterScript { $_.Key -eq 'islabelgroup' -and $_.Value -eq $true })
                if ($isLabelGroup)
                {
                    $CreationParams.Add('IsLabelGroup', $true)
                    $CreationParams.Remove('ContentType') | Out-Null
                }
            }

            if ($this.GetBoundParameters().ContainsKey('LocaleSettings'))
            {
                $locale = $this.ConvertCIMToLocaleSettings($this.LocaleSettings)
                $CreationParams['LocaleSettings'] = $locale
            }

            if ($CreationParams.ContainsKey('SiteAndGroupExternalSharingControlType'))
            {
                $CreationParams.SiteExternalSharingControlType = $CreationParams.SiteAndGroupExternalSharingControlType
                $CreationParams.Remove('SiteAndGroupExternalSharingControlType')
            }

            if ($this.GetBoundParameters().ContainsKey('AutoLabelingSettings') -and $null -ne $desiredAutoLabelingSettings)
            {
                $CreationParams.Conditions = $desiredAutoLabelingSettings | ConvertTo-Json -Depth 20
                $CreationParams.Remove('AutoLabelingSettings')
            }

            $CreationParams.Remove('Priority') | Out-Null

            try
            {
                Write-Verbose -Message "Creating Label {$($this.Name)} with:`r`n$(ConvertTo-Json $CreationParams -Depth 10)"
                $newLabel = New-Label @CreationParams -ErrorAction Stop

                ## Can't set priority until label created
                if ($this.GetBoundParameters().ContainsKey('Priority') -and $this.Priority -ne $newLabel.Priority)
                {
                    Start-Sleep 5
                    Write-Verbose -Message "Updating the priority for newly created label {$($this.Name)} and Priority {$($this.priority)})"
                    [SCSensitivityLabel]::SetLabelPriority($this.Name, [System.Int32] $this.Priority)
                }
            }
            catch
            {
                $this.LogError($_, 'Error retrieving data:')

                throw $_
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $label.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Label {$($this.Name)} already exist, updating it"
            $SetParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            if ($this.GetBoundParameters().ContainsKey('AdvancedSettings'))
            {
                $advanced = $this.ConvertCIMToAdvancedSettings($this.AdvancedSettings)
                $SetParams['AdvancedSettings'] = $advanced
                $isLabelGroup = $null -ne ($this.AdvancedSettings | Where-Object -FilterScript { $_.Key -eq 'islabelgroup' -and $_.Value -eq $true })
                if ($isLabelGroup)
                {
                    $SetParams.Remove('ContentType') | Out-Null
                }
            }

            if ($this.GetBoundParameters().ContainsKey('LocaleSettings'))
            {
                $locale = $this.ConvertCIMToLocaleSettings($this.LocaleSettings)
                $SetParams['LocaleSettings'] = $locale
            }

            if ($SetParams.ContainsKey('SiteAndGroupExternalSharingControlType'))
            {
                $SetParams.SiteExternalSharingControlType = $SetParams.SiteAndGroupExternalSharingControlType
                $SetParams.Remove('SiteAndGroupExternalSharingControlType')
            }

            if ($this.GetBoundParameters().ContainsKey('AutoLabelingSettings') -and $null -ne $desiredAutoLabelingSettings)
            {
                $SetParams.Conditions = $desiredAutoLabelingSettings | ConvertTo-Json -Depth 20
                $SetParams.Remove('AutoLabelingSettings')
            }

            #Remove unused parameters for Set-Label cmdlet
            $SetParams.Remove('Name') | Out-Null

            $SetParams.Remove('Priority') | Out-Null

            try
            {
                if ($SetParams.Count -gt 0)
                {
                    Write-Verbose -Message "Updating label {$($this.Name)} with:`r`n$(ConvertTo-Json $SetParams -Depth 10)"
                    Set-Label @SetParams -Identity $this.Name -ErrorAction Stop
                }

                if ($this.GetBoundParameters().ContainsKey('Priority') -and $this.Priority -ne $label.Priority)
                {
                    Write-Verbose -Message "Updating the priority of label {$($this.Name)} from {$($label.Priority)} to {$($this.Priority)}"
                    [SCSensitivityLabel]::SetLabelPriority($this.Name, [System.Int32] $this.Priority)
                }
            }
            catch
            {
                $this.LogError($_, 'Error retrieving data:')

                throw $_
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $label.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Deleting Sensitivity label $($this.Name)."

            try
            {
                Remove-Label -Identity $this.Name -Confirm:$false -ErrorAction Stop
            }
            catch
            {
                $this.LogError($_, 'Error retrieving data:')

                throw $_
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

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$this.ResourceCache['AllLabels'] = Get-Label -IncludeDetailedLabelActions -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($this.ResourceCache['AllLabels'].Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($label in $this.ResourceCache['AllLabels'])
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($this.ResourceCache['AllLabels'].Count)] $($label.Name)" -DeferWrite

                $this.ExportedInstance = $label
                $Results = $this.GetForExport(@{ Name = $label.Name })
                $rawResults = $Results.Clone()

                if ($null -ne $Results.AdvancedSettings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'AdvancedSettings'
                            CimInstanceName = 'MSFT_SCLabelSetting'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AdvancedSettings `
                        -CIMInstanceName 'MSFT_SCLabelSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AdvancedSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AdvancedSettings') | Out-Null
                    }
                }

                if ($null -ne $Results.LocaleSettings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'LocaleSettings'
                            CimInstanceName = 'MSFT_SCLabelLocaleSettings'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LabelSettings'
                            CimInstanceName = 'MSFT_SCLabelSetting'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.LocaleSettings `
                        -CIMInstanceName 'MSFT_SCLabelLocaleSettings' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.LocaleSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('LocaleSettings') | Out-Null
                    }
                }

                if ($null -ne $Results.AutoLabelingSettings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'AutoLabelingSettings'
                            CimInstanceName = 'MSFT_SCSLAutoLabelingSettings'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'Groups'
                            CimInstanceName = 'MSFT_SCSLSensitiveInformationGroup'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'SensitiveInformationType'
                            CimInstanceName = 'MSFT_SCSLSensitiveInformationType'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'TrainableClassifier'
                            CimInstanceName = 'MSFT_SCSLTrainableClassifiers'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AutoLabelingSettings `
                        -CIMInstanceName 'MSFT_SCSLAutoLabelingSettings' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AutoLabelingSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AutoLabelingSettings') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('AdvancedSettings', 'LocaleSettings', 'AutoLabelingSettings') `
                    -RawResults $rawResults

                $currentDSCBlock = $currentDSCBlock.Replace("''", "'")

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
            }
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
        return $dscContent.ToString()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)
                $logDrift = -not [M365DSCResourceBase]::IsReportContext($PostProcessingArgs)
                $ValuesToCheck.Remove('AdvancedSettings') | Out-Null
                $ValuesToCheck.Remove('LocaleSettings') | Out-Null
                $ValuesToCheck.Remove('AutoLabelingSettings') | Out-Null

                if ($null -ne $DesiredValues.AdvancedSettings -and $null -ne $CurrentValues.AdvancedSettings)
                {
                    Write-Verbose -Message 'Testing AdvancedSettings'
                    $TestAdvancedSettings = [SCSensitivityLabel]::TestAdvancedSettings($DesiredValues.AdvancedSettings, $CurrentValues.AdvancedSettings, $logDrift)
                    if ($false -eq $TestAdvancedSettings)
                    {
                        $DesiredValues['AdvancedSettings'] = @{ Drift = 'desired' }
                        $CurrentValues['AdvancedSettings'] = @{ Drift = 'current' }
                        $ValuesToCheck['AdvancedSettings'] = $DesiredValues['AdvancedSettings']
                    }
                }

                if ($null -ne $DesiredValues.LocaleSettings -and $null -ne $CurrentValues.LocaleSettings)
                {
                    Write-Verbose -Message 'Testing LocaleSettings'
                    $localeSettingsSame = [SCSensitivityLabel]::TestLocaleSettings($DesiredValues.LocaleSettings, $CurrentValues.LocaleSettings, $logDrift)
                    if ($false -eq $localeSettingsSame)
                    {
                        $DesiredValues['LocaleSettings'] = @{ Drift = 'desired' }
                        $CurrentValues['LocaleSettings'] = @{ Drift = 'current' }
                        $ValuesToCheck['LocaleSettings'] = $DesiredValues['LocaleSettings']
                    }
                }

                if ($null -ne $DesiredValues.AutoLabelingSettings -and $null -ne $CurrentValues.AutoLabelingSettings)
                {
                    Write-Verbose -Message 'Testing AutoLabelingSettings'
                    $autoLabelingSettingsHT = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $DesiredValues.AutoLabelingSettings
                    $autoLabelSettingsSame = [SCSensitivityLabel]::TestAutoLabelingSettings($autoLabelingSettingsHT, $CurrentValues.AutoLabelingSettings, $logDrift)
                    if ($false -eq $autoLabelSettingsSame)
                    {
                        $DesiredValues['AutoLabelingSettings'] = @{ Drift = 'desired' }
                        $CurrentValues['AutoLabelingSettings'] = @{ Drift = 'current' }
                        $ValuesToCheck['AutoLabelingSettings'] = $DesiredValues['AutoLabelingSettings']
                    }
                }

                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    # Set-Label -Priority is not the final priority. A top-level label is inserted before the label
    # holding that priority. A sub-label lands on it, but the first sub-label lands one lower, so
    # no other sub-label can take the first position directly and the end of the list needs two moves.
    hidden static [void] SetLabelPriority([System.String] $Identity, [System.Int32] $DesiredPriority)
    {
        $labels = @(Get-Label -ErrorAction Stop | Sort-Object -Property Priority)
        $label = $labels | Where-Object -FilterScript { $_.Name -eq $Identity -or "$($_.Guid)" -eq $Identity } | Select-Object -First 1
        if ($null -eq $label -or $label.Priority -eq $DesiredPriority)
        {
            return
        }

        $labelId = "$($label.Guid)"
        $labelParentId = "$($label.ParentId)"
        if (-not [System.String]::IsNullOrEmpty($labelParentId))
        {
            $parent = $labels | Where-Object Guid -EQ $labelParentId | Select-Object -First 1
            $siblingCount = @($labels | Where-Object ParentId -EQ $labelParentId).Count
            if ($null -ne $parent -and ($DesiredPriority -le $parent.Priority -or $DesiredPriority -gt $parent.Priority + $siblingCount))
            {
                throw "Priority $DesiredPriority of SC Sensitivity Label {$Identity} is outside the range $($parent.Priority + 1) - $($parent.Priority + $siblingCount) its sub-labels occupy below the parent label {$($parent.Name)}."
            }

            $firstSibling = $labels | Where-Object ParentId -EQ $labelParentId | Select-Object -First 1
            if ("$($firstSibling.Guid)" -eq $labelId)
            {
                Set-Label -Identity $labelId -Priority ($DesiredPriority + 1) -ErrorAction Stop
            }
            elseif ($DesiredPriority -le $firstSibling.Priority)
            {
                if ($label.Priority -ne $firstSibling.Priority + 1)
                {
                    Set-Label -Identity $labelId -Priority ($firstSibling.Priority + 1) -ErrorAction Stop
                }
                Set-Label -Identity "$($firstSibling.Guid)" -Priority ($firstSibling.Priority + 2) -ErrorAction Stop
            }
            else
            {
                Set-Label -Identity $labelId -Priority $DesiredPriority -ErrorAction Stop
            }

            return
        }

        $movedIds = @($labelId) + @($labels | Where-Object ParentId -EQ $labelId | ForEach-Object -Process { "$($_.Guid)" })
        $remaining = @($labels | Where-Object Guid -notin $movedIds)
        $reachable = @(0..$remaining.Count | Where-Object -FilterScript {
                $_ -eq $remaining.Count -or [System.String]::IsNullOrEmpty("$($remaining[$_].ParentId)")
            })
        if ($DesiredPriority -notin $reachable)
        {
            throw "Priority $DesiredPriority of SC Sensitivity Label {$Identity} cannot be reached, because sub-labels always directly follow their parent label. The priorities it can take are $($reachable -join ', ')."
        }

        if ($DesiredPriority -lt $remaining.Count)
        {
            Set-Label -Identity $labelId -Priority $remaining[$DesiredPriority].Priority -ErrorAction Stop
            return
        }

        $lastPeer = $remaining[-1]
        if (-not [System.String]::IsNullOrEmpty("$($lastPeer.ParentId)"))
        {
            $lastPeerParentId = "$($lastPeer.ParentId)"
            $lastPeer = $remaining | Where-Object Guid -EQ $lastPeerParentId | Select-Object -First 1
        }

        Set-Label -Identity $labelId -Priority $lastPeer.Priority -ErrorAction Stop
        $movedLabel = Get-Label -Identity $labelId -ErrorAction Stop
        Set-Label -Identity "$($lastPeer.Guid)" -Priority $movedLabel.Priority -ErrorAction Stop
    }

    hidden [System.Object] ConvertCIMToAdvancedSettings([System.Object] $AdvancedSettings)
    {
        $entry = @{}
        foreach ($obj in $AdvancedSettings)
        {
            $settingsValues = ''
            foreach ($objVal in $obj.Value)
            {
                $settingsValues += $objVal
                $settingsValues += ','
            }
            $entry[$obj.Key] = $settingsValues.Substring(0, ($settingsValues.Length - 1))
        }

        return $entry
    }

    hidden [System.Collections.ArrayList] ConvertCIMToLocaleSettings([System.Object] $LocaleSettings)
    {
        $entry = [System.Collections.ArrayList]@()
        foreach ($localset in $LocaleSettings)
        {
            $localeEntries = [ordered]@{
                localeKey = $localset.LocaleKey
            }
            $settings = @()
            foreach ($setting in $localset.LabelSettings)
            {
                $settingEntry = [ordered]@{
                    Key   = $setting.Key
                    Value = $setting.Value
                }
                $settings += $settingEntry
            }
            $localeEntries.Add('Settings', $settings)
            [void]$entry.Add(($localeEntries | ConvertTo-Json))
        }

        return $entry
    }

    hidden [System.Object[]] ConvertJSONToLocaleSettings([System.Object] $JSONLocalSettings)
    {
        $parsedSettings = $JSONLocalSettings | ConvertFrom-Json

        $entries = @()
        foreach ($localeSetting in $parsedSettings)
        {
            $result = [ordered]@{
                LocaleKey = $localeSetting.LocaleKey
            }
            $settings = @()
            foreach ($setting in $localeSetting.Settings)
            {
                $entry = [ordered]@{
                    Key   = $setting.Key
                    Value = $setting.Value -replace "`r"
                }
                $settings += $entry
            }
            $result.Add('LabelSettings', $settings)
            $entries += $result
        }

        return $entries
    }

    hidden [System.String] ConvertEncryptionRightDefinition([System.String] $RightsDefinition)
    {
        $StringContent = ''
        $EncryptionRights = $RightsDefinition | ConvertFrom-Json
        foreach ($right in $EncryptionRights)
        {
            $StringContent += "$($right.Identity):$($right.Rights);"
        }
        if ($StringContent.EndsWith(';'))
        {
            $StringContent = $StringContent.Substring(0, ($StringContent.Length - 1))
        }

        return $StringContent
    }

    hidden [System.Object[]] ConvertStringToAdvancedSettings([System.String[]] $AdvancedSettings)
    {
        $settings = @()
        foreach ($setting in $AdvancedSettings)
        {
            $settingString = $setting.Replace('[', '').Replace(']', '')
            $settingKey = $settingString.Split(',')[0]

            if ($settingKey -notin @('displayname', 'contenttype', 'tooltip', 'parentid'))
            {
                $startPos = $settingString.IndexOf(',', 0) + 1
                $valueString = $settingString.Substring($startPos, $settingString.Length - $startPos).Trim()
                $values = $valueString.Split(',')

                $entry = [ordered]@{
                    Key   = $settingKey
                    Value = $values.Trim()
                }

                # Only export the entry if it has a value
                if ([String]::IsNullOrEmpty($entry.Value) -eq $false)
                {
                    $settings += $entry
                }
            }
        }

        return $settings
    }

    hidden static [System.Boolean] HasMember([System.Object] $Object, [System.String] $Name)
    {
        if ($null -eq $Object)
        {
            return $false
        }

        if ($Object -is [System.Collections.IDictionary])
        {
            return ([System.Collections.IDictionary] $Object).Contains($Name)
        }

        return $null -ne $Object.PSObject.Properties[$Name]
    }

    hidden static [System.Boolean] IsSettingValueEqual([System.Object] $DesiredValue, [System.Object] $CurrentValue)
    {
        $desiredTexts = [System.Collections.Generic.List[System.String]]::new()
        foreach ($entry in @($DesiredValue))
        {
            $text = [System.String] $entry
            if ($text.Length -gt 0)
            {
                $desiredTexts.Add($text)
            }
        }

        $currentTexts = [System.Collections.Generic.List[System.String]]::new()
        foreach ($entry in @($CurrentValue))
        {
            $text = [System.String] $entry
            if ($text.Length -gt 0)
            {
                $currentTexts.Add($text)
            }
        }

        if ($desiredTexts.Count -ne $currentTexts.Count)
        {
            return $false
        }

        if ($desiredTexts.Count -gt 1)
        {
            $desiredTexts.Sort([System.StringComparer]::OrdinalIgnoreCase)
            $currentTexts.Sort([System.StringComparer]::OrdinalIgnoreCase)
        }

        for ($index = 0; $index -lt $desiredTexts.Count; $index++)
        {
            if ($desiredTexts[$index] -ne $currentTexts[$index])
            {
                return $false
            }
        }

        return $true
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

    hidden static [System.Boolean] TestLocaleSettings([System.Object] $DesiredProperty, [System.Object] $CurrentProperty, [System.Boolean] $LogDrift)
    {
        $driftedSetting = [System.Collections.Generic.List[System.String]]::new()
        $currentLocales = [SCSensitivityLabel]::NewMemberLookup($CurrentProperty, 'LocaleKey')
        foreach ($desiredLocale in @($DesiredProperty))
        {
            if ($null -eq $desiredLocale)
            {
                continue
            }

            $localeKey = [System.String] $desiredLocale.LocaleKey
            $currentSettings = @{}
            $currentLocale = $currentLocales[$localeKey]
            if ($null -ne $currentLocale)
            {
                $currentSettings = [SCSensitivityLabel]::NewMemberLookup($currentLocale.LabelSettings, 'Key')
            }

            foreach ($desiredSetting in @($desiredLocale.LabelSettings))
            {
                if ($null -eq $desiredSetting)
                {
                    continue
                }

                $settingKey = [System.String] $desiredSetting.Key
                $desiredValue = $desiredSetting.Value
                if ($desiredValue -is [System.Array])
                {
                    if ($desiredValue.Count -ne 1)
                    {
                        $driftedSetting.Add("$localeKey ($settingKey)")
                        continue
                    }

                    $desiredValue = $desiredValue[0]
                }

                $desiredText = [System.String] $desiredValue
                $found = $false
                $currentSetting = $currentSettings[$settingKey]
                if ($null -ne $currentSetting)
                {
                    foreach ($candidate in @($currentSetting.Value))
                    {
                        if ([System.String] $candidate -eq $desiredText)
                        {
                            $found = $true
                            break
                        }
                    }
                }

                if (-not $found)
                {
                    $driftedSetting.Add("$localeKey ($settingKey)")
                }
            }
        }

        $foundSettings = $driftedSetting.Count -eq 0
        if (-not $foundSettings -and $LogDrift)
        {
            New-M365DSCLogEntry -Message "LocaleSettings do not match: $($driftedSetting -join ', ')" `
                -Source 'SCSensitivityLabel'
        }

        Write-Verbose -Message "Test LocaleSettings returns $foundSettings"

        return $foundSettings
    }

    hidden static [System.Boolean] TestAutoLabelingSettings([System.Object] $DesiredProperty, [System.Object] $CurrentProperty, [System.Boolean] $LogDrift)
    {
        $driftedSetting = [System.Collections.Generic.List[System.String]]::new()

        foreach ($propertyName in @('Operator', 'AutoApplyType', 'PolicyTip'))
        {
            if ($propertyName -eq 'PolicyTip' -and -not [SCSensitivityLabel]::HasMember($DesiredProperty, $propertyName))
            {
                continue
            }

            $desiredValue = $DesiredProperty.$propertyName
            $currentValue = $CurrentProperty.$propertyName
            if ([System.String] $desiredValue -ne [System.String] $currentValue)
            {
                $driftedSetting.Add("Parameter '$propertyName' does not match. Current: '$currentValue'. Desired: '$desiredValue'.")
            }
        }

        $desiredGroups = @($DesiredProperty.Groups)
        $currentGroups = @($CurrentProperty.Groups)
        $desiredGroupLookup = [SCSensitivityLabel]::NewMemberLookup($desiredGroups, 'Name')
        $currentGroupLookup = [SCSensitivityLabel]::NewMemberLookup($currentGroups, 'Name')

        foreach ($group in $desiredGroups)
        {
            if ($null -eq $group)
            {
                continue
            }

            $groupName = [System.String] $group.Name
            $currentGroup = $currentGroupLookup[$groupName]
            if ($null -eq $currentGroup)
            {
                $driftedSetting.Add("Group '$groupName' not found in the current settings.")
                continue
            }

            $desiredOperator = $group.Operator
            $currentOperator = $currentGroup.Operator
            if ([System.String] $desiredOperator -ne [System.String] $currentOperator)
            {
                $driftedSetting.Add("Parameter 'Groups\$groupName\Operator' does not match. Current: '$currentOperator'. Desired: '$desiredOperator'.")
            }

            $currentTypes = [SCSensitivityLabel]::NewMemberLookup($currentGroup.SensitiveInformationType, 'name')
            foreach ($sensitiveInfoType in @($group.SensitiveInformationType))
            {
                if ($null -eq $sensitiveInfoType)
                {
                    continue
                }

                $typeName = [System.String] $sensitiveInfoType.name
                $currentType = $currentTypes[$typeName]
                if ($null -eq $currentType)
                {
                    $driftedSetting.Add("Sensitive Information Type '$typeName' not found in the current settings for group '$groupName'.")
                    continue
                }

                foreach ($propertyName in @('confidencelevel', 'classifiertype', 'mincount', 'maxcount'))
                {
                    if (-not [SCSensitivityLabel]::HasMember($sensitiveInfoType, $propertyName))
                    {
                        continue
                    }

                    $desiredValue = $sensitiveInfoType.$propertyName
                    $currentValue = $currentType.$propertyName
                    if ([System.String] $desiredValue -ne [System.String] $currentValue)
                    {
                        $driftedSetting.Add("Parameter '$propertyName' does not match for Sensitive Information Type '$typeName' in group '$groupName'. Current: '$currentValue'. Desired: '$desiredValue'.")
                    }
                }
            }

            $currentClassifiers = [SCSensitivityLabel]::NewMemberLookup($currentGroup.TrainableClassifier, 'name')
            foreach ($trainableClassifier in @($group.TrainableClassifier))
            {
                if ($null -eq $trainableClassifier)
                {
                    continue
                }

                $classifierName = [System.String] $trainableClassifier.name
                if (-not $currentClassifiers.ContainsKey($classifierName))
                {
                    $driftedSetting.Add("Trainable Classifier '$classifierName' not found in the current settings for group '$groupName'.")
                }
            }
        }

        foreach ($group in $currentGroups)
        {
            if ($null -eq $group)
            {
                continue
            }

            $groupName = [System.String] $group.Name
            $desiredGroup = $desiredGroupLookup[$groupName]
            if ($null -eq $desiredGroup)
            {
                $driftedSetting.Add("Group '$groupName' not found in the desired settings.")
                continue
            }

            $desiredTypes = [SCSensitivityLabel]::NewMemberLookup($desiredGroup.SensitiveInformationType, 'name')
            foreach ($sensitiveInfoType in @($group.SensitiveInformationType))
            {
                if ($null -eq $sensitiveInfoType)
                {
                    continue
                }

                $typeName = [System.String] $sensitiveInfoType.name
                if (-not $desiredTypes.ContainsKey($typeName))
                {
                    $driftedSetting.Add("Sensitive Information Type '$typeName' not found in the desired settings for group '$groupName'.")
                }
            }

            $desiredClassifiers = [SCSensitivityLabel]::NewMemberLookup($desiredGroup.TrainableClassifier, 'name')
            foreach ($trainableClassifier in @($group.TrainableClassifier))
            {
                if ($null -eq $trainableClassifier)
                {
                    continue
                }

                $classifierName = [System.String] $trainableClassifier.name
                if (-not $desiredClassifiers.ContainsKey($classifierName))
                {
                    $driftedSetting.Add("Trainable Classifier '$classifierName' not found in the desired settings for group '$groupName'.")
                }
            }
        }

        $foundSettings = $driftedSetting.Count -eq 0
        if (-not $foundSettings -and $LogDrift)
        {
            New-M365DSCLogEntry -Message "AutoLabelingSettings do not match: `r`n- $($driftedSetting -join "`r`n- ")" `
                -Source 'SCSensitivityLabel'
        }

        Write-Verbose -Message "Test AutoLabelingSettings returns $foundSettings"

        return $foundSettings
    }

    hidden static [System.Boolean] TestAdvancedSettings([System.Object] $DesiredProperty, [System.Object] $CurrentProperty, [System.Boolean] $LogDrift)
    {
        $driftedSetting = [System.Collections.Generic.List[System.String]]::new()
        $currentSettings = [SCSensitivityLabel]::NewMemberLookup($CurrentProperty, 'Key')
        foreach ($desiredSetting in @($DesiredProperty))
        {
            if ($null -eq $desiredSetting)
            {
                continue
            }

            $settingKey = [System.String] $desiredSetting.Key
            $currentSetting = $currentSettings[$settingKey]
            if ($null -eq $currentSetting -or -not [SCSensitivityLabel]::IsSettingValueEqual($desiredSetting.Value, $currentSetting.Value))
            {
                $driftedSetting.Add($settingKey)
            }
        }

        $foundSettings = $driftedSetting.Count -eq 0
        if (-not $foundSettings -and $LogDrift)
        {
            New-M365DSCLogEntry -Message "AdvancedSettings do not match: $($driftedSetting -join ', ')" `
                -Source 'SCSensitivityLabel'
        }

        Write-Verbose -Message "Test AdvancedSettings returns $foundSettings"
        return $foundSettings
    }

    hidden [SCSensitivityLabel] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCSensitivityLabel])
        {
            return $Values
        }

        $result = [SCSensitivityLabel]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_SCLabelSetting
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Advanced settings key.')]
    [System.String] $Key

    [DscProperty()]
    [System.ComponentModel.Description('Advanced settings value.')]
    [System.String[]] $Value
}

class MSFT_SCLabelLocaleSettings
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the Local key.')]
    [System.String] $LocaleKey

    [DscProperty()]
    [System.ComponentModel.Description('The locale settings display names.')]
    [MSFT_SCLabelSetting[]] $LabelSettings
}

class MSFT_SCSLAutoLabelingSettings
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Groups of sensitive information types.')]
    [MSFT_SCSLSensitiveInformationGroup[]] $Groups

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('How to process the various groups')]
    [ValidateSet('And', 'Or')]
    [System.String] $Operator

    [DscProperty()]
    [System.ComponentModel.Description('Display this message to users when the label is applied')]
    [System.String] $PolicyTip

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Specifies what to do when content matches the conditions')]
    [ValidateSet('Automatic', 'Recommend')]
    [System.String] $AutoApplyType
}

class MSFT_SCSLSensitiveInformationGroup
{
    [DscProperty()]
    [System.ComponentModel.Description('Sensitive Information Content Types')]
    [MSFT_SCSLSensitiveInformationType[]] $SensitiveInformationType

    [DscProperty()]
    [System.ComponentModel.Description('Trainable Classifiers')]
    [MSFT_SCSLTrainableClassifiers[]] $TrainableClassifier

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the group')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('How to process the Sensitive Information Types and Trainable Classifiers')]
    [ValidateSet('And', 'Or')]
    [System.String] $Operator
}

class MSFT_SCSLSensitiveInformationType
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the Sensitive Information Type')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('Confidence level value for the Sensitive Information')]
    [ValidateSet('Low', 'Medium', 'High')]
    [System.String] $confidencelevel

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

class MSFT_SCSLTrainableClassifiers
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the Trainable Classifier')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Trainable Classifier')]
    [System.String] $id
}
