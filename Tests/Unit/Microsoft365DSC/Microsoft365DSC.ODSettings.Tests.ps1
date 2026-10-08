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
    -DscResource 'ODSettings' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-PnPTenant -MockWith {
                return @{
                    OneDriveStorageQuota = '1024'
                }
            }

            Mock -CommandName Set-PnPTenant -MockWith {
            }

            Mock -CommandName Set-PnPTenantSyncClientRestriction -MockWith {
            }

            Mock -CommandName Get-PnPTenantSyncClientRestriction -MockWith {
                return @{
                    OptOutOfGrooveBlock        = $false
                    OptOutOfGrooveSoftBlock    = $false
                    DisableReportProblemDialog = $false
                    BlockMacSync               = $true
                    AllowedDomainList          = @([System.Guid]::Empty)
                    TenantRestrictionEnabled   = $true
                    ExcludedFileExtensions     = @('.asmx')
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Check OneDrive Quota' -Fixture {
            BeforeAll {
                $testParams = @{
                    OneDriveStorageQuota = 1024
                    IsSingleInstance     = 'Yes'
                    Credential           = $Credential
                }

                Mock -CommandName Get-PnPTenant -MockWith {
                    return $null
                }
            }

            It 'Should throw from the Test method' {
                { (New-M365DSCResourceInstance -ResourceName 'ODSettings' -Property $testParams).Test() } | Should -Throw -ExpectedMessage 'Failed to get Tenant information'
            }

            It 'Updates the OneDriveSettings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'ODSettings' -Property $testParams).Set()
            }
        }

        Context -Name 'Set OneDrive Quota' -Fixture {
            BeforeAll {
                $testParams = @{
                    OneDriveStorageQuota                      = 1024
                    IsSingleInstance                          = 'Yes'
                    OrphanedPersonalSitesRetentionPeriod      = 60
                    OneDriveForGuestsEnabled                  = $true
                    NotificationsInOneDriveForBusinessEnabled = $true
                    ODBMembersCanShare                        = 'On'
                    ODBAccessRequests                         = 'On'
                    BlockMacSync                              = $true
                    DisableReportProblemDialog                = $true
                    TenantRestrictionEnabled                  = $true
                    DomainGuids                               = @('00000000-0000-0000-0000-000000000000')
                    ExcludedFileExtensions                    = @('.asmx')
                    GrooveBlockOption                         = 'HardOptIn'
                    Credential                                = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'ODSettings' -Property $testParams).Get().ToHashtable()).OneDriveStorageQuota | Should -Be 1024
            }

            It 'Should configure OneDrive settings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'ODSettings' -Property $testParams).Set()
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'ODSettings' -Property $testParams).Test() | Should -Be $false
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'ODSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
