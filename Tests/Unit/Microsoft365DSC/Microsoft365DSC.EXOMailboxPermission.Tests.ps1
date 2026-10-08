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
    -DscResource 'EXOMailboxPermission' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Get-Mailbox -MockWith {
                return @{
                    UserPrincipalName = "john.smith@contoso.com";
                }
            }

            Mock -CommandName Add-MailboxPermission -MockWith {
            }

            Mock -CommandName Remove-MailboxPermission -MockWith {
            }

            Mock -CommandName Get-MailboxPermission -MockWith {
                return @{
                    AccessRights         = @("FullAccess","ReadPermission");
                    Deny                 = $False;
                    Identity             = "john.smith";
                    InheritanceType      = "None";
                    User                 = "NT AUTHORITY\SELF";
                }
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

            Mock -CommandName Get-User -MockWith {
                return @{
                    Identity          = 'john.smith'
                    UserPrincipalName = 'john.smith'
                }
            }
            $Script:exportedInstance =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Permission doesnt exist and it should' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure               = 'Present'
                    Credential           = $Credential
                    AccessRights         = @("FullAccess","ReadPermission");
                    Deny                 = $False;
                    Identity             = "john.smith";
                    InheritanceType      = "None";
                    User                 = "NT AUTHORITY\SELF";
                }

                Mock -CommandName Get-MailboxPermission -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailboxPermission' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return absent from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMailboxPermission' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should add the permission in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailboxPermission' -Property $testParams).Set()
                Should -Invoke -CommandName Add-MailboxPermission -Exactly 1
            }
        }
        Context -Name 'Permission exists and is in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure               = 'Present'
                    Credential           = $Credential
                    AccessRights         = @("FullAccess","ReadPermission");
                    Deny                 = $false;
                    Identity             = "john.smith";
                    InheritanceType      = "None";
                    User                 = "NT AUTHORITY\SELF";
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailboxPermission' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMailboxPermission' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Permission exists and is not in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure               = 'Present'
                    Credential           = $Credential
                    AccessRights         = @("FullAccess","ReadPermission");
                    Deny                 = $true; # Drift
                    Identity             = "john.smith";
                    InheritanceType      = "None";
                    User                 = "NT AUTHORITY\SELF";
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailboxPermission' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMailboxPermission' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Permission exist and it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure               = 'Absent'
                    Credential           = $Credential
                    AccessRights         = @("FullAccess","ReadPermission");
                    Deny                 = $False;
                    Identity             = "john.smith";
                    InheritanceType      = "None";
                    User                 = "NT AUTHORITY\SELF";
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailboxPermission' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return absent from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMailboxPermission' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should remove the permission in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailboxPermission' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MailboxPermission -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOMailboxPermission' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
