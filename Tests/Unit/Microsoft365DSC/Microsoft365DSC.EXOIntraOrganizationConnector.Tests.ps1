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
    -DscResource 'EXOIntraOrganizationConnector' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-IntraOrganizationConnector -MockWith {
            }

            Mock -CommandName Set-IntraOrganizationConnector -MockWith {
            }

            Mock -CommandName Remove-IntraOrganizationConnector -MockWith {
            }

            Mock -CommandName Get-IntraOrganizationConnector -MockWith {
                return @{
                    Ensure               = 'Present'
                    Credential           = $Credential
                    Identity             = 'TestIntraOrganizationConnector'
                    DiscoveryEndpoint    = 'https://ExternalDiscovery.Contoso.com/autodiscover/autodiscover.svc'
                    Enabled              = $true
                    TargetAddressDomains = @('contoso.com', 'contoso.org')
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'IntraOrganizationConnector creation.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure               = 'Present'
                    Credential           = $Credential
                    Identity             = 'TestIntraOrganizationConnector'
                    DiscoveryEndpoint    = 'https://ExternalDiscovery.Contoso.com/autodiscover/autodiscover.svc/'
                    Enabled              = $true
                    TargetAddressDomains = @('contoso.com', 'contoso.org')
                }

                Mock -CommandName Get-IntraOrganizationConnector -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOIntraOrganizationConnector' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOIntraOrganizationConnector' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOIntraOrganizationConnector' -Property $testParams).Set()
            }
        }

        Context -Name 'IntraOrganizationConnector update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure               = 'Present'
                    Credential           = $Credential
                    Identity             = 'TestIntraOrganizationConnector'
                    DiscoveryEndpoint    = 'https://ExternalDiscovery.Contoso.com/autodiscover/autodiscover.svc/'
                    Enabled              = $true
                    TargetAddressDomains = @('contoso.com', 'contoso.org')
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOIntraOrganizationConnector' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'IntraOrganizationConnector update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure               = 'Present'
                    Credential           = $Credential
                    Identity             = 'TestIntraOrganizationConnector'
                    DiscoveryEndpoint    = 'https://ExternalDiscovery.Contoso.com/autodiscover/autodiscover.svc/'
                    Enabled              = $false # Drift
                    TargetAddressDomains = @('contoso.com', 'contoso.org')
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOIntraOrganizationConnector' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOIntraOrganizationConnector' -Property $testParams).Set()
                Should -Invoke -CommandName Set-IntraOrganizationConnector -Exactly 1
            }
        }

        Context -Name 'IntraOrganizationConnector removal.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure            = 'Absent'
                    Credential        = $Credential
                    Identity          = 'TestIntraOrganizationConnector'
                    DiscoveryEndpoint = 'https://ExternalDiscovery.Contoso.com/autodiscover/autodiscover.svc/'
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOIntraOrganizationConnector' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the Connector in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOIntraOrganizationConnector' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-IntraOrganizationConnector -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOIntraOrganizationConnector' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
