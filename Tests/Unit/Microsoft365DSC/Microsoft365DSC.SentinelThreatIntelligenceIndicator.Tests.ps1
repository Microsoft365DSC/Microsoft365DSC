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

            Mock -CommandName Get-AzResource -MockWith {
                return @{
                    ResourceGroupName = "MyResourceGroup"
                    Name              = 'MySentinelWorkspace'
                    ResourceId        = "name/part/resourceId/"
                }
            }

            Mock -CommandName Get-M365DSCAPIEndpoint -MockWith {
                return @{
                    AzureManagement = 'https://management.azure.com'
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
                    DisplayName            = "MyIndicator";
                    Labels                 = @("Tag1", "Tag2");
                    Pattern                = "[ipv6-addr:value = '2607:fa49:d340:f600:c8d5:6961:247f:a238']";
                    PatternType            = "ipv6-addr";
                    ResourceGroupName      = "MyResourceGroup";
                    Source                 = "Microsoft Sentinel";
                    SubscriptionId         = "12345-12345-12345-12345-12345";
                    ThreatIntelligenceTags = @();
                    ValidFrom              = "2024-10-21T19:03:57.24Z";
                    ValidUntil             = "2024-10-21T19:03:57.24Z";
                    WorkspaceName          = "SentinelWorkspace";
                    Ensure                 = 'Present'
                    Credential             = $Credential;
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        StatusCode = 200
                        Content    = '{}'
                    }
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SentinelThreatIntelligenceIndicator' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SentinelThreatIntelligenceIndicator' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SentinelThreatIntelligenceIndicator' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-AzRestMethod -ParameterFilter { $Method -eq 'POST' } -Exactly 1
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = "MyIndicator";
                    Labels                 = @("Tag1", "Tag2");
                    Pattern                = "[ipv6-addr:value = '2607:fa49:d340:f600:c8d5:6961:247f:a238']";
                    PatternType            = "ipv6-addr";
                    ResourceGroupName      = "MyResourceGroup";
                    Source                 = "Microsoft Sentinel";
                    SubscriptionId         = "12345-12345-12345-12345-12345";
                    ThreatIntelligenceTags = @();
                    ValidFrom              = "2024-10-21T19:03:57.24Z";
                    ValidUntil             = "2024-10-21T19:03:57.24Z";
                    WorkspaceName          = "SentinelWorkspace";
                    Ensure                 = 'Absent'
                    Credential             = $Credential;
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    $indicator = @{
                        name = '12345-12345-12345-12345-12345'
                        properties = @{
                            displayName            = 'MyIndicator'
                            labels                 = @("Tag1", "Tag2")
                            pattern                = "[ipv6-addr:value = '2607:fa49:d340:f600:c8d5:6961:247f:a238']";
                            patternType            = "ipv6-addr";
                            threatIntelligenceTags = @();
                            validFrom              = "2024-10-21T19:03:57.24Z";
                            validUntil             = "2024-10-21T19:03:57.24Z";
                        }
                    }
                    if ($Uri -like '*/indicators/*')
                    {
                        return @{
                            StatusCode = 200
                            Content    = (ConvertTo-Json $indicator -Depth 10)
                        }
                    }
                    return @{
                        StatusCode = 200
                        Content    = (ConvertTo-Json @{ value = @($indicator) } -Depth 10)
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SentinelThreatIntelligenceIndicator' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SentinelThreatIntelligenceIndicator' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SentinelThreatIntelligenceIndicator' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-AzRestMethod -ParameterFilter { $Method -eq 'DELETE' } -Exactly 1
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                # The Azure REST payload is JSON, so ConvertFrom-Json materialises the timestamps as DateTime.
                $timestampValue = (ConvertFrom-Json '"2024-10-21T19:03:57.24Z"').ToString()
                $testParams = @{
                    DisplayName            = "MyIndicator";
                    Labels                 = @("Tag1", "Tag2");
                    Pattern                = "[ipv6-addr:value = '2607:fa49:d340:f600:c8d5:6961:247f:a238']";
                    PatternType            = "ipv6-addr";
                    ResourceGroupName      = "MyResourceGroup";
                    Source                 = "Microsoft Sentinel";
                    SubscriptionId         = "12345-12345-12345-12345-12345";
                    ThreatIntelligenceTags = @();
                    ValidFrom              = $timestampValue;
                    ValidUntil             = $timestampValue;
                    WorkspaceName          = "SentinelWorkspace";
                    Ensure                 = 'Present'
                    Credential             = $Credential;
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    $indicator = @{
                        name = '12345-12345-12345-12345-12345'
                        properties = @{
                            displayName            = 'MyIndicator'
                            labels                 = @("Tag1", "Tag2")
                            pattern                = "[ipv6-addr:value = '2607:fa49:d340:f600:c8d5:6961:247f:a238']";
                            patternType            = "ipv6-addr";
                            threatIntelligenceTags = @();
                            validFrom              = "2024-10-21T19:03:57.24Z";
                            validUntil             = "2024-10-21T19:03:57.24Z";
                            source                 = 'Microsoft Sentinel'
                        }
                    }
                    if ($Uri -like '*/indicators/*')
                    {
                        return @{
                            StatusCode = 200
                            Content    = (ConvertTo-Json $indicator -Depth 10)
                        }
                    }
                    return @{
                        StatusCode = 200
                        Content    = (ConvertTo-Json @{ value = @($indicator) } -Depth 10)
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SentinelThreatIntelligenceIndicator' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName            = "MyIndicator";
                    Labels                 = @("Tag1", "Tag2");
                    Pattern                = "[ipv6-addr:value = '2607:fa49:d340:f600:c8d5:6961:247f:a238']";
                    PatternType            = "ipv6-addr";
                    ResourceGroupName      = "MyResourceGroup";
                    Source                 = "Microsoft Sentinel";
                    SubscriptionId         = "12345-12345-12345-12345-12345";
                    ThreatIntelligenceTags = @();
                    ValidFrom              = "2024-10-21T19:03:57.24Z";
                    ValidUntil             = "2024-10-21T19:03:57.24Z";
                    WorkspaceName          = "SentinelWorkspace";
                    Ensure                 = 'Present'
                    Credential             = $Credential;
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    $indicator = @{
                        name = '12345-12345-12345-12345-12345'
                        properties = @{
                            displayName            = 'MyIndicator'
                            labels                 = @("Tag1", "Tag2")
                            pattern                = "[ipv6-addr:value = '2607:fa49:d340:f600:c8d5:6961:247f:a238']";
                            patternType            = "ipv6-addr";
                            threatIntelligenceTags = @();
                            validFrom              = "2024-10-22T19:03:57.24Z"; #Drift
                            validUntil             = "2024-10-23T19:03:57.24Z"; #Drift
                        }
                    }
                    if ($Uri -like '*/indicators/*')
                    {
                        return @{
                            StatusCode = 200
                            Content    = (ConvertTo-Json $indicator -Depth 10)
                        }
                    }
                    return @{
                        StatusCode = 200
                        Content    = (ConvertTo-Json @{ value = @($indicator) } -Depth 10)
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SentinelThreatIntelligenceIndicator' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SentinelThreatIntelligenceIndicator' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SentinelThreatIntelligenceIndicator' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-AzRestMethod -ParameterFilter { $Method -eq 'PUT' } -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    $indicator = @{
                        name = '12345-12345-12345-12345-12345'
                        properties = @{
                            displayName            = 'MyIndicator'
                            labels                 = @("Tag1", "Tag2")
                            pattern                = "[ipv6-addr:value = '2607:fa49:d340:f600:c8d5:6961:247f:a238']";
                            patternType            = "ipv6-addr";
                            threatIntelligenceTags = @();
                            validFrom              = "2024-10-22T19:03:57.24Z";
                            validUntil             = "2024-10-23T19:03:57.24Z";
                            source                 = 'Microsoft Sentinel'
                        }
                    }
                    if ($Uri -like '*/indicators/*')
                    {
                        return @{
                            StatusCode = 200
                            Content    = (ConvertTo-Json $indicator -Depth 10)
                        }
                    }
                    return @{
                        StatusCode = 200
                        Content    = (ConvertTo-Json @{ value = @($indicator) } -Depth 10)
                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SentinelThreatIntelligenceIndicator' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
