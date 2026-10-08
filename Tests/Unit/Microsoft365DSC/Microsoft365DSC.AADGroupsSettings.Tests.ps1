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
    -DscResource 'AADGroupsSettings' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDirectorySetting -MockWith {
            }

            Mock -CommandName Remove-MgBetaDirectorySetting -MockWith {
            }

            Mock -CommandName New-MgBetaDirectorySetting -MockWith {
            }

            Mock -CommandName 'Get-MgGroup' -MockWith {
                return @{
                    ObjectId    = '12345-12345-12345-12345-12345'
                    DisplayName = 'All Company'
                }
            }

            Mock -CommandName Get-MgBetaDirectorySetting -MockWith {
                if (-not $Script:calledOnceAlready)
                {
                    $Script:calledOnceAlready = $true
                    return $null
                }
                else
                {
                    return @{
                        DisplayName = 'Group.Unified'
                        Values      = @(
                            @{
                                Name  = 'NewUnifiedGroupWritebackDefault'
                                Value = $true
                            },
                            @{
                                Name  = 'GroupCreationAllowedGroupId'
                                Value = '12345-12345-12345-12345-12345'
                            },
                            @{
                                Name  = 'EnableGroupCreation'
                                Value = $true
                            },
                            @{
                                Name  = 'EnableMIPLabels'
                                Value = $true
                            },
                            @{
                                Name  = 'AllowGuestsToBeGroupOwner'
                                Value = $true
                            },
                            @{
                                Name  = 'AllowGuestsToAccessGroups'
                                Value = $true
                            },
                            @{
                                Name  = 'GuestUsageGuidelinesUrl'
                                Value = 'https://contoso.com/guestusage'
                            },
                            @{
                                Name  = 'AllowToAddGuests'
                                Value = $true
                            },
                            @{
                                Name  = 'UsageGuidelinesUrl'
                                Value = 'https://contoso.com/usage'
                            }
                        )
                    }
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The Policy should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $Script:calledOnceAlready = $false
                $testParams = @{
                    AllowGuestsToAccessGroups     = $True
                    AllowGuestsToBeGroupOwner     = $True
                    AllowToAddGuests              = $True
                    EnableGroupCreation           = $True
                    Ensure                        = 'Present'
                    Credential                    = $Credential
                    GroupCreationAllowedGroupName = 'All Company'
                    GuestUsageGuidelinesUrl       = 'https://contoso.com/guestusage'
                    IsSingleInstance              = 'Yes'
                    UsageGuidelinesUrl            = 'https://contoso.com/usage'
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADGroupsSettings' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-MgBetaDirectorySetting' -Exactly 1
            }

            It 'Should return true from the Test method' {
                $Script:calledOnceAlready = $false
                (New-M365DSCResourceInstance -ResourceName 'AADGroupsSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create and set the settings the Set method' {
                $Script:calledOnceAlready = $false
                (New-M365DSCResourceInstance -ResourceName 'AADGroupsSettings' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDirectorySetting' -Exactly 1
                Should -Invoke -CommandName 'Update-MgBetaDirectorySetting' -Exactly 1
            }
        }

        Context -Name 'The Policy exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    Ensure           = 'Absent'
                    Credential       = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                $Script:calledOnceAlready = $true
                ((New-M365DSCResourceInstance -ResourceName 'AADGroupsSettings' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaDirectorySetting' -Exactly 1
            }

            It 'Should return false from the Test method' {
                $Script:calledOnceAlready = $true
                (New-M365DSCResourceInstance -ResourceName 'AADGroupsSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Prevent Remove the Policy from the Set method' {
                $Script:calledOnceAlready = $true
                { (New-M365DSCResourceInstance -ResourceName 'AADGroupsSettings' -Property $testParams).Set() } | Should -Throw 'The AADGroupsSettings resource cannot delete existing Directory Setting entries. Please specify Present.'
            }
        }
        Context -Name 'The Policy Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowGuestsToAccessGroups     = $True
                    AllowGuestsToBeGroupOwner     = $True
                    AllowToAddGuests              = $True
                    EnableGroupCreation           = $True
                    EnableMIPLabels               = $True
                    Ensure                        = 'Present'
                    Credential                    = $Credential
                    GroupCreationAllowedGroupName = 'All Company'
                    GuestUsageGuidelinesUrl       = 'https://contoso.com/guestusage'
                    IsSingleInstance              = 'Yes'
                    UsageGuidelinesUrl            = 'https://contoso.com/usage'
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        Id          = '12345-12345-12345-12345-12345'
                        DisplayName = 'All Company'
                    }
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroupsSettings' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaDirectorySetting' -Exactly 1
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADGroupsSettings' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowGuestsToAccessGroups     = $True
                    AllowGuestsToBeGroupOwner     = $True
                    AllowToAddGuests              = $True
                    EnableGroupCreation           = $False # Drift
                    EnableMIPLabels               = $False
                    Ensure                        = 'Present'
                    Credential                    = $Credential
                    GroupCreationAllowedGroupName = 'All Company'
                    GuestUsageGuidelinesUrl       = 'https://contoso.com/guestusage'
                    IsSingleInstance              = 'Yes'
                    UsageGuidelinesUrl            = 'https://contoso.com/usage'
                }
            }

            It 'Should return Values from the Get method' {
                $Script:calledOnceAlready = $true
                (New-M365DSCResourceInstance -ResourceName 'AADGroupsSettings' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaDirectorySetting' -Exactly 1
            }

            It 'Should return false from the Test method' {
                $Script:calledOnceAlready = $true
                (New-M365DSCResourceInstance -ResourceName 'AADGroupsSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                $Script:calledOnceAlready = $true
                (New-M365DSCResourceInstance -ResourceName 'AADGroupsSettings' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaDirectorySetting' -Exactly 1
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
                $Script:calledOnceAlready = $true
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADGroupsSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
