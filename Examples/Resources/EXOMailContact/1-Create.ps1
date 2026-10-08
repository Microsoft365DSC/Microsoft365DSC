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
        EXOMailContact 'EXOMailContact-Example'
        {
            Alias                       = 'AlbertoPereira'
            DisplayName                 = 'Alberto Pereira'
            Ensure                      = 'Present'
            ExternalEmailAddress        = 'SMTP:orders@tailspintoys.com'
            FirstName                   = 'Alberto'
            Initials                    = 'R'
            LastName                    = 'Pereira'
            MacAttachmentFormat         = 'BinHex'
            MessageBodyFormat           = 'TextAndHtml'
            MessageFormat               = 'Mime'
            ModeratedBy                 = @()
            ModerationEnabled           = $false
            Name                        = 'Tailspin Toys Orders'
            OrganizationalUnit          = $TenantId
            SendModerationNotifications = 'Always'
            UsePreferMessageFormat      = $true
            CustomAttribute1            = 'Supplier'
            CustomAttribute2            = 'Toys and Games'
            CustomAttribute3            = 'Tailspin Toys'
            CustomAttribute4            = 'North America'
            CustomAttribute5            = 'Seattle'
            CustomAttribute6            = 'Procurement'
            CustomAttribute7            = 'Net 30'
            CustomAttribute8            = 'Preferred'
            CustomAttribute9            = 'Wholesale'
            CustomAttribute10           = 'English'
            CustomAttribute11           = 'Pacific Standard Time'
            CustomAttribute12           = 'Contract 4471'
            CustomAttribute13           = 'Renews 2027'
            CustomAttribute14           = 'Account Management'
            CustomAttribute15           = 'Active'
            ExtensionCustomAttribute1   = @("Product Catalogue")
            ExtensionCustomAttribute2   = @("Product Catalogue", "Price List")
            ExtensionCustomAttribute3   = @("Order Confirmations", "Shipping Notices")
            ExtensionCustomAttribute4   = @("Trade Shows", "Partner Webinars")
            ExtensionCustomAttribute5   = @("Quarterly Business Review", "Annual Supplier Summit")
            ApplicationId               = $ApplicationId
            TenantId                    = $TenantId
            CertificateThumbprint       = $CertificateThumbprint
        }
    }
}
