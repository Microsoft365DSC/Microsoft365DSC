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
    -DscResource 'AADNamedLocationPolicy' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Remove-MgBetaIdentityConditionalAccessNamedLocation -MockWith {
            }

            Mock -CommandName Get-MgBetaIdentityConditionalAccessNamedLocation -MockWith {
                return @{
                    DisplayName          = 'Company Network'
                    Id                   = '046956df-2367-4dd4-b7fd-c6175ec11cd5'
                    ipRanges                          = @(@{cidrAddress = '2.1.1.1/32' }, @{cidrAddress = '1.2.2.2/32' })
                    isTrusted                         = $True
                    '@odata.type'                     = '#microsoft.graph.ipNamedLocation'
                    countriesAndRegions               = $null
                    includeUnknownCountriesAndRegions = $null
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName New-MgBetaIdentityConditionalAccessNamedLocation -MockWith {
            }

            Mock -CommandName Update-MgBetaIdentityConditionalAccessNamedLocation -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The Policy should exist but it does not' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'Company Network'
                    Ensure      = 'Present'
                    IpRanges    = @('2.1.1.1/32', '1.2.2.2/32')
                    IsTrusted   = $True
                    OdataType   = '#microsoft.graph.ipNamedLocation'
                    Credential  = $Credscredential
                }

                Mock -CommandName Get-MgBetaIdentityConditionalAccessNamedLocation -MockWith {
                    return $null
                }
            }

            It 'Should return values from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADNamedLocationPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-MgBetaIdentityConditionalAccessNamedLocation' -Exactly 1
            }
            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNamedLocationPolicy' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should create the Policy from the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNamedLocationPolicy' -Property $testParams).Set()
            }
        }
        Context -Name 'The Policy exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'Company Network'
                    Ensure      = 'Absent'
                    IpRanges    = @('2.1.1.1/32', '1.2.2.2/32')
                    IsTrusted   = $True
                    OdataType   = '#microsoft.graph.ipNamedLocation'
                    Credential  = $Credscredential
                }
            }

            It 'Should return values from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADNamedLocationPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaIdentityConditionalAccessNamedLocation' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNamedLocationPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the app from the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNamedLocationPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MgBetaIdentityConditionalAccessNamedLocation' -Exactly 1
            }
        }

        Context -Name 'The Policy exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'Company Network'
                    Ensure      = 'Present'
                    IpRanges    = @('2.1.1.1/32', '1.2.2.2/32')
                    IsTrusted   = $True
                    OdataType   = '#microsoft.graph.ipNamedLocation'
                    Credential  = $Credscredential
                }
            }

            It 'Should return Values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNamedLocationPolicy' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaIdentityConditionalAccessNamedLocation' -Exactly 1
            }

            It 'Should return true from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNamedLocationPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Values are not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'Company Network'
                    Ensure      = 'Present'
                    IpRanges    = @('2.1.1.1/32', '1.2.2.2/32')
                    IsTrusted   = $false # Drift
                    OdataType   = '#microsoft.graph.ipNamedLocation'
                    Credential  = $Credscredential
                }
            }

            It 'Should return values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNamedLocationPolicy' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaIdentityConditionalAccessNamedLocation' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNamedLocationPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNamedLocationPolicy' -Property $testParams).Set()
            }
        }

        Context -Name 'Policies with duplicate names exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'Company Network'
                    Ensure      = 'Present'
                    IpRanges    = @('2.1.1.1/32', '1.2.2.2/32')
                    IsTrusted   = $True
                    OdataType   = '#microsoft.graph.ipNamedLocation'
                    Credential  = $Credscredential
                }

                Mock -CommandName Get-MgBetaIdentityConditionalAccessNamedLocation -MockWith {
                    return @(
                        @{
                            DisplayName          = 'Company Network'
                            Id                   = '046956df-2367-4dd4-b7fd-c6175ec11cd5'
                            ipRanges      = @(@{cidrAddress = '2.1.1.1/32' }, @{cidrAddress = '1.2.2.2/32' })
                            isTrusted     = $False
                            '@odata.type' = '#microsoft.graph.ipNamedLocation'
                        }
                        @{
                            DisplayName          = 'Company Network'
                            Id                   = '046956df-2367-4dd4-b7fd-c6175ec11cd6'
                            ipRanges      = @(@{cidrAddress = '2.1.1.1/32' }, @{cidrAddress = '1.2.2.2/32' })
                            isTrusted     = $False
                            '@odata.type' = '#microsoft.graph.ipNamedLocation'
                        }
                    )
                }
            }

            It 'Should return values from the get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADNamedLocationPolicy' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-MgBetaIdentityConditionalAccessNamedLocation' -Exactly 1
            }

            It 'Should call the set method' {
                { (New-M365DSCResourceInstance -ResourceName 'AADNamedLocationPolicy' -Property $testParams).Set() } | Should -Throw "More than one instance of a Named Location Policy with name {Company Network} was found. Please provide the ID parameter."
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

            It 'Should reverse engineer resource from the export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADNamedLocationPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
