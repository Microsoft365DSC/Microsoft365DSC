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

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                return @{
                    value = @(
                        @{
                            issuerUri                       = 'https://contoso.com/issuerUri'
                            displayName                     = 'contoso display name'
                            metadataExchangeUri             = 'https://contoso.com/metadataExchangeUri'
                            passiveSignInUri                = 'https://contoso.com/signin'
                            preferredAuthenticationProtocol = 'wsFed'
                            domains                         = @(
                                @{
                                    "@odata.type" = "microsoft.graph.externalDomainName"
                                    id            = "contoso.com"
                                }
                            )
                            signingCertificate              = 'MIIDADCCAeigAwIBAgIQEX41y8r6'
                        }
                    )
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
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
                    IssuerUri                       = 'https://contoso.com/issuerUri'
                    DisplayName                     = 'contoso display name'
                    MetadataExchangeUri             ='https://contoso.com/metadataExchangeUri'
                    PassiveSignInUri                = 'https://contoso.com/signin'
                    PreferredAuthenticationProtocol = 'wsFed'
                    Domains                         = @('contoso.com')
                    SigningCertificate              = 'MIIDADCCAeigAwIBAgIQEX41y8r6'
                    Ensure                          = 'Present'
                    Credential          = $Credential;
                }

                Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADFederationConfiguration' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFederationConfiguration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFederationConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 2
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    IssuerUri                       = 'https://contoso.com/issuerUri'
                    DisplayName                     = 'contoso display name'
                    MetadataExchangeUri             = 'https://contoso.com/metadataExchangeUri'
                    PassiveSignInUri                = 'https://contoso.com/signin'
                    PreferredAuthenticationProtocol = 'wsFed'
                    Domains                         = @('contoso.com')
                    SigningCertificate              = 'MIIDADCCAeigAwIBAgIQEX41y8r6'
                    Ensure                          = 'Absent'
                    Credential                      = $Credential;
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADFederationConfiguration' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFederationConfiguration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFederationConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 2
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    IssuerUri                       = 'https://contoso.com/issuerUri'
                    DisplayName                     = 'contoso display name'
                    MetadataExchangeUri             = 'https://contoso.com/metadataExchangeUri'
                    PassiveSignInUri                = 'https://contoso.com/signin'
                    PreferredAuthenticationProtocol = 'wsFed'
                    Domains                         = @('contoso.com')
                    SigningCertificate              = 'MIIDADCCAeigAwIBAgIQEX41y8r6'
                    Ensure                          = 'Present'
                    Credential                      = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFederationConfiguration' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    IssuerUri                       = 'https://contoso.com/issuerUri'
                    DisplayName                     = 'contoso display name'
                    MetadataExchangeUri             = 'https://contoso.com/metadataExchangeUri'
                    PassiveSignInUri                = 'https://contoso.com/Drift' # Drift
                    PreferredAuthenticationProtocol = 'wsFed'
                    Domains                         = @('fabrikam.com') # Drift
                    SigningCertificate              = 'MIIDADCCAeigAwIBAgIQEX41y8r6'
                    Ensure                          = 'Present'
                    Credential                      = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADFederationConfiguration' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFederationConfiguration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFederationConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 4
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -ParameterFilter {
                    $Method -eq 'PATCH' -and $Body -notmatch '"domains"'
                } -Exactly 1
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -ParameterFilter {
                    $Method -eq 'POST' -and $Uri -like '*/domains' -and $Body -match 'fabrikam.com'
                } -Exactly 1
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -ParameterFilter {
                    $Method -eq 'DELETE' -and $Uri -like '*/domains/contoso.com'
                } -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADFederationConfiguration' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
