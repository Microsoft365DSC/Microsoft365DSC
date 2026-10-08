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
    -DscResource 'EXOCalendarProcessing' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Set-CalendarProcessing -MockWith {
                return $null
            }

            Mock -CommandName Get-CalendarProcessing -MockWith {
                return @{
                    AddAdditionalResponse                = $False;
                    AddNewRequestsTentatively            = $True;
                    AddOrganizerToSubject                = $True;
                    AllBookInPolicy                      = $True;
                    AllowConflicts                       = $False;
                    AllowRecurringMeetings               = $True;
                    AllRequestInPolicy                   = $False;
                    AllRequestOutOfPolicy                = $False;
                    AutomateProcessing                   = "AutoUpdate";
                    BookingType                          = "Standard";
                    BookingWindowInDays                  = 180;
                    BookInPolicy                         = @();
                    ConflictPercentageAllowed            = 0;
                    DeleteAttachments                    = $True;
                    DeleteComments                       = $True;
                    DeleteNonCalendarItems               = $True;
                    DeleteSubject                        = $True;
                    EnableAutoRelease                    = $False;
                    EnableResponseDetails                = $True;
                    EnforceCapacity                      = $False;
                    EnforceSchedulingHorizon             = $True;
                    ForwardRequestsToDelegates           = $True;
                    Identity                             = "John.Smith";
                    MaximumConflictInstances             = 0;
                    MaximumDurationInMinutes             = 1440;
                    MinimumDurationInMinutes             = 0;
                    OrganizerInfo                        = $True;
                    PostReservationMaxClaimTimeInMinutes = 10;
                    ProcessExternalMeetingMessages       = $False;
                    RemoveCanceledMeetings               = $False;
                    RemoveForwardedMeetingNotifications  = $False;
                    RemoveOldMeetingMessages             = $False;
                    RemovePrivateProperty                = $True;
                    RequestInPolicy                      = @('12345-12345-12345-12345-12345');
                    ResourceDelegates                    = @();
                    ScheduleOnlyDuringWorkHours          = $False;
                    TentativePendingApproval             = $True;
                }
            }

            Mock -CommandName Get-User -MockWith {
                return @{
                    Identity          = '12345-12345-12345-12345-12345'
                    UserPrincipalName = "Bob.Houle@contoso.com"
                }
            }

            Mock -CommandName Get-Recipient -MockWith {
                return @{
                    Identity           = '12345-12345-12345-12345-12345'
                    PrimarySmtpAddress = "Bob.Houle@contoso.com"
                }
            }

            Mock -CommandName Get-CalendarProcessing -MockWith {
                return @{
                    AddAdditionalResponse                = $False;
                    AddNewRequestsTentatively            = $True;
                    AddOrganizerToSubject                = $True;
                    AllBookInPolicy                      = $True;
                    AllowConflicts                       = $False;
                    AllowRecurringMeetings               = $True;
                    AllRequestInPolicy                   = $False;
                    AllRequestOutOfPolicy                = $False;
                    AutomateProcessing                   = "AutoUpdate";
                    BookingType                          = "Standard";
                    BookingWindowInDays                  = 180;
                    BookInPolicy                         = @();
                    ConflictPercentageAllowed            = 0;
                    DeleteAttachments                    = $True;
                    DeleteComments                       = $True;
                    DeleteNonCalendarItems               = $True;
                    DeleteSubject                        = $True;
                    EnableAutoRelease                    = $False;
                    EnableResponseDetails                = $True;
                    EnforceCapacity                      = $False;
                    EnforceSchedulingHorizon             = $True;
                    ForwardRequestsToDelegates           = $True;
                    Identity                             = "John.Smith";
                    MaximumConflictInstances             = 0;
                    MaximumDurationInMinutes             = 1440;
                    MinimumDurationInMinutes             = 0;
                    OrganizerInfo                        = $True;
                    PostReservationMaxClaimTimeInMinutes = 10;
                    ProcessExternalMeetingMessages       = $False;
                    RemoveCanceledMeetings               = $False;
                    RemoveForwardedMeetingNotifications  = $False;
                    RemoveOldMeetingMessages             = $False;
                    RemovePrivateProperty                = $True;
                    RequestInPolicy                      = @('12345-12345-12345-12345-12345');
                    ResourceDelegates                    = @();
                    ScheduleOnlyDuringWorkHours          = $False;
                    TentativePendingApproval             = $True;
                }
            }
        }

        # Test contexts
        Context -Name 'Settings are not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AddAdditionalResponse                = $False;
                    AddNewRequestsTentatively            = $True;
                    AddOrganizerToSubject                = $True;
                    AllBookInPolicy                      = $True;
                    AllowConflicts                       = $False;
                    AllowRecurringMeetings               = $True;
                    AllRequestInPolicy                   = $False;
                    AllRequestOutOfPolicy                = $True; # Drift
                    AutomateProcessing                   = "AutoUpdate";
                    BookingType                          = "Standard";
                    BookingWindowInDays                  = 180;
                    BookInPolicy                         = @();
                    ConflictPercentageAllowed            = 0;
                    Credential                           = $Credential;
                    DeleteAttachments                    = $True;
                    DeleteComments                       = $True;
                    DeleteNonCalendarItems               = $True;
                    DeleteSubject                        = $True;
                    EnableAutoRelease                    = $False;
                    EnableResponseDetails                = $True;
                    EnforceCapacity                      = $False;
                    EnforceSchedulingHorizon             = $True;
                    Ensure                               = "Present";
                    ForwardRequestsToDelegates           = $True;
                    Identity                             = "John.Smith";
                    MaximumConflictInstances             = 0;
                    MaximumDurationInMinutes             = 1440;
                    MinimumDurationInMinutes             = 0;
                    OrganizerInfo                        = $True;
                    PostReservationMaxClaimTimeInMinutes = 10;
                    ProcessExternalMeetingMessages       = $False;
                    RemoveCanceledMeetings               = $False;
                    RemoveForwardedMeetingNotifications  = $False;
                    RemoveOldMeetingMessages             = $False;
                    RemovePrivateProperty                = $True;
                    RequestInPolicy                      = @("Bob.Houle@contoso.com");
                    ResourceDelegates                    = @();
                    ScheduleOnlyDuringWorkHours          = $False;
                    TentativePendingApproval             = $True;
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOCalendarProcessing' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOCalendarProcessing' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CalendarProcessing -Exactly 1
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOCalendarProcessing' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Settings are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AddAdditionalResponse                = $False;
                    AddNewRequestsTentatively            = $True;
                    AddOrganizerToSubject                = $True;
                    AllBookInPolicy                      = $True;
                    AllowConflicts                       = $False;
                    AllowRecurringMeetings               = $True;
                    AllRequestInPolicy                   = $False;
                    AllRequestOutOfPolicy                = $False;
                    AutomateProcessing                   = "AutoUpdate";
                    BookingType                          = "Standard";
                    BookingWindowInDays                  = 180;
                    BookInPolicy                         = @();
                    ConflictPercentageAllowed            = 0;
                    Credential                           = $Credential;
                    DeleteAttachments                    = $True;
                    DeleteComments                       = $True;
                    DeleteNonCalendarItems               = $True;
                    DeleteSubject                        = $True;
                    EnableAutoRelease                    = $False;
                    EnableResponseDetails                = $True;
                    EnforceCapacity                      = $False;
                    EnforceSchedulingHorizon             = $True;
                    Ensure                               = "Present";
                    ForwardRequestsToDelegates           = $True;
                    Identity                             = "John.Smith";
                    MaximumConflictInstances             = 0;
                    MaximumDurationInMinutes             = 1440;
                    MinimumDurationInMinutes             = 0;
                    OrganizerInfo                        = $True;
                    PostReservationMaxClaimTimeInMinutes = 10;
                    ProcessExternalMeetingMessages       = $False;
                    RemoveCanceledMeetings               = $False;
                    RemoveForwardedMeetingNotifications  = $False;
                    RemoveOldMeetingMessages             = $False;
                    RemovePrivateProperty                = $True;
                    RequestInPolicy                      = @("Bob.Houle@contoso.com");
                    ResourceDelegates                    = @();
                    ScheduleOnlyDuringWorkHours          = $False;
                    TentativePendingApproval             = $True;
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOCalendarProcessing' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOCalendarProcessing' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name "User doesn't exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    AddAdditionalResponse                = $False;
                    AddNewRequestsTentatively            = $True;
                    AddOrganizerToSubject                = $True;
                    AllBookInPolicy                      = $True;
                    AllowConflicts                       = $False;
                    AllowRecurringMeetings               = $True;
                    AllRequestInPolicy                   = $False;
                    AllRequestOutOfPolicy                = $False;
                    AutomateProcessing                   = "AutoUpdate";
                    BookingType                          = "Standard";
                    BookingWindowInDays                  = 180;
                    BookInPolicy                         = @();
                    ConflictPercentageAllowed            = 0;
                    Credential                           = $Credential;
                    DeleteAttachments                    = $True;
                    DeleteComments                       = $True;
                    DeleteNonCalendarItems               = $True;
                    DeleteSubject                        = $True;
                    EnableAutoRelease                    = $False;
                    EnableResponseDetails                = $True;
                    EnforceCapacity                      = $False;
                    EnforceSchedulingHorizon             = $True;
                    Ensure                               = "Present";
                    ForwardRequestsToDelegates           = $True;
                    Identity                             = "John.Smith";
                    MaximumConflictInstances             = 0;
                    MaximumDurationInMinutes             = 1440;
                    MinimumDurationInMinutes             = 0;
                    OrganizerInfo                        = $True;
                    PostReservationMaxClaimTimeInMinutes = 10;
                    ProcessExternalMeetingMessages       = $False;
                    RemoveCanceledMeetings               = $False;
                    RemoveForwardedMeetingNotifications  = $False;
                    RemoveOldMeetingMessages             = $False;
                    RemovePrivateProperty                = $True;
                    RequestInPolicy                      = @("Bob.Houle@contoso.com");
                    ResourceDelegates                    = @();
                    ScheduleOnlyDuringWorkHours          = $False;
                    TentativePendingApproval             = $True;
                }

                Mock -CommandName Get-CalendarProcessing -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOCalendarProcessing' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOCalendarProcessing' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @(
                        @{
                            Identity          = 'Bob.Houle'
                            UserPrincipalName = 'Bob.Houle'
                        }
                    )
                }
            }


            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOCalendarProcessing' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
