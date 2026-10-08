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
    -DscResource "EXOSmtpDaneInbound" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Reset-MSCloudLoginConnectionProfileContext -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Get-AcceptedDomain -MockWith {
                return @{
                    DomainName     = "fakedomain.com"
                    SmtpDaneStatus = "Enabled"
                }
            }

            Mock -CommandName Enable-SmtpDaneInbound -MockWith {
            }

            Mock -CommandName Disable-SmtpDaneInbound -MockWith {
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
        Context -Name "The EXOSmtpDaneInbound should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DomainName = "fakedomain.com"
                    Ensure     = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-AcceptedDomain -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOSmtpDaneInbound' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSmtpDaneInbound' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Enable SmtpDaneInbound from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSmtpDaneInbound' -Property $testParams).Set()
                Should -Invoke -CommandName Enable-SmtpDaneInbound -Exactly 1

                Mock -CommandName Enable-SmtpDaneInbound -MockWith {
                    return [PSCustomObject]@{
                        Result    = 'Error'
                        ErrorData = "ErrorCode:'DomainNotFound'"
                    }
                }
                { (New-M365DSCResourceInstance -ResourceName 'EXOSmtpDaneInbound' -Property $testParams).Set() } | Should -Throw "*DomainNotFound*"
            }
        }

        Context -Name "The EXOSmtpDaneInbound exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DomainName = "fakedomain.com"
                    Ensure     = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOSmtpDaneInbound' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSmtpDaneInbound' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should disable SmtpDaneInbound from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSmtpDaneInbound' -Property $testParams).Set()
                Should -Invoke -CommandName Disable-SmtpDaneInbound -Exactly 1

                Mock -CommandName Disable-SmtpDaneInbound -MockWith {
                    return [PSCustomObject]@{
                        Result    = 'Error'
                        ErrorData = "ErrorCode:'DomainNotFound'"
                    }
                }
                { (New-M365DSCResourceInstance -ResourceName 'EXOSmtpDaneInbound' -Property $testParams).Set() } | Should -Throw "*DomainNotFound*"
            }
        }

        Context -Name "The EXOSmtpDaneInbound Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DomainName = "fakedomain.com"
                    Ensure     = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSmtpDaneInbound' -Property $testParams).Test() | Should -Be $true
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOSmtpDaneInbound' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
