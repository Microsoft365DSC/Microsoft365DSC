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
    -DscResource "EXOEOPProtectionPolicyRule" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Get-EOPProtectionPolicyRule -MockWith {
                return @{
                    Identity                  = "Strict Preset Security Policy"
                    Name                      = "Strict Preset Security Policy"
                    ExceptIfRecipientDomainIs = @("contoso.onmicrosoft.com")
                    Comments                  = "FakeStringValue"
                    Priority                  = 0
                    State                     = "Disabled";
                }
            }

            Mock -CommandName Disable-EOPProtectionPolicyRule -MockWith {
            }

            Mock -CommandName Set-EOPProtectionPolicyRule -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts

        Context -Name "The EXOEOPProtectionPolicyRule exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                    = 'Absent'
                    Credential                = $Credential;
                    ExceptIfRecipientDomainIs = @("contoso.onmicrosoft.com");
                    Identity                  = "Strict Preset Security Policy";
                    Name                      = "Strict Preset Security Policy";
                    Priority                  = 0;
                    State                     = "Disabled";
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOEOPProtectionPolicyRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOEOPProtectionPolicyRule' -Property $testParams).Test() | Should -Be $false
            }
        }
        Context -Name "The EXOEOPProtectionPolicyRule Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                    = 'Present'
                    Credential                = $Credential;
                    ExceptIfRecipientDomainIs = @("contoso.onmicrosoft.com");
                    Identity                  = "Strict Preset Security Policy";
                    Name                      = "Strict Preset Security Policy";
                    Priority                  = 0;
                    State                     = "Disabled";
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOEOPProtectionPolicyRule' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The EXOEOPProtectionPolicyRule exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                    = 'Present'
                    Credential                = $Credential;
                    ExceptIfRecipientDomainIs = @("contoso1.onmicrosoft.com"); # Drift
                    Identity                  = "Strict Preset Security Policy 2";
                    Name                      = "Strict Preset Security Policy";
                    Priority                  = 0;
                    State                     = "Disabled";
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOEOPProtectionPolicyRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOEOPProtectionPolicyRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOEOPProtectionPolicyRule' -Property $testParams).Set()
                Should -Invoke -CommandName Set-EOPProtectionPolicyRule -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOEOPProtectionPolicyRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
