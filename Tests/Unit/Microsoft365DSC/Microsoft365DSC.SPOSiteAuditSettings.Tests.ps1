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
    -DscResource 'SPOSiteAuditSettings' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Set-PnPAuditing -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Set SPOSiteAuditSettings to All' -Fixture {
            BeforeAll {
                $testParams = @{
                    Url        = 'https://contoso.com/sites/fakesite'
                    AuditFlags = 'All'
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPAuditing -MockWith {
                    return @{
                        AuditFlags = 'None'
                    }
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    return @{
                        Url = 'https://contoso.com/sites/fakesite'
                    }
                }
            }

            It 'Should return the current resource from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSiteAuditSettings' -Property $testParams).Get().ToHashtable()).Url | Should -Be 'https://contoso.com/sites/fakesite'
            }

            It 'Should set settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteAuditSettings' -Property $testParams).Set()
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteAuditSettings' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'Set SPOSiteAuditSettings to None' -Fixture {
            BeforeAll {
                $testParams = @{
                    Url        = 'https://contoso.com/sites/fakesite'
                    AuditFlags = 'None'
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPAuditing -MockWith {
                    return @{
                        AuditFlags = 'All'
                    }
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    return @{
                        Url = 'https://contoso.com/sites/fakesite'
                    }
                }
            }

            It 'Should return the current resource from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSiteAuditSettings' -Property $testParams).Get().ToHashtable()).Url | Should -Be 'https://contoso.com/sites/fakesite'
            }

            It 'Should set settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteAuditSettings' -Property $testParams).Set()
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteAuditSettings' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPAuditing -MockWith {
                    return @{
                        AuditFlags = 'None'
                    }
                }

                Mock -CommandName Get-PnPTenantSite -MockWith {
                    return @{
                        Url = 'https://contoso.com/sites/fakesite'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOSiteAuditSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }

    }
}


Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
