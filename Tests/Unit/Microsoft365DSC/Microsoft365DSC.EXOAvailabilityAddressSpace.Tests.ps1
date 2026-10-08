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
    -DscResource 'EXOAvailabilityAddressSpace' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)
            $targetCreds = New-Object System.Management.Automation.PSCredential ('tenantadmin@otherdomain.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Add-AvailabilityAddressSpace -MockWith {
            }

            Mock -CommandName Get-AvailabilityAddressSpace -MockWith {
                return @{
                    Credential            = $Credential
                    Ensure                = 'Present'
                    Identity              = 'contoso.com'
                    AccessMethod          = 'OrgWideFB'
                    Credentials           = $Null
                    ForestName            = 'contoso.com'
                    TargetAutodiscoverEpr = 'http://autodiscover.contoso.com/autodiscover/autodiscover.xml'
                }
            }

            Mock -CommandName Remove-AvailabilityAddressSpace -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'AvailabilityAddressSpace creation.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential            = $Credential
                    Ensure                = 'Present'
                    Identity              = 'contoso.com'
                    AccessMethod          = 'OrgWideFBToken'
                    ForestName            = 'contoso.com'
                    TargetServiceEpr      = 'http://autodiscover.contoso.com/autodiscover/autodiscover.xml'
                    TargetTenantId        = 'contoso.com'
                }

                Mock -CommandName Get-AvailabilityAddressSpace -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOAvailabilityAddressSpace' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAvailabilityAddressSpace' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAvailabilityAddressSpace' -Property $testParams).Set()
                Should -Invoke -CommandName Add-AvailabilityAddressSpace -Exactly 1
            }
        }

        Context -Name 'AvailabilityAddressSpace update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential            = $Credential
                    Ensure                = 'Present'
                    Identity              = 'contoso.com'
                    AccessMethod          = 'OrgWideFB'
                    Credentials           = $Null
                    ForestName            = 'contoso.com'
                    TargetAutodiscoverEpr = 'http://autodiscover.contoso.com/autodiscover/autodiscover.xml'
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAvailabilityAddressSpace' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'AvailabilityAddressSpace update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential            = $Credential
                    Ensure                = 'Present'
                    Identity              = 'Contoso Free/Busy'
                    AccessMethod          = 'PerUserFB' # Drift
                    Credentials           = $targetCreds
                    ForestName            = 'contoso.com'
                    TargetAutodiscoverEpr = 'http://autodiscover.contoso.com/autodiscover/autodiscover.xml'
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAvailabilityAddressSpace' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Successfully call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAvailabilityAddressSpace' -Property $testParams).Set()
                Should -Invoke -CommandName Add-AvailabilityAddressSpace -Exactly 1
                Should -Invoke -CommandName Remove-AvailabilityAddressSpace -Exactly 1 -ParameterFilter { $Identity -eq 'contoso.com' }
            }
        }

        Context -Name 'AvailabilityAddressSpace removal.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure     = 'Absent'
                    Credential = $Credential
                    Identity   = 'TestAvailabilityAddressSpace'
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAvailabilityAddressSpace' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the Connector in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAvailabilityAddressSpace' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-AvailabilityAddressSpace -Exactly 1 -ParameterFilter { $Identity -eq 'contoso.com' }
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOAvailabilityAddressSpace' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
