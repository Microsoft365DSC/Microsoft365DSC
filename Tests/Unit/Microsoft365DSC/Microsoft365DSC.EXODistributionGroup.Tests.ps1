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
    -DscResource 'EXODistributionGroup' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString 'password' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)
            $Script:ExportMode = $false
            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Set-DistributionGroup -MockWith {
            }

            Mock -CommandName New-DistributionGroup -MockWith {
            }

            Mock -CommandName Remove-DistributionGroup -MockWith {
            }
            Mock -CommandName Get-DistributionGroup -MockWith {
                return @{
                    Alias                              = 'demodg'
                    BccBlocked                         = $False
                    BypassNestedModerationEnabled      = $False
                    DisplayName                        = 'My Demo DG'
                    HiddenGroupMembershipEnabled       = $True
                    ManagedByWithDisplayName           = @('john.smith@contoso.com')
                    MemberDepartRestriction            = 'Open'
                    MemberJoinRestriction              = 'Closed'
                    ModeratedByWithDisplayNames        = @('john.smith@contoso.com')
                    ModerationEnabled                  = $False
                    Identity                           = 'DemoDG'
                    Name                               = 'DemoDG'
                    OrganizationalUnit                 = 'nampr03a010.prod.outlook.com/Microsoft Exchange Hosted Organizations/contoso.com'
                    PrimarySmtpAddress                 = 'demodg@contoso.com'
                    RequireSenderAuthenticationEnabled = $True
                    SendModerationNotifications        = 'Always'
                    GroupType                          = @('Universal')
                    RecipientTypeDetails               = 'MailUniversalDistributionGroup'
                    AcceptMessagesOnlyFromSendersOrMembersWithDisplayNames = @('john.smith@contoso.com')
                }
            }
            Mock -CommandName Get-Recipient -MockWith {
                return @{
                    Name               = 'john.smith@contoso.com'
                    PrimarySmtpAddress = 'john.smith@contoso.com'
                    WindowsLiveID      = 'john.smith@contoso.com'
                }
            }
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Get-DistributionGroupMember -MockWith {
            }

            Mock -CommandName Start-Sleep -ModuleName M365DSCErrorHandler -MockWith {
            }
        }

        # Test contexts
        Context -Name "Distribution group should exist but it doesn't. CREATE IT." -Fixture {
            BeforeAll {
                $testParams = @{
                    Alias                              = 'demodg'
                    BccBlocked                         = $False
                    BypassNestedModerationEnabled      = $False
                    DisplayName                        = 'My Demo DG'
                    Ensure                             = 'Present'
                    HiddenGroupMembershipEnabled       = $True
                    ManagedBy                          = @('john.smith@contoso.com')
                    MemberDepartRestriction            = 'Open'
                    MemberJoinRestriction              = 'Closed'
                    ModeratedBy                        = @('admin@contoso.com')
                    ModerationEnabled                  = $False
                    Identity                           = 'DemoDG'
                    Name                               = 'DemoDG'
                    OrganizationalUnit                 = 'nampr03a010.prod.outlook.com/Microsoft Exchange Hosted Organizations/contoso.com'
                    PrimarySmtpAddress                 = 'demodg@contoso.com'
                    RequireSenderAuthenticationEnabled = $True
                    SendModerationNotifications        = 'Always'
                    Credential                         = $Credential
                }

                Mock -CommandName Get-DistributionGroup -MockWith {
                    return $null
                }

                Mock -CommandName Get-DistributionGroup -ParameterFilter { $Identity -eq 'DemoDG' } -MockWith {
                    return @{
                        Identity = 'DemoDG'
                    }
                }

                Mock -CommandName New-DistributionGroup -MockWith {
                    return @{
                        Identity = 'DemoDG'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODistributionGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODistributionGroup' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-DistributionGroup' -Exactly 1
                Should -Invoke -CommandName 'Get-DistributionGroup' -Exactly 2 -ParameterFilter { $Identity -eq 'DemoDG' }
                Should -Invoke -CommandName Start-Sleep -ModuleName M365DSCErrorHandler -Exactly 0
                Should -Invoke -CommandName 'Set-DistributionGroup' -Exactly 1 -ParameterFilter { $Identity -eq 'DemoDG' }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXODistributionGroup' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'Distribution group exists but is not in the desired state. UPDATE IT.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Alias                              = 'demodg'
                    BccBlocked                         = $False
                    BypassNestedModerationEnabled      = $False
                    DisplayName                        = 'My Demo DG'
                    Ensure                             = 'Present'
                    HiddenGroupMembershipEnabled       = $True
                    ManagedBy                          = @('john.smith@contoso.com')
                    MemberDepartRestriction            = 'Open'
                    MemberJoinRestriction              = 'Open' # Drift
                    ModeratedBy                        = @('john.smith@contoso.com')
                    ModerationEnabled                  = $False
                    Identity                           = 'DemoDG'
                    Name                               = 'DemoDG'
                    OrganizationalUnit                 = 'nampr03a010.prod.outlook.com/Microsoft Exchange Hosted Organizations/contoso.com'
                    PrimarySmtpAddress                 = 'demodg@contoso.com'
                    RequireSenderAuthenticationEnabled = $True
                    SendModerationNotifications        = 'Always'
                    Credential                         = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODistributionGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODistributionGroup' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-DistributionGroup' -Exactly 1
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXODistributionGroup' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Distribution group exists and is already in the desired state. DO NOTHING.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Alias                              = 'demodg'
                    BccBlocked                         = $False
                    BypassNestedModerationEnabled      = $False
                    DisplayName                        = 'My Demo DG'
                    Ensure                             = 'Present'
                    HiddenGroupMembershipEnabled       = $True
                    ManagedBy                          = @('john.smith@contoso.com')
                    MemberDepartRestriction            = 'Open'
                    MemberJoinRestriction              = 'Closed'
                    ModeratedBy                        = @('john.smith@contoso.com')
                    ModerationEnabled                  = $False
                    Identity                           = 'DemoDG'
                    Name                               = 'DemoDG'
                    OrganizationalUnit                 = 'nampr03a010.prod.outlook.com/Microsoft Exchange Hosted Organizations/contoso.com'
                    PrimarySmtpAddress                 = 'demodg@contoso.com'
                    RequireSenderAuthenticationEnabled = $True
                    SendModerationNotifications        = 'Always'
                    RoomList                           = $False
                    AcceptMessagesOnlyFromSendersOrMembers = @('john.smith@contoso.com')
                    Credential                         = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODistributionGroup' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXODistributionGroup' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Distribution group exists but should not. REMOVE IT.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Alias                              = 'demodg'
                    BccBlocked                         = $False
                    BypassNestedModerationEnabled      = $False
                    DisplayName                        = 'My Demo DG'
                    Ensure                             = 'Absent'
                    HiddenGroupMembershipEnabled       = $True
                    ManagedBy                          = @('john.smith@contoso.com')
                    MemberDepartRestriction            = 'Open'
                    MemberJoinRestriction              = 'Closed'
                    ModeratedBy                        = @('john.smith@contoso.com')
                    ModerationEnabled                  = $False
                    Identity                           = 'DemoDG'
                    Name                               = 'DemoDG'
                    OrganizationalUnit                 = 'nampr03a010.prod.outlook.com/Microsoft Exchange Hosted Organizations/contoso.com'
                    PrimarySmtpAddress                 = 'demodg@contoso.com'
                    RequireSenderAuthenticationEnabled = $True
                    SendModerationNotifications        = 'Always'
                    Credential                         = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODistributionGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXODistributionGroup' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-DistributionGroup' -Exactly 1
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXODistributionGroup' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXODistributionGroup' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
