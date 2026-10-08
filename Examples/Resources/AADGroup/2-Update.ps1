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
        AADGroup 'AADGroup-Example'
        {
            DisplayName                         = "Marketing Team"
            Description                         = "Collaboration group for the marketing and communications departments" # Updated Property
            SecurityEnabled                     = $True
            MailEnabled                         = $True
            GroupTypes                          = @("Unified")
            MailNickname                        = "MarketingTeam"
            Members                             = @("AdeleV@$TenantId") # Updated Property
            Visibility                          = "Private"
            Theme                               = "Blue"
            Owners                              = @("MeganB@$TenantId", "AdeleV@$TenantId")
            WritebackConfiguration              = MSFT_MicrosoftGraphGroupWritebackConfiguration{
                IsEnabled           = $true
                OnPremisesGroupType = "universalDistributionGroup"
            }
            AssignedToRole                      = @()
            IsAssignableToRole                  = $false
            GroupLifecyclePolicySelectedEnabled = $false
            Ensure                              = "Present"
            ApplicationId                       = $ApplicationId
            TenantId                            = $TenantId
            CertificateThumbprint               = $CertificateThumbprint
        }
    }
}
