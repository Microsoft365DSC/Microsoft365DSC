<#
This example creates a new Device Enrollment Limit Restriction.
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
        IntuneDeviceEnrollmentLimitRestriction 'IntuneDeviceEnrollmentLimitRestriction-Example'
        {
            Assignments           = @()
            DisplayName           = 'Standard Enrollment Limit'
            Description           = 'Maximum number of devices a standard employee may enroll'
            Limit                 = 11 # Updated Property
            Priority              = 1
            Ensure                = 'Present'
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
