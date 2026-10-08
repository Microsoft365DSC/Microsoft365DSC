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
    -DscResource 'AADGroup' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Get-MgGroup -MockWith {
            }

            Mock -CommandName Get-MgBetaGroupMember -MockWith {
            }

            Mock -CommandName Get-MgBetaGroup -MockWith {
            }

            Mock -CommandName Restore-MgBetaDirectoryDeletedItem -MockWith {
            }

            Mock -CommandName Get-MgBetaDirectoryDeletedItemAsGroup -MockWith {
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            Mock -CommandName Update-MgBetaGroup -MockWith {
            }

            Mock -CommandName Remove-MgBetaGroup -MockWith {
            }

            Mock -CommandName New-MgBetaGroup -MockWith {
            }

            Mock -CommandName New-MgGroupOwnerByRef -MockWith {
            }

            Mock -CommandName New-MgBetaGroupMemberByRef -MockWith {
            }

            Mock -CommandName New-MgBetaGroupOwnerByRef -MockWith {
            }

            Mock -CommandName Remove-MgBetaRoleManagementDirectoryRoleAssignment -MockWith {
            }

            Mock -CommandName New-MgBetaGroupMember -MockWith {
            }

            Mock -CommandName New-MgBetaRoleManagementDirectoryRoleAssignment -MockWith {
            }

            Mock -CommandName Remove-MgGroupOwnerDirectoryObjectByRef -MockWith {
            }

            Mock -CommandName Remove-MgBetaGroupMemberDirectoryObjectByRef -MockWith {
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            Mock -CommandName Set-MgGroupLicense -MockWith {
            }

            Mock -CommandName Get-MgBetaRoleManagementDirectoryRoleAssignment -MockWith {
                return @{
                    PrincipalId = "12345-12345-12345-12345-12345"
                    RoleDefinitionId = "12345-12345-12345-12345-12345"
                }
            }

            Mock -CommandName Get-MgBetaRoleManagementDirectoryRoleDefinition -MockWith {
                return @{
                    Id          = "12345-12345-12345-12345-12345"
                    DisplayName = "AADRole"
                }
            }

            Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                return @()
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The Group should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $True
                    MailNickname           = 'M365DSC'
                    GroupTypes             = @('Unified')
                    Visibility             = 'Private'
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    GroupLifecyclePolicySelectedEnabled = $false
                    Owners                 = @('john.smith@contoso.com')
                    Members                = @('john.smith@contoso.com', 'jane.doe@contoso.com')
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgUser -MockWith {
                    return @{
                        Id = "id-$UserId"
                    }
                }

                Mock -CommandName Get-MgBetaGroupLifecyclePolicy -MockWith {
                    return @{
                        Id                = '12345-12345-12345-12345-12345'
                        ManagedGroupTypes = 'Selected'
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaGroup' -Exactly 1 -ParameterFilter {
                    -not $BodyParameter.ContainsKey('GroupLifecyclePolicySelectedEnabled') -and
                    $BodyParameter.'owners@odata.bind'.Count -eq 1 -and $BodyParameter.'owners@odata.bind'[0] -like '*/directoryObjects/id-john.smith@contoso.com' -and
                    $BodyParameter.'members@odata.bind'.Count -eq 2 -and $BodyParameter.'members@odata.bind'[1] -like '*/directoryObjects/id-jane.doe@contoso.com'
                }
                Should -Invoke -CommandName 'New-MgGroupOwnerByRef' -Exactly 0
                Should -Invoke -CommandName 'New-MgBetaGroupMemberByRef' -Exactly 0
            }
        }

        Context -Name 'The Group exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $True
                    MailNickname           = 'M365DSC'
                    GroupTypes             = @('Unified')
                    Visibility             = 'Private'
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    Ensure                 = 'Absent'
                    Credential             = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -MockWith {
                    return @{
                        DisplayName            = 'DSCGroup'
                        ID                     = '12345-12345-12345-12345-12345'
                        Theme                  = 'Blue'
                        WritebackConfiguration = @{
                            isEnabled           = $true
                            onPremisesGroupType = 'universalDistributionGroup'
                        }
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MgBetaGroup' -Exactly 1
            }
        }

        Context -Name 'The Group Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    ID                     = '12345-12345-12345-12345-12345'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $True
                    MailNickname           = 'M365DSC'
                    GroupTypes             = @('Unified')
                    Visibility             = 'Private'
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }


                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -MockWith {
                    return @{
                        DisplayName            = 'DSCGroup'
                        ID                     = '12345-12345-12345-12345-12345'
                        Description            = 'Microsoft DSC Group'
                        SecurityEnabled        = $True
                        MailEnabled            = $True
                        MailNickname           = 'M365DSC'
                        GroupTypes             = @('Unified')
                        Visibility             = 'Private'
                        Theme                  = 'Blue'
                        WritebackConfiguration = @{
                            isEnabled           = $true
                            onPremisesGroupType = 'universalDistributionGroup'
                        }
                    }
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The Group Exists with empty desired members' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    ID                     = '12345-12345-12345-12345-12345'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $True
                    MailNickname           = 'M365DSC'
                    GroupTypes             = @('Unified')
                    Members                = @()
                    GroupAsMembers         = @()
                    Visibility             = 'Private'
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -MockWith {
                    return @{
                        DisplayName            = 'DSCGroup'
                        ID                     = '12345-12345-12345-12345-12345'
                        Description            = 'Microsoft DSC Group'
                        SecurityEnabled        = $True
                        MailEnabled            = $True
                        MailNickname           = 'M365DSC'
                        GroupTypes             = @('Unified')
                        Visibility             = 'Private'
                        Members                = 1..20 | ForEach-Object {
                            @{
                                '@odata.type'      = '#microsoft.graph.user'
                                userPrincipalName = "user$_.contoso.com"
                            }
                        }
                        Theme                  = 'Blue'
                        WritebackConfiguration = @{
                            isEnabled           = $true
                            onPremisesGroupType = 'universalDistributionGroup'
                        }
                    }
                }
            }

            It 'Should not retrieve all group members from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaGroupMember' -Exactly 0
            }

            It 'Should return existing group members so empty desired members can detect drift' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()

                $result.Members | Should -Contain 'user1.contoso.com'
                Should -Invoke -CommandName 'Get-MgBetaGroupMember' -Exactly 0
            }
        }

        Context -Name 'The Group Exists and is a member of another group. Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    ID                     = '12345-12345-12345-12345-12345'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $True
                    GroupTypes             = @()
                    MailNickname           = 'M365DSC'
                    MemberOf               = 'DSCMemberOfGroup'
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -ParameterFilter { $GroupId -eq '12345-12345-12345-12345-12345' -or $Filter -eq "DisplayName eq 'DSCGroup'" } -MockWith {
                    return @{
                        DisplayName            = 'DSCGroup'
                        ID                     = '12345-12345-12345-12345-12345'
                        Description            = 'Microsoft DSC Group'
                        SecurityEnabled        = $True
                        MailEnabled            = $true
                        MailNickname           = 'M365DSC'
                        GroupTypes             = @()
                        Theme                  = 'Blue'
                        WritebackConfiguration = @{
                            isEnabled           = $true
                            onPremisesGroupType = 'universalDistributionGroup'
                        }
                    }
                }
                Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                    return @(
                        @{
                            id = 'MemberOf'
                            body = @{
                                value = @{
                                    '@odata.type' = '#microsoft.graph.group'
                                    displayName   = 'DSCMemberOfGroup'
                                }
                            }
                        }
                    )
                }
                Mock -CommandName Get-MgBetaGroup -ParameterFilter { $GroupId -eq '67890-67890-67890-67890' -or $Filter -eq "DisplayName eq 'DSCMemberOfGroup'" } -MockWith {
                    $returnData = @{
                        DisplayName     = 'DSCMemberOfGroup'
                        ID              = '67890-67890-67890-67890'
                        Description     = 'Microsoft DSC MemberOf Group'
                        SecurityEnabled = $True
                        GroupTypes      = @()
                        MailEnabled     = $True
                        MailNickname    = 'M365DSCM'
                    }
                    return $returnData
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
                Should -Invoke -CommandName 'Invoke-M365DSCGraphBatchRequest' -Exactly 1
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The Group Exists and is assigned to the correct role. Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    ID                     = '12345-12345-12345-12345-12345'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $True
                    GroupTypes             = @()
                    MailNickname           = 'M365DSC'
                    IsAssignableToRole     = $true
                    AssignedToRole         = 'AADRole'
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }


                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -MockWith {
                    return @{
                        DisplayName            = 'DSCGroup'
                        ID                     = '12345-12345-12345-12345-12345'
                        Description            = 'Microsoft DSC Group'
                        SecurityEnabled        = $True
                        MailEnabled            = $true
                        GroupTypes             = @()
                        MailNickname           = 'M365DSC'
                        IsAssignableToRole     = $true
                        Theme                  = 'Blue'
                        WritebackConfiguration = @{
                            isEnabled           = $true
                            onPremisesGroupType = 'universalDistributionGroup'
                        }
                    }
                }

                Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                    return @(
                        @{
                            id   = 'MemberOf'
                            body = @{
                                value = @{
                                    '@odata.type' = '#microsoft.graph.directoryRole'
                                    displayName   = 'AADRole'
                                }
                            }
                        }
                    )
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
                Should -Invoke -CommandName 'Invoke-M365DSCGraphBatchRequest' -Exactly 1
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The Group exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $True
                    MailNickname           = 'M365DSC'
                    GroupTypes             = @('Unified')
                    Visibility             = 'Private'
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -MockWith {
                    return @{
                        DisplayName            = 'DSCGroup'
                        Description            = 'Microsoft DSC' #Drift
                        SecurityEnabled        = $True
                        GroupTypes             = @('Unified')
                        MailEnabled            = $True
                        MailNickname           = 'M365DSC'
                        Visibility             = 'Private'
                        Id                     = '12345-12345-12345-12345-12345'
                        Theme                  = 'Blue'
                        WritebackConfiguration = @{
                            isEnabled           = $true
                            onPremisesGroupType = 'universalDistributionGroup'
                        }
                    }
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaGroup' -Exactly 1
            }
        }

        Context -Name 'The Group Exists but is not a member of another group. Values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    ID                     = '12345-12345-12345-12345-12345'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $true
                    GroupTypes             = @()
                    MailNickname           = 'M365DSC'
                    MemberOf               = 'DSCMemberOfGroup'
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }


                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }
                Mock -CommandName Get-MgBetaGroup -ParameterFilter { $GroupId -eq '12345-12345-12345-12345-12345' -or $Filter -eq "DisplayName eq 'DSCGroup'" } -MockWith {
                    $returnData = @{
                        DisplayName            = 'DSCGroup'
                        ID                     = '12345-12345-12345-12345-12345'
                        Description            = 'Microsoft DSC Group'
                        SecurityEnabled        = $True
                        MailEnabled            = $true
                        MailNickname           = 'M365DSC'
                        GroupTypes             = @()
                        Theme                  = 'Blue'
                        WritebackConfiguration = @{
                            isEnabled           = $true
                            onPremisesGroupType = 'universalDistributionGroup'
                        }
                    }
                    return $returnData
                }
                Mock -CommandName Get-MgBetaGroup -ParameterFilter { $GroupId -eq '67890-67890-67890-67890' -or $Filter -eq "DisplayName eq 'DSCMemberOfGroup'" } -MockWith {
                    $returnData = @{
                        DisplayName     = 'DSCMemberOfGroup'
                        ID              = '67890-67890-67890-67890'
                        Description     = 'Microsoft DSC MemberOf Group'
                        SecurityEnabled = $True
                        MailEnabled     = $true
                        GroupTypes      = @()
                        MailNickname    = 'M365DSCM'
                    }
                    return $returnData
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Set()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 2
            }
        }

        Context -Name 'The Group Exists but group is not assigned as member. Values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    ID                     = '12345-12345-12345-12345-12345'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $true
                    GroupTypes             = @()
                    MailNickname           = 'M365DSC'
                    IsAssignableToRole     = $true
                    GroupAsMembers         = @('DSCGroupMember')
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -MockWith {
                    return @{
                        DisplayName            = 'DSCGroupMember'
                        ID                     = '12345-12345-12345-12345-12345'
                        Description            = 'Microsoft DSC Group'
                        SecurityEnabled        = $True
                        MailEnabled            = $true
                        GroupTypes             = @()
                        MailNickname           = 'M365DSC'
                        IsAssignableToRole     = $true
                        AssignedToRole         = @()
                        Theme                  = 'Blue'
                        WritebackConfiguration = @{
                            isEnabled           = $true
                            onPremisesGroupType = 'universalDistributionGroup'
                        }
                        Ensure                 = 'Present'
                    }
                }

                Mock -CommandName New-MgBetaGroupMemberByRef -MockWith {
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Set()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 2
                Should -Invoke -CommandName 'New-MgBetaGroupMemberByRef' -Exactly 1
            }
        }

        Context -Name "The Group Exists and is assigned to a role but it shouldn't be. Values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    ID                     = '12345-12345-12345-12345-12345'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $true
                    GroupTypes             = @()
                    MailNickname           = 'M365DSC'
                    IsAssignableToRole     = $true
                    AssignedToRole         = @()
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }


                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -MockWith {
                    return @{
                        DisplayName            = 'DSCGroup'
                        ID                     = '12345-12345-12345-12345-12345'
                        Description            = 'Microsoft DSC Group'
                        SecurityEnabled        = $True
                        MailEnabled            = $true
                        GroupTypes             = @()
                        MailNickname           = 'M365DSC'
                        IsAssignableToRole     = $true
                        Theme                  = 'Blue'
                        WritebackConfiguration = @{
                            isEnabled           = $true
                            onPremisesGroupType = 'universalDistributionGroup'
                        }
                    }
                }
                Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                    return @(
                        @{
                            id   = 'MemberOf'
                            body = @{
                                value = @{
                                    '@odata.type' = '#microsoft.graph.directoryRole'
                                    displayName   = 'AADRole'
                                }
                            }
                        }
                    )
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
                Should -Invoke -CommandName 'Invoke-M365DSCGraphBatchRequest' -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Set()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
                Should -Invoke -CommandName 'Get-MgBetaRoleManagementDirectoryRoleDefinition' -Exactly 2
                Should -Invoke -CommandName 'Remove-MgBetaRoleManagementDirectoryRoleAssignment' -Exactly 1
            }
        }

        Context -Name "The Group does not exist and must be created and assigned a license. Values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    ID                     = '12345-12345-12345-12345-12345'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $false
                    GroupTypes             = @()
                    MailNickname           = 'M365DSC'
                    AssignedLicenses       = @(
                        ([MSFT_AADGroupLicense] @{
                            DisabledPlans  = [string[]]@()
                            SkuId          = 'AAD_PREMIUM_P2'
                        })
                    )
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -MockWith {
                }

                Mock -CommandName Get-MgBetaSubscribedSku -MockWith {
                    return [pscustomobject]@{
                        ServicePlans         = @(
                            @{
                                ServicePlanId   = '56789-56789-56789-56789'
                                ServicePlanName = 'Something_P2'
                            }
                        )
                        SkuId                = '12345-12345-12345-12345-12345'
                        SkuPartNumber        = 'AAD_PREMIUM_P2'
                    }
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaGroup' -Exactly 1
                Should -Invoke -CommandName 'Set-MgGroupLicense' -Exactly 1
            }
        }

        Context -Name "The Group exists and has been assigned the correct license. Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    ID                     = '12345-12345-12345-12345-12345'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $false
                    GroupTypes             = @()
                    MailNickname           = 'M365DSC'
                    AssignedLicenses       = @(
                        ([MSFT_AADGroupLicense] @{
                            DisabledPlans  = [string[]]@()
                            SkuId          = 'AAD_PREMIUM_P2'
                        })
                    )
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -MockWith {
                    return @{
                        DisplayName            = 'DSCGroup'
                        ID                     = '12345-12345-12345-12345-12345'
                        Description            = 'Microsoft DSC Group'
                        SecurityEnabled        = $True
                        MailEnabled            = $false
                        GroupTypes             = @()
                        MailNickname           = 'M365DSC'
                        IsAssignableToRole     = $false
                        AssignedLicenses       = @(
                            @{
                                DisabledPlans = @()
                                SkuId         = '12345-12345-12345'
                            }
                        )
                        Theme                  = 'Blue'
                        WritebackConfiguration = @{
                            isEnabled           = $true
                            onPremisesGroupType = 'universalDistributionGroup'
                        }
                    }
                }

                Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                    return @()
                }

                Mock -CommandName Get-MgBetaSubscribedSku -MockWith {
                    return [pscustomobject]@{
                        ServicePlans         = @(
                            @{
                                ServicePlanId   = '67890-67890-67890'
                                ServicePlanName = 'Something_P2'
                            }
                        )
                        SkuId                = '12345-12345-12345'
                        SkuPartNumber        = 'AAD_PREMIUM_P2'
                    }
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
                Should -Invoke -CommandName 'Invoke-M365DSCGraphBatchRequest' -Exactly 1
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The Group exists and is not assigned a license but it should be. Values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    ID                     = '12345-12345-12345-12345-12345'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $false
                    GroupTypes             = @()
                    MailNickname           = 'M365DSC'
                    AssignedLicenses       = @(
                        ([MSFT_AADGroupLicense] @{
                            DisabledPlans  = [string[]]@()
                            SkuId          = 'AAD_PREMIUM_P2'
                        })
                    )
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -MockWith {
                    return @{
                        DisplayName            = 'DSCGroup'
                        ID                     = '12345-12345-12345-12345-12345'
                        Description            = 'Microsoft DSC Group'
                        SecurityEnabled        = $True
                        MailEnabled            = $false
                        GroupTypes             = @()
                        MailNickname           = 'M365DSC'
                        IsAssignableToRole     = $false
                        Theme                  = 'Blue'
                        WritebackConfiguration = @{
                            isEnabled           = $true
                            onPremisesGroupType = 'universalDistributionGroup'
                        }
                    }
                }

                Mock -CommandName Get-MgBetaSubscribedSku -MockWith {
                    return [pscustomobject]@{
                        ServicePlans         = @(
                            @{
                                ServicePlanId   = '67890-67890-67890'
                                ServicePlanName = 'Something_P2'
                            }
                        )
                        SkuId                = '12345-12345-12345'
                        SkuPartNumber        = 'AAD_PREMIUM_P2'
                    }
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Set()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
                Should -Invoke -CommandName 'Set-MgGroupLicense' -Exactly 1
            }
        }
        Context -Name "The Group exists and is assigned a license but it shouldn't be. Values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    ID                     = '12345-12345-12345-12345-12345'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $false
                    GroupTypes             = @()
                    MailNickname           = 'M365DSC'
                    AssignedLicenses       = @()
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -MockWith {
                    return @{
                        DisplayName            = 'DSCGroup'
                        ID                     = '12345-12345-12345-12345-12345'
                        Description            = 'Microsoft DSC Group'
                        SecurityEnabled        = $True
                        MailEnabled            = $false
                        GroupTypes             = @()
                        MailNickname           = 'M365DSC'
                        IsAssignableToRole     = $false
                        AssignedLicenses       = @(
                            @{
                                DisabledPlans = @()
                                SkuId         = '12345-12345-12345'
                            }
                        )
                        Theme                  = 'Blue'
                        WritebackConfiguration = @{
                            isEnabled           = $true
                            onPremisesGroupType = 'universalDistributionGroup'
                        }
                    }
                }

                Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                    return @()
                }

                Mock -CommandName Get-MgBetaSubscribedSku -MockWith {
                    return [pscustomobject]@{
                        ServicePlans         = @(
                            @{
                                ServicePlanId   = '67890-67890-67890'
                                ServicePlanName = 'Something_P2'
                            }
                        )
                        SkuId                = '12345-12345-12345'
                        SkuPartNumber        = 'AAD_PREMIUM_P2'
                    }
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
                Should -Invoke -CommandName 'Invoke-M365DSCGraphBatchRequest' -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Set()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
                Should -Invoke -CommandName 'Set-MgGroupLicense' -Exactly 1
            }
        }

        Context -Name "The Group exists and is assigned a license. Tested values are in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = 'DSCGroup'
                    ID                     = '12345-12345-12345-12345-12345'
                    Description            = 'Microsoft DSC Group'
                    SecurityEnabled        = $True
                    MailEnabled            = $false
                    GroupTypes             = @()
                    MailNickname           = 'M365DSC'
                    Theme                  = 'Blue'
                    WritebackConfiguration = ([MSFT_MicrosoftGraphGroupWritebackConfiguration] @{
                        IsEnabled           = $true
                        OnPremisesGroupType = 'universalDistributionGroup'
                    })
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -MockWith {
                    return @{
                        DisplayName            = 'DSCGroup'
                        ID                     = '12345-12345-12345-12345-12345'
                        Description            = 'Microsoft DSC Group'
                        SecurityEnabled        = $True
                        MailEnabled            = $false
                        GroupTypes             = @()
                        MailNickname           = 'M365DSC'
                        IsAssignableToRole     = $false
                        Theme                  = 'Blue'
                        WritebackConfiguration = @{
                            isEnabled           = $true
                            onPremisesGroupType = 'universalDistributionGroup'
                        }
                    }
                }

                Mock -CommandName Get-MgBetaSubscribedSku -MockWith {
                    return [pscustomobject]@{
                        ServicePlans         = @(
                            @{
                                ServicePlanId   = '67890-67890-67890'
                                ServicePlanName = 'Something_P2'
                            }
                        )
                        SkuId                = '12345-12345-12345'
                        SkuPartNumber        = 'AAD_PREMIUM_P2'
                    }
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaGroup' -Exactly 1
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroup' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaGroup -MockWith {
                    return @{
                        DisplayName            = 'DSCGroup'
                        ID                     = '12345-12345-12345-12345-12345'
                        Description            = 'Microsoft DSC Group'
                        SecurityEnabled        = $True
                        MailEnabled            = $False
                        GroupTypes             = @("Unified")
                        MailNickname           = 'M365DSC'
                        IsAssignableToRole     = $true
                        Theme                  = 'Blue'
                        WritebackConfiguration = @{
                            isEnabled           = $true
                            onPremisesGroupType = 'universalDistributionGroup'
                        }
                        Ensure                 = 'Present'
                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADGroup' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
