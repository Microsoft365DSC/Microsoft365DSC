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
        AADPasswordRuleSettings 'AADPasswordRuleSettings-Example'
        {
            IsSingleInstance                    = "Yes"
            LockoutThreshold                    = 6
            LockoutDurationInSeconds            = 30
            BannedPasswordCheckOnPremisesMode   = 'Audit'
            EnableBannedPasswordCheckOnPremises = $false
            EnableBannedPasswordCheck           = $false
            BannedPasswordList                  = $null
            Ensure                              = "Present"
            ApplicationId                       = $ApplicationId
            TenantId                            = $TenantId
            CertificateThumbprint               = $CertificateThumbprint
        }
    }
}
