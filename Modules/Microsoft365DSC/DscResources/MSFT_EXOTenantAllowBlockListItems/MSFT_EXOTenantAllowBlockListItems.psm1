using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOTenantAllowBlockListItems : M365DSCResourceBase
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The action (allow/block) to take for this list entry')]
    [ValidateSet('Allow', 'Block')]
    [System.String] $Action

    [DscProperty(Key)]
    [System.ComponentModel.Description('The value that you want to add to the Tenant Allow/Block List based on the ListType parameter value')]
    [System.String] $Value

    [DscProperty()]
    [System.ComponentModel.Description('The expiration date of the entry in Coordinated Universal Time (UTC)')]
    [System.Nullable[System.DateTime]] $ExpirationDate

    [DscProperty()]
    [System.ComponentModel.Description('Specifies that the entry never expires. Cannot be combined with ExpirationDate.')]
    [System.Nullable[System.Boolean]] $NoExpiration

    [DscProperty()]
    [System.ComponentModel.Description('The subtype for this entry')]
    [ValidateSet('AdvancedDelivery', 'Submission', 'Tenant')]
    [System.String] $ListSubType

    [DscProperty(Key)]
    [System.ComponentModel.Description('The type of entry to add.')]
    [ValidateSet('FileHash', 'Sender', 'Url')]
    [System.String] $ListType

    [DscProperty()]
    [System.ComponentModel.Description('Additional information about the object')]
    [System.String] $Notes

    [DscProperty()]
    [System.ComponentModel.Description('Number of days after the entry is first used for it to removed')]
    [System.Nullable[System.UInt32]] $RemoveAfter

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
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

    [EXOTenantAllowBlockListItems] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOTenantAllowBlockListItems]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Tenant Allow/Block List Items with Action {$($this.Action)} and Value {$($this.Value)}"

        try
        {
            if (-not $this.ExportedInstance -or ($this.ExportedInstance.Value -ne $this.Value -or $this.ExportedInstance.ListType -ne $this.ListType))
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'
                $nullResult.ListType = $this.ListType

                $getParams = @{
                    ListType = $this.ListType
                    Entry = $this.Value
                }
                $instance = Get-TenantAllowBlockListItems @getParams -ErrorAction SilentlyContinue
                if ($null -eq $instance)
                {
                    Write-Verbose -Message "No EXO Tenant Allow/Block List Item found for Action {$($this.Action)} and Value {$($this.Value)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "Found an EXO Tenant Allow/Block List Item with Action {$($this.Action)}, Value {$($this.Value)}, and ListType {$($this.ListType)}"

            $results = @{
                Action                = $instance.Action
                Value                 = $instance.Value
                ExpirationDate        = $instance.ExpirationDate
                NoExpiration          = $null -eq $instance.ExpirationDate
                ListSubType           = $instance.ListSubType
                ListType              = $this.ListType
                Notes                 = $instance.Notes
                RemoveAfter           = $instance.RemoveAfter
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }
            return $this.AsResult($results)
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

        Write-Verbose -Message "Setting configuration for Tenant Allow/Block List Items with Action {$($this.Action)} and Value {$($this.Value)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        if ($boundParameters.ContainsKey('NoExpiration') -and -not $this.NoExpiration)
        {
            $boundParameters.Remove('NoExpiration') | Out-Null
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $createParameters = ([Hashtable]$boundParameters).Clone()

            $createParameters.Remove('Value') | Out-Null
            $createParameters.Add('Entries', @($this.Value)) | Out-Null
            if ($this.Action -eq 'Allow')
            {
                $createParameters.Add('Allow', $true) | Out-Null
            }
            elseif ($this.Action -eq 'Block')
            {
                $createParameters.Add('Block', $true) | Out-Null
            }
            $createParameters.Remove('Action') | Out-Null

            Write-Verbose -Message "Creating {$($this.Value)} with Parameters:`r`n$(Convert-M365DscHashtableToString -Hashtable $createParameters)"
            New-TenantAllowBlockListItems @createParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating {$($this.Value)}"

            $updateParameters = ([Hashtable]$boundParameters).Clone()
            $updateParameters.Remove('Value') | Out-Null
            $updateParameters.Add('Entries', @($this.Value)) | Out-Null
            $updateParameters.Remove('Action') | Out-Null

            Set-TenantAllowBlockListItems @updateParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing {$($this.Value)}"
            Remove-TenantAllowBlockListItems -Entries $currentInstance.Value -ListType $currentInstance.ListType
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $listValues = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $ListTypes = ('FileHash', 'Sender', 'Url')

            foreach ($ListType in $ListTypes)
            {
                [array]$listValues = Get-TenantAllowBlockListItems -ListType $ListType -ErrorAction Stop
                foreach ($value in $listValues)
                {
                    $value | Add-Member -MemberType NoteProperty -Name ListType -Value $ListType
                }
            }

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($listValues.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $listValues)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = "[$($config.Action)] [$($config.ListType)] $($config.Value)"
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($listValues.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Action                = $config.Action
                    ListType              = $config.ListType
                    Value                 = $config.Value
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
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
            IncludedProperties = @('Action', 'ListType', 'Value')
        }
    }

    hidden [EXOTenantAllowBlockListItems] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOTenantAllowBlockListItems])
        {
            return $Values
        }

        $result = [EXOTenantAllowBlockListItems]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
