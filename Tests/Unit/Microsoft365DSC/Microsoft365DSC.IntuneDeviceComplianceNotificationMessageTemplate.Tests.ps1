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
    -DscResource "IntuneDeviceComplianceNotificationMessageTemplate" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Reset-MSCloudLoginConnectionProfileContext -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementNotificationMessageTemplate -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementNotificationMessageTemplate -MockWith {
                return @{
                    BrandingOptions = "none"
                    DefaultLocale = "en-US"
                    Description = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                }
            }

            Mock -CommandName Remove-MgBetaDeviceManagementNotificationMessageTemplate -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementNotificationMessageTemplate -MockWith {
                return @{
                    BrandingOptions = "none"
                    DefaultLocale = "en-US"
                    Description = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    LocalizedNotificationMessages = @(
                        @{
                            MessageTemplate = "This is a message for English (United States)."
                            Subject = "Test English"
                            Locale = "en-us"
                            IsDefault = $True
                        }
                    )
                    Id = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                }
            }

            Mock -CommandName New-MgBetaDeviceManagementNotificationMessageTemplateLocalizedNotificationMessage -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementNotificationMessageTemplateLocalizedNotificationMessage -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementNotificationMessageTemplateLocalizedNotificationMessage -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "The IntuneDeviceComplianceNotificationMessageTemplate should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    BrandingOptions = "none"
                    Description = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    LocalizedNotificationMessages = ([MSFT_DeviceManagementNotificationMessageTemplate] @{
                        MessageTemplate = "This is a message for English (United States)."
                        Subject = "Test English"
                        Locale = "en-us"
                        IsDefault = $True
                    })
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementNotificationMessageTemplate -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceNotificationMessageTemplate' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceNotificationMessageTemplate' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should create the template from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceNotificationMessageTemplate' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementNotificationMessageTemplate -Exactly 1
            }
        }

        Context -Name "The IntuneDeviceComplianceNotificationMessageTemplate exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    BrandingOptions = "none"
                    Description = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    LocalizedNotificationMessages = ([MSFT_DeviceManagementNotificationMessageTemplate] @{
                        MessageTemplate = "This is a message for English (United States)."
                        Subject = "Test English"
                        Locale = "en-us"
                        IsDefault = $True
                    })
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceNotificationMessageTemplate' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceNotificationMessageTemplate' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceNotificationMessageTemplate' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementNotificationMessageTemplate -Exactly 1
            }
        }

        Context -Name "The IntuneDeviceComplianceNotificationMessageTemplate Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    BrandingOptions = "none"
                    Description = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    LocalizedNotificationMessages = ([MSFT_DeviceManagementNotificationMessageTemplate] @{
                        MessageTemplate = "This is a message for English (United States)."
                        Subject = "Test English"
                        Locale = "en-us"
                        IsDefault = $True
                    })
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceNotificationMessageTemplate' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneDeviceComplianceNotificationMessageTemplate exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    BrandingOptions = "none"
                    Description = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    LocalizedNotificationMessages = ([MSFT_DeviceManagementNotificationMessageTemplate] @{
                        MessageTemplate = "This is a message for English (United States)."
                        Subject = "Updated Test English" # Drift
                        Locale = "en-us"
                        IsDefault = $True
                    })
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceNotificationMessageTemplate' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceNotificationMessageTemplate' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceComplianceNotificationMessageTemplate' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementNotificationMessageTemplate -Exactly 1
                Should -Invoke -CommandName Update-MgBetaDeviceManagementNotificationMessageTemplateLocalizedNotificationMessage -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceComplianceNotificationMessageTemplate' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
