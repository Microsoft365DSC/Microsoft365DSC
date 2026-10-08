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
    -DscResource 'AADApplicationFederatedIdentityCredential' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-MgApplication -MockWith {
                return @(
                    @{
                        Id          = '11111111-1111-1111-1111-111111111111'
                        DisplayName = 'App1'
                    }
                )
            }

            Mock -CommandName Get-MgApplicationFederatedIdentityCredential -MockWith {
                return @{
                    Id          = '22222222-2222-2222-2222-222222222222'
                    Name        = 'github-main'
                    Issuer      = 'https://token.actions.githubusercontent.com'
                    Subject     = 'repo:contoso/app:ref:refs/heads/main'
                    Audiences   = @('api://AzureADTokenExchange')
                    Description = 'GitHub Actions main branch'
                }
            }

            Mock -CommandName New-MgApplicationFederatedIdentityCredential -MockWith {
            }

            Mock -CommandName Update-MgApplicationFederatedIdentityCredential -MockWith {
            }

            Mock -CommandName Remove-MgApplicationFederatedIdentityCredential -MockWith {
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }

        Context -Name 'The federated identity credential should exist but it does not' -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationDisplayName = 'App1'
                    Name                = 'github-main'
                    Issuer              = 'https://token.actions.githubusercontent.com'
                    Subject             = 'repo:contoso/app:ref:refs/heads/main'
                    Audiences           = @('api://AzureADTokenExchange')
                    Description         = 'GitHub Actions main branch'
                    Ensure              = 'Present'
                    Credential          = $Credential
                }

                Mock -CommandName Get-MgApplicationFederatedIdentityCredential -MockWith {
                    return $null
                }
            }

            It 'Should return values from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADApplicationFederatedIdentityCredential' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-MgApplicationFederatedIdentityCredential' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADApplicationFederatedIdentityCredential' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the federated identity credential from the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADApplicationFederatedIdentityCredential' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgApplicationFederatedIdentityCredential' -Exactly 1
            }
        }

        Context -Name 'The federated identity credential exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationDisplayName = 'App1'
                    Name                = 'github-main'
                    Issuer              = 'https://token.actions.githubusercontent.com'
                    Subject             = 'repo:contoso/app:ref:refs/heads/main'
                    Audiences           = @('api://AzureADTokenExchange')
                    Description         = 'GitHub Actions main branch'
                    Ensure              = 'Absent'
                    Credential          = $Credential
                }
            }

            It 'Should return values from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADApplicationFederatedIdentityCredential' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgApplicationFederatedIdentityCredential' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADApplicationFederatedIdentityCredential' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the federated identity credential from the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADApplicationFederatedIdentityCredential' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MgApplicationFederatedIdentityCredential' -Exactly 1
            }
        }

        Context -Name 'The federated identity credential exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationDisplayName = 'App1'
                    Name                = 'github-main'
                    Issuer              = 'https://token.actions.githubusercontent.com'
                    Subject             = 'repo:contoso/app:ref:refs/heads/main'
                    Audiences           = @('api://AzureADTokenExchange')
                    Description         = 'GitHub Actions main branch'
                    Ensure              = 'Present'
                    Credential          = $Credential
                }
            }

            It 'Should return values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADApplicationFederatedIdentityCredential' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgApplicationFederatedIdentityCredential' -Exactly 1
            }

            It 'Should return true from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADApplicationFederatedIdentityCredential' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Values are not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationDisplayName = 'App1'
                    Name                = 'github-main'
                    Issuer              = 'https://token.actions.githubusercontent.com'
                    Subject             = 'repo:contoso/app:ref:refs/heads/main'
                    Audiences           = @('api://AzureADTokenExchange')
                    Description         = 'Updated GitHub Actions main branch'
                    Ensure              = 'Present'
                    Credential          = $Credential
                }
            }

            It 'Should return values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADApplicationFederatedIdentityCredential' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgApplicationFederatedIdentityCredential' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADApplicationFederatedIdentityCredential' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the federated identity credential from the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADApplicationFederatedIdentityCredential' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgApplicationFederatedIdentityCredential' -Exactly 1
            }
        }

        Context -Name 'Only some values are specified for an existing federated identity credential' -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationDisplayName = 'App1'
                    Name                   = 'github-main'
                    Description            = 'Updated GitHub Actions main branch'
                    Ensure                 = 'Present'
                    Credential             = $Credential
                }

                Mock -CommandName Update-MgApplicationFederatedIdentityCredential -MockWith {
                    $BodyParameter.Keys | Should -Contain 'description'
                    $BodyParameter.Keys | Should -Not -Contain 'name'
                    $BodyParameter.Keys | Should -Not -Contain 'issuer'
                    $BodyParameter.Keys | Should -Not -Contain 'subject'
                    $BodyParameter.Keys | Should -Not -Contain 'audiences'
                }
            }

            It 'Should only include specified properties in the update body' {
                (New-M365DSCResourceInstance -ResourceName 'AADApplicationFederatedIdentityCredential' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgApplicationFederatedIdentityCredential' -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADApplicationFederatedIdentityCredential' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope

