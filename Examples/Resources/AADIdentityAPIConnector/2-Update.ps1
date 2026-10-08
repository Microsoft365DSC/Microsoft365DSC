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
        AADIdentityAPIConnector 'AADIdentityAPIConnector-Example'
        {
            DisplayName           = "NewTestConnector";
            Id                    = "RestApi_NewTestConnector";
            AuthenticationConfiguration = MSFT_MicrosoftGraphApiAuthenticationConfigurationBase{
                dataType = '#microsoft.graph.basicAuthentication'
                Username = "anexas"
                Password = New-Object System.Management.Automation.PSCredential('api-user', (ConvertTo-SecureString "<api-password>" -AsPlainText -Force))
            };
            TargetUrl             = "https://graph.microsoft.com";
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
