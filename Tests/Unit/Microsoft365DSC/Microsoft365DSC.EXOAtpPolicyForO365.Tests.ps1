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
    -DscResource 'EXOAtpPolicyForO365' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Get-AtpPolicyForO365 -MockWith {
                return @{
                    IsSingleInstance        = 'Yes'
                    Ensure                  = 'Present'
                    Identity                = 'Default'
                    Credential              = $Credential
                    AllowSafeDocsOpen       = $false
                    BlockUrls               = @()
                    EnableATPForSPOTeamsODB = $true
                    TrackClicks             = $true
                }
            }

            Mock -CommandName Set-AtpPolicyForO365 -MockWith {
            }

            Mock -CommandName Confirm-ImportedCmdletIsAvailable -MockWith {
                return $true
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'AtpPolicyForO365 update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance        = 'Yes'
                    Credential              = $Credential
                    AllowSafeDocsOpen       = $false
                    EnableATPForSPOTeamsODB = $true
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpPolicyForO365' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'AtpPolicyForO365 update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance        = 'Yes'
                    Credential              = $Credential
                    AllowSafeDocsOpen       = $true # Drift
                    EnableATPForSPOTeamsODB = $true
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpPolicyForO365' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpPolicyForO365' -Property $testParams).Set()
                Should -Invoke -CommandName Set-AtpPolicyForO365 -Exactly 1 -ParameterFilter { $Identity -eq 'Default' }
            }
        }

        Context -Name 'AtpPolicyForO365 does not exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance        = 'Yes'
                    Credential              = $Credential
                    AllowSafeDocsOpen       = $false
                    EnableATPForSPOTeamsODB = $true
                }
                Mock -CommandName Get-AtpPolicyForO365 -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpPolicyForO365' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method with the Default policy' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAtpPolicyForO365' -Property $testParams).Set()
                Should -Invoke -CommandName Set-AtpPolicyForO365 -Exactly 1 -ParameterFilter { $Identity -eq 'Default' }
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOAtpPolicyForO365' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
