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

$CurrentScriptPath = $PSCommandPath.Split('\')
$CurrentScriptName = $CurrentScriptPath[$CurrentScriptPath.Length -1]
$ResourceName      = $CurrentScriptName.Split('.')[1]
$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource $ResourceName -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementMobileApp -MockWith {
            }
            Mock -CommandName New-MgBetaDeviceAppManagementMobileApp -MockWith {
            }
            Mock -CommandName Update-MgBetaDeviceAppManagementMobileApp -MockWith {
            }
            Mock -CommandName Remove-MgBetaDeviceAppManagementMobileApp -MockWith {
            }
            Mock -CommandName Get-MgBetaDeviceAppManagementMobileAppAssignment -MockWith{
                return @()
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementMobileApp -MockWith {
                return @{
                    Id                    = "8d027f94-0682-431e-97c1-827d1879fa79"
                    Categories            = @()
                    Description           = "Microsoft 365 Apps for Windows 10 and later"
                    DisplayName           = "Microsoft 365 Apps for Windows 10 and later"
                    InformationUrl        = ""
                    IsFeatured            = $False
                    Notes                 = ""
                    PrivacyInformationUrl = ""
                    RoleScopeTagIds       = @()
                    '@odata.type' = '#microsoft.graph.officeSuiteApp'
                    excludedApps          = @{
                        teams = $false
                        sharePointDesigner = $true
                        powerPoint = $false
                        outlook = $false
                        groove = $true
                        word = $false
                        lync = $true
                        oneNote = $false
                        oneDrive = $false
                        publisher = $false
                        bing = $false
                        visio = $false
                        access = $false
                        infoPath = $true
                        excel = $false
                    }
                }
            }

            Mock -CommandName Update-MgBetaDeviceAppManagementMobileAppAssignment -MockWith{}

            Mock -CommandName Wait-M365DSCIntuneMobileAppPublished -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "1. The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                    = "8d027f94-0682-431e-97c1-827d1879fa79"
                    Categories            = @()
                    Description           = "Microsoft 365 Apps for Windows 10 and later"
                    DisplayName           = "Microsoft 365 Apps for Windows 10 and later"
                    InformationUrl        = ""
                    IsFeatured            = $False
                    PrivacyInformationUrl = ""
                    ExcludedApps          = ([MSFT_DeviceManagementMobileAppExcludedApp] @{
                        teams = $false
                        sharePointDesigner = $true
                        powerPoint = $false
                        outlook = $false
                        groove = $true
                        word = $false
                        lync = $true
                        oneNote = $false
                        oneDrive = $false
                        publisher = $false
                        bing = $false
                        visio = $false
                        access = $false
                        infoPath = $true
                        excel = $false
                    })
                    RoleScopeTagIds       = @()
                    Notes                 = ""
                    Ensure                = 'Present'
                    Credential            = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementMobileApp -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementMobileApp -ParameterFilter { -not [System.String]::IsNullOrEmpty($Filter) } -MockWith {
                    return @{
                        '@odata.type' = '#microsoft.graph.macOSOfficeSuiteApp'
                        id            = 'FakeStringValue'
                        displayName   = 'Microsoft 365 Apps for Windows 10 and later'
                    }
                }

                Mock -CommandName New-MgBetaDeviceAppManagementMobileApp -MockWith {
                    return @{
                        Id = 'FakeStringValue'
                    }
                }

                Mock -CommandName Update-DeviceAppManagementPolicyAssignment -MockWith {
                }
            }

            It '1.1 Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWindowsOfficeSuiteApp' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName Get-MgBetaDeviceAppManagementMobileApp -ParameterFilter { $Filter -eq "DisplayName eq 'Microsoft 365 Apps for Windows 10 and later'" }
            }
            It '1.2 Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWindowsOfficeSuiteApp' -Property $testParams).Test() | Should -Be $false
            }
            It '1.3 Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWindowsOfficeSuiteApp' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceAppManagementMobileApp -Exactly 1
                Should -Invoke -CommandName Wait-M365DSCIntuneMobileAppPublished -Exactly 1 -ParameterFilter { $AppId -eq 'FakeStringValue' }
                Should -Invoke -CommandName Update-DeviceAppManagementPolicyAssignment -Exactly 1 -ParameterFilter { $AppManagementPolicyId -eq 'FakeStringValue' }
            }
        }

        Context -Name "2. The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                    = "ad027f94-0682-431e-97c1-827d1879fa79"
                    Categories            = @()
                    Description           = "Microsoft 365 Apps for Windows 10 and later"
                    DisplayName           = "Microsoft 365 Apps for Windows 10 and later"
                    InformationUrl        = ""
                    IsFeatured            = $False
                    ExcludedApps          = ([MSFT_DeviceManagementMobileAppExcludedApp] @{
                        teams = $false
                        sharePointDesigner = $true
                        powerPoint = $false
                        outlook = $false
                        groove = $true
                        word = $false
                        lync = $true
                        oneNote = $false
                        oneDrive = $false
                        publisher = $false
                        bing = $false
                        visio = $false
                        access = $false
                        infoPath = $true
                        excel = $false
                    })
                    Notes                 = ""
                    PrivacyInformationUrl = ""
                    RoleScopeTagIds       = @()
                    Ensure                = 'Absent'
                    Credential            = $Credential
                }
            }

            It '2.1 Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWindowsOfficeSuiteApp' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It '2.2 Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWindowsOfficeSuiteApp' -Property $testParams).Test() | Should -Be $false
            }
            It '2.3 Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWindowsOfficeSuiteApp' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceAppManagementMobileApp -Exactly 1
            }
        }

        Context -Name "3. The instance exists and values are already in the desired state" -Fixture {
        BeforeAll {
            $testParams = @{
                Id                    = "ad027f94-0682-431e-97c1-827d1879fa79"
                Categories            = @()
                Description           = "Microsoft 365 Apps for Windows 10 and later"
                DisplayName           = "Microsoft 365 Apps for Windows 10 and later"
                InformationUrl        = ""
                IsFeatured            = $False
                ExcludedApps          = ([MSFT_DeviceManagementMobileAppExcludedApp] @{
                    teams = $false
                    sharePointDesigner = $true
                    powerPoint = $false
                    outlook = $false
                    groove = $true
                    word = $false
                    lync = $true
                    oneNote = $false
                    oneDrive = $false
                    publisher = $false
                    bing = $false
                    visio = $false
                    access = $false
                    infoPath = $true
                    excel = $false
                })
                Notes                 = ""
                PrivacyInformationUrl = ""
                RoleScopeTagIds       = @()
                Ensure                = 'Present'
                Credential            = $Credential
            }
        }

        It '3.0 Should return true from the Test method' {
            (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWindowsOfficeSuiteApp' -Property $testParams).Test() | Should -Be $true
        }
    }

        Context -Name "4. The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                    = "8d027f94-0682-431e-97c1-827d1879fa79"
                    Categories            = @()
                    Description           = "Microsoft 365 Apps for Windows 10 and later"
                    DisplayName           = "Microsoft 365 Apps for Windows 10 and later"
                    InformationUrl        = ""
                    IsFeatured            = $False
                    ExcludedApps          = ([MSFT_DeviceManagementMobileAppExcludedApp] @{
                        teams = $false
                        sharePointDesigner = $false # Updated property
                        powerPoint = $false
                        outlook = $false
                        groove = $true
                        word = $false
                        lync = $true
                        oneNote = $false
                        oneDrive = $false
                        publisher = $false
                        bing = $false
                        visio = $false
                        access = $false
                        infoPath = $true
                        excel = $false
                    })
                    Notes                 = ""
                    PrivacyInformationUrl = ""
                    RoleScopeTagIds       = @()
                    Ensure                = 'Present'
                    Credential            = $Credential;
                }
            }

            It '4.1 Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWindowsOfficeSuiteApp' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It '4.2 Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWindowsOfficeSuiteApp' -Property $testParams).Test() | Should -Be $false
            }
            It '4.3 Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneMobileAppsWindowsOfficeSuiteApp' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceAppManagementMobileApp -Exactly 1
            }
        }

        Context -Name '5. ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }
            }

            It '5.0 Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneMobileAppsWindowsOfficeSuiteApp' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
