using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCRetentionCompliancePolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name of the retention policy.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this policy should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The AdaptiveScopeLocation parameter specifies the names of the adaptive scopes the policy applies to. An adaptive policy cannot use any other location, and a policy cannot switch between adaptive and static locations.')]
    [System.String[]] $AdaptiveScopeLocation

    [DscProperty()]
    [System.ComponentModel.Description('The Applications parameter specifies the workloads the policy applies to, in the format <LocationType>:<Workload>, for example User:Exchange. Adaptive scopes of the User or Group location type require it.')]
    [System.String[]] $Applications

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('Determines if the policy is enabled or not.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The ExchangeLocation parameter specifies the mailboxes to include.')]
    [System.String[]] $ExchangeLocation

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the mailboxes to remove from the list of excluded mailboxes when you use the value All for the ExchangeLocation parameter')]
    [System.String[]] $ExchangeLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The ModernGroupLocation parameter specifies the Office 365 groups to include in the policy.')]
    [System.String[]] $ModernGroupLocation

    [DscProperty()]
    [System.ComponentModel.Description('The ModernGroupLocationException parameter specifies the Office 365 groups to exclude when you''re using the value All for the ModernGroupLocation parameter.')]
    [System.String[]] $ModernGroupLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The OneDriveLocation parameter specifies the OneDrive for Business sites to include. You identify the site by its URL value, or you can use the value All to include all sites.')]
    [System.String[]] $OneDriveLocation

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the OneDrive for Business sites to exclude when you use the value All for the OneDriveLocation parameter. You identify the site by its URL value.')]
    [System.String[]] $OneDriveLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The PublicFolderLocation parameter specifies that you want to include all public folders in the retention policy. You use the value All for this parameter.')]
    [System.String[]] $PublicFolderLocation

    [DscProperty()]
    [System.ComponentModel.Description('The RestrictiveRetention parameter specifies whether Preservation Lock is enabled for the policy.')]
    [System.Nullable[System.Boolean]] $RestrictiveRetention

    [DscProperty()]
    [System.ComponentModel.Description('The SharePointLocation parameter specifies the SharePoint Online sites to include. You identify the site by its URL value, or you can use the value All to include all sites.')]
    [System.String[]] $SharePointLocation

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the SharePoint Online sites to exclude when you use the value All for the SharePointLocation parameter. You identify the site by its URL value.')]
    [System.String[]] $SharePointLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The SkypeLocation parameter specifies the Skype for Business Online users to include in the policy.')]
    [System.String[]] $SkypeLocation

    [DscProperty()]
    [System.ComponentModel.Description('This parameter is reserved for internal Microsoft use.')]
    [System.String[]] $SkypeLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The TeamsChannelLocation parameter specifies the Teams Channel to include in the policy.')]
    [System.String[]] $TeamsChannelLocation

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the SharePoint Online sites to exclude when you use the value All for the TeamsChannelLocation parameter. You identify the site by its URL value.')]
    [System.String[]] $TeamsChannelLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The TeamsChatLocation parameter specifies the Teams Chat to include in the policy.')]
    [System.String[]] $TeamsChatLocation

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the SharePoint Online sites to exclude when you use the value All for the TeamsChatLocation parameter. You identify the site by its URL value.')]
    [System.String[]] $TeamsChatLocationException

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

    [SCRetentionCompliancePolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCRetentionCompliancePolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of RetentionCompliancePolicy for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $PolicyObject = Invoke-M365DSCCommand -ScriptBlock { Get-RetentionCompliancePolicy -Identity $this.Name -DistributionDetail -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $PolicyObject -or $PolicyObject.Mode -eq 'PendingDeletion')
                {
                    Write-Verbose -Message "RetentionCompliancePolicy $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $PolicyObject = $this.ExportedInstance
            }

            Write-Verbose "Found existing RetentionCompliancePolicy $($this.Name)"

            if ($PolicyObject.TeamsPolicy)
            {
                $result = @{
                    Ensure                        = 'Present'
                    Name                          = $PolicyObject.Name
                    Comment                       = $PolicyObject.Comment
                    Enabled                       = $PolicyObject.Enabled
                    RestrictiveRetention          = $PolicyObject.RestrictiveRetention
                    TeamsChannelLocation          = @()
                    TeamsChannelLocationException = @()
                    TeamsChatLocation             = @()
                    TeamsChatLocationException    = @()
                    Credential                    = $this.Credential
                    ApplicationId                 = $this.ApplicationId
                    TenantId                      = $this.TenantId
                    CertificateThumbprint         = $this.CertificateThumbprint
                    CertificatePath               = $this.CertificatePath
                    CertificatePassword           = $this.CertificatePassword
                    ManagedIdentity               = $this.ManagedIdentity
                    AccessTokens                  = $this.AccessTokens
                }

                if ($PolicyObject.TeamsChannelLocation.Count -gt 0)
                {
                    $result.TeamsChannelLocation = [array]$PolicyObject.TeamsChannelLocation.Name
                }
                if ($PolicyObject.TeamsChatLocation.Count -gt 0)
                {
                    $result.TeamsChatLocation = [array]$PolicyObject.TeamsChatLocation.Name
                }
                if ($PolicyObject.TeamsChannelLocationException.Count -gt 0)
                {
                    $result.TeamsChannelLocationException = [array]$PolicyObject.TeamsChannelLocationException.Name
                }
                if ($PolicyObject.TeamsChatLocationException.Count -gt 0)
                {
                    $result.TeamsChatLocationException = [array]$PolicyObject.TeamsChatLocationException.Name
                }
            }
            else
            {
                $result = @{
                    Ensure                       = 'Present'
                    Name                         = $PolicyObject.Name
                    AdaptiveScopeLocation        = $null
                    Applications                 = $null
                    Comment                      = $PolicyObject.Comment
                    Enabled                      = $PolicyObject.Enabled
                    ExchangeLocation             = @()
                    ExchangeLocationException    = @()
                    ModernGroupLocation          = @()
                    ModernGroupLocationException = @()
                    OneDriveLocation             = @()
                    OneDriveLocationException    = @()
                    PublicFolderLocation         = @()
                    RestrictiveRetention         = $PolicyObject.RestrictiveRetention
                    SharePointLocation           = @()
                    SharePointLocationException  = @()
                    SkypeLocation                = @()
                    SkypeLocationException       = @()
                    Credential                   = $this.Credential
                    ApplicationId                = $this.ApplicationId
                    TenantId                     = $this.TenantId
                    CertificateThumbprint        = $this.CertificateThumbprint
                    CertificatePath              = $this.CertificatePath
                    CertificatePassword          = $this.CertificatePassword
                    ManagedIdentity              = $this.ManagedIdentity
                    AccessTokens                 = $this.AccessTokens
                }

                if ($PolicyObject.AdaptiveScopeLocation.Count -gt 0)
                {
                    $result.AdaptiveScopeLocation = [array]$PolicyObject.AdaptiveScopeLocation.Name
                }
                if ($PolicyObject.Applications.Count -gt 0)
                {
                    $result.Applications = [System.String[]]$PolicyObject.Applications
                }
                if ($PolicyObject.ExchangeLocation.Count -gt 0)
                {
                    $result.ExchangeLocation = [array]$PolicyObject.ExchangeLocation.Name
                }
                if ($PolicyObject.ModernGroupLocation.Count -gt 0)
                {
                    $result.ModernGroupLocation = [array]$PolicyObject.ModernGroupLocation.Name
                }
                if ($PolicyObject.OneDriveLocation.Count -gt 0)
                {
                    $result.OneDriveLocation = [array]$PolicyObject.OneDriveLocation.Name
                }
                if ($PolicyObject.PublicFolderLocation.Count -gt 0)
                {
                    $result.PublicFolderLocation = [array]$PolicyObject.PublicFolderLocation.Name
                }
                if ($PolicyObject.SharePointLocation.Count -gt 0)
                {
                    $result.SharePointLocation = [array]$PolicyObject.SharePointLocation.Name
                }
                if ($PolicyObject.SkypeLocation.Count -gt 0)
                {
                    $result.SkypeLocation = [array]$PolicyObject.SkypeLocation.Name
                }
                if ($PolicyObject.ExchangeLocationException.Count -gt 0)
                {
                    $result.ExchangeLocationException = [array]$PolicyObject.ExchangeLocationException.Name
                }
                if ($PolicyObject.ModernGroupLocationException.Count -gt 0)
                {
                    $result.ModernGroupLocationException = [array]$PolicyObject.ModernGroupLocationException.Name
                }
                if ($PolicyObject.OneDriveLocationException.Count -gt 0)
                {
                    $result.OneDriveLocationException = [array]$PolicyObject.OneDriveLocationException.Name
                }
                if ($PolicyObject.SharePointLocationException.Count -gt 0)
                {
                    $result.SharePointLocationException = [array]$PolicyObject.SharePointLocationException.Name
                }
                if ($PolicyObject.SkypeLocationException.Count -gt 0)
                {
                    $result.SkypeLocationException = [array]$PolicyObject.SkypeLocationException.Name
                }
            }

            Write-Verbose -Message "Found RetentionCompliancePolicy $($this.Name)"
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

        $staticLocations = @(
            $this.SharePointLocation, $this.ExchangeLocation, $this.OneDriveLocation, $this.SkypeLocation,
            $this.PublicFolderLocation, $this.ModernGroupLocation, $this.TeamsChannelLocation, $this.TeamsChatLocation
        ) | Where-Object -FilterScript { $null -ne $_ }
        $isAdaptive = @($this.AdaptiveScopeLocation | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) }).Count -gt 0

        if (-not $isAdaptive -and @($staticLocations).Count -eq 0 -and $this.Ensure -eq 'Present')
        {
            throw 'You need to specify at least one Location for this Policy.'
        }

        if ($isAdaptive -and @($staticLocations).Count -gt 0)
        {
            throw "Retention Compliance Policy {$($this.Name)} cannot combine AdaptiveScopeLocation with static locations."
        }

        if ($null -ne $this.SkypeLocation -and $this.SkypeLocation -eq 'all')
        {
            throw 'Skype Location must be a any value that uniquely identifies the user.Ex Name, email address, GUID'
        }

        Write-Verbose -Message "Setting configuration of RetentionCompliancePolicy for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentPolicy = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Present' -and
            $isAdaptive -ne (@($CurrentPolicy.AdaptiveScopeLocation | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) }).Count -gt 0))
        {
            throw "Retention Compliance Policy {$($this.Name)} cannot switch between adaptive and static locations. Remove the policy and create it again instead."
        }

        $isTeamsBased = $false
        if ($null -eq $this.TeamsChannelLocation -and $null -eq $this.TeamsChatLocation)
        {
            $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            $CreationParams.Remove('Name')
            $CreationParams.Add('Identity', $this.Name)
            $CreationParams.Remove('TeamsChannelLocation')
            $CreationParams.Remove('TeamsChannelLocationException')
            $CreationParams.Remove('TeamsChatLocation')
            $CreationParams.Remove('TeamsChatLocationException')

            if ($CurrentPolicy.Ensure -eq 'Present')
            {
                if ($isAdaptive)
                {
                    $ToBeRemoved = $CurrentPolicy.AdaptiveScopeLocation | `
                            Where-Object { $this.AdaptiveScopeLocation -notcontains $_ }
                    if ($null -ne $ToBeRemoved)
                    {
                        $CreationParams.Add('RemoveAdaptiveScopeLocation', $ToBeRemoved)
                    }

                    $ToBeAdded = $this.AdaptiveScopeLocation | `
                            Where-Object { $CurrentPolicy.AdaptiveScopeLocation -notcontains $_ }
                    if ($null -ne $ToBeAdded)
                    {
                        $CreationParams.Add('AddAdaptiveScopeLocation', $ToBeAdded)
                    }
                    $CreationParams.Remove('AdaptiveScopeLocation')
                }

                # Exchange Location is specified or already existing, we need to determine
                # the delta.
                if ($null -ne $CurrentPolicy.ExchangeLocation -or `
                        $null -ne $this.ExchangeLocation)
                {
                    $ToBeRemoved = $CurrentPolicy.ExchangeLocation | `
                            Where-Object { $this.ExchangeLocation -notcontains $_ }
                    if ($null -ne $ToBeRemoved)
                    {
                        $CreationParams.Add('RemoveExchangeLocation', $ToBeRemoved)
                    }

                    $ToBeAdded = $this.ExchangeLocation | `
                            Where-Object { $CurrentPolicy.ExchangeLocation -notcontains $_ }
                    if ($null -ne $ToBeAdded)
                    {
                        $CreationParams.Add('AddExchangeLocation', $ToBeAdded)
                    }

                    $CreationParams.Remove('ExchangeLocation')
                }

                # Exchange Location Exception is specified or already existing, we need to determine
                # the delta.
                if ($null -ne $CurrentPolicy.ExchangeLocationException -or `
                        $null -ne $this.ExchangeLocationException)
                {
                    $ToBeRemoved = $CurrentPolicy.ExchangeLocationException | `
                            Where-Object { $this.ExchangeLocationException -notcontains $_ }
                    if ($null -ne $ToBeRemoved)
                    {
                        $CreationParams.Add('RemoveExchangeLocationException', $ToBeRemoved)
                    }

                    $ToBeAdded = $this.ExchangeLocationException | `
                            Where-Object { $CurrentPolicy.ExchangeLocationException -notcontains $_ }
                    if ($null -ne $ToBeAdded)
                    {
                        $CreationParams.Add('AddExchangeLocationException', $ToBeAdded)
                    }
                    $CreationParams.Remove('ExchangeLocationException')
                }

                # Modern Group Location is specified or already existing, we need to determine
                # the delta.
                if ($null -ne $CurrentPolicy.ModernGroupLocation -or `
                        $null -ne $this.ModernGroupLocation)
                {
                    $ToBeRemoved = $CurrentPolicy.ModernGroupLocation | `
                            Where-Object { $this.ModernGroupLocation -notcontains $_ }
                    if ($null -ne $ToBeRemoved)
                    {
                        $CreationParams.Add('RemoveModernGroupLocation', $ToBeRemoved)
                    }

                    $ToBeAdded = $this.ModernGroupLocation | `
                            Where-Object { $CurrentPolicy.ModernGroupLocation -notcontains $_ }
                    if ($null -ne $ToBeAdded)
                    {
                        $CreationParams.Add('AddModernGroupLocation', $ToBeAdded)
                    }
                    $CreationParams.Remove('ModernGroupLocation')
                }

                # Modern Group Location Exception is specified or already existing, we need to determine
                # the delta.
                if ($null -ne $CurrentPolicy.ModernGroupLocationException -or `
                        $null -ne $this.ModernGroupLocationException)
                {
                    $ToBeRemoved = $CurrentPolicy.ModernGroupLocationException | `
                            Where-Object { $this.ModernGroupLocationException -notcontains $_ }
                    if ($null -ne $ToBeRemoved)
                    {
                        $CreationParams.Add('RemoveModernGroupLocationException', $ToBeRemoved)
                    }

                    $ToBeAdded = $this.ModernGroupLocationException | `
                            Where-Object { $CurrentPolicy.ModernGroupLocationException -notcontains $_ }
                    if ($null -ne $ToBeAdded)
                    {
                        $CreationParams.Add('AddModernGroupLocationException', $ToBeAdded)
                    }
                    $CreationParams.Remove('ModernGroupLocationException')
                }

                # OneDrive Location is specified or already existing, we need to determine
                # the delta.
                if ($null -ne $CurrentPolicy.OneDriveLocation -or `
                        $null -ne $this.OneDriveLocation)
                {
                    $ToBeRemoved = $CurrentPolicy.OneDriveLocation | `
                            Where-Object { $this.OneDriveLocation -notcontains $_ }
                    if ($null -ne $ToBeRemoved)
                    {
                        $CreationParams.Add('RemoveOneDriveLocation', $ToBeRemoved)
                    }

                    $ToBeAdded = $this.OneDriveLocation | `
                            Where-Object { $CurrentPolicy.OneDriveLocation -notcontains $_ }
                    if ($null -ne $ToBeAdded)
                    {
                        $CreationParams.Add('AddOneDriveLocation', $ToBeAdded)
                    }
                    $CreationParams.Remove('OneDriveLocation')
                }

                # OneDrive Location Exception is specified or already existing, we need to determine
                # the delta.
                if ($null -ne $CurrentPolicy.OneDriveLocationException -or `
                        $null -ne $this.OneDriveLocationException)
                {
                    $ToBeRemoved = $CurrentPolicy.OneDriveLocationException | `
                            Where-Object { $this.OneDriveLocationException -notcontains $_ }
                    if ($null -ne $ToBeRemoved)
                    {
                        $CreationParams.Add('RemoveOneDriveLocationException', $ToBeRemoved)
                    }

                    $ToBeAdded = $this.OneDriveLocationException | `
                            Where-Object { $CurrentPolicy.OneDriveLocationException -notcontains $_ }
                    if ($null -ne $ToBeAdded)
                    {
                        $CreationParams.Add('AddOneDriveLocationException', $ToBeAdded)
                    }
                    $CreationParams.Remove('OneDriveLocationException')
                }

                # Public Folder Location is specified or already existing, we need to determine
                # the delta.
                if ($null -ne $CurrentPolicy.PublicFolderLocation -or `
                        $null -ne $this.PublicFolderLocation)
                {
                    $ToBeRemoved = $CurrentPolicy.PublicFolderLocation | `
                            Where-Object { $this.PublicFolderLocation -notcontains $_ }
                    if ($null -ne $ToBeRemoved)
                    {
                        $CreationParams.Add('RemovePublicFolderLocation', $ToBeRemoved)
                    }

                    $ToBeAdded = $this.PublicFolderLocation | `
                            Where-Object { $CurrentPolicy.PublicFolderLocation -notcontains $_ }
                    if ($null -ne $ToBeAdded)
                    {
                        $CreationParams.Add('AddPublicFolderLocation', $ToBeAdded)
                    }
                    $CreationParams.Remove('PublicFolderLocation')
                }

                # SharePoint Location is specified or already existing, we need to determine
                # the delta.
                if ($null -ne $CurrentPolicy.SharePointLocation -or `
                        $null -ne $this.SharePointLocation)
                {
                    $ToBeRemoved = $CurrentPolicy.SharePointLocation | `
                            Where-Object { $this.SharePointLocation -notcontains $_ }
                    if ($null -ne $ToBeRemoved)
                    {
                        $CreationParams.Add('RemoveSharePointLocation', $ToBeRemoved)
                    }

                    $ToBeAdded = $this.SharePointLocation | `
                            Where-Object { $CurrentPolicy.SharePointLocation -notcontains $_ }
                    if ($null -ne $ToBeAdded)
                    {
                        $CreationParams.Add('AddSharePointLocation', $ToBeAdded)
                    }
                    $CreationParams.Remove('SharePointLocation')
                }

                # SharePoint Location Exception is specified or already existing, we need to determine
                # the delta.
                if ($null -ne $CurrentPolicy.SharePointLocationException -or `
                        $null -ne $this.SharePointLocationException)
                {
                    $ToBeRemoved = $CurrentPolicy.SharePointLocationException | `
                            Where-Object { $this.SharePointLocationException -notcontains $_ }
                    if ($null -ne $ToBeRemoved)
                    {
                        $CreationParams.Add('RemoveSharePointLocationException', $ToBeRemoved)
                    }

                    $ToBeAdded = $this.SharePointLocationException | `
                            Where-Object { $CurrentPolicy.SharePointLocationException -notcontains $_ }
                    if ($null -ne $ToBeAdded)
                    {
                        $CreationParams.Add('AddSharePointLocationException', $ToBeAdded)
                    }
                    $CreationParams.Remove('SharePointLocationException')
                }

                # Skype Location is specified or already existing, we need to determine
                # the delta.
                if ($null -ne $CurrentPolicy.SkypeLocation -or `
                        $null -ne $this.SkypeLocation)
                {
                    $ToBeRemoved = $CurrentPolicy.SkypeLocation | `
                            Where-Object { $this.SkypeLocation -notcontains $_ }
                    if ($null -ne $ToBeRemoved)
                    {
                        $CreationParams.Add('RemoveSkypeLocation', $ToBeRemoved)
                    }

                    $ToBeAdded = $this.SkypeLocation | `
                            Where-Object { $CurrentPolicy.SkypeLocation -notcontains $_ }
                    if ($null -ne $ToBeAdded)
                    {
                        $CreationParams.Add('AddSkypeLocation', $ToBeAdded)
                    }
                    $CreationParams.Remove('SkypeLocation')
                }

                # Skype Location Exception is specified or already existing, we need to determine
                # the delta.
                if ($null -ne $CurrentPolicy.SkypeLocationException -or `
                        $null -ne $this.SkypeLocationException)
                {
                    $ToBeRemoved = $CurrentPolicy.SkypeLocationException | `
                            Where-Object { $this.SkypeLocationException -notcontains $_ }
                    if ($null -ne $ToBeRemoved)
                    {
                        $CreationParams.Add('RemoveSkypeLocationException', $ToBeRemoved)
                    }

                    $ToBeAdded = $this.SkypeLocationException | `
                            Where-Object { $CurrentPolicy.SkypeLocationException -notcontains $_ }
                    if ($null -ne $ToBeAdded)
                    {
                        $CreationParams.Add('AddSkypeLocationException', $ToBeAdded)
                    }
                    $CreationParams.Remove('SkypeLocationException')
                }
            }
        }
        else
        {
            $isTeamsBased = $true
            Write-Verbose -Message "Policy $($this.Name) is a Teams Policy"
            $CreationParams = @{
                Identity             = $this.Name
                Comment              = $this.Comment
                Enabled              = $this.Enabled
                RestrictiveRetention = $this.RestrictiveRetention
            }

            if ($null -ne $this.TeamsChannelLocation)
            {
                $CreationParams.Add('TeamsChannelLocation', $this.TeamsChannelLocation)
            }
            if ($null -ne $this.TeamsChannelLocationException)
            {
                $CreationParams.Add('TeamsChannelLocationException', $this.TeamsChannelLocationException)
            }
            if ($null -ne $this.TeamsChatLocation)
            {
                $CreationParams.Add('TeamsChatLocation', $this.TeamsChatLocation)
            }
            if ($null -ne $this.TeamsChatLocationException)
            {
                $CreationParams.Add('TeamsChatLocationException', $this.TeamsChatLocationException)
            }

            # Teams Chat Location is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.TeamsChatLocation -or `
                    $null -ne $this.TeamsChatLocation)
            {
                $ToBeRemoved = $CurrentPolicy.TeamsChatLocation | `
                        Where-Object { $this.TeamsChatLocation -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    Write-Verbose -Message 'Adding the RemoveTeamsChatLocation property.'
                    $CreationParams.Add('RemoveTeamsChatLocation', $ToBeRemoved)
                }

                $ToBeAdded = $this.TeamsChatLocation | `
                        Where-Object { $CurrentPolicy.TeamsChatLocation -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    Write-Verbose -Message 'Adding the AddTeamsChatLocation property.'
                    $CreationParams.Add('AddTeamsChatLocation', $ToBeAdded)
                }
            }

            # Teams Chat Location Exception is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.TeamsChatLocationException -or `
                    $null -ne $this.TeamsChatLocationException)
            {
                $ToBeRemoved = $CurrentPolicy.TeamsChatLocationException | `
                        Where-Object { $this.TeamsChatLocationException -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    Write-Verbose -Message 'Adding the RemoveTeamsChatLocationException property.'
                    $CreationParams.Add('RemoveTeamsChatLocationException', $ToBeRemoved)
                }

                $ToBeAdded = $this.TeamsChatLocationException | `
                        Where-Object { $CurrentPolicy.TeamsChatLocationException -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    Write-Verbose -Message 'Adding the AddTeamsChatLocationException property.'
                    $CreationParams.Add('AddTeamsChatLocationException', $ToBeAdded)
                }
            }

            # Teams Channel Location is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.TeamsChannelLocation -or `
                    $null -ne $this.TeamsChannelLocation)
            {
                $ToBeRemoved = $CurrentPolicy.TeamsChannelLocation | `
                        Where-Object { $this.TeamsChannelLocation -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    Write-Verbose -Message 'Adding the RemoveTeamsChannelLocation property.'
                    $CreationParams.Add('RemoveTeamsChannelLocation', $ToBeRemoved)
                }

                $ToBeAdded = $this.TeamsChannelLocation | `
                        Where-Object { $CurrentPolicy.TeamsChannelLocation -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    Write-Verbose -Message 'Adding the AddTeamsChannelLocation property.'
                    $CreationParams.Add('AddTeamsChannelLocation', $ToBeAdded)
                }
            }

            # Teams Channel Location Exception is specified or already existing, we need to determine
            # the delta.
            if ($null -ne $CurrentPolicy.TeamsChannelLocationException -or `
                    $null -ne $this.TeamsChannelLocationException)
            {
                $ToBeRemoved = $CurrentPolicy.TeamsChannelLocationException | `
                        Where-Object { $this.TeamsChannelLocationException -notcontains $_ }
                if ($null -ne $ToBeRemoved)
                {
                    Write-Verbose -Message 'Adding the RemoveTeamsChannelLocationException property.'
                    $CreationParams.Add('RemoveTeamsChannelLocationException', $ToBeRemoved)
                }

                $ToBeAdded = $this.TeamsChannelLocationException | `
                        Where-Object { $CurrentPolicy.TeamsChannelLocationException -notcontains $_ }
                if ($null -ne $ToBeAdded)
                {
                    Write-Verbose -Message 'Adding the AddTeamsChannelLocationException property.'
                    $CreationParams.Add('AddTeamsChannelLocationException', $ToBeAdded)
                }
            }
        }
        if ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Absent')
        {
            $pendingPolicy = Invoke-M365DSCCommand -ScriptBlock { Get-RetentionCompliancePolicy -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError
            if ($null -ne $pendingPolicy -and "$($pendingPolicy.Mode)" -eq 'PendingDeletion')
            {
                Write-Verbose -Message "Completing the pending deletion of the Retention Compliance Policy {$($this.Name)}"
                $this.CompleteDeletion($pendingPolicy.Guid)
            }

            $CreationParams.Add('Name', $this.Name)
            $CreationParams.Remove('Identity') | Out-Null
            Write-Verbose -Message "Creating new Retention Compliance Policy $($this.Name) with values: $(Convert-M365DscHashtableToString -Hashtable $CreationParams)"
            for ($attempt = 1; $attempt -le 10; $attempt++)
            {
                try
                {
                    New-RetentionCompliancePolicy @CreationParams -ErrorAction Stop
                    break
                }
                catch
                {
                    if ($_.Exception.Message -like '*failed to be deployed*')
                    {
                        Write-Warning -Message "The creation succeeded, but the policy failed to be deployed. The service retries the deployment later. $($_.Exception.Message)"
                        break
                    }

                    if ($_.Exception.Message -notlike '*already exists in scenario*' -or $attempt -eq 10)
                    {
                        throw
                    }

                    Write-Verbose -Message "The deletion of the previous policy is still in progress. Waiting 30 seconds for a maximum of 300 seconds (5 minutes). Total time waited so far {$($attempt * 30) seconds}"
                    Start-Sleep -Seconds 30
                }
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            # Remove Teams specific parameters
            $CreationParams.Remove('TeamsChatLocationException') | Out-Null
            $CreationParams.Remove('TeamsChannelLocationException') | Out-Null
            $CreationParams.Remove('TeamsChannelLocation') | Out-Null
            $CreationParams.Remove('TeamsChatLocation') | Out-Null

            if ($isTeamsBased)
            {
                $CreationParams.Remove('RestrictiveRetention') | Out-Null
            }

            Write-Verbose "Updating Policy with values: $(Convert-M365DscHashtableToString -Hashtable $CreationParams)"
            $success = $false
            $retries = 1
            while (!$success -and $retries -le 10)
            {
                try
                {
                    Set-RetentionCompliancePolicy @CreationParams -Force -ErrorAction Stop
                    $success = $true
                }
                catch
                {
                    if ($_.Exception.Message -like '*failed to be deployed*')
                    {
                        Write-Warning -Message "The update succeeded, but the policy failed to be deployed. The service retries the deployment later. $($_.Exception.Message)"
                        $success = $true
                    }
                    elseif ($_.Exception.Message -like '*are being deployed. Once deployed, additional actions can be performed*' -and $retries -lt 10)
                    {
                        Write-Verbose -Message "The policy has pending changes being deployed. Waiting 30 seconds for a maximum of 300 seconds (5 minutes). Total time waited so far {$($retries * 30) seconds}"
                        Start-Sleep -Seconds 30
                    }
                    else
                    {
                        throw
                    }
                }
                $retries++
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            $success = $false
            $retries = 1
            while (!$success -and $retries -le 10)
            {
                try
                {
                    Remove-RetentionCompliancePolicy -Identity $this.Name -Confirm:$false -ErrorAction Stop
                    $success = $true
                }
                catch
                {
                    if ($_.Exception.Message -like '*failed to be deployed*')
                    {
                        Write-Warning -Message "The removal succeeded, but the policy failed to be deployed. The service retries the deployment later. $($_.Exception.Message)"
                        $success = $true
                    }
                    elseif ($_.Exception.Message -like '*are being deployed. Once deployed, additional actions can be performed*' -and $retries -lt 10)
                    {
                        Write-Verbose -Message "The policy has pending changes being deployed. Waiting 30 seconds for a maximum of 300 seconds (5 minutes). Total time waited so far {$($retries * 30) seconds}"
                        Start-Sleep -Seconds 30
                    }
                    else
                    {
                        throw
                    }
                }
                $retries++
            }

            $this.CompleteDeletion($this.Name)
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

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$policies = @(Get-RetentionCompliancePolicy -DistributionDetail -ErrorAction Stop | Where-Object -FilterScript { $_.Mode -ne 'PendingDeletion' })

            $i = 1
            if ($policies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Length)] $($policy.Name)" -DeferWrite

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport(@{ Name = $policy.Name })
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

    hidden [void] CompleteDeletion([System.String] $Identity)
    {
        for ($attempt = 1; $attempt -le 10; $attempt++)
        {
            try
            {
                Remove-RetentionCompliancePolicy -Identity $Identity -ForceDeletion -Confirm:$false -ErrorAction Stop
                return
            }
            catch
            {
                if ($_.Exception.Message -like '*failed to be deployed*')
                {
                    Write-Warning -Message "The deletion succeeded, but the policy failed to be deployed. The service retries the deployment later. $($_.Exception.Message)"
                    return
                }

                if ($_.Exception.Message -notlike '*are being deployed. Once deployed, additional actions can be performed*' -or $attempt -eq 10)
                {
                    throw
                }

                Write-Verbose -Message "The policy has pending changes being deployed. Waiting 30 seconds for a maximum of 300 seconds (5 minutes). Total time waited so far {$($attempt * 30) seconds}"
                Start-Sleep -Seconds 30
            }
        }
    }

    hidden [SCRetentionCompliancePolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCRetentionCompliancePolicy])
        {
            return $Values
        }

        $result = [SCRetentionCompliancePolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
