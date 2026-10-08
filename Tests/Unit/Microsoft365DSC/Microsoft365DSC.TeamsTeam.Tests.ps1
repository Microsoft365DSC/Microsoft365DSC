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
    -DscResource 'TeamsTeam' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -Command Get-TeamUser -MockWith {
                return @(
                    @{
                        User = 'owner@contoso.com'
                        Role = 'owner'
                    }
                )
            }

            Mock -CommandName Get-Team -MockWith {
                return @(
                    @{
                        DisplayName  = 'TestTeam'
                        GroupID      = '1234-1234-1234-1234'
                        MailNickName = 'testteam'
                        Visibility   = 'Private'
                        Archived     = $false
                    }
                )
            }

            Mock -CommandName Set-Team -MockWith {
                return @{
                    DisplayName = 'Test Team'
                    Visibility  = 'Private'
                }
            }

            Mock -CommandName New-Team -MockWith {
                return @{
                    DisplayName = 'TestTeam'
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Start-Sleep -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'When the Team doesnt exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                       = 'TestTeam'
                    Ensure                            = 'Present'
                    Description                       = 'Test Team'
                    Visibility                        = 'Private'
                    MailNickName                      = 'teamposh'
                    AllowUserEditMessages             = $true
                    AllowUserDeleteMessages           = $false
                    AllowOwnerDeleteMessages          = $false
                    AllowTeamMentions                 = $false
                    AllowChannelMentions              = $false
                    AllowCreateUpdateChannels         = $false
                    AllowDeleteChannels               = $false
                    AllowAddRemoveApps                = $false
                    AllowCreateUpdateRemoveTabs       = $false
                    AllowCreateUpdateRemoveConnectors = $false
                    AllowGiphy                        = $True
                    GiphyContentRating                = 'Moderate'
                    AllowStickersAndMemes             = $True
                    AllowCustomMemes                  = $True
                    AllowGuestCreateUpdateChannels    = $false
                    AllowGuestDeleteChannels          = $false
                    Owner                             = @('JohnDoe@contoso.com')
                    Credential                        = $Credential
                }

                Mock -CommandName Get-Team -MockWith {
                    return $null
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'ServicePrincipalWithThumbprint'
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgUser -MockWith {
                    return @{
                        Id = '5678-5678-5678-5678'
                    }
                }

                Mock -CommandName New-MgGroup -MockWith {
                    return @{
                        Id = '1234-1234-1234-1234'
                    }
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Test() | Should -Be $false
            }

            It 'Updates the Team fun settings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Set()
                Should -Invoke -CommandName Get-MgUser -Exactly 1 -ParameterFilter { $UserId -eq 'JohnDoe@contoso.com' }
                Should -Invoke -CommandName New-MgGroup -Exactly 1 -ParameterFilter {
                    $BodyParameter.description -eq 'Test Team' -and $BodyParameter.visibility -eq 'Private' -and
                    $BodyParameter.'owners@odata.bind' -like '*/directoryObjects/5678-5678-5678-5678'
                }
                Should -Invoke -CommandName New-Team -Exactly 1 -ParameterFilter { $GroupId -eq '1234-1234-1234-1234' }
                Should -Invoke -CommandName Set-Team -Exactly 1 -ParameterFilter { $GroupId -eq '1234-1234-1234-1234' -and $GiphyContentRating -eq 'Moderate' }
            }
        }

        Context -Name 'The Team already exists - Credential' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'TestTeam'
                    Ensure      = 'Present'
                    Visibility  = 'Private'
                    Owner       = @('owner@contoso.com')
                    Credential  = $Credential
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The Team already exists and is in the Desired State - ServicePrincipal' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName           = 'TestTeam'
                    Ensure                = 'Present'
                    Visibility            = 'Private'
                    Owner                 = @('owner@contoso.com')
                    ApplicationId         = '12345-12345-12345'
                    TenantId              = 'contoso.onmicrosoft.com'
                    CertificateThumbprint = '123451234512345'
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'ServicePrincipal'
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The Team already exists and is NOT in the Desired State - ServicePrincipal' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName           = 'TestTeam'
                    Ensure                = 'Present'
                    Visibility            = 'Public' #Drift
                    Owner                 = @('owner@contoso.com')
                    ApplicationId         = '12345-12345-12345'
                    TenantId              = 'contoso.onmicrosoft.com'
                    CertificateThumbprint = '123451234512345'
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'ServicePrincipal'
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the values in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-Team' -Exactly 1
            }
        }

        Context -Name 'Update existing team access type' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'TestTeam'
                    Ensure      = 'Present'
                    Visibility  = 'Public' # Drift
                    Owner       = @('owner@contoso.com')
                    Credential  = $Credential
                }

                Mock -Command Get-TeamUser -MockWith {
                    return @{
                        User = 'owner@contoso.com'
                        Role = 'owner'
                    }
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the test method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Test()) | Should -Be 'False'
            }

            It 'Should set access type in set command' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Set()
            }
        }

        Context -Name 'Update team visibility' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName  = 'TestTeam'
                    Ensure       = 'Present'
                    MailNickName = 'testteam'
                    Visibility   = 'Public'
                    Description  = 'Update description'
                    Credential   = $Credential
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should update display name and description in set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Set()
            }
        }

        Context -Name 'Remove the Team' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'TestTeam'
                    Ensure      = 'Absent'
                    Credential  = $Credential
                }

                Mock -CommandName Remove-Team -MockWith {
                    return $null
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should update display name and description in set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsTeam' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsTeam' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
