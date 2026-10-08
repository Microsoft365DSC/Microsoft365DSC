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
    -DscResource 'SPOSiteDesign' -GenericStubModule $GenericStubPath

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

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Check Site Design ' -Fixture {
            BeforeAll {
                $testParams = @{
                    Title               = 'DSC Site Design'
                    SiteScriptNames     = @('Cust List', 'List_Views')
                    WebTemplate         = 'TeamSite'
                    IsDefault           = $false
                    Description         = 'Created by DSC'
                    PreviewImageAltText = 'Office 365'
                    PreviewImageUrl     = ''
                    Ensure              = 'Present'
                    Credential          = $Credential
                }

                Mock -CommandName Get-PnPSiteScript -MockWith {
                    return @(
                        @{
                            Id    = '12345678-1234-1234-1234-123456789012'
                            Title = 'Cust List'
                        },
                        @{
                            Id    = '12345678-1234-1234-1234-123456789011'
                            Title = 'List_Views'
                        }
                    )
                }

                Mock -CommandName Get-PnPSiteDesign -MockWith {
                    return $null
                }

                Mock -CommandName Add-PnPSiteDesign -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSiteDesign' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteDesign' -Property $testParams).Test() | Should -Be $false
            }

            It 'Adds the site design in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteDesign' -Property $testParams).Set()
            }

        }

        Context -Name 'Check existing Site Design ' -Fixture {
            BeforeAll {
                $testParams = @{
                    Title               = 'DSC Site Design'
                    SiteScriptNames     = 'Cust List'
                    WebTemplate         = 'TeamSite'
                    Description         = 'Created by DSC'
                    PreviewImageAltText = 'Office 365'
                    Ensure              = 'Present'
                    Credential          = $Credential
                }

                Mock -CommandName Get-PnPSiteDesign -MockWith {
                    return @{
                        Title               = 'DSC Site Design'
                        Id                  = '93cd8bf8-516c-4f24-a215-d4afded51fc1'
                        SiteScriptNames     = 'Cust List'
                        WebTemplate         = 'TeamSite'
                        Description         = 'Updated by DSC'
                        PreviewImageAltText = 'Office'
                    }
                }
                Mock -CommandName Get-PnPSiteScript -MockWith {
                    return @{
                        Title = 'Cust List'
                        Id    = '93cd8bf8-516c-4f24-a215-d4afded51fc1'
                    }
                }

                Mock -CommandName Set-PnPSiteDesign -MockWith {
                    return $null
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSiteDesign' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteDesign' -Property $testParams).Test() | Should -Be $false
            }

            It 'Updates the site design in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteDesign' -Property $testParams).Set()
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPSiteDesign -MockWith {
                    return @{
                        Title = 'DSC Site Design'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOSiteDesign' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }

    }
}


Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
