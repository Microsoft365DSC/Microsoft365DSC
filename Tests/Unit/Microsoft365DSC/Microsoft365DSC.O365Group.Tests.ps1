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
    -DscResource 'O365Group' -GenericStubModule $GenericStubPath
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
        Context -Name "When the group doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName  = 'Test Group'
                    MailNickName = 'TestGroup'
                    Description  = 'This is a test'
                    ManagedBy    = 'JohnSmith@contoso.onmicrosoft.com'
                    Members      = @('JaneDoe@contoso.onmicrosoft.com')
                    Theme        = 'Teal'
                    Ensure       = 'Present'
                    Credential   = $Credential
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return $null
                }

                Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
                    return @{
                        ResourceUrl = 'https://graph.microsoft.com/'
                    }
                }

                Mock -CommandName Get-MgUser -MockWith {
                    return @{
                        Id = $UserId.Split('@')[0]
                    }
                }

                Mock -CommandName New-MgGroup -MockWith {
                    return @{
                        Id = '12345-12345-12345-12345-12345'
                    }
                }

                Mock -CommandName New-MgGroupMemberByRef -MockWith {
                }

                Mock -CommandName New-MgGroupOwnerByRef -MockWith {
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'O365Group' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should create the Group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'O365Group' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgGroup -Exactly 1 -ParameterFilter {
                    $BodyParameter.'owners@odata.bind' -contains 'https://graph.microsoft.com/v1.0/directoryObjects/JohnSmith' -and
                    $BodyParameter.'members@odata.bind' -contains 'https://graph.microsoft.com/v1.0/directoryObjects/JaneDoe'
                }
                Should -Invoke -CommandName New-MgGroupMemberByRef -Exactly 0
                Should -Invoke -CommandName New-MgGroupOwnerByRef -Exactly 0
            }
        }

        Context -Name 'When the group already exists' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName  = 'Test Group'
                    MailNickName = 'TestGroup'
                    ManagedBy    = 'Bob.Houle@contoso.onmicrosoft.com'
                    Description  = 'This is a test'
                    Theme        = 'Teal'
                    Ensure       = 'Present'
                    Credential   = $Credential
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        DisplayName  = 'Test Group'
                        Id           = 'a53dbbd6-7e9b-4df9-841a-a2c3071a1770'
                        Members      = @('John.Smith@contoso.onmcirosoft.com')
                        MailNickName = 'TestGroup'
                        Owners       = @('Bob.Houle@contoso.onmcirosoft.com')
                        Description  = 'This is a test'
                        Theme        = 'Teal'
                    }
                }

                Mock -CommandName Get-MgGroupMember -MockWith {
                    return @{
                        UserPrincipalName = 'John.smith@contoso.onmicrosoft.com'
                    }
                }

                Mock -CommandName Get-MgGroupOwner -MockWith {
                    return @{
                        UserPrincipalName = 'Bob.Houle@contoso.onmicrosoft.com'
                    }
                }
            }

            Mock -CommandName Get-MgUser -MockWith {
                return @{
                    Id = '12345-12345-12345-12345-12345'
                }
            }
            Mock -CommandName New-MgGroupOwnerByRef -MockWith {
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'O365Group' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'O365Group' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should update the new Group in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'O365Group' -Property $testParams).Set()
            }
        }

        Context -Name 'Office 365 Group - When the group already exists but with different members' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName  = 'Test Group'
                    MailNickName = 'TestGroup'
                    Description  = 'This is a test'
                    Members      = @('GoodUser1', 'GoodUser2')
                    ManagedBy    = @('JohnSmith@contoso.onmicrosoft.com', 'Bob.Houle@contoso.onmicrosoft.com')
                    Theme        = 'Teal'
                    Ensure       = 'Present'
                    Credential   = $Credential
                }

                Mock -CommandName Get-MgGroupMember
                {
                    return (@{
                            Identity = 'Test Group'
                            Name     = 'GoodUser1'
                        },
                        @{
                            LinkType = 'Members'
                            Identity = 'Test Group'
                            Name     = 'BadUser1'
                        },
                        @{
                            LinkType = 'Members'
                            Identity = 'Test Group'
                            Name     = 'GoodUser2'
                        })
                }

                Mock -CommandName Get-MgGroupOwner
                {
                    return @(@{
                            UserPrincipalName = 'JohnSmith@contoso.onmicrosoft.com'
                        },
                        @{
                            UserPrincipalName = 'JohnSmith@contoso.onmicrosoft.com'
                        })
                }

                Mock -CommandName Get-MgUser -MockWith {
                    return @{
                        Id = '12345-12345-12345-12345-12345'
                    }
                }

                Mock -CommandName New-MgGroupOwnerByRef -MockWith {

                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        DisplayName  = 'Test Group'
                        MailNickName = 'TestGroup'
                        Description  = 'This is a test'
                        Theme        = 'Teal'
                        ID           = 'a53dbbd6-7e9b-4df9-841a-a2c3071a1770'
                    }
                }

                Mock -CommandName New-MgGroup -MockWith {

                }

                Mock -CommandName New-MgGroupMemberByRef -MockWith {

                }

                Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {

                }

                Mock -CommandName Get-MgGroupMember -MockWith {
                    return @(
                        @{
                            UserPrincipalName = 'JohnSmith@contoso.onmicrosoft.com'
                        },
                        @{
                            UserPrincipalName = 'SecondUser@contoso.onmicrosoft.com'
                        }
                    )
                }

                Mock -CommandName Get-MgGroupOwner -MockWith {
                    return @{
                        UserPrincipalName = 'Bob.Houle@contoso.onmicrosoft.com'
                    }
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'O365Group' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'O365Group' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the membership list in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'O365Group' -Property $testParams).Set()
            }
        }

        Context -Name 'Office 365 Group - When the group already exists with different members and no owners are specified' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName  = 'Test Group'
                    MailNickName = 'TestGroup'
                    Description  = 'This is a test'
                    Members      = @('JohnSmith@contoso.onmicrosoft.com')
                    Theme        = 'Teal'
                    Ensure       = 'Present'
                    Credential   = $Credential
                }

                Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
                    return @{
                        ResourceUrl = 'https://graph.microsoft.com/'
                    }
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        DisplayName  = 'Test Group'
                        MailNickName = 'TestGroup'
                        Description  = 'This is a test'
                        Theme        = 'Teal'
                        Id           = 'a53dbbd6-7e9b-4df9-841a-a2c3071a1770'
                    }
                }

                Mock -CommandName Get-MgGroupMember -MockWith {
                    return @{
                        UserPrincipalName = 'SecondUser@contoso.onmicrosoft.com'
                    }
                }

                Mock -CommandName Get-MgGroupOwner -MockWith {
                    return @{
                        UserPrincipalName = 'Bob.Houle@contoso.onmicrosoft.com'
                    }
                }

                Mock -CommandName Get-MgUser -MockWith {
                    return @{
                        Id = '12345-12345-12345-12345-12345'
                    }
                }

                Mock -CommandName New-MgGroupMemberByRef -MockWith {
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                }
            }

            It 'Should add the desired member in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'O365Group' -Property $testParams).Set()

                Should -Invoke -CommandName New-MgGroupMemberByRef -Exactly 1 -ParameterFilter {
                    $GroupId -eq 'a53dbbd6-7e9b-4df9-841a-a2c3071a1770' -and
                    $BodyParameter['@odata.id'] -eq 'https://graph.microsoft.com/v1.0/directoryObjects/12345-12345-12345-12345-12345'
                }
            }

            It 'Should remove the undesired member in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'O365Group' -Property $testParams).Set()

                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'DELETE' -and
                    $Uri -eq '/v1.0/groups/a53dbbd6-7e9b-4df9-841a-a2c3071a1770/members/12345-12345-12345-12345-12345/$ref'
                }
            }

            It 'Should leave the existing owners untouched in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'O365Group' -Property $testParams).Set()

                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 0 -ParameterFilter {
                    $Uri -like '*/owners/*'
                }
            }
        }

        Context -Name 'Office 365 Group - When the group already exists with a different theme' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName  = 'Test Group'
                    MailNickName = 'TestGroup'
                    Description  = 'This is a test'
                    Theme        = 'Purple'
                    Ensure       = 'Present'
                    Credential   = $Credential
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        DisplayName  = 'Test Group'
                        MailNickName = 'TestGroup'
                        Description  = 'This is a test'
                        Theme        = 'Teal'
                        Id           = 'a53dbbd6-7e9b-4df9-841a-a2c3071a1770'
                    }
                }

                Mock -CommandName Get-MgGroupMember -MockWith {
                    return @{
                        UserPrincipalName = 'JohnSmith@contoso.onmicrosoft.com'
                    }
                }

                Mock -CommandName Get-MgGroupOwner -MockWith {
                    return @{
                        UserPrincipalName = 'Bob.Houle@contoso.onmicrosoft.com'
                    }
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                }
            }

            It 'Should return the current theme from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'O365Group' -Property $testParams).Get().ToHashtable()).Theme | Should -Be 'Teal'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'O365Group' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the theme in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'O365Group' -Property $testParams).Set()

                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'PATCH' -and
                    $Uri -eq '/v1.0/groups/a53dbbd6-7e9b-4df9-841a-a2c3071a1770' -and
                    $Body['theme'] -eq 'Purple'
                }
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        DisplayName  = 'Test Group'
                        MailNickName = 'TestGroup'
                        Description  = 'This is a test'
                        Theme        = 'Teal'
                        ID           = 'a53dbbd6-7e9b-4df9-841a-a2c3071a1770'
                    }
                }

                Mock -CommandName Get-MgGroupMember -MockWith {
                    return @(
                        @{
                            UserPrincipalName = 'JohnSmith@contoso.onmicrosoft.com'
                        },
                        @{
                            UserPrincipalName = 'SecondUser@contoso.onmicrosoft.com'
                        }
                    )
                }

                Mock -CommandName Get-MgGroupOwner -MockWith {
                    return @{
                        UserPrincipalName = 'Bob.Houle@contoso.onmicrosoft.com'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'O365Group' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
