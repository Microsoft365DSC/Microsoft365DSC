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
        SCSensitivityLabel 'SCSensitivityLabel-Example'
        {
            Name                                           = "Finance Confidential"
            Comment                                        = "Applied to internal business documents and customer records" # Updated Property
            ToolTip                                        = "Use for information that must stay inside the company"
            DisplayName                                    = "Finance Confidential"
            Priority                                       = 0
            ContentType                                    = @("File", "Email", "Site", "UnifiedGroup")
            ApplyContentMarkingFooterAlignment             = "Center"
            ApplyContentMarkingFooterEnabled               = $true
            ApplyContentMarkingFooterFontColor             = "#FF0000"
            ApplyContentMarkingFooterFontSize              = 10
            ApplyContentMarkingFooterMargin                = 5
            ApplyContentMarkingFooterText                  = "Contoso Confidential"
            ApplyContentMarkingHeaderAlignment             = "Center"
            ApplyContentMarkingHeaderEnabled               = $true
            ApplyContentMarkingHeaderFontColor             = "#FF0000"
            ApplyContentMarkingHeaderFontSize              = 10
            ApplyContentMarkingHeaderMargin                = 5
            ApplyContentMarkingHeaderText                  = "Confidential - Do Not Distribute"
            ApplyWaterMarkingEnabled                       = $true
            ApplyWaterMarkingFontColor                     = "#FF0000"
            ApplyWaterMarkingFontSize                      = 10
            ApplyWaterMarkingLayout                        = "Diagonal"
            ApplyWaterMarkingText                          = "Confidential"
            EncryptionEnabled                              = $true
            EncryptionProtectionType                       = "Template"
            EncryptionRightsDefinitions                    = "contoso.com:VIEW,VIEWRIGHTSDATA,DOCEDIT,EDIT,PRINT,EXTRACT,REPLY,REPLYALL,FORWARD"
            EncryptionOfflineAccessDays                    = 30
            EncryptionContentExpiredOnDateInDaysOrNever    = "Never"
            SiteAndGroupProtectionAllowAccessToGuestUsers  = $true
            SiteAndGroupProtectionAllowEmailFromGuestUsers = $true
            SiteAndGroupProtectionAllowFullAccess          = $true
            SiteAndGroupProtectionAllowLimitedAccess       = $false
            SiteAndGroupProtectionBlockAccess              = $false
            SiteAndGroupProtectionEnabled                  = $true
            SiteAndGroupProtectionPrivacy                  = "Private"
            SiteAndGroupExternalSharingControlType         = "ExternalUserSharingOnly"
            LocaleSettings                                 = @(
                MSFT_SCLabelLocaleSettings{
                    LocaleKey     = "DisplayName"
                    LabelSettings = @(
                        MSFT_SCLabelSetting{
                            Key   = "en-us"
                            Value = "Finance Confidential"
                        }
                        MSFT_SCLabelSetting{
                            Key   = "fr-fr"
                            Value = "Finance confidentiel"
                        }
                    )
                }
                MSFT_SCLabelLocaleSettings{
                    LocaleKey     = "Tooltip"
                    LabelSettings = @(
                        MSFT_SCLabelSetting{
                            Key   = "en-us"
                            Value = "Use for information that must stay inside the company"
                        }
                        MSFT_SCLabelSetting{
                            Key   = "fr-fr"
                            Value = "A utiliser pour les informations qui doivent rester dans l'entreprise"
                        }
                    )
                }
            )
            AdvancedSettings                               = @(
                MSFT_SCLabelSetting{
                    Key   = "color"
                    Value = "#40e0d0"
                }
                MSFT_SCLabelSetting{
                    Key   = "DefaultSharingScope"
                    Value = "SpecificPeople"
                }
            )
            AutoLabelingSettings                           = MSFT_SCSLAutoLabelingSettings{
                Operator      = "And"
                AutoApplyType = "Recommend"
                PolicyTip     = "This document contains financial data and will be labelled Confidential."
                Groups        = @(
                    MSFT_SCSLSensitiveInformationGroup{
                        Name                     = "Financial account details"
                        Operator                 = "Or"
                        SensitiveInformationType = @(
                            MSFT_SCSLSensitiveInformationType{
                                name            = "ABA Routing Number"
                                confidencelevel = "High"
                                maxcount        = "-1"
                                mincount        = "1"
                            }
                        )
                        TrainableClassifier      = @(
                            MSFT_SCSLTrainableClassifiers{
                                name = "Finance"
                            }
                        )
                    }
                    MSFT_SCSLSensitiveInformationGroup{
                        Name                     = "Customer identity details"
                        Operator                 = "And"
                        SensitiveInformationType = @(
                            MSFT_SCSLSensitiveInformationType{
                                name            = "All Full Names"
                                confidencelevel = "High"
                                maxcount        = "100"
                                mincount        = "10"
                            }
                        )
                        TrainableClassifier      = @(
                            MSFT_SCSLTrainableClassifiers{
                                name = "Legal Affairs"
                            }
                        )
                    }
                )
            }
            Ensure                                         = "Present"
            ApplicationId                                  = $ApplicationId
            TenantId                                       = $TenantId
            CertificateThumbprint                          = $CertificateThumbprint
        }
    }
}
