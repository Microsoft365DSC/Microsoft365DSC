<#
This example creates a new Planner Task in a Plan.
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
        PlannerTask 'PlannerTask-Example'
        {
            PlanId                = "<planner-plan-id>"
            Title                 = "Contoso Task"
            Categories            = @("Red", "Blue")
            Assignments           = @("admin@$TenantId")
            Attachments           = @(
                MSFT_PlannerTaskAttachment{
                    Alias = "Campaign brief"
                    Uri   = "https://contoso.sharepoint.com/sites/marketing/Shared%20Documents/Campaign%20Brief.docx"
                    Type  = "Word"
                }
            )
            Checklist             = @(
                MSFT_PlannerTaskChecklistItem{
                    Title     = "Collect the regional spend figures"
                    Completed = $true
                }
                MSFT_PlannerTaskChecklistItem{
                    Title     = "Review the numbers with the finance team"
                    Completed = $false
                }
            )
            Description           = "Consolidate the regional marketing spend ahead of the quarterly budget review."
            StartDateTime         = "2026-01-05T08:00:00.0000000Z"
            DueDateTime           = "2026-01-30T17:00:00.0000000Z"
            PercentComplete       = 75
            Priority              = 7
            PreviewType           = "checklist"
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
