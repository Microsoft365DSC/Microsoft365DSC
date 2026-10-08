[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
    -ChildPath '..\..\Unit' `
    -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Microsoft365.psm1' `
        -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Generic.psm1' `
        -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\UnitTestHelper.psm1' `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource 'EXOHostedContentFilterPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName New-HostedContentFilterPolicy -MockWith {
            }

            Mock -CommandName Set-HostedContentFilterPolicy -MockWith {
            }

            Mock -CommandName Remove-HostedContentFilterPolicy -MockWith {
            }

            Mock -CommandName Get-HostedContentFilterPolicy -MockWith {
                return @{
                    Identity                             = 'TestPolicy'
                    AdminDisplayName                     = 'This ContentFilter policiy is a test'
                    AddXHeaderValue                      = 'MyCustomSpamHeader'
                    ModifySubjectValue                   = 'SPAM!'
                    RedirectToRecipients                 = @()
                    TestModeBccToRecipients              = @()
                    QuarantineRetentionPeriod            = 15
                    TestModeAction                       = 'AddXHeader'
                    IncreaseScoreWithImageLinks          = 'Off'
                    IncreaseScoreWithNumericIps          = 'On'
                    IncreaseScoreWithRedirectToOtherPort = 'On'
                    IncreaseScoreWithBizOrInfoUrls       = 'On'
                    IntraOrgFilterState                  = 'Default'
                    MarkAsSpamEmptyMessages              = 'On'
                    MarkAsSpamJavaScriptInHtml           = 'On'
                    MarkAsSpamFramesInHtml               = 'On'
                    MarkAsSpamObjectTagsInHtml           = 'On'
                    MarkAsSpamEmbedTagsInHtml            = 'Off'
                    MarkAsSpamFormTagsInHtml             = 'Off'
                    MarkAsSpamWebBugsInHtml              = 'On'
                    MarkAsSpamSensitiveWordList          = 'Test'
                    MarkAsSpamSpfRecordHardFail          = 'On'
                    MarkAsSpamFromAddressAuthFail        = 'On'
                    MarkAsSpamBulkMail                   = 'On'
                    MarkAsSpamNdrBackscatter             = 'On'
                    LanguageBlockList                    = @('AF', 'SQ', 'AR', 'HY', 'AZ', 'EU', 'BE', 'BN', 'BS', 'BR', 'BG', 'CA', 'ZH-CN', 'ZH-TW', 'HR', 'CS', 'DA', 'NL', 'EO', 'ET', 'FO', 'TL', 'FI', 'FR', 'FY', 'GL', 'KA', 'DE', 'EL', 'KL', 'GU', 'HA', 'HE', 'HI', 'HU', 'IS', 'ID', 'GA', 'ZU', 'IT', 'JA', 'KN', 'KK', 'SW', 'KO', 'KU', 'KY', 'LA', 'LV', 'LT', 'LB', 'MK', 'MS', 'ML', 'MT', 'MI', 'MR', 'MN', 'NB', 'NN', 'PS', 'FA', 'PL', 'PT', 'PA', 'RO', 'RM', 'RU', 'SE', 'SR', 'SK', 'SL', 'WEN', 'SV', 'TA', 'TE', 'TH', 'TR', 'UK', 'UR', 'UZ', 'VI', 'CY', 'YI')
                    RegionBlockList                      = @('AF', 'AX', 'AL', 'DZ', 'AS', 'AD', 'AO', 'AI', 'AQ', 'AG', 'AR', 'AM', 'AW', 'AU', 'AT', 'AZ', 'BS', 'BH', 'BD', 'BB', 'BY', 'BE', 'BZ', 'BJ', 'BM', 'BT', 'BO', 'BQ', 'BA', 'BW', 'BV', 'BR', 'IO', 'VG', 'BN', 'BG', 'BF', 'BI', 'CV', 'KH', 'CM', 'KY', 'CF', 'TD', 'CL', 'CN', 'CX', 'CC', 'CO', 'KM', 'CG', 'CD', 'CK', 'CR', 'CI', 'HR', 'CU', 'CW', 'CY', 'CZ', 'DK', 'DJ', 'DM', 'DO', 'EC', 'EG', 'SV', 'GQ', 'ER', 'EE', 'ET', 'FK', 'FO', 'FJ', 'FI', 'FR', 'GF', 'PF', 'TF', 'GA', 'GM', 'GE', 'DE', 'GH', 'GI', 'GR', 'GL', 'GD', 'GP', 'GU', 'GT', 'GG', 'GN', 'GW', 'GY', 'HT', 'HM', 'VA', 'HN', 'HK', 'HU', 'IS', 'IN', 'ID', 'IR', 'IQ', 'IE', 'IM', 'IL', 'IT', 'JM', 'XJ', 'SJ', 'JP', 'JE', 'JO', 'KZ', 'KE', 'KI', 'KR', 'KW', 'KG', 'LA', 'LV', 'LB', 'LS', 'LR', 'LY', 'LI', 'LT', 'LU', 'MO', 'MK', 'MG', 'MW', 'MY', 'MV', 'ML', 'MT', 'MH', 'MQ', 'MR', 'MU', 'YT', 'FM', 'MD', 'MC', 'MN', 'ME', 'MS', 'MA', 'MZ', 'MM', 'NA', 'NR', 'NP', 'NL', 'NC', 'NZ', 'NI', 'NE', 'NG', 'NU', 'NF', 'KP', 'MP', 'NO', 'OM', 'PK', 'PW', 'PS', 'PA', 'PG', 'PY', 'PE', 'PH', 'PN', 'PL', 'PT', 'PR', 'QA', 'RE', 'RO', 'RU', 'RW', 'XS', 'BL', 'SH', 'KN', 'LC', 'MF', 'PM', 'VC', 'WS', 'SM', 'ST', 'SA', 'SN', 'RS', 'SC', 'SL', 'SG', 'XE', 'SX', 'SK', 'SI', 'SB', 'SO', 'ZA', 'GS', 'ES', 'LK', 'SD', 'SR', 'SZ', 'SE', 'CH', 'SY', 'TW', 'TJ', 'TZ', 'TH', 'TL', 'TG', 'TK', 'TO', 'TT', 'TN', 'TR', 'TM', 'TC', 'TV', 'UG', 'UA', 'AE', 'UY', 'UZ', 'VU', 'VE', 'VN', 'WF', 'YE', 'ZM', 'ZW')
                    HighConfidencePhishAction            = 'Quarantine'
                    HighConfidenceSpamAction             = 'Quarantine'
                    SpamAction                           = 'MoveToJmf'
                    DownloadLink                         = $false
                    EnableRegionBlockList                = $true
                    EnableLanguageBlockList              = $true
                    BulkThreshold                        = 5
                    AllowedSenders                       = @{
                        Sender = @(
                            [PSCustomObject]@{Address = 'test@contoso.com' },
                            [PSCustomObject]@{Address = 'test@fabrikam.com' }
                        )
                    }
                    AllowedSenderDomains                 = @(
                        [PSCustomObject]@{Domain = 'contoso.com' },
                        [PSCustomObject]@{Domain = 'fabrikam.com' }
                    )
                    BlockedSenders                       = @{
                        Sender = @(
                            [PSCustomObject]@{Address = 'me@privacy.net' },
                            [PSCustomObject]@{Address = 'thedude@contoso.com' }
                        )
                    }
                    BlockedSenderDomains                 = @(
                        [PSCustomObject]@{Domain = 'privacy.net' },
                        [PSCustomObject]@{Domain = 'facebook.com' }
                    )
                    PhishZapEnabled                      = $true
                    SpamZapEnabled                       = $true
                    InlineSafetyTipsEnabled              = $true
                    BulkSpamAction                       = 'MoveToJmf'
                    PhishSpamAction                      = 'Quarantine'
                    IsDefault                            = $false
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'HostedContentFilterPolicy creation.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                               = 'Present'
                    Identity                             = 'TestPolicy'
                    Credential                           = $Credential
                    AdminDisplayName                     = 'This ContentFilter policiy is a test'
                    AddXHeaderValue                      = 'MyCustomSpamHeader'
                    ModifySubjectValue                   = 'SPAM!'
                    RedirectToRecipients                 = @()
                    TestModeBccToRecipients              = @()
                    QuarantineRetentionPeriod            = 15
                    TestModeAction                       = 'AddXHeader'
                    IncreaseScoreWithImageLinks          = 'Off'
                    IncreaseScoreWithNumericIps          = 'On'
                    IncreaseScoreWithRedirectToOtherPort = 'On'
                    IncreaseScoreWithBizOrInfoUrls       = 'On'
                    IntraOrgFilterState                  = 'Default'
                    MarkAsSpamEmptyMessages              = 'On'
                    MarkAsSpamJavaScriptInHtml           = 'On'
                    MarkAsSpamFramesInHtml               = 'On'
                    MarkAsSpamObjectTagsInHtml           = 'On'
                    MarkAsSpamEmbedTagsInHtml            = 'Off'
                    MarkAsSpamFormTagsInHtml             = 'Off'
                    MarkAsSpamWebBugsInHtml              = 'On'
                    MarkAsSpamSensitiveWordList          = 'Test'
                    MarkAsSpamSpfRecordHardFail          = 'On'
                    MarkAsSpamFromAddressAuthFail        = 'On'
                    MarkAsSpamBulkMail                   = 'On'
                    MarkAsSpamNdrBackscatter             = 'On'
                    LanguageBlockList                    = @('AF', 'SQ', 'AR', 'HY', 'AZ', 'EU', 'BE', 'BN', 'BS', 'BR', 'BG', 'CA', 'ZH-CN', 'ZH-TW', 'HR', 'CS', 'DA', 'NL', 'EO', 'ET', 'FO', 'TL', 'FI', 'FR', 'FY', 'GL', 'KA', 'DE', 'EL', 'KL', 'GU', 'HA', 'HE', 'HI', 'HU', 'IS', 'ID', 'GA', 'ZU', 'IT', 'JA', 'KN', 'KK', 'SW', 'KO', 'KU', 'KY', 'LA', 'LV', 'LT', 'LB', 'MK', 'MS', 'ML', 'MT', 'MI', 'MR', 'MN', 'NB', 'NN', 'PS', 'FA', 'PL', 'PT', 'PA', 'RO', 'RM', 'RU', 'SE', 'SR', 'SK', 'SL', 'WEN', 'SV', 'TA', 'TE', 'TH', 'TR', 'UK', 'UR', 'UZ', 'VI', 'CY', 'YI')
                    RegionBlockList                      = @('AF', 'AX', 'AL', 'DZ', 'AS', 'AD', 'AO', 'AI', 'AQ', 'AG', 'AR', 'AM', 'AW', 'AU', 'AT', 'AZ', 'BS', 'BH', 'BD', 'BB', 'BY', 'BE', 'BZ', 'BJ', 'BM', 'BT', 'BO', 'BQ', 'BA', 'BW', 'BV', 'BR', 'IO', 'VG', 'BN', 'BG', 'BF', 'BI', 'CV', 'KH', 'CM', 'KY', 'CF', 'TD', 'CL', 'CN', 'CX', 'CC', 'CO', 'KM', 'CG', 'CD', 'CK', 'CR', 'CI', 'HR', 'CU', 'CW', 'CY', 'CZ', 'DK', 'DJ', 'DM', 'DO', 'EC', 'EG', 'SV', 'GQ', 'ER', 'EE', 'ET', 'FK', 'FO', 'FJ', 'FI', 'FR', 'GF', 'PF', 'TF', 'GA', 'GM', 'GE', 'DE', 'GH', 'GI', 'GR', 'GL', 'GD', 'GP', 'GU', 'GT', 'GG', 'GN', 'GW', 'GY', 'HT', 'HM', 'VA', 'HN', 'HK', 'HU', 'IS', 'IN', 'ID', 'IR', 'IQ', 'IE', 'IM', 'IL', 'IT', 'JM', 'XJ', 'SJ', 'JP', 'JE', 'JO', 'KZ', 'KE', 'KI', 'KR', 'KW', 'KG', 'LA', 'LV', 'LB', 'LS', 'LR', 'LY', 'LI', 'LT', 'LU', 'MO', 'MK', 'MG', 'MW', 'MY', 'MV', 'ML', 'MT', 'MH', 'MQ', 'MR', 'MU', 'YT', 'FM', 'MD', 'MC', 'MN', 'ME', 'MS', 'MA', 'MZ', 'MM', 'NA', 'NR', 'NP', 'NL', 'NC', 'NZ', 'NI', 'NE', 'NG', 'NU', 'NF', 'KP', 'MP', 'NO', 'OM', 'PK', 'PW', 'PS', 'PA', 'PG', 'PY', 'PE', 'PH', 'PN', 'PL', 'PT', 'PR', 'QA', 'RE', 'RO', 'RU', 'RW', 'XS', 'BL', 'SH', 'KN', 'LC', 'MF', 'PM', 'VC', 'WS', 'SM', 'ST', 'SA', 'SN', 'RS', 'SC', 'SL', 'SG', 'XE', 'SX', 'SK', 'SI', 'SB', 'SO', 'ZA', 'GS', 'ES', 'LK', 'SD', 'SR', 'SZ', 'SE', 'CH', 'SY', 'TW', 'TJ', 'TZ', 'TH', 'TL', 'TG', 'TK', 'TO', 'TT', 'TN', 'TR', 'TM', 'TC', 'TV', 'UG', 'UA', 'AE', 'UY', 'UZ', 'VU', 'VE', 'VN', 'WF', 'YE', 'ZM', 'ZW')
                    HighConfidencePhishAction            = 'Quarantine'
                    HighConfidenceSpamAction             = 'Quarantine'
                    SpamAction                           = 'MoveToJmf'
                    EnableRegionBlockList                = $true
                    EnableLanguageBlockList              = $true
                    BulkThreshold                        = 5
                    AllowedSenders                       = @('test@contoso.com', 'test@fabrikam.com')
                    AllowedSenderDomains                 = @('contoso.com', 'fabrikam.com')
                    BlockedSenders                       = @('me@privacy.net', 'thedude@contoso.com')
                    BlockedSenderDomains                 = @('privacy.net', 'facebook.com')
                    PhishZapEnabled                      = $true
                    SpamZapEnabled                       = $true
                    InlineSafetyTipsEnabled              = $true
                    BulkSpamAction                       = 'MoveToJmf'
                    PhishSpamAction                      = 'Quarantine'
                    MakeDefault                          = $false
                }

                Mock -CommandName Get-HostedContentFilterPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedContentFilterPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedContentFilterPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-HostedContentFilterPolicy -Exactly 1
            }
        }

        Context -Name 'HostedContentFilterPolicy update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                               = 'Present'
                    Identity                             = 'TestPolicy'
                    Credential                           = $Credential
                    AdminDisplayName                     = 'This ContentFilter policiy is a test'
                    AddXHeaderValue                      = 'MyCustomSpamHeader'
                    ModifySubjectValue                   = 'SPAM!'
                    RedirectToRecipients                 = @()
                    TestModeBccToRecipients              = @()
                    QuarantineRetentionPeriod            = 15
                    TestModeAction                       = 'AddXHeader'
                    IncreaseScoreWithImageLinks          = 'Off'
                    IncreaseScoreWithNumericIps          = 'On'
                    IncreaseScoreWithRedirectToOtherPort = 'On'
                    IncreaseScoreWithBizOrInfoUrls       = 'On'
                    IntraOrgFilterState                  = 'Default'
                    MarkAsSpamEmptyMessages              = 'On'
                    MarkAsSpamJavaScriptInHtml           = 'On'
                    MarkAsSpamFramesInHtml               = 'On'
                    MarkAsSpamObjectTagsInHtml           = 'On'
                    MarkAsSpamEmbedTagsInHtml            = 'Off'
                    MarkAsSpamFormTagsInHtml             = 'Off'
                    MarkAsSpamWebBugsInHtml              = 'On'
                    MarkAsSpamSensitiveWordList          = 'Test'
                    MarkAsSpamSpfRecordHardFail          = 'On'
                    MarkAsSpamFromAddressAuthFail        = 'On'
                    MarkAsSpamBulkMail                   = 'On'
                    MarkAsSpamNdrBackscatter             = 'On'
                    LanguageBlockList                    = @('AF', 'SQ', 'AR', 'HY', 'AZ', 'EU', 'BE', 'BN', 'BS', 'BR', 'BG', 'CA', 'ZH-CN', 'ZH-TW', 'HR', 'CS', 'DA', 'NL', 'EO', 'ET', 'FO', 'TL', 'FI', 'FR', 'FY', 'GL', 'KA', 'DE', 'EL', 'KL', 'GU', 'HA', 'HE', 'HI', 'HU', 'IS', 'ID', 'GA', 'ZU', 'IT', 'JA', 'KN', 'KK', 'SW', 'KO', 'KU', 'KY', 'LA', 'LV', 'LT', 'LB', 'MK', 'MS', 'ML', 'MT', 'MI', 'MR', 'MN', 'NB', 'NN', 'PS', 'FA', 'PL', 'PT', 'PA', 'RO', 'RM', 'RU', 'SE', 'SR', 'SK', 'SL', 'WEN', 'SV', 'TA', 'TE', 'TH', 'TR', 'UK', 'UR', 'UZ', 'VI', 'CY', 'YI')
                    RegionBlockList                      = @('AF', 'AX', 'AL', 'DZ', 'AS', 'AD', 'AO', 'AI', 'AQ', 'AG', 'AR', 'AM', 'AW', 'AU', 'AT', 'AZ', 'BS', 'BH', 'BD', 'BB', 'BY', 'BE', 'BZ', 'BJ', 'BM', 'BT', 'BO', 'BQ', 'BA', 'BW', 'BV', 'BR', 'IO', 'VG', 'BN', 'BG', 'BF', 'BI', 'CV', 'KH', 'CM', 'KY', 'CF', 'TD', 'CL', 'CN', 'CX', 'CC', 'CO', 'KM', 'CG', 'CD', 'CK', 'CR', 'CI', 'HR', 'CU', 'CW', 'CY', 'CZ', 'DK', 'DJ', 'DM', 'DO', 'EC', 'EG', 'SV', 'GQ', 'ER', 'EE', 'ET', 'FK', 'FO', 'FJ', 'FI', 'FR', 'GF', 'PF', 'TF', 'GA', 'GM', 'GE', 'DE', 'GH', 'GI', 'GR', 'GL', 'GD', 'GP', 'GU', 'GT', 'GG', 'GN', 'GW', 'GY', 'HT', 'HM', 'VA', 'HN', 'HK', 'HU', 'IS', 'IN', 'ID', 'IR', 'IQ', 'IE', 'IM', 'IL', 'IT', 'JM', 'XJ', 'SJ', 'JP', 'JE', 'JO', 'KZ', 'KE', 'KI', 'KR', 'KW', 'KG', 'LA', 'LV', 'LB', 'LS', 'LR', 'LY', 'LI', 'LT', 'LU', 'MO', 'MK', 'MG', 'MW', 'MY', 'MV', 'ML', 'MT', 'MH', 'MQ', 'MR', 'MU', 'YT', 'FM', 'MD', 'MC', 'MN', 'ME', 'MS', 'MA', 'MZ', 'MM', 'NA', 'NR', 'NP', 'NL', 'NC', 'NZ', 'NI', 'NE', 'NG', 'NU', 'NF', 'KP', 'MP', 'NO', 'OM', 'PK', 'PW', 'PS', 'PA', 'PG', 'PY', 'PE', 'PH', 'PN', 'PL', 'PT', 'PR', 'QA', 'RE', 'RO', 'RU', 'RW', 'XS', 'BL', 'SH', 'KN', 'LC', 'MF', 'PM', 'VC', 'WS', 'SM', 'ST', 'SA', 'SN', 'RS', 'SC', 'SL', 'SG', 'XE', 'SX', 'SK', 'SI', 'SB', 'SO', 'ZA', 'GS', 'ES', 'LK', 'SD', 'SR', 'SZ', 'SE', 'CH', 'SY', 'TW', 'TJ', 'TZ', 'TH', 'TL', 'TG', 'TK', 'TO', 'TT', 'TN', 'TR', 'TM', 'TC', 'TV', 'UG', 'UA', 'AE', 'UY', 'UZ', 'VU', 'VE', 'VN', 'WF', 'YE', 'ZM', 'ZW')
                    HighConfidencePhishAction            = 'Quarantine'
                    HighConfidenceSpamAction             = 'Quarantine'
                    SpamAction                           = 'MoveToJmf'
                    EnableRegionBlockList                = $true
                    EnableLanguageBlockList              = $true
                    BulkThreshold                        = 5
                    AllowedSenders                       = @('test@contoso.com', 'test@fabrikam.com')
                    AllowedSenderDomains                 = @('contoso.com', 'fabrikam.com')
                    BlockedSenders                       = @('me@privacy.net', 'thedude@contoso.com')
                    BlockedSenderDomains                 = @('privacy.net', 'facebook.com')
                    PhishZapEnabled                      = $true
                    SpamZapEnabled                       = $true
                    InlineSafetyTipsEnabled              = $true
                    BulkSpamAction                       = 'MoveToJmf'
                    PhishSpamAction                      = 'Quarantine'
                    MakeDefault                          = $false
                }

                Mock -CommandName Get-HostedContentFilterPolicy -MockWith {
                    return @{
                        Identity                             = 'TestPolicy'
                        AdminDisplayName                     = 'This ContentFilter policiy is a test'
                        AddXHeaderValue                      = 'MyCustomSpamHeader'
                        ModifySubjectValue                   = 'SPAM!'
                        RedirectToRecipients                 = @()
                        TestModeBccToRecipients              = @()
                        QuarantineRetentionPeriod            = 15
                        TestModeAction                       = 'AddXHeader'
                        IncreaseScoreWithImageLinks          = 'Off'
                        IncreaseScoreWithNumericIps          = 'On'
                        IncreaseScoreWithRedirectToOtherPort = 'On'
                        IncreaseScoreWithBizOrInfoUrls       = 'On'
                        IntraOrgFilterState                  = 'Default'
                        MarkAsSpamEmptyMessages              = 'On'
                        MarkAsSpamJavaScriptInHtml           = 'On'
                        MarkAsSpamFramesInHtml               = 'On'
                        MarkAsSpamObjectTagsInHtml           = 'On'
                        MarkAsSpamEmbedTagsInHtml            = 'Off'
                        MarkAsSpamFormTagsInHtml             = 'Off'
                        MarkAsSpamWebBugsInHtml              = 'On'
                        MarkAsSpamSensitiveWordList          = 'Test'
                        MarkAsSpamSpfRecordHardFail          = 'On'
                        MarkAsSpamFromAddressAuthFail        = 'On'
                        MarkAsSpamBulkMail                   = 'On'
                        MarkAsSpamNdrBackscatter             = 'On'
                        LanguageBlockList                    = @('AF', 'SQ', 'AR', 'HY', 'AZ', 'EU', 'BE', 'BN', 'BS', 'BR', 'BG', 'CA', 'ZH-CN', 'ZH-TW', 'HR', 'CS', 'DA', 'NL', 'EO', 'ET', 'FO', 'TL', 'FI', 'FR', 'FY', 'GL', 'KA', 'DE', 'EL', 'KL', 'GU', 'HA', 'HE', 'HI', 'HU', 'IS', 'ID', 'GA', 'ZU', 'IT', 'JA', 'KN', 'KK', 'SW', 'KO', 'KU', 'KY', 'LA', 'LV', 'LT', 'LB', 'MK', 'MS', 'ML', 'MT', 'MI', 'MR', 'MN', 'NB', 'NN', 'PS', 'FA', 'PL', 'PT', 'PA', 'RO', 'RM', 'RU', 'SE', 'SR', 'SK', 'SL', 'WEN', 'SV', 'TA', 'TE', 'TH', 'TR', 'UK', 'UR', 'UZ', 'VI', 'CY', 'YI')
                        RegionBlockList                      = @('AF', 'AX', 'AL', 'DZ', 'AS', 'AD', 'AO', 'AI', 'AQ', 'AG', 'AR', 'AM', 'AW', 'AU', 'AT', 'AZ', 'BS', 'BH', 'BD', 'BB', 'BY', 'BE', 'BZ', 'BJ', 'BM', 'BT', 'BO', 'BQ', 'BA', 'BW', 'BV', 'BR', 'IO', 'VG', 'BN', 'BG', 'BF', 'BI', 'CV', 'KH', 'CM', 'KY', 'CF', 'TD', 'CL', 'CN', 'CX', 'CC', 'CO', 'KM', 'CG', 'CD', 'CK', 'CR', 'CI', 'HR', 'CU', 'CW', 'CY', 'CZ', 'DK', 'DJ', 'DM', 'DO', 'EC', 'EG', 'SV', 'GQ', 'ER', 'EE', 'ET', 'FK', 'FO', 'FJ', 'FI', 'FR', 'GF', 'PF', 'TF', 'GA', 'GM', 'GE', 'DE', 'GH', 'GI', 'GR', 'GL', 'GD', 'GP', 'GU', 'GT', 'GG', 'GN', 'GW', 'GY', 'HT', 'HM', 'VA', 'HN', 'HK', 'HU', 'IS', 'IN', 'ID', 'IR', 'IQ', 'IE', 'IM', 'IL', 'IT', 'JM', 'XJ', 'SJ', 'JP', 'JE', 'JO', 'KZ', 'KE', 'KI', 'KR', 'KW', 'KG', 'LA', 'LV', 'LB', 'LS', 'LR', 'LY', 'LI', 'LT', 'LU', 'MO', 'MK', 'MG', 'MW', 'MY', 'MV', 'ML', 'MT', 'MH', 'MQ', 'MR', 'MU', 'YT', 'FM', 'MD', 'MC', 'MN', 'ME', 'MS', 'MA', 'MZ', 'MM', 'NA', 'NR', 'NP', 'NL', 'NC', 'NZ', 'NI', 'NE', 'NG', 'NU', 'NF', 'KP', 'MP', 'NO', 'OM', 'PK', 'PW', 'PS', 'PA', 'PG', 'PY', 'PE', 'PH', 'PN', 'PL', 'PT', 'PR', 'QA', 'RE', 'RO', 'RU', 'RW', 'XS', 'BL', 'SH', 'KN', 'LC', 'MF', 'PM', 'VC', 'WS', 'SM', 'ST', 'SA', 'SN', 'RS', 'SC', 'SL', 'SG', 'XE', 'SX', 'SK', 'SI', 'SB', 'SO', 'ZA', 'GS', 'ES', 'LK', 'SD', 'SR', 'SZ', 'SE', 'CH', 'SY', 'TW', 'TJ', 'TZ', 'TH', 'TL', 'TG', 'TK', 'TO', 'TT', 'TN', 'TR', 'TM', 'TC', 'TV', 'UG', 'UA', 'AE', 'UY', 'UZ', 'VU', 'VE', 'VN', 'WF', 'YE', 'ZM', 'ZW')
                        HighConfidencePhishAction            = 'Quarantine'
                        HighConfidenceSpamAction             = 'Quarantine'
                        SpamAction                           = 'MoveToJmf'
                        EnableRegionBlockList                = $true
                        EnableLanguageBlockList              = $true
                        BulkThreshold                        = 5
                        AllowedSenders                       = @('test@contoso.com','test@fabrikam.com')
                        AllowedSenderDomains                 = @('contoso.com', 'fabrikam.com')
                        BlockedSenders                       = @('me@privacy.net', 'thedude@contoso.com')
                        BlockedSenderDomains                 = @('privacy.net', 'facebook.com')
                        PhishZapEnabled                      = $true
                        SpamZapEnabled                       = $true
                        InlineSafetyTipsEnabled              = $true
                        BulkSpamAction                       = 'MoveToJmf'
                        PhishSpamAction                      = 'Quarantine'
                        IsDefault                            = $false
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedContentFilterPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'HostedContentFilterPolicy update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                               = 'Present'
                    Identity                             = 'TestPolicy'
                    Credential                           = $Credential
                    AdminDisplayName                     = 'This ContentFilter policiy is a test'
                    AddXHeaderValue                      = 'MyCustomSpamHeader'
                    ModifySubjectValue                   = 'SPAM!'
                    RedirectToRecipients                 = @()
                    TestModeBccToRecipients              = @()
                    QuarantineRetentionPeriod            = 15
                    TestModeAction                       = 'AddXHeader'
                    IncreaseScoreWithImageLinks          = 'Off'
                    IncreaseScoreWithNumericIps          = 'On'
                    IncreaseScoreWithRedirectToOtherPort = 'On'
                    IncreaseScoreWithBizOrInfoUrls       = 'On'
                    IntraOrgFilterState                  = 'Default'
                    MarkAsSpamEmptyMessages              = 'On'
                    MarkAsSpamJavaScriptInHtml           = 'On'
                    MarkAsSpamFramesInHtml               = 'On'
                    MarkAsSpamObjectTagsInHtml           = 'On'
                    MarkAsSpamEmbedTagsInHtml            = 'Off'
                    MarkAsSpamFormTagsInHtml             = 'Off'
                    MarkAsSpamWebBugsInHtml              = 'On'
                    MarkAsSpamSensitiveWordList          = 'Test'
                    MarkAsSpamSpfRecordHardFail          = 'On'
                    MarkAsSpamFromAddressAuthFail        = 'On'
                    MarkAsSpamBulkMail                   = 'On'
                    MarkAsSpamNdrBackscatter             = 'On'
                    LanguageBlockList                    = @('AF', 'SQ', 'AR', 'HY', 'AZ', 'EU', 'BE', 'BN', 'BS', 'BR', 'BG', 'CA', 'ZH-CN', 'ZH-TW', 'HR', 'CS', 'DA', 'NL', 'EO', 'ET', 'FO', 'TL', 'FI', 'FR', 'FY', 'GL', 'KA', 'DE', 'EL', 'KL', 'GU', 'HA', 'HE', 'HI', 'HU', 'IS', 'ID', 'GA', 'ZU', 'IT', 'JA', 'KN', 'KK', 'SW', 'KO', 'KU', 'KY', 'LA', 'LV', 'LT', 'LB', 'MK', 'MS', 'ML', 'MT', 'MI', 'MR', 'MN', 'NB', 'NN', 'PS', 'FA', 'PL', 'PT', 'PA', 'RO', 'RM', 'RU', 'SE', 'SR', 'SK', 'SL', 'WEN', 'SV', 'TA', 'TE', 'TH', 'TR', 'UK', 'UR', 'UZ', 'VI', 'CY', 'YI')
                    RegionBlockList                      = @('AF', 'AX', 'AL', 'DZ', 'AS', 'AD', 'AO', 'AI', 'AQ', 'AG', 'AR', 'AM', 'AW', 'AU', 'AT', 'AZ', 'BS', 'BH', 'BD', 'BB', 'BY', 'BE', 'BZ', 'BJ', 'BM', 'BT', 'BO', 'BQ', 'BA', 'BW', 'BV', 'BR', 'IO', 'VG', 'BN', 'BG', 'BF', 'BI', 'CV', 'KH', 'CM', 'KY', 'CF', 'TD', 'CL', 'CN', 'CX', 'CC', 'CO', 'KM', 'CG', 'CD', 'CK', 'CR', 'CI', 'HR', 'CU', 'CW', 'CY', 'CZ', 'DK', 'DJ', 'DM', 'DO', 'EC', 'EG', 'SV', 'GQ', 'ER', 'EE', 'ET', 'FK', 'FO', 'FJ', 'FI', 'FR', 'GF', 'PF', 'TF', 'GA', 'GM', 'GE', 'DE', 'GH', 'GI', 'GR', 'GL', 'GD', 'GP', 'GU', 'GT', 'GG', 'GN', 'GW', 'GY', 'HT', 'HM', 'VA', 'HN', 'HK', 'HU', 'IS', 'IN', 'ID', 'IR', 'IQ', 'IE', 'IM', 'IL', 'IT', 'JM', 'XJ', 'SJ', 'JP', 'JE', 'JO', 'KZ', 'KE', 'KI', 'KR', 'KW', 'KG', 'LA', 'LV', 'LB', 'LS', 'LR', 'LY', 'LI', 'LT', 'LU', 'MO', 'MK', 'MG', 'MW', 'MY', 'MV', 'ML', 'MT', 'MH', 'MQ', 'MR', 'MU', 'YT', 'FM', 'MD', 'MC', 'MN', 'ME', 'MS', 'MA', 'MZ', 'MM', 'NA', 'NR', 'NP', 'NL', 'NC', 'NZ', 'NI', 'NE', 'NG', 'NU', 'NF', 'KP', 'MP', 'NO', 'OM', 'PK', 'PW', 'PS', 'PA', 'PG', 'PY', 'PE', 'PH', 'PN', 'PL', 'PT', 'PR', 'QA', 'RE', 'RO', 'RU', 'RW', 'XS', 'BL', 'SH', 'KN', 'LC', 'MF', 'PM', 'VC', 'WS', 'SM', 'ST', 'SA', 'SN', 'RS', 'SC', 'SL', 'SG', 'XE', 'SX', 'SK', 'SI', 'SB', 'SO', 'ZA', 'GS', 'ES', 'LK', 'SD', 'SR', 'SZ', 'SE', 'CH', 'SY', 'TW', 'TJ', 'TZ', 'TH', 'TL', 'TG', 'TK', 'TO', 'TT', 'TN', 'TR', 'TM', 'TC', 'TV', 'UG', 'UA', 'AE', 'UY', 'UZ', 'VU', 'VE', 'VN', 'WF', 'YE', 'ZM', 'ZW')
                    HighConfidencePhishAction            = 'Quarantine'
                    HighConfidenceSpamAction             = 'Quarantine'
                    SpamAction                           = 'MoveToJmf'
                    EnableRegionBlockList                = $true
                    EnableLanguageBlockList              = $true
                    BulkThreshold                        = 5
                    AllowedSenders                       = @('test@contoso.com', 'test@fabrikam.com')
                    AllowedSenderDomains                 = @('contoso.com', 'fabrikam.com')
                    BlockedSenders                       = @('me@privacy.net', 'thedude@contoso.com')
                    BlockedSenderDomains                 = @('privacy.net', 'facebook.com')
                    PhishZapEnabled                      = $true
                    SpamZapEnabled                       = $false # Drift
                    InlineSafetyTipsEnabled              = $true
                    BulkSpamAction                       = 'MoveToJmf'
                    PhishSpamAction                      = 'Quarantine'
                    MakeDefault                          = $false
                }
                Mock -CommandName Get-HostedContentFilterPolicy -MockWith {
                    return @{
                        Ensure                               = 'Present'
                        Identity                             = 'TestPolicy'
                        Credential                           = $Credential
                        AdminDisplayName                     = 'This ContentFilter policiy is a test'
                        AddXHeaderValue                      = 'MyCustomSpamHeader'
                        ModifySubjectValue                   = 'SPAM!'
                        RedirectToRecipients                 = @()
                        TestModeBccToRecipients              = @()
                        QuarantineRetentionPeriod            = 15
                        TestModeAction                       = 'AddXHeader'
                        IncreaseScoreWithImageLinks          = 'Off'
                        IncreaseScoreWithNumericIps          = 'On'
                        IncreaseScoreWithRedirectToOtherPort = 'On'
                        IncreaseScoreWithBizOrInfoUrls       = 'On'
                        IntraOrgFilterState                  = 'Default'
                        MarkAsSpamEmptyMessages              = 'On'
                        MarkAsSpamJavaScriptInHtml           = 'On'
                        MarkAsSpamFramesInHtml               = 'On'
                        MarkAsSpamObjectTagsInHtml           = 'On'
                        MarkAsSpamEmbedTagsInHtml            = 'Off'
                        MarkAsSpamFormTagsInHtml             = 'Off'
                        MarkAsSpamWebBugsInHtml              = 'On'
                        MarkAsSpamSensitiveWordList          = 'Test'
                        MarkAsSpamSpfRecordHardFail          = 'On'
                        MarkAsSpamFromAddressAuthFail        = 'On'
                        MarkAsSpamBulkMail                   = 'On'
                        MarkAsSpamNdrBackscatter             = 'On'
                        LanguageBlockList                    = @()
                        RegionBlockList                      = @()
                        HighConfidencePhishAction            = 'Quarantine'
                        HighConfidenceSpamAction             = 'Quarantine'
                        SpamAction                           = 'MoveToJmf'
                        EnableRegionBlockList                = $true
                        EnableLanguageBlockList              = $true
                        BulkThreshold                        = 5
                        AllowedSenders                       = @{
                            Sender = @(
                                [PSCustomObject]@{Address = 'test@contoso.com' },
                                [PSCustomObject]@{Address = 'test@fabrikam.com' }
                            )
                        }
                        AllowedSenderDomains                 = @(
                            [PSCustomObject]@{Domain = 'contoso.com' },
                            [PSCustomObject]@{Domain = 'fabrikam.com' }
                        )
                        BlockedSenders                       = @{
                            Sender = @(
                                [PSCustomObject]@{Address = 'me@privacy.net' },
                                [PSCustomObject]@{Address = 'thedude@contoso.com' }
                            )
                        }
                        BlockedSenderDomains                 = @(
                            [PSCustomObject]@{Domain = 'privacy.net' },
                            [PSCustomObject]@{Domain = 'facebook.com' }
                        )
                        PhishZapEnabled                      = $true
                        SpamZapEnabled                       = $true
                        InlineSafetyTipsEnabled              = $true
                        BulkSpamAction                       = 'MoveToJmf'
                        PhishSpamAction                      = 'MoveToJmf'
                        MakeDefault                          = $false
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedContentFilterPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedContentFilterPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-HostedContentFilterPolicy -Exactly 1
            }
        }

        Context -Name 'HostedContentFilterPolicy removal.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure     = 'Absent'
                    Identity   = 'TestPolicy'
                    Credential = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedContentFilterPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedContentFilterPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-HostedContentFilterPolicy -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOHostedContentFilterPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
