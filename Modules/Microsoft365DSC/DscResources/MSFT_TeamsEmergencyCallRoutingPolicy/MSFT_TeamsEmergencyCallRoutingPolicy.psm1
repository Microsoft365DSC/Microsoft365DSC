using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsEmergencyCallRoutingPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identity of the Teams Emergency Call Routing Policy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Teams Emergency Call Routing Policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Emergency number(s) associated with the policy.')]
    [MSFT_TeamsEmergencyNumber[]] $EmergencyNumbers

    [DscProperty()]
    [System.ComponentModel.Description('Flag to enable Enhanced Emergency Services')]
    [System.Nullable[System.Boolean]] $AllowEnhancedEmergencyServices

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Admin.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
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

    # Export-only. Not part of the resource schema.
    [System.String] $Filter = '*'

    [TeamsEmergencyCallRoutingPolicy] Get()
    {
        ${$Identity} = $null
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsEmergencyCallRoutingPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Teams Emergency Call Routing Policy $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $policy = Get-CsTeamsEmergencyCallRoutingPolicy -Identity $this.Identity `
                    -ErrorAction 'SilentlyContinue'
            }
            else
            {
                $policy = $this.ExportedInstance
            }

            if ($null -eq $policy)
            {
                Write-Verbose -Message "Could not find Teams Emergency Call Routing Policy ${$Identity}"
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found Teams Emergency Call Routing Policy {$($this.Identity)}"
            $results = @{
                Identity                       = $this.Identity
                Description                    = $policy.Description
                AllowEnhancedEmergencyServices = $policy.AllowEnhancedEmergencyServices
                Ensure                         = 'Present'
                Credential                     = $this.Credential
                ApplicationId                  = $this.ApplicationId
                TenantId                       = $this.TenantId
                CertificateThumbprint          = $this.CertificateThumbprint
                CertificatePath                = $this.CertificatePath
                CertificatePassword            = $this.CertificatePassword
                ManagedIdentity                = $this.ManagedIdentity
                AccessTokens                   = $this.AccessTokens
            }

            if ($policy.EmergencyNumbers.Count -gt 0)
            {
                $numbers = @()
                foreach ($number in $policy.EmergencyNumbers)
                {
                    $numbers += @{
                        EmergencyDialString = $number.EmergencyDialString
                        EmergencyDialMask   = $number.EmergencyDialMask
                        OnlinePSTNUsage     = $number.OnlinePSTNUsage
                    }
                }
                $results.Add('EmergencyNumbers', $numbers)
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

        Write-Verbose -Message "Setting Teams Emergency Call Routing Policy {$($this.Identity)}"

        # Check that at least one optional parameter is specified
        $inputValues = @()
        foreach ($item in $this.GetBoundParameters().Keys)
        {
            if (-not [System.String]::IsNullOrEmpty($this.GetBoundParameters().$item) -and $item -ne 'Credential' `
                    -and $item -ne 'Identity' -and $item -ne 'Ensure')
            {
                $inputValues += $item
            }
        }

        if ($inputValues.Count -eq 0)
        {
            throw 'You need to specify at least one optional parameter for the [TeamsEmergencyCallRoutingPolicy] instance {$($this.Identity)}'
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()
        $SetParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.GetBoundParameters().ContainsKey('EmergencyNumbers'))
        {
            $SetParameters.EmergencyNumbers = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $SetParameters.EmergencyNumbers
        }

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a new Teams Emergency Call Routing Policy {$($this.Identity)}"
            $numbers = @()
            if ($null -ne $SetParameters['EmergencyNumbers'])
            {
                foreach ($number in $SetParameters['EmergencyNumbers'])
                {
                    $curNumber = New-CsTeamsEmergencyNumber @number
                    $numbers += $curNumber
                }
                $SetParameters.EmergencyNumbers = $numbers
            }
            New-CsTeamsEmergencyCallRoutingPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating settings for Teams Emergency Call Routing Policy {$($this.Identity)}"
            $numbers = @()
            if ($null -ne $SetParameters['EmergencyNumbers'])
            {
                foreach ($number in $SetParameters['EmergencyNumbers'])
                {
                    $curNumber = New-CsTeamsEmergencyNumber @number
                    $numbers += $curNumber
                }
                $SetParameters.EmergencyNumbers = $numbers
            }
            Set-CsTeamsEmergencyCallRoutingPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing existing Teams Meeting Policy {$($this.Identity)}"
            Remove-CsTeamsEmergencyCallRoutingPolicy -Identity $this.Identity
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

        $ConnectionMode = $this.Connect('MicrosoftTeams')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $i = 1
            [array]$policies = Get-CsTeamsEmergencyCallRoutingPolicy -Filter $this.Filter -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.Identity)" -DeferWrite
                $params = @{
                    Identity              = $policy.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $policy
                $result = $this.GetForExport($params)

                if ($null -ne $result.EmergencyNumbers)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'EmergencyNumbers'
                            CimInstanceName = 'TeamsEmergencyNumber'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $result.EmergencyNumbers `
                        -CIMInstanceName 'TeamsEmergencyNumber' `
                        -ComplexTypeMapping $complexMapping
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $result.EmergencyNumbers = $complexTypeStringResult
                    }
                    else
                    {
                        $result.Remove('EmergencyNumbers') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Result `
                    -Credential $this.Credential `
                    -NoEscape @('EmergencyNumbers')

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

    hidden [TeamsEmergencyCallRoutingPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsEmergencyCallRoutingPolicy])
        {
            return $Values
        }

        $result = [TeamsEmergencyCallRoutingPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_TeamsEmergencyNumber
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Specifies the emergency phone number.')]
    [System.String] $EmergencyDialString

    [DscProperty()]
    [System.ComponentModel.Description('For each Teams emergency number, you can specify zero or more emergency dial masks. A dial mask is a number that you want to translate into the value of the emergency dial number value when it is dialed.')]
    [System.String] $EmergencyDialMask

    [DscProperty()]
    [System.ComponentModel.Description('Specify the online public switched telephone network (PSTN) usage')]
    [System.String] $OnlinePSTNUsage
}
