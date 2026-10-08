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
    -DscResource 'PPPowerAppsEnvironment' -GenericStubModule $GenericStubPath
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

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Write-Warning -MockWith {
            }
        }

        # Test contexts
        Context -Name "Environment doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName    = 'Test Environment'
                    Location       = 'canada'
                    EnvironmentSKU = 'production'
                    Credential     = $Credential
                    Ensure         = 'Present'
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPPowerAppsEnvironment' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PPPowerAppsEnvironment' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should create the environment in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PPPowerAppsEnvironment' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -Exactly 2
            }

            It 'Should throw when a database is provisioned without a currency' {
                $params = $testParams.Clone()
                $params.ProvisionDatabase = $true
                $params.LanguageName = '1033'

                { (New-M365DSCResourceInstance -ResourceName 'PPPowerAppsEnvironment' -Property $params).Set() } |
                    Should -Throw '*requires CurrencyName and LanguageName*'
            }
        }

        Context -Name 'Environment already exists but IS ALREADY in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName    = 'Test Environment'
                    Location       = 'canada'
                    EnvironmentSKU = 'production'
                    EnvironmentType = 'production'
                    Credential     = $Credential
                    Ensure         = 'Present'
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        value = @{
                            properties = @{
                                displayName     = 'Test Environment'
                                environmentType = 'production'
                                environmentSKU  = 'production'
                            }
                            location        = 'canada'
                        }
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPPowerAppsEnvironment' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PPPowerAppsEnvironment' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Environment already exists but SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName    = 'Test Environment'
                    Location       = 'canada'
                    EnvironmentSKU = 'production'
                    Credential     = $Credential
                    Ensure         = 'Absent'
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        value = @{
                            name       = 'a1b2c3d4-0000-0000-0000-000000000001'
                            properties = @{
                                displayName     = 'Test Environment'
                                environmentType = 'production'
                                environmentSKU  = 'production'
                            }
                            location        = 'canada'
                        }
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPPowerAppsEnvironment' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PPPowerAppsEnvironment' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should delete the environment in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PPPowerAppsEnvironment' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'POST' -and $Uri -like '*/environments/a1b2c3d4-0000-0000-0000-000000000001/validateDelete?*'
                }
                Should -Invoke -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -Exactly 1 -ParameterFilter {
                    $Method -eq 'DELETE' -and $Uri -like '*/environments/a1b2c3d4-0000-0000-0000-000000000001?api-version=*'
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

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        value = @{
                            properties = @{
                                displayName     = 'Test Environment'
                                environmentType = 'production'
                                environmentSKU  = 'production'
                            }
                            location        = 'canada'
                        }
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'PPPowerAppsEnvironment' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
