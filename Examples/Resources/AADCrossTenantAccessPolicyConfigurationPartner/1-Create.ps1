<#
This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.
#>

Configuration Example
{
    param
    (
        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )

    Import-DscResource -ModuleName Microsoft365DSC

    Node localhost
    {
        AADCrossTenantAccessPolicyConfigurationPartner "AADCrossTenantAccessPolicyConfigurationPartner-Example"
        {
            PartnerTenantId                    = "e7a80bcf-696e-40ca-8775-a7f85fbb3ebc"; # fabrikam.onmicrosoft.com
            AppServiceConnectInbound           = MSFT_AADCrossTenantAccessPolicyAppServiceConnectSetting{
                Applications = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'allowed'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = 'Office365'
                            TargetType = 'application'
                        }
                    )
                }
            };
            AutomaticUserConsentSettings       = MSFT_AADCrossTenantAccessPolicyAutomaticUserConsentSettings {
                InboundAllowed  = $True
                OutboundAllowed = $True
            };
            B2BCollaborationOutbound           = MSFT_AADCrossTenantAccessPolicyB2BSetting {
                Applications   = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'allowed'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = 'AllApplications'
                            TargetType = 'application'
                        }
                    )
                }
                UsersAndGroups = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'allowed'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = '68bafe64-f86b-4c4e-b33b-9d3eaa11544b' # Office 365
                            TargetType = 'user'
                        }
                    )
                }
            };
            B2BCollaborationInbound            = MSFT_AADCrossTenantAccessPolicyB2BSetting{
                Applications   = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'allowed'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = 'AllApplications'
                            TargetType = 'application'
                        }
                    )
                }
                UsersAndGroups = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'allowed'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = '68bafe64-f86b-4c4e-b33b-9d3eaa11544b'
                            TargetType = 'user'
                        }
                    )
                }
            };
            B2BDirectConnectInbound            = MSFT_AADCrossTenantAccessPolicyB2BSetting{
                Applications   = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'blocked'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = 'AllApplications'
                            TargetType = 'application'
                        }
                    )
                }
                UsersAndGroups = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'blocked'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = 'AllUsers'
                            TargetType = 'user'
                        }
                    )
                }
            };
            B2BDirectConnectOutbound           = MSFT_AADCrossTenantAccessPolicyB2BSetting{
                Applications   = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'blocked'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = 'AllApplications'
                            TargetType = 'application'
                        }
                    )
                }
                UsersAndGroups = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'blocked'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = 'AllUsers'
                            TargetType = 'user'
                        }
                    )
                }
            };
            IdentitySynchronization            = MSFT_AADCrossTenantIdentitySyncPolicyPartnerInbound{
                GroupSyncInbound = MSFT_AADCrossTenantGroupSyncInbound{
                    IsSyncAllowed = $False
                }
                UserSyncInbound  = MSFT_AADCrossTenantUserSyncInbound{
                    IsSyncAllowed = $True
                }
            };
            InboundTrust                       = MSFT_AADCrossTenantAccessPolicyInboundTrust{
                IsCompliantDeviceAccepted           = $True
                IsHybridAzureADJoinedDeviceAccepted = $True
                IsMfaAccepted                       = $True
            };
            M365CollaborationInbound           = MSFT_AADCrossTenantAccessPolicyM365CollaborationInboundSetting{
                Users = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'allowed'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = 'AllUsers'
                            TargetType = 'user'
                        }
                    )
                }
            };
            M365CollaborationOutbound          = MSFT_AADCrossTenantAccessPolicyM365CollaborationOutboundSetting{
                UsersAndGroups = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'allowed'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = 'AllUsers'
                            TargetType = 'user'
                        }
                    )
                }
            };
            TenantRestrictions                 = MSFT_AADCrossTenantAccessPolicyTenantRestrictions{
                Applications   = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'blocked'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = 'AllApplications'
                            TargetType = 'application'
                        }
                    )
                }
                UsersAndGroups = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'blocked'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = 'AllUsers'
                            TargetType = 'user'
                        }
                    )
                }
            };
            Ensure                             = "Present";
            ApplicationId                      = $ApplicationId
            TenantId                           = $TenantId
            CertificateThumbprint              = $CertificateThumbprint
        }
    }
}
