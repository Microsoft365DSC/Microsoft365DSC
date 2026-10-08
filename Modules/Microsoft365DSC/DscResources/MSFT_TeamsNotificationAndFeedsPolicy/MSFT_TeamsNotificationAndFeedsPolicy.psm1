using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsNotificationAndFeedsPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Free format text')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The SuggestedFeedsEnabledType parameter in the Microsoft Teams notifications and feeds policy controls whether users receive notifications about suggested activities and content within their Teams environment. When enabled, this parameter ensures that users are notified about recommended or relevant activities, helping them stay informed and engaged with important updates and interactions.')]
    [ValidateSet('Disabled', 'EnabledUserOverride')]
    [System.String] $SuggestedFeedsEnabledType

    [DscProperty()]
    [System.ComponentModel.Description('The TrendingFeedsEnabledType parameter in the Microsoft Teams notifications and feeds policy controls whether users receive notifications about trending activities within their Teams environment. When enabled, this parameter ensures that users are notified about popular or important activities, helping them stay informed about significant updates and interactions.')]
    [ValidateSet('Disabled', 'EnabledUserOverride')]
    [System.String] $TrendingFeedsEnabledType

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
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [TeamsNotificationAndFeedsPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsNotificationAndFeedsPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Teams Notification And Feeds Policy"

        try
        {
            # Single-instance policy: it always targets the Global identity.
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne 'Global')
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-CsTeamsNotificationAndFeedsPolicy -Identity 'Global' -ErrorAction Stop
                if ($null -eq $instance)
                {
                    throw 'Could not find a Teams Notification And Feeds Policy with Identity {Global}'
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "A Teams Notification And Feeds Policy with Identity {Global} was found"
            $results = @{
                IsSingleInstance          = 'Yes'
                Description               = $instance.Description
                SuggestedFeedsEnabledType = $instance.SuggestedFeedsEnabledType
                TrendingFeedsEnabledType  = $instance.TrendingFeedsEnabledType
                Credential                = $this.Credential
                ApplicationId             = $this.ApplicationId
                TenantId                  = $this.TenantId
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
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

        $null = $this.Connect('MicrosoftTeams')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        Write-Verbose -Message "Updating a Teams Notification And Feeds Policy with Identity {Global}"

        $updateParameters = ([Hashtable]$boundParameters).Clone()
        $updateParameters.Remove('IsSingleInstance') | Out-Null
        $updateParameters.Add('Identity', 'Global')
        Set-CsTeamsNotificationAndFeedsPolicy @updateParameters | Out-Null
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
            [array]$getValue = Get-CsTeamsNotificationAndFeedsPolicy -Identity 'Global' -ErrorAction Stop

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
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    IsSingleInstance      = 'Yes'
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

    hidden [TeamsNotificationAndFeedsPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsNotificationAndFeedsPolicy])
        {
            return $Values
        }

        $result = [TeamsNotificationAndFeedsPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
