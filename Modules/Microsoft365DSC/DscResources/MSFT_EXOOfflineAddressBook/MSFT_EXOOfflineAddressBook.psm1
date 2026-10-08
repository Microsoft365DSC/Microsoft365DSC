using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOOfflineAddressBook : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name of the Offline Address Book. The maximum length is 64 characters.')]
    [ValidateLength(1, 64)]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The AddressLists parameter specifies the address lists or global address lists that are included in the OAB. You can use any value that uniquely identifies the address list.')]
    [System.String[]] $AddressLists

    [DscProperty()]
    [System.ComponentModel.Description('The ConfiguredAttributes parameter specifies the recipient MAPI properties that are available in the OAB.')]
    [System.String[]] $ConfiguredAttributes

    [DscProperty()]
    [System.ComponentModel.Description('The DiffRetentionPeriod parameter specifies the number of days that the OAB difference files are stored on the server.')]
    [System.String] $DiffRetentionPeriod

    [DscProperty()]
    [System.ComponentModel.Description('The IsDefault parameter specifies whether the OAB is used by all mailboxes and mailbox databases that don''t have an OAB specified.')]
    [System.Nullable[System.Boolean]] $IsDefault

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Offline Address Book should exist or not.')]
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

    [EXOOfflineAddressBook] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOOfflineAddressBook]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Offline Address Book configuration for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $OfflineAddressBook = Get-OfflineAddressBook -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $OfflineAddressBook)
                {
                    Write-Verbose -Message "Offline Address Book $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $OfflineAddressBook = $this.ExportedInstance
            }

            Write-Verbose -Message "Offline Address Book with Name $($OfflineAddressBook.Name) found"

            $result = @{
                Name                  = $OfflineAddressBook.Name
                AddressLists          = $OfflineAddressBook.AddressLists
                ConfiguredAttributes  = $OfflineAddressBook.ConfiguredAttributes
                DiffRetentionPeriod   = $OfflineAddressBook.DiffRetentionPeriod
                IsDefault             = $OfflineAddressBook.IsDefault
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

        Write-Verbose -Message "Setting Offline Address Book configuration for $($this.Name)"

        $currentOfflineAddressBookConfig = $this.Get().ToHashtable()
        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $NewOfflineAddressBookParams = @{
            Name                = $this.Name
            AddressLists        = $this.AddressLists
            DiffRetentionPeriod = $this.DiffRetentionPeriod
            IsDefault           = $this.IsDefault
            Confirm             = $false
        }

        $SetOfflineAddressBookParams = @{
            Identity             = $this.Name
            Name                 = $this.Name
            AddressLists         = $this.AddressLists
            ConfiguredAttributes = $this.ConfiguredAttributes
            DiffRetentionPeriod  = $this.DiffRetentionPeriod
            IsDefault            = $this.IsDefault
            Confirm              = $false
        }
        $NewOfflineAddressBookParams = Remove-NullEntriesFromHashtable -Hash $NewOfflineAddressBookParams
        $SetOfflineAddressBookParams = Remove-NullEntriesFromHashtable -Hash $SetOfflineAddressBookParams

        # CASE: Offline Address Book doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentOfflineAddressBookConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Offline Address Book '$($this.Name)' does not exist but it should. Create and configure it."
            # Create Offline Address Book
            New-OfflineAddressBook @NewOfflineAddressBookParams

        }
        # CASE: Offline Address Book exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentOfflineAddressBookConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Offline Address Book '$($this.Name)' exists but it shouldn't. Remove it."
            Remove-OfflineAddressBook -Identity $this.Name -Confirm:$false -Force
        }
        # CASE: Offline Address Book exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentOfflineAddressBookConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Offline Address Book '$($this.Name)' already exists, but needs updating."
            Write-Verbose -Message "Setting Offline Address Book $($this.Name) with values: $(Convert-M365DscHashtableToString -Hashtable $SetOfflineAddressBookParams)"
            Set-OfflineAddressBook @SetOfflineAddressBookParams
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
            [array]$AllOfflineAddressBooks = Get-OfflineAddressBook -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()

            if ($AllOfflineAddressBooks.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($OfflineAddressBook in $AllOfflineAddressBooks)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllOfflineAddressBooks.Count)] $($OfflineAddressBook.Name)" -DeferWrite

                $Params = @{
                    Name                  = $OfflineAddressBook.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $OfflineAddressBook
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

    hidden [EXOOfflineAddressBook] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOOfflineAddressBook])
        {
            return $Values
        }

        $result = [EXOOfflineAddressBook]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
