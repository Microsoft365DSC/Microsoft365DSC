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

            Mock -CommandName Set-InsiderRiskEntityList -MockWith {
            }

            Mock -CommandName New-InsiderRiskEntityList -MockWith {
            }

            Mock -CommandName Remove-InsiderRiskEntityList -MockWith {
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
                    Description = "Test Description";
                    DisplayName = "TestFileTypeList";
                    Ensure      = "Present";
                    FileTypes   = @(".exe",".cmd",".bat");
                    ListType    = "CustomFileTypeLists";
                    Name        = "TestName";
                    Credential  = $Credential;
                }

                Mock -CommandName Get-InsiderRiskEntityList -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCInsiderRiskEntityList' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCInsiderRiskEntityList' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCInsiderRiskEntityList' -Property $testParams).Set()
                Should -Invoke -CommandName New-InsiderRiskEntityList -Exactly 1
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "Test Description";
                    DisplayName = "TestFileTypeList";
                    Ensure      = "Absent";
                    FileTypes   = @(".exe",".cmd",".bat");
                    ListType    = "CustomFileTypeLists";
                    Name        = "TestName";
                    Credential  = $Credential;
                }

                Mock -CommandName Get-InsiderRiskEntityList -MockWith {
                    return @{
                        ListType   = 'CustomFileTypeLists'
                        Name        = 'TestName';
                        DisplayName = "TestFileTypeList";
                        Description = "Test Description";
                        Entities = @(
                            '{"Ext":".exe"}',
                            '{"Ext":".cmd"}',
                            '{"Ext":".bat"}'
                        )
                    }
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCInsiderRiskEntityList' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCInsiderRiskEntityList' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCInsiderRiskEntityList' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-InsiderRiskEntityList -Exactly 1
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "Test Description";
                    DisplayName = "TestFileTypeList";
                    Ensure      = "Present";
                    FileTypes   = @(".exe",".cmd",".bat");
                    ListType    = "CustomFileTypeLists";
                    Name        = "TestName";
                    Credential  = $Credential;
                }

                Mock -CommandName Get-InsiderRiskEntityList -MockWith {
                    return @{
                        ListType   = 'CustomFileTypeLists'
                        Name        = 'TestName';
                        DisplayName = "TestFileTypeList";
                        Description = "Test Description";
                        Entities = @(
                            '{"Ext":".exe"}',
                            '{"Ext":".cmd"}',
                            '{"Ext":".bat"}'
                        )
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCInsiderRiskEntityList' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "Test Description";
                    DisplayName = "TestFileTypeList";
                    Ensure      = "Present";
                    FileTypes   = @(".exe",".cmd",".bat");
                    ListType    = "CustomFileTypeLists";
                    Name        = "TestName";
                    Credential  = $Credential;
                }

                Mock -CommandName Get-InsiderRiskEntityList -MockWith {
                    return @{
                        ListType   = 'CustomFileTypeLists'
                        Name        = 'TestName';
                        DisplayName = "TestFileTypeList";
                        Description = "Test Description";
                        Entities = @(
                            '{"Ext":".exe"}',
                            '{"Ext":".txt"}', #drift
                            '{"Ext":".bat"}'
                        )
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCInsiderRiskEntityList' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCInsiderRiskEntityList' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCInsiderRiskEntityList' -Property $testParams).Set()
                Should -Invoke -CommandName Set-InsiderRiskEntityList -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }

                Mock -CommandName Get-InsiderRiskEntityList -MockWith {
                    return @{
                        ListType   = 'CustomFileTypeLists'
                        Name        = 'TestName';
                        DisplayName = "TestFileTypeList";
                        Description = "Test Description";
                        Entities = @(
                            '{"Ext":".exe"}',
                            '{"Ext":".cmd"}',
                            '{"Ext":".bat"}'
                        )
                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCInsiderRiskEntityList' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
