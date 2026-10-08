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
    -DscResource 'SPOStorageEntity' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-M365DSCOrganization -MockWith {
                return 'contoso.com'
            }

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-SPOAdministrationUrl -MockWith {
                return 'https://contoso-admin.sharepoint.com'
            }

            Mock -CommandName Get-PnPTenantSite -MockWith {
                return @{
                    Url = 'https://contoso-admin.sharepoint.com'
                    DenyAddAndCustomizePages = 'Enabled'
                }
            }

            Mock -CommandName Set-PnPTenantSite -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Check SPOStorageEntity' -Fixture {
            BeforeAll {
                $testParams = @{
                    Key         = 'DSCKey'
                    Value       = 'Test storage entity'
                    EntityScope = 'Site'
                    Description = 'Description created by DSC'
                    Comment     = 'Comment from DSC'
                    Ensure      = 'Present'
                    Credential  = $Credential
                    SiteUrl     = 'https://contoso-admin.sharepoint.com'
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-PnPStorageEntity -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOStorageEntity' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOStorageEntity' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'Check existing Storage Entity' -Fixture {
            BeforeAll {
                $testParams = @{
                    Key         = 'DSCKey'
                    Value       = 'Test storage entity'
                    EntityScope = 'Site'
                    Description = 'Description created by DSC'
                    Comment     = 'Comment from DSC'
                    Ensure      = 'Present'
                    SiteUrl     = 'https://contoso-admin.sharepoint.com'
                    Credential  = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-PnPStorageEntity -MockWith {
                    return @{
                        Key         = 'DSCKey'
                        Value       = 'Test storage entity'
                        EntityScope = 'Site'
                        Description = 'Description created by DSC'
                        Comment     = 'Comment from DSC'
                    }
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOStorageEntity' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOStorageEntity' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Adding storage entity' -Fixture {
            BeforeAll {
                $testParams = @{
                    Key         = 'DSCKey'
                    Value       = 'Test storage entity'
                    EntityScope = 'Site'
                    Description = 'Description created by DSC'
                    Comment     = 'Comment from DSC'
                    Ensure      = 'Present'
                    SiteUrl     = 'https://contoso-admin.sharepoint.com'
                    Credential  = $Credential
                }
                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-PnPStorageEntity -MockWith {
                    return @{
                        Key         = 'DSCKey'
                        Value       = 'Updated test storage entity'
                        EntityScope = 'Site'
                        Description = 'Description created by DSC'
                        Comment     = 'Comment from DSC'
                    }
                }

                Mock -CommandName Set-PnPStorageEntity -MockWith {
                    return @{
                        Key         = 'DSCKey'
                        Value       = 'Updated test storage entity'
                        EntityScope = 'Site'
                        Description = 'Updated description created by DSC'
                        Comment     = 'Comment from DSC'
                    }
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOStorageEntity' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOStorageEntity' -Property $testParams).Test() | Should -Be $false
            }

            It 'Updates storage entity in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOStorageEntity' -Property $testParams).Set()
            }
        }

        Context -Name 'Adding a tenant storage entity is denied' -Fixture {
            BeforeAll {
                $testParams = @{
                    Key         = 'DSCKey'
                    Value       = 'Test storage entity'
                    EntityScope = 'Tenant'
                    Ensure      = 'Present'
                    SiteUrl     = 'https://contoso-admin.sharepoint.com'
                    Credential  = $Credential
                }
                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-PnPStorageEntity -MockWith {
                    return $null
                }

                Mock -CommandName Get-PnPTenantAppCatalogUrl -MockWith {
                    return 'https://contoso.sharepoint.com/sites/appcatalog'
                }

                Mock -CommandName Set-PnPStorageEntity -MockWith {
                    throw 'Access is denied. (Exception from HRESULT: 0x80070005 (E_ACCESSDENIED))'
                }
            }

            It 'Names the app catalog and its custom script setting, and restores the setting' {
                { (New-M365DSCResourceInstance -ResourceName 'SPOStorageEntity' -Property $testParams).Set() } |
                    Should -Throw -ExpectedMessage '*https://contoso.sharepoint.com/sites/appcatalog*DenyAddAndCustomizePages was {Enabled}*'
                Should -Invoke -CommandName Set-PnPTenantSite -Exactly -Times 1 -ParameterFilter {
                    $Identity -eq 'https://contoso.sharepoint.com/sites/appcatalog' -and $NoScriptSite -eq $true
                }
            }
        }

        Context -Name 'Removing a storage entity' -Fixture {
            BeforeAll {
                $testParams = @{
                    Key         = 'DSCKey'
                    Value       = 'Test storage entity'
                    EntityScope = 'Site'
                    Description = 'Description created by DSC'
                    Comment     = 'Comment from DSC'
                    Ensure      = 'Absent'
                    SiteUrl     = 'https://contoso-admin.sharepoint.com'
                    Credential  = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-PnPStorageEntity -MockWith {
                    return @{
                        Key         = 'DSCKey'
                        Value       = 'Test storage entity'
                        EntityScope = 'Site'
                        Description = 'Description created by DSC'
                        Comment     = 'Comment from DSC'
                    }
                }

                Mock -CommandName Remove-PnPStorageEntity -MockWith {
                    return $null
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOStorageEntity' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOStorageEntity' -Property $testParams).Test() | Should -Be $false
            }

            It 'Remove storage entity in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOStorageEntity' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-PnPStorageEntity -Exactly 1 -ParameterFilter { $Key -eq 'DSCKey' -and $Scope -eq 'Site' }
                Should -Invoke -CommandName Set-PnPTenantSite -Exactly 1 -ParameterFilter { $NoScriptSite -eq $false }
                Should -Invoke -CommandName Set-PnPTenantSite -Exactly 1 -ParameterFilter { $NoScriptSite -eq $true }
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-PnPStorageEntity -MockWith {
                    return @{
                        Key         = 'DSCKey'
                        Value       = 'Test storage entity'
                        EntityScope = 'Site'
                        Description = 'Description created by DSC'
                        Comment     = 'Comment from DSC'
                        Ensure      = 'Present'
                        SiteUrl     = 'https://contoso-admin.sharepoint.com'
                        Credential  = $Credential
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOStorageEntity' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }

    }
}


Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
