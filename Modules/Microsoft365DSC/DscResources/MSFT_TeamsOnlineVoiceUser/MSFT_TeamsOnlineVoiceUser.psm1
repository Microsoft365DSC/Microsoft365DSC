using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsOnlineVoiceUser : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the identity of the target user.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the unique identifier of the emergency location to assign to the user. Location identities can be discovered by using the Get-CsOnlineLisLocation cmdlet.')]
    [System.String] $LocationID

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the telephone number to be assigned to the user. The value must be in E.164 format: +14255043920. Setting the value to $Null clears the user''s telephone number.')]
    [System.String] $TelephoneNumber

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the online voice user exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Global Admin.')]
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
    [System.String] $Filter

    [TeamsOnlineVoiceUser] Get()
    {
        ${$Identity} = $null
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsOnlineVoiceUser]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Teams Online Voice User $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.UserPrincipalName -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $instance = Get-CsOnlineUser -Identity $this.Identity `
                    -ErrorAction 'SilentlyContinue'
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                Write-Verbose -Message "Could not find Teams Online Voice User ${$Identity}"
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found Teams Online Voicemail Policy {$($this.Identity)}"
            $telephoneNumberValue = $instance.LineUri

            if (-not [System.String]::IsNullOrEmpty($telephoneNumberValue))
            {
                $telephoneNumberValue = $telephoneNumberValue.Replace('tel:+', '')
            }

            $numberAssignment = Get-CsPhoneNumberAssignment -AssignedPstnTargetId $this.Identity
            $locationValue = $null
            if ($null -ne $numberAssignment)
            {
                $locationValue = $numberAssignment.LocationId
            }

            return $this.AsResult(@{
                Identity              = $this.Identity
                LocationID            = $locationValue
                TelephoneNumber       = $telephoneNumberValue
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            })
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

        Write-Verbose -Message "Setting Teams Online Voice User {$($this.Identity)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('MicrosoftTeams')

        if ($this.Ensure -eq 'Present')
        {
            if ([System.String]::IsNullOrEmpty($this.TelephoneNumber))
            {
                throw "A TelephoneNumber is required to assign a phone number to the Teams Online Voice User {$($this.Identity)}."
            }

            $acquiredNumber = Get-CsPhoneNumberAssignment -TelephoneNumber $this.TelephoneNumber -ErrorAction Stop
            if ($null -eq $acquiredNumber)
            {
                throw "The telephone number {$($this.TelephoneNumber)} to assign to the Teams Online Voice User {$($this.Identity)} does not exist in the tenant."
            }

            Set-CsPhoneNumberAssignment -Identity $this.Identity `
                -TelephoneNumber $this.TelephoneNumber `
                -NumberType $acquiredNumber.NumberType `
                -LocationId $this.LocationID | Out-Null
        }
        else
        {
            Remove-CsPhoneNumberAssignment -Identity $this.Identity -RemoveAll | Out-Null
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

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $i = 1
            $baseFilter = "(FeatureTypes -contains 'PhoneSystem') -and (AccountEnabled -eq '$True')"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($baseFilter) -and ($($this.Filter))"
            }
            [array]$users = Get-CsOnlineUser -Filter $mergedFilter `
                -AccountType User `
                -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($user in $users)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($users.Count)] $($user.UserPrincipalName)" -DeferWrite
                $params = @{
                    Identity              = $user.UserPrincipalName
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $user
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

    hidden [TeamsOnlineVoiceUser] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsOnlineVoiceUser])
        {
            return $Values
        }

        $result = [TeamsOnlineVoiceUser]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
