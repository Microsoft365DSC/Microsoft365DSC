using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsTargetingPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Determine whether Teams users can create tags in team. Set this to Enabled to allow users to create new tags. Set this to Disabled to prohibit them from creating new tags.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $CustomTagsMode

    [DscProperty()]
    [System.ComponentModel.Description('Pass in a new description if that field needs to be updated.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Determine whether team users can manage tag settings in Teams. Set this to EnabledTeamOwner to only allow Teams owners to manage tag settings in current Teams. Set this to EnabledTeamOwnerMember to allow Teams owners and Teams members to manage tag settings in current Teams. Set this to EnabledTeamOwnerMemberGuest to allow Teams owners, Teams members and guest users to manage tag settings in current Teams. Set this to MicrosoftDefault to user default setting in current Teams, which will be the same as EnabledTeamOwner. Set this to Disabled to prohibit all users from managing tag settings in current Teams.')]
    [ValidateSet('Disabled', 'EnabledTeamOwner', 'EnabledTeamOwnerMember', 'EnabledTeamOwnerMemberGuest', 'MicrosoftDefault')]
    [System.String] $ManageTagsPermissionMode

    [DscProperty()]
    [System.ComponentModel.Description('Determine whether Teams can have tags created by Shift App. Set this to Enabled to allow tags created by Shift App. Set this to Disabled to prohibit tags from Shift App.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $ShiftBackedTagsMode

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $SuggestedPresetTags

    [DscProperty()]
    [System.ComponentModel.Description('Determine whether Teams owners can change Tenant tag settings. Set this to Enabled to allow Teams owners to change Tenant tag settings for current Teams. Set this to Disabled to prohibit them from changing Tenant tag settings.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $TeamOwnersEditWhoCanManageTagsMode

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

    [TeamsTargetingPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsTargetingPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Teams Targeting Policy"

        try
        {
            $null = $this.Connect('MicrosoftTeams')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $instance = Get-CsTeamsTargetingPolicy -ErrorAction SilentlyContinue
            if ($null -eq $instance)
            {
                Write-Verbose -Message "Could not find an Teams Targeting Policy with Identity {Global}"
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "A Teams Targeting Policy with Identity {Global} was found"
            $results = @{
                IsSingleInstance                   = 'Yes'
                CustomTagsMode                     = $instance.CustomTagsMode
                Description                        = $instance.Description
                ManageTagsPermissionMode           = $instance.ManageTagsPermissionMode
                ShiftBackedTagsMode                = $instance.ShiftBackedTagsMode
                SuggestedPresetTags                = $instance.SuggestedPresetTags
                TeamOwnersEditWhoCanManageTagsMode = $instance.TeamOwnersEditWhoCanManageTagsMode
                Credential                         = $this.Credential
                ApplicationId                      = $this.ApplicationId
                TenantId                           = $this.TenantId
                CertificateThumbprint              = $this.CertificateThumbprint
                CertificatePath                    = $this.CertificatePath
                CertificatePassword                = $this.CertificatePassword
                ManagedIdentity                    = $this.ManagedIdentity
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

        Write-Verbose -Message "Updating the Teams Targeting Policy with Identity {Global}"

        $updateParameters = ([Hashtable]$boundParameters).Clone()
        $updateParameters.Remove('IsSingleInstance') | Out-Null
        $updateParameters.Add('Identity', 'Global')
        Set-CsTeamsTargetingPolicy @updateParameters | Out-Null
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
            [array]$getValue = Get-CsTeamsTargetingPolicy -ErrorAction Stop

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

    hidden [TeamsTargetingPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsTargetingPolicy])
        {
            return $Values
        }

        $result = [TeamsTargetingPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
