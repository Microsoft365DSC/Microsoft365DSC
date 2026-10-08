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
    -DscResource 'SPOBrowserIdleSignout' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Set-PnPBrowserIdleSignout -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'SPOBrowserIdleSignout settings are not configured' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential       = $Credential
                    Enabled          = $True
                    IsSingleInstance = 'Yes'
                    SignOutAfter     = '04:00:00'
                    WarnAfter        = '03:30:00'
                }

                Mock -CommandName Get-PnPBrowserIdleSignout -MockWith {
                    return @{
                        Enabled      = $True
                        SignOutAfter = '02:00:00'
                        WarnAfter    = '01:30:00'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOBrowserIdleSignout' -Property $testParams).Test() | Should -Be $false
            }

            It 'Sets the SharePoint browser idle signout settings in Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOBrowserIdleSignout' -Property $testParams).Set()
                Should -Invoke -CommandName Set-PnPBrowserIdleSignout -Exactly 1
            }
        }

        Context -Name 'Settings need to be updated.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential       = $Credential
                    Enabled          = $False
                    IsSingleInstance = 'Yes'
                    SignOutAfter     = '00:00:00'
                    WarnAfter        = '00:00:00'
                }

                Mock -CommandName Get-PnPBrowserIdleSignout -MockWith {
                    return @{
                        Enabled          = $False
                        IsSingleInstance = 'Yes'
                        SignOutAfter     = '01:00:00'; #Drift
                        WarnAfter        = '00:00:00'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOBrowserIdleSignout' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the settings' {
                (New-M365DSCResourceInstance -ResourceName 'SPOBrowserIdleSignout' -Property $testParams).Set()
                Should -Invoke -CommandName Set-PnPBrowserIdleSignout -Exactly 1
            }
        }

        Context -Name 'Settings are already in the desired state.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential       = $Credential
                    Enabled          = $False
                    IsSingleInstance = 'Yes'
                    SignOutAfter     = '00:00:00'
                    WarnAfter        = '00:00:00'
                }

                Mock -CommandName Get-PnPBrowserIdleSignout -MockWith {
                    return @{
                        Enabled          = $False
                        IsSingleInstance = 'Yes'
                        SignOutAfter     = '00:00:00'
                        WarnAfter        = '00:00:00'
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOBrowserIdleSignout' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPBrowserIdleSignout -MockWith {
                    return @{
                        Enabled          = $False
                        IsSingleInstance = 'Yes'
                        SignOutAfter     = '00:00:00'
                        WarnAfter        = '00:00:00'
                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOBrowserIdleSignout' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }#inmodulescope
}#describe

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
