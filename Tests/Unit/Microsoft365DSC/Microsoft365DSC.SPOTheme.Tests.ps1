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
    -DscResource 'SPOTheme' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Add-PnPTenantTheme -MockWith {
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
        Context -Name "The theme doesn't exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'TestTheme'
                    IsInverted = $false
                    Palette    = ([MSFT_SPOThemePaletteProperty] @{
                            Property = 'themePrimary'
                            Value    = '#eff6fc'
                        })
                    Credential = $Credential
                    Ensure     = 'Present'
                }

                Mock -CommandName Add-PnPTenantTheme -MockWith {
                    return @{
                        Name = $null
                    }
                }

                Mock -CommandName Get-PnPTenantTheme -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOTheme' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOTheme' -Property $testParams).Test() | Should -Be $false
            }

            It 'Creates the theme in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOTheme' -Property $testParams).Set()
            }
        }

        Context -Name 'The theme already exists' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'TestTheme'
                    IsInverted = $false
                    Palette    = ([MSFT_SPOThemePaletteProperty] @{
                            Property = 'themePrimary'
                            Value    = '#eff6fc'
                        })
                    Credential = $Credential
                    Ensure     = 'Present'
                }

                Mock -CommandName Get-PnPTenantTheme -MockWith {
                    return @{
                        Name       = 'TestTheme'
                        IsInverted = $true
                        Palette    = @{
                            'themePrimary'         = '#0078d4'
                            'themeLighterAlt'      = '#eff6fc'
                            'themeLighter'         = '#deecf9'
                            'themeLight'           = '#c7e0f4'
                            'themeTertiary'        = '#71afe5'
                            'themeSecondary'       = '#2b88d8'
                            'themeDarkAlt'         = '#106ebe'
                            'themeDark'            = '#005a9e'
                            'themeDarker'          = '#004578'
                            'neutralLighterAlt'    = '#f8f8f8'
                            'neutralLighter'       = '#f4f4f4'
                            'neutralLight'         = '#eaeaea'
                            'neutralQuaternaryAlt' = '#dadada'
                            'neutralQuaternary'    = '#d0d0d0'
                            'neutralTertiaryAlt'   = '#c8c8c8'
                            'neutralTertiary'      = '#c2c2c2'
                            'neutralSecondary'     = '#858585'
                            'neutralPrimaryAlt'    = '#4b4b4b'
                            'neutralPrimary'       = '#333'
                            'neutralDark'          = '#272727'
                            'black'                = '#1d1d1d'
                            'white'                = '#fff'
                            'bodyBackground'       = '#0078d4'
                            'bodyText'             = '#fff'
                        }
                    }
                }
            }

            It 'Should update the Theme from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOTheme' -Property $testParams).Set()
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOTheme' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOTheme' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'Testing theme removal' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'TestTheme'
                    IsInverted = $false
                    Palette    = ([MSFT_SPOThemePaletteProperty] @{
                            Property = 'themePrimary'
                            Value    = '#eff6fc'
                        })
                    Credential = $Credential
                    Ensure     = 'Present'
                }

                Mock -CommandName Get-PnPTenantTheme -MockWith {
                    return @{
                        Name       = 'TestTheme'
                        IsInverted = $true
                        Palette    = @{
                            'themePrimary'         = '#0078d4'
                            'themeLighterAlt'      = '#eff6fc'
                            'themeLighter'         = '#deecf9'
                            'themeLight'           = '#c7e0f4'
                            'themeTertiary'        = '#71afe5'
                            'themeSecondary'       = '#2b88d8'
                            'themeDarkAlt'         = '#106ebe'
                            'themeDark'            = '#005a9e'
                            'themeDarker'          = '#004578'
                            'neutralLighterAlt'    = '#f8f8f8'
                            'neutralLighter'       = '#f4f4f4'
                            'neutralLight'         = '#eaeaea'
                            'neutralQuaternaryAlt' = '#dadada'
                            'neutralQuaternary'    = '#d0d0d0'
                            'neutralTertiaryAlt'   = '#c8c8c8'
                            'neutralTertiary'      = '#c2c2c2'
                            'neutralSecondary'     = '#858585'
                            'neutralPrimaryAlt'    = '#4b4b4b'
                            'neutralPrimary'       = '#333'
                            'neutralDark'          = '#272727'
                            'black'                = '#1d1d1d'
                            'white'                = '#fff'
                            'bodyBackground'       = '#0078d4'
                            'bodyText'             = '#fff'
                        }
                    }
                }

                Mock -CommandName Remove-PnPTenantTheme -MockWith {
                    return 'Theme has been successfully removed'
                }
            }

            It 'Should remove the Theme successfully' {
                (New-M365DSCResourceInstance -ResourceName 'SPOTheme' -Property $testParams).Set()
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPTenantTheme -MockWith {
                    return @{
                        Name       = 'TestTheme'
                        IsInverted = $false
                        Palette    = @{
                            'themePrimary'         = '#0078d4'
                            'themeLighterAlt'      = '#eff6fc'
                            'themeLighter'         = '#deecf9'
                            'themeLight'           = '#c7e0f4'
                            'themeTertiary'        = '#71afe5'
                            'themeSecondary'       = '#2b88d8'
                            'themeDarkAlt'         = '#106ebe'
                            'themeDark'            = '#005a9e'
                            'themeDarker'          = '#004578'
                            'neutralLighterAlt'    = '#f8f8f8'
                            'neutralLighter'       = '#f4f4f4'
                            'neutralLight'         = '#eaeaea'
                            'neutralQuaternaryAlt' = '#dadada'
                            'neutralQuaternary'    = '#d0d0d0'
                            'neutralTertiaryAlt'   = '#c8c8c8'
                            'neutralTertiary'      = '#c2c2c2'
                            'neutralSecondary'     = '#858585'
                            'neutralPrimaryAlt'    = '#4b4b4b'
                            'neutralPrimary'       = '#333'
                            'neutralDark'          = '#272727'
                            'black'                = '#1d1d1d'
                            'white'                = '#fff'
                            'bodyBackground'       = '#0078d4'
                            'bodyText'             = '#fff'
                        }
                        Credential = $Credential
                        Ensure     = 'Present'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOTheme' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
