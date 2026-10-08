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

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Get-MgBetaDomain -MockWith {
                return @{
                    Id                 = "contoso.com"
                    AuthenticationType = "Managed"
                }
            }

            Mock -CommandName Get-MgBetaDomainFederationConfiguration -MockWith {
                return @{
                    Id                                      = "12345678-1234-1234-1234-123456789012"
                    DisplayName                             = "Contoso Federation"
                    IssuerUri                               = "http://contoso.com/adfs/services/trust"
                    MetadataExchangeUri                     = "https://adfs.contoso.com/FederationMetadata/2007-06/FederationMetadata.xml"
                    SigningCertificate                      = "MIIDdzCCAl+gAwIBAgIQXWWjEQ=="
                    NextSigningCertificate                  = $null
                    PassiveSignInUri                        = "https://adfs.contoso.com/adfs/ls/"
                    ActiveSignInUri                         = "https://adfs.contoso.com/adfs/services/trust/2005/usernamemixed"
                    SignOutUri                              = "https://adfs.contoso.com/adfs/ls/?wa=wsignout1.0"
                    PreferredAuthenticationProtocol         = "wsFed"
                    PromptLoginBehavior                     = $null
                    FederatedIdpMfaBehavior                 = "acceptIfMfaDoneByFederatedIdp"
                    PasswordResetUri                        = "https://adfs.contoso.com/adfs/portal/updatepassword/"
                    IsSignedAuthenticationRequestRequired   = $true
                }
            }

            Mock -CommandName New-MgBetaDomainFederationConfiguration -MockWith {
            }

            Mock -CommandName Update-MgBetaDomainFederationConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDomainFederationConfiguration -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DomainId                                = "contoso.com"
                    DisplayName                             = "Contoso Federation"
                    IssuerUri                               = "http://contoso.com/adfs/services/trust"
                    MetadataExchangeUri                     = "https://adfs.contoso.com/FederationMetadata/2007-06/FederationMetadata.xml"
                    PassiveSignInUri                        = "https://adfs.contoso.com/adfs/ls/"
                    PreferredAuthenticationProtocol         = "wsFed"
                    SigningCertificate                      = "MIIDdzCCAl+gAwIBAgIQXWWjEQ=="
                    FederatedIdpMfaBehavior                 = "acceptIfMfaDoneByFederatedIdp"
                    IsSignedAuthenticationRequestRequired   = $true
                    Ensure                                  = "Present"
                    Credential                              = $Credential
                }

                Mock -CommandName Get-MgBetaDomainFederationConfiguration -MockWith {
                    return $null
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDomainFederationConfiguration -Exactly 1
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DomainId   = "contoso.com"
                    Ensure     = "Absent"
                    Credential = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDomainFederationConfiguration -Exactly 1
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DomainId                                = "contoso.com"
                    DisplayName                             = "Contoso Federation"
                    IssuerUri                               = "http://contoso.com/adfs/services/trust"
                    MetadataExchangeUri                     = "https://adfs.contoso.com/FederationMetadata/2007-06/FederationMetadata.xml"
                    PassiveSignInUri                        = "https://adfs.contoso.com/adfs/ls/"
                    ActiveSignInUri                         = "https://adfs.contoso.com/adfs/services/trust/2005/usernamemixed"
                    SignOutUri                              = "https://adfs.contoso.com/adfs/ls/?wa=wsignout1.0"
                    PreferredAuthenticationProtocol         = "wsFed"
                    SigningCertificate                      = "MIIDdzCCAl+gAwIBAgIQXWWjEQ=="
                    FederatedIdpMfaBehavior                 = "acceptIfMfaDoneByFederatedIdp"
                    PasswordResetUri                        = "https://adfs.contoso.com/adfs/portal/updatepassword/"
                    IsSignedAuthenticationRequestRequired   = $true
                    Ensure                                  = "Present"
                    Credential                              = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DomainId                                = "contoso.com"
                    DisplayName                             = "Updated Contoso Federation"
                    IssuerUri                               = "http://contoso.com/adfs/services/trust"
                    MetadataExchangeUri                     = "https://adfs.contoso.com/FederationMetadata/2007-06/FederationMetadata.xml"
                    PassiveSignInUri                        = "https://adfs.contoso.com/adfs/ls/"
                    PreferredAuthenticationProtocol         = "saml"
                    SigningCertificate                      = "MIIDdzCCAl+gAwIBAgIQXWWjEQ=="
                    FederatedIdpMfaBehavior                 = "enforceMfaByFederatedIdp"
                    IsSignedAuthenticationRequestRequired   = $false
                    Ensure                                  = "Present"
                    Credential                              = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDomainFederationConfiguration -Exactly 1
            }
        }

        Context -Name "Domain has non-Managed authentication type" -Fixture {
            BeforeAll {
                $testParams = @{
                    DomainId                                = "contoso.com"
                    DisplayName                             = "Contoso Federation"
                    IssuerUri                               = "http://contoso.com/adfs/services/trust"
                    PassiveSignInUri                        = "https://adfs.contoso.com/adfs/ls/"
                    PreferredAuthenticationProtocol         = "wsFed"
                    SigningCertificate                      = "MIIDdzCCAl+gAwIBAgIQXWWjEQ=="
                    Ensure                                  = "Present"
                    Credential                              = $Credential
                }

                Mock -CommandName Get-MgBetaDomain -MockWith {
                    return @{
                        Id                 = "contoso.com"
                        AuthenticationType = "Federated"
                    }
                }

                Mock -CommandName Get-MgBetaDomainFederationConfiguration -MockWith {
                    return $null
                }
            }

            It 'Should throw an error when creating federation on non-Managed domain' {
                { (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Set() } | Should -Throw "*must have AuthenticationType 'Managed'*"
            }
        }

        Context -Name "Certificate rollover scenario with NextSigningCertificate" -Fixture {
            BeforeAll {
                $testParams = @{
                    DomainId                                = "contoso.com"
                    DisplayName                             = "Contoso Federation"
                    IssuerUri                               = "http://contoso.com/adfs/services/trust"
                    MetadataExchangeUri                     = "https://adfs.contoso.com/FederationMetadata/2007-06/FederationMetadata.xml"
                    PassiveSignInUri                        = "https://adfs.contoso.com/adfs/ls/"
                    PreferredAuthenticationProtocol         = "wsFed"
                    SigningCertificate                      = "MIIDdzCCAl+gAwIBAgIQXWWjEQ=="
                    NextSigningCertificate                  = "MIIDdzCCAl+gAwIBAgIQYZZkFR=="
                    FederatedIdpMfaBehavior                 = "acceptIfMfaDoneByFederatedIdp"
                    IsSignedAuthenticationRequestRequired   = $true
                    Ensure                                  = "Present"
                    Credential                              = $Credential
                }

                Mock -CommandName Get-MgBetaDomainFederationConfiguration -MockWith {
                    return @{
                        Id                                      = "12345678-1234-1234-1234-123456789012"
                        DisplayName                             = "Contoso Federation"
                        IssuerUri                               = "http://contoso.com/adfs/services/trust"
                        MetadataExchangeUri                     = "https://adfs.contoso.com/FederationMetadata/2007-06/FederationMetadata.xml"
                        SigningCertificate                      = "MIIDdzCCAl+gAwIBAgIQXWWjEQ=="
                        NextSigningCertificate                  = $null
                        PassiveSignInUri                        = "https://adfs.contoso.com/adfs/ls/"
                        ActiveSignInUri                         = "https://adfs.contoso.com/adfs/services/trust/2005/usernamemixed"
                        SignOutUri                              = "https://adfs.contoso.com/adfs/ls/?wa=wsignout1.0"
                        PreferredAuthenticationProtocol         = "wsFed"
                        PromptLoginBehavior                     = $null
                        FederatedIdpMfaBehavior                 = "acceptIfMfaDoneByFederatedIdp"
                        IsSignedAuthenticationRequestRequired   = $true
                    }
                }
            }

            It 'Should detect drift when NextSigningCertificate is added' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update configuration with NextSigningCertificate' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDomainFederationConfiguration -Exactly 1
            }
        }

        Context -Name "NextSigningCertificate already in desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DomainId                                = "contoso.com"
                    DisplayName                             = "Contoso Federation"
                    IssuerUri                               = "http://contoso.com/adfs/services/trust"
                    MetadataExchangeUri                     = "https://adfs.contoso.com/FederationMetadata/2007-06/FederationMetadata.xml"
                    PassiveSignInUri                        = "https://adfs.contoso.com/adfs/ls/"
                    PreferredAuthenticationProtocol         = "wsFed"
                    SigningCertificate                      = "MIIDdzCCAl+gAwIBAgIQXWWjEQ=="
                    NextSigningCertificate                  = "MIIDdzCCAl+gAwIBAgIQYZZkFR=="
                    FederatedIdpMfaBehavior                 = "acceptIfMfaDoneByFederatedIdp"
                    IsSignedAuthenticationRequestRequired   = $true
                    Ensure                                  = "Present"
                    Credential                              = $Credential
                }

                Mock -CommandName Get-MgBetaDomainFederationConfiguration -MockWith {
                    return @{
                        Id                                      = "12345678-1234-1234-1234-123456789012"
                        DisplayName                             = "Contoso Federation"
                        IssuerUri                               = "http://contoso.com/adfs/services/trust"
                        MetadataExchangeUri                     = "https://adfs.contoso.com/FederationMetadata/2007-06/FederationMetadata.xml"
                        SigningCertificate                      = "MIIDdzCCAl+gAwIBAgIQXWWjEQ=="
                        NextSigningCertificate                  = "MIIDdzCCAl+gAwIBAgIQYZZkFR=="
                        PassiveSignInUri                        = "https://adfs.contoso.com/adfs/ls/"
                        ActiveSignInUri                         = $null
                        SignOutUri                              = $null
                        PreferredAuthenticationProtocol         = "wsFed"
                        PromptLoginBehavior                     = $null
                        FederatedIdpMfaBehavior                 = "acceptIfMfaDoneByFederatedIdp"
                        IsSignedAuthenticationRequestRequired   = $true
                    }
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return the NextSigningCertificate from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Get().ToHashtable()).NextSigningCertificate | Should -Be "MIIDdzCCAl+gAwIBAgIQYZZkFR=="
            }

            It 'Should return true from the Test method when NextSigningCertificate matches' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should not call Update when configuration is in desired state' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDomainFederationConfiguration -Exactly 0
            }
        }

        Context -Name "PasswordResetUri is set and drifts" -Fixture {
            BeforeAll {
                $testParams = @{
                    DomainId                                = "contoso.com"
                    DisplayName                             = "Contoso Federation"
                    IssuerUri                               = "http://contoso.com/adfs/services/trust"
                    PassiveSignInUri                        = "https://adfs.contoso.com/adfs/ls/"
                    PreferredAuthenticationProtocol         = "wsFed"
                    SigningCertificate                      = "MIIDdzCCAl+gAwIBAgIQXWWjEQ=="
                    FederatedIdpMfaBehavior                 = "acceptIfMfaDoneByFederatedIdp"
                    PasswordResetUri                        = "https://adfs.contoso.com/adfs/portal/updatepassword/"
                    IsSignedAuthenticationRequestRequired   = $true
                    Ensure                                  = "Present"
                    Credential                              = $Credential
                }

                Mock -CommandName Get-MgBetaDomainFederationConfiguration -MockWith {
                    return @{
                        Id                                      = "12345678-1234-1234-1234-123456789012"
                        DisplayName                             = "Contoso Federation"
                        IssuerUri                               = "http://contoso.com/adfs/services/trust"
                        PassiveSignInUri                        = "https://adfs.contoso.com/adfs/ls/"
                        PreferredAuthenticationProtocol         = "wsFed"
                        SigningCertificate                      = "MIIDdzCCAl+gAwIBAgIQXWWjEQ=="
                        FederatedIdpMfaBehavior                 = "acceptIfMfaDoneByFederatedIdp"
                        PasswordResetUri                        = $null
                        IsSignedAuthenticationRequestRequired   = $true
                    }
                }
            }

            It 'Should return the PasswordResetUri from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Get().ToHashtable()).PasswordResetUri | Should -BeNullOrEmpty
            }

            It 'Should return false from the Test method when PasswordResetUri drifts' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method to update PasswordResetUri' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDomainFederationConfiguration -Exactly 1
            }
        }

        Context -Name "Multiple federation configurations for same domain" -Fixture {
            BeforeAll {
                $testParams = @{
                    DomainId                                = "contoso.com"
                    Id                                      = "87654321-4321-4321-4321-210987654321"
                    DisplayName                             = "Secondary Federation"
                    IssuerUri                               = "http://contoso.com/adfs2/services/trust"
                    PassiveSignInUri                        = "https://adfs2.contoso.com/adfs/ls/"
                    PreferredAuthenticationProtocol         = "saml"
                    SigningCertificate                      = "MIIDdzCCAl+gAwIBAgIQXWWjEQ=="
                    Ensure                                  = "Present"
                    Credential                              = $Credential
                }

                Mock -CommandName Get-MgBetaDomainFederationConfiguration -MockWith {
                    return @(
                        @{
                            Id                                      = "12345678-1234-1234-1234-123456789012"
                            DisplayName                             = "Primary Federation"
                            IssuerUri                               = "http://contoso.com/adfs/services/trust"
                            PreferredAuthenticationProtocol         = "wsFed"
                        },
                        @{
                            Id                                      = "87654321-4321-4321-4321-210987654321"
                            DisplayName                             = "Secondary Federation"
                            IssuerUri                               = "http://contoso.com/adfs2/services/trust"
                            PassiveSignInUri                        = "https://adfs2.contoso.com/adfs/ls/"
                            PreferredAuthenticationProtocol         = "saml"
                            SigningCertificate                      = "MIIDdzCCAl+gAwIBAgIQXWWjEQ=="
                        }
                    )
                }
            }

            It 'Should retrieve the correct federation configuration by Id' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Get().ToHashtable()
                $result.Id | Should -Be "87654321-4321-4321-4321-210987654321"
                $result.DisplayName | Should -Be "Secondary Federation"
            }

            It 'Should return true when configuration matches' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "Export with multiple domains and configurations" -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaDomain -MockWith {
                    return @(
                        @{
                            Id                 = "contoso.com"
                            AuthenticationType = "Federated"
                        },
                        @{
                            Id                 = "fabrikam.com"
                            AuthenticationType = "Federated"
                        },
                        @{
                            Id                 = "northwind.com"
                            AuthenticationType = "Managed"
                        }
                    )
                }

                Mock -CommandName Get-MgBetaDomainFederationConfiguration -MockWith {
                    param($DomainId)

                    if ($DomainId -eq "contoso.com") {
                        return @(
                            @{
                                Id                                      = "12345678-1234-1234-1234-123456789012"
                                DisplayName                             = "Contoso Primary"
                                IssuerUri                               = "http://contoso.com/adfs/services/trust"
                                PreferredAuthenticationProtocol         = "wsFed"
                            },
                            @{
                                Id                                      = "22345678-1234-1234-1234-123456789012"
                                DisplayName                             = "Contoso Secondary"
                                IssuerUri                               = "http://contoso.com/adfs2/services/trust"
                                PreferredAuthenticationProtocol         = "saml"
                            }
                        )
                    }
                    elseif ($DomainId -eq "fabrikam.com") {
                        return @{
                            Id                                      = "32345678-1234-1234-1234-123456789012"
                            DisplayName                             = "Fabrikam Federation"
                            IssuerUri                               = "http://fabrikam.com/adfs/services/trust"
                            PreferredAuthenticationProtocol         = "wsFed"
                        }
                    }
                    else {
                        return $null
                    }
                }
            }

            It 'Should export all federation configurations from all domains' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADDomainFederation' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Should export correct domain IDs and configuration details' {
                $exportedContent = Invoke-M365DSCResourceMethod -ResourceName 'AADDomainFederation' -MethodName 'Export' -Parameters $testParams

                # Verify contoso.com has 2 configurations
                $exportedContent | Should -Match "contoso.com"
                $exportedContent | Should -Match 'Contoso Primary'
                $exportedContent | Should -Match 'Contoso Secondary'

                # Verify fabrikam.com has 1 configuration
                $exportedContent | Should -Match 'fabrikam.com'
                $exportedContent | Should -Match 'Fabrikam Federation'
            }
        }

        Context -Name "Domain does not exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    DomainId                                = "nonexistent.com"
                    DisplayName                             = "Nonexistent Federation"
                    IssuerUri                               = "http://nonexistent.com/adfs/services/trust"
                    Ensure                                  = "Present"
                    Credential                              = $Credential
                }

                Mock -CommandName Get-MgBetaDomain -MockWith {
                    return $null
                }
            }

            It 'Should return Absent when domain does not exist' {
                ((New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from Test when domain does not exist' {
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name "Invalid certificate format handling" -Fixture {
            BeforeAll {
                $testParams = @{
                    DomainId                                = "contoso.com"
                    DisplayName                             = "Contoso Federation"
                    IssuerUri                               = "http://contoso.com/adfs/services/trust"
                    PassiveSignInUri                        = "https://adfs.contoso.com/adfs/ls/"
                    PreferredAuthenticationProtocol         = "wsFed"
                    SigningCertificate                      = "INVALID_BASE64_STRING!!!"
                    Ensure                                  = "Present"
                    Credential                              = $Credential
                }

                Mock -CommandName Get-MgBetaDomainFederationConfiguration -MockWith {
                    return $null
                }
            }
        }

        Context -Name "Different MFA behavior scenarios" -Fixture {
            BeforeAll {
                Mock -CommandName Get-MgBetaDomainFederationConfiguration -MockWith {
                    return @{
                        Id                                      = "12345678-1234-1234-1234-123456789012"
                        DisplayName                             = "Contoso Federation"
                        IssuerUri                               = "http://contoso.com/adfs/services/trust"
                        FederatedIdpMfaBehavior                 = "acceptIfMfaDoneByFederatedIdp"
                        PreferredAuthenticationProtocol         = "wsFed"
                    }
                }
            }

            It 'Should detect drift when changing from acceptIfMfaDoneByFederatedIdp to enforceMfaByFederatedIdp' {
                $testParams = @{
                    DomainId                = "contoso.com"
                    DisplayName             = "Contoso Federation"
                    IssuerUri               = "http://contoso.com/adfs/services/trust"
                    FederatedIdpMfaBehavior = "enforceMfaByFederatedIdp"
                    Ensure                  = "Present"
                    Credential              = $Credential
                }
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should detect drift when changing from acceptIfMfaDoneByFederatedIdp to rejectMfaByFederatedIdp' {
                $testParams = @{
                    DomainId                = "contoso.com"
                    DisplayName             = "Contoso Federation"
                    IssuerUri               = "http://contoso.com/adfs/services/trust"
                    FederatedIdpMfaBehavior = "rejectMfaByFederatedIdp"
                    Ensure                  = "Present"
                    Credential              = $Credential
                }
                (New-M365DSCResourceInstance -ResourceName 'AADDomainFederation' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaDomain -MockWith {
                    return @(
                        @{
                            Id                 = "contoso.com"
                            AuthenticationType = "Federated"
                        }
                    )
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADDomainFederation' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
