using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCAutoSensitivityLabelPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name for the sensitivity label. The maximum length is 64 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this label policy should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The ApplySensitivityLabel parameter specifies the label to use for the auto label policy.')]
    [System.String] $ApplySensitivityLabel

    [DscProperty()]
    [System.ComponentModel.Description('The ExchangeSender parameter specifies which senders to include in the policy.')]
    [System.String[]] $ExchangeSender

    [DscProperty()]
    [System.ComponentModel.Description('The ExchangeSenderException parameter specifies which senders to exclude in the policy.')]
    [System.String[]] $ExchangeSenderException

    [DscProperty()]
    [System.ComponentModel.Description('The ExchangeSenderMemberOf parameter specifies the distribution groups, mail-enabled security groups, or dynamic distribution groups to include in the auto-labeling policy.')]
    [System.String[]] $ExchangeSenderMemberOf

    [DscProperty()]
    [System.ComponentModel.Description('he ExchangeSenderMemberOf parameter specifies the distribution groups, mail-enabled security groups, or dynamic distribution groups to exclude from the auto-labeling policy.')]
    [System.String[]] $ExchangeSenderMemberOfException

    [DscProperty()]
    [System.ComponentModel.Description('The ExchangeSender parameter specifies which senders to include in the policy.')]
    [System.String[]] $ExchangeLocation

    [DscProperty()]
    [System.ComponentModel.Description('This AddExchangeLocation parameter specifies new Exchange locations to be added to the policy without affecting the existing ones.')]
    [System.String[]] $AddExchangeLocation

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveExchangeLocation parameter removes locations on Exchange from the policy.')]
    [System.String[]] $RemoveExchangeLocation

    [DscProperty()]
    [System.ComponentModel.Description('The Mode parameter specifies the action and notification level of the auto-labeling policy.')]
    [ValidateSet('Enable', 'Disable', 'TestWithNotifications', 'TestWithoutNotifications')]
    [System.String] $Mode

    [DscProperty()]
    [System.ComponentModel.Description('The OneDriveLocation parameter specifies the OneDrive for Business sites to include. You identify the site by its URL value, or you can use the value.')]
    [System.String[]] $OneDriveLocation

    [DscProperty()]
    [System.ComponentModel.Description('The AddOneDriveLocation parameter specifies the OneDrive for Business sites to add to the list of included sites when you aren''t using the value All for the OneDriveLocation parameter.')]
    [System.String[]] $AddOneDriveLocation

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveOneDriveLocation parameter specifies the OneDrive for Business sites to remove from the list of included sites when you aren''t using the value All for the OneDriveLocation parameter.')]
    [System.String[]] $RemoveOneDriveLocation

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the OneDrive for Business sites to exclude when you use the value All for the OneDriveLocation parameter.')]
    [System.String[]] $AddOneDriveLocationException

    [DscProperty()]
    [System.ComponentModel.Description('This RemoveOneDriveLocationException parameter specifies the OneDrive for Business sites to remove from the list of excluded sites when you use the value All for the OneDriveLocation parameter.')]
    [System.String[]] $RemoveOneDriveLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The AddOneDriveLocationException parameter specifies the OneDrive for Business sites to add to the list of excluded sites when you use the value All for the OneDriveLocation parameter.')]
    [System.String[]] $OneDriveLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The Priority parameter specifies the priority of the policy. The highest priority policy will take action over lower priority policies if two policies are applicable for a file.')]
    [System.Nullable[System.UInt32]] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('The SharePointLocation parameter specifies the SharePoint Online sites to include. You identify the site by its URL value, or you can use the value All to include all sites.')]
    [System.String[]] $SharePointLocation

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the SharePoint Online sites to exclude when you use the value All for the SharePointLocation parameter.')]
    [System.String[]] $SharePointLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The AddSharePointLocation parameter specifies the SharePoint Online sites to add to the list of included sites when you aren''t using the value All for the SharePointLocation parameter.')]
    [System.String[]] $AddSharePointLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveSharePointLocationException parameter specifies the SharePoint Online sites to remove from the list of excluded sites when you use the value All for the SharePointLocation parameter.')]
    [System.String[]] $RemoveSharePointLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The AddSharePointLocation parameter specifies the SharePoint Online sites to add to the list of included sites when you aren''t using the value All for the SharePointLocation parameter.')]
    [System.String[]] $AddSharePointLocation

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveSharePointLocation parameter specifies the SharePoint Online sites to remove from the list of included sites when you aren''t using the value All for the SharePointLocation parameter.')]
    [System.String[]] $RemoveSharePointLocation

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

    [SCAutoSensitivityLabelPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCAutoSensitivityLabelPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Auto sensitivity Label Policy for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                $this.AddTelemetry('Get')

                $nullReturn = @{
                    Ensure = 'Absent'
                    Name   = $this.Name
                }

                # There is a bug with the Get-AutoSensitivityLabelPolicy where if you get by Identity, the priority is an invalid number.
                # Threfore we get it by name.
                $policy = Invoke-M365DSCCommand -ScriptBlock { Get-AutoSensitivityLabelPolicy -ErrorAction Stop | Where-Object { $_.Name -eq $this.Name } } -SuppressNotFoundError

                if ($null -eq $policy -or $policy.Mode -eq 'PendingDeletion')
                {
                    Write-Verbose -Message "Auto Sensitivity label policy $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $policy = $this.ExportedInstance
            }

            Write-Verbose "Found existing Auto Sensitivity label policy $($this.Name)"
            $result = @{
                Name                              = $policy.Name
                Comment                           = $policy.Comment
                ApplySensitivityLabel             = $policy.ApplySensitivityLabel
                Credential                        = $this.Credential
                Ensure                            = 'Present'
                ExchangeSender                    = [SCAutoSensitivityLabelPolicy]::GetRecipientAddresses($policy.ExchangeSender)
                ExchangeSenderException           = [SCAutoSensitivityLabelPolicy]::GetRecipientAddresses($policy.ExchangeSenderException)
                ExchangeSenderMemberOf            = [SCAutoSensitivityLabelPolicy]::GetRecipientAddresses($policy.ExchangeSenderMemberOf)
                ExchangeSenderMemberOfException   = [SCAutoSensitivityLabelPolicy]::GetRecipientAddresses($policy.ExchangeSenderMemberOfException)
                ExchangeLocation                  = $policy.ExchangeLocation.Name
                AddExchangeLocation               = $policy.AddExchangeLocation
                RemoveExchangeLocation            = $policy.RemoveExchangeLocation
                Mode                              = $policy.Mode
                OneDriveLocation                  = $policy.OneDriveLocation.Name
                AddOneDriveLocation               = $policy.AddOneDriveLocation
                RemoveOneDriveLocation            = $policy.RemoveOneDriveLocation
                OneDriveLocationException         = $policy.OneDriveLocationException.Name
                AddOneDriveLocationException      = $policy.AddOneDriveLocationException.Name
                RemoveOneDriveLocationException   = $policy.RemoveOneDriveLocationException.Name
                Priority                          = $policy.Priority
                SharePointLocation                = $policy.SharePointLocation.Name
                SharePointLocationException       = $policy.SharePointLocationException.Name
                AddSharePointLocationException    = $policy.AddSharePointLocationException.Name
                RemoveSharePointLocationException = $policy.RemoveSharePointLocationException.Name
                AddSharePointLocation             = $policy.AddSharePointLocation
                RemoveSharePointLocation          = $policy.RemoveSharePointLocation
                ApplicationId                     = $this.ApplicationId
                TenantId                          = $this.TenantId
                CertificateThumbprint             = $this.CertificateThumbprint
                CertificatePath                   = $this.CertificatePath
                CertificatePassword               = $this.CertificatePassword
                ManagedIdentity                   = $this.ManagedIdentity
                AccessTokens                      = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of Sensitivity label policy for $($this.Name)"

        #region Telemetry
        $this.AddTelemetry('Set')
        #endregion

        $CurrentPolicy = $this.Get().ToHashtable()
        $boundParameters = $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('SharePointLocation') -or $boundParameters.ContainsKey('OneDriveLocation'))
        {
            if ($boundParameters.ContainsKey('Mode') -eq $false)
            {
                Write-Verbose 'SharePoint or OneDrive location has been specified. Setting Mode to TestWithoutNotifications.'
                $boundParameters.Add('Mode', 'TestWithoutNotifications')
            }
            elseif ($boundParameters.Mode -eq 'Enable')
            {
                Write-Verbose 'SharePoint or OneDrive location has been specified. Changing Mode to TestWithoutNotifications.'
                $boundParameters.Mode = 'TestWithoutNotifications'
            }
        }

        if ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose "Creating new Auto Sensitivity label policy $($this.Name)."

            $createParameters = $boundParameters
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $createParameters

            # Remove parameters not used in New-LabelPolicy
            $CreationParams.Remove('AddExchangeLocation') | Out-Null
            $CreationParams.Remove('AddOneDriveLocation') | Out-Null
            $CreationParams.Remove('AddOneDriveLocationException') | Out-Null
            $CreationParams.Remove('AddSharePointLocation') | Out-Null
            $CreationParams.Remove('AddSharePointLocationException') | Out-Null
            $CreationParams.Remove('RemoveExchangeLocation') | Out-Null
            $CreationParams.Remove('RemoveOneDriveLocation') | Out-Null
            $CreationParams.Remove('RemoveOneDriveLocationException') | Out-Null
            $CreationParams.Remove('RemoveSharePointLocation') | Out-Null
            $CreationParams.Remove('RemoveSharePointLocationException') | Out-Null

            try
            {
                New-AutoSensitivityLabelPolicy @CreationParams
            }
            catch
            {
                Write-Warning "New-AutoSensitivityLabelPolicy is not available in tenant $($this.Credential.UserName.Split('@')[0])"
            }
            try
            {
                Start-Sleep 5
                $SetParams = Remove-M365DSCAuthenticationParameter -BoundParameters $createParameters

                #Remove unused parameters for Set-Label cmdlet
                $SetParams.Remove('Name') | Out-Null
                $SetParams.Remove('ExchangeLocationException') | Out-Null
                $SetParams.Remove('ExchangeLocation') | Out-Null
                $SetParams.Remove('OneDriveLocation') | Out-Null
                $SetParams.Remove('OneDriveLocationException') | Out-Null
                $SetParams.Remove('SharePointLocation') | Out-Null
                $SetParams.Remove('SharePointLocationException') | Out-Null

                Set-AutoSensitivityLabelPolicy @SetParams -Identity $this.Name
            }
            catch
            {
                Write-Warning "Set-AutoSensitivityLabelPolicy is not available in tenant $($this.Credential.UserName.Split('@')[0])"
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            $updateParameters = $boundParameters
            $SetParams = Remove-M365DSCAuthenticationParameter -BoundParameters $updateParameters

            #Remove unused parameters for Set-Label cmdlet
            $SetParams.Remove('Name') | Out-Null
            $SetParams.Remove('ExchangeLocationException') | Out-Null
            $SetParams.Remove('ExchangeLocation') | Out-Null
            $SetParams.Remove('OneDriveLocation') | Out-Null
            $SetParams.Remove('OneDriveLocationException') | Out-Null
            $SetParams.Remove('SharePointLocation') | Out-Null
            $SetParams.Remove('SharePointLocationException') | Out-Null

            try
            {
                Set-AutoSensitivityLabelPolicy @SetParams -Identity $this.Name
            }
            catch
            {
                Write-Warning "Set-AutoSensitivityLabelPolicy is not available in tenant $($this.Credential.UserName.Split('@')[0])"
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            # If the label exists and it shouldn't, simply remove it;Need to force deletoion
            Write-Verbose -Message "Deleting Auto Sensitivity label policy $($this.Name)."

            try
            {
                Remove-AutoSensitivityLabelPolicy -Identity $this.Name -Confirm:$false
            }
            catch
            {
                Write-Warning "Remove-AutoSensitivityLabelPolicy is not available in tenant $($this.Credential.UserName.Split('@')[0])"
            }
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        # Declared up front: assigned conditionally below, which class methods reject.
        $dscContent = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        #region Telemetry
        $this.AddTelemetry('Export')
        #endregion

        try
        {
            [array]$policies = Get-AutoSensitivityLabelPolicy -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($policies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.Name)" -DeferWrite

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport(@{ Name = $policy.Name })

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
            }
        }
        catch
        {
            if ($_.Exception.Message -like '*is not recognized as the name of a cmdlet*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for this feature."
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }
        return $dscContent.ToString()
    }

    hidden static [System.String[]] GetRecipientAddresses([System.Object] $Values)
    {
        $addresses = @()
        foreach ($value in @($Values))
        {
            if ($null -eq $value)
            {
                continue
            }

            if ($value -is [System.String] -and $value.TrimStart().StartsWith('{'))
            {
                $value = ConvertFrom-Json -InputObject $value
            }

            if ($value -is [System.String])
            {
                $addresses += $value
            }
            elseif (-not [System.String]::IsNullOrEmpty($value.PrimarySmtpAddress))
            {
                $addresses += [System.String] $value.PrimarySmtpAddress
            }
            elseif (-not [System.String]::IsNullOrEmpty($value.Name))
            {
                $addresses += [System.String] $value.Name
            }
        }

        return $addresses
    }

    hidden [SCAutoSensitivityLabelPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCAutoSensitivityLabelPolicy])
        {
            return $Values
        }

        $result = [SCAutoSensitivityLabelPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
