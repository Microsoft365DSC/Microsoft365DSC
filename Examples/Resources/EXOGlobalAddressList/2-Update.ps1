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
        EXOGlobalAddressList 'EXOGlobalAddressList-Example'
        {
            Name                         = "Contoso Human Resources in Washington"
            ConditionalCompany           = "Contoso"
            ConditionalCustomAttribute1  = @("Payroll")
            ConditionalCustomAttribute2  = @("Benefits")
            ConditionalCustomAttribute3  = @("Recruiting")
            ConditionalCustomAttribute4  = @("Onboarding")
            ConditionalCustomAttribute5  = @("Training")
            ConditionalCustomAttribute6  = @("Compensation")
            ConditionalCustomAttribute7  = @("Compliance")
            ConditionalCustomAttribute8  = @("Diversity")
            ConditionalCustomAttribute9  = @("Talent")
            ConditionalCustomAttribute10 = @("Retention")
            ConditionalCustomAttribute11 = @("Wellbeing")
            ConditionalCustomAttribute12 = @("Relocation")
            ConditionalCustomAttribute13 = @("Contractors")
            ConditionalCustomAttribute14 = @("Interns")
            ConditionalCustomAttribute15 = @("Alumni")
            ConditionalDepartment        = "Finances" # Updated Property
            ConditionalStateOrProvince   = "Washington"
            IncludedRecipients           = 'AllRecipients'
            Ensure                       = "Present"
            ApplicationId                = $ApplicationId
            TenantId                     = $TenantId
            CertificateThumbprint        = $CertificateThumbprint
        }
    }
}
