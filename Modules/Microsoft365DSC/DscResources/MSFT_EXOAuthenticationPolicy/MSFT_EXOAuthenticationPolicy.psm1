using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOAuthenticationPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the authentication policy you want to view or modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The AllowBasicAuthActiveSync switch specifies whether to allow Basic authentication with Exchange Active Sync.')]
    [System.Nullable[System.Boolean]] $AllowBasicAuthActiveSync

    [DscProperty()]
    [System.ComponentModel.Description('The AllowBasicAuthAutodiscover switch specifies whether to allow Basic authentication with Autodiscover.')]
    [System.Nullable[System.Boolean]] $AllowBasicAuthAutodiscover

    [DscProperty()]
    [System.ComponentModel.Description('The AllowBasicAuthImap switch specifies whether to allow Basic authentication with IMAP.')]
    [System.Nullable[System.Boolean]] $AllowBasicAuthImap

    [DscProperty()]
    [System.ComponentModel.Description('The AllowBasicAuthMapi switch specifies whether to allow Basic authentication with MAPI.')]
    [System.Nullable[System.Boolean]] $AllowBasicAuthMapi

    [DscProperty()]
    [System.ComponentModel.Description('The AllowBasicAuthOfflineAddressBook switch specifies whether to allow Basic authentication with Offline Address Books.')]
    [System.Nullable[System.Boolean]] $AllowBasicAuthOfflineAddressBook

    [DscProperty()]
    [System.ComponentModel.Description('The AllowBasicAuthOutlookService switch specifies whether to allow Basic authentication with the Outlook service.')]
    [System.Nullable[System.Boolean]] $AllowBasicAuthOutlookService

    [DscProperty()]
    [System.ComponentModel.Description('The AllowBasicAuthPop switch specifies whether to allow Basic authentication with POP.')]
    [System.Nullable[System.Boolean]] $AllowBasicAuthPop

    [DscProperty()]
    [System.ComponentModel.Description('The AllowBasicAuthPowerShell switch specifies whether to allow Basic authentication with PowerShell.')]
    [System.Nullable[System.Boolean]] $AllowBasicAuthPowershell

    [DscProperty()]
    [System.ComponentModel.Description('The AllowBasicAuthReporting Web Services switch specifies whether to allow Basic authentication with reporting web services.')]
    [System.Nullable[System.Boolean]] $AllowBasicAuthReportingWebServices

    [DscProperty()]
    [System.ComponentModel.Description('The AllowBasicAuthRpc switch specifies whether to allow Basic authentication with RPC.')]
    [System.Nullable[System.Boolean]] $AllowBasicAuthRpc

    [DscProperty()]
    [System.ComponentModel.Description('The AllowBasicAuthSmtp switch specifies whether to allow Basic authentication with SMTP.')]
    [System.Nullable[System.Boolean]] $AllowBasicAuthSmtp

    [DscProperty()]
    [System.ComponentModel.Description('The AllowBasicAuthWebServices switch specifies whether to allow Basic authentication with Exchange Web Services (EWS).')]
    [System.Nullable[System.Boolean]] $AllowBasicAuthWebServices

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

    [EXOAuthenticationPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOAuthenticationPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Authentication Policy configuration for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $AuthenticationPolicy = Get-AuthenticationPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $AuthenticationPolicy)
                {
                    Write-Verbose -Message "Authentication Policy $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $AuthenticationPolicy = $this.ExportedInstance
            }

            $result = @{
                Identity                           = $AuthenticationPolicy.Identity
                AllowBasicAuthActiveSync           = $AuthenticationPolicy.AllowBasicAuthActiveSync
                AllowBasicAuthAutodiscover         = $AuthenticationPolicy.AllowBasicAuthAutodiscover
                AllowBasicAuthImap                 = $AuthenticationPolicy.AllowBasicAuthImap
                AllowBasicAuthMapi                 = $AuthenticationPolicy.AllowBasicAuthMapi
                AllowBasicAuthOfflineAddressBook   = $AuthenticationPolicy.AllowBasicAuthOfflineAddressBook
                AllowBasicAuthOutlookService       = $AuthenticationPolicy.AllowBasicAuthOutlookService
                AllowBasicAuthPop                  = $AuthenticationPolicy.AllowBasicAuthPop
                AllowBasicAuthPowerShell           = $AuthenticationPolicy.AllowBasicAuthPowerShell
                AllowBasicAuthReportingWebServices = $AuthenticationPolicy.AllowBasicAuthReportingWebServices
                AllowBasicAuthRpc                  = $AuthenticationPolicy.AllowBasicAuthRpc
                AllowBasicAuthSmtp                 = $AuthenticationPolicy.AllowBasicAuthSmtp
                AllowBasicAuthWebServices          = $AuthenticationPolicy.AllowBasicAuthWebServices
                Ensure                             = 'Present'
                Credential                         = $this.Credential
                ApplicationId                      = $this.ApplicationId
                CertificateThumbprint              = $this.CertificateThumbprint
                CertificatePath                    = $this.CertificatePath
                CertificatePassword                = $this.CertificatePassword
                ManagedIdentity                    = $this.ManagedIdentity
                TenantId                           = $this.TenantId
                AccessTokens                       = $this.AccessTokens
            }

            Write-Verbose -Message "Found Authentication Policy $($this.Identity)"
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

        Write-Verbose -Message "Setting Authentication Policy configuration for $($this.Identity)"

        $currentAuthenticationPolicyConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $NewAuthenticationPolicyParams = @{
            AllowBasicAuthActiveSync           = $this.AllowBasicAuthActiveSync
            AllowBasicAuthAutodiscover         = $this.AllowBasicAuthAutodiscover
            AllowBasicAuthImap                 = $this.AllowBasicAuthImap
            AllowBasicAuthMapi                 = $this.AllowBasicAuthMapi
            AllowBasicAuthOfflineAddressBook   = $this.AllowBasicAuthOfflineAddressBook
            AllowBasicAuthOutlookService       = $this.AllowBasicAuthOutlookService
            AllowBasicAuthPop                  = $this.AllowBasicAuthPop
            AllowBasicAuthPowerShell           = $this.AllowBasicAuthPowerShell
            AllowBasicAuthReportingWebServices = $this.AllowBasicAuthReportingWebServices
            AllowBasicAuthRpc                  = $this.AllowBasicAuthRpc
            AllowBasicAuthSmtp                 = $this.AllowBasicAuthSmtp
            AllowBasicAuthWebServices          = $this.AllowBasicAuthWebServices
        }

        # CASE: Authentication Policy doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentAuthenticationPolicyConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Authentication Policy '$($this.Identity)' does not exist but it should. Create and configure it."
            New-AuthenticationPolicy -Name $this.Identity @NewAuthenticationPolicyParams | Out-Null
        }
        # CASE: Authentication Policy exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentAuthenticationPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Authentication Policy '$($this.Identity)' exists but it shouldn't. Remove it."
            Remove-AuthenticationPolicy -Identity $this.Identity -Confirm:$false
        }
        # CASE: Authentication Policy exists and it should, but has different values than the desired one
        # Policy cannot be changed so it must be deleted and re-created again
        elseif ($this.Ensure -eq 'Present' -and $currentAuthenticationPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Authentication Policy '$($this.Identity)' exists. Updating settings."
            Remove-AuthenticationPolicy -Identity $this.Identity -Confirm:$false
            New-AuthenticationPolicy -Name $this.Identity @NewAuthenticationPolicyParams | Out-Null
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
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllAuthenticationPolicies.Count)] $($AuthenticationPolicy.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $AuthenticationPolicy.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $AuthenticationPolicy
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

    hidden [EXOAuthenticationPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOAuthenticationPolicy])
        {
            return $Values
        }

        $result = [EXOAuthenticationPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
