<#
This example creates a new Device and App Management Assignment Filter.
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
        IntuneDeviceAndAppManagementAssignmentFilter 'IntuneDeviceAndAppManagementAssignmentFilter-Example'
        {
            DisplayName                    = 'Corporate Windows Devices'
            Description                    = 'Targets company-owned Windows desktops and laptops'
            AssignmentFilterManagementType = 'devices'
            Platform                       = 'windows10AndLater'
            RoleScopeTags                  = @("0")
            Rule                           = "(device.manufacturer -ne `"Microsoft Corporation`")"
            Ensure                         = 'Present'
            ApplicationId                  = $ApplicationId;
            TenantId                       = $TenantId;
            CertificateThumbprint          = $CertificateThumbprint;
        }
    }
}
