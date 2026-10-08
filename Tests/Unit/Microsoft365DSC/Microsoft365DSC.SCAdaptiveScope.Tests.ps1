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
    -DscResource 'SCAdaptiveScope' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Add-M365DSCTelemetryEvent -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName New-AdaptiveScope -MockWith {
            }

            Mock -CommandName Set-AdaptiveScope -MockWith {
            }

            Mock -CommandName Remove-AdaptiveScope -MockWith {
            }

            $Script:filterConditions = '{"Conditions":[{"Value":"Finance","Operator":"Equals","Name":"Department"},{"Value":"Zurich","Operator":"Equals","Name":"City"}],"Conjunction":"And"}'

            $Script:NewAdaptiveScope = {
                return [PSCustomObject]@{
                    Name                    = 'Finance Zurich Users'
                    LocationType            = 'User'
                    FilterConditions        = $Script:filterConditions
                    RawQuery                = ''
                    IsRawQueryEnabled       = $false
                    UseKql                  = $null
                    AdministrativeUnit      = [System.Guid] '39400ee9-c21c-4713-b6d2-b938c1a90f8b'
                    Comment                 = 'Members of the finance department in Zurich'
                    EnabledStates           = @('Active', 'Inactive')
                    IsImplicitAdaptiveScope = $false
                    Mode                    = 'Enforce'
                }
            }

            Mock -CommandName Get-AdaptiveScope -MockWith {
                return & $Script:NewAdaptiveScope
            }

            Mock -CommandName Get-MgDirectoryAdministrativeUnit -MockWith {
                return @{
                    Id          = '39400ee9-c21c-4713-b6d2-b938c1a90f8b'
                    DisplayName = 'Amsterdam Office'
                }
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                return @{}
            }

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
                return "SCAdaptiveScope 'TestInstance' {}`r`n"
            }

            $Script:exportedInstance = $null
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The instance should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name               = 'Finance Zurich Users'
                    LocationType       = 'User'
                    FilterConditions   = $Script:filterConditions
                    AdministrativeUnit = 'Amsterdam Office'
                    Comment            = 'Members of the finance department in Zurich'
                    EnabledStates      = @('Active', 'Inactive')
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-AdaptiveScope -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-AdaptiveScope'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the instance with the administrative unit id from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-AdaptiveScope' -Exactly 1 -ParameterFilter {
                    $Name -eq 'Finance Zurich Users' -and $AdministrativeUnit -eq '39400ee9-c21c-4713-b6d2-b938c1a90f8b'
                }
            }
        }

        Context -Name 'The instance should exist with both FilterConditions and RawQuery' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name             = 'Finance Zurich Users'
                    LocationType     = 'User'
                    FilterConditions = $Script:filterConditions
                    RawQuery         = "Department -eq 'Finance'"
                    Ensure           = 'Present'
                    Credential       = $Credential
                }

                Mock -CommandName Get-AdaptiveScope -MockWith {
                    return $null
                }
            }

            It 'Should throw from the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Set() } | Should -Throw '*cannot specify both FilterConditions and RawQuery*'
                Should -Invoke -CommandName 'New-AdaptiveScope' -Exactly 0
            }
        }

        Context -Name 'The instance is pending deletion' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name         = 'Finance Zurich Users'
                    LocationType = 'User'
                    Ensure       = 'Absent'
                    Credential   = $Credential
                }

                Mock -CommandName Get-AdaptiveScope -MockWith {
                    $instance = & $Script:NewAdaptiveScope
                    $instance.Mode = 'PendingDeletion'
                    return $instance
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name         = 'Finance Zurich Users'
                    LocationType = 'User'
                    Ensure       = 'Absent'
                    Credential   = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-AdaptiveScope'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-AdaptiveScope' -Exactly 1
            }
        }

        Context -Name 'The instance exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name               = 'Finance Zurich Users'
                    LocationType       = 'User'
                    FilterConditions   = $Script:filterConditions
                    AdministrativeUnit = 'Amsterdam Office'
                    Comment            = 'Members of the finance department in Zurich'
                    EnabledStates      = @('Active', 'Inactive')
                    Ensure             = 'Present'
                    Credential         = $Credential
                }
            }

            It 'Should return the expected values from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.Name | Should -Be 'Finance Zurich Users'
                $result.LocationType | Should -Be 'User'
                $result.FilterConditions | Should -Be $Script:filterConditions
                $result.RawQuery | Should -BeNullOrEmpty
                $result.AdministrativeUnit | Should -Be 'Amsterdam Office'
                $result.Comment | Should -Be 'Members of the finance department in Zurich'
                $result.EnabledStates | Should -Be @('Active', 'Inactive')
                $result.LinkedRecipientEnabledStates | Should -BeNullOrEmpty
                Should -Invoke -CommandName 'Get-AdaptiveScope'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and FilterConditions only differ in formatting and property order' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name             = 'Finance Zurich Users'
                    LocationType     = 'User'
                    FilterConditions = @'
{
    "Conjunction": "And",
    "Conditions": [
        { "Name": "Department", "Operator": "Equals", "Value": "Finance" },
        { "Name": "City", "Operator": "Equals", "Value": "Zurich" }
    ]
}
'@
                    Ensure           = 'Present'
                    Credential       = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name               = 'Finance Zurich Users'
                    LocationType       = 'User'
                    FilterConditions   = '{"Conditions":[{"Value":"Finance","Operator":"Equals","Name":"Department"}],"Conjunction":"And"}'
                    AdministrativeUnit = 'Amsterdam Office'
                    Comment            = 'Members of the finance department located in Zurich'
                    EnabledStates      = @('Active', 'Inactive')
                    Ensure             = 'Present'
                    Credential         = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-AdaptiveScope'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance by identity without the create-only properties from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-AdaptiveScope' -Exactly 1 -ParameterFilter {
                    $Identity -eq 'Finance Zurich Users' -and
                    $Comment -eq 'Members of the finance department located in Zurich' -and
                    -not $PSBoundParameters.ContainsKey('Name') -and
                    -not $PSBoundParameters.ContainsKey('LocationType')
                }
            }
        }

        Context -Name 'The instance exists with a different LocationType' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name         = 'Finance Zurich Users'
                    LocationType = 'Group'
                    Ensure       = 'Present'
                    Credential   = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should throw from the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'SCAdaptiveScope' -Property $testParams).Set() } | Should -Throw '*LocationType*cannot be changed*'
                Should -Invoke -CommandName 'Set-AdaptiveScope' -Exactly 0
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

            It 'Should reverse engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCAdaptiveScope' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                Should -Invoke -CommandName 'Get-AdaptiveScope'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
