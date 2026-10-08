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

            Mock -CommandName Get-AzRoleDefinition -MockWith {
            }

            Mock -CommandName New-AzRoleDefinition -MockWith {
            }

            Mock -CommandName Set-AzRoleDefinition -MockWith {
            }

            Mock -CommandName Remove-AzRoleDefinition -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The AzureRoleDefinition should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    CustomRoleName        = "My Custom Role"
                    Description           = "A custom role for testing."
                    Actions               = @("Microsoft.Compute/virtualMachines/read")
                    NotActions            = @()
                    DataActions           = @()
                    NotDataActions        = @()
                    AssignableScopes      = @("/subscriptions/00000000-0000-0000-0000-000000000000")
                    Ensure                = 'Present'
                    SubscriptionId        = "00000000-0000-0000-0000-000000000000"
                    Credential            = $Credential
                }

                Mock -CommandName Get-AzRoleDefinition -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AzureRoleDefinition' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleDefinition' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call New-AzRoleDefinition from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleDefinition' -Property $testParams).Set()
                Should -Invoke -CommandName New-AzRoleDefinition -Exactly 1
            }

            It 'Should create a role without a description through the REST API' {
                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{ StatusCode = 201 }
                }
                $params = $testParams.Clone()
                $params.Description = ''

                (New-M365DSCResourceInstance -ResourceName 'AzureRoleDefinition' -Property $params).Set()
                Should -Invoke -CommandName New-AzRoleDefinition -Exactly 0
                Should -Invoke -CommandName Invoke-AzRestMethod -Exactly 1 -ParameterFilter {
                    $Method -eq 'PUT' -and $Path -like '/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/*' -and
                    ($Payload | ConvertFrom-Json).properties.roleName -eq 'My Custom Role'
                }
            }
        }

        Context -Name "The AzureRoleDefinition exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    CustomRoleName        = "My Custom Role"
                    Description           = "A custom role for testing."
                    Actions               = @("Microsoft.Compute/virtualMachines/read")
                    NotActions            = @()
                    DataActions           = @()
                    NotDataActions        = @()
                    AssignableScopes      = @("/subscriptions/00000000-0000-0000-0000-000000000000")
                    Ensure                = 'Absent'
                    SubscriptionId        = "00000000-0000-0000-0000-000000000000"
                    Credential            = $Credential
                }

                Mock -CommandName Get-AzRoleDefinition -MockWith {
                    return [PSCustomObject]@{
                        Name             = "My Custom Role"
                        Id               = "00000000-0000-0000-0000-000000000001"
                        Description      = "A custom role for testing."
                        Actions          = @("Microsoft.Compute/virtualMachines/read")
                        NotActions       = @()
                        DataActions      = @()
                        NotDataActions   = @()
                        AssignableScopes = @("/subscriptions/00000000-0000-0000-0000-000000000000")
                        IsCustom         = $true
                    }
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AzureRoleDefinition' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleDefinition' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call Remove-AzRoleDefinition from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleDefinition' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-AzRoleDefinition -Exactly 1
            }
        }

        Context -Name "The AzureRoleDefinition Exists and Values are already in the Desired State" -Fixture {
            BeforeAll {
                $testParams = @{
                    CustomRoleName        = "My Custom Role"
                    Description           = "A custom role for testing."
                    Actions               = @("Microsoft.Compute/virtualMachines/read")
                    NotActions            = @()
                    DataActions           = @()
                    NotDataActions        = @()
                    AssignableScopes      = @("/subscriptions/00000000-0000-0000-0000-000000000000")
                    Ensure                = 'Present'
                    SubscriptionId        = "00000000-0000-0000-0000-000000000000"
                    Credential            = $Credential
                }

                Mock -CommandName Get-AzRoleDefinition -MockWith {
                    return [PSCustomObject]@{
                        Name             = "My Custom Role"
                        Id               = "00000000-0000-0000-0000-000000000001"
                        Description      = "A custom role for testing."
                        Actions          = @("Microsoft.Compute/virtualMachines/read")
                        NotActions       = @()
                        DataActions      = @()
                        NotDataActions   = @()
                        AssignableScopes = @("/subscriptions/00000000-0000-0000-0000-000000000000")
                        IsCustom         = $true
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleDefinition' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The AzureRoleDefinition exists and values are NOT in the Desired State" -Fixture {
            BeforeAll {
                $testParams = @{
                    CustomRoleName        = "My Custom Role"
                    Description           = "A custom role for testing."
                    Actions               = @("Microsoft.Compute/virtualMachines/read")
                    NotActions            = @()
                    DataActions           = @()
                    NotDataActions        = @()
                    AssignableScopes      = @("/subscriptions/00000000-0000-0000-0000-000000000000")
                    Ensure                = 'Present'
                    SubscriptionId        = "00000000-0000-0000-0000-000000000000"
                    Credential            = $Credential
                }

                Mock -CommandName Get-AzRoleDefinition -MockWith {
                    return [PSCustomObject]@{
                        Name             = "My Custom Role"
                        Id               = "00000000-0000-0000-0000-000000000001"
                        Description      = "A DIFFERENT description with drift."
                        Actions          = @("Microsoft.Compute/virtualMachines/read")
                        NotActions       = @()
                        DataActions      = @()
                        NotDataActions   = @()
                        AssignableScopes = @("/subscriptions/00000000-0000-0000-0000-000000000000")
                        IsCustom         = $true
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleDefinition' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call Set-AzRoleDefinition from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureRoleDefinition' -Property $testParams).Set()
                Should -Invoke -CommandName Set-AzRoleDefinition -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    SubscriptionId = "00000000-0000-0000-0000-000000000000"
                    Credential     = $Credential;
                }

                Mock -CommandName Get-AzRoleDefinition -MockWith {
                    return @(
                        [PSCustomObject]@{
                            Name             = "My Custom Role"
                            Id               = "00000000-0000-0000-0000-000000000001"
                            Description      = "A custom role for testing."
                            Actions          = @("Microsoft.Compute/virtualMachines/read")
                            NotActions       = @()
                            DataActions      = @()
                            NotDataActions   = @()
                            AssignableScopes = @("/subscriptions/00000000-0000-0000-0000-000000000000")
                            IsCustom         = $true
                        }
                    )
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AzureRoleDefinition' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
