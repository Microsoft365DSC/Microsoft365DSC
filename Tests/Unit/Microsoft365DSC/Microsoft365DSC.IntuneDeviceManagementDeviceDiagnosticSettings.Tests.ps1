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
    -DscResource 'IntuneDeviceManagementDeviceDiagnosticSettings' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Update-MgBetaDeviceManagement -MockWith {
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                return @{
                    enableLogCollection = $true
                    enableAutopilotDiagnostics = $true
                    m365AppDiagnosticsEnabled = $true
                    enhancedJailBreak = $true
                    ignoreDevicesForUnsupportedSettingsEnabled = $true
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Write-Verbose -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "The settings are already in the desired state." -Fixture {
            BeforeAll {
                $testParams = @{
                    EnableLogCollection        = $true;
                    EnableAutopilotDiagnostics = $true;
                    M365AppDiagnosticsEnabled  = $true;
                    IsSingleInstance           = "Yes";
                    Credential                 = $Credential
                }
            }

            It 'Should return Yes from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceManagementDeviceDiagnosticSettings' -Property $testParams).Get().ToHashtable()).IsSingleInstance | Should -Be 'Yes'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceManagementDeviceDiagnosticSettings' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The settings are NOT in the desired state." -Fixture {
            BeforeAll {
                $testParams = @{
                    EnableLogCollection        = $false; # Updated property
                    EnableAutopilotDiagnostics = $true;
                    M365AppDiagnosticsEnabled  = $true;
                    IsSingleInstance           = "Yes";
                    Credential                 = $Credential
                }
            }

            It 'Should return Yes from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceManagementDeviceDiagnosticSettings' -Property $testParams).Get().ToHashtable()).IsSingleInstance | Should -Be 'Yes'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceManagementDeviceDiagnosticSettings' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Update cmdlet from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceManagementDeviceDiagnosticSettings' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagement -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceManagementDeviceDiagnosticSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
