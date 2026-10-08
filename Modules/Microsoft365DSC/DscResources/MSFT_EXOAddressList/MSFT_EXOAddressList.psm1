using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOAddressList : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies a unique name for the address list.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCompany parameter specifies a precanned filter that''s based on the value of the recipient''s Company property.')]
    [System.String[]] $ConditionalCompany

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute1 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute1 property.')]
    [System.String[]] $ConditionalCustomAttribute1

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute10 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute10 property.')]
    [System.String[]] $ConditionalCustomAttribute10

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute11 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute11 property.')]
    [System.String[]] $ConditionalCustomAttribute11

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute12 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute12 property.')]
    [System.String[]] $ConditionalCustomAttribute12

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute13 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute13 property.')]
    [System.String[]] $ConditionalCustomAttribute13

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute14 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute14 property.')]
    [System.String[]] $ConditionalCustomAttribute14

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute15 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute15 property.')]
    [System.String[]] $ConditionalCustomAttribute15

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute2 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute2 property.')]
    [System.String[]] $ConditionalCustomAttribute2

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute3 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute3 property.')]
    [System.String[]] $ConditionalCustomAttribute3

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute4 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute4 property.')]
    [System.String[]] $ConditionalCustomAttribute4

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute5 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute5 property.')]
    [System.String[]] $ConditionalCustomAttribute5

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute6 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute6 property.')]
    [System.String[]] $ConditionalCustomAttribute6

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute7 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute7 property.')]
    [System.String[]] $ConditionalCustomAttribute7

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute8 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute8 property.')]
    [System.String[]] $ConditionalCustomAttribute8

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalCustomAttribute9 parameter specifies a precanned filter that''s based on the value of the recipient''s CustomAttribute9 property.')]
    [System.String[]] $ConditionalCustomAttribute9

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalDepartment parameter specifies a precanned filter that''s based on the value of the recipient''s Department property.')]
    [System.String[]] $ConditionalDepartment

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalStateOrProvince parameter specifies a precanned filter that''s based on the value of the recipient''s StateOrProvince property.')]
    [System.String[]] $ConditionalStateOrProvince

    [DscProperty()]
    [System.ComponentModel.Description('The DisplayName parameter specifies the display name of the address list.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The IncludedRecipients parameter specifies a precanned filter that''s based on the recipient type.')]
    [ValidateSet('AllRecipients', 'MailboxUsers', 'MailContacts', 'MailGroups', 'MailUsers', 'Resources')]
    [System.String[]] $IncludedRecipients

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientFilter parameter specifies a custom OPath filter that''s based on the value of any available recipient property.')]
    [System.String] $RecipientFilter

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this AddressList should exist.')]
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

    [EXOAddressList] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOAddressList]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AddressList with Name {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                Write-Verbose -Message "Getting configuration of AddressList for $($this.Name)"

                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                if ($null -eq (Get-Command 'Get-AddressList' -ErrorAction SilentlyContinue))
                {
                    return $this.AsResult($nullReturn)
                }

                $AddressList = Get-AddressList -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $AddressList)
                {
                    Write-Verbose -Message "Address List $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $AddressList = $this.ExportedInstance
            }

            $includedRecipientsValue = @()
            if ($null -ne $AddressList.IncludedRecipients)
            {
                $includedRecipientsValue = $AddressList.IncludedRecipients
            }

            Write-Verbose -Message "Found AddressList $($this.Name)"

            $result = @{
                Name                         = $this.Name
                ConditionalCompany           = $AddressList.ConditionalCompany
                ConditionalCustomAttribute1  = $AddressList.ConditionalCustomAttribute1
                ConditionalCustomAttribute10 = $AddressList.ConditionalCustomAttribute10
                ConditionalCustomAttribute11 = $AddressList.ConditionalCustomAttribute11
                ConditionalCustomAttribute12 = $AddressList.ConditionalCustomAttribute12
                ConditionalCustomAttribute13 = $AddressList.ConditionalCustomAttribute13
                ConditionalCustomAttribute14 = $AddressList.ConditionalCustomAttribute14
                ConditionalCustomAttribute15 = $AddressList.ConditionalCustomAttribute15
                ConditionalCustomAttribute2  = $AddressList.ConditionalCustomAttribute2
                ConditionalCustomAttribute3  = $AddressList.ConditionalCustomAttribute3
                ConditionalCustomAttribute4  = $AddressList.ConditionalCustomAttribute4
                ConditionalCustomAttribute5  = $AddressList.ConditionalCustomAttribute5
                ConditionalCustomAttribute6  = $AddressList.ConditionalCustomAttribute6
                ConditionalCustomAttribute7  = $AddressList.ConditionalCustomAttribute7
                ConditionalCustomAttribute8  = $AddressList.ConditionalCustomAttribute8
                ConditionalCustomAttribute9  = $AddressList.ConditionalCustomAttribute9
                ConditionalDepartment        = $AddressList.ConditionalDepartment
                ConditionalStateOrProvince   = $AddressList.ConditionalStateOrProvince
                DisplayName                  = $AddressList.DisplayName
                IncludedRecipients           = $includedRecipientsValue
                RecipientFilter              = $AddressList.RecipientFilter
                Ensure                       = 'Present'
                Credential                   = $this.Credential
                ApplicationId                = $this.ApplicationId
                CertificateThumbprint        = $this.CertificateThumbprint
                CertificatePath              = $this.CertificatePath
                CertificatePassword          = $this.CertificatePassword
                ManagedIdentity              = $this.ManagedIdentity
                TenantId                     = $this.TenantId
                AccessTokens                 = $this.AccessTokens
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

        Write-Verbose -Message "Setting Address List configuration with Name {$($this.Name)}"

        $currentAddressListConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        #Address List doesn't exist but it should
        if ($this.Ensure -eq 'Present' -and $currentAddressListConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "The Address List '$($this.Name)' does not exist but it should. Creating Address List."

            if ($this.RecipientFilter)
            {
                Write-Verbose -Message "You can't use RecipientFilter and precanned filters at the same time. All precanned filters will be ignored."
                $NewAddressListParams = @{
                    Name            = $this.Name
                    RecipientFilter = $this.RecipientFilter
                    Confirm         = $false
                }
            }
            else
            {
                $NewAddressListParams = @{
                    Name                         = $this.Name
                    ConditionalCompany           = $this.ConditionalCompany
                    ConditionalCustomAttribute1  = $this.ConditionalCustomAttribute1
                    ConditionalCustomAttribute10 = $this.ConditionalCustomAttribute10
                    ConditionalCustomAttribute11 = $this.ConditionalCustomAttribute11
                    ConditionalCustomAttribute12 = $this.ConditionalCustomAttribute12
                    ConditionalCustomAttribute13 = $this.ConditionalCustomAttribute13
                    ConditionalCustomAttribute14 = $this.ConditionalCustomAttribute14
                    ConditionalCustomAttribute15 = $this.ConditionalCustomAttribute15
                    ConditionalCustomAttribute2  = $this.ConditionalCustomAttribute2
                    ConditionalCustomAttribute3  = $this.ConditionalCustomAttribute3
                    ConditionalCustomAttribute4  = $this.ConditionalCustomAttribute4
                    ConditionalCustomAttribute5  = $this.ConditionalCustomAttribute5
                    ConditionalCustomAttribute6  = $this.ConditionalCustomAttribute6
                    ConditionalCustomAttribute7  = $this.ConditionalCustomAttribute7
                    ConditionalCustomAttribute8  = $this.ConditionalCustomAttribute8
                    ConditionalCustomAttribute9  = $this.ConditionalCustomAttribute9
                    ConditionalDepartment        = $this.ConditionalDepartment
                    ConditionalStateOrProvince   = $this.ConditionalStateOrProvince
                    IncludedRecipients           = $this.IncludedRecipients
                    Confirm                      = $false
                }

                if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                {
                    $NewAddressListParams.Add('DisplayName', $this.DisplayName)
                }
            }
            New-AddressList @NewAddressListParams
        }
        #Address List exists but shouldn't
        elseif ($this.Ensure -eq 'Absent' -and $currentAddressListConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Address List '$($this.Name)' exists but shouldn't. Removing Address List."
            Remove-AddressList -Identity $this.Name -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Present' -and $currentAddressListConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Address List '$($this.Name)' already exists. Updating settings"
            if ($this.RecipientFilter)
            {
                Write-Verbose -Message "You can't use RecipientFilter and precanned filters at the same time. All precanned filters will be ignored."
                $SetAddressListParams = @{
                    Identity        = $this.Name
                    Name            = $this.Name
                    RecipientFilter = $this.RecipientFilter
                    Confirm         = $false
                }
            }
            else
            {
                $SetAddressListParams = @{
                    Identity                     = $this.Name
                    Name                         = $this.Name
                    ConditionalCompany           = $this.ConditionalCompany
                    ConditionalCustomAttribute1  = $this.ConditionalCustomAttribute1
                    ConditionalCustomAttribute10 = $this.ConditionalCustomAttribute10
                    ConditionalCustomAttribute11 = $this.ConditionalCustomAttribute11
                    ConditionalCustomAttribute12 = $this.ConditionalCustomAttribute12
                    ConditionalCustomAttribute13 = $this.ConditionalCustomAttribute13
                    ConditionalCustomAttribute14 = $this.ConditionalCustomAttribute14
                    ConditionalCustomAttribute15 = $this.ConditionalCustomAttribute15
                    ConditionalCustomAttribute2  = $this.ConditionalCustomAttribute2
                    ConditionalCustomAttribute3  = $this.ConditionalCustomAttribute3
                    ConditionalCustomAttribute4  = $this.ConditionalCustomAttribute4
                    ConditionalCustomAttribute5  = $this.ConditionalCustomAttribute5
                    ConditionalCustomAttribute6  = $this.ConditionalCustomAttribute6
                    ConditionalCustomAttribute7  = $this.ConditionalCustomAttribute7
                    ConditionalCustomAttribute8  = $this.ConditionalCustomAttribute8
                    ConditionalCustomAttribute9  = $this.ConditionalCustomAttribute9
                    ConditionalDepartment        = $this.ConditionalDepartment
                    ConditionalStateOrProvince   = $this.ConditionalStateOrProvince
                    IncludedRecipients           = $this.IncludedRecipients
                    Confirm                      = $false
                }

                if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                {
                    $SetAddressListParams.Add('DisplayName', $this.DisplayName)
                }

                if (-not [System.String]::IsNullOrEmpty($this.RecipientFilter))
                {
                    $SetAddressListParams.Add('RecipientFilter', $this.RecipientFilter)
                }
            }
            Write-Verbose -Message "Setting Address List '$($this.Name)' with values: $(Convert-M365DscHashtableToString -Hashtable $SetAddressListParams)"
            Set-AddressList @SetAddressListParams
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
            if ($null -eq (Get-Command 'Get-AddressList' -ErrorAction SilentlyContinue))
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered to allow for Address Lists"
                return ''
            }
            $dscContent = [System.Text.StringBuilder]::new()
            [array] $this.ResourceCache['exportedInstances'] = Get-Addresslist -ErrorAction Stop
            if ($this.ResourceCache['exportedInstances'].Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1

            foreach ($addressList in $this.ResourceCache['exportedInstances'])
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($this.ResourceCache['exportedInstances'].Count)] $($addressList.Name)" -DeferWrite
                $params = @{
                    Name                  = $addressList.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $addressList
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

    hidden [EXOAddressList] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOAddressList])
        {
            return $Values
        }

        $result = [EXOAddressList]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
