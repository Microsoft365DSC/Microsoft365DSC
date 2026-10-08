using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXORecipientPermission : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The mailbox the permission should be given on.')]
    [System.String] $Identity

    [DscProperty(Key)]
    [System.ComponentModel.Description('The account to give the permission to.')]
    [System.String] $Trustee

    [DscProperty()]
    [System.ComponentModel.Description('The access rights granted to the account. Only ''SendAs'' is supported.')]
    [System.String[]] $AccessRights

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the group exists, absent ensures it is removed')]
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

    [EXORecipientPermission] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXORecipientPermission]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Office 365 Recipient permission $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                Write-Verbose -Message "Retrieving Recipient Permissions by Identity {$($this.Identity)}, Trustee {$($this.Trustee)} and AccessRights {$($this.AccessRights)}"
                $recipientPermission = Get-RecipientPermission -Identity $this.Identity -Trustee $this.Trustee -AccessRights $this.AccessRights -ErrorAction SilentlyContinue

                if ($null -eq $recipientPermission)
                {
                    Write-Verbose -Message "The specified Recipient Permission doesn't exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $recipientPermission = $this.ExportedInstance
            }

            Write-Verbose -Message "Found Recipient Permission for Identity {$($this.Identity)}, Trustee {$($this.Trustee)} and AccessRights {$($this.AccessRights)}"

            [Array]$trusteeValues = $recipientPermission.Trustee

            $result = @{
                Identity              = $this.Identity
                Trustee               = $trusteeValues[0]
                AccessRights          = $recipientPermission.AccessRights
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
        $Name = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting Mail Contact configuration for $Name"

        $currentState = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $parameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $parameters.AccessRights = $this.AccessRights #Parameters with default values are not part PSBoundParameters

        # Receipient Permission doesn't exist but it should
        if ($this.Ensure -eq 'Present' -and $currentState.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "The Recipient Permission for '$($this.Trustee)' with Access Rights '$($this.AccessRights -join ', ')' on mailbox '$($this.Identity)' does not exist but it should. Adding it."
            Add-RecipientPermission @parameters -Confirm:$false
        }
        # Receipient Permission exists but shouldn't
        elseif ($this.Ensure -eq 'Absent' -and $currentState.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Recipient Permission for '$($this.Trustee)' with Access Rights '$($currentState.AccessRights -join ', ')' on mailbox '$($this.Identity)' exists but shouldn't. Removing it."
            $parameters.AccessRights = $currentState.AccessRights
            Remove-RecipientPermission @parameters -Confirm:$false
        }
        elseif ($this.Ensure -eq 'Present' -and $currentState.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Recipient Permission for '$($this.Trustee)' with Access Rights '$($this.AccessRights -join ', ')' on mailbox '$($this.Identity)' exists."
            Remove-RecipientPermission @parameters -Confirm:$false
            Add-RecipientPermission @parameters -Confirm:$false
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
            [array]$recipientPermissions = Get-RecipientPermission -ResultSize Unlimited

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($recipientPermissions.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            if ($null -eq $this.ResourceCache['UsersCache'])
            {
                $this.ResourceCache['UsersCache'] = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new()
                [array]$exoUsers = Get-M365DSCExportCachedCollection -Collection 'exoUsers'
                foreach ($exoUser in $exoUsers)
                {
                    $this.ResourceCache['UsersCache'][$exoUser.Identity] = @{
                        Identity          = $exoUser.Identity
                        UserPrincipalName = $exoUser.UserPrincipalName
                    }
                }
            }
            foreach ($recipientPermission in $recipientPermissions)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $IdentityValue = $recipientPermission.Identity
                if ([System.Guid]::TryParse($IdentityValue, [ref][System.Guid]::Empty))
                {
                    $IdentityValue = $this.ResourceCache['UsersCache'][$IdentityValue].UserPrincipalName
                }
                Write-M365DSCHost -Message "    |---[$i/$($recipientPermissions.Length)] $($IdentityValue)" -DeferWrite

                $params = @{
                    Identity              = $IdentityValue
                    Trustee               = $recipientPermission.Trustee
                    AccessRights          = $recipientPermission.AccessRights
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $recipientPermission
                $Results = $this.GetForExport($Params)
                if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
                {
                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    [void]$dscContent.Append($currentDSCBlock)

                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName

                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
                }

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

    hidden [EXORecipientPermission] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXORecipientPermission])
        {
            return $Values
        }

        $result = [EXORecipientPermission]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
