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

            Mock -CommandName Get-MigrationBatch -MockWith {
            }

            Mock -CommandName Set-MigrationBatch -MockWith {
            }

            Mock -CommandName New-MigrationBatch -MockWith {
            }

            Mock -CommandName Remove-MigrationBatch -MockWith {
            }

            Mock -CommandName Stop-MigrationBatch -MockWith {
            }

            Mock -CommandName Get-MigrationUser -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Write-Verbose -MockWith {
            }

            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AddUsers             = $False;
                    CompleteAfter        = "07/30/2020 9:00:00 PM";
                    Credential           = $Credscredential;
                    Ensure               = "Present";
                    Identity             = "Arpita";
                    MigrationUsers       = @("peixintest1@bellred.org","akstest39@bellred.org");
                    MoveOptions          = @();
                    NotificationEmails   = @("eac_admin@bellred.org","abc@bellred.org");
                    SkipMerging          = @("abc");
                    SourceEndpoint       = "gmailCalendar";
                    StartAfter           = "07/30/2020 9:00:00 PM";
                    Status               = "Completing";
                    TargetDeliveryDomain = "O365InsightsView.mail.onmicrosoft.com";
                    Update               = $False;
                }

                Mock -CommandName Get-MigrationBatch -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMigration' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigration' -Property $testParams).Set()
                Should -Invoke -CommandName New-MigrationBatch -Exactly 1 -ParameterFilter { -not $PesterBoundParameters.ContainsKey('BadItemLimit') -and -not $PesterBoundParameters.ContainsKey('LargeItemLimit') }
            }
        }

        Context -Name "The instance exists but it SHOULD NOT but in progress state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AddUsers             = $False;
                    CompleteAfter        = "07/30/2020 9:00:00 PM";
                    Credential           = $Credscredential;
                    Ensure               = "Absent";
                    Identity             = "Arpita";
                    MigrationUsers       = @("peixintest1@bellred.org","akstest39@bellred.org");
                    MoveOptions          = @();
                    NotificationEmails   = @("eac_admin@bellred.org","abc@bellred.org");
                    SkipMerging          = @("abc");
                    SourceEndpoint       = "gmailCalendar";
                    StartAfter           = "07/30/2020 9:00:00 PM";
                    Status               = "Completing";
                    TargetDeliveryDomain = "O365InsightsView.mail.onmicrosoft.com";
                    Update               = $False;
                }

                Mock -CommandName Get-MigrationBatch -MockWith {
                    return @{
                        AddUsers             = $False;
                        BadItemLimit         = "Unlimited";
                        CompleteAfter        = [DateTime]::ParseExact("07/30/2020 9:00:00 PM", "MM/dd/yyyy h:mm:ss tt", [System.Globalization.CultureInfo]::new('en-us'))
                        Credential           = $Credscredential;
                        Ensure               = "Present";
                        Identity             = "Arpita";
                        LargeItemLimit       = "Unlimited";
                        MigrationUsers       = @("peixintest1@bellred.org","akstest39@bellred.org");
                        MoveOptions          = @();
                        NotificationEmails   = @("eac_admin@bellred.org","abc@bellred.org");
                        SkipMerging          = @("abc");
                        SourceEndpoint       = @{Identity = @{Id = "gmailCalendar"}};
                        StartAfter           = [DateTime]::ParseExact("07/30/2020 9:00:00 PM", "MM/dd/yyyy h:mm:ss tt", [System.Globalization.CultureInfo]::new('en-us'))
                        Status               = @{Value = "Completing"};
                        TargetDeliveryDomain = "O365InsightsView.mail.onmicrosoft.com";
                        Update               = $False;
                    }
                }
                Mock -CommandName Get-MigrationUser -MockWith {
                    return @(
                        @{
                            Identity = "peixintest1@bellred.org"
                        },
                        @{
                            Identity = "akstest39@bellred.org"
                        }
                    )
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMigration' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigration' -Property $testParams).Set()
                Should -Invoke -CommandName Stop-MigrationBatch -Exactly 1
                Should -Invoke -CommandName Remove-MigrationBatch -Exactly 1
            }
        }

        Context -Name "The instance exists but it SHOULD NOT but in completion state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AddUsers             = $False;
                    CompleteAfter        = "07/30/2020 9:00:00 PM";
                    Credential           = $Credscredential;
                    Ensure               = "Absent";
                    Identity             = "Arpita";
                    MigrationUsers       = @("peixintest1@bellred.org","akstest39@bellred.org");
                    MoveOptions          = @();
                    NotificationEmails   = @("eac_admin@bellred.org","abc@bellred.org");
                    SkipMerging          = @("abc");
                    SourceEndpoint       = "gmailCalendar";
                    StartAfter           = "07/30/2020 9:00:00 PM";
                    Status               = "Completed";
                    TargetDeliveryDomain = "O365InsightsView.mail.onmicrosoft.com";
                    Update               = $False;
                }

                Mock -CommandName Get-MigrationBatch -MockWith {
                    return @{
                        AddUsers             = $False;
                        BadItemLimit         = "Unlimited";
                        CompleteAfter        = [DateTime]::ParseExact("07/30/2020 9:00:00 PM", "MM/dd/yyyy h:mm:ss tt", [System.Globalization.CultureInfo]::new('en-us'))
                        Credential           = $Credscredential;
                        Ensure               = "Present";
                        Identity             = "Arpita";
                        LargeItemLimit       = "Unlimited";
                        MoveOptions          = @();
                        NotificationEmails   = @("eac_admin@bellred.org","abc@bellred.org");
                        SkipMerging          = @("abc");
                        SourceEndpoint       = @{Identity = @{Id = "gmailCalendar"}};
                        StartAfter           = [DateTime]::ParseExact("07/30/2020 9:00:00 PM", "MM/dd/yyyy h:mm:ss tt", [System.Globalization.CultureInfo]::new('en-us'))
                        Status               = @{Value = "Completed"};
                        TargetDeliveryDomain = "O365InsightsView.mail.onmicrosoft.com";
                        Update               = $False;
                    }
                }
                Mock -CommandName Get-MigrationUser -MockWith {
                    return @(
                        @{
                            Identity = "peixintest1@bellred.org"
                        },
                        @{
                            Identity = "akstest39@bellred.org"
                        }
                    )
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMigration' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigration' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MigrationBatch -Exactly 1
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AddUsers             = $False;
                    Credential           = $Credscredential;
                    Ensure               = "Present";
                    Identity             = "Arpita";
                    MigrationUsers       = @("peixintest1@bellred.org","akstest39@bellred.org");
                    MoveOptions          = @();
                    NotificationEmails   = @("eac_admin@bellred.org","abc@bellred.org");
                    SkipMerging          = @("abc");
                    SourceEndpoint       = "gmailCalendar";
                    Status               = "Completing";
                    TargetDeliveryDomain = "O365InsightsView.mail.onmicrosoft.com";
                    Update               = $False;
                }

                Mock -CommandName Get-MigrationBatch -MockWith {
                    return @{
                        AddUsers             = $False;
                        BadItemLimit         = "Unlimited";
                        Credential           = $Credscredential;
                        Ensure               = "Present";
                        Identity             = "Arpita";
                        LargeItemLimit       = "Unlimited";
                        MoveOptions          = @();
                        NotificationEmails   = @("eac_admin@bellred.org","abc@bellred.org");
                        SkipMerging          = @("abc");
                        SourceEndpoint       = @{Identity = @{Id = "gmailCalendar"}};
                        Status               = @{Value = "Completing"};
                        TargetDeliveryDomain = "O365InsightsView.mail.onmicrosoft.com";
                        Update               = $False;
                    }
                }

                Mock -CommandName Get-MigrationUser -MockWith {
                    return @(
                        @{
                            Identity = "peixintest1@bellred.org"
                        },
                        @{
                            Identity = "akstest39@bellred.org"
                        }
                    )
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigration' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AddUsers             = $False;
                    CompleteAfter        = "07/30/2020 9:00:00 PM"
                    Credential           = $Credscredential;
                    Ensure               = "Present";
                    Identity             = "Arpita";
                    MigrationUsers       = @("peixintest1@bellred.org","akstest39@bellred.org");
                    MoveOptions          = @();
                    NotificationEmails   = @("eac_admin@bellred.org","abc@bellred.org");
                    SkipMerging          = @("abc");
                    SourceEndpoint       = "gmailCalendar";
                    StartAfter           = "07/30/2020 9:00:00 PM"
                    Status               = @{Value = "Completing"};
                    TargetDeliveryDomain = "O365InsightsView.mail.onmicrosoft.com";
                    Update               = $False;
                }

                Mock -CommandName Get-MigrationBatch -MockWith {
                    return @{
                        AddUsers             = $False;
                        BadItemLimit         = "Unlimited";
                        CompleteAfter        = [DateTime]::ParseExact("07/30/2020 9:00:00 PM", "MM/dd/yyyy h:mm:ss tt", [System.Globalization.CultureInfo]::new('en-us'));
                        Credential           = $Credscredential;
                        Ensure               = "Present";
                        Identity             = "Arpita";
                        LargeItemLimit       = "Unlimited";
                        MigrationUsers       = @("peixintest1@bellred.org","akstest39@bellred.org");
                        MoveOptions          = @();
                        NotificationEmails   = @("eac_admin@bellred.org","abc@bellred.org");
                        SkipMerging          = @();
                        SourceEndpoint       = "gmailCalendar";
                        StartAfter           = [DateTime]::ParseExact("07/30/2020 9:00:00 PM", "MM/dd/yyyy h:mm:ss tt", [System.Globalization.CultureInfo]::new('en-us'));
                        Status               = @{Value = "Completing"};
                        TargetDeliveryDomain = "O365InsightsView.mail.onmicrosoft.com";
                        Update               = $False;
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMigration' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMigration' -Property $testParams).Set()
                Should -Invoke -CommandName Set-MigrationBatch -Exactly 1 -ParameterFilter { -not $PesterBoundParameters.ContainsKey('BadItemLimit') -and -not $PesterBoundParameters.ContainsKey('LargeItemLimit') }
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }

                Mock -CommandName Get-MigrationBatch -MockWith {
                    return @{
                        AddUsers             = $False;
                        BadItemLimit         = "Unlimited";
                        CompleteAfter        = [DateTime]::ParseExact("07/30/2020 9:00:00 PM", "MM/dd/yyyy h:mm:ss tt", [System.Globalization.CultureInfo]::new('en-us'));
                        Credential           = $Credscredential;
                        Ensure               = "Present";
                        Identity             = "Arpita";
                        LargeItemLimit       = "Unlimited";
                        MigrationUsers       = @("peixintest1@bellred.org","akstest39@bellred.org");
                        MoveOptions          = @();
                        NotificationEmails   = @("eac_admin@bellred.org","abc@bellred.org");
                        SkipMerging          = @();
                        SourceEndpoint       = "gmailCalendar";
                        StartAfter           = [DateTime]::ParseExact("07/30/2020 9:00:00 PM", "MM/dd/yyyy h:mm:ss tt", [System.Globalization.CultureInfo]::new('en-us'));
                        Status               = @{Value = "Completing"};
                        TargetDeliveryDomain = "O365InsightsView.mail.onmicrosoft.com";
                        Update               = $False;
                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOMigration' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
