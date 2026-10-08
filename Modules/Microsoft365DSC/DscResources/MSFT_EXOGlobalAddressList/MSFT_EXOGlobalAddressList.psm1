using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOGlobalAddressList : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name of the GAL. The maximum length is 64 characters.')]
    [ValidateLength(1, 64)]
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
    [System.ComponentModel.Description('The IncludedRecipients parameter specifies a precanned filter that''s based on the recipient type.')]
    [ValidateSet('', 'AllRecipients', 'MailboxUsers', 'MailContacts', 'MailGroups', 'MailUsers', 'Resources')]
    [System.String[]] $IncludedRecipients

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientFilter parameter specifies an OPath filter that''s based on the value of any available recipient property.')]
    [System.String] $RecipientFilter

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Global Address List should exist or not.')]
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

    [EXOGlobalAddressList] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOGlobalAddressList]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Global Address List configuration for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                if ($null -eq (Get-Command 'Get-GlobalAddressList' -ErrorAction SilentlyContinue))
                {
                    Write-Warning -Message "Command 'Get-GlobalAddressList' not found. Returning Absent for Global Address List $($this.Name)."
                    return $this.AsResult($nullReturn)
                }

                $GlobalAddressList = Get-GlobalAddressList -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $GlobalAddressList)
                {
                    Write-Verbose -Message "Global Address List $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $GlobalAddressList = $this.ExportedInstance
            }

            $includedRecipientsValue = ''
            if ($null -ne $GlobalAddressList.IncludedRecipients)
            {
                $includedRecipientsValue = $GlobalAddressList.IncludedRecipients
            }

            $result = @{
                Name                         = $GlobalAddressList.Name
                ConditionalCompany           = $GlobalAddressList.ConditionalCompany
                ConditionalCustomAttribute1  = $GlobalAddressList.ConditionalCustomAttribute1
                ConditionalCustomAttribute10 = $GlobalAddressList.ConditionalCustomAttribute10
                ConditionalCustomAttribute11 = $GlobalAddressList.ConditionalCustomAttribute11
                ConditionalCustomAttribute12 = $GlobalAddressList.ConditionalCustomAttribute12
                ConditionalCustomAttribute13 = $GlobalAddressList.ConditionalCustomAttribute13
                ConditionalCustomAttribute14 = $GlobalAddressList.ConditionalCustomAttribute14
                ConditionalCustomAttribute15 = $GlobalAddressList.ConditionalCustomAttribute15
                ConditionalCustomAttribute2  = $GlobalAddressList.ConditionalCustomAttribute2
                ConditionalCustomAttribute3  = $GlobalAddressList.ConditionalCustomAttribute3
                ConditionalCustomAttribute4  = $GlobalAddressList.ConditionalCustomAttribute4
                ConditionalCustomAttribute5  = $GlobalAddressList.ConditionalCustomAttribute5
                ConditionalCustomAttribute6  = $GlobalAddressList.ConditionalCustomAttribute6
                ConditionalCustomAttribute7  = $GlobalAddressList.ConditionalCustomAttribute7
                ConditionalCustomAttribute8  = $GlobalAddressList.ConditionalCustomAttribute8
                ConditionalCustomAttribute9  = $GlobalAddressList.ConditionalCustomAttribute9
                ConditionalDepartment        = $GlobalAddressList.ConditionalDepartment
                ConditionalStateOrProvince   = $GlobalAddressList.ConditionalStateOrProvince
                IncludedRecipients           = $includedRecipientsValue
                RecipientFilter              = $GlobalAddressList.RecipientFilter
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

            Write-Verbose -Message "Found Global Address List $($this.Name)"
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

        Write-Verbose -Message "Setting Global Address List configuration for $($this.Name)"

        $currentGlobalAddressListConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        # RecipientFilter parameter cannot be used in combination with the IncludedRecipients parameter or any Conditional parameters (which are used to create precanned filters).
        if ($this.RecipientFilter)
        {
            $NewGlobalAddressListParams = @{
                Name            = $this.Name
                RecipientFilter = $this.RecipientFilter
                Confirm         = $false
            }
        }
        else
        {
            $NewGlobalAddressListParams = @{
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
                Confirm                      = $false
            }

            if (-not [System.String]::IsNullOrEmpty($this.IncludedRecipients))
            {
                $NewGlobalAddressListParams.Add('IncludedRecipients', $this.IncludedRecipients)
            }
        }

        $SetGlobalAddressListParams = @{
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
            Confirm                      = $false
        }

        if (-not [System.String]::IsNullOrEmpty($this.IncludedRecipients))
        {
            $SetGlobalAddressListParams.Add('IncludedRecipients', $this.IncludedRecipients)
        }

        if (-not [System.String]::IsNullOrEmpty($this.RecipientFilter))
        {
            $SetGlobalAddressListParams.Add('RecipientFilter', $this.RecipientFilter)
        }

        # CASE: Global Address List doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentGlobalAddressListConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Global Address List '$($this.Name)' does not exist but it should. Create and configure it."
            # Create Global Address List
            New-GlobalAddressList @NewGlobalAddressListParams

        }
        # CASE: Global Address List exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentGlobalAddressListConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Global Address List '$($this.Name)' exists but it shouldn't. Remove it."
            Remove-GlobalAddressList -Identity $this.Name -Confirm:$false
        }
        # CASE: Global Address List exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentGlobalAddressListConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Global Address List '$($this.Name)' already exists, but needs updating."
            Write-Verbose -Message "Setting Global Address List $($this.Name) with values: $(Convert-M365DscHashtableToString -Hashtable $SetGlobalAddressListParams)"
            Set-GlobalAddressList @SetGlobalAddressListParams
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

        if ($null -eq (Get-Command 'Get-GlobalAddressList' -ErrorAction SilentlyContinue))
        {
            Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered to allow for Global Address List" -CommitWrite
            return ''
        }

        try
        {
            [array]$AllGlobalAddressLists = Get-GlobalAddressList -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            if ($AllGlobalAddressLists.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($GlobalAddressList in $AllGlobalAddressLists)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllGlobalAddressLists.Count)] $($GlobalAddressList.Name)" -DeferWrite

                $Params = @{
                    Name                  = $GlobalAddressList.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $GlobalAddressList
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

    hidden [EXOGlobalAddressList] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOGlobalAddressList])
        {
            return $Values
        }

        $result = [EXOGlobalAddressList]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
