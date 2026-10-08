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

            Mock -CommandName Invoke-AzRestMethod -MockWith {
                return @{
                    content = ConvertTo-Json @{
                        value = @(
                        @{
                            id = "12345-12345-12345-12345-12345"
                            name = 'MyAction'
                            kind = "Email"
                            properties = @{
                                displayName = "MyAction"
                                scope = "/providers/Microsoft.Billing/billingAccounts/1e5b9e50-a1ea-581e-fb3a-778b93a06854:6487d5cf-0a7b-42e6-9549-23cavvvvvvv_2019-05-31"
                                status = "Enabled"
                                viewId = "/providers/Microsoft.Billing/billingAccounts/xxxxx:xxxxx_xxxxx/providers/Microsoft.CostManagement/views/ms:AccumulatedCosts";
                                schedule = @{
                                    daysOfWeek = @('Wednesday')
                                    startDate = '2024-11-06T13:00:00Z'
                                    endDate = '2025-11-06T05:00:00Z'
                                    frequency = 'Weekly'
                                    dayOfMonth = 0
                                    hourOfDay = 13
                                }
                                notification = @{
                                    subject = 'Cost Alert'
                                    message = 'This is my demo message!'
                                    to = @('john.smith@contoso.com')
                                }
                                notificationEmail = "alert@contoso.com";
                            }
                        }
                        )
                    } -Depth 10 -Compress
                }
            }

            Mock -CommandName Get-M365DSCAzureBillingAccount -MockWith {
                return @{
                    value = @{
                        name = "1e5b9e50-a1ea-581e-fb3a-778b93a06854:6487d5cf-0a7b-42e6-9549-23cavvvvvvv_2019-05-31"
                        properties = @{
                            displayName = "MyBillingAccount"
                        }
                    }
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
                    BillingAccount        = "1e5b9e50-a1ea-581e-fb3a-778b93a06854:6487d5cf-0a7b-42e6-9549-23cavvvvvvv_2019-05-31";
                    DisplayName           = "MyAction";
                    Notification          = ([MSFT_AzureBillingAccountScheduledActionNotification] @{
                        subject = 'Cost Alert'
                        message = 'This is my demo message!'
                        to = @('john.smith@contoso.com')
                    })
                    NotificationEmail     = "alert@contoso.com";
                    Schedule              = ([MSFT_AzureBillingAccountScheduledActionSchedule] @{
                        daysOfWeek = @('Wednesday')
                        startDate = '2024-11-06T13:00:00Z'
                        endDate = '2025-11-06T05:00:00Z'
                        frequency = 'Weekly'
                        dayOfMonth = 0
                        hourOfDay = 13
                    })
                    Status                = "Enabled";
                    View                  = "/providers/Microsoft.Billing/billingAccounts/xxxxx:xxxxx_xxxxx/providers/Microsoft.CostManagement/views/ms:AccumulatedCosts";
                    Ensure              = 'Present'
                    SubscriptionId      = "00000000-0000-0000-0000-000000000000"
                    Credential          = $Credential;
                }

                Mock -CommandName Invoke-AzRestMethod -MockWith {
                    return @{
                        Content = ConvertTo-Json @{
                            value = @()
                        }
                    }
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AzureBillingAccountScheduledAction' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureBillingAccountScheduledAction' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureBillingAccountScheduledAction' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-AzRestMethod -Exactly 2
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    BillingAccount        = "1e5b9e50-a1ea-581e-fb3a-778b93a06854:6487d5cf-0a7b-42e6-9549-23cavvvvvvv_2019-05-31";
                    DisplayName           = "MyAction";
                    Notification          = ([MSFT_AzureBillingAccountScheduledActionNotification] @{
                        subject = 'Cost Alert'
                        message = 'This is my demo message!'
                        to = @('john.smith@contoso.com')
                    })
                    NotificationEmail     = "alert@contoso.com";
                    Schedule              = ([MSFT_AzureBillingAccountScheduledActionSchedule] @{
                        daysOfWeek = @('Wednesday')
                        startDate = '2024-11-06T13:00:00Z'
                        endDate = '2025-11-06T05:00:00Z'
                        frequency = 'Weekly'
                        dayOfMonth = 0
                        hourOfDay = 13
                    })
                    Status                = "Enabled";
                    View                  = "/providers/Microsoft.Billing/billingAccounts/xxxxx:xxxxx_xxxxx/providers/Microsoft.CostManagement/views/ms:AccumulatedCosts";
                    Ensure              = 'Absent'
                    SubscriptionId      = "00000000-0000-0000-0000-000000000000"
                    Credential          = $Credential;
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AzureBillingAccountScheduledAction' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureBillingAccountScheduledAction' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureBillingAccountScheduledAction' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-AzRestMethod -Exactly 2
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    BillingAccount        = "1e5b9e50-a1ea-581e-fb3a-778b93a06854:6487d5cf-0a7b-42e6-9549-23cavvvvvvv_2019-05-31";
                    DisplayName           = "MyAction";
                    Notification          = ([MSFT_AzureBillingAccountScheduledActionNotification] @{
                        subject = 'Cost Alert'
                        message = 'This is my demo message!'
                        to = @('john.smith@contoso.com')
                    })
                    NotificationEmail     = "alert@contoso.com";
                    Schedule              = ([MSFT_AzureBillingAccountScheduledActionSchedule] @{
                        daysOfWeek = @('Wednesday')
                        startDate = '2024-11-06T13:00:00Z'
                        endDate = '2025-11-06T05:00:00Z'
                        frequency = 'Weekly'
                        dayOfMonth = 0
                        hourOfDay = 13
                    })
                    Status                = "Enabled";
                    View                  = "/providers/Microsoft.Billing/billingAccounts/xxxxx:xxxxx_xxxxx/providers/Microsoft.CostManagement/views/ms:AccumulatedCosts";
                    Ensure              = 'Present'
                    SubscriptionId      = "00000000-0000-0000-0000-000000000000"
                    Credential          = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureBillingAccountScheduledAction' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    BillingAccount        = "1e5b9e50-a1ea-581e-fb3a-778b93a06854:6487d5cf-0a7b-42e6-9549-23cavvvvvvv_2019-05-31";
                    DisplayName           = "MyAction";
                    Notification          = ([MSFT_AzureBillingAccountScheduledActionNotification] @{
                        subject = 'Cost Alert'
                        message = 'This is my demo message!'
                        to = @('john.smith@contoso.com')
                    })
                    NotificationEmail     = "alert@contoso.com";
                    Schedule              = ([MSFT_AzureBillingAccountScheduledActionSchedule] @{
                        daysOfWeek = @('Wednesday')
                        startDate = '2024-11-06T13:00:00Z'
                        endDate = '2025-11-06T05:00:00Z'
                        frequency = 'Weekly'
                        dayOfMonth = 0
                        hourOfDay = 13
                    })
                    Status                = "Disabled"; # Drift
                    View                  = "/providers/Microsoft.Billing/billingAccounts/xxxxx:xxxxx_xxxxx/providers/Microsoft.CostManagement/views/ms:AccumulatedCosts";
                    Ensure              = 'Present'
                    SubscriptionId      = "00000000-0000-0000-0000-000000000000"
                    Credential          = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AzureBillingAccountScheduledAction' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureBillingAccountScheduledAction' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureBillingAccountScheduledAction' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-AzRestMethod -Exactly 2
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
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AzureBillingAccountScheduledAction' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
