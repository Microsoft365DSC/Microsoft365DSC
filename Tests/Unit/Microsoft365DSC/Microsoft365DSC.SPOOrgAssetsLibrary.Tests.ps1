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
    -DscResource 'SPOOrgAssetsLibrary' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)
            $global:tenantName = $Credential.UserName.Split('@')[1].Split('.')[0]

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-PSSession -MockWith {
            }
            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Remove-PNPOrgAssetsLibrary -MockWith {
            }

            Mock -CommandName Add-PnPOrgAssetsLibrary -MockWith {
            }

            Mock -CommandName Get-M365TenantName -MockWith {
                return 'contoso'
            }

            Mock -CommandName Get-PnPTenantCdnEnabled -ParameterFilter { $CdnType -eq 'Public' } -MockWith {
                return @{ Value = $true }
            }

            Mock -CommandName Get-PnPTenantCdnEnabled -ParameterFilter { $CdnType -eq 'Private' } -MockWith {
                return @{ Value = $false }
            }

            Mock -CommandName Get-PNPOrgAssetsLibrary -MockWith {
                return @{
                    LibraryUrl = @{
                        decodedurl = 'sites/m365dsc/Branding'
                    }
                    CdnType    = 'Public'
                }
            }

            Mock -CommandName Get-PnPTenantCdnOrigin -ParameterFilter { $CdnType -eq 'Public' } -MockWith {
                return @('SITES/M365DSC/BRANDING (configuration pending)', '*/MASTERPAGE')
            }

            Mock -CommandName Get-PnPTenantCdnOrigin -ParameterFilter { $CdnType -eq 'Private' } -MockWith {
                return @()
            }

            Mock -CommandName Remove-PnPTenantCdnOrigin -MockWith {
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
        Context -Name 'The site assets org library should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    LibraryUrl = 'https://contoso.sharepoint.com/sites/m365dsc/Branding'
                    CdnType    = 'Public'
                    Credential = $Credential
                    Ensure     = 'Present'
                }

                Mock -CommandName Get-PNPOrgAssetsLibrary -MockWith {
                    return @{
                        LibraryUrl = @{
                            decodedurl = 'sites/m365dsc/Other'
                        }
                        CdnType    = 'Public'
                    }
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOOrgAssetsLibrary' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-PNPOrgAssetsLibrary' -Exactly 1
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOOrgAssetsLibrary' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the site assets org libary from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOOrgAssetsLibrary' -Property $testParams).Set()
                Should -Invoke -CommandName 'Add-PNPOrgAssetsLibrary' -Exactly 1
            }
        }

        Context -Name 'The site assets org library exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    LibraryUrl = 'https://contoso.sharepoint.com/sites/m365dsc/Branding'
                    CdnType    = 'Public'
                    Credential = $Credential
                    Ensure     = 'Absent'
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOOrgAssetsLibrary' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-PNPOrgAssetsLibrary' -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOOrgAssetsLibrary' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the site assets org library from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOOrgAssetsLibrary' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-PNPOrgAssetsLibrary' -Exactly 1
                Should -Invoke -CommandName 'Remove-PnPTenantCdnOrigin' -Exactly 1 -ParameterFilter { $OriginUrl -eq 'sites/m365dsc/Branding' -and $CdnType -eq 'Public' }
            }
        }
        Context -Name 'The site assets org library Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    LibraryUrl = 'https://contoso.sharepoint.com/sites/m365dsc/Branding'
                    CdnType    = 'Public'
                    Credential = $Credential
                    Ensure     = 'Present'
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOOrgAssetsLibrary' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-PNPOrgAssetsLibrary' -Exactly 1
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOOrgAssetsLibrary' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The site assets org library exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    LibraryUrl   = 'https://contoso.sharepoint.com/sites/m365dsc/Branding'
                    CdnType      = 'Public'
                    ThumbnailUrl = 'https://contoso.sharepoint.com/sites/m365dsc/Branding/Logo.png' # Drift
                    Credential   = $Credential
                    Ensure       = 'Present'
                }
            }

            It 'Should return Values from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOOrgAssetsLibrary' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-PNPOrgAssetsLibrary' -Exactly 1
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOOrgAssetsLibrary' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOOrgAssetsLibrary' -Property $testParams).Set()
                Should -Invoke -CommandName 'Add-PNPOrgAssetsLibrary' -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOOrgAssetsLibrary' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
