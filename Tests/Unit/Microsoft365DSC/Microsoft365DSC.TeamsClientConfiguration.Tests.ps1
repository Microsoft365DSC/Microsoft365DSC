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
    -DscResource 'TeamsClientConfiguration' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-CsTeamsClientConfiguration -MockWith {
                return @{
                    AllowBox                         = $True
                    AllowDropBox                     = $True
                    AllowEmailIntoChannel            = $True
                    AllowGoogleDrive                 = $True
                    AllowGuestUser                   = $True
                    AllowOrganizationTab             = $True
                    AllowResourceAccountSendMessage  = $True
                    AllowScopedPeopleSearchandAccess = $False
                    AllowShareFile                   = $True
                    AllowSkypeBusinessInterop        = $True
                    ContentPin                       = 'RequiredOutsideScheduleMeeting'
                    ExtendedWorkInfoInPeopleSearch   = $False
                    UseUnifiedDomain                 = 'Disabled'
                    ResourceAccountContentAccess     = 'NoAccess'
                    RestrictedSenderList             = @('john.smith@contoso.com')
                }
            }

            Mock -CommandName Set-CsTeamsClientConfiguration -MockWith {
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
                    AllowBox                         = $True
                    AllowDropBox                     = $True
                    AllowEmailIntoChannel            = $True
                    AllowGoogleDrive                 = $True
                    AllowGuestUser                   = $True
                    AllowOrganizationTab             = $True
                    AllowResourceAccountSendMessage  = $True
                    AllowScopedPeopleSearchandAccess = $False
                    AllowShareFile                   = $True
                    AllowSkypeBusinessInterop        = $True
                    ContentPin                       = 'RequiredOutsideScheduleMeeting'
                    ExtendedWorkInfoInPeopleSearch   = $False
                    UseUnifiedDomain                 = 'Disabled'
                    Credential                       = $Credential
                    IsSingleInstance                 = 'Yes'
                    ResourceAccountContentAccess     = 'NoAccess'
                    RestrictedSenderList             = @('john.smith@contoso.com')
                }
            }

            It 'Should return true for the AllowBox property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsClientConfiguration' -Property $testParams).Get().ToHashtable()).AllowBox | Should -Be $True
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsClientConfiguration' -Property $testParams).Test() | Should -Be $true
            }

            It 'Updates the Team fun settings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsClientConfiguration' -Property $testParams).Set()
            }
        }

        Context -Name 'When settings are NOT correctly set' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowBox                         = $false
                    AllowDropBox                     = $True
                    AllowEmailIntoChannel            = $True
                    AllowGoogleDrive                 = $True
                    AllowGuestUser                   = $True
                    AllowOrganizationTab             = $True
                    AllowResourceAccountSendMessage  = $True
                    AllowScopedPeopleSearchandAccess = $False
                    AllowShareFile                   = $True
                    AllowSkypeBusinessInterop        = $True
                    ContentPin                       = 'RequiredOutsideScheduleMeeting'
                    ExtendedWorkInfoInPeopleSearch   = $False
                    UseUnifiedDomain                 = 'Disabled'
                    Credential                       = $Credential
                    IsSingleInstance                 = 'Yes'
                    ResourceAccountContentAccess     = 'NoAccess'
                    RestrictedSenderList             = @('john.smith@contoso.com', 'test@contoso.com')
                }
            }

            It 'Should return true for the AllowBox property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsClientConfiguration' -Property $testParams).Get().ToHashtable()).AllowBox | Should -Be $True
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsClientConfiguration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Updates the Teams Client settings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsClientConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsClientConfiguration
            }
        }


        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                It 'Should Reverse Engineer resource from the Export method' {
                    $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsClientConfiguration' -MethodName 'Export' -Parameters $testParams
                    $result | Should -Not -BeNullOrEmpty
                }
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
