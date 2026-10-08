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
        AADCrossTenantAccessPolicyConfigurationDefault "AADCrossTenantAccessPolicyConfigurationDefault-Example"
        {
            AppServiceConnectInbound           = MSFT_AADCrossTenantAccessPolicyAppServiceConnectSetting {
                Applications = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'blocked'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = 'AllApplications'
                            TargetType = 'application'
                        }
                    )
                }
            }
            AutomaticUserConsentSettings       = MSFT_AADCrossTenantAccessPolicyAutomaticUserConsentSettings {
                InboundAllowed  = $True
                OutboundAllowed = $True
            }
            B2BCollaborationInbound            = MSFT_AADCrossTenantAccessPolicyB2BSetting {
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
                            Target     = 'AllUsers'
                            TargetType = 'user'
                        }
                    )
                }
            }
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
                            Target     = 'AllUsers'
                            TargetType = 'user'
                        }
                    )
                }
            }
            B2BDirectConnectInbound            = MSFT_AADCrossTenantAccessPolicyB2BSetting {
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
            }
            B2BDirectConnectOutbound           = MSFT_AADCrossTenantAccessPolicyB2BSetting {
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
            }
            BlockServiceProviderOutboundAccess = $False;
            Ensure                             = "Present";
            InboundTrust                       = MSFT_AADCrossTenantAccessPolicyInboundTrust {
                IsCompliantDeviceAccepted           = $False
                IsHybridAzureADJoinedDeviceAccepted = $False
                IsMfaAccepted                       = $False
            }
            IsSingleInstance                   = "Yes";
            M365CollaborationInbound           = MSFT_AADCrossTenantAccessPolicyM365CollaborationInboundSetting {
                Users = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'allowed'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = 'AllUsers'
                            TargetType = 'user'
                        }
                    )
                }
            }
            M365CollaborationOutbound          = MSFT_AADCrossTenantAccessPolicyM365CollaborationOutboundSetting {
                UsersAndGroups = MSFT_AADCrossTenantAccessPolicyTargetConfiguration{
                    AccessType = 'allowed'
                    Targets    = @(
                        MSFT_AADCrossTenantAccessPolicyTarget{
                            Target     = 'AllUsers'
                            TargetType = 'user'
                        }
                    )
                }
            }
            ApplicationId                      = $ApplicationId
            TenantId                           = $TenantId
            CertificateThumbprint              = $CertificateThumbprint
        }
    }
}
