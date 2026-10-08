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
    -DscResource 'EXOPlace' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Set-Place -MockWith {
            }

            Mock -CommandName Get-Place -MockWith {
                return @{
                    AudioDeviceName        = "MyAudioDevice";
                    Capacity               = 10;
                    City                   = "";
                    DisplayDeviceName      = "DisplayDeviceName";
                    Identity               = "MyRoom@$contoso.com";
                    IsWheelChairAccessible = $True;
                    MTREnabled             = $False;
                    ParentType             = "None";
                    Phone                  = "555-555-5555";
                    Tags                   = @("Tag1", "Tag2");
                    VideoDeviceName        = "VideoDevice";
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Instance is already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AudioDeviceName        = "MyAudioDevice";
                    Capacity               = 10;
                    City                   = "";
                    Credential             = $Credential;
                    DisplayDeviceName      = "DisplayDeviceName";
                    Ensure                 = "Present";
                    Identity               = "MyRoom@$contoso.com";
                    IsWheelChairAccessible = $True;
                    MTREnabled             = $False;
                    ParentType             = "None";
                    Phone                  = "555-555-5555";
                    Tags                   = @("Tag1", "Tag2");
                    VideoDeviceName        = "VideoDevice";
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOPlace' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should not update anything in the Set Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOPlace' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Instance is NOT already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AudioDeviceName        = "MyAudioDevice";
                    Capacity               = 15; # Drift
                    City                   = "";
                    Credential             = $Credential;
                    DisplayDeviceName      = "DisplayDeviceName";
                    Ensure                 = "Present";
                    Identity               = "MyRoom@$contoso.com";
                    IsWheelChairAccessible = $True;
                    MTREnabled             = $False;
                    ParentType             = "None";
                    Phone                  = "555-555-5555";
                    Tags                   = @("Tag1", "Tag2");
                    VideoDeviceName        = "VideoDevice";
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOPlace' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should not update anything in the Set Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOPlace' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should update the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOPlace' -Property $testParams).Set()
                Should -Invoke -CommandName Set-Place -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOPlace' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
