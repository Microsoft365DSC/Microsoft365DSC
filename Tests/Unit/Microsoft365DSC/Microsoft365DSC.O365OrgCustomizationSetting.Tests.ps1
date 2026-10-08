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
    -DscResource 'O365OrgCustomizationSetting' -GenericStubModule $GenericStubPath

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

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        Context -Name 'When Organization Customization should be enabled' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    State            = 'Present'
                    Credential       = $Credential
                }

                Mock -CommandName Get-OrganizationConfig -MockWith {
                    return @{
                        IsDehydrated = $true
                    }
                }

                Mock -CommandName Enable-OrganizationCustomization -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                (New-M365DSCResourceInstance -ResourceName 'O365OrgCustomizationSetting' -Property $testParams).Get().State | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'O365OrgCustomizationSetting' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should enable Organization Customization from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'O365OrgCustomizationSetting' -Property $testParams).Set()
                Should -Invoke -CommandName Enable-OrganizationCustomization
            }
        }

        Context -Name 'When Organization Customization is already enabled' -Fixture {
            BeforeAll {
                $testParams = @{
                    State            = 'Present'
                    IsSingleInstance = 'Yes'
                    Credential       = $Credential
                }

                Mock -CommandName Get-OrganizationConfig -MockWith {
                    return @{
                        IsDehydrated = $false
                    }
                }

                Mock -CommandName Enable-OrganizationCustomization -MockWith {
                    return $null
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'O365OrgCustomizationSetting' -Property $testParams).Get().ToHashtable()).State | Should -Be 'Present'
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
                Mock -CommandName Get-OrganizationConfig -MockWith {
                    return @{
                        IsDehydrated = $false
                    }
                }
                $result = Invoke-M365DSCResourceMethod -ResourceName 'O365OrgCustomizationSetting' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }

            BeforeEach {
                Mock -CommandName Get-OrganizationConfig -MockWith {
                    return @{
                        IsDehydrated = $true
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'O365OrgCustomizationSetting' -MethodName 'Export' -Parameters $testParams
                $result | Should -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
