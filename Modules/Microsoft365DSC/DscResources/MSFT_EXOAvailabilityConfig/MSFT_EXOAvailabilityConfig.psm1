using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOAvailabilityConfig : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The AllowedTenantIds parameter specifies the tenant ID values of Microsoft 365 organization that you want to share free/busy information with (for example, d6b0a40e-029b-43f2-9852-f3724f68ead9). You can specify multiple values separated by commas. A maximum of 25 values are allowed.')]
    [System.String[]] $AllowedTenantIds

    [DscProperty()]
    [System.ComponentModel.Description('Specify the OrgWideAccount for the AvailabilityConfig.')]
    [System.String] $OrgWideAccount

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the AvailabilityConfig should exist or not.')]
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

    [EXOAvailabilityConfig] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOAvailabilityConfig]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Availability Config"

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $availabilityConfig = Get-AvailabilityConfig -ErrorAction Stop
                if ($null -eq $availabilityConfig)
                {
                    Write-Verbose -Message "Availability config does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $availabilityConfig = $this.ExportedInstance
            }

            Write-Verbose -Message "Found Availability Config"

            $orgWideAccountValue = $availabilityConfig.OrgWideAccount
            if ($null -ne $availabilityConfig -and -not [System.String]::IsNullOrEmpty($orgWideAccountValue) -and [System.Guid]::TryParse($orgWideAccountValue, [ref][System.Guid]::Empty))
            {
                $user = Get-User -Identity $orgWideAccountValue -ErrorAction SilentlyContinue
                if ($null -ne $user)
                {
                    $orgWideAccountValue = $user.UserPrincipalName
                }
            }

            $result = @{
                OrgWideAccount        = $orgWideAccountValue
                AllowedTenantIds      = [System.String[]]$availabilityConfig.AllowedTenantIds
                IsSingleInstance      = 'Yes'
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

        Write-Verbose -Message "Setting configuration of Availability Config"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')
        Write-Verbose -Message "Setting configuration of Availability Config"

        $currentAvailabilityConfig = $this.Get().ToHashtable()

        $currentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $currentParameters.Remove('IsSingleInstance') | Out-Null
        if ($currentParameters.OrgWideAccount -eq '' -or $currentParameters.OrgWideAccount -eq 'NotConfigured')
        {
            $currentParameters.OrgWideAccount = $null
        }

        if ($this.Ensure -eq 'Present' -and $currentAvailabilityConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Availability Config does not exist but it should. Create it."
            New-AvailabilityConfig @currentParameters -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentAvailabilityConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Availability Config exists but it shouldn't. Remove it."
            Remove-AvailabilityConfig -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Present' -and $currentAvailabilityConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Availability Config already exists, but needs updating."
            Set-AvailabilityConfig @currentParameters -Confirm:$false
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
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            if ($null -eq (Get-Command Get-AvailabilityConfig -ErrorAction SilentlyContinue))
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiRedX) The specified account doesn't have permissions to access Availibility Config"
                return ''
            }
            $AvailabilityConfig = Get-AvailabilityConfig -ErrorAction Stop

            if ($null -eq $AvailabilityConfig)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                return ''
            }

            $Params = @{
                IsSingleInstance      = 'Yes'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                CertificatePath       = $this.CertificatePath
                AccessTokens          = $this.AccessTokens
            }
            $this.ExportedInstance = $AvailabilityConfig
            $dscContent = [System.Text.StringBuilder]::new()
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
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($DesiredValues.OrgWideAccount -eq 'NotConfigured')
                {
                    Write-Verbose -Message "OrgWideAccount is set to 'NotConfigured' in DesiredValues. Updating it to an empty string for comparison."
                    $DesiredValues.OrgWideAccount = ''
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [EXOAvailabilityConfig] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOAvailabilityConfig])
        {
            return $Values
        }

        $result = [EXOAvailabilityConfig]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
