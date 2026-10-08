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
    -DscResource 'AADRoleEligibilityScheduleRequest' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $Global:CurrentModeIsExport = $false
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)
            $Script:exportedInstances = $null
            $Script:ExportMode = $null
            Mock -CommandName Add-M365DSCTelemetryEvent -ModuleName '_Shared' -MockWith {
            }

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName New-MgBetaRoleManagementDirectoryRoleEligibilityScheduleRequest -MockWith {
            }

            Mock -CommandName Get-MgUser -MockWith {
                return @{
                    Id = '123456'
                    UserPrincipalName = 'John.Smith@contoso.com'
                }
            }

            Mock -CommandName Get-MgBetaDirectoryObjectById -MockWith {
                return @{
                    Id = '123456'
                    '@odata.type' = '#microsoft.graph.user'
                    userPrincipalName = 'John.Smith@contoso.com'
                }
            }

            Mock -CommandName Get-MgBetaRoleManagementDirectoryRoleDefinition -MockWith {
                return @{
                    DisplayName      = 'Teams Communications Administrator'
                    Id               = '12345'
                    DirectoryScopeId = '/'
                }
            }
            Mock -CommandName Get-MgBetaRoleManagementDirectoryRoleEligibilitySchedule -MockWith {
                return @{
                    Id               = '12345-12345-12345-12345-12345'
                    RoleDefinitionId = "12345"
                    DirectoryScopeId = '/'
                    PrincipalId      = "123456"
                    ScheduleInfo         = @{
                        startDateTime = [System.DateTime]::Parse('2021-09-01T02:40:44Z')
                        expiration    = @{
                            endDateTime = [System.DateTime]::Parse('2025-10-31T02:40:09Z')
                            type        = 'afterDateTime'
                        }
                    };
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name 'The instance should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DirectoryScopeId     = "/";
                    Ensure               = "Present";
                    Principal            = "John.Smith@contoso.com";
                    PrincipalType        = "User"
                    RoleDefinition       = "Teams Communications Administrator";
                    ScheduleInfo         = [MSFT_AADRoleEligibilityScheduleRequestSchedule] @{
                        startDateTime             = '2023-09-01T02:40:44Z'
                        expiration = [MSFT_AADRoleEligibilityScheduleRequestScheduleExpiration] @{
                            endDateTime = '2025-10-31T02:40:09Z'
                            type        = 'afterDateTime'
                        }
                    }
                    Credential  = $Credential
                }

                Mock -CommandName Get-MgBetaRoleManagementDirectoryRoleEligibilitySchedule -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADRoleEligibilityScheduleRequest' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleEligibilityScheduleRequest' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleEligibilityScheduleRequest' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaRoleManagementDirectoryRoleEligibilityScheduleRequest -Exactly 1
            }
        }

        Context -Name 'The instance exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DirectoryScopeId     = "/";
                    Ensure               = "Absent";
                    Principal            = "John.Smith@contoso.com";
                    RoleDefinition       = "Teams Communications Administrator";
                    ScheduleInfo         = [MSFT_AADRoleEligibilityScheduleRequestSchedule] @{
                        expiration = [MSFT_AADRoleEligibilityScheduleRequestScheduleExpiration] @{
                            type        = 'afterDateTime'
                        }
                    }
                    Credential  = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADRoleEligibilityScheduleRequest' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleEligibilityScheduleRequest' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleEligibilityScheduleRequest' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaRoleManagementDirectoryRoleEligibilityScheduleRequest -Exactly 1 -ParameterFilter {
                    $BodyParameter.action -eq 'AdminRemove'
                }
            }
        }

        Context -Name 'The instance Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DirectoryScopeId     = "/";
                    Ensure               = "Present";
                    PrincipalType        = "User"
                    Principal            = "John.Smith@contoso.com";
                    RoleDefinition       = "Teams Communications Administrator";
                    ScheduleInfo         = [MSFT_AADRoleEligibilityScheduleRequestSchedule] @{
                        expiration = [MSFT_AADRoleEligibilityScheduleRequestScheduleExpiration] @{
                            duration    = 'P180D'
                            type        = 'afterDuration'
                        }
                    }
                    Credential  = $Credential
                }

                Mock -CommandName Get-MgBetaRoleManagementDirectoryRoleEligibilitySchedule -MockWith {
                    $start = [System.DateTime]::new(2026, 1, 1, 8, 0, 0, [System.DateTimeKind]::Utc)
                    return @{
                        Id               = '12345-12345-12345-12345-12345'
                        DirectoryScopeId = '/'
                        PrincipalId      = '123456'
                        RoleDefinitionId = '12345'
                        ScheduleInfo     = @{
                            startDateTime = $start
                            expiration    = @{
                                endDateTime = $start.AddDays(180)
                                type        = 'afterDateTime'
                            }
                        }
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADRoleEligibilityScheduleRequest' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleEligibilityScheduleRequest' -Property $testParams).Test() | Should -Be $true
            }
        }
        Context -Name 'The instance Exists and specified Values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DirectoryScopeId     = "/";
                    Ensure               = "Present";
                    PrincipalType        = "User"
                    Principal            = "John.Smith@contoso.com";
                    RoleDefinition       = "Teams Communications Administrator";
                    ScheduleInfo         = [MSFT_AADRoleEligibilityScheduleRequestSchedule] @{
                        startDateTime = '2023-01-01T02:40:44Z'
                        expiration = [MSFT_AADRoleEligibilityScheduleRequestScheduleExpiration] @{
                            endDateTime = (Get-Date).AddYears(1).ToString("yyyy-MM-ddTHH:mm:ssZ")
                            type        = 'afterDateTime'
                        }
                    }
                    Credential  = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADRoleEligibilityScheduleRequest' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleEligibilityScheduleRequest' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set to Update the instance' {
                (New-M365DSCResourceInstance -ResourceName 'AADRoleEligibilityScheduleRequest' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaRoleManagementDirectoryRoleEligibilityScheduleRequest -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADRoleEligibilityScheduleRequest' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
