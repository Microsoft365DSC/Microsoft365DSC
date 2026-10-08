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
    -DscResource 'EXOMailboxSettings' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Set-Mailbox -MockWith {
            }

            Mock -CommandName Get-Mailbox -MockWith {
                return @(
                    @{
                        Name = 'John.Smith'
                    }
                )
            }

            Mock -CommandName Get-MailboxRegionalConfiguration -MockWith {
                return @{
                    TimeZone = 'Eastern Standard Time'
                    Language = @{
                        Name = 'en-US'
                    }
                }
            }

            Mock -CommandName Set-MailboxRegionalConfiguration -MockWith {
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
        }

        Context -Name 'Specified TimeZone is Invalid' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'Admin@contoso.com'
                    TimeZone    = 'Non-Existing'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }
            }

            It 'Should return the current TimeZone from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMailboxSettings' -Property $testParams).Get().ToHashtable()).TimeZone | Should -Be 'Eastern Standard Time'
            }

            It 'Should return False from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailboxSettings' -Property $testParams).Test() | Should -Be $False
            }
        }

        Context -Name 'Specified Parameters are all valid' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'Admin@contoso.com'
                    TimeZone    = 'Eastern Standard Time'
                    Locale      = 'en-US'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }
            }

            It 'Should return True from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailboxSettings' -Property $testParams).Test() | Should -Be $True
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

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOMailboxSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
