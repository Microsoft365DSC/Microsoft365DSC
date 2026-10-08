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
    -DscResource 'EXOEmailTenantSettings' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Get-EmailTenantSettings -MockWith {
                return @{
                    EnablePriorityAccountProtection            = $True;
                    IsValid                                    = $True;
                    ObjectState                                = "New"
                    Identity                                   = "sotmcpoc.onmicrosoft.com\Default"
                    Name                                       = "Default"
                }
            }

            Mock -CommandName Set-EmailTenantSettings -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Configuration needs updating' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                           = 'Yes'
                    EnablePriorityAccountProtection            = $False; # Drift
                    IsValid                                    = $True;
                    ObjectState                                = "New"
                    Credential                                 = $Credential
                    Name                                       = "Default"
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOEmailTenantSettings' -Property $testParams).Test() | Should -Be $false

                Mock -CommandName Get-EmailTenantSettings -MockWith {
                    return $null
                }
                { (New-M365DSCResourceInstance -ResourceName 'EXOEmailTenantSettings' -Property $testParams).Get() } | Should -Throw '*Could not find the Email Tenant Settings.*'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOEmailTenantSettings' -Property $testParams).Set()
                Should -Invoke -CommandName Set-EmailTenantSettings -Exactly 1
            }
        }

        Context -Name 'Update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance                           = 'Yes'
                    EnablePriorityAccountProtection            = $True;
                    Identity                                   = "sotmcpoc.onmicrosoft.com\Default";
                    IsValid                                    = $True;
                    ObjectState                                = "New"
                    Credential                                 = $Credential
                    Name                                       = "Default"
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOEmailTenantSettings' -Property $testParams).Test() | Should -Be $true
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOEmailTenantSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
