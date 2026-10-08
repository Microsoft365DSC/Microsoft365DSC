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
                    AlertDetailsOverride  = ([MSFT_SentinelAlertRuleAlertDetailsOverride] @{
                        alertDescriptionFormat = 'This is an example of the alert content'
                        alertDisplayNameFormat = 'Alert from {{{TimeGenerated}} '
                    })
                    CustomDetails         = @(
                        ([MSFT_SentinelAlertRuleCustomDetails] @{
                            DetailKey = 'Color'
                            DetailValue = 'TenantId'
                        })
                    )
                    Description           = "Test";
                    DisplayName           = "TestDSC1";
                    Enabled               = $True;
                    Ensure                = "Present";
                    EventGroupingSettings = ([MSFT_SentinelAlertRuleEventGroupingSettings] @{
                        aggregationKind = 'AlertPerResult'
                    })
                    IncidentConfiguration = ([MSFT_SentinelAlertRuleIncidentConfiguration] @{
                        groupingConfiguration = ([MSFT_SentinelAlertRuleIncidentConfigurationGroupingConfiguration] @{
                            lookbackDuration = 'PT5H'
                            matchingMethod = 'Selected'
                            groupByCustomDetails = @('Color')
                            groupByEntities = @('CloudApplication')
                            reopenClosedIncident = $True
                            enabled = $True
                        })
                        createIncident = $True
                    })
                    Kind                  = "NRT";
                    Query                 = "ThreatIntelIndicators";
                    ResourceGroupName     = "TBDSentinel";
                    Severity              = "Medium";
                    SubscriptionId        = "42136a41-5030-4140-aba0-7e6211115d3a";
                    SuppressionDuration   = "PT5H";
                    Tactics               = @();
                    Techniques            = @();
                    WorkspaceName         = "SentinelWorkspace";
                    Credential            = $Credential;
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        StatusCode = 200
                        Content    = '{}'
                    }
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SentinelAlertRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SentinelAlertRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SentinelAlertRule' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-AzRestMethod -ParameterFilter { $Method -eq 'PUT' } -Exactly 1
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AlertDetailsOverride  = ([MSFT_SentinelAlertRuleAlertDetailsOverride] @{
                        alertDescriptionFormat = 'This is an example of the alert content'
                        alertDisplayNameFormat = 'Alert from {{{TimeGenerated}} '
                    })
                    CustomDetails         = @(
                        ([MSFT_SentinelAlertRuleCustomDetails] @{
                            DetailKey = 'Color'
                            DetailValue = 'TenantId'
                        })
                    )
                    Description           = "Test";
                    DisplayName           = "TestDSC1";
                    Enabled               = $True;
                    Ensure                = "Absent";
                    EventGroupingSettings = ([MSFT_SentinelAlertRuleEventGroupingSettings] @{
                        aggregationKind = 'AlertPerResult'
                    })
                    IncidentConfiguration = ([MSFT_SentinelAlertRuleIncidentConfiguration] @{
                        groupingConfiguration = ([MSFT_SentinelAlertRuleIncidentConfigurationGroupingConfiguration] @{
                            lookbackDuration = 'PT5H'
                            matchingMethod = 'Selected'
                            groupByCustomDetails = @('Color')
                            groupByEntities = @('CloudApplication')
                            reopenClosedIncident = $True
                            enabled = $True
                        })
                        createIncident = $True
                    })
                    Kind                  = "NRT";
                    Query                 = "ThreatIntelIndicators";
                    ResourceGroupName     = "TBDSentinel";
                    Severity              = "Medium";
                    SubscriptionId        = "42136a41-5030-4140-aba0-7e6211115d3a";
                    SuppressionDuration   = "PT5H";
                    Tactics               = @();
                    Techniques            = @();
                    WorkspaceName         = "SentinelWorkspace";
                    Credential            = $Credential;
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    $rule = @{
                        Kind = 'NRT'
                        name = '12345-12345-12345-12345-12345'
                        properties = @{
                            Query                 = "ThreatIntelIndicators";
                            Severity              = "Medium";
                            SuppressionDuration   = "PT5H";
                            Tactics               = @();
                            Techniques            = @();
                            Description           = "Test";
                            DisplayName           = "TestDSC1";
                            Enabled               = $True;
                            AlertDetailsOverride  = @{
                                alertDescriptionFormat = 'This is an example of the alert content'
                                alertDisplayNameFormat = 'Alert from {{{TimeGenerated}} '
                            }
                            CustomDetails         = @(
                                @{
                                    Color = 'TenantId'
                                }
                            )
                            EventGroupingSettings = @{
                                aggregationKind = 'AlertPerResult'
                            }
                            IncidentConfiguration = @{
                                groupingConfiguration = @{
                                    lookbackDuration = 'PT5H'
                                    matchingMethod = 'Selected'
                                    groupByCustomDetails = @('Color')
                                    groupByEntities = @('CloudApplication')
                                    reopenClosedIncident = $True
                                    enabled = $True
                                }
                                createIncident = $True
                            }
                        }
                    }
                    if ($Uri -like '*/alertrules/*')
                    {
                        return @{
                            StatusCode = 200
                            Content    = (ConvertTo-Json $rule -Depth 10)
                        }
                    }
                    return @{
                        StatusCode = 200
                        Content    = (ConvertTo-Json @{ value = @($rule) } -Depth 10)
                    }
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SentinelAlertRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SentinelAlertRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SentinelAlertRule' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-AzRestMethod -ParameterFilter { $Method -eq 'DELETE' } -Exactly 1
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AlertDetailsOverride  = ([MSFT_SentinelAlertRuleAlertDetailsOverride] @{
                        alertDescriptionFormat = 'This is an example of the alert content'
                        alertDisplayNameFormat = 'Alert from {{{TimeGenerated}} '
                    })
                    CustomDetails         = @(
                        ([MSFT_SentinelAlertRuleCustomDetails] @{
                            DetailKey = 'Color'
                            DetailValue = 'TenantId'
                        })
                    )
                    Description           = "Test";
                    DisplayName           = "TestDSC1";
                    Enabled               = $True;
                    Ensure                = "Present";
                    EventGroupingSettings = ([MSFT_SentinelAlertRuleEventGroupingSettings] @{
                        aggregationKind = 'AlertPerResult'
                    })
                    IncidentConfiguration = ([MSFT_SentinelAlertRuleIncidentConfiguration] @{
                        groupingConfiguration = ([MSFT_SentinelAlertRuleIncidentConfigurationGroupingConfiguration] @{
                            lookbackDuration = 'PT5H'
                            matchingMethod = 'Selected'
                            groupByCustomDetails = @('Color')
                            groupByEntities = @('CloudApplication')
                            reopenClosedIncident = $True
                            enabled = $True
                        })
                        createIncident = $True
                    })
                    Kind                  = "NRT";
                    Query                 = "ThreatIntelIndicators";
                    ResourceGroupName     = "TBDSentinel";
                    Severity              = "Medium";
                    SubscriptionId        = "42136a41-5030-4140-aba0-7e6211115d3a";
                    SuppressionDuration   = "PT5H";
                    Tactics               = @();
                    Techniques            = @();
                    WorkspaceName         = "SentinelWorkspace";
                    Credential            = $Credential;
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    $rule = @{
                        Kind = 'NRT'
                        name = '12345-12345-12345-12345-12345'
                        properties = @{
                            Query                 = "ThreatIntelIndicators";
                            Severity              = "Medium";
                            SuppressionDuration   = "PT5H";
                            Tactics               = @();
                            Techniques            = @();
                            Description           = "Test";
                            DisplayName           = "TestDSC1";
                            Enabled               = $True;
                            AlertDetailsOverride  = @{
                                alertDescriptionFormat = 'This is an example of the alert content'
                                alertDisplayNameFormat = 'Alert from {{{TimeGenerated}} '
                            }
                            CustomDetails         =
                                [PSCustomObject]@{
                                    Color = 'TenantId'
                                }
                            EventGroupingSettings = @{
                                aggregationKind = 'AlertPerResult'
                            }
                            IncidentConfiguration = @{
                                groupingConfiguration = @{
                                    lookbackDuration = 'PT5H'
                                    matchingMethod = 'Selected'
                                    groupByCustomDetails = @('Color')
                                    groupByEntities = @('CloudApplication')
                                    reopenClosedIncident = $True
                                    enabled = $True
                                }
                                createIncident = $True
                            }
                        }
                    }
                    if ($Uri -like '*/alertrules/*')
                    {
                        return @{
                            StatusCode = 200
                            Content    = (ConvertTo-Json $rule -Depth 10)
                        }
                    }
                    return @{
                        StatusCode = 200
                        Content    = (ConvertTo-Json @{ value = @($rule) } -Depth 10)
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SentinelAlertRule' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AlertDetailsOverride  = ([MSFT_SentinelAlertRuleAlertDetailsOverride] @{
                        alertDescriptionFormat = 'This is an example of the alert content'
                        alertDisplayNameFormat = 'Alert from {{{TimeGenerated}} '
                    })
                    CustomDetails         = @(
                        ([MSFT_SentinelAlertRuleCustomDetails] @{
                            DetailKey = 'Color'
                            DetailValue = 'TenantId'
                        })
                    )
                    Description           = "Test";
                    DisplayName           = "TestDSC1";
                    Enabled               = $False; #Drift
                    Ensure                = "Present";
                    EventGroupingSettings = ([MSFT_SentinelAlertRuleEventGroupingSettings] @{
                        aggregationKind = 'AlertPerResult'
                    })
                    IncidentConfiguration = ([MSFT_SentinelAlertRuleIncidentConfiguration] @{
                        groupingConfiguration = ([MSFT_SentinelAlertRuleIncidentConfigurationGroupingConfiguration] @{
                            lookbackDuration = 'PT5H'
                            matchingMethod = 'Selected'
                            groupByCustomDetails = @('Color')
                            groupByEntities = @('CloudApplication')
                            reopenClosedIncident = $True
                            enabled = $True
                        })
                        createIncident = $True
                    })
                    Kind                  = "NRT";
                    Query                 = "ThreatIntelIndicators";
                    ResourceGroupName     = "TBDSentinel";
                    Severity              = "Medium";
                    SubscriptionId        = "42136a41-5030-4140-aba0-7e6211115d3a";
                    SuppressionDuration   = "PT5H";
                    Tactics               = @();
                    Techniques            = @();
                    WorkspaceName         = "SentinelWorkspace";
                    Credential            = $Credential;
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    $rule = @{
                        Kind = 'NRT'
                        name = '12345-12345-12345-12345-12345'
                        properties = @{
                            Query                 = "ThreatIntelIndicators";
                            Severity              = "Medium";
                            SuppressionDuration   = "PT5H";
                            Tactics               = @();
                            Techniques            = @();
                            Description           = "Test";
                            DisplayName           = "TestDSC1";
                            Enabled               = $True;
                            AlertDetailsOverride  = @{
                                alertDescriptionFormat = 'This is an example of the alert content'
                                alertDisplayNameFormat = 'Alert from {{{TimeGenerated}} '
                            }
                            CustomDetails         = @(
                                @{
                                    Color = 'TenantId'
                                }
                            )
                            EventGroupingSettings = @{
                                aggregationKind = 'AlertPerResult'
                            }
                            IncidentConfiguration = @{
                                groupingConfiguration = @{
                                    lookbackDuration = 'PT5H'
                                    matchingMethod = 'Selected'
                                    groupByCustomDetails = @('Color')
                                    groupByEntities = @('CloudApplication')
                                    reopenClosedIncident = $True
                                    enabled = $True
                                }
                                createIncident = $True
                            }
                        }
                    }
                    if ($Uri -like '*/alertrules/*')
                    {
                        return @{
                            StatusCode = 200
                            Content    = (ConvertTo-Json $rule -Depth 10)
                        }
                    }
                    return @{
                        StatusCode = 200
                        Content    = (ConvertTo-Json @{ value = @($rule) } -Depth 10)
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SentinelAlertRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SentinelAlertRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SentinelAlertRule' -Property $testParams).Set()
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
                    $rule = @{
                        Kind = 'NRT'
                        name = '12345-12345-12345-12345-12345'
                        properties = @{
                            Query                 = "ThreatIntelIndicators";
                            Severity              = "Medium";
                            SuppressionDuration   = "PT5H";
                            Tactics               = @();
                            Techniques            = @();
                            Description           = "Test";
                            DisplayName           = "TestDSC1";
                            Enabled               = $True;
                            AlertDetailsOverride  = @{
                                alertDescriptionFormat = 'This is an example of the alert content'
                                alertDisplayNameFormat = 'Alert from {{{TimeGenerated}} '
                            }
                            CustomDetails         = @(
                                @{
                                    Color = 'TenantId'
                                }
                            )
                            EventGroupingSettings = @{
                                aggregationKind = 'AlertPerResult'
                            }
                            IncidentConfiguration = @{
                                groupingConfiguration = @{
                                    lookbackDuration = 'PT5H'
                                    matchingMethod = 'Selected'
                                    groupByCustomDetails = @('Color')
                                    groupByEntities = @('CloudApplication')
                                    reopenClosedIncident = $True
                                    enabled = $True
                                }
                                createIncident = $True
                            }
                        }
                    }
                    if ($Uri -like '*/alertrules/*')
                    {
                        return @{
                            StatusCode = 200
                            Content    = (ConvertTo-Json $rule -Depth 10)
                        }
                    }
                    return @{
                        StatusCode = 200
                        Content    = (ConvertTo-Json @{ value = @($rule) } -Depth 10)
                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SentinelAlertRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
