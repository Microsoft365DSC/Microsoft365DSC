using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOMailContact : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies a unique name for the mail contact.')]
    [System.String] $Name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The ExternalEmailAddress parameter specifies the target email address of the mail contact or mail user. By default, this value is used as the primary email address of the mail contact or mail user.')]
    [System.String] $ExternalEmailAddress

    [DscProperty()]
    [System.ComponentModel.Description('The Alias parameter specifies the Exchange alias (also known as the mail nickname) for the recipient. This value identifies the recipient as a mail-enabled object, and shouldn''t be confused with multiple email addresses for the same recipient (also known as proxy addresses). A recipient can have only one Alias value. The maximum length is 64 characters.')]
    [ValidateLength(0, 64)]
    [System.String] $Alias

    [DscProperty()]
    [System.ComponentModel.Description('The DisplayName parameter specifies the display name of the mail contact. The display name is visible in the Exchange admin center and in address lists. ')]
    [ValidateLength(0, 256)]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The FirstName parameter specifies the user''s first name.')]
    [System.String] $FirstName

    [DscProperty()]
    [System.ComponentModel.Description('The Initials parameter specifies the user''s middle initials.')]
    [System.String] $Initials

    [DscProperty()]
    [System.ComponentModel.Description('The LastName parameter specifies the user''s last name.')]
    [System.String] $LastName

    [DscProperty()]
    [System.ComponentModel.Description('The MacAttachmentFormat parameter specifies the Apple Macintosh operating system attachment format to use for messages sent to the mail contact or mail user. Valid values are: BinHex, UuEncode, AppleSingle, AppleDouble')]
    [ValidateSet('BinHex', 'UuEncode', 'AppleSingle', 'AppleDouble')]
    [System.String] $MacAttachmentFormat

    [DscProperty()]
    [System.ComponentModel.Description('The MessageBodyFormat parameter specifies the message body format for messages sent to the mail contact or mail user. Valid values are: Text, Html, TextAndHtml')]
    [ValidateSet('Text', 'Html', 'TextAndHtml')]
    [System.String] $MessageBodyFormat

    [DscProperty()]
    [System.ComponentModel.Description('The MessageFormat parameter specifies the message format for messages sent to the mail contact or mail user. Valid values are: Mime, Text')]
    [ValidateSet('Mime', 'Text')]
    [System.String] $MessageFormat

    [DscProperty()]
    [System.ComponentModel.Description('The ModeratedBy parameter specifies one or more moderators for this mail contact. A moderator approves messages sent to the mail contact before the messages are delivered. A moderator must be a mailbox, mail user, or mail contact in your organization.')]
    [System.String[]] $ModeratedBy

    [DscProperty()]
    [System.ComponentModel.Description('The ModerationEnabled parameter specifies whether moderation is enabled for this recipient.')]
    [System.Nullable[System.Boolean]] $ModerationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OrganizationalUnit parameter specifies the location in Active Directory where the new contact is created.')]
    [System.String] $OrganizationalUnit

    [DscProperty()]
    [System.ComponentModel.Description('The SendModerationNotifications parameter specifies when moderation notification messages are sent. Valid values are: ALways, Internal, Never')]
    [ValidateSet('Always', 'Internal', 'Never')]
    [System.String] $SendModerationNotifications

    [DscProperty()]
    [System.ComponentModel.Description('The UsePreferMessageFormat specifies whether the message format settings configured for the mail user or mail contact override the global settings configured for the remote domain or configured by the message sender')]
    [System.Nullable[System.Boolean]] $UsePreferMessageFormat

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute1 parameter specifies the value of the CustomAttribute1')]
    [System.String] $CustomAttribute1

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute2 parameter specifies the value of the CustomAttribute2')]
    [System.String] $CustomAttribute2

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute3 parameter specifies the value of the CustomAttribute3')]
    [System.String] $CustomAttribute3

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute4 parameter specifies the value of the CustomAttribute4')]
    [System.String] $CustomAttribute4

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute5 parameter specifies the value of the CustomAttribute5')]
    [System.String] $CustomAttribute5

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute6 parameter specifies the value of the CustomAttribute6')]
    [System.String] $CustomAttribute6

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute7 parameter specifies the value of the CustomAttribute7')]
    [System.String] $CustomAttribute7

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute8 parameter specifies the value of the CustomAttribute8')]
    [System.String] $CustomAttribute8

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute9 parameter specifies the value of the CustomAttribute9')]
    [System.String] $CustomAttribute9

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute10 parameter specifies the value of the CustomAttribute10')]
    [System.String] $CustomAttribute10

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute11 parameter specifies the value of the CustomAttribute11')]
    [System.String] $CustomAttribute11

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute12 parameter specifies the value of the CustomAttribute12')]
    [System.String] $CustomAttribute12

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute13 parameter specifies the value of the CustomAttribute13')]
    [System.String] $CustomAttribute13

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute14 parameter specifies the value of the CustomAttribute14')]
    [System.String] $CustomAttribute14

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAttribute15 parameter specifies the value of the CustomAttribute15')]
    [System.String] $CustomAttribute15

    [DscProperty()]
    [System.ComponentModel.Description('The ExtensionCustomAttribute1 parameter specifies the value of the ExtensionCustomAttribute1')]
    [System.String[]] $ExtensionCustomAttribute1

    [DscProperty()]
    [System.ComponentModel.Description('The ExtensionCustomAttribute2 parameter specifies the value of the ExtensionCustomAttribute2')]
    [System.String[]] $ExtensionCustomAttribute2

    [DscProperty()]
    [System.ComponentModel.Description('The ExtensionCustomAttribute3 parameter specifies the value of the ExtensionCustomAttribute3')]
    [System.String[]] $ExtensionCustomAttribute3

    [DscProperty()]
    [System.ComponentModel.Description('The ExtensionCustomAttribute4 parameter specifies the value of the ExtensionCustomAttribute4')]
    [System.String[]] $ExtensionCustomAttribute4

    [DscProperty()]
    [System.ComponentModel.Description('The ExtensionCustomAttribute5 parameter specifies the value of the ExtensionCustomAttribute5')]
    [System.String[]] $ExtensionCustomAttribute5

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this Contact should exist.')]
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

    EXOMailContact() : base()
    {
        $this.ResourceCache['NewParameters'] = @('Alias', 'DisplayName', 'ExternalEmailAddress', 'FirstName', 'Initials', 'LastName', 'MacAttachmentFormat', 'MessageBodyFormat', 'MessageFormat', 'ModeratedBy', 'ModerationEnabled', 'Name', 'OrganizationalUnit', 'SendModerationNotifications', 'UsePreferMessageFormat')
        $this.ResourceCache['SetParameters'] = @('AcceptMessagesOnlyFrom', 'AcceptMessagesOnlyFromDLMembers', 'AcceptMessagesOnlyFromSendersOrMembers', 'Alias', 'BypassModerationFromSendersOrMembers', 'CustomAttribute1', 'CustomAttribute10', 'CustomAttribute11', 'CustomAttribute12', 'CustomAttribute13', 'CustomAttribute14',
                          'CustomAttribute15', 'CustomAttribute2', 'CustomAttribute3', 'CustomAttribute4', 'CustomAttribute5', 'CustomAttribute6', 'CustomAttribute7', 'CustomAttribute8', 'CustomAttribute9', 'DisplayName', 'EmailAddresses', 'ExtensionCustomAttribute1', 'ExtensionCustomAttribute2',
                          'ExtensionCustomAttribute3', 'ExtensionCustomAttribute4', 'ExtensionCustomAttribute5', 'ExternalEmailAddress', 'ForceUpgrade', 'GrantSendOnBehalfTo', 'HiddenFromAddressListsEnabled', 'Identity', 'MacAttachmentFormat', 'MailTip', 'MailTipTranslations', 'MessageBodyFormat',
                          'MessageFormat', 'ModeratedBy', 'ModerationEnabled', 'Name', 'RejectMessagesFrom', 'RejectMessagesFromDLMembers', 'RejectMessagesFromSendersOrMembers', 'RequireSenderAuthenticationEnabled', 'SendModerationNotifications', 'SimpleDisplayName', 'UseMapiRichTextFormat',
                          'UsePreferMessageFormat', 'UserCertificate', 'UserSMimeCertificate', 'WindowsEmailAddress')
    }

    [EXOMailContact] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOMailContact]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Mail Contact for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $contact = Get-MailContact -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $contact)
                {
                    Write-Verbose -Message "Contact $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $contact = $this.ExportedInstance
            }

            Write-Verbose -Message "Found Mail Contact $($this.Name)"

            $contactDetails = $null
            if ($null -ne $this.ResourceCache['ContactDetails'])
            {
                $contactDetails = $this.ResourceCache['ContactDetails'][[System.String]$contact.Identity]
            }
            if ($null -eq $contactDetails)
            {
                $contactDetails = Get-Contact -Identity ([System.String]$contact.Identity) -ErrorAction SilentlyContinue
            }

            $result = @{
                Name                        = $this.Name
                ExternalEmailAddress        = $contact.ExternalEmailAddress
                Alias                       = $contact.Alias
                DisplayName                 = $contact.DisplayName
                FirstName                   = $contactDetails.FirstName
                Initials                    = $contactDetails.Initials
                LastName                    = $contactDetails.LastName
                MacAttachmentFormat         = $contact.MacAttachmentFormat
                MessageBodyFormat           = $contact.MessageBodyFormat
                MessageFormat               = $contact.MessageFormat
                ModeratedBy                 = $contact.ModeratedBy
                ModerationEnabled           = $contact.ModerationEnabled
                OrganizationalUnit          = $contact.OrganizationalUnit
                SendModerationNotifications = $contact.SendModerationNotifications
                UsePreferMessageFormat      = $contact.UsePreferMessageFormat
                Ensure                      = 'Present'
                Credential                  = $this.Credential
                ApplicationId               = $this.ApplicationId
                CertificateThumbprint       = $this.CertificateThumbprint
                CertificatePath             = $this.CertificatePath
                CertificatePassword         = $this.CertificatePassword
                ManagedIdentity             = $this.ManagedIdentity
                TenantId                    = $this.TenantId
                AccessTokens                = $this.AccessTokens
            }

            foreach ($i in (1..15))
            {
                if ($contact."CustomAttribute$i")
                {
                    $result."CustomAttribute$i" = $contact."CustomAttribute$i"
                }
            }
            foreach ($i in (1..5))
            {
                if ($contact."ExtensionCustomAttribute$i")
                {
                    $result."ExtensionCustomAttribute$i" = $contact."ExtensionCustomAttribute$i"
                }
                else
                {
                    $result."ExtensionCustomAttribute$i" = @()
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

        Write-Verbose -Message "Setting Mail Contact configuration for $($this.Name)"

        $currentContact = $this.Get().ToHashtable()

        $null = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        # Mail Contact doesn't exist but it should
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters.Remove('Name') | Out-Null
        if ($this.Ensure -eq 'Present' -and $currentContact.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "The Mail Contact '$($this.Name)' does not exist but it should. Creating Mail Contact."
            $createParameters = @{ Name = $this.Name }
            $updateParameters = @{}
            foreach ($param in $this.ResourceCache['NewParameters'])
            {
                if (-not $createParameters.ContainsKey($param) -and $boundParameters.ContainsKey($param))
                {
                    $createParameters.Add($param, $this.GetBoundParameters()[$param])
                }
            }
            foreach ($param in $this.ResourceCache['SetParameters'])
            {
                if (-not $updateParameters.ContainsKey($param) -and $boundParameters.ContainsKey($param))
                {
                    $updateParameters.Add($param, $this.GetBoundParameters()[$param])
                }
            }
            $updateParameters.Add('Identity', $this.Name)

            New-MailContact @createParameters -ErrorAction Stop
            $null = Wait-M365DSCCondition -Description "Mail Contact {$($createParameters.Name)}" -ConsecutiveCount 2 -ScriptBlock {
                $null -ne (Get-MailContact -Identity $createParameters.Name -ErrorAction 'SilentlyContinue')
            }

            Set-MailContact @updateParameters -ErrorAction Stop
        }
        elseif ($this.Ensure -eq 'Present' -and $currentContact.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Mail Contact '$($this.Name)' already exists. Updating settings"
            $updateParameters = @{}
            foreach ($param in $this.ResourceCache['SetParameters'])
            {
                if (-not $updateParameters.ContainsKey($param) -and $boundParameters.ContainsKey($param))
                {
                    $updateParameters.Add($param, $this.GetBoundParameters()[$param])
                }
            }
            $updateParameters.Add('Identity', $this.Name)
            Set-MailContact @updateParameters

            $contactParameters = @{}
            foreach ($param in @('FirstName', 'Initials', 'LastName'))
            {
                if ($boundParameters.ContainsKey($param) -and $this.$param -ne $currentContact.$param)
                {
                    $contactParameters.Add($param, $this.$param)
                }
            }
            if ($contactParameters.Count -gt 0)
            {
                Set-Contact -Identity $this.Name @contactParameters
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentContact.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Mail Contact'$($this.Name)' exists but shouldn't. Removing Mail Contact."
            Remove-MailContact -Identity $this.Name -Confirm:$false
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
            $dscContent = [System.Text.StringBuilder]::new()
            [array]$contactList = Get-MailContact -ResultSize 'Unlimited' -ErrorAction Stop
            $this.ResourceCache['ContactDetails'] = @{}
            foreach ($contactDetails in (Get-Contact -RecipientTypeDetails 'MailContact' -ResultSize 'Unlimited' -ErrorAction Stop))
            {
                $this.ResourceCache['ContactDetails'][[System.String]$contactDetails.Identity] = $contactDetails
            }
            if ($contactList.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1

            foreach ($contact in $contactList)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($contactList.Count)] $($contact.Name)" -DeferWrite
                $params = @{
                    Name                  = $contact.Name
                    ExternalEmailAddress  = $contact.ExternalEmailAddress
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $contact
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
                $i ++
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
            ExcludedProperties = @('OrganizationalUnit')
        }
    }

    hidden [EXOMailContact] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOMailContact])
        {
            return $Values
        }

        $result = [EXOMailContact]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
