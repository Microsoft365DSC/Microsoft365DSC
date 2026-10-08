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
    -DscResource "AADGroupEligibilitySchedule" -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -MockWith {
                return @{
                    isExpirationRequired = $true
                }
            }

            Mock  -CommandName Get-MgBetaPolicyRoleManagementPolicyAssignment -MockWith {
                return @(
                    @{
                        PolicyIdId = 'FakeId'
                    }
                )
            }

            Mock -CommandName New-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilityScheduleRequest -MockWith {
                return $null
            }

            Mock -CommandName Update-MgBetaPolicyRoleManagementPolicyRule -MockWith {
                return @()
            }

            Mock -CommandName Get-MgGroup -MockWith {
                return @{
                    Id = 'FakeId'
                    DisplayName = 'FakeStringValue'
                }
            }

            Mock -CommandName Get-MgBetaDirectoryObjectById -MockWith {
                return @{
                    '@odata.type' = '#microsoft.graph.group'
                    displayName = 'FakePrincipal'
                }
            }

            Mock -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -MockWith {
                return @{
                    AccessId             = 'member'
                    GroupDisplayName     = 'FakeStringValue'
                    MemberType           = 'direct'
                    PrincipalDisplayName = 'FakePrincipal'
                    ScheduleInfo         = @{
                        StartDateTime = '2025-01-23T08:59:00.000Z'
                        Expiration = @{
                            EndDateTime = '2025-12-23T08:59:00.000Z'
                            type = 'afterDateTime'
                        }
                    }
                }
            }
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "The AADGroupEligibilitySchedule should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                   = 'FakeId'
                    AccessId             = "member"
                    MemberType           = "direct"
                    GroupDisplayName     = "FakeStringValue"
                    Principal            = "FakeGroup"
                    PrincipalType        = "group"
                    ScheduleInfo         = ([MSFT_MicrosoftGraphrequestSchedule] @{

                            startDateTime = '2025-01-23T08:59:00.0000000+00:00'
                            Expiration = ([MSFT_MicrosoftGraphExpirationPattern] @{
                                    EndDateTime = '2025-12-23T08:59:00.00000000+00:00'
                                    Type = 'afterDateTime'})
                            })
                    Ensure               = "Present"
                    Credential           = $Credential;
                }

                Mock -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -MockWith {
                    return $null
                }

                Mock -CommandName New-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilityScheduleRequest -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -MockWith {
                    return @{
                        isExpirationRequired = $false
                    }
                }

                mock -CommandName Get-MgUser -MockWith {
                    return @{
                        Id = 'FakeId'
                        UserPrincipalName = 'John.Smith@contoso.com'
                    }
                }

                mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        Id = 'FakeId'
                        DisplayName = 'FakeStringValue'
                    }
                } -ParameterFilter {$Filter -eq "DisplayName eq 'FakeStringValue'"}

                mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        Id = 'FakeId'
                        DisplayName = 'FakeGroup'
                    }
                } -ParameterFilter {$Filter -eq "DisplayName eq 'FakeGroup'"}

                Mock -CommandName Get-MgBetaDirectoryObjectById -MockWith {
                    return @{
                        Id                   = "FakeId"
                        '@odata.type' = '#microsoft.graph.user'
                        userPrincipalName = 'John.Smith@contoso.com'
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGroupEligibilitySchedule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName Get-MgGroup -Exactly 2
                Should -Invoke -CommandName Get-MgBetaDirectoryObjectById -Exactly 0
                Should -Invoke -CommandName Get-MgUser -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyAssignment -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Update-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -Exactly 2
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroupEligibilitySchedule' -Property $testParams).Test() | Should -Be $false
                Should -Invoke -CommandName Get-MgGroup -Exactly 2
                Should -Invoke -CommandName Get-MgBetaDirectoryObjectById -Exactly 0
                Should -Invoke -CommandName Get-MgUser -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyAssignment -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Update-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -Exactly 2
            }

            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroupEligibilitySchedule' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilityScheduleRequest -Exactly 1
                Should -Invoke -CommandName Get-MgGroup -Exactly 4
                Should -Invoke -CommandName Get-MgBetaDirectoryObjectById -Exactly 0
                Should -Invoke -CommandName Get-MgUser -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyAssignment -Exactly 1
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -Exactly 1
                Should -Invoke -CommandName Update-MgBetaPolicyRoleManagementPolicyRule -Exactly 1
                Should -Invoke -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -Exactly 2
                Should -Invoke -CommandName New-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilityScheduleRequest -Exactly 1
            }
        }

        Context -Name "The AADGroupEligibilitySchedule exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AccessId = "member"
                    MemberType = "direct"
                    GroupDisplayName = "FakeStringValue"
                    Principal = "John.Smith@contoso.com"
                    ScheduleInfo         = ([MSFT_MicrosoftGraphrequestSchedule] @{
                        startDateTime = '2025-01-23T08:59:00.0000000+00:00'
                        Expiration = ([MSFT_MicrosoftGraphExpirationPattern] @{
                                EndDateTime = '2025-12-23T08:59:00.00000000+00:00'
                                Type = 'afterDateTime'})
                        })
                    Ensure = "Absent"
                    Credential = $Credential;
                }

                mock -CommandName Get-MgUser -MockWith {
                    return @{
                        Id = 'UserFakeId'
                        UserPrincipalName = 'John.Smith@contoso.com'
                    }
                }

                mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        Id = 'GroupFakeId'
                        DisplayName = 'FakeStringValue'
                    }
                }

                Mock -CommandName Get-MgBetaDirectoryObjectById -MockWith {
                    return @{
                        '@odata.type' = '#microsoft.graph.user'
                        userPrincipalName = 'John.Smith@contoso.com'
                    }
                }

                Mock -CommandName New-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilityScheduleRequest -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -MockWith {
                    return @{
                        Id                   = 'GroupFakeId_member_FakeId'
                        AccessId             = 'member'
                        MemberType           = 'direct'
                        PrincipalId          = 'UserFakeId'
                        PrincipalType        = "User"
                        GroupId              = "GroupFakeId"
                        Status               = "Provisioned"
                        ScheduleInfo         = @{
                            StartDateTime = '2025-01-23T08:59:00.000Z'
                                Expiration = @{
                                    EndDateTime = '2025-12-23T08:59:00.000Z'
                                    type = 'afterDateTime'
                                }
                        }
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGroupEligibilitySchedule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName Get-MgGroup -Exactly 1
                Should -Invoke -CommandName Get-MgBetaDirectoryObjectById -Exactly 1
                Should -Invoke -CommandName Get-MgUser -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyAssignment -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Update-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -Exactly 1
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroupEligibilitySchedule' -Property $testParams).Test() | Should -Be $false
                Should -Invoke -CommandName Get-MgGroup -Exactly 1
                Should -Invoke -CommandName Get-MgBetaDirectoryObjectById -Exactly 1
                Should -Invoke -CommandName Get-MgUser -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyAssignment -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Update-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -Exactly 1
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroupEligibilitySchedule' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilityScheduleRequest -Exactly 1
                Should -Invoke -CommandName Get-MgGroup -Exactly 2
                Should -Invoke -CommandName Get-MgBetaDirectoryObjectById -Exactly 1
                Should -Invoke -CommandName Get-MgUser -Exactly 1
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyAssignment -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Update-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -Exactly 1
                Should -Invoke -CommandName New-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilityScheduleRequest -Exactly 1
            }
        }

        Context -Name "The AADGroupEligibilitySchedule Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AccessId = "member"
                    MemberType = "direct"
                    GroupDisplayName     = "FakeStringValue"
                    Principal            = "John.Smith@contoso.com";
                    PrincipalType        = "User"
                    ScheduleInfo         = ([MSFT_MicrosoftGraphrequestSchedule] @{
                        startDateTime = '2025-01-23T08:59:00.0000000Z'
                        Expiration = ([MSFT_MicrosoftGraphExpirationPattern] @{
                                EndDateTime = '2025-12-23T08:59:00.0000000Z'
                                Type = 'afterDateTime'})
                        })
                    Ensure = "Present"
                    Credential = $Credential;
                }
                Mock -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -MockWith {
                    return @{
                        Id                   = 'GroupFakeId_member_FakeId'
                        AccessId             = 'member'
                        MemberType           = 'direct'
                        PrincipalId          = 'UserFakeId'
                        PrincipalType        = "User"
                        GroupId              = "GroupFakeId"
                        Status               = "Provisioned"
                        ScheduleInfo         = @{
                            StartDateTime = '2025-01-23T08:59:00.000Z'
                                Expiration = @{
                                    EndDateTime = '2025-12-23T08:59:00.000Z'
                                    type = 'afterDateTime'
                                }
                        }
                    }
                }
                mock -CommandName Get-MgUser -MockWith {
                    return @{
                        Id = 'UserFakeId'
                        UserPrincipalName = 'John.Smith@contoso.com'
                    }
                }

                mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        Id = 'GroupFakeId'
                        DisplayName = 'FakeStringValue'
                    }
                } -ParameterFilter {$Filter -eq "DisplayName eq 'FakeStringValue'"}

                Mock -CommandName Get-MgBetaDirectoryObjectById -MockWith {
                    return @{
                        '@odata.type' = '#microsoft.graph.user'
                        userPrincipalName = 'John.Smith@contoso.com'
                    }
                }

                Mock -CommandName New-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilityScheduleRequest -MockWith {
                    return $null
                }

                Mock  -CommandName Get-MgBetaPolicyRoleManagementPolicyAssignment -MockWith {
                    return @(
                        @{
                            PolicyId = 'FakeId'
                        }
                    )
                }

                Mock -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -MockWith {
                    return @{
                        isExpirationRequired = $true
                    }
                }

                Mock -CommandName Update-MgBetaPolicyRoleManagementPolicyRule -MockWith {
                    return @()
                }
            }

            It 'Should return true from the Test method' {
               (New-M365DSCResourceInstance -ResourceName 'AADGroupEligibilitySchedule' -Property $testParams).Test() | Should -Be $true

                Should -Invoke -CommandName Get-MgGroup -Exactly 1
                Should -Invoke -CommandName Get-MgBetaDirectoryObjectById -Exactly 1
                Should -Invoke -CommandName Get-MgUser -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyAssignment -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Update-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -Exactly 1
            }
        }

        Context -Name "The AADGroupEligibilitySchedule exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AccessId                 = "member"
                    MemberType               = "direct"
                    GroupDisplayName         = "FakeStringValue"
                    Principal                = "John.Smith@contoso.com";
                    PrincipalType            = "User"
                    ScheduleInfo             = ([MSFT_MicrosoftGraphrequestSchedule] @{
                        startDateTime = '2025-01-23T08:59:00.0000000+00:00'
                        Expiration = ([MSFT_MicrosoftGraphExpirationPattern] @{
                                EndDateTime = '2025-12-24T08:59:00.00000000+00:00' # Drift
                                Type = 'afterDateTime'})
                        })
                    Ensure                    = "Present"
                    Credential                = $Credential;
                }

                mock -CommandName Get-MgUser -MockWith {
                    return @{
                        Id = 'UserFakeId'
                        UserPrincipalName = 'John.Smith@contoso.com'
                    }
                }
                mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        Id = 'GroupFakeId'
                        DisplayName = 'FakeStringValue'
                    }
                }

                Mock -CommandName Get-MgBetaDirectoryObjectById -MockWith {
                    return @{
                        '@odata.type' = '#microsoft.graph.user'
                        userPrincipalName = 'John.Smith@contoso.com'
                    }
                }

                Mock -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -MockWith {
                    return @{
                        Id                   = 'GroupFakeId_member_FakeId'
                        AccessId             = 'member'
                        MemberType           = 'direct'
                        PrincipalId          = 'UserFakeId'
                        PrincipalType        = "User"
                        GroupId              = "GroupFakeId"
                        Status               = "Provisioned"
                        ScheduleInfo         = @{
                            StartDateTime = '2025-01-23T08:59:00.000Z'
                                Expiration = @{
                                    EndDateTime = '2025-12-23T08:59:00.000Z'
                                    type = 'afterDateTime'
                                }
                        }
                    }
                }

                Mock -CommandName New-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilityScheduleRequest -MockWith {
                    return $null
                }

                Mock  -CommandName Get-MgBetaPolicyRoleManagementPolicyAssignment -MockWith {
                    return @(
                        @{
                            PolicyId = 'FakeId'
                        }
                    )
                }

                Mock -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -MockWith {
                    return @{
                        isExpirationRequired = $true
                    }
                }

                Mock -CommandName Update-MgBetaPolicyRoleManagementPolicyRule -MockWith {
                    return @()
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGroupEligibilitySchedule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName Get-MgGroup -Exactly 1
                Should -Invoke -CommandName Get-MgBetaDirectoryObjectById -Exactly 1
                Should -Invoke -CommandName Get-MgUser -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyAssignment -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Update-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroupEligibilitySchedule' -Property $testParams).Test() | Should -Be $false
                Should -Invoke -CommandName Get-MgGroup -Exactly 1
                Should -Invoke -CommandName Get-MgBetaDirectoryObjectById -Exactly 1
                Should -Invoke -CommandName Get-MgUser -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyAssignment -Exactly 0
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Update-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -Exactly 1
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroupEligibilitySchedule' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilityScheduleRequest -Exactly 1
                Should -Invoke -CommandName Get-MgGroup -Exactly 2
                Should -Invoke -CommandName Get-MgBetaDirectoryObjectById -Exactly 1
                Should -Invoke -CommandName Get-MgUser -Exactly 1
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyAssignment -Exactly 1
                Should -Invoke -CommandName Get-MgBetaPolicyRoleManagementPolicyRule -Exactly 1
                Should -Invoke -CommandName Update-MgBetaPolicyRoleManagementPolicyRule -Exactly 0
                Should -Invoke -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -Exactly 1
                Should -Invoke -CommandName New-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilityScheduleRequest -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-M365DSCExportCachedCollection -ParameterFilter { $Collection -eq 'pimGroups' } -MockWith {
                    return @(
                        [PSCustomObject]@{
                            Id          = 'GroupFakeId'
                            DisplayName = 'FakeStringValue'
                        }
                    )
                }

                Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                    return @(
                        @{
                            id = 'GroupFakeId'
                            body = @{
                                value = @{
                                    Id                   = "GroupFakeId_member_FakeId"
                                    accessId             = 'member'
                                    groupDisplayName     = 'FakeStringValue'
                                    memberType           = 'direct'
                                    principalDisplayName = 'FakePrincipal'
                                    scheduleInfo         = @{
                                        startDateTime = '2025-01-23T08:59:00.000Z'
                                        expiration = @{
                                            endDateTime = '2025-12-22T08:59:00.000Z'
                                            type = 'afterDateTime'
                                        }
                                    }
                                }
                            }
                        }
                    )
                }

                mock -CommandName Get-MgUser -MockWith {
                    return @{
                        Id = 'UserFakeId'
                        UserPrincipalName = 'John.Smith@contoso.com'
                    }
                }

                mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        Id = 'GroupFakeId'
                        DisplayName = 'FakeStringValue'
                    }
                }

                Mock -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -MockWith {
                    return @{
                        Id                   = 'GroupFakeId_member_FakeId'
                        AccessId             = 'member'
                        MemberType           = 'direct'
                        PrincipalId          = 'UserFakeId'
                        PrincipalType        = "User"
                        GroupId              = "GroupFakeId"
                        Status               = "Provisioned"
                        ScheduleInfo         = @{
                            StartDateTime = '2025-01-23T08:59:00.000Z'
                                Expiration = @{
                                    EndDateTime = '2025-12-23T08:59:00.000Z'
                                    type = 'afterDateTime'
                                }
                        }
                    }
                }

                Mock -CommandName Get-MgBetaDirectoryObjectById -MockWith {
                    return @{
                        '@odata.type' = '#microsoft.graph.user'
                        userPrincipalName = 'John.Smith@contoso.com'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADGroupEligibilitySchedule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                Should -Invoke -CommandName Get-MgGroup -Exactly 1
                Should -Invoke -CommandName Get-MgBetaDirectoryObjectById -Exactly 2
                Should -Invoke -CommandName Get-MgUser -Exactly 0
                Should -Invoke -CommandName Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule -Exactly 0
            }

            It 'Should skip groups that are not enabled in PIM' {
                Mock -CommandName Get-M365DSCExportCachedCollection -ParameterFilter { $Collection -eq 'pimGroups' } -MockWith {
                    return @()
                }

                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADGroupEligibilitySchedule' -MethodName 'Export' -Parameters $testParams
                $result | Should -BeNullOrEmpty
                Should -Invoke -CommandName Get-MgBetaDirectoryObjectById -Exactly 0
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
