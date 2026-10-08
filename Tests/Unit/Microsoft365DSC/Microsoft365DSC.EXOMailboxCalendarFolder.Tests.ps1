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
    -DscResource 'EXOMailboxCalendarFolder' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                switch ($Collection)
                {
                    'exoMailboxes'
                    {
                        return @(Get-Mailbox -ResultSize 'Unlimited')
                    }
                    'exoUsers'
                    {
                        return @(Get-User -ResultSize 'Unlimited')
                    }
                }
            }
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Set-MailboxCalendarFolder -MockWith {
                return $null
            }

            Mock -CommandName Get-Mailbox -MockWith {
                return @{
                    Id                = '12345-12345-12345-12345-12345'
                    UserPrincipalName = "Bob.Houle@contoso.com"
                }
            }
            Mock -CommandName Get-User -MockWith {
                return @{
                    UserPrincipalName = 'john.smith'
                }
            }

            Mock -CommandName Get-MailboxCalendarFolder -MockWith {
                return @{
                    DetailLevel          = "AvailabilityOnly";
                    Identity             = "john.smith:\Calendar";
                    PublishDateRangeFrom = "ThreeMonths";
                    PublishDateRangeTo   = "ThreeMonths"
                    PublishEnabled       = $False;
                    SearchableUrlEnabled = $False;
                }
            }
        }

        # Test contexts
        Context -Name 'Settings are not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DetailLevel          = "AvailabilityOnly";
                    Ensure               = "Present";
                    Identity             = "john.smith:\Calendar";
                    PublishDateRangeFrom = "ThreeMonths";
                    PublishDateRangeTo   = "SixMonths"; # Drift
                    PublishEnabled       = $False;
                    SearchableUrlEnabled = $False;
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailboxCalendarFolder' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailboxCalendarFolder' -Property $testParams).Set()
                Should -Invoke -CommandName Set-MailboxCalendarFolder -Exactly 1
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMailboxCalendarFolder' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Settings are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DetailLevel          = "AvailabilityOnly";
                    Ensure               = "Present";
                    Identity             = "john.smith:\Calendar";
                    PublishDateRangeFrom = "ThreeMonths";
                    PublishDateRangeTo   = "ThreeMonths";
                    PublishEnabled       = $False;
                    SearchableUrlEnabled = $False;
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailboxCalendarFolder' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMailboxCalendarFolder' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name "User doesn't exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    DetailLevel          = "AvailabilityOnly";
                    Ensure               = "Present";
                    Identity             = "john.smith:\Calendar";
                    PublishDateRangeFrom = "ThreeMonths";
                    PublishDateRangeTo   = "ThreeMonths";
                    PublishEnabled       = $False;
                    SearchableUrlEnabled = $False;
                }

                Mock -CommandName Get-MailboxCalendarFolder -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailboxCalendarFolder' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMailboxCalendarFolder' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MailboxFolderStatistics -MockWith {
                    return @{
                        FolderType  = "Calendar";
                        Name        = "Calendar";
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOMailboxCalendarFolder' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
