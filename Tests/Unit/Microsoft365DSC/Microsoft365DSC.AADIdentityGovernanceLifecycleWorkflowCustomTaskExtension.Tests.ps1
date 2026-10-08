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

            Mock -CommandName Remove-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -MockWith {
            }
            Mock -CommandName New-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -MockWith {
            }
            Mock -CommandName Update-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -MockWith {
            }
            Mock -CommandName Get-MgApplication -MockWith {
                return @{
                    id = '12345-12345-12345-12345-12345'
                    DisplayName = 'M365DSC'
                }
            }

            Mock -CommandName Get-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -MockWith {
                return @{
                    id = '12345-12345-12345-12345-12345'
                    authenticationConfiguration = @{
                        "@odata.type" = "#microsoft.graph.azureAdPopTokenAuthentication"
                    }
                    CallbackConfiguration = @{
                        TimeoutDuration = @{
                            Minutes = '34'
                        }
                        "@odata.type" = "#microsoft.graph.identityGovernance.customTaskExtensionCallbackConfiguration"
                        authorizedApps = @(
                            @{
                                id = '12345-12345-12345-12345-12345'
                            }
                        )
                    }
                    ClientConfiguration   = @{
                        MaximumRetries = 1
                        TimeoutInMilliseconds = 1000
                    }
                    Description           = "My Description";
                    DisplayName           = "My Custom Extension";
                    EndpointConfiguration = @{
                        "@odata.type"         = "#microsoft.graph.logicAppTriggerEndpointConfiguration"
                        subscriptionId =       '63e62ab2-fd92-46ce-a393-2cb338039cc7'
                        logicAppWorkflowName = 'MyTestApp'
                        resourceGroupName =    'TestRG'
                        url = 'https://prod-35.eastus.logic.azure.com:443/workflows/xxxxxxxxxxx/triggers/manual/paths/invoke?api-version=2016-10-01'
                    }
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    CallbackConfiguration = ([MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionCallbackConfiguration] @{
                        TimeoutDuration = 'PT34M'
                        AuthorizedApps = @('M365DSC')
                    })
                    ClientConfiguration   = ([MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionClientConfiguration] @{
                        MaximumRetries = 1
                        TimeoutInMilliseconds = 1000
                    })
                    Description           = "My Description";
                    DisplayName           = "My Custom Extension";
                    EndpointConfiguration = ([MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionEndpointConfiguration] @{
                        SubscriptionId =       '63e62ab2-fd92-46ce-a393-2cb338039cc7'
                        logicAppWorkflowName = 'MyTestApp'
                        resourceGroupName =    'TestRG'
                        url = 'https://prod-35.eastus.logic.azure.com:443/workflows/xxxxxxxxxxx/triggers/manual/paths/invoke?api-version=2016-10-01'
                    })
                    Ensure                = "Present";
                    Credential          = $Credential;
                }

                Mock -CommandName Get-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -Exactly 1
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    CallbackConfiguration = ([MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionCallbackConfiguration] @{
                        TimeoutDuration = 'PT34M'
                        AuthorizedApps = @('M365DSC')
                    })
                    ClientConfiguration   = ([MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionClientConfiguration] @{
                        MaximumRetries = 1
                        TimeoutInMilliseconds = 1000
                    })
                    Description           = "My Description";
                    DisplayName           = "My Custom Extension";
                    EndpointConfiguration = ([MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionEndpointConfiguration] @{
                        SubscriptionId =       '63e62ab2-fd92-46ce-a393-2cb338039cc7'
                        logicAppWorkflowName = 'MyTestApp'
                        resourceGroupName =    'TestRG'
                        url = 'https://prod-35.eastus.logic.azure.com:443/workflows/xxxxxxxxxxx/triggers/manual/paths/invoke?api-version=2016-10-01'
                    })
                    Ensure                = "Absent";
                    Credential          = $Credential;
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -Exactly 1
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    CallbackConfiguration = ([MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionCallbackConfiguration] @{
                        TimeoutDuration = 'PT34M'
                        AuthorizedApps = @('M365DSC')
                    })
                    ClientConfiguration   = ([MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionClientConfiguration] @{
                        MaximumRetries = 1
                        TimeoutInMilliseconds = 1000
                    })
                    Description           = "My Description";
                    DisplayName           = "My Custom Extension";
                    EndpointConfiguration = ([MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionEndpointConfiguration] @{
                        SubscriptionId =       '63e62ab2-fd92-46ce-a393-2cb338039cc7'
                        logicAppWorkflowName = 'MyTestApp'
                        resourceGroupName =    'TestRG'
                        url = 'https://prod-35.eastus.logic.azure.com:443/workflows/xxxxxxxxxxx/triggers/manual/paths/invoke?api-version=2016-10-01'
                    })
                    Ensure                = "Present";
                    Credential          = $Credential;
                }

                Mock -CommandName Get-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -MockWith {
                    return @{
                        id = '12345-12345-12345-12345-12345'
                        authenticationConfiguration = @{
                            "@odata.type" = "#microsoft.graph.azureAdPopTokenAuthentication"
                        }
                        CallbackConfiguration = @{
                            TimeoutDuration = @{
                                Minutes = '34'
                            }
                            "@odata.type" = "#microsoft.graph.identityGovernance.customTaskExtensionCallbackConfiguration"
                            authorizedApps = @(
                                @{
                                    id = '12345-12345-12345-12345-12345'
                                }
                            )
                        }
                        ClientConfiguration   = @{
                            MaximumRetries = 1
                            TimeoutInMilliseconds = 1000
                        }
                        Description           = "My Description";
                        DisplayName           = "My Custom Extension";
                        EndpointConfiguration = @{
                            "@odata.type"         = "#microsoft.graph.logicAppTriggerEndpointConfiguration"
                            subscriptionId =       '63e62ab2-fd92-46ce-a393-2cb338039cc7'
                            logicAppWorkflowName = 'MyTestApp'
                            resourceGroupName =    'TestRG'
                                url = 'https://prod-35.eastus.logic.azure.com:443/workflows/xxxxxxxxxxx/triggers/manual/paths/invoke?api-version=2016-10-01'
                        }
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    CallbackConfiguration = ([MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionCallbackConfiguration] @{
                        TimeoutDuration = 'PT34M'
                        AuthorizedApps = @('M365DSC')
                    })
                    ClientConfiguration   = ([MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionClientConfiguration] @{
                        MaximumRetries = 2 # Drift
                        TimeoutInMilliseconds = 1000
                    })
                    Description           = "My Description";
                    DisplayName           = "My Custom Extension";
                    EndpointConfiguration = ([MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionEndpointConfiguration] @{
                        SubscriptionId =       '63e62ab2-fd92-46ce-a393-2cb338039cc7'
                        logicAppWorkflowName = 'MyTestApp'
                        resourceGroupName =    'TestRG'
                        url = 'https://prod-35.eastus.logic.azure.com:443/workflows/xxxxxxxxxxx/triggers/manual/paths/invoke?api-version=2016-10-01'
                    })
                    Ensure                = "Present";
                    Credential          = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
