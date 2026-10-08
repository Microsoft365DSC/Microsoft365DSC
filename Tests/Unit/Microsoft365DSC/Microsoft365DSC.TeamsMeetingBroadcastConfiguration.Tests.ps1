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
    -DscResource 'TeamsMeetingBroadcastConfiguration' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-CsTeamsMeetingBroadcastConfiguration -MockWith {
                return @{
                    AllowSdnProviderForBroadcastMeeting = $True
                    Identity                            = 'Global'
                    SdnApiTemplateUrl                   = 'https://api.contosoprovider.com/v1/Template'
                    SdnApiToken                         = $ConfigurationData.Settings.SdnApiToken
                    SdnLicenseId                        = '123456-123456-123456-123456'
                    SdnName                             = 'ContosoProvider'
                }
            }

            Mock -CommandName Set-CsTeamsMeetingBroadcastConfiguration -MockWith {
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
                    AllowSdnProviderForBroadcastMeeting = $True
                    IsSingleInstance                    = 'Yes'
                    SdnApiTemplateUrl                   = 'https://api.contosoprovider.com/v1/Template'
                    SdnApiToken                         = $ConfigurationData.Settings.SdnApiToken
                    SdnLicenseId                        = '123456-123456-123456-123456'
                    SdnProviderName                     = 'ContosoProvider'
                    Credential                          = $Credential
                }
            }

            It 'Should the SdnProviderName property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastConfiguration' -Property $testParams).Get().ToHashtable()).SdnProviderName | Should -Be 'ContosoProvider'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastConfiguration' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When settings are NOT correctly set' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowSdnProviderForBroadcastMeeting = $True
                    IsSingleInstance                    = 'Yes'
                    SdnApiTemplateUrl                   = 'https://api.contosoprovider.com/v1/Template'
                    SdnApiToken                         = $ConfigurationData.Settings.SdnApiToken
                    SdnLicenseId                        = '123456-111111-111111-123456'; #Variant
                    SdnProviderName                     = 'ContosoProvider'
                    Credential                          = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastConfiguration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Updates the settings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsMeetingBroadcastConfiguration
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsMeetingBroadcastConfiguration' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
