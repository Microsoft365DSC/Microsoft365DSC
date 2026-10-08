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
        IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10 'IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10-Example'
        {
            Assignments                      = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments
                {
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments
                {
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                }
            )
            DefinitionValues                 = @(
                MSFT_IntuneGroupPolicyDefinitionValue
                {
                    ConfigurationType = 'policy'
                    Id                = 'f41bbbec-0807-4ae3-8a61-5580a2f310f0'
                    Definition        = MSFT_IntuneGroupPolicyDefinitionValueDefinition
                    {
                        Id           = '50b2626d-f092-4e71-8983-12a5c741ebe0'
                        DisplayName  = 'Do not display the lock screen'
                        CategoryPath = '\Control Panel\Personalization'
                        PolicyType   = 'admxBacked'
                        SupportedOn  = 'At least Windows Server 2012, Windows 8 or Windows RT'
                        ClassType    = 'machine'
                    }
                    Enabled           = $False
                }
                MSFT_IntuneGroupPolicyDefinitionValue
                {
                    ConfigurationType  = 'policy'
                    PresentationValues = @(
                        MSFT_IntuneGroupPolicyDefinitionValuePresentationValue
                        {
                            presentationDefinitionId    = '98210829-af9b-4020-8d96-3e4108557a95'
                            presentationDefinitionLabel = 'Types of extensions/apps that are allowed to be installed'
                            KeyValuePairValues          = @(
                                MSFT_IntuneGroupPolicyDefinitionValuePresentationValueKeyValuePair
                                {
                                    Name = 'hosted_app'
                                }

                                MSFT_IntuneGroupPolicyDefinitionValuePresentationValueKeyValuePair
                                {
                                    Name = 'user_script'
                                }
                            )
                            Id                          = '7312a452-e087-4290-9b9f-3f14a304c18d'
                            odataType                   = '#microsoft.graph.groupPolicyPresentationValueList'
                        }
                    )
                    Id                 = 'f3047f6a-550e-4b5e-b3da-48fc951b72fc'
                    Definition         = MSFT_IntuneGroupPolicyDefinitionValueDefinition
                    {
                        Id           = '37ab8b81-47d7-46d8-8b99-81d9cecdcce9'
                        DisplayName  = 'Configure allowed app/extension types'
                        CategoryPath = '\Google\Google Chrome\Extensions'
                        PolicyType   = 'admxIngested'
                        SupportedOn  = 'Microsoft Windows 7 or later'
                        ClassType    = 'machine'
                    }
                    Enabled            = $True
                }
                MSFT_IntuneGroupPolicyDefinitionValue
                {
                    ConfigurationType  = 'policy'
                    PresentationValues = @(
                        MSFT_IntuneGroupPolicyDefinitionValuePresentationValue
                        {
                            presentationDefinitionId    = 'a8a0ae11-58d9-41d5-b258-1c16d9f1e328'
                            presentationDefinitionLabel = 'Password Length'
                            DecimalValue                = 15
                            Id                          = '14c48993-35af-4b77-a4f8-12de917b1bb9'
                            odataType                   = '#microsoft.graph.groupPolicyPresentationValueDecimal'
                        }

                        MSFT_IntuneGroupPolicyDefinitionValuePresentationValue
                        {
                            presentationDefinitionId    = '98998e7f-cc2a-4d96-8c47-35dd4b2ce56b'
                            presentationDefinitionLabel = 'Password Age (Days)'
                            DecimalValue                = 30
                            Id                          = '4d654df9-6826-470f-af4e-d37491663c76'
                            odataType                   = '#microsoft.graph.groupPolicyPresentationValueDecimal'
                        }

                        MSFT_IntuneGroupPolicyDefinitionValuePresentationValue
                        {
                            presentationDefinitionId    = '6900e752-4bc3-463b-9fc8-36d78c77bc3e'
                            presentationDefinitionLabel = 'Password Complexity'
                            StringValue                 = '4'
                            Id                          = '17e2ff15-8573-4e7e-a6f9-64baebcb5312'
                            odataType                   = '#microsoft.graph.groupPolicyPresentationValueText'
                        }
                    )
                    Id                 = '426c9e99-0084-443a-ae07-b8f40c11910f'
                    Definition         = MSFT_IntuneGroupPolicyDefinitionValueDefinition
                    {
                        Id           = 'c4df131a-d415-44fc-9254-a717ff7dbee3'
                        DisplayName  = 'Password Settings'
                        CategoryPath = '\LAPS'
                        PolicyType   = 'admxBacked'
                        SupportedOn  = 'At least Microsoft Windows Vista or Windows Server 2003 family'
                        ClassType    = 'machine'
                    }
                    Enabled            = $True
                }
                MSFT_IntuneGroupPolicyDefinitionValue
                {
                    ConfigurationType = 'policy'
                    Id                = 'a3577119-b240-4093-842c-d8e959dfe317'
                    Definition        = MSFT_IntuneGroupPolicyDefinitionValueDefinition
                    {
                        Id           = '986073b6-e149-495f-a131-aa0e3c697225'
                        DisplayName  = 'Ability to change properties of an all user remote access connection'
                        CategoryPath = '\Network\Network Connections'
                        PolicyType   = 'admxBacked'
                        SupportedOn  = 'At least Windows 2000 Service Pack 1'
                        ClassType    = 'user'
                    }
                    Enabled           = $True
                }
            )
            Description                      = ''
            DisplayName                      = 'admin template'
            Ensure                           = 'Present'
            PolicyConfigurationIngestionType = 'unknown'
            ApplicationId                    = $ApplicationId;
            TenantId                         = $TenantId;
            CertificateThumbprint            = $CertificateThumbprint;
        }
    }
}
