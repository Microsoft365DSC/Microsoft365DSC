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

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName New-ServicePrincipal -MockWith {
            }

            Mock -CommandName Remove-ServicePrincipal -MockWith {
            }

            Mock -CommandName Set-ServicePrincipal -MockWith {
            }

            Mock -CommandName Get-ServicePrincipal -MockWith {
                return @{
                    AppId                = "c6871074-3ded-4935-a5dc-b8f8d91d7d06";
                    DisplayName          = "Arpita";
                    Identity             = "00f6b0e4-1d00-427b-9a5b-ce6c43c43fc7";
                    Ensure               = "Present"
                    Credential           = $Credential;
                }
            }
            Mock -CommandName Get-MgServicePrincipal -MockWith {
                return @{
                    AppDisplayName       = "ISV Portal";
                    DisplayName          = "ISV Portal";
                    Id                   = "00f6b0e4-1d00-427b-9a5b-ce6c43c43fc7"
                    AppId                = "f53895d3-095d-408f-8e93-8f94b391404e"
                    SignInAudience       = "AzureADMultipleOrgs"
                    ServicePrincipalType = "Application"
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AppId                = "c6871074-3ded-4935-a5dc-b8f8d91d7d06";
                    AppName              = "ISV Portal";
                    DisplayName          = "Arpita";
                    Ensure               = "Present";
                    Identity             = "00f6b0e4-1d00-427b-9a5b-ce6c43c43fc7";
                    Credential           = $Credential;
                }

                Mock -CommandName Get-ServicePrincipal -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgServicePrincipal -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOServicePrincipal' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOServicePrincipal' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOServicePrincipal' -Property $testParams).Set()
                Should -Invoke -CommandName New-ServicePrincipal -Exactly 1
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AppId                = "c6871074-3ded-4935-a5dc-b8f8d91d7d06";
                    AppName              = "ISV Portal";
                    DisplayName          = "Arpita";
                    Ensure               = "Absent";
                    Identity             = "00f6b0e4-1d00-427b-9a5b-ce6c43c43fc7";
                    Credential           = $Credential;
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOServicePrincipal' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOServicePrincipal' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOServicePrincipal' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-ServicePrincipal -Exactly 1
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AppId                = "c6871074-3ded-4935-a5dc-b8f8d91d7d06";
                    AppName              = "ISV Portal";
                    DisplayName          = "Arpita";
                    Identity             = "00f6b0e4-1d00-427b-9a5b-ce6c43c43fc7";
                    Ensure               = "Present"
                    Credential           = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOServicePrincipal' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AppId                = "c6871074-3ded-4935-a5dc-b8f8d91d7d06";
                    AppName              = "ISV Portal";
                    DisplayName          = "Aditya";   # Drift
                    Identity             = "00f6b0e4-1d00-427b-9a5b-ce6c43c43fc7";
                    Ensure               = "Present"
                    Credential           = $Credential;

                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOServicePrincipal' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOServicePrincipal' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOServicePrincipal' -Property $testParams).Set()
                Should -Invoke -CommandName Set-ServicePrincipal -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOServicePrincipal' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
