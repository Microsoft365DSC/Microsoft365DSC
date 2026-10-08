using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsFeedbackPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specify the name of the Teams Feedback Policy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if users are allowed to give feedback.')]
    [System.String] $UserInitiatedMode

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if users are allowed to receive the survey.')]
    [ValidateSet('Enabled', 'Disabled', 'EnabledUserOverride')]
    [System.String] $ReceiveSurveysMode

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if Screenshot Collection is enabled or not.')]
    [System.Nullable[System.Boolean]] $AllowScreenshotCollection

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if Email Collection is enabled or not.')]
    [System.Nullable[System.Boolean]] $AllowEmailCollection

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if Log Collection is enabled or not.')]
    [System.Nullable[System.Boolean]] $AllowLogCollection

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if users are allowed to provide feature suggestions')]
    [System.Nullable[System.Boolean]] $EnableFeatureSuggestions

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
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
    [System.String] $Filter = '*'

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [TeamsFeedbackPolicy] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsFeedbackPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for TeamsFeedbackPolicy $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-CsTeamsFeedbackPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "Found an instance with Identity {$($this.Identity)}"
            $results = @{
                UserInitiatedMode         = $instance.UserInitiatedMode
                ReceiveSurveysMode        = $instance.ReceiveSurveysMode
                AllowScreenshotCollection = $instance.AllowScreenshotCollection
                AllowEmailCollection      = $instance.AllowEmailCollection
                AllowLogCollection        = $instance.AllowLogCollection
                EnableFeatureSuggestions  = $instance.EnableFeatureSuggestions
                Identity                  = $instance.Identity
                Ensure                    = 'Present'
                Credential                = $this.Credential
                ApplicationId             = $this.ApplicationId
                TenantId                  = $this.TenantId
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
                AccessTokens              = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration for TeamsFeedbackPolicy $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $createParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            Write-Verbose -Message "Creating a Teams Feedback Policy with Identity {$($this.Identity)}"
            New-CsTeamsFeedbackPolicy @createParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Teams Feedback Policy with Identity {$($this.Identity)}"
            $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            Set-CsTeamsFeedbackPolicy @updateParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Teams Feedback Policy with Identity {$($this.Identity)}"
            Remove-CsTeamsFeedbackPolicy -Identity $currentInstance.Identity
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
            [array]$getValue = Get-CsTeamsFeedbackPolicy -Filter $this.Filter -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Identity
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Identity              = $config.Identity
                    Ensure                = 'Present'
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

    hidden [TeamsFeedbackPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsFeedbackPolicy])
        {
            return $Values
        }

        $result = [TeamsFeedbackPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
