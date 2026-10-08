using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOManagementScope : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the name of the management scope to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The Name parameter specifies the name of the management scope.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientRestrictionFilter parameter uses OPATH filter syntax to specify the recipients that are included in the scope.')]
    [System.String] $RecipientRestrictionFilter

    [DscProperty()]
    [System.ComponentModel.Description('The RecipientRoot parameter specifies the organizational unit (OU) under which the filter specified with the RecipientRestrictionFilter parameter should be applied.')]
    [System.String] $RecipientRoot

    [DscProperty()]
    [System.ComponentModel.Description('The Exclusive switch specifies that the role should be an exclusive scope.')]
    [System.Nullable[System.Boolean]] $Exclusive

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this Outbound connector should exist.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the workload''s Admin')]
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

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [EXOManagementScope] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOManagementScope]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Management Scope configuration for {$($this.Identity)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $ManagementScope = Get-ManagementScope -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $ManagementScope)
                {
                    Write-Verbose -Message "Management Scope with Identity $($this.Identity) not found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $ManagementScope = $this.ExportedInstance
            }

            Write-Verbose -Message "Management Scope with Identity $($this.Identity) found"

            $results = @{
                Identity                   = $this.Identity
                Name                       = $ManagementScope.Name
                RecipientRestrictionFilter = $ManagementScope.RecipientFilter
                RecipientRoot              = $ManagementScope.RecipientRoot
                Exclusive                  = $ManagementScope.Exclusive
                Ensure                     = 'Present'
                Credential                 = $this.Credential
                ApplicationId              = $this.ApplicationId
                TenantId                   = $this.TenantId
                CertificateThumbprint      = $this.CertificateThumbprint
                CertificatePath            = $this.CertificatePath
                CertificatePassword        = $this.CertificatePassword
                ManagedIdentity            = $this.ManagedIdentity
                AccessTokens               = $this.AccessTokens
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

        Write-Verbose -Message "Setting Management Scope configuration for {$($this.Identity)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            if ($setParameters.ContainsKey('Identity'))
            {
                $setParameters.Remove('Identity') | Out-Null
            }
            if ([System.String]::IsNullOrEmpty($setParameters.Name))
            {
                $setParameters.Name = $this.Identity
            }
            New-ManagementScope @SetParameters
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            if ($setParameters.ContainsKey('Exclusive'))
            {
                $setParameters.Remove('Exclusive') | Out-Null
            }
            Set-ManagementScope @SetParameters
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Remove-ManagementScope -Identity $this.Identity
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
            [array]$managementScopes = Get-ManagementScope -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($managementScopes.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $managementScopes)
            {
                $displayedKey = $config.Identity
                Write-M365DSCHost -Message "    |---[$i/$($managementScopes.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Identity              = $config.Identity
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

    hidden [EXOManagementScope] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOManagementScope])
        {
            return $Values
        }

        $result = [EXOManagementScope]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
