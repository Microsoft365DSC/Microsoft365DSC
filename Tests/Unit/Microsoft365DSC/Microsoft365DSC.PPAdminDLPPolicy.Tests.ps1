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

$CurrentScriptPath = $PSCommandPath.Split('\')
$CurrentScriptName = $CurrentScriptPath[$CurrentScriptPath.Length -1]
$ResourceName      = $CurrentScriptName.Split('.')[1]
$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource $ResourceName -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName           = "SuperTest";
                    Ensure                = "Present";
                    Environments          = "Default-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx";
                    FilterType            = "include";
                    Credential            = $Credential;
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PPAdminDLPPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPAdminDLPPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PPAdminDLPPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -Exactly 3
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName           = "SuperTest";
                    Ensure                = "Absent";
                    Environments          = "Default-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx";
                    FilterType            = "include";
                    Credential            = $Credential;
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        value = @(
                            @{
                                PolicyName  = "MyPolicy"
                                properties = @{
                                    displayName = "SuperTest"
                                    definition = @{
                                        constraints = @{
                                            environmentFilter1 = @{
                                                parameters = @{
                                                    environments = @{
                                                        name = 'Default-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx'
                                                    }
                                                    filterType = 'include'
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        )
                    }
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PPAdminDLPPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPAdminDLPPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PPAdminDLPPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -Exactly 3
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName           = "SuperTest";
                    Ensure                = "Present";
                    Environments          = "Default-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx";
                    FilterType            = "include";
                    Credential            = $Credential;
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        value = @(
                            @{
                                PolicyName  = "MyPolicy"
                                properties = @{
                                    displayName = "SuperTest"
                                    definition = @{
                                        constraints = @{
                                            environmentFilter1 = @{
                                                parameters = @{
                                                    environments = @{
                                                        name = 'Default-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx'
                                                    }
                                                    filterType = 'include'
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        )
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPAdminDLPPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName           = "SuperTest";
                    Ensure                = "Present";
                    Environments          = "Default-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx";
                    FilterType            = "exclude"; #drift
                    Credential            = $Credential;
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        value = @(
                            @{
                                PolicyName  = "MyPolicy"
                                properties = @{
                                    displayName = "SuperTest"
                                    definition = @{
                                        constraints = @{
                                            environmentFilter1 = @{
                                                parameters = @{
                                                    environments = @{
                                                        name = 'Default-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx'
                                                    }
                                                    filterType = 'include'
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        )
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PPAdminDLPPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PPAdminDLPPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PPAdminDLPPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -Exactly 3
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }

                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    return @{
                        value = @(
                            @{
                                PolicyName  = "MyPolicy"
                                properties = @{
                                    displayName = "SuperTest"
                                    definition = @{
                                        constraints = @{
                                            environmentFilter1 = @{
                                                parameters = @{
                                                    environments = @{
                                                        name = 'Default-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx'
                                                    }
                                                    filterType = 'include'
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        )
                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'PPAdminDLPPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
