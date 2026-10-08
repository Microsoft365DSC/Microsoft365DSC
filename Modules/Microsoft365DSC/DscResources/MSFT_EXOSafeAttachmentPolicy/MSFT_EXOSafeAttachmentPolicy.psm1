using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOSafeAttachmentPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the name of the SafeAttachmentpolicy that you want to modify.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The Action parameter specifies the action for the Safe Attachments policy.')]
    [ValidateSet('Block', 'Replace', 'Allow', 'DynamicDelivery')]
    [System.String] $Action

    [DscProperty()]
    [System.ComponentModel.Description('The AdminDisplayName parameter specifies a description for the policy.')]
    [System.String] $AdminDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this policy should be enabled. Default is $true.')]
    [System.Nullable[System.Boolean]] $Enable

    [DscProperty()]
    [System.ComponentModel.Description('The QuarantineTag specifies the quarantine policy that''s used on messages that are quarantined as malware by Safe Attachments.')]
    [System.String] $QuarantineTag

    [DscProperty()]
    [System.ComponentModel.Description('The Redirect parameter specifies whether to send detected malware attachments to another email address. Valid values are: $true: Malware attachments are sent to the email address specified by the RedirectAddress parameter. $false: Malware attachments aren''t sent to another email address. This is the default value.')]
    [System.Nullable[System.Boolean]] $Redirect

    [DscProperty()]
    [System.ComponentModel.Description('The RedirectAddress parameter specifies the email address where detected malware attachments are sent when the Redirect parameter is set to the value $true.')]
    [System.String] $RedirectAddress

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this policy should exist or not.')]
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

    [EXOSafeAttachmentPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOSafeAttachmentPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SafeAttachmentPolicy for $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $SafeAttachmentPolicy = Get-SafeAttachmentPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $SafeAttachmentPolicy)
                {
                    Write-Verbose -Message "SafeAttachmentPolicy $($this.Identity) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $SafeAttachmentPolicy = $this.ExportedInstance
            }

            Write-Verbose -Message "Found existing instance of SafeAttachmentPolicy $($this.Identity)"

            $result = @{
                Ensure                = 'Present'
                Identity              = $this.Identity
                Action                = $SafeAttachmentPolicy.Action
                AdminDisplayName      = $SafeAttachmentPolicy.AdminDisplayName
                Enable                = $SafeAttachmentPolicy.Enable
                QuarantineTag         = $SafeAttachmentPolicy.QuarantineTag
                Redirect              = $SafeAttachmentPolicy.Redirect
                RedirectAddress       = $SafeAttachmentPolicy.RedirectAddress
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

        Write-Verbose -Message "Setting configuration of SafeAttachmentPolicy for $($this.Identity)"
        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $SafeAttachmentPolicyParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $SafeAttachmentPolicyParams.Remove('TenantId') | Out-Null

        $SafeAttachmentPolicy = Get-SafeAttachmentPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
        if ($this.Ensure -eq 'Present')
        {
            $StopProcessingPolicy = $false
            if ($this.Redirect -eq $true)
            {
                $Message = 'Cannot proceed with processing of SafeAttachmentPolicy because Redirect is set to true '
                if ([String]::IsNullOrEmpty($this.RedirectAddress))
                {
                    $Message += 'and RedirectAddress is null'
                    $StopProcessingPolicy = $true
                }
                if ($StopProcessingPolicy -eq $true)
                {
                    Write-Verbose -Message $Message
                    try
                    {
                        $Message = 'Please ensure that if Redirect is set to true ' + `
                            'and RedirectAddress is not null'
                        $this.LogError($_, $Message)
                    }
                    catch
                    {
                        Write-Verbose -Message $_
                    }
                    break
                }
            }
            else
            {
                $SafeAttachmentPolicyParams.Remove('RedirectAddress') | Out-Null
            }

            if (-not $SafeAttachmentPolicy)
            {
                Write-Verbose -Message "Creating SafeAttachmentPolicy $($this.Identity)."
                $SafeAttachmentPolicyParams += @{
                    Name = $SafeAttachmentPolicyParams.Identity
                }

                $SafeAttachmentPolicyParams.Remove('Identity') | Out-Null
                try
                {
                    New-SafeAttachmentPolicy @SafeAttachmentPolicyParams
                }
                catch
                {
                    try
                    {
                        $this.LogError($_, 'Error updating data:')
                    }
                    catch
                    {
                        Write-Verbose -Message $_
                    }

                    throw
                }
            }
            else
            {
                Write-Verbose -Message "Setting SafeAttachmentPolicy $($this.Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $SafeAttachmentPolicyParams)"
                try
                {
                    Set-SafeAttachmentPolicy @SafeAttachmentPolicyParams
                }
                catch
                {
                    try
                    {
                        $this.LogError($_, 'Error updating data:')
                    }
                    catch
                    {
                        Write-Verbose -Message $_
                    }

                    throw
                }
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $null -ne $SafeAttachmentPolicy)
        {
            Write-Verbose -Message "Removing SafeAttachmentPolicy $($this.Identity) "
            Remove-SafeAttachmentPolicy -Identity $this.Identity -Confirm:$false -Force
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

        $dscContent = [System.Text.StringBuilder]::new()
        try
        {
            if (Confirm-ImportedCmdletIsAvailable -CmdletName 'Get-SafeAttachmentPolicy')
            {
                [array]$SafeAttachmentPolicies = Get-SafeAttachmentPolicy -ErrorAction Stop
                if ($SafeAttachmentPolicies.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }
                $i = 1
                foreach ($SafeAttachmentPolicy in $SafeAttachmentPolicies)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "    |---[$i/$($SafeAttachmentPolicies.Length)] $($SafeAttachmentPolicy.Identity)" -DeferWrite
                    $Params = @{
                        Credential            = $this.Credential
                        Identity              = $SafeAttachmentPolicy.Identity
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        CertificatePath       = $this.CertificatePath
                        AccessTokens          = $this.AccessTokens
                    }
                    $this.ExportedInstance = $SafeAttachmentPolicy
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
            }
            else
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant doesn't have access to Safe Attachment Policy APIs."
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOSafeAttachmentPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOSafeAttachmentPolicy])
        {
            return $Values
        }

        $result = [EXOSafeAttachmentPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
