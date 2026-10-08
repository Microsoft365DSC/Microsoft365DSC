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
    -DscResource 'TeamsChannelTab' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName New-MgBetaTeamChannelTab -MockWith {
            }

            Mock -CommandName Update-MgBetaTeamChannelTab -MockWith {
            }

            Mock -CommandName Remove-MgBetaTeamChannelTab -MockWith {
            }

            Mock -CommandName Get-MgBetaTeamChannelTab -MockWith {
                return @{
                    id             = '12345-12345-12345-12345-12345'
                    displayName    = 'TestTab'
                    sortOrderIndex = '10100'
                    webUrl         = 'https://contoso.com'
                    configuration  = @{
                        contentUrl = 'https://contoso.com'
                        entityId   = $null
                        removeUrl  = $null
                        websiteUrl = 'https://contoso.com'
                    }
                    teamsApp       = @{
                        id = 'com.microsoft.teamspace.tab.web'
                    }
                }
            }

            Mock -CommandName Get-MgGroup -MockWith {
                return @{
                    Id     = '12345-12345-12345-12345-12345'
                    DisplayName = 'Contoso Team'
                }
            }

            Mock -CommandName Get-MgBetaTeamChannel -MockWith {
                return @{
                    Id          = '67890-67890-67890-67890-67890'
                    DisplayName = 'General'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the Tab doesn't exist but should" -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationId         = '12345'
                    CertificateThumbprint = 'ABCDEF1234567890'
                    ChannelName           = 'General'
                    Configuration         = @{
                        ContentUrl = 'https://contoso.com'
                        WebsiteUrl = 'https://contoso.com'
                    }
                    DisplayName           = 'TestTab'
                    Ensure                = 'Present'
                    SortOrderIndex        = '10100'
                    TeamName              = 'Contoso Team'
                    TeamsApp              = 'com.microsoft.teamspace.tab.web'
                    TenantId              = 'contoso.onmicrosoft.com'
                }

                Mock -CommandName Get-MgBetaTeamChannelTab -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsChannelTab' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannelTab' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the tab in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannelTab' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaTeamChannelTab -Exactly 1
            }
        }

        Context -Name 'The tab exists but is not in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationId         = '12345'
                    CertificateThumbprint = 'ABCDEF1234567890'
                    ChannelName           = 'General'
                    Configuration         = @{
                        ContentUrl = 'https://contoso.com'
                        WebsiteUrl = 'https://contoso.com'
                    }
                    DisplayName           = 'TestTab'
                    Ensure                = 'Present'
                    SortOrderIndex        = '11100' # Drift
                    TeamName              = 'Contoso Team'
                    TeamsApp              = 'com.microsoft.teamspace.tab.web'
                    TenantId              = 'contoso.onmicrosoft.com'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsChannelTab' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName Get-MgBetaTeamChannelTab -ParameterFilter { $All -and $NoPageSize }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannelTab' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannelTab' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaTeamChannelTab -Exactly 1
                Should -Invoke -CommandName Get-MgBetaTeamChannel -ParameterFilter { -not [System.String]::IsNullOrEmpty($Filter) -and $All -and $NoPageSize }
            }
        }

        Context -Name 'The tab exists and is already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationId         = '12345'
                    CertificateThumbprint = 'ABCDEF1234567890'
                    ChannelName           = 'General'
                    Configuration         = @{
                        ContentUrl = 'https://contoso.com'
                        WebsiteUrl = 'https://contoso.com'
                    }
                    DisplayName           = 'TestTab'
                    Ensure                = 'Present'
                    SortOrderIndex        = '10100'
                    TeamName              = 'Contoso Team'
                    TeamsApp              = 'com.microsoft.teamspace.tab.web'
                    TenantId              = 'contoso.onmicrosoft.com'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsChannelTab' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannelTab' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Policy exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationId         = '12345'
                    CertificateThumbprint = 'ABCDEF1234567890'
                    ChannelName           = 'General'
                    Configuration         = @{
                        ContentUrl = 'https://contoso.com'
                        WebsiteUrl = 'https://contoso.com'
                    }
                    DisplayName           = 'TestTab'
                    Ensure                = 'Absent'
                    SortOrderIndex        = '10100'
                    TeamName              = 'Contoso Team'
                    TeamsApp              = 'com.microsoft.teamspace.tab.web'
                    TenantId              = 'contoso.onmicrosoft.com'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsChannelTab' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannelTab' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannelTab' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaTeamChannelTab -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaTeam -MockWith {
                    return @{
                        Id          = '12345-12345-12345-12345-12345'
                        DisplayName = 'Contoso Team'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsChannelTab' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
