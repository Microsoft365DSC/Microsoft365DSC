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
        EXODistributionGroup 'EXODistributionGroup-Example'
        {
            Identity                               = "FieldOperations"
            Name                                   = "FieldOperations"
            Alias                                  = "fieldoperations"
            BccBlocked                             = $false
            BypassModerationFromSendersOrMembers   = @("adeleV@$TenantId")
            BypassNestedModerationEnabled          = $false
            Description                            = "Reaches the field operations team for site scheduling and dispatch requests."
            DisplayName                            = "Field Operations"
            HiddenGroupMembershipEnabled           = $true
            ManagedBy                              = @("adeleV@$TenantId")
            MemberDepartRestriction                = "Open"
            MemberJoinRestriction                  = "Closed"
            Members                                = @("adeleV@$TenantId", "alexW@$TenantId")
            ModeratedBy                            = @("alexW@$TenantId")
            ModerationEnabled                      = $false
            PrimarySmtpAddress                     = "fieldoperations@$TenantId"
            RequireSenderAuthenticationEnabled     = $true
            RoomList                               = $false
            AcceptMessagesOnlyFromSendersOrMembers = @("Executives@$TenantId")
            CustomAttribute1                       = "Field Operations"
            CustomAttribute2                       = "Operations"
            CustomAttribute3                       = "Dispatch"
            CustomAttribute4                       = "Wave 1"
            CustomAttribute5                       = "Onboarded"
            CustomAttribute6                       = "Cost Center 1000"
            CustomAttribute7                       = "Commercial Division"
            CustomAttribute8                       = "Redmond"
            CustomAttribute9                       = "Building 31"
            CustomAttribute10                      = "EMEA"
            CustomAttribute11                      = "Enterprise"
            CustomAttribute12                      = "Aurora"
            CustomAttribute13                      = "Gold"
            CustomAttribute14                      = "English"
            CustomAttribute15                      = "Standard Retention"
            EmailAddresses                         = @("SMTP:fieldoperations@$TenantId", "smtp:field.operations@$TenantId")
            GrantSendOnBehalfTo                    = @("adeleV@$TenantId")
            HiddenFromAddressListsEnabled          = $true
            SendOofMessageToOriginatorEnabled      = $false
            SendModerationNotifications            = "Always"
            Type                                   = "Distribution"
            Ensure                                 = "Present"
            ApplicationId                          = $ApplicationId
            TenantId                               = $TenantId
            CertificateThumbprint                  = $CertificateThumbprint
        }
    }
}
