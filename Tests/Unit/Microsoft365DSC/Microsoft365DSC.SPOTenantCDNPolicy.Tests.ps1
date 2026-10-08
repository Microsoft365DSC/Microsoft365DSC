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
    -DscResource 'SPOTenantCdnPolicy' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Set-PnPTenantCDNPolicy -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Update existing Public Policies' -Fixture {
            BeforeAll {
                $testParams = @{
                    CDNType                              = 'Public'
                    ExcludeRestrictedSiteClassifications = @('Sensitive')
                    IncludeFileExtensions                = @('.gif')
                    Credential                           = $Credential
                }

                Mock -CommandName Get-PnPTenantCDNPolicies -MockWith {
                    return @{
                        CDNType                              = 'Public'
                        ExcludeRestrictedSiteClassifications = 'Secured'
                        IncludeFileExtensions                = '.php'
                    }
                }
            }

            It "Should return $false for the ExcludeIfNoScriptDisabled for the  from the Get method" {
                ((New-M365DSCResourceInstance -ResourceName 'SPOTenantCdnPolicy' -Property $testParams).Get().ToHashtable()).ExcludeRestrictedSiteClassifications | Should -Be @('Secured')
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOTenantCdnPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the policies from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOTenantCdnPolicy' -Property $testParams).Set()
            }
        }

        Context -Name 'Update existing Private Policies' -Fixture {
            BeforeAll {
                $testParams = @{
                    CDNType                              = 'Private'
                    ExcludeRestrictedSiteClassifications = @('Sensitive')
                    IncludeFileExtensions                = @('.gif')
                    Credential                           = $Credential
                }

                Mock -CommandName Get-PnPTenantCDNPolicies -MockWith {
                    return @{
                        CDNType                              = 'Private'
                        ExcludeIfNoScriptDisabled            = $false
                        ExcludeRestrictedSiteClassifications = 'Secured'
                        IncludeFileExtensions                = '.php'
                    }
                }
            }

            It "Should return $false for the ExcludeIfNoScriptDisabled for the  from the Get method" {
                ((New-M365DSCResourceInstance -ResourceName 'SPOTenantCdnPolicy' -Property $testParams).Get().ToHashtable()).ExcludeRestrictedSiteClassifications | Should -Be @('Secured')
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOTenantCdnPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the policies from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOTenantCdnPolicy' -Property $testParams).Set()
            }
        }

        Context -Name 'Policies are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    CDNType                              = 'Public'
                    ExcludeRestrictedSiteClassifications = @('Secured')
                    IncludeFileExtensions                = @('.php')
                    Credential                           = $Credential
                }

                Mock -CommandName Get-PnPTenantCDNPolicies -MockWith {
                    return @{
                        CDNType                              = 'Public'
                        ExcludeIfNoScriptDisabled            = $false
                        ExcludeRestrictedSiteClassifications = 'Secured'
                        IncludeFileExtensions                = '.php'
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOTenantCdnPolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should not update the policies from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOTenantCdnPolicy' -Property $testParams).Set()
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPTenantCDNPolicies -MockWith {
                    return @{
                        CDNType                              = 'Public'
                        ExcludeIfNoScriptDisabled            = $false
                        ExcludeRestrictedSiteClassifications = 'Secured'
                        IncludeFileExtensions                = '.php'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOTenantCdnPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }

    }
}


Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
