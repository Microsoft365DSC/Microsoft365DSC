using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADCrossTenantAccessPolicyConfigurationPartner : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The tenant identifier for the partner Azure Active Directory (Azure AD) organization.')]
    [System.String] $PartnerTenantId

    [DscProperty()]
    [System.ComponentModel.Description('Defines your partner-specific configuration for inbound app service connect settings that control which applications can connect across tenant boundaries with the partner organization.')]
    [MSFT_AADCrossTenantAccessPolicyAppServiceConnectSetting] $AppServiceConnectInbound

    [DscProperty()]
    [System.ComponentModel.Description('Defines your partner-specific configuration for users from other organizations accessing your resources via Azure AD B2B collaboration.')]
    [MSFT_AADCrossTenantAccessPolicyB2BSetting] $B2BCollaborationInbound

    [DscProperty()]
    [System.ComponentModel.Description('Defines your partner-specific configuration for users in your organization going outbound to access resources in another organization via Azure AD B2B collaboration.')]
    [MSFT_AADCrossTenantAccessPolicyB2BSetting] $B2BCollaborationOutbound

    [DscProperty()]
    [System.ComponentModel.Description('Defines your partner-specific configuration for users from other organizations accessing your resources via Azure AD B2B direct connect.')]
    [MSFT_AADCrossTenantAccessPolicyB2BSetting] $B2BDirectConnectInbound

    [DscProperty()]
    [System.ComponentModel.Description('Defines your partner-specific configuration for users in your organization going outbound to access resources in another organization via Azure AD B2B direct connect.')]
    [MSFT_AADCrossTenantAccessPolicyB2BSetting] $B2BDirectConnectOutbound

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether users can use granular delegated admin privileges (GDAP) to sign-in and access resources in other organizations. Default value is false.')]
    [System.Nullable[System.Boolean]] $BlockServiceProviderOutboundAccess

    [DscProperty()]
    [System.ComponentModel.Description('Determines the partner-specific configuration for accepting trust claims from other tenant invitations.')]
    [MSFT_AADCrossTenantAccessPolicyAutomaticUserConsentSettings] $AutomaticUserConsentSettings

    [DscProperty()]
    [System.ComponentModel.Description('Defines the identity synchronization settings.')]
    [MSFT_AADCrossTenantIdentitySyncPolicyPartnerInbound] $IdentitySynchronization

    [DscProperty()]
    [System.ComponentModel.Description('Determines the partner-specific configuration for trusting other Conditional Access claims from external Azure AD organizations.')]
    [MSFT_AADCrossTenantAccessPolicyInboundTrust] $InboundTrust

    [DscProperty()]
    [System.ComponentModel.Description('Defines your partner-specific configuration for inbound Microsoft 365 collaboration settings that determine which users from the partner organization can collaborate with your organization using Microsoft 365 apps.')]
    [MSFT_AADCrossTenantAccessPolicyM365CollaborationInboundSetting] $M365CollaborationInbound

    [DscProperty()]
    [System.ComponentModel.Description('Defines your partner-specific configuration for outbound Microsoft 365 collaboration settings that determine which users in your organization can collaborate with the partner organization using Microsoft 365 apps.')]
    [MSFT_AADCrossTenantAccessPolicyM365CollaborationOutboundSetting] $M365CollaborationOutbound

    [DscProperty()]
    [System.ComponentModel.Description('Defines the partner-specific tenant restrictions configuration for users in your organization who access an external organization on your network or devices.')]
    [MSFT_AADCrossTenantAccessPolicyTenantRestrictions] $TenantRestrictions

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the policy should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

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

    [AADCrossTenantAccessPolicyConfigurationPartner] Get()
    {
        $AutomaticUserConsentSettingsValue = $null
        $B2BDirectConnectInboundValue = $null
        $B2BCollaborationOutboundValue = $null
        $IdentitySynchronizationValue = $null
        $B2BDirectConnectOutboundValue = $null
        $InboundTrustValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADCrossTenantAccessPolicyConfigurationPartner]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AzureAD Cross Tenant Access Policy Configuration Partner for TenantId {$($this.PartnerTenantId)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.TenantId -ne $this.PartnerTenantId)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = Get-MgBetaPolicyCrossTenantAccessPolicyPartner -CrossTenantAccessPolicyConfigurationPartnerTenantId $this.PartnerTenantId `
                    -ExpandProperty "IdentitySynchronization" `
                    -ErrorAction SilentlyContinue

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Cross Tenant Access Configuration Partner with TenantId {$($this.PartnerTenantId)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            $AppServiceConnectInboundValue = $null
            if ($null -ne $getValue.AppServiceConnectInbound.Applications.AccessType -or `
                $null -ne $getValue.AppServiceConnectInbound.Applications.Targets)
            {
                $AppServiceConnectInboundValue = [ordered]@{
                    Applications = [ordered]@{
                        AccessType = $getValue.AppServiceConnectInbound.Applications.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -PropertyValue ($getValue.AppServiceConnectInbound.Applications.Targets | ForEach-Object {
                                [ordered]@{
                                    Target     = $_.target
                                    TargetType = $_.targetType
                                }
                            }) -ElementType ([System.Object])
                    }
                }
            }
            $M365CollaborationInboundValue = $null
            if ($null -ne $getValue.M365CollaborationInbound.Users.AccessType -or `
                $null -ne $getValue.M365CollaborationInbound.Users.Targets)
            {
                $M365CollaborationInboundValue = [ordered]@{
                    Users = [ordered]@{
                        AccessType = $getValue.M365CollaborationInbound.Users.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -PropertyValue ($getValue.M365CollaborationInbound.Users.Targets | ForEach-Object {
                                [ordered]@{
                                    Target     = $_.target
                                    TargetType = $_.targetType
                                }
                            }) -ElementType ([System.Object])
                    }
                }
            }
            $M365CollaborationOutboundValue = $null
            if ($null -ne $getValue.M365CollaborationOutbound.UsersAndGroups.AccessType -or `
                $null -ne $getValue.M365CollaborationOutbound.UsersAndGroups.Targets)
            {
                $M365CollaborationOutboundValue = [ordered]@{
                    UsersAndGroups = [ordered]@{
                        AccessType = $getValue.M365CollaborationOutbound.UsersAndGroups.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -PropertyValue ($getValue.M365CollaborationOutbound.UsersAndGroups.Targets | ForEach-Object {
                                [ordered]@{
                                    Target     = $_.target
                                    TargetType = $_.targetType
                                }
                            }) -ElementType ([System.Object])
                    }
                }

                # The outbound targets are local principals, so report them the way the configuration declares them.
                $M365CollaborationOutboundValue.UsersAndGroups.Targets = Get-M365DSCArrayFromProperty -PropertyValue (
                    $M365CollaborationOutboundValue.UsersAndGroups.Targets | ForEach-Object {
                        $targetValue = $_.Target
                        if ($_.TargetType -eq 'user' -and $_.Target -ne 'AllUsers')
                        {
                            $user = Get-MgUser -UserId $_.Target -ErrorAction SilentlyContinue
                            if ($null -ne $user)
                            {
                                $targetValue = $user.UserPrincipalName
                            }
                        }
                        elseif ($_.TargetType -eq 'group')
                        {
                            $group = Get-MgGroup -GroupId $_.Target -ErrorAction SilentlyContinue
                            if ($null -ne $group)
                            {
                                $targetValue = $group.DisplayName
                            }
                        }
                        [ordered]@{
                            Target     = $targetValue
                            TargetType = $_.TargetType
                        }
                    }) -ElementType ([System.Object])
            }

            $B2BCollaborationInboundValue = $null
            if ($null -ne $getValue.B2BCollaborationInbound -and $this.TestB2BIsDefault($getValue.B2BCollaborationInbound) -eq $false)
            {
                $B2BCollaborationInboundValue = $getValue.B2BCollaborationInbound
            }
            if ($null -ne $getValue.B2BCollaborationOutbound -and $this.TestB2BIsDefault($getValue.B2BCollaborationOutbound) -eq $false)
            {
                $B2BCollaborationOutboundValue = $getValue.B2BCollaborationOutbound
            }
            if ($null -ne $getValue.B2BDirectConnectInbound -and $this.TestB2BIsDefault($getValue.B2BDirectConnectInbound) -eq $false)
            {
                $B2BDirectConnectInboundValue = $getValue.B2BDirectConnectInbound
            }
            if ($null -ne $getValue.B2BDirectConnectOutbound -and $this.TestB2BIsDefault($getValue.B2BDirectConnectOutbound) -eq $false)
            {
                $B2BDirectConnectOutboundValue = $getValue.B2BDirectConnectOutbound
            }
            if ($null -ne $getValue.AutomaticUserConsentSettings)
            {
                $AutomaticUserConsentSettingsValue = $getValue.AutomaticUserConsentSettings
            }
            if ($null -ne $getValue.InboundTrust)
            {
                $InboundTrustValue = $getValue.InboundTrust
            }
            if ($null -ne $getValue.IdentitySynchronization)
            {
                $IdentitySynchronizationValue = [ordered]@{
                    GroupSyncInbound = @{
                        IsSyncAllowed = $getValue.IdentitySynchronization.GroupSyncInbound.IsSyncAllowed
                    }
                    UserSyncInbound = @{
                        IsSyncAllowed = $getValue.IdentitySynchronization.UserSyncInbound.IsSyncAllowed
                    }
                }
                if ($null -eq $getValue.IdentitySynchronization.GroupSyncInbound.IsSyncAllowed)
                {
                    $IdentitySynchronizationValue.Remove('GroupSyncInbound') | Out-Null
                }
                if ($null -eq $getValue.IdentitySynchronization.UserSyncInbound.IsSyncAllowed)
                {
                    $IdentitySynchronizationValue.Remove('UserSyncInbound') | Out-Null
                }
            }
            $TenantRestrictionsValue = $null
            if ($null -ne $getValue.TenantRestrictions)
            {
                $TenantRestrictionsValue = [ordered]@{
                    Applications   = [ordered]@{
                        AccessType = $getValue.TenantRestrictions.Applications.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -PropertyValue ($getValue.TenantRestrictions.Applications.Targets | ForEach-Object {
                                [ordered]@{
                                    Target     = $_.Target
                                    TargetType = $_.TargetType
                                }
                            }) -ElementType ([System.Object])
                    }
                    UsersAndGroups = [ordered]@{
                        AccessType = $getValue.TenantRestrictions.UsersAndGroups.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -PropertyValue ($getValue.TenantRestrictions.UsersAndGroups.Targets | ForEach-Object {
                                [ordered]@{
                                    Target     = $_.Target
                                    TargetType = $_.TargetType
                                }
                            }) -ElementType ([System.Object])
                    }
                }
                if ($null -ne $getValue.TenantRestrictions.Devices.Mode -or $null -ne $getValue.TenantRestrictions.Devices.Rule)
                {
                    $TenantRestrictionsValue.Add('Devices', [ordered]@{
                            Mode = $getValue.TenantRestrictions.Devices.Mode
                            Rule = $getValue.TenantRestrictions.Devices.Rule
                        })
                }
            }
            $results = @{
                PartnerTenantId                    = $getValue.TenantId
                AppServiceConnectInbound           = $AppServiceConnectInboundValue
                B2BCollaborationInbound            = $B2BCollaborationInboundValue
                B2BCollaborationOutbound           = $B2BCollaborationOutboundValue
                B2BDirectConnectInbound            = $B2BDirectConnectInboundValue
                B2BDirectConnectOutbound           = $B2BDirectConnectOutboundValue
                BlockServiceProviderOutboundAccess = $getValue.BlockServiceProviderOutboundAccess
                AutomaticUserConsentSettings       = $AutomaticUserConsentSettingsValue
                IdentitySynchronization            = $IdentitySynchronizationValue
                InboundTrust                       = $InboundTrustValue
                M365CollaborationInbound           = $M365CollaborationInboundValue
                M365CollaborationOutbound          = $M365CollaborationOutboundValue
                TenantRestrictions                 = $TenantRestrictionsValue
                Ensure                             = 'Present'
                Credential                         = $this.Credential
                ApplicationId                      = $this.ApplicationId
                TenantId                           = $this.TenantId
                ApplicationSecret                  = $this.ApplicationSecret
                CertificateThumbprint              = $this.CertificateThumbprint
                CertificatePath                    = $this.CertificatePath
                CertificatePassword                = $this.CertificatePassword
                ManagedIdentity                    = $this.ManagedIdentity
                AccessTokens                       = $this.AccessTokens
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
        $identitySynchronizationValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of AzureAD Cross Tenant Access Policy Configuration Partner for TenantId {$($this.PartnerTenantId)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $OperationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($null -ne $OperationParams.AppServiceConnectInbound)
        {
            $OperationParams.AppServiceConnectInbound = $this.GetAppServiceConnectSetting($OperationParams.AppServiceConnectInbound)
        }
        if ($null -ne $OperationParams.B2BCollaborationInbound)
        {
            $OperationParams.B2BCollaborationInbound = $this.GetB2BSetting($OperationParams.B2BCollaborationInbound)
            $OperationParams.B2BCollaborationInbound = $this.UpdateSettingUserIdFromUPN($OperationParams.B2BCollaborationInbound)
        }
        if ($null -ne $OperationParams.B2BCollaborationOutbound)
        {
            $OperationParams.B2BCollaborationOutbound = $this.GetB2BSetting($OperationParams.B2BCollaborationOutbound)
            $OperationParams.B2BCollaborationOutbound = $this.UpdateSettingUserIdFromUPN($OperationParams.B2BCollaborationOutbound)
        }
        if ($null -ne $OperationParams.B2BDirectConnectInbound)
        {
            $OperationParams.B2BDirectConnectInbound = $this.GetB2BSetting($OperationParams.B2BDirectConnectInbound)
            $OperationParams.B2BDirectConnectInbound = $this.UpdateSettingUserIdFromUPN($OperationParams.B2BDirectConnectInbound)
        }
        if ($null -ne $OperationParams.B2BDirectConnectOutbound)
        {
            $OperationParams.B2BDirectConnectOutbound = $this.GetB2BSetting($OperationParams.B2BDirectConnectOutbound)
            $OperationParams.B2BDirectConnectOutbound = $this.UpdateSettingUserIdFromUPN($OperationParams.B2BDirectConnectOutbound)
        }
        if ($null -ne $OperationParams.AutomaticUserConsentSettings)
        {
            $OperationParams.AutomaticUserConsentSettings = $this.GetAutomaticUserConsentSettings($OperationParams.AutomaticUserConsentSettings)
        }
        if ($null -ne $OperationParams.InboundTrust)
        {
            $OperationParams.InboundTrust = $this.GetInboundTrust($OperationParams.InboundTrust)
        }
        if ($null -ne $OperationParams.M365CollaborationInbound)
        {
            $OperationParams.M365CollaborationInbound = $this.GetM365CollaborationInboundSetting($OperationParams.M365CollaborationInbound)
        }
        if ($null -ne $OperationParams.M365CollaborationOutbound)
        {
            $OperationParams.M365CollaborationOutbound = $this.GetM365CollaborationOutboundSetting($OperationParams.M365CollaborationOutbound)
            $OperationParams.M365CollaborationOutbound = $this.UpdateSettingUserIdFromUPN($OperationParams.M365CollaborationOutbound)
        }
        if ($null -ne $OperationParams.TenantRestrictions)
        {
            $OperationParams.TenantRestrictions = $this.GetTenantRestrictions($OperationParams.TenantRestrictions)
            $OperationParams.TenantRestrictions = $this.UpdateSettingUserIdFromUPN($OperationParams.TenantRestrictions)
        }
        if ($null -ne $OperationParams.IdentitySynchronization)
        {
            $identitySynchronizationValue = $this.GetIdentitySynchronization($OperationParams.IdentitySynchronization)
            $OperationParams.Remove('IdentitySynchronization') | Out-Null
        }

        $OperationParams = Rename-M365DSCCimInstanceParameter -Properties $OperationParams -KeyMapping @{
            B2BCollaborationInbound  = 'b2bCollaborationInbound'
            B2BCollaborationOutbound = 'b2bCollaborationOutbound'
            B2BDirectConnectInbound  = 'b2bDirectConnectInbound'
            B2BDirectConnectOutbound = 'b2bDirectConnectOutbound'
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Cross Tenant Access Policy Configuration Partner entry for TenantId {$($this.PartnerTenantId)}"
            $OperationParams.Add('tenantId', $this.PartnerTenantId)
            $OperationParams.Remove('PartnerTenantId') | Out-Null
            $newPartner = New-MgBetaPolicyCrossTenantAccessPolicyPartner -BodyParameter $OperationParams
            Start-Sleep -Seconds 2
            if ($newPartner.TenantId -and $null -ne $identitySynchronizationValue)
            {
                $this.SetIdentitySynchronization($newPartner.TenantId, $identitySynchronizationValue, $false)
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating Cross Tenant Access Policy Configuration Partner entry with TenantId {$($this.PartnerTenantId)}"
            $OperationParams.Remove('PartnerTenantId') | Out-Null
            Update-MgBetaPolicyCrossTenantAccessPolicyPartner -CrossTenantAccessPolicyConfigurationPartnerTenantId $this.PartnerTenantId -BodyParameter $OperationParams
            if ($null -ne $identitySynchronizationValue)
            {
                $this.SetIdentitySynchronization($this.PartnerTenantId, $identitySynchronizationValue, $true)
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Cross Tenant Access Policy Configuration Partner entry with TenantId {$($this.PartnerTenantId)}"
            Remove-MgBetaPolicyCrossTenantAccessPolicyPartner -CrossTenantAccessPolicyConfigurationPartnerTenantId $this.PartnerTenantId
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

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$getValue = Get-MgBetaPolicyCrossTenantAccessPolicyPartner `
                -All `
                -Filter $this.Filter `
                -ExpandProperty "IdentitySynchronization" `
                -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($entry in $getValue)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $($entry.TenantId)" -DeferWrite
                $Params = @{
                    PartnerTenantId       = $entry.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    Credential            = $this.Credential
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $entry
                $Results = $this.GetForExport($Params)

                if ($null -ne $Results.AppServiceConnectInbound)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'AppServiceConnectInbound'
                            CimInstanceName = 'AADCrossTenantAccessPolicyAppServiceConnectSetting'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Applications'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Targets'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AppServiceConnectInbound `
                        -CIMInstanceName 'AADCrossTenantAccessPolicyAppServiceConnectSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AppServiceConnectInbound = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AppServiceConnectInbound') | Out-Null
                    }
                }

                if ($null -ne $Results.B2BCollaborationInbound)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'B2BCollaborationInbound'
                            CimInstanceName = 'AADCrossTenantAccessPolicyB2BSetting'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Applications'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'UsersAndGroups'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Targets'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.B2BCollaborationInbound `
                        -CIMInstanceName 'AADCrossTenantAccessPolicyB2BSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.B2BCollaborationInbound = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('B2BCollaborationInbound') | Out-Null
                    }
                }

                if ($null -ne $Results.AutomaticUserConsentSettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AutomaticUserConsentSettings `
                        -CIMInstanceName 'AADCrossTenantAccessPolicyAutomaticUserConsentSettings'

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AutomaticUserConsentSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AutomaticUserConsentSettings') | Out-Null
                    }
                }

                if ($null -ne $Results.B2BCollaborationOutbound)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'B2BCollaborationOutbound'
                            CimInstanceName = 'AADCrossTenantAccessPolicyB2BSetting'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Applications'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'UsersAndGroups'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Targets'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.B2BCollaborationOutbound `
                        -CIMInstanceName 'AADCrossTenantAccessPolicyB2BSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.B2BCollaborationOutbound = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('B2BCollaborationOutbound') | Out-Null
                    }
                }

                if ($null -ne $Results.B2BDirectConnectInbound)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'B2BDirectConnectInbound'
                            CimInstanceName = 'AADCrossTenantAccessPolicyB2BSetting'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Applications'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'UsersAndGroups'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Targets'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.B2BDirectConnectInbound `
                        -CIMInstanceName 'AADCrossTenantAccessPolicyB2BSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.B2BDirectConnectInbound = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('B2BDirectConnectInbound') | Out-Null
                    }
                }

                if ($null -ne $Results.B2BDirectConnectOutbound)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'B2BDirectConnectOutbound'
                            CimInstanceName = 'AADCrossTenantAccessPolicyB2BSetting'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Applications'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'UsersAndGroups'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Targets'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.B2BDirectConnectOutbound `
                        -CIMInstanceName 'AADCrossTenantAccessPolicyB2BSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.B2BDirectConnectOutbound = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('B2BDirectConnectOutbound') | Out-Null
                    }
                }

                if ($null -ne $Results.InboundTrust)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.InboundTrust `
                        -CIMInstanceName 'AADCrossTenantAccessPolicyInboundTrust'

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.InboundTrust = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('InboundTrust') | Out-Null
                    }
                }

                if ($null -ne $Results.IdentitySynchronization)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'IdentitySynchronization'
                            CimInstanceName = 'AADCrossTenantIdentitySyncPolicyPartnerInbound'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'GroupSyncInbound'
                            CimInstanceName = 'AADCrossTenantGroupSyncInbound'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'UserSyncInbound'
                            CimInstanceName = 'AADCrossTenantUserSyncInbound'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.IdentitySynchronization `
                        -CIMInstanceName 'AADCrossTenantIdentitySyncPolicyPartnerInbound' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.IdentitySynchronization = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('IdentitySynchronization') | Out-Null
                    }
                }

                if ($null -ne $Results.M365CollaborationInbound)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'M365CollaborationInbound'
                            CimInstanceName = 'AADCrossTenantAccessPolicyM365CollaborationInboundSetting'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Users'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Targets'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.M365CollaborationInbound `
                        -CIMInstanceName 'AADCrossTenantAccessPolicyM365CollaborationInboundSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.M365CollaborationInbound = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('M365CollaborationInbound') | Out-Null
                    }
                }

                if ($null -ne $Results.M365CollaborationOutbound)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'M365CollaborationOutbound'
                            CimInstanceName = 'AADCrossTenantAccessPolicyM365CollaborationOutboundSetting'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'UsersAndGroups'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Targets'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.M365CollaborationOutbound `
                        -CIMInstanceName 'AADCrossTenantAccessPolicyM365CollaborationOutboundSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.M365CollaborationOutbound = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('M365CollaborationOutbound') | Out-Null
                    }
                }

                if ($null -ne $Results.TenantRestrictions)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'Applications'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'UsersAndGroups'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Devices'
                            CimInstanceName = 'AADDevicesFilter'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Targets'
                            CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.TenantRestrictions `
                        -CIMInstanceName 'AADCrossTenantAccessPolicyTenantRestrictions' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.TenantRestrictions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('TenantRestrictions') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('AppServiceConnectInbound', 'B2BCollaborationInbound', 'B2BCollaborationOutbound', 'B2BDirectConnectInbound', 'B2BDirectConnectOutbound', 'InboundTrust', 'AutomaticUserConsentSettings', 'IdentitySynchronization', 'M365CollaborationInbound', 'M365CollaborationOutbound', 'TenantRestrictions')

                # Fix OrganizationName variable in CIMInstance
                $currentDSCBlock = $currentDSCBlock.Replace('@$OrganizationName''', "@' + `$OrganizationName")

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

    hidden [System.Collections.Hashtable] GetAutomaticUserConsentSettings([System.Object] $Setting)
    {
        $result = @{
            InboundAllowed  = $Setting.InboundAllowed
            OutboundAllowed = $Setting.OutboundAllowed
        }

        return $result
    }

    hidden [System.Boolean] TestB2BIsDefault([System.Object] $B2BSetting)
    {
        if ($null -eq $B2BSetting.Applications.AccessType -and `
            $null -eq $B2BSetting.Applications.Target -and `
            $null -eq $B2BSetting.UsersAndGroups.AccessType -and `
            $null -eq $B2BSetting.UsersAndGroups.Target)
        {
            return $true
        }

        return $false
    }

    hidden [System.Collections.Hashtable] GetB2BSetting([System.Object] $Setting)
    {
        #region Applications
        $applications = @{
            AccessType = $Setting.applications.accessType
        }

        if ($null -ne $Setting.applications.targets)
        {
            $targets = @()
            foreach ($currentTarget in $Setting.applications.targets)
            {
                $targets += @{
                    Target     = $currentTarget.target
                    TargetType = $currentTarget.targetType
                }
            }
            $applications.Add('Targets', $targets)
        }
        #endregion

        #region UsersAndGroups
        $usersAndGroups = @{
            AccessType = $Setting.usersAndGroups.accessType
        }

        if ($null -ne $Setting.usersAndGroups.targets)
        {
            $targets = @()
            $user = $null
            $group = $null
            foreach ($currentTarget in $Setting.usersAndGroups.targets)
            {
                if ($currentTarget.targetType -eq 'User')
                {
                    $user = Get-MgUser -UserId $currentTarget.target -ErrorAction SilentlyContinue
                }
                elseif ($currentTarget.targetType -eq 'Group')
                {
                    $group = Get-MgGroup -GroupId $currentTarget.target -ErrorAction SilentlyContinue
                }

                $targetValue = $currentTarget.target
                if ($null -ne $user)
                {
                    $targetValue = $user.UserPrincipalName
                }
                elseif ($null -ne $group)
                {
                    $targetValue = $group.DisplayName
                }
                $targets += @{
                    Target     = $targetValue
                    TargetType = $currentTarget.targetType
                }
            }
            $usersAndGroups.Add('Targets', $targets)
        }
        #endregion
        $results = @{
            Applications   = $applications
            UsersAndGroups = $usersAndGroups
        }

        return $results
    }

    hidden [System.Collections.Hashtable] GetAppServiceConnectSetting([System.Object] $Setting)
    {
        $body = $this.GetB2BSetting($Setting)
        $body.Remove('usersAndGroups')

        return $body
    }

    hidden [System.Collections.Hashtable] GetM365CollaborationInboundSetting([System.Object] $Setting)
    {
        # Targets are external principals that do not exist in the local tenant.
        $users = @{
            accessType = $Setting.Users.AccessType
        }

        if ($null -ne $Setting.Users.Targets)
        {
            $targets = @()
            foreach ($currentTarget in $Setting.Users.Targets)
            {
                $targets += @{
                    target     = $currentTarget.Target
                    targetType = $currentTarget.TargetType
                }
            }
            $users.Add('targets', $targets)
        }

        return @{
            users = $users
        }
    }

    hidden [System.Collections.Hashtable] GetM365CollaborationOutboundSetting([System.Object] $Setting)
    {
        $body = $this.GetB2BSetting($Setting)
        $body.Remove('applications')

        return $body
    }

    hidden [System.Collections.Hashtable] GetIdentitySynchronization([System.Object] $Setting)
    {
        return @{
            groupSyncInbound = @{
                isSyncAllowed = $Setting.GroupSyncInbound.IsSyncAllowed
            }
            userSyncInbound = @{
                isSyncAllowed = $Setting.UserSyncInbound.IsSyncAllowed
            }
        }
    }

    hidden [void] SetIdentitySynchronization([System.String] $PartnerTenantId, [System.Collections.Hashtable] $Value, [System.Boolean] $UsePatch)
    {
        for ($attempt = 1; $attempt -le 6; $attempt++)
        {
            try
            {
                if ($UsePatch)
                {
                    $null = Invoke-M365DSCGraphRequest -Uri "/beta/policies/crossTenantAccessPolicy/partners/$PartnerTenantId/identitySynchronization" `
                        -Method PATCH `
                        -Body $Value `
                        -ErrorAction Stop
                }
                else
                {
                    Set-MgBetaPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization `
                        -CrossTenantAccessPolicyConfigurationPartnerTenantId $PartnerTenantId `
                        -BodyParameter $Value `
                        -ErrorAction Stop
                }
                return
            }
            catch
            {
                $message = "$($_.ErrorDetails.Message) $($_.Exception.Message)"
                if ($attempt -ge 6)
                {
                    throw
                }

                if (-not $UsePatch -and ($message -like '*Conflict*' -or $message -like '*MultipleObjectsWithSameKeyValue*'))
                {
                    $UsePatch = $true
                    continue
                }

                if ($message -notlike '*Directory_ObjectNotFound*' -and $message -notlike '*Not Found*')
                {
                    throw
                }

                $UsePatch = -not $UsePatch
                Start-Sleep -Seconds 5
            }
        }
    }

    hidden [System.Collections.Hashtable] GetTenantRestrictions([System.Object] $Setting)
    {
        $result = $this.GetB2BSetting($Setting)

        if ($null -ne $Setting.Devices.Mode -or $null -ne $Setting.Devices.Rule)
        {
            $result.Add('Devices', @{
                    Mode = $Setting.Devices.Mode
                    Rule = $Setting.Devices.Rule
                })
        }

        return $result
    }

    hidden [System.Collections.Hashtable] UpdateSettingUserIdFromUPN([System.Collections.Hashtable] $Setting)
    {
        if ($null -ne $Setting.UsersAndGroups -and $null -ne $Setting.UsersAndGroups.Targets)
        {
            for ($i = 0; $i -le $Setting.UsersAndGroups.Targets.Length; $i++)
            {
                $user = $Setting.UsersAndGroups.Targets[$i]
                $userValue = $user.Target
                if ($null -ne $userValue)
                {
                    if ($user.TargetType -eq 'User')
                    {
                        Write-Verbose -Message "Detected User type with UPN {$($user.Target)}"
                        $user = Get-MgUser -UserId $user.Target -ErrorAction SilentlyContinue
                        if ($null -ne $user)
                        {
                            $userValue = $user.Id
                        }
                    }
                    elseif ($user.TargetType -eq 'Group')
                    {
                        Write-Verbose -Message "Detected Group type with Name {$($user.Target)}"
                        $group = Get-MgGroup -Filter "DisplayName eq  '$($user.Target)'" -ErrorAction SilentlyContinue
                        if ($null -ne $group)
                        {
                            $userValue = $group.Id
                        }
                    }
                }
                if ($null -ne $userValue)
                {
                    Write-Verbose -Message "Updating principal to Id {$userValue}"
                }
                if ($null -ne $Setting.UsersAndGroups.Targets[$i].Target)
                {
                    $Setting.UsersAndGroups.Targets[$i].Target = $userValue
                }
            }
        }
        return $Setting
    }

    hidden [System.Collections.Hashtable] GetInboundTrust([System.Object] $Setting)
    {
        $result = @{
            IsCompliantDeviceAccepted           = $Setting.isCompliantDeviceAccepted
            IsHybridAzureADJoinedDeviceAccepted = $Setting.isHybridAzureADJoinedDeviceAccepted
            IsMfaAccepted                       = $Setting.isMfaAccepted
        }

        return $result
    }

    hidden [AADCrossTenantAccessPolicyConfigurationPartner] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADCrossTenantAccessPolicyConfigurationPartner])
        {
            return $Values
        }

        $result = [AADCrossTenantAccessPolicyConfigurationPartner]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADCrossTenantAccessPolicyAppServiceConnectSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines the target applications that are allowed for inbound app service connect across tenant boundaries.')]
    [MSFT_AADCrossTenantAccessPolicyTargetConfiguration] $Applications
}

class MSFT_AADCrossTenantAccessPolicyB2BSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('The list of applications targeted with your cross-tenant access policy.')]
    [MSFT_AADCrossTenantAccessPolicyTargetConfiguration] $Applications

    [DscProperty()]
    [System.ComponentModel.Description('The list of users and groups targeted with your cross-tenant access policy.')]
    [MSFT_AADCrossTenantAccessPolicyTargetConfiguration] $UsersAndGroups
}

class MSFT_AADCrossTenantAccessPolicyAutomaticUserConsentSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether you want to automatically trust Inbound invitations.')]
    [System.Nullable[System.Boolean]] $InboundAllowed

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether you want to automatically trust Outbound invitations.')]
    [System.Nullable[System.Boolean]] $OutboundAllowed
}

class MSFT_AADCrossTenantIdentitySyncPolicyPartnerInbound
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines whether groups can be synchronized from a partner tenant. Key.')]
    [MSFT_AADCrossTenantGroupSyncInbound] $GroupSyncInbound

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether you want to automatically trust Outbound invitations.')]
    [MSFT_AADCrossTenantUserSyncInbound] $UserSyncInbound
}

class MSFT_AADCrossTenantAccessPolicyInboundTrust
{
    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether compliant devices from external Azure AD organizations are trusted.')]
    [System.Nullable[System.Boolean]] $IsCompliantDeviceAccepted

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether hybrid Azure AD joined devices from external Azure AD organizations are trusted.')]
    [System.Nullable[System.Boolean]] $IsHybridAzureADJoinedDeviceAccepted

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether MFA from external Azure AD organizations is trusted.')]
    [System.Nullable[System.Boolean]] $IsMfaAccepted
}

class MSFT_AADCrossTenantAccessPolicyM365CollaborationInboundSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines the target users from other organizations who are allowed inbound Microsoft 365 collaboration with your organization.')]
    [MSFT_AADCrossTenantAccessPolicyTargetConfiguration] $Users
}

class MSFT_AADCrossTenantAccessPolicyM365CollaborationOutboundSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines the target users and groups in your organization who are allowed outbound Microsoft 365 collaboration with external organizations.')]
    [MSFT_AADCrossTenantAccessPolicyTargetConfiguration] $UsersAndGroups
}

class MSFT_AADCrossTenantAccessPolicyTenantRestrictions
{
    [DscProperty()]
    [System.ComponentModel.Description('The list of applications targeted with your cross-tenant access policy.')]
    [MSFT_AADCrossTenantAccessPolicyTargetConfiguration] $Applications

    [DscProperty()]
    [System.ComponentModel.Description('Defines the rule for filtering devices and whether devices satisfying the rule should be allowed or blocked. This property isn''t supported on the server side yet.')]
    [MSFT_AADDevicesFilter] $Devices

    [DscProperty()]
    [System.ComponentModel.Description('The list of users and groups targeted with your cross-tenant access policy.')]
    [MSFT_AADCrossTenantAccessPolicyTargetConfiguration] $UsersAndGroups
}

class MSFT_AADCrossTenantAccessPolicyTargetConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines whether access is allowed or blocked. The possible values are: allowed, blocked, unknownFutureValue.')]
    [ValidateSet('allowed', 'blocked', 'unknownFutureValue')]
    [System.String] $AccessType

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to target users, groups, or applications with this rule.')]
    [MSFT_AADCrossTenantAccessPolicyTarget[]] $Targets
}

class MSFT_AADDevicesFilter
{
    [DscProperty()]
    [System.ComponentModel.Description('Determines whether devices that satisfy the rule should be allowed or blocked. The possible values are: allowed, blocked.')]
    [ValidateSet('allowed', 'blocked')]
    [System.String] $Mode

    [DscProperty()]
    [System.ComponentModel.Description('Defines the rule to filter the devices. For example, ''device.deviceAttribute2 -eq ''PrivilegedAccessWorkstation''.')]
    [System.String] $Rule
}

class MSFT_AADCrossTenantGroupSyncInbound
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines whether group objects should be synchronized from the partner tenant. false stops any current group synchronization from the source tenant to the target tenant. This property has no impact on existing groups that were synchronized.')]
    [System.Nullable[System.Boolean]] $IsSyncAllowed
}

class MSFT_AADCrossTenantUserSyncInbound
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines whether user objects should be synchronized from the partner tenant. false causes any current user synchronization from the source tenant to the target tenant to stop. This property has no impact on existing users who have already been synchronized.')]
    [System.Nullable[System.Boolean]] $IsSyncAllowed
}

class MSFT_AADCrossTenantAccessPolicyTarget
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Defines the target for cross-tenant access policy settings and can have one of the following values: The unique identifier of the user, group, or application, AllUsers, AllApplications - Refers to any Microsoft cloud application, Office365 - Includes the applications mentioned as part of the Office 365 suite.')]
    [System.String] $Target

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of resource that you want to target. The possible values are: user, group, application, unknownFutureValue.')]
    [ValidateSet('user', 'group', 'application', 'unknownFutureValue')]
    [System.String] $TargetType
}
