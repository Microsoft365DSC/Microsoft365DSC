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
    -DscResource 'PlannerTask' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Connect-Graph -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgUser -MockWith {
                return @{
                    UserPrincipalName = 'john.smith@contoso.com'
                    Id                = '12345-12345-12345-12345-12345'
                }
            }

            Mock -CommandName Get-MgPlannerTask -MockWith {
                return @{
                    PlanId          = '1234567890'
                    Title           = 'Contoso Task'
                    Priority        = 5
                    Id              = '12345'
                    PercentComplete = 75
                    StartDateTime   = '2020-06-09'
                    DueDateTime     = '2020-06-10'
                    BucketId        = 'Bucket12345'
                    Assignments     = @{
                        'john.smith@contoso.com' = @{}
                    }
                    AppliedCategories = @{
                        Category1 = $true
                    }
                }
            }

            Mock -CommandName New-MgPlannerTask -MockWith {
            }

            Mock -CommandName Get-MgPlannerTaskDetail -MockWith {
                return @{
                    CheckList   = @()
                    PreviewType = 'automatic'
                }
            }

            Mock -CommandName Get-MgPlannerPlanDetail -MockWith {
                return @{
                    Id = '1234567890'
                    CategoryDescriptions = @{
                        Category1 = $null
                    }
                }
            }
        }

        # Test contexts
        Context -Name "When the Task doesn't exist but it should" -Fixture {
            BeforeAll {
                $testParams = @{
                    PlanId          = '1234567890'
                    Title           = 'Contoso Task'
                    Priority        = 5
                    PreviewType     = 'automatic'
                    BucketId        = '1234'
                    PercentComplete = 75
                    StartDateTime   = '2020-06-09'
                    DueDateTime     = '2020-06-10'
                    Assignments     = @('john.smith@contoso.com')
                    Description     = 'Contoso Task Description'
                    Attachments     = [MSFT_PlannerTaskAttachment[]]@(
                        [MSFT_PlannerTaskAttachment] @{
                            Uri   = 'https://contoso.com/doc.docx'
                            Alias = 'Contoso Document'
                            Type  = 'Word'
                        }
                    )
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Get-MgPlannerTask -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgPlannerTaskDetail -MockWith {
                    return @{
                        '@odata.etag' = 'W/"NewTaskDetails"'
                    }
                }

                Mock -CommandName New-MgPlannerTask -MockWith {
                    return @{
                        Id = 'NewTask12345'
                    }
                }

                Mock -CommandName Update-MgPlannerTaskDetail -MockWith {
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the Task in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Set()

                Should -Invoke -CommandName New-MgPlannerTask -Exactly 1 -ParameterFilter {
                    -not $BodyParameter.ContainsKey('Details') -and -not $BodyParameter.ContainsKey('Ensure')
                }
            }

            It 'Should write the attachments to the details of the new Task in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Set()

                Should -Invoke -CommandName Update-MgPlannerTaskDetail -Exactly 1 -ParameterFilter {
                    $PlannerTaskId -eq 'NewTask12345' -and
                    $Headers.'If-Match' -eq 'W/"NewTaskDetails"' -and
                    $BodyParameter.references.Keys -contains 'https://contoso.com/doc.docx' -and
                    $BodyParameter.references.'https://contoso.com/doc.docx'.alias -eq 'Contoso Document' -and
                    $BodyParameter.description -eq 'Contoso Task Description'
                }
            }
        }

        Context -Name 'Task exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    PlanId          = '1234567890'
                    Id              = '12345'
                    Title           = 'Contoso Task'
                    Priority        = 4
                    PreviewType     = 'checklist'
                    Assignments     = @('john.smith@contoso.com')
                    PercentComplete = 75
                    Categories      = @('Pink')
                    StartDateTime   = '2020-06-09'
                    DueDateTime     = '2020-06-10'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Test() | Should -Be $False
            }

            It 'Should update the settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Set()
            }
        }

        Context -Name 'Task exists and is IN the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    PlanId          = '1234567890'
                    Title           = 'Contoso Task'
                    Id              = '12345'
                    Priority        = 5
                    PreviewType     = 'automatic'
                    Assignments     = @('john.smith@contoso.com')
                    PercentComplete = 75
                    Categories      = @('Pink')
                    StartDateTime   = '2020-06-09'
                    DueDateTime     = '2020-06-10'
                    BucketId        = 'Bucket12345'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Task exists on a plan that defines a custom category label' -Fixture {
            BeforeAll {
                $testParams = @{
                    PlanId          = '1234567890'
                    Title           = 'Contoso Task'
                    Id              = '12345'
                    Priority        = 5
                    PreviewType     = 'automatic'
                    Assignments     = @('john.smith@contoso.com')
                    PercentComplete = 75
                    Categories      = @('Urgent')
                    StartDateTime   = '2020-06-09'
                    DueDateTime     = '2020-06-10'
                    BucketId        = 'Bucket12345'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Get-MgPlannerPlanDetail -MockWith {
                    return @{
                        Id                   = '1234567890'
                        CategoryDescriptions = @{
                            Category1 = 'Urgent'
                        }
                    }
                }
            }

            It 'Should return the plan label from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Get().ToHashtable()).Categories | Should -Be 'Urgent'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Task exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    PlanId          = '1234567890'
                    Title           = 'Contoso Task'
                    Id              = '12345'
                    Priority        = 5
                    PreviewType     = 'automatic'
                    Assignments     = @('john.smith@contoso.com')
                    PercentComplete = 75
                    Categories      = @('Pink')
                    StartDateTime   = '2020-06-09'
                    DueDateTime     = '2020-06-10'
                    Ensure          = 'Absent'
                    Credential      = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Test() | Should -Be $False
            }
        }

        Context -Name 'Task is need to be part of a Bucket by ID and is in Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    PlanId          = '1234567890'
                    Id              = '12345'
                    Title           = 'Contoso Task'
                    BucketId        = 'Bucket12345'
                    Priority        = 5
                    PreviewType     = 'automatic'
                    Assignments     = @('john.smith@contoso.com')
                    PercentComplete = 75
                    Categories      = @('Pink')
                    StartDateTime   = '2020-06-09'
                    DueDateTime     = '2020-06-10'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Get-MgPlannerPlanBucket -MockWith {
                    return @{
                        Id   = 'Bucket12345'
                        Name = 'TestBucket'
                    }
                }
            }

            It "Should return 'Bucket12345' as the Bucket Value" {
                ((New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Get().ToHashtable()).BucketId | Should -Be 'Bucket12345'
            }

            It 'Should return True from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Test() | Should -Be $True
            }
        }


        Context -Name 'Task is need to be part of a Bucket by Name and is NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    PlanId          = '1234567890'
                    Id              = '12345'
                    Title           = 'Contoso Task'
                    BucketId        = 'TestBucket'
                    Priority        = 5
                    PreviewType     = 'automatic'
                    Assignments     = @('john.smith@contoso.com')
                    PercentComplete = 75
                    Categories      = @('Pink')
                    StartDateTime   = '2020-06-09'
                    DueDateTime     = '2020-06-10'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Get-MgPlannerPlanBucket -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'Task should not be part of a Bucket but it IS' -Fixture {
            BeforeAll {
                $testParams = @{
                    PlanId          = '1234567890'
                    Id              = '12345'
                    Title           = 'Contoso Task'
                    Priority        = 5
                    PreviewType     = 'automatic'
                    Assignments     = @('john.smith@contoso.com')
                    PercentComplete = 75
                    Categories      = @('Pink')
                    StartDateTime   = '2020-06-09'
                    DueDateTime     = '2020-06-10'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }


                Mock -CommandName Get-MgPlannerPlanBucket -MockWith {
                    return @{
                        Id   = 'Bucket12345'
                        Name = 'TestBucket'
                    }
                }
            }

            It "Should return 'TestBucket' as the Bucket Value" {
                ((New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Get().ToHashtable()).BucketId | Should -Be 'Bucket12345'
            }

            It 'Should return False from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerTask' -Property $testParams).Test() | Should -Be $False
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return @(
                        @{
                            DisplayName = 'Contoso Group'
                            Id          = '12345-12345-12345-12345-12345'
                        }
                    )
                }

                Mock -CommandName Get-MgGroupPlannerPlan -MockWith {
                    return @{
                        Title = 'Contoso Plan'
                        Id    = '1234567890'
                        Owner = '12345-12345-12345-12345-12345'
                    }
                }

                Mock -CommandName Get-MgGroupPlannerPlanTask -MockWith {
                    return @(
                        @{
                            PlanId          = '1234567890'
                            Title           = 'Contoso Task'
                            Priority        = 5
                            PercentComplete = 75
                            StartDateTime   = '2020-06-09'
                        }
                    )
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'PlannerTask' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }

        Context -Name 'ReverseDSC Tests across plans with different category labels' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return @(
                        @{
                            DisplayName = 'Contoso Group'
                            Id          = '12345-12345-12345-12345-12345'
                        }
                    )
                }

                Mock -CommandName Get-MgGroupPlannerPlan -MockWith {
                    return @(
                        @{
                            Title = 'Contoso Plan One'
                            Id    = 'PlanOne'
                        },
                        @{
                            Title = 'Contoso Plan Two'
                            Id    = 'PlanTwo'
                        }
                    )
                }

                Mock -CommandName Get-MgGroupPlannerPlanTask -MockWith {
                    return @(
                        @{
                            Id     = "Task$PlannerPlanId"
                            PlanId = $PlannerPlanId
                            Title  = "Contoso Task on $PlannerPlanId"
                        }
                    )
                }

                Mock -CommandName Get-MgPlannerTask -MockWith {
                    return @{
                        Id                = $PlannerTaskId
                        Title             = 'Contoso Task'
                        AppliedCategories = @{
                            Category1 = $true
                        }
                    }
                }

                Mock -CommandName Get-MgPlannerPlanDetail -MockWith {
                    $labelsByPlan = @{
                        PlanOne = 'Urgent'
                        PlanTwo = 'Blocked'
                    }
                    return @{
                        Id                   = $PlannerPlanId
                        CategoryDescriptions = @{
                            Category1 = $labelsByPlan.$PlannerPlanId
                        }
                    }
                }
            }

            It 'Should export the category label of the plan that owns each task' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'PlannerTask' -MethodName 'Export' -Parameters $testParams
                $result | Should -Match 'Urgent'
                $result | Should -Match 'Blocked'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
