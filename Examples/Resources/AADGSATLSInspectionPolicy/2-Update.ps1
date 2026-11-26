<#
This example updates an existing TLS Inspection Policy in Global Secure Access.
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
        AADGSATLSInspectionPolicy 'AADGSATLSInspectionPolicy-Example'
        {
            Name                  = "Branch Office TLS Inspection"
            Description           = "Inspects encrypted traffic from all branch office locations" # Updated Property
            DefaultAction         = "bypass"
            Rules                 = @(
                MSFT_AADGSATLSInspectionPolicyRule{
                    Name         = "Inspect financial services traffic"
                    Priority     = 100
                    Description  = "Applies deep inspection to financial services destinations"
                    Action       = "inspect"
                    Status       = "enabled"
                    Destinations = @(
                        MSFT_AADGSATLSInspectionPolicyRuleDestination{
                            Type   = "tlsInspectionWebCategoryDestination"
                            Values = @("Finance")
                        }
                    )
                }
            )
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
