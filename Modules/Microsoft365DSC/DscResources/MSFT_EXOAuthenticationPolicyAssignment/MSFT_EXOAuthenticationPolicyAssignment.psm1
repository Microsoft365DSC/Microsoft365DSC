using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOAuthenticationPolicyAssignment : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the user assigned to the authentication policy.')]
    [System.String] $UserName

    [DscProperty()]
    [System.ComponentModel.Description('Name of the authentication policy.')]
    [System.String] $AuthenticationPolicyName

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the authentication Policy should exist or not.')]
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

    [EXOAuthenticationPolicyAssignment] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOAuthenticationPolicyAssignment]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Authentication Policy assignment for $($this.UserName)"

        try
        {
            $nullReturn = $this.GetBoundParameters()
            $nullReturn.Ensure = 'Absent'

            if (-not $this.ExportedInstance -or $this.ExportedInstance.UserPrincipalName -ne $this.UserName)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $user = Get-User -Identity $this.UserName -ErrorAction SilentlyContinue
                if ($null -eq $user)
                {
                    Write-Verbose -Message "Could not find user {$($this.UserName)}."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $user = $this.ExportedInstance
            }

            if ([System.String]::IsNullOrEmpty($user.AuthenticationPolicy))
            {
                Write-Verbose -Message "User {$($this.UserName)} has no Authentication Policy assigned."
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found user {$($this.UserName)} with Authentication Policy {$($user.AuthenticationPolicy)}"

            $result = @{
                UserName                 = $this.UserName
                AuthenticationPolicyName = $user.AuthenticationPolicy
                Ensure                   = 'Present'
                Credential               = $this.Credential
                ApplicationId            = $this.ApplicationId
                CertificateThumbprint    = $this.CertificateThumbprint
                CertificatePath          = $this.CertificatePath
                CertificatePassword      = $this.CertificatePassword
                ManagedIdentity          = $this.ManagedIdentity
                TenantId                 = $this.TenantId
                AccessTokens             = $this.AccessTokens
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

        Write-Verbose -Message "Setting Authentication Policy assignment for $($this.UserName)"

        $currentPolicyAssignment = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        # CASE: Authentication Policy doesn't exist but should;
        if ($this.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Assigning authentication policy {$($this.AuthenticationPolicyName)} to {$($this.UserName)}."
            Set-User -Identity $this.UserName -AuthenticationPolicy $this.AuthenticationPolicyName -Confirm:$false | Out-Null
        }
        # CASE: Authentication Policy exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicyAssignment.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing authentication policy assignment {$($this.AuthenticationPolicyName)} for {$($this.UserName)}."
            Set-User -Identity $this.UserName -AuthenticationPolicy $null -Confirm:$false | Out-Null
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
            try
            {
                [array]$AllAuthenticationPolicies = Get-AuthenticationPolicy -ErrorAction SilentlyContinue
            }
            catch
            {
                if ($_.Exception -like "*The operation couldn't be performed because object*")
                {
                    Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered to allow for Authentication Policies"
                    return ''
                }
                throw $_
            }

            $dscContent = [System.Text.StringBuilder]::new()
            if ($AllAuthenticationPolicies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($AuthenticationPolicy in $AllAuthenticationPolicies)
            {
                Write-M365DSCHost -Message "    |---[$i/$($AllAuthenticationPolicies.Count)] $($AuthenticationPolicy.Identity)" -DeferWrite
                $assignedUsers = Get-User -Filter "AuthenticationPolicy -eq '$($AuthenticationPolicy.DistinguishedName)'" -ResultSize unlimited

                foreach ($user in $assignedUsers)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    $Params = @{
                        UserName              = $user.UserPrincipalName
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        CertificatePath       = $this.CertificatePath
                        AccessTokens          = $this.AccessTokens
                    }
                    $this.ExportedInstance = $user
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
                }
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

    hidden [EXOAuthenticationPolicyAssignment] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOAuthenticationPolicyAssignment])
        {
            return $Values
        }

        $result = [EXOAuthenticationPolicyAssignment]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
