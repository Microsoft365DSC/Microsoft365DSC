using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOAvailabilityAddressSpace : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the AvailabilityAddressSpace you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The AccessMethod parameter specifies how the free/busy data is accessed. Valid values are:PerUserFB, OrgWideFB, OrgWideFBToken, OrgWideFBBasic,InternalProxy')]
    [ValidateSet('PerUserFB', 'OrgWideFB', 'OrgWideFBToken', 'OrgWideFBBasic', 'InternalProxy')]
    [System.String] $AccessMethod

    [DscProperty()]
    [System.ComponentModel.Description('The Credentials parameter specifies the username and password that''s used to access the Availability services in the target forest.')]
    [System.Management.Automation.PSCredential] $Credentials

    [DscProperty()]
    [System.ComponentModel.Description('The ForestName parameter specifies the SMTP domain name of the target forest for users whose free/busy data must be retrieved. If your users are distributed among multiple SMTP domains in the target forest, run the Add-AvailabilityAddressSpace command once for each SMTP domain.')]
    [System.String] $ForestName

    [DscProperty()]
    [System.ComponentModel.Description('The TargetAutodiscoverEpr parameter specifies the Autodiscover URL of Exchange Web Services for the external organization. Exchange uses Autodiscover to automatically detect the correct server endpoint for external requests.')]
    [System.String] $TargetAutodiscoverEpr

    [DscProperty()]
    [System.ComponentModel.Description('The TargetServiceEpr parameter specifies the Exchange Online Calendar Service URL of the external Microsoft 365 organization that you''re trying to read free/busy information from.')]
    [System.String] $TargetServiceEpr

    [DscProperty()]
    [System.ComponentModel.Description('The TargetTenantID parameter specifies the tenant ID of the external Microsoft 365 organization that you''re trying to read free/busy information from.')]
    [System.String] $TargetTenantId

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this AvailabilityAddressSpace should exist.')]
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

    [EXOAvailabilityAddressSpace] Get()
    {
        $AvailabilityAddressSpace = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOAvailabilityAddressSpace]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AvailabilityAddressSpace with Identity $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $AvailabilityAddressSpace = Get-AvailabilityAddressSpace -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $AvailabilityAddressSpace -and -not [System.String]::IsNullOrEmpty($this.ForestName))
                {
                    $AvailabilityAddressSpace = Get-AvailabilityAddressSpace -Identity $this.ForestName -ErrorAction SilentlyContinue
                }
                if ($null -eq $AvailabilityAddressSpace)
                {
                    Write-Verbose -Message "AvailabilityAddressSpace $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $AvailabilityAddressSpace = $this.ExportedInstance
            }

            $targetAutodiscoverEprValue = ''
            if ($null -ne $AvailabilityAddressSpace.TargetAutodiscoverEpr -and $AvailabilityAddressSpace.TargetAutodiscoverEpr -ne '')
            {
                $targetAutodiscoverEprValue = $AvailabilityAddressSpace.TargetAutodiscoverEpr.ToString()
            }

            Write-Verbose -Message "Found AvailabilityAddressSpace $($this.Identity)"

            $result = @{
                Identity              = $this.Identity
                AccessMethod          = $AvailabilityAddressSpace.AccessMethod
                TargetServiceEpr      = $AvailabilityAddressSpace.TargetServiceEpr
                TargetTenantId        = $AvailabilityAddressSpace.TargetTenantId
                ForestName            = $AvailabilityAddressSpace.ForestName
                TargetAutodiscoverEpr = $targetAutodiscoverEprValue
                Credential            = $this.Credential
                Ensure                = 'Present'
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

        Write-Verbose -Message "Setting configuration of AvailabilityAddressSpace with Identity $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        Write-Verbose -Message "Setting configuration of AvailabilityAddressSpace for $($this.Identity)"

        $null = $this.Connect('ExchangeOnline')

        $currentInstance = $this.Get().ToHashtable()

        $AvailabilityAddressSpaceParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ('Present' -eq $this.Ensure -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating AvailabilityAddressSpace $($this.Identity)."
            # AvailabilityAddressSpace doe not have a new-AvailabilityAddressSpace cmdlet but instead uses an add-AvailabilityAddressSpace cmdlet
            try
            {
                $AvailabilityAddressSpaceParams.Remove('Identity') | Out-Null
                Add-AvailabilityAddressSpace @AvailabilityAddressSpaceParams -ErrorAction stop
            }
            catch
            {
                $this.LogError($_, "Couldn't add new AvailabilityAddressSpace")

                throw
            }
        }
        elseif ('Present' -eq $this.Ensure -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Setting AvailabilityAddressSpace $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $AvailabilityAddressSpaceParams)"
            # AvailabilityAddressSpace is a special case in that it does not have a "set-AvailabilityAddressSpace" cmdlet. To change values of an existing AvailabilityAddressSpace it must be removed and then added again with add-AvailabilityAddressSpace
            try
            {
                Remove-AvailabilityAddressSpace -Identity $currentInstance.ForestName -Confirm:$false -ErrorAction Stop
            }
            catch
            {
                $this.LogError($_, "Couldn't remove AvailabilityAddressSpace")

                throw
            }

            try
            {
                $AvailabilityAddressSpaceParams.Remove('Identity') | Out-Null
                Add-AvailabilityAddressSpace @AvailabilityAddressSpaceParams -ErrorAction Stop
            }
            catch
            {
                $this.LogError($_, "Couldn't add new AvailabilityAddressSpace")

                throw
            }
        }
        elseif ('Absent' -eq $this.Ensure -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing AvailabilityAddressSpace $($this.Identity)"
            try
            {
                Remove-AvailabilityAddressSpace -Identity $currentInstance.ForestName -Confirm:$false -ErrorAction Stop
            }
            catch
            {
                $this.LogError($_, "Couldn't remove AvailabilityAddressSpace")

                throw
            }
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $AvailabilityAddressSpaces = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            if ($null -eq (Get-Command Get-AvailabilityAddressSpace -ErrorAction SilentlyContinue))
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiRedX) The specified account doesn't have permissions to access Availibility Address Space"
                return ''
            }
            try
            {
                [array]$AvailabilityAddressSpaces = Get-AvailabilityAddressSpace -ErrorAction stop
            }
            catch
            {
                $this.LogError($_, "Couldn't get AvailabilityAddressSpaces")
            }

            $dscContent = [System.Text.StringBuilder]::new()
            if ($AvailabilityAddressSpaces.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($AvailabilityAddressSpace in $AvailabilityAddressSpaces)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AvailabilityAddressSpaces.Length)] $($AvailabilityAddressSpace.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $AvailabilityAddressSpace.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $AvailabilityAddressSpace
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('Credentials')
        }
    }

    hidden [EXOAvailabilityAddressSpace] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOAvailabilityAddressSpace])
        {
            return $Values
        }

        $result = [EXOAvailabilityAddressSpace]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
