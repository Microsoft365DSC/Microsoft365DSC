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
    -DscResource "AADVerifiedIdAuthority" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Invoke-WebRequest -MockWith {
                return @{
                    Content = (ConvertTo-Json @{
                        value = @(
                            @{
                                id = "FakeStringValue"
                                name = "FakeStringValue"
                                didModel = @{
                                    linkedDomainUrls = @("FakeStringValue")
                                    did = "did:FakeStringValue"
                                }
                                keyVaultMetadata = @{
                                    subscriptionId = "FakeStringValue"
                                    resourceGroup = "FakeStringValue"
                                    resourceName = "FakeStringValue"
                                    resourceUrl = "FakeStringValue"
                                }
                            }
                        )
                    } -Depth 10)
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            Mock -CommandName Write-Warning -MockWith {
            }
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The AADVerifiedIdAuthority should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id = "FakeStringValue"
                    Name = "FakeStringValue"
                    LinkedDomainUrl = "FakeStringValue"
                    DidMethod = "FakeStringValue"
                    KeyVaultMetadata = ([MSFT_AADVerifiedIdAuthorityKeyVaultMetadata] @{
                        SubscriptionId = "FakeStringValue"
                        ResourceGroup = "FakeStringValue"
                        ResourceName = "FakeStringValue"
                        ResourceUrl = "FakeStringValue"
                    })
                    Ensure = 'Present'
                }

                Mock -CommandName Invoke-WebRequest -MockWith {
                    return @{
                        Content = (ConvertTo-Json @())
                    }
                }

            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthority' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthority' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the id from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthority' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-WebRequest -Exactly 2
            }
        }

        Context -Name "The AADVerifiedIdAuthority exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id = "FakeStringValue"
                    Name = "FakeStringValue"
                    LinkedDomainUrl = "FakeStringValue"
                    DidMethod = "FakeStringValue"
                    KeyVaultMetadata = ([MSFT_AADVerifiedIdAuthorityKeyVaultMetadata] @{
                        SubscriptionId = "FakeStringValue"
                        ResourceGroup = "FakeStringValue"
                        ResourceName = "FakeStringValue"
                        ResourceUrl = "FakeStringValue"
                    })
                    Ensure = 'Absent'
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthority' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthority' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthority' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-WebRequest -Exactly 2
            }
        }
        Context -Name "The AADVerifiedIdAuthority Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id = "FakeStringValue"
                    Name = "FakeStringValue"
                    LinkedDomainUrl = "FakeStringValue"
                    DidMethod = "FakeStringValue"
                    KeyVaultMetadata = ([MSFT_AADVerifiedIdAuthorityKeyVaultMetadata] @{
                        SubscriptionId = "FakeStringValue"
                        ResourceGroup = "FakeStringValue"
                        ResourceName = "FakeStringValue"
                        ResourceUrl = "FakeStringValue"
                    })
                    Ensure = 'Present'
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthority' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The AADVerifiedIdAuthority exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id = "FakeStringValue"
                    Name = "FakeStringValue2"
                    LinkedDomainUrl = "FakeStringValue" # Drift
                    DidMethod = "FakeStringValue2"
                    KeyVaultMetadata = ([MSFT_AADVerifiedIdAuthorityKeyVaultMetadata] @{
                        SubscriptionId = "FakeStringValue"
                        ResourceGroup = "FakeStringValue"
                        ResourceName = "FakeStringValue"
                        ResourceUrl = "FakeStringValue"
                    })
                    Ensure = 'Present'
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthority' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthority' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthority' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-WebRequest -Exactly 2
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADVerifiedIdAuthority' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
