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
    -DscResource '<ResourceName>' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Add-M365DSCTelemetryEvent -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName <NewCmdletName> -MockWith {
            }

            Mock -CommandName <SetCmdletName> -MockWith {
            }

            Mock -CommandName <RemoveCmdletName> -MockWith {
            }

            Mock -CommandName <GetCmdletName> -MockWith {
<GetMockBody>
            }
<AdditionalMockBlock>

            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                return @{}
            }

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
                return "<ResourceName> 'TestInstance' {}`r`n"
            }

            $Script:exportedInstance = $null
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        # Test contexts
<#IF HasEnsure#>
        Context -Name 'The instance should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
<TestParamsBlock>
                }

                Mock -CommandName <GetCmdletName> -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName '<ResourceName>' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName '<GetCmdletName>'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName '<ResourceName>' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName '<ResourceName>' -Property $testParams).Set()
                Should -Invoke -CommandName '<NewCmdletName>' -Exactly 1
            }
        }

        Context -Name 'The instance exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
<KeysOnlyParamsBlock>
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName '<ResourceName>' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName '<GetCmdletName>'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName '<ResourceName>' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName '<ResourceName>' -Property $testParams).Set()
                Should -Invoke -CommandName '<RemoveCmdletName>' -Exactly 1
            }
        }

<#ENDIF HasEnsure#>
        Context -Name 'The instance exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
<TestParamsBlock>
                }
            }

            It 'Should return the expected values from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName '<ResourceName>' -Property $testParams).Get().ToHashtable()
<#IF HasEnsure#>
                $result.Ensure | Should -Be 'Present'
<#ENDIF HasEnsure#>
<PropertyAssertions>
                Should -Invoke -CommandName '<GetCmdletName>'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName '<ResourceName>' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
<DriftParamsBlock>
                }
            }

<#IF HasEnsure#>
            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName '<ResourceName>' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName '<GetCmdletName>'
            }

<#ENDIF HasEnsure#>
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName '<ResourceName>' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName '<ResourceName>' -Property $testParams).Set()
                Should -Invoke -CommandName '<SetCmdletName>' -Exactly 1
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

            It 'Should reverse engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName '<ResourceName>' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                Should -Invoke -CommandName '<GetCmdletName>'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
