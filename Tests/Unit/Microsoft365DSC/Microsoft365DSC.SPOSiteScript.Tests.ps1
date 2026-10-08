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
    -DscResource 'SPOSiteScript' -GenericStubModule $GenericStubPath

$Global:script = @'
{
        "$schema": "schema.json",
            "actions": [
    {
    "verb": "setSiteExternalSharingCapability",
    "capability": "ExternalUserAndGuestSharing"
    }
            ],
            "bindata": { },
            "version": 1
    }
'@

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

            Mock -CommandName Add-PnPSiteScript -MockWith {
                return @{
                    Id = (New-Guid).ToString()
                }
            }

            Mock -CommandName Set-PnPSiteScript -MockWith {
            }

            Mock -CommandName Remove-PnPSiteScript -MockWith {
            }

            Mock -CommandName Start-Sleep -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Write-Warning -MockWith {
            }
        }

        # Test contexts
        Context -Name "The Script doesn't exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Title       = 'Title One'
                    Content     = $script
                    Description = "This is the description for the Site Script: 'Test Title'"
                    Credential  = $Credential
                    Ensure      = 'Present'
                }

                Mock -CommandName Add-PnPSiteScript -MockWith {
                    return @{
                        Id = '12345-67890-abcde-f0123'
                    }
                }

                # calls to Get-PnPSiteScript without proper Identity returns nothing
                Mock -CommandName Get-PnPSiteScript -ParameterFilter { $Identity -ne '12345-67890-abcde-f0123' } -MockWith {
                    return $null
                }
                # after Add-PnPSiteScript has been called, Get-PnPSiteScript should return the created site-script
                Mock -CommandName Get-PnPSiteScript -ParameterFilter { $Identity -eq '12345-67890-abcde-f0123' } -MockWith {
                    return @{
                        Id          = '12345-67890-abcde-f0123'
                        Title       = 'Title One'
                        Content     = $script
                        Description = "This is the description for the Site Script: 'Test Title'"
                    }
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSiteScript' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteScript' -Property $testParams).Test() | Should -Be $false
            }

            It 'Creates the site script in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteScript' -Property $testParams).Set()
                Should -Invoke -CommandName Add-PnPSiteScript -Exactly -Times 1
            }
        }

        Context -Name 'The site script already exist and is in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity    = '6c42cc50-7f90-45c2-9094-e8df5f9aa202'
                    Title       = 'Title One'
                    Content     = $script
                    Description = "This is the description for the Site Script: 'Test Title'"
                    Credential  = $Credential
                    Ensure      = 'Present'
                }

                Mock -CommandName Get-PnPSiteScript -MockWith {
                    return @{
                        Id          = '6c42cc50-7f90-45c2-9094-e8df5f9aa202'
                        Title       = 'Title One'
                        Content     = $script
                        Description = "This is the description for the Site Script: 'Test Title'"
                    }
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSiteScript' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteScript' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The site script already exist but is not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity    = '6c42cc50-7f90-45c2-9094-e8df5f9aa202'
                    Title       = 'Title One'
                    Content     = $script
                    Description = "This is the description for the Site Script: 'Test Title'"
                    Credential  = $Credential
                    Ensure      = 'Present'
                }

                Mock -CommandName Get-PnPSiteScript -MockWith {
                    return @{
                        Id          = '6c42cc50-7f90-45c2-9094-e8df5f9aa202'
                        Title       = 'Title One'
                        Description = "wrong description"
                    }
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSiteScript' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteScript' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the site script from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteScript' -Property $testParams).Set()
                Should -Invoke -CommandName Set-PnPSiteScript -Exactly -Times 1
            }
        }

        Context -Name 'The site script identified by Title already exist but is not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Title       = 'Title One'
                    Content     = $script
                    Description = "This is the description for the Site Script: 'Test Title'"
                    Credential  = $Credential
                    Ensure      = 'Present'
                }

                Mock -CommandName Get-PnPSiteScript -MockWith {
                    return @(
                        @{
                            Identity    = '6c42cc50-7f90-45c2-9094-e8df5f9aa202'
                            Title       = 'Title One'
                            Description = "This is the first sitescript with title 'Title One'"
                        },
                        @{
                            Identity    = '01234567-890a-bcde-f094-e8df5f9aa202'
                            Title       = 'Title One'
                            Description = "This is another sitescript with the same title"
                        }
                    )
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSiteScript' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteScript' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the site script from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteScript' -Property $testParams).Set()
                Should -Invoke -CommandName Set-PnPSiteScript -Exactly -Times 1
            }
        }

        Context -Name 'Testing site script removal' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity    = '6c42cc50-7f90-45c2-9094-e8df5f9aa202'
                    Title       = 'Title One'
                    Content     = $script
                    Description = "This is the description for the Site Script: 'Test Title'"
                    Credential  = $Credential
                    Ensure      = 'Absent'
                }

                Mock -CommandName Get-PnPSiteScript -MockWith {
                    return @{
                        Id          = '6c42cc50-7f90-45c2-9094-e8df5f9aa202'
                        Title       = 'Title One'
                        Content     = $script
                        Description = "This is the description for the Site Script: 'Test Title'"
                    }
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSiteScript' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteScript' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the site script successfully' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSiteScript' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-PnPSiteScript -Exactly -Times 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPSiteScript -MockWith {
                    return @{
                        Id    = '11111'
                        Title = 'Test'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOSiteScript' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
