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
    -DscResource 'AADAdministrativeUnit' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -CommandName Add-M365DSCTelemetryEvent -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Get-MgUser -MockWith {
                return [pscustomobject]@{
                    Id                = '1234567890'
                    DisplayName       = 'John Doe'
                    UserPrincipalName = 'John.Doe@mytenant.com'
                }
            }

            Mock -CommandName Get-MgDirectoryRole -MockWith {
                return @(
                    @{
                        Id          = '12345-67890'
                        DisplayName = 'User Administrator'
                    }
                    @{
                        Id          = '12345-67890-2'
                        DisplayName = 'DSC User Administrator'
                    }
                    @{
                        Id          = '09876-54321'
                        DisplayName = 'DSC Groups Administrator'
                    }
                )
            }

            Mock -CommandName Get-MgDirectoryAdministrativeUnit -MockWith {
                return @{
                    Description = 'DSCAU'
                    DisplayName = 'DSCAU'
                    Id          = 'DSCAU'
                }
            }

            Mock -CommandName Update-MgDirectoryAdministrativeUnit -MockWith {
            }

            Mock -CommandName New-MgDirectoryAdministrativeUnit -MockWith {
            }

            Mock -CommandName New-MgDirectoryAdministrativeUnitMemberByRef -MockWith {
            }

            Mock -CommandName New-MgDirectoryAdministrativeUnitScopedRoleMember -MockWith {
            }

            Mock -CommandName Remove-MgDirectoryAdministrativeUnit -MockWith {
            }

            Mock -CommandName Remove-MgDirectoryAdministrativeUnitMemberDirectoryObjectByRef -MockWith {
            }

            Mock -CommandName Remove-MgDirectoryAdministrativeUnitScopedRoleMember -MockWith {
            }
            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name 'The AU should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = 'FakeStringValue1'
                    DisplayName = 'FakeStringValue1'
                    Id          = 'FakeStringValue1'
                    Members     = @(
                        ([MSFT_MicrosoftGraphMember] @{
                            Type     = 'User'
                            Identity = 'john.smith@contoso.com'
                        })
                    )
                    Visibility  = 'Public'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }

                Mock -CommandName Get-MgDirectoryAdministrativeUnit -MockWith {
                    return $null
                }
                Mock -CommandName Get-MgDirectoryAdministrativeUnitMember -MockWith {
                    return $null
                }
                Mock -CommandName Get-MgDirectoryAdministrativeUnitScopedRoleMember -MockWith {
                    return $null
                }
                Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                    return @(
                        @{
                            id = '1234567890'
                            body = @{
                                '@odata.type' = '#microsoft.graph.user'
                                id            = '1234567890'
                            }
                        }
                    )
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the AU from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgDirectoryAdministrativeUnit -Exactly 1
            }
        }

        Context -Name 'The AU exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = 'FakeStringValue2'
                    DisplayName = 'FakeStringValue2'
                    Id          = 'FakeStringValue2'
                    Members     = @(
                        ([MSFT_MicrosoftGraphMember] @{
                            Type     = 'User'
                            Identity = 'john.smith@contoso.com'
                        })
                    )
                    Ensure      = 'Absent'
                    Credential  = $Credential
                }

                Mock -CommandName Get-MgDirectoryAdministrativeUnit -MockWith {
                    return @{
                        Description = 'FakeStringValue2'
                        DisplayName = 'FakeStringValue2'
                        Id          = 'FakeStringValue2'
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the AU from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgDirectoryAdministrativeUnit -Exactly 1
            }
        }

        Context -Name 'The AU exists and values are already in desired state - without ID/Ensure' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = 'FakeStringValue2'
                    DisplayName = 'FakeStringValue2'
                    Credential  = $Credential
                }

                Mock -CommandName Get-MgDirectoryAdministrativeUnit -MockWith {
                    return @{
                        Description = 'FakeStringValue2'
                        DisplayName = 'FakeStringValue2'
                        Id          = 'FakeStringValue2'
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Two identically-named AUs exists and ID is not specified. Should throw' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = 'FakeStringValue2'
                    DisplayName = 'FakeStringValueDuplicated'
                    Credential  = $Credential
                }

                Mock -CommandName Get-MgDirectoryAdministrativeUnit -MockWith {
                    return @(
                        @{
                            Description = 'FakeStringValue2'
                            DisplayName = 'FakeStringValueDuplicated'
                            Id          = 'FakeStringValue2'
                        },
                        @{
                            Description = 'FakeStringValue3'
                            DisplayName = 'FakeStringValueDuplicated'
                            Id          = 'FakeStringValue3'
                        }
                    )
                }
            }

            It 'Should throw in the Get method' {
                {(New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Get().ToHashtable()} | Should -Throw -ExpectedMessage '*Multiple Azure AD Administrative Units with DisplayName {*} were found. Please specify the Id of the desired Administrative Unit*'
            }
        }

        Context -Name 'The AU Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                   = 'DSCAU'
                    DisplayName                   = 'DSCAU'
                    Id                            = 'DSCAU'
                    Members                       = @(
                        ([MSFT_MicrosoftGraphMember] @{
                            Identity = 'John.Doe@mytenant.com'
                            Type     = 'User'
                        })
                    )
                    ScopedRoleMembers             = @(
                        ([MSFT_MicrosoftGraphScopedRoleMembership] @{
                            RoleName       = 'User Administrator'
                            RoleMemberInfo = ([MSFT_MicrosoftGraphMember] @{
                                    Identity = 'John.Doe@mytenant.com'
                                    Type     = 'User'
                                })
                            #Identity = 'John.Doe@mytenant.com'
                            #Type     = 'User'
                        })
                    )
                    Visibility                    = 'Public'
                    MembershipType                = 'Assigned'
                    # MembershipRule and -ProcessingState params are only used when MembershipType is Dynamic
                    MembershipRule                = 'Canada'
                    MembershipRuleProcessingState = 'On'
                    Ensure                        = 'Present'
                    Credential                    = $Credential
                }

                # Note: It is in fact possible to update the AU MembershipRule with any invalid value, but in the AAD-portal, updates are not possible unless the rule is valid.
                Mock -CommandName Get-MgDirectoryAdministrativeUnitMember -MockWith {
                    return @(@{
                            Id = '1234567890'
                            '@odata.type' = '#microsoft.graph.user'
                            userPrincipalName = 'John.Doe@mytenant.com'
                        })
                }
                Mock -CommandName Get-MgDirectoryAdministrativeUnitScopedRoleMember -MockWith {
                    return @(
                        @{
                            RoleId         = '12345-67890'
                            RoleMemberInfo = @{
                                DisplayName = 'John Doe'
                                Id          = '1234567890'
                                UserPrincipalName = 'John.Doe@mytenant.com'
                            }
                        }
                    )
                }
                Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                    return @(
                        @{
                            id = '1234567890'
                            body = @{
                                '@odata.type'     = '#microsoft.graph.user'
                                Id                = '1234567890'
                            }
                        }
                    )
                }
                Mock -CommandName Get-MgDirectoryAdministrativeUnit -MockWith {
                    return @{
                        Description = 'DSCAU'
                        DisplayName = 'DSCAU'
                        Id          = 'DSCAU'
                        MembershipType = 'Assigned'
                        MembershipRule = 'Canada'
                        MembershipRuleProcessingState = 'On'
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Test() | Should -Be $true
            }
        }
        Context -Name 'The AU Exists and specified Values are NOT in the desired state (leaving Members and ScopedRoleMembers as-is)' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                   = 'DSCAU New Description'
                    DisplayName                   = 'DSCAU'
                    Id                            = 'DSCAU'
                    Ensure                        = 'Present'
                    Credential                    = $Credential
                }

                # Note: It is in fact possible to update the AU MembershipRule with any invalid value, but in the AAD-portal, updates are not possible unless the rule is valid.
                Mock -CommandName Get-MgDirectoryAdministrativeUnitMember -MockWith {
                    return @(
                        @{
                            Id = '1234567890'
                            '@odata.type' = '#microsoft.graph.user'
                            userPrincipalName = 'John.Doe@mytenant.com'
                        }
                    )
                }
                Mock -CommandName Get-MgDirectoryAdministrativeUnitScopedRoleMember -MockWith {
                    return @(
                        @{
                            RoleId         = '12345-67890'
                            RoleMemberInfo = @{
                                DisplayName = 'John Doe'
                                Id          = '1234567890'
                                UserPrincipalName = 'John.Doe@mytenant.com'
                            }
                        }
                    )
                }
                Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                    return @(
                        @{
                            id = '1234567890'
                            body = @{
                                '@odata.type'     = '#microsoft.graph.user'
                                Id                = '1234567890'
                            }
                        }
                    )
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method without removing existing Members or ScopedRoleMembers' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Set()
                Should -Not -Invoke -CommandName Remove-MgDirectoryAdministrativeUnitMemberDirectoryObjectByRef
                Should -Not -Invoke -CommandName Remove-MgDirectoryAdministrativeUnitScopedRoleMember
            }

        }
        Context -Name 'The AU exists and values (Members contains a User) are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description       = 'DSCAU'
                    DisplayName       = 'DSCAU'
                    Id                = 'DSCAU'
                    Members           = @(
                            ([MSFT_MicrosoftGraphMember] @{
                            Identity = 'John.Doe@mytenant.com'
                            Type     = 'User'
                        })
                    )
                    Visibility        = 'Public'
                    Ensure            = 'Present'
                    Credential        = $Credential
                }

                Mock -CommandName Get-MgDirectoryAdministrativeUnitMember -MockWith {
                    return $null
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgDirectoryAdministrativeUnitMemberByRef -Exactly 1
            }
        }

        Context -Name 'The AU exists and values (Members contains a Group) are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description       = 'DSCAU2'
                    DisplayName       = 'DSCAU2'
                    Id                = 'DSCAU2'
                    Members           = @(
                            ([MSFT_MicrosoftGraphMember] @{
                            Identity = 'DSCAUMemberGroup'
                            Type     = 'Group'
                        })
                    )
                    Visibility        = 'Public'

                    Ensure            = 'Present'
                    Credential        = $Credential
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return [pscustomobject]@{
                        Id                = '1234567890'
                        DisplayName       = 'DSCAUMemberGroup'
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgDirectoryAdministrativeUnitMemberByRef -Exactly 1
            }
        }

        Context -Name 'The AU exists and values (Members contains a Device) are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description       = 'DSCAU'
                    DisplayName       = 'DSCAU'
                    Id                = 'DSCAU'
                    Members           = @(
                            ([MSFT_MicrosoftGraphMember] @{
                            Identity = 'DSCAUMemberDevice'
                            Type     = 'Device'
                        })
                    )
                    Visibility        = 'Public'
                    Ensure            = 'Present'
                    Credential        = $Credential
                }

                Mock -CommandName Get-MgDevice -MockWith {
                    return [pscustomobject]@{
                        Id                = '1234567890'
                        DisplayName       = 'DSCAUMemberDevice'
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgDirectoryAdministrativeUnitMemberByRef -Exactly 1
            }
        }

        Context -Name 'The AU exists and values (ScopedRoleMembers contains a User) are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description       = 'DSCAU'
                    DisplayName       = 'DSCAU'
                    Id                = 'DSCAU'
                    ScopedRoleMembers = @(
                        ([MSFT_MicrosoftGraphScopedRoleMembership] @{
                            RoleName       = 'User Administrator'
                            RoleMemberInfo = ([MSFT_MicrosoftGraphMember] @{
                                    Identity = 'John.Doe@mytenant.com'
                                    Type     = 'User'
                                })
                            #Identity = 'John.Doe@mytenant.com'
                            #Type     = 'User'
                        })
                    )
                    Visibility        = 'Public'
                    Ensure            = 'Present'
                    Credential        = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgDirectoryAdministrativeUnitScopedRoleMember -Exactly 1
            }
        }

        Context -Name 'The AU exists and values (ScopedRoleMembers contains a Group) are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description       = 'DSCAU'
                    DisplayName       = 'DSCAU'
                    Id                = 'DSCAU'
                    ScopedRoleMembers = @(
                        ([MSFT_MicrosoftGraphScopedRoleMembership] @{
                            RoleName       = 'User Administrator'
                            RoleMemberInfo = ([MSFT_MicrosoftGraphMember] @{
                                    Identity = 'DSCScopedRoleUserAdmins'
                                    Type     = 'Group'
                                })
                        })
                    )
                    Visibility        = 'Public'
                    Ensure            = 'Present'
                    Credential        = $Credential
                }

                Mock -CommandName Get-MgDirectoryAdministrativeUnit -MockWith {
                    return [pscustomobject]@{
                        Description = 'DSCAU'
                        DisplayName = 'DSCAU'
                        Id          = 'DSCAU'
                        Visibility  = 'Public'
                    }
                }
                Mock -CommandName Get-MgGroup -MockWith {
                    return [pscustomobject]@{
                        Id                = '1234567890'
                        DisplayName       = 'DSCScopedRoleUserAdmins'
                        IsAssignableToRole = $true
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgDirectoryAdministrativeUnitScopedRoleMember -Exactly 1
            }
        }

        Context -Name 'The AU exists, attempt to add as a ScopedRoleMember a Group that is NOT role-enabled. Should throw' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description       = 'DSCAU New Description'
                    DisplayName       = 'DSCAU'
                    Id                = 'DSCAU'
                    ScopedRoleMembers = @(
                        ([MSFT_MicrosoftGraphScopedRoleMembership] @{
                            RoleName       = 'User Administrator'
                            RoleMemberInfo = ([MSFT_MicrosoftGraphMember] @{
                                    Identity = 'DSCNotARoleGroup'
                                    Type     = 'Group'
                                })
                        })
                    )
                    Ensure            = 'Present'
                    Credential        = $Credential
                }

                Mock -CommandName Get-MgDirectoryAdministrativeUnit -MockWith {
                    return [pscustomobject]@{
                        Description = 'DSCAU Old Description'
                        DisplayName = 'DSCAU'
                        Id          = 'DSCAU'
                    }
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return [pscustomobject]@{
                        Id                = '1234567890'
                        DisplayName       = 'DSCNotARoleGroup'
                        IsAssignableToRole = $false
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should call the Set method and throw' {
                {(New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Set()} | Should -Throw -ExpectedMessage '*scoped role group*is not role-enabled*'
            }
        }

        Context -Name 'The AU exists and values (ScopedRoleMembers contains an SPN) are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description       = 'DSCAU'
                    DisplayName       = 'DSCAU'
                    Id                = 'DSCAU'
                    ScopedRoleMembers = @(
                        ([MSFT_MicrosoftGraphScopedRoleMembership] @{
                            RoleName       = 'User Administrator'
                            RoleMemberInfo = ([MSFT_MicrosoftGraphMember] @{
                                    Identity = 'DSCScopedRoleSPN'
                                    Type     = 'ServicePrincipal'
                                })
                        })
                    )
                    Visibility        = 'Public'
                    Ensure            = 'Present'
                    Credential        = $Credential
                }

                Mock -CommandName Get-MgDirectoryAdministrativeUnit -MockWith {
                    return [pscustomobject]@{
                        Description = 'DSCAU'
                        DisplayName = 'DSCAU'
                        Id          = 'DSCAU'
                        Visibility  = 'Public'
                    }
                }

                Mock -CommandName Get-MgServicePrincipal -MockWith {
                    return [pscustomobject]@{
                        Id                = '1234567890'
                        DisplayName       = 'DSCScopedRoleSPN'
                    }
                }

                Mock -CommandName Get-MgDirectoryAdministrativeUnitScopedRoleMember -MockWith {
                    return $null
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAdministrativeUnit' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgDirectoryAdministrativeUnitScopedRoleMember -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgDirectoryAdministrativeUnit -MockWith {
                    return @{
                        Description = 'ExportDSCAU'
                        DisplayName = 'ExportDSCAU'
                        Id          = 'ExportDSCAU'
                        Visibility  = 'Public'
                    }
                }

                Mock -CommandName Get-MgDirectoryAdministrativeUnitMember -MockWith {
                    return [pscustomobject]@{
                        Id = '1234567890'
                        '@odata.type' = '#microsoft.graph.user'
                        userPrincipalName = 'John.Doe@mytenant.com'
                    }
                }

                Mock -CommandName Get-MgDirectoryAdministrativeUnitScopedRoleMember -MockWith {
                    return @([pscustomobject]@{
                            RoleId         = '12345-67890'
                            RoleMemberInfo = @{
                                DisplayName = 'John Doe'
                                Id          = '1234567890'
                                UserPrincipalName = 'John.Doe@mytenant.com'
                            }
                        },
                        [pscustomobject]@{
                            RoleId         = '09876-54321'
                            RoleMemberInfo = @{
                                DisplayName = 'FakeRoleGroup'
                                Id          = '0987654321'
                            }
                        })
                }

                Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                    return @(
                        @{
                            id = '1234567890'
                            body = @{
                                '@odata.type' = '#microsoft.graph.user'
                                id            = '1234567890'
                            }
                        }
                        @{
                            id = '0987654321'
                            body = @{
                                '@odata.type' = '#microsoft.graph.group'
                                id            = '0987654321'
                            }
                        }
                    )
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADAdministrativeUnit' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
