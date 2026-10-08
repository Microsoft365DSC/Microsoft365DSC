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
    -DscResource 'TeamsGuestMessagingConfiguration' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-CsTeamsGuestMessagingConfiguration -MockWith {
                return @{
                    AllowGiphy             = $True
                    AllowImmersiveReader   = $False
                    AllowMemes             = $True
                    AllowStickers          = $True
                    AllowUserChat          = $True
                    AllowUserDeleteMessage = $False
                    AllowUserEditMessage   = $True
                    GiphyRatingType        = 'Moderate'
                    Identity               = 'Global'
                }
            }

            Mock -CommandName Set-CsTeamsGuestMessagingConfiguration -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'When settings are correctly set' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowGiphy             = $True
                    AllowImmersiveReader   = $False
                    AllowMemes             = $True
                    AllowStickers          = $True
                    AllowUserChat          = $True
                    AllowUserDeleteMessage = $False
                    AllowUserEditMessage   = $True
                    GiphyRatingType        = 'Moderate'
                    IsSingleInstance       = 'Yes'
                    Credential             = $Credential
                }
            }

            It 'Should return true for the AllowGiphy property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsGuestMessagingConfiguration' -Property $testParams).Get().ToHashtable()).AllowGiphy | Should -Be $true
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsGuestMessagingConfiguration' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When settings are NOT correctly set' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowGiphy             = $False; #Drifted
                    AllowImmersiveReader   = $False
                    AllowMemes             = $True
                    AllowStickers          = $True
                    AllowUserChat          = $True
                    AllowUserDeleteMessage = $True; #Drifted
                    AllowUserEditMessage   = $True
                    GiphyRatingType        = 'Moderate'
                    IsSingleInstance       = 'Yes'
                    Credential             = $Credential
                }
            }

            It 'Should true for the AllowGiphy property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsGuestMessagingConfiguration' -Property $testParams).Get().ToHashtable()).AllowGiphy | Should -Be $true
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsGuestMessagingConfiguration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Updates the settings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsGuestMessagingConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsGuestMessagingConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsGuestMessagingConfiguration' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
