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
    -DscResource 'SPOSiteDesignRights' -GenericStubModule $GenericStubPath

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
        Context -Name 'Check Site Design Rights' -Fixture {
            BeforeAll {
                $testParams = @{
                    SiteDesignTitle = 'Customer List'
                    UserPrincipals  = 'jdoe@dsazure.com'
                    Rights          = 'View'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Grant-PnPSiteDesignRights -MockWith {
                    return @{
                        UserPrincipals = $null
                        Rights         = $null
                        Identity       = $null
                    }
                }

                Mock -CommandName Get-PnPSiteDesign -MockWith {
                    return @{
                        SiteDesignTitle = 'Customer List'
                        Id              = '12345-12345-12345-12345-12345'
                    }
                }

                Mock -CommandName Get-PnPSiteDesignRights -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSiteDesignRights' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteDesignRights' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'Check existing Site Design rights' -Fixture {
            BeforeAll {
                $testParams = @{
                    SiteDesignTitle = 'Customer List'
                    UserPrincipals  = 'jdoe@dsazure.com'
                    Rights          = 'View'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Get-PnPSiteDesign -MockWith {
                    return @{
                        Id = '12345-12345-12345-12345-12345'
                    }
                }

                Mock -CommandName Get-PnPSiteDesignRights -MockWith {
                    return @{
                        PrincipalName = 'i:0#.f|membership|jdoe@dsazure.com'
                        Rights        = 'View'
                    }
                }

                Mock -CommandName Grant-PnPSiteDesignRights -MockWith {
                    return $null
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSiteDesignRights' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteDesignRights' -Property $testParams).Test() | Should -Be $true
            }

            It 'Updates the Team fun settings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteDesignRights' -Property $testParams).Set()
            }
        }

        Context -Name 'Adding new user Site Design rights' -Fixture {
            BeforeAll {
                $testParams = @{
                    SiteDesignTitle = 'Customer List'
                    UserPrincipals  = 'jdoe@dsazure.com', 'dsmay@dsazure.com'
                    Rights          = 'View'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Get-PnPSiteDesign -MockWith {
                    return @{
                        Id = '12345-12345-12345-12345-12345'
                    }
                }

                Mock -CommandName Get-PnPSiteDesignRights -MockWith {
                    return @{
                        PrincipalName = 'i:0#.f|membership|jdoe@dsazure.com'
                        Rights        = 'View'
                    }
                }

                Mock -CommandName Grant-PnPSiteDesignRights -MockWith {
                    return $null
                }

                Mock -CommandName Revoke-PnPSiteDesignRights -MockWith {
                    return $null
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSiteDesignRights' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteDesignRights' -Property $testParams).Test() | Should -Be $false
            }

            It 'Updates the user design rights in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteDesignRights' -Property $testParams).Set()
            }
        }

        Context -Name 'Removing a user Site Design rights' -Fixture {
            BeforeAll {
                $testParams = @{
                    SiteDesignTitle = 'Customer List'
                    UserPrincipals  = 'dsmay@dsazure.com'
                    Rights          = 'View'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Get-PnPSiteDesign -MockWith {
                    return @{
                        Id = '12345-12345-12345-12345-12345'
                    }
                }

                Mock -CommandName Get-PnPSiteDesignRights -MockWith {
                    return @{
                        PrincipalName = 'i:0#.f|membership|jdoe@dsazure.com'
                        Rights        = 'View'
                    }
                }

                Mock -CommandName Grant-PnPSiteDesignRights -MockWith {
                    return $null
                }

                Mock -CommandName Revoke-PnPSiteDesignRights -MockWith {
                    return $null
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSiteDesignRights' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteDesignRights' -Property $testParams).Test() | Should -Be $false
            }

            It 'Updates the user design rights in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteDesignRights' -Property $testParams).Set()
                Should -Invoke -CommandName Grant-PnPSiteDesignRights -Exactly 1 -ParameterFilter { $Principals -contains 'dsmay@dsazure.com' }
                Should -Invoke -CommandName Revoke-PnPSiteDesignRights -Exactly 1 -ParameterFilter { $Principals -contains 'jdoe@dsazure.com' }
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
                        Title = 'Customer List'
                        Id    = '12345-12345-12345-12345-12345'
                    }
                }

                Mock -CommandName Get-PnPSiteDesignRights -MockWith {
                    return @{
                        PrincipalName = 'i:0#.f|membership|john.smith@contoso.com'
                        Rights        = 'View'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOSiteDesignRights' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }

    }
}


Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
