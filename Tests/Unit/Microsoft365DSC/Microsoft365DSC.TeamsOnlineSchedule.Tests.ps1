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
    -DscResource 'TeamsOnlineSchedule' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Add-M365DSCTelemetryEvent -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName New-CsOnlineSchedule -MockWith {
            }

            Mock -CommandName Set-CsOnlineSchedule -MockWith {
            }

            Mock -CommandName Remove-CsOnlineSchedule -MockWith {
            }

            Mock -CommandName New-CsOnlineTimeRange -MockWith {
                return [PSCustomObject] @{
                    Start = $Start
                    End   = $End
                }
            }

            Mock -CommandName New-CsOnlineDateTimeRange -MockWith {
                return [PSCustomObject] @{
                    Start = $Start
                    End   = $End
                }
            }

            function Get-BaseOnlineSchedule
            {
                $businessHours = @(
                    @{
                        Start = [System.TimeSpan] '09:00:00'
                        End   = [System.TimeSpan] '17:00:00'
                    }
                )

                return @{
                    Id                      = '5f4b3c2a-1d0e-4f9a-8b7c-6d5e4f3a2b1c'
                    Name                    = 'Contoso Business Hours'
                    Type                    = 'WeeklyRecurrence'
                    WeeklyRecurrentSchedule = @{
                        MondayHours       = $businessHours
                        TuesdayHours      = $businessHours
                        WednesdayHours    = $businessHours
                        ThursdayHours     = $businessHours
                        FridayHours       = $businessHours
                        SaturdayHours     = @()
                        SundayHours       = @()
                        ComplementEnabled = $false
                    }
                    FixedSchedule           = $null
                }
            }

            function New-BusinessHoursRange
            {
                param
                (
                    [Parameter()]
                    [System.String]
                    $End = '17:00'
                )

                return [MSFT_TeamsOnlineScheduleTimeRange[]] @(
                    ([MSFT_TeamsOnlineScheduleTimeRange] @{
                        Start = '09:00'
                        End   = $End
                    })
                )
            }

            Mock -CommandName Get-CsOnlineSchedule -MockWith {
                return @(Get-BaseOnlineSchedule)
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                return @{}
            }

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
                return "TeamsOnlineSchedule 'TestInstance' {}`r`n"
            }

            $Script:exportedInstance = $null
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        Context -Name 'The instance should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name           = 'Contoso Business Hours'
                    Type           = 'WeeklyRecurrence'
                    MondayHours    = New-BusinessHoursRange
                    TuesdayHours   = New-BusinessHoursRange
                    WednesdayHours = New-BusinessHoursRange
                    ThursdayHours  = New-BusinessHoursRange
                    FridayHours    = New-BusinessHoursRange
                    Complement     = $false
                    Ensure         = 'Present'
                    Credential     = $Credential
                }

                Mock -CommandName Get-CsOnlineSchedule -MockWith {
                    return @()
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-CsOnlineSchedule'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the weekly recurrent schedule from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-CsOnlineSchedule' -Exactly 1 -ParameterFilter {
                    $Name -eq 'Contoso Business Hours' -and
                    $WeeklyRecurrentSchedule -and
                    -not $FixedSchedule -and
                    -not $Complement -and
                    $MondayHours.Count -eq 1 -and
                    $MondayHours[0].Start -eq '09:00' -and
                    $FridayHours[0].End -eq '17:00' -and
                    $null -eq $SaturdayHours
                }
            }
        }

        Context -Name 'The fixed schedule should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name           = 'Contoso Holidays'
                    Type           = 'Fixed'
                    DateTimeRanges = [MSFT_TeamsOnlineScheduleDateTimeRange[]] @(
                        ([MSFT_TeamsOnlineScheduleDateTimeRange] @{
                            Start = '24/12/2026 0:00'
                            End   = '27/12/2026 0:00'
                        })
                    )
                    Ensure         = 'Present'
                    Credential     = $Credential
                }
            }

            It 'Should create the fixed schedule from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-CsOnlineSchedule' -Exactly 1 -ParameterFilter {
                    $Name -eq 'Contoso Holidays' -and
                    $FixedSchedule -and
                    -not $WeeklyRecurrentSchedule -and
                    $DateTimeRanges.Count -eq 1 -and
                    $DateTimeRanges[0].Start -eq '24/12/2026 0:00' -and
                    $DateTimeRanges[0].End -eq '27/12/2026 0:00'
                }
            }
        }

        Context -Name 'The instance exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Contoso Business Hours'
                    Ensure     = 'Absent'
                    Credential = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-CsOnlineSchedule'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-CsOnlineSchedule' -Exactly 1 -ParameterFilter {
                    $Id -eq '5f4b3c2a-1d0e-4f9a-8b7c-6d5e4f3a2b1c'
                }
            }
        }

        Context -Name 'The instance exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name           = 'Contoso Business Hours'
                    Type           = 'WeeklyRecurrence'
                    MondayHours    = New-BusinessHoursRange
                    TuesdayHours   = New-BusinessHoursRange
                    WednesdayHours = New-BusinessHoursRange
                    ThursdayHours  = New-BusinessHoursRange
                    FridayHours    = New-BusinessHoursRange
                    Complement     = $false
                    Ensure         = 'Present'
                    Credential     = $Credential
                }
            }

            It 'Should return the ranges formatted as HH:mm from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.Name | Should -Be 'Contoso Business Hours'
                $result.Type | Should -Be 'WeeklyRecurrence'
                $result.MondayHours | Should -HaveCount 1
                $result.MondayHours[0].Start | Should -Be '09:00'
                $result.MondayHours[0].End | Should -Be '17:00'
                $result.SaturdayHours | Should -BeNullOrEmpty
                $result.Complement | Should -Be $false
                Should -Invoke -CommandName 'Get-CsOnlineSchedule'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return true from the Test method when the desired times are not zero padded' {
                $unpaddedParams = $testParams.Clone()
                $unpaddedParams.MondayHours = [MSFT_TeamsOnlineScheduleTimeRange[]] @(
                    ([MSFT_TeamsOnlineScheduleTimeRange] @{
                        Start = '9:00'
                        End   = '17:00'
                    })
                )

                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $unpaddedParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and the end of day is returned as 1.00:00' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name        = 'Contoso Business Hours'
                    SundayHours = [MSFT_TeamsOnlineScheduleTimeRange[]] @(
                        ([MSFT_TeamsOnlineScheduleTimeRange] @{
                            Start = '00:00'
                            End   = '1.00:00'
                        })
                    )
                    Ensure      = 'Present'
                    Credential  = $Credential
                }

                Mock -CommandName Get-CsOnlineSchedule -MockWith {
                    $schedule = Get-BaseOnlineSchedule
                    $schedule.WeeklyRecurrentSchedule.SundayHours = @(
                        @{
                            Start = [System.TimeSpan] '00:00:00'
                            End   = [System.TimeSpan] '1.00:00:00'
                        }
                    )
                    return @($schedule)
                }
            }

            It 'Should return the end of the day as 1.00:00 from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Get().ToHashtable()
                $result.SundayHours[0].Start | Should -Be '00:00'
                $result.SundayHours[0].End | Should -Be '1.00:00'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and a day range is NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name           = 'Contoso Business Hours'
                    Type           = 'WeeklyRecurrence'
                    MondayHours    = New-BusinessHoursRange
                    TuesdayHours   = New-BusinessHoursRange
                    WednesdayHours = New-BusinessHoursRange
                    ThursdayHours  = New-BusinessHoursRange
                    FridayHours    = New-BusinessHoursRange -End '16:00'
                    Complement     = $false
                    Ensure         = 'Present'
                    Credential     = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-CsOnlineSchedule'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-CsOnlineSchedule' -Exactly 1 -ParameterFilter {
                    $Instance.Id -eq '5f4b3c2a-1d0e-4f9a-8b7c-6d5e4f3a2b1c' -and
                    $Instance.WeeklyRecurrentSchedule.FridayHours[0].End -eq '16:00' -and
                    $Instance.WeeklyRecurrentSchedule.MondayHours[0].End -eq '17:00' -and
                    $Instance.WeeklyRecurrentSchedule.ComplementEnabled -eq $false
                }
                Should -Invoke -CommandName 'New-CsOnlineSchedule' -Exactly 0
            }
        }

        Context -Name 'The fixed schedule exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name           = 'Contoso Holidays'
                    Type           = 'Fixed'
                    DateTimeRanges = [MSFT_TeamsOnlineScheduleDateTimeRange[]] @(
                        ([MSFT_TeamsOnlineScheduleDateTimeRange] @{
                            Start = '24/12/2026 0:00'
                            End   = '27/12/2026 0:00'
                        })
                    )
                    Ensure         = 'Present'
                    Credential     = $Credential
                }

                Mock -CommandName Get-CsOnlineSchedule -MockWith {
                    $schedule = Get-BaseOnlineSchedule
                    $schedule.Name = 'Contoso Holidays'
                    $schedule.Type = 'Fixed'
                    $schedule.WeeklyRecurrentSchedule = $null
                    $schedule.FixedSchedule = @{
                        DateTimeRanges = @(
                            @{
                                Start = [System.DateTime]::new(2026, 12, 24, 0, 0, 0)
                                End   = [System.DateTime]::new(2026, 12, 27, 0, 0, 0)
                            }
                        )
                    }
                    return @($schedule)
                }
            }

            It 'Should return the ranges formatted as d/M/yyyy H:mm from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Get().ToHashtable()
                $result.Type | Should -Be 'Fixed'
                $result.DateTimeRanges | Should -HaveCount 1
                $result.DateTimeRanges[0].Start | Should -Be '24/12/2026 0:00'
                $result.DateTimeRanges[0].End | Should -Be '27/12/2026 0:00'
                $result.MondayHours | Should -BeNullOrEmpty
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return true from the Test method when the desired dates use another supported format' {
                $paddedParams = $testParams.Clone()
                $paddedParams.DateTimeRanges = [MSFT_TeamsOnlineScheduleDateTimeRange[]] @(
                    ([MSFT_TeamsOnlineScheduleDateTimeRange] @{
                        Start = '24/12/2026 00:00'
                        End   = '27/12/2026'
                    })
                )

                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $paddedParams).Test() | Should -Be $true
            }

            It 'Should update the date time ranges from the Set method when they drift' {
                $driftParams = $testParams.Clone()
                $driftParams.DateTimeRanges = [MSFT_TeamsOnlineScheduleDateTimeRange[]] @(
                    ([MSFT_TeamsOnlineScheduleDateTimeRange] @{
                        Start = '24/12/2026 0:00'
                        End   = '28/12/2026 0:00'
                    })
                )

                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $driftParams).Test() | Should -Be $false
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $driftParams).Set()
                Should -Invoke -CommandName 'Set-CsOnlineSchedule' -Exactly 1 -ParameterFilter {
                    $Instance.FixedSchedule.DateTimeRanges[0].End -eq '28/12/2026 0:00'
                }
            }
        }

        Context -Name 'The instance exists with a different type' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Contoso Business Hours'
                    Type       = 'Fixed'
                    Ensure     = 'Present'
                    Credential = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should throw from the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineSchedule' -Property $testParams).Set() } | Should -Throw -ExpectedMessage '*cannot change from {WeeklyRecurrence} to {Fixed}*'
                Should -Invoke -CommandName 'Set-CsOnlineSchedule' -Exactly 0
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
            }

            It 'Should reverse engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsOnlineSchedule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                Should -Invoke -CommandName 'Get-CsOnlineSchedule'
                Should -Invoke -CommandName 'Get-M365DSCExportContentForResource' -Exactly 1 -ParameterFilter {
                    $Results.Name -eq 'Contoso Business Hours' -and
                    $Results.MondayHours -like '*MSFT_TeamsOnlineScheduleTimeRange*' -and
                    $NoEscape -contains 'MondayHours'
                }
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
