using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOAddressBookPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the name that you want this address book policy to be called.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The AddressLists parameter specifies the address lists that will be used by mailbox users who are assigned this address book policy. This parameter accepts multiple values.')]
    [System.String[]] $AddressLists

    [DscProperty()]
    [System.ComponentModel.Description('The GlobalAddressList parameter specifies the identity of the global address list (GAL) that will be used by mailbox users who are assigned this address book policy. You can specify only one GAL for each address book policy.')]
    [System.String] $GlobalAddressList

    [DscProperty()]
    [System.ComponentModel.Description('The OfflineAddressBook parameter specifies the identity of the offline address book (OAB) that will be used by mailbox users who are assigned this address book policy. You can specify only one OAB for each address book policy.')]
    [System.String] $OfflineAddressBook

    [DscProperty()]
    [System.ComponentModel.Description('The RoomList parameter specifies the name of the room address list.')]
    [System.String] $RoomList

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Address Book Policy should exist or not.')]
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

    [EXOAddressBookPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOAddressBookPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Address Book Policy configuration for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $AddressBookPolicy = Get-AddressBookPolicy -Identity $this.Name -ErrorAction SilentlyContinue

                if ($null -eq $AddressBookPolicy)
                {
                    Write-Verbose -Message "Address Book Policy $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $AddressBookPolicy = $this.ExportedInstance
            }

            Write-Verbose -Message "Found Address Book Policy $($this.Name)"
            $result = @{
                Name                  = $AddressBookPolicy.Name
                AddressLists          = [System.String[]]$AddressBookPolicy.AddressLists
                GlobalAddressList     = $AddressBookPolicy.GlobalAddressList
                OfflineAddressBook    = $AddressBookPolicy.OfflineAddressBook
                RoomList              = $AddressBookPolicy.RoomList
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                TenantId              = $this.TenantId
                AccessTokens          = $this.AccessTokens
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

        Write-Verbose -Message "Setting Address Book Policy configuration for $($this.Name)"

        $currentAddressBookPolicyConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $NewAddressBookPolicyParams = @{
            Name               = $this.Name
            AddressLists       = $this.AddressLists
            GlobalAddressList  = $this.GlobalAddressList
            OfflineAddressBook = $this.OfflineAddressBook
            RoomList           = $this.RoomList
            Confirm            = $false
        }

        $SetAddressBookPolicyParams = @{
            Identity           = $this.Name
            AddressLists       = $this.AddressLists
            GlobalAddressList  = $this.GlobalAddressList
            OfflineAddressBook = $this.OfflineAddressBook
            RoomList           = $this.RoomList
            Confirm            = $false
        }

        # CASE: Address Book Policy doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentAddressBookPolicyConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Address Book Policy '$($this.Name)' does not exist but it should. Create and configure it."
            # Create Address Book Policy
            New-AddressBookPolicy @NewAddressBookPolicyParams

        }
        # CASE: Address Book Policy exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentAddressBookPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Address Book Policy '$($this.Name)' exists but it shouldn't. Remove it."
            Remove-AddressBookPolicy -Identity $this.Name -Confirm:$false
        }
        # CASE: Address Book Policy exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentAddressBookPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Address Book Policy '$($this.Name)' already exists, but needs updating."
            Write-Verbose -Message "Setting Address Book Policy $($this.Name) with values: $(Convert-M365DscHashtableToString -Hashtable $SetAddressBookPolicyParams)"
            Set-AddressBookPolicy @SetAddressBookPolicyParams
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
            [array]$AllAddressBookPolicies = Get-AddressBookPolicy -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($AllAddressBookPolicies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($AddressBookPolicy in $AllAddressBookPolicies)
            {
                Write-M365DSCHost -Message "    |---[$i/$($AllAddressBookPolicies.Count)] $($AddressBookPolicy.Name)" -DeferWrite

                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $Params = @{
                    Name                  = $AddressBookPolicy.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $AddressBookPolicy
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
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
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOAddressBookPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOAddressBookPolicy])
        {
            return $Values
        }

        $result = [EXOAddressBookPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
