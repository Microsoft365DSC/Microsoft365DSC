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

            Mock -CommandName New-MgBetaDirectoryCustomSecurityAttributeDefinition -MockWith{
                return @{
                    Id = "ContosoSet_ShoeSize"
                }
            }

            Mock -CommandName Update-MgBetaDirectoryCustomSecurityAttributeDefinition -MockWith{
            }

            Mock -CommandName Get-MgBetaDirectoryCustomSecurityAttributeDefinition -MockWith {
                return @{
                    AllowedValues           = @(
                        @{
                            Id = "Test"
                            IsActive = $True
                        }
                    )
                    AttributeSet            = 'ContosoSet'
                    IsCollection            = $false
                    IsSearchable            = $true
                    Name                    = "ShoeSize";
                    Status                  = "Available";
                    Type                    = "String";
                    UsePreDefinedValuesOnly = $False;
                    Description             = "What size of shoe is the person wearing?"
                    Id                      = "ContosoSet_ShoeSize"
                }
            }

            Mock -CommandName New-MgBetaDirectoryCustomSecurityAttributeDefinitionAllowedValue {
            }

            Mock -CommandName Update-MgBetaDirectoryCustomSecurityAttributeDefinitionAllowedValue {
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
                    AllowedValues           = @(
                        [MSFT_CustomSecurityAttributeAllowedValue] @{
                            ValueId  = "Test"
                            IsActive = $True
                        }
                    )
                    ApplicationId           = $ApplicationId;
                    AttributeSet            = "ContosoSet";
                    CertificateThumbprint   = $CertificateThumbprint;
                    Ensure                  = "Present";
                    IsCollection            = $False;
                    IsSearchable            = $True;
                    Name                    = "ShoeSize";
                    Status                  = "Available";
                    TenantId                = $TenantId;
                    Type                    = "String";
                    UsePreDefinedValuesOnly = $False;
                    Description             = "What size of shoe is the person wearing?"
                    Credential              = $Credential;
                }

                Mock -CommandName Get-MgBetaDirectoryCustomSecurityAttributeDefinition -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADCustomSecurityAttributeDefinition' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName Get-MgBetaDirectoryCustomSecurityAttributeDefinition -ParameterFilter {
                    $Filter -eq "attributeSet eq 'ContosoSet' and name eq 'ShoeSize'"
                } -Exactly 1
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCustomSecurityAttributeDefinition' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCustomSecurityAttributeDefinition' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDirectoryCustomSecurityAttributeDefinition -ParameterFilter {
                    $BodyParameter.AllowedValues[0].id -eq 'Test' -and $BodyParameter.AllowedValues[0].isActive -eq $true
                } -Exactly 1
                Should -Invoke -CommandName New-MgBetaDirectoryCustomSecurityAttributeDefinitionAllowedValue -Exactly 0
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationId           = $ApplicationId;
                    AllowedValues           = @(
                        [MSFT_CustomSecurityAttributeAllowedValue] @{
                            ValueId  = "Test"
                            IsActive = $True
                        }
                    )
                    AttributeSet            = "ContosoSet";
                    CertificateThumbprint   = $CertificateThumbprint;
                    Ensure                  = "Absent";
                    IsCollection            = $False;
                    IsSearchable            = $True;
                    Name                    = "ShoeSize";
                    Status                  = "Available";
                    TenantId                = $TenantId;
                    Type                    = "String";
                    UsePreDefinedValuesOnly = $False;
                    Description             = "What size of shoe is the person wearing?"
                    Credential              = $Credential;
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADCustomSecurityAttributeDefinition' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCustomSecurityAttributeDefinition' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCustomSecurityAttributeDefinition' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDirectoryCustomSecurityAttributeDefinition -Exactly 1
            }

            It 'Should return true from the Test method when the instance is deprecated' {
                Mock -CommandName Get-MgBetaDirectoryCustomSecurityAttributeDefinition -MockWith {
                    return @{
                        AllowedValues = @()
                        AttributeSet  = 'ContosoSet'
                        Name          = 'ShoeSize'
                        Status        = 'Deprecated'
                        Type          = 'String'
                        Id            = 'ContosoSet_ShoeSize'
                    }
                }

                (New-M365DSCResourceInstance -ResourceName 'AADCustomSecurityAttributeDefinition' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationId           = $ApplicationId;
                    AllowedValues           = @(
                        [MSFT_CustomSecurityAttributeAllowedValue] @{
                            ValueId  = "Test"
                            IsActive = $True
                        }
                    )
                    AttributeSet            = "ContosoSet";
                    CertificateThumbprint   = $CertificateThumbprint;
                    Ensure                  = "Present";
                    IsCollection            = $False;
                    IsSearchable            = $True;
                    Name                    = "ShoeSize";
                    Status                  = "Available";
                    TenantId                = $TenantId;
                    Type                    = "String";
                    UsePreDefinedValuesOnly = $False;
                    Description             = "What size of shoe is the person wearing?"
                    Credential              = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCustomSecurityAttributeDefinition' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists but is missing a desired allowed value" -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationId           = $ApplicationId;
                    AllowedValues           = @(
                        [MSFT_CustomSecurityAttributeAllowedValue] @{
                            ValueId  = "Test"
                            IsActive = $True
                        }
                        [MSFT_CustomSecurityAttributeAllowedValue] @{
                            ValueId  = "Missing"
                            IsActive = $True
                        }
                    )
                    AttributeSet            = "ContosoSet";
                    CertificateThumbprint   = $CertificateThumbprint;
                    Ensure                  = "Present";
                    IsCollection            = $False;
                    IsSearchable            = $True;
                    Name                    = "ShoeSize";
                    Status                  = "Available";
                    TenantId                = $TenantId;
                    Type                    = "String";
                    UsePreDefinedValuesOnly = $False;
                    Description             = "What size of shoe is the person wearing?"
                    Credential              = $Credential;
                }

                Mock -CommandName Get-MgBetaDirectoryCustomSecurityAttributeDefinition -MockWith {
                    return @{
                        AllowedValues           = @(
                            @{
                                Id       = "Test"
                                IsActive = $True
                            }
                        )
                        AttributeSet            = 'ContosoSet'
                        IsCollection            = $false
                        IsSearchable            = $true
                        Name                    = "ShoeSize";
                        Status                  = "Available";
                        Type                    = "String";
                        UsePreDefinedValuesOnly = $False;
                        Description             = "What size of shoe is the person wearing?"
                        Id                      = "ContosoSet_ShoeSize"
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCustomSecurityAttributeDefinition' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should add the missing allowed value from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCustomSecurityAttributeDefinition' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDirectoryCustomSecurityAttributeDefinition -Exactly 1
                Should -Invoke -CommandName New-MgBetaDirectoryCustomSecurityAttributeDefinitionAllowedValue -ParameterFilter {
                    $CustomSecurityAttributeDefinitionId -eq 'ContosoSet_ShoeSize' -and
                    $Id -eq 'Missing' -and
                    $IsActive -eq $true
                } -Exactly 1
                Should -Invoke -CommandName New-MgBetaDirectoryCustomSecurityAttributeDefinitionAllowedValue -Exactly 1
                Should -Invoke -CommandName Update-MgBetaDirectoryCustomSecurityAttributeDefinitionAllowedValue -Exactly 0
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationId           = $ApplicationId;
                    AllowedValues           = @(
                        [MSFT_CustomSecurityAttributeAllowedValue] @{
                            ValueId  = "Test"
                            IsActive = $True
                        }
                    )
                    AttributeSet            = "ContosoSet";
                    CertificateThumbprint   = $CertificateThumbprint;
                    Ensure                  = "Absent";
                    IsCollection            = $False;
                    IsSearchable            = $True;
                    Name                    = "ShoeSize";
                    Status                  = "Available";
                    TenantId                = $TenantId;
                    Type                    = "String";
                    UsePreDefinedValuesOnly = $False;
                    Description             = "What size of shoe is the person wearing? Drift" # drift
                    Credential              = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADCustomSecurityAttributeDefinition' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCustomSecurityAttributeDefinition' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCustomSecurityAttributeDefinition' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDirectoryCustomSecurityAttributeDefinition -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADCustomSecurityAttributeDefinition' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
