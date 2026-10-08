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
    -DscResource "EXODynamicDistributionGroup" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Reset-MSCloudLoginConnectionProfileContext -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Get-Recipient -MockWith {
                return @(
                    @{
                        Name = "FakeStringValue"
                        PrimarySmtpAddress = "FakeStringValue@contoso.com"
                        WindowsLiveID = "FakeStringValue@contoso.com"
                    }
                )
            }

            Mock -CommandName Set-DynamicDistributionGroup -MockWith {
            }

            Mock -CommandName New-DynamicDistributionGroup -MockWith {
            }

            Mock -CommandName Remove-DynamicDistributionGroup -MockWith {
            }

            Mock -CommandName Get-DynamicDistributionGroup -MockWith {
                return @{
                    AcceptMessagesOnlyFrom             = @("FakeStringValue")
                    ConditionalDepartment              = @("FakeStringValue")
                    CustomAttribute1                   = "FakeStringValue"
                    Notes                              = "FakeStringValue"
                    DisplayName                        = "FakeStringValue"
                    Identity                           = "FakeStringValue"
                    MailTip                            = "<html>`r`n<body>`r`nFakeStringValue`r`n</body>`r`n</html>`r`n"
                    MailTipTranslations                = @("default:<html>`r`n<body>`r`nFakeStringValue`r`n</body>`r`n</html>`r`n", "FR:<html>`r`n<body>`r`nFakeStringValue`r`n</body>`r`n</html>`r`n")
                    IncludedRecipients                 = "MailboxUsers, MailContacts"
                    ReportToOriginatorEnabled          = $True
                    HiddenFromAddressListsEnabled      = $True
                    SendOofMessageToOriginatorEnabled  = $True
                    ModerationEnabled                  = $True
                    CustomAttribute10                  = "FakeStringValue"
                    CustomAttribute4                   = "FakeStringValue"
                    Name                               = "FakeStringValue"
                    Alias                              = "smtp:FakeStringValue@contoso.com"
                    ReportToManagerEnabled             = $True
                    RecipientFilter                    = "((((Title -eq 'Architect') -or (Title -eq 'Title'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))"
                    RequireSenderAuthenticationEnabled = $True
                    SimpleDisplayName                  = "FakeStringValue"
                    PhoneticDisplayName                = "FakeStringValue"
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "The EXODynamicDistributionGroup should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AcceptMessagesOnlyFrom             = @("FakeStringValue@contoso.com")
                    ConditionalDepartment              = @("FakeStringValue")
                    CustomAttribute1                   = "FakeStringValue"
                    Notes                              = "FakeStringValue"
                    DisplayName                        = "FakeStringValue"
                    MailTip                            = "FakeStringValue"
                    Identity                           = "FakeStringValue"
                    ReportToOriginatorEnabled          = $True
                    HiddenFromAddressListsEnabled      = $True
                    SendOofMessageToOriginatorEnabled  = $True
                    ModerationEnabled                  = $True
                    CustomAttribute10                  = "FakeStringValue"
                    CustomAttribute4                   = "FakeStringValue"
                    Name                               = "FakeStringValue"
                    Alias                              = "smtp:FakeStringValue@contoso.com"
                    ReportToManagerEnabled             = $True
                    RecipientFilter                    = "(((Title -eq 'Architect') -or (Title -eq 'Title')))"
                    RequireSenderAuthenticationEnabled = $True
                    SimpleDisplayName                  = "FakeStringValue"
                    PhoneticDisplayName                = "FakeStringValue"
                    Ensure                             = "Present"
                    Credential                         = $Credential;
                }

                Mock -CommandName Get-DynamicDistributionGroup -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXODynamicDistributionGroup' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODynamicDistributionGroup' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODynamicDistributionGroup' -Property $testParams).Set()
                Should -Invoke -CommandName New-DynamicDistributionGroup -Exactly 1
                Should -Invoke -CommandName Set-DynamicDistributionGroup -Exactly 1
            }
        }

        Context -Name "The EXODynamicDistributionGroup exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AcceptMessagesOnlyFrom             = @("FakeStringValue@contoso.com")
                    ConditionalDepartment              = @("FakeStringValue")
                    CustomAttribute1                   = "FakeStringValue"
                    Notes                              = "FakeStringValue"
                    DisplayName                        = "FakeStringValue"
                    MailTip                            = "FakeStringValue"
                    Identity                           = "FakeStringValue"
                    ReportToOriginatorEnabled          = $True
                    HiddenFromAddressListsEnabled      = $True
                    SendOofMessageToOriginatorEnabled  = $True
                    ModerationEnabled                  = $True
                    CustomAttribute10                  = "FakeStringValue"
                    CustomAttribute4                   = "FakeStringValue"
                    Name                               = "FakeStringValue"
                    Alias                              = "smtp:FakeStringValue@contoso.com"
                    ReportToManagerEnabled             = $True
                    RecipientFilter                    = "(((Title -eq 'Architect') -or (Title -eq 'Title')))"
                    RequireSenderAuthenticationEnabled = $True
                    SimpleDisplayName                  = "FakeStringValue"
                    PhoneticDisplayName                = "FakeStringValue"
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXODynamicDistributionGroup' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODynamicDistributionGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODynamicDistributionGroup' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-DynamicDistributionGroup -Exactly 1
            }
        }

        Context -Name "The EXODynamicDistributionGroup Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AcceptMessagesOnlyFrom             = @("FakeStringValue@contoso.com")
                    ConditionalDepartment              = @("FakeStringValue")
                    CustomAttribute1                   = "FakeStringValue"
                    Notes                              = "FakeStringValue"
                    DisplayName                        = "FakeStringValue"
                    MailTip                            = "FakeStringValue"
                    MailTipTranslations                = @("FR:FakeStringValue")
                    IncludedRecipients                 = @("MailboxUsers", "MailContacts")
                    Identity                           = "FakeStringValue"
                    ReportToOriginatorEnabled          = $True
                    HiddenFromAddressListsEnabled      = $True
                    SendOofMessageToOriginatorEnabled  = $True
                    ModerationEnabled                  = $True
                    CustomAttribute10                  = "FakeStringValue"
                    CustomAttribute4                   = "FakeStringValue"
                    Name                               = "FakeStringValue"
                    Alias                              = "smtp:FakeStringValue@contoso.com"
                    ReportToManagerEnabled             = $True
                    RecipientFilter                    = "(((Title -eq 'Architect') -or (Title -eq 'Title')))"
                    RequireSenderAuthenticationEnabled = $True
                    SimpleDisplayName                  = "FakeStringValue"
                    PhoneticDisplayName                = "FakeStringValue"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODynamicDistributionGroup' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The EXODynamicDistributionGroup exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AcceptMessagesOnlyFrom             = @("FakeStringValue@contoso.com")
                    ConditionalDepartment              = @("FakeStringValue")
                    CustomAttribute1                   = "FakeStringValue"
                    Notes                              = "FakeStringValue"
                    DisplayName                        = "FakeStringValue"
                    MailTip                            = "FakeStringValue"
                    Identity                           = "FakeStringValue"
                    ReportToOriginatorEnabled          = $False # Drift
                    HiddenFromAddressListsEnabled      = $True
                    SendOofMessageToOriginatorEnabled  = $True
                    ModerationEnabled                  = $True
                    CustomAttribute10                  = "FakeStringValue"
                    CustomAttribute4                   = "FakeStringValue"
                    Name                               = "FakeStringValue"
                    Alias                              = "smtp:FakeStringValue@contoso.com"
                    ReportToManagerEnabled             = $True
                    RecipientFilter                    = "(((Title -eq 'Architect') -or (Title -eq 'Title')))"
                    RequireSenderAuthenticationEnabled = $True
                    SimpleDisplayName                  = "FakeStringValue"
                    PhoneticDisplayName                = "FakeStringValue"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXODynamicDistributionGroup' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODynamicDistributionGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODynamicDistributionGroup' -Property $testParams).Set()
                Should -Invoke -CommandName Set-DynamicDistributionGroup -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXODynamicDistributionGroup' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
