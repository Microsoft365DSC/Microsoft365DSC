using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOAtpPolicyForO365 : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the resource is a single instance, the value must be ''Yes''')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The AllowSafeDocsOpen parameter specifies whether users can click through and bypass the Protected View container even when Safe Documents identifies a file as malicious.')]
    [System.Nullable[System.Boolean]] $AllowSafeDocsOpen

    [DscProperty()]
    [System.ComponentModel.Description('The EnableATPForSPOTeamsODB parameter specifies whether ATP is enabled for SharePoint Online, OneDrive for Business and Microsoft Teams. Default is $false.')]
    [System.Nullable[System.Boolean]] $EnableATPForSPOTeamsODB

    [DscProperty()]
    [System.ComponentModel.Description('The EnableSafeDocs parameter specifies whether to enable the Safe Documents feature in the organization. Default is $false.')]
    [System.Nullable[System.Boolean]] $EnableSafeDocs

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

    [EXOAtpPolicyForO365] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOAtpPolicyForO365]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of the EXO AtpPolicyForO365'

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = @{
                    IsSingleInstance = 'Yes'
                }

                $AtpPolicyForO365 = Get-AtpPolicyForO365 -Identity 'Default' -ErrorAction SilentlyContinue
                if (-not $AtpPolicyForO365)
                {
                    Write-Verbose -Message 'AtpPolicyForO365 Default does not exist.'
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $AtpPolicyForO365 = $this.ExportedInstance
            }

            Write-Verbose -Message 'Found the EXO AtpPolicyForO365 Default'

            $result = @{
                IsSingleInstance        = 'Yes'
                AllowSafeDocsOpen       = $AtpPolicyForO365.AllowSafeDocsOpen
                EnableATPForSPOTeamsODB = $AtpPolicyForO365.EnableATPForSPOTeamsODB
                EnableSafeDocs          = $AtpPolicyForO365.EnableSafeDocs
                ApplicationId           = $this.ApplicationId
                CertificateThumbprint   = $this.CertificateThumbprint
                CertificatePath         = $this.CertificatePath
                CertificatePassword     = $this.CertificatePassword
                ManagedIdentity         = $this.ManagedIdentity
                TenantId                = $this.TenantId
                AccessTokens            = $this.AccessTokens
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

        Write-Verbose -Message 'Setting configuration of the EXO AtpPolicyForO365'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $AtpPolicyParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $AtpPolicyParams.Remove('IsSingleInstance') | Out-Null
        $AtpPolicyParams.Add('Identity', 'Default')
        Write-Verbose -Message "Setting configuration of the EXO AtpPolicyForO365 Default"

        Set-AtpPolicyForO365 @AtpPolicyParams
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $dscContent = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            if (Confirm-ImportedCmdletIsAvailable -CmdletName Get-AtpPolicyForO365)
            {
                [array]$ATPPolicies = Get-AtpPolicyForO365 -ErrorAction Stop
                $dscContent = [System.Text.StringBuilder]::new()

                if ($ATPPolicies.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }
                $i = 1
                foreach ($atpPolicy in $ATPPolicies)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "    |---[$i/$($ATPPolicies.Length)] $($atpPolicy.Identity)" -DeferWrite

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
                    $this.ExportedInstance = $atpPolicy
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
            }
            else
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered to allow for ATP Policies"
            }

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOAtpPolicyForO365] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOAtpPolicyForO365])
        {
            return $Values
        }

        $result = [EXOAtpPolicyForO365]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
