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
        AADUser 'AADUser-Example'
        {
            UserPrincipalName     = "John.Smith@$TenantId"
            GivenName             = "John"
            Surname               = "Smith"
            DisplayName           = "John J. Smith"
            AgeGroup              = "Adult"
            City                  = "Ottawa" # Updated Property
            Country               = "Canada"
            OfficeLocation        = "Ottawa - Queen"
            UsageLocation         = "US"
            CustomSecurityAttributes = @(
                MSFT_AADUserAttributeSet{
                    AttributeSetName = 'Engineering'
                    AttributeValues  = @(
                        MSFT_AADUserAttributeValue{
                            AttributeName    = 'Skills'
                            StringArrayValue = @('PowerShell', 'Networking', 'Security') # Updated Property
                        }
                        MSFT_AADUserAttributeValue{
                            AttributeName = 'Datacenter'
                            StringValue   = 'Portland' # Updated Property
                        }
                    )
                }
            )
            OnPremisesExtensionAttributes = MSFT_AADUserOnPremisesExtensionAttributes{
                ExtensionAttribute1 = "Head Office"
                ExtensionAttribute2 = "Cost Center 4100"
            }
            AccountEnabled        = $true
            CompanyName           = "Contoso"
            Department            = "Human Resources"
            EmployeeHireDate      = "2026-01-01T00:00:00.0000000Z"
            EmployeeId            = "E1234567"
            EmployeeLeaveDateTime = "2027-06-30T00:00:00.0000000Z"
            EmployeeType          = "Employee"
            JobTitle              = "Senior Program Manager"
            StreetAddress         = "100 Rue Principale"
            State                 = "Quebec"
            PostalCode            = "K1A 0B1"
            PhoneNumber           = "+1 613 555 0100"
            MobilePhone           = "+1 613 555 0177"
            FaxNumber             = "+1 613 555 0143"
            OtherMails            = @("john.smith.contoso@outlook.com")
            PreferredLanguage     = "en-US"
            PasswordPolicies      = "DisablePasswordExpiration"
            UserType              = "Member"
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
