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
    -DscResource 'EXOOrganizationConfig' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Set-OrganizationConfig -MockWith {
            }

            Mock -CommandName Get-OrganizationConfig -MockWith {
                return @{
                    DefaultPublicFolderProhibitPostQuota              = '13 KB (13,312 bytes)'
                    VisibleMeetingUpdateProperties                    = 'Location,AllProperties:15'
                    DefaultPublicFolderIssueWarningQuota              = '13 KB (13,312 bytes)'
                    ConnectorsEnabledForYammer                        = $True
                    DefaultPublicFolderMaxItemSize                    = '13 KB (13,312 bytes)'
                    MailTipsLargeAudienceThreshold                    = 25
                    PublicFoldersEnabled                              = 'Local'
                    WebPushNotificationsDisabled                      = $False
                    MailTipsGroupMetricsEnabled                       = $True
                    DefaultPublicFolderMovedItemRetention             = '06.00:00:00'
                    DefaultPublicFolderDeletedItemRetention           = '30.00:00:00'
                    ByteEncoderTypeFor7BitCharsets                    = 0
                    SendFromAliasEnabled                              = $false
                    ActivityBasedAuthenticationTimeoutInterval        = '06:00:00'
                    DefaultGroupAccessType                            = 'Private'
                    DelayedDelicensingEnabledState                    = 'Enabled: False; WhenLastModifiedUtc: 1/1/0001 12:00:00 AM'
                    EndUserMailNotificationForDelayedDelicensingState = 'Enabled: False; WhenLastModifiedUtc: 1/1/0001 12:00:00 AM'
                    TenantAdminNotificationForDelayedDelicensingState = 'Enabled: False; WhenLastModifiedUtc: 1/1/0001 12:00:00 AM'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                           = 'Yes'
                    DefaultPublicFolderProhibitPostQuota       = '13 KB (13,312 bytes)'
                    VisibleMeetingUpdateProperties             = 'Location,AllProperties:15'
                    DefaultPublicFolderIssueWarningQuota       = '13 KB (13,312 bytes)'
                    Credential                                 = $Credential
                    ConnectorsEnabledForYammer                 = $True
                    DefaultPublicFolderMaxItemSize             = '13 KB (13,312 bytes)'
                    MailTipsLargeAudienceThreshold             = 25
                    PublicFoldersEnabled                       = 'Local'
                    WebPushNotificationsDisabled               = $False
                    MailTipsGroupMetricsEnabled                = $True
                    DefaultPublicFolderMovedItemRetention      = '06.00:00:00'
                    DefaultPublicFolderDeletedItemRetention    = '30.00:00:00'
                    ByteEncoderTypeFor7BitCharsets             = 0
                    ActivityBasedAuthenticationTimeoutInterval = '06:00:00'
                    SendFromAliasEnabled                       = $false
                    DefaultGroupAccessType                     = 'Private'
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOOrganizationConfig' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOOrganizationConfig' -Property $testParams).Get().ToHashtable()).IsSingleInstance | Should -Be 'Yes'
            }
        }

        Context -Name 'Values are not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                           = 'Yes'
                    DefaultPublicFolderProhibitPostQuota       = '13 KB (13,312 bytes)'
                    VisibleMeetingUpdateProperties             = 'Location,AllProperties:15'
                    DefaultPublicFolderIssueWarningQuota       = '13 KB (13,312 bytes)'
                    Credential                                 = $Credential
                    ConnectorsEnabledForYammer                 = $False
                    DefaultPublicFolderMaxItemSize             = '13 KB (13,312 bytes)'
                    MailTipsLargeAudienceThreshold             = 25
                    PublicFoldersEnabled                       = 'Local'
                    WebPushNotificationsDisabled               = $False
                    MailTipsGroupMetricsEnabled                = $False
                    DefaultPublicFolderMovedItemRetention      = '07.00:00:00' # Drift
                    DefaultPublicFolderDeletedItemRetention    = '30.00:00:00'
                    ByteEncoderTypeFor7BitCharsets             = 0
                    ActivityBasedAuthenticationTimeoutInterval = '06:00:00'
                    SendFromAliasEnabled                       = $false
                    DefaultGroupAccessType                     = 'Public'
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOOrganizationConfig' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOOrganizationConfig' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-OrganizationConfig' -Exactly 1
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOOrganizationConfig' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-OrganizationConfig'
            }
        }

        Context -Name 'Invalid properties are passed' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                           = 'Yes'
                    DefaultPublicFolderProhibitPostQuota       = '13 KB (13,312 bytes)'
                    VisibleMeetingUpdateProperties             = 'Location,AllProperties:15'
                    DefaultPublicFolderIssueWarningQuota       = '13 KB (13,312 bytes)'
                    Credential                                 = $Credential
                    ConnectorsEnabledForYammer                 = $False
                    DefaultPublicFolderMaxItemSize             = '13 KB (13,312 bytes)'
                    MailTipsLargeAudienceThreshold             = 25
                    PublicFoldersEnabled                       = 'Local'
                    WebPushNotificationsDisabled               = $False
                    MailTipsGroupMetricsEnabled                = $False
                    DefaultPublicFolderMovedItemRetention      = '06.00:00:00'
                    DefaultPublicFolderDeletedItemRetention    = '30.00:00:00'
                    ByteEncoderTypeFor7BitCharsets             = 0
                    ActivityBasedAuthenticationTimeoutInterval = '06:00:00'
                    DefaultGroupAccessType                     = 'Public'
                    EWSAllowList                               = @('111')
                    EWSBlockList                               = @('222')
                    SendFromAliasEnabled                       = $false
                }
            }

            It 'Should call the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'EXOOrganizationConfig' -Property $testParams).Set() } | Should -Throw "You can't specify both EWSAllowList and EWSBlockList properties."
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOOrganizationConfig' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
