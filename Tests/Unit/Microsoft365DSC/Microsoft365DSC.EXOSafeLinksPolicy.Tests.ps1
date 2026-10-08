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
    -DscResource 'EXOSafeLinksPolicy' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Remove-SafeLinksPolicy -MockWith {
            }

            Mock -CommandName New-SafeLinksPolicy -MockWith {
            }

            Mock -CommandName Set-SafeLinksPolicy -MockWith {
            }

            Mock -CommandName Get-SafeLinksPolicy -MockWith {
                return @{
                    Identity                      = 'TestSafeLinksPolicy'
                    AdminDisplayName              = 'Test SafeLinks Policy'
                    CustomNotificationText        = ''
                    DoNotRewriteUrls              = @('test.contoso.com', 'test.fabrikam.org')
                    EnableForInternalSenders      = $false
                    EnableSafeLinksForEmail       = $false
                    EnableSafeLinksForTeams       = $false
                    EnableOrganizationBranding    = $false
                    ScanUrls                      = $false
                    UseTranslatedNotificationText = $false
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'SafeLinksPolicy creation.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                        = 'Present'
                    Identity                      = 'TestSafeLinksPolicy'
                    Credential                    = $Credential
                    AdminDisplayName              = 'Test SafeLinks Policy'
                    CustomNotificationText        = ''
                    DoNotRewriteUrls              = @('test.contoso.com', 'test.fabrikam.org')
                    EnableForInternalSenders      = $false
                    EnableSafeLinksForEmail       = $false
                    EnableSafeLinksForTeams       = $false
                    EnableOrganizationBranding    = $false
                    ScanUrls                      = $false
                    UseTranslatedNotificationText = $false
                }

                Mock -CommandName Get-SafeLinksPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSafeLinksPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSafeLinksPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-SafeLinksPolicy -Exactly 1
            }
        }

        Context -Name 'SafeLinksPolicy update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                        = 'Present'
                    Identity                      = 'TestSafeLinksPolicy'
                    Credential                    = $Credential
                    AdminDisplayName              = 'Test SafeLinks Policy'
                    CustomNotificationText        = ''
                    DoNotRewriteUrls              = @('test.contoso.com', 'test.fabrikam.org')
                    EnableForInternalSenders      = $false
                    EnableSafeLinksForEmail       = $false
                    EnableSafeLinksForTeams       = $false
                    EnableOrganizationBranding    = $false
                    ScanUrls                      = $false
                    UseTranslatedNotificationText = $false
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSafeLinksPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'SafeLinksPolicy update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                        = 'Present'
                    Identity                      = 'TestSafeLinksPolicy'
                    Credential                    = $Credential
                    AdminDisplayName              = 'Test SafeLinks Policy'
                    CustomNotificationText        = ''
                    DoNotRewriteUrls              = @('test.contoso.com', 'test.fabrikam.org')
                    EnableForInternalSenders      = $true # Drift
                    EnableSafeLinksForEmail       = $false
                    EnableSafeLinksForTeams       = $false
                    EnableOrganizationBranding    = $false
                    ScanUrls                      = $false
                    UseTranslatedNotificationText = $false
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSafeLinksPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSafeLinksPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-SafeLinksPolicy -Exactly 1
            }
        }

        Context -Name 'SafeLinksPolicy removal.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                        = 'Absent'
                    Identity                      = 'TestSafeLinksPolicy'
                    Credential                    = $Credential
                    AdminDisplayName              = 'Test SafeLinks Policy'
                    CustomNotificationText        = ''
                    DoNotRewriteUrls              = @('test.contoso.com', 'test.fabrikam.org')
                    EnableForInternalSenders      = $false
                    EnableSafeLinksForEmail       = $false
                    EnableSafeLinksForTeams       = $false
                    EnableOrganizationBranding    = $false
                    ScanUrls                      = $false
                    UseTranslatedNotificationText = $false
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSafeLinksPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSafeLinksPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-SafeLinksPolicy -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Confirm-ImportedCmdletIsAvailable -MockWith {
                    return $true
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOSafeLinksPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
