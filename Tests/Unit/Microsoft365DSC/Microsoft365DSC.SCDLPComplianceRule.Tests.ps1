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
    -DscResource 'SCDLPComplianceRule' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Import-PSSession -MockWith {
            }

            Mock -CommandName New-PSSession -MockWith {
            }

            Mock -CommandName Remove-DLPComplianceRule -MockWith {
            }

            Mock -CommandName New-DLPComplianceRule -MockWith {
                return @{

                }
            }

            Mock -CommandName Get-DlpSensitiveInformationType -MockWith {
                return @(
                    [PSCustomObject]@{Name = 'ABA Routing Number'; Id = 'cb353f78-2b72-4c3c-8827-92ebe4f69fdf' },
                    [PSCustomObject]@{Name = 'Argentina Unique Tax Identification Key (CUIT/CUIL)'; Id = '98da3da1-9199-4571-b7c4-b6522980b507' },
                    [PSCustomObject]@{Name = 'Argentina National Identity (DNI) Number'; Id = 'eefbb00e-8282-433c-8620-8f1da3bffdb2' },
                    [PSCustomObject]@{Name = 'EU Debit Card Number'; Id = '0e9b3178-9678-47dd-a509-37222ca96b42' }
                    [PSCustomObject]@{Name = 'SCSEDM001-SCHEMA-CUSTOMERDATA'; Id = '00000000-0000-0000-0000-000000000000' }
                )
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "Rule doesn't already exist but should" -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                              = 'Present'
                    Policy                              = 'MyParentPolicy'
                    Comment                             = ''
                    AdvancedRule                        = "`"{\r\n  \`"Version\`": \`"1.0\`",\r\n  \`"Condition\`": {\r\n    \`"Operator\`": \`"And\`",\r\n    \`"SubConditions\`": [\r\n      {\r\n        \`"ConditionName\`": \`"AccessScope\`",\r\n        \`"Value\`": \`"InOrganization\`"\r\n      },\r\n      {\r\n        \`"ConditionName\`": \`"ContentContainsSensitiveInformation\`",\r\n        \`"Value\`": {\r\n          \`"maxconfidence\`": \`"100\`",\r\n          \`"name\`": \`"EU Debit Card Number\`",\r\n          \`"maxcount\`": \`"9\`",\r\n          \`"minconfidence\`": \`"75\`",\r\n          \`"classifiertype\`": \`"Content\`",\r\n          \`"mincount\`": \`"1\`",\r\n          \`"confidencelevel\`": \`"Medium\`"\r\n        }\r\n      }\r\n    ]\r\n  }\r\n}`"";
                    ContentContainsSensitiveInformation = ([MSFT_SCDLPContainsSensitiveInformation] @{
                            SensitiveInformation = @([MSFT_SCDLPSensitiveInformation] @{
                                    name           = 'ABA Routing Number'
                                    id             = 'cb353f78-2b72-4c3c-8827-92ebe4f69fdf'
                                    maxconfidence  = '100'
                                    minconfidence  = '75'
                                    classifiertype = 'Content'
                                    mincount       = '1'
                                    maxcount       = '-1'
                                })
                        })

                    BlockAccess                         = $False
                    Name                                = 'TestPolicy'
                    Credential                          = $Credential
                }
                Mock -CommandName Get-DLPComplianceRule -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Set()
            }
        }

        Context -Name "Rule Group doesn't already exist but should" -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                              = 'Present'
                    Policy                              = 'MyParentPolicy'
                    Comment                             = ''
                    AdvancedRule                        = "`"{\r\n  \`"Version\`": \`"1.0\`",\r\n  \`"Condition\`": {\r\n    \`"Operator\`": \`"And\`",\r\n    \`"SubConditions\`": [\r\n      {\r\n        \`"ConditionName\`": \`"ContentContainsSensitiveInformation\`",\r\n        \`"Value\`": [\r\n          {\r\n            \`"Groups\`": [\r\n              {\r\n                \`"Name\`": \`"Default\`",\r\n                \`"Operator\`": \`"Or\`",\r\n                \`"Sensitivetypes\`": [\r\n                  {\r\n                    \`"Name\`": \`"SCSEDM001-SCHEMA-CUSTOMERDATA\`",\r\n                    \`"Id\`": null,\r\n                    \`"Mincount\`": 5,\r\n                    \`"Maxcount\`": 9,\r\n                    \`"Confidencelevel\`": \`"High\`",\r\n                    \`"Minconfidence\`": 85,\r\n                    \`"Maxconfidence\`": 100\r\n                  }\r\n                ]\r\n              }\r\n            ],\r\n            \`"Operator\`": \`"And\`"\r\n          }\r\n        ]\r\n      }\r\n    ]\r\n  }\r\n}`"";
                    ContentContainsSensitiveInformation = @([MSFT_SCDLPContainsSensitiveInformation] @{
                        Operator = 'And'
                        Groups   = @(
                            [MSFT_SCDLPContainsSensitiveInformationGroup] @{
                                Name                 = 'default'
                                operator             = 'and'
                                SensitiveInformation = @(
                                    [MSFT_SCDLPSensitiveInformation] @{
                                        name           = 'ABA Routing Number'
                                        id             = 'cb353f78-2b72-4c3c-8827-92ebe4f69fdf'
                                        maxconfidence  = '100'
                                        minconfidence  = '75'
                                        classifiertype = 'Content'
                                        mincount       = '1'
                                        maxcount       = '-1'
                                    }
                                    [MSFT_SCDLPSensitiveInformation] @{
                                        name           = 'Argentina Unique Tax Identification Key (CUIT/CUIL)'
                                        id             = '98da3da1-9199-4571-b7c4-b6522980b507'
                                        maxconfidence  = '100'
                                        minconfidence  = '75'
                                        classifiertype = 'Content'
                                        mincount       = '1'
                                        maxcount       = '-1'
                                    }
                                )
                            }
                        )
                    })
                    BlockAccess                         = $False
                    Name                                = 'TestPolicy'
                    Credential                          = $Credential
                }

                Mock -CommandName Get-DLPComplianceRule -MockWith {
                    return $null
                }
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Set()
            }
        }

        Context -Name 'Rule already exists, and should with ContentContainsSensitiveInformation' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                              = 'Present'
                    Policy                              = 'MyParentPolicy'
                    Comment                             = 'New comment'
                    ContentContainsSensitiveInformation = @([MSFT_SCDLPContainsSensitiveInformation] @{
                            SensitiveInformation = @([MSFT_SCDLPSensitiveInformation] @{
                                    name           = 'ABA Routing Number'
                                    id             = 'cb353f78-2b72-4c3c-8827-92ebe4f69fdf'
                                    maxconfidence  = '100'
                                    minconfidence  = '75'
                                    classifiertype = 'Content'
                                    mincount       = '1'
                                    maxcount       = '-1'
                                })
                        })
                    BlockAccess                         = $False
                    SentToMemberOf                      = @('finance@contoso.com')
                    FromAddressContainsWords            = @('payroll')
                    Name                                = 'TestPolicy'
                    Credential                          = $Credential
                }

                Mock -CommandName Get-DLPComplianceRule -MockWith {
                    return @{
                        Name                                = 'TestPolicy'
                        Comment                             = 'New Comment'
                        ParentPolicyName                    = 'MyParentPolicy'
                        ContentContainsSensitiveInformation = @(@{maxconfidence = '100'; id = 'cb353f78-2b72-4c3c-8827-92ebe4f69fdf'; minconfidence = '75'; rulePackId = '00000000-0000-0000-0000-000000000000'; classifiertype = 'Content'; name = 'ABA Routing Number'; mincount = '1'; maxcount = '-1'; })
                        BlockAccess                         = $False
                        SentToMemberOf                      = @('finance@contoso.com')
                        FromAddressMatchesPatterns          = @('^alerts@')
                        FromAddressContainsWords            = @('payroll')
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should recreate from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Rule already exists, and should with AdvancedRules' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                              = 'Present'
                    Policy                              = 'MyParentPolicy'
                    Comment                             = 'New comment'
                    AdvancedRule                        = "`"{\r\n  \`"Version\`": \`"1.0\`",\r\n  \`"Condition\`": {\r\n    \`"Operator\`": \`"And\`",\r\n    \`"SubConditions\`": [\r\n      {\r\n        \`"ConditionName\`": \`"AccessScope\`",\r\n        \`"Value\`": \`"InOrganization\`"\r\n      },\r\n      {\r\n        \`"ConditionName\`": \`"ContentContainsSensitiveInformation\`",\r\n        \`"Value\`": {\r\n          \`"name\`": \`"EU Debit Card Number\`",\r\n          \`"maxconfidence\`": \`"100\`",\r\n          \`"minconfidence\`": \`"75\`",\r\n          \`"classifiertype\`": \`"Content\`",\r\n          \`"mincount\`": \`"1\`",\r\n          \`"maxcount\`": \`"9\`",\r\n          \`"confidencelevel\`": \`"Medium\`"\r\n        }\r\n      }\r\n    ]\r\n  }\r\n}`"";
                    BlockAccess                         = $False
                    Name                                = 'TestPolicy'
                    Credential                          = $Credential
                }

                Mock -CommandName Get-DLPComplianceRule -MockWith {
                    return @{
                        Name                                = 'TestPolicy'
                        Comment                             = 'New Comment'
                        ParentPolicyName                    = 'MyParentPolicy'
                        AdvancedRule                        = @'
{
  "Version": "1.0",
  "Condition": {
    "Operator": "And",
    "SubConditions": [
    {
      "ConditionName": "AccessScope",
      "Value": "InOrganization"
    },
      {
        "ConditionName": "ContentContainsSensitiveInformation",
        "Value": [
          {
            "name": "EU Debit Card Number",
            "maxconfidence": "100",
            "minconfidence": "75",
            "classifiertype": "Content",
            "mincount": "1",
            "maxcount": "9",
            "confidencelevel": "Medium"
          }
        ]
      }
    ]
  }
}
'@;
                        BlockAccess                         = $False
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should recreate from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Rule already exists, and should with AdvancedRules containing trainable classifier ids' -Fixture {
            BeforeAll {
                $desiredAdvancedRule = @'
{
  "Version": "1.0",
  "Condition": {
    "Operator": "And",
    "SubConditions": [
      {
        "ConditionName": "ContentContainsSensitiveInformation",
        "Value": [
          {
            "Groups": [
              {
                "Name": "PHI SITs",
                "Operator": "Or",
                "Sensitivetypes": [
                  {
                    "Name": "Healthcare",
                    "Id": "11111111-1111-1111-1111-111111111111",
                    "Classifiertype": "MLModel"
                  },
                  {
                    "Name": "EU Debit Card Number",
                    "Id": "0e9b3178-9678-47dd-a509-37222ca96b42",
                    "Mincount": 1,
                    "Maxcount": -1,
                    "Confidencelevel": "Medium"
                  }
                ]
              }
            ],
            "Operator": "And"
          }
        ]
      }
    ]
  }
}
'@
                $currentAdvancedRule = @'
{
  "Version": "1.0",
  "Condition": {
    "Operator": "And",
    "SubConditions": [
      {
        "ConditionName": "ContentContainsSensitiveInformation",
        "Value": [
          {
            "Groups": [
              {
                "Name": "PHI SITs",
                "Operator": "Or",
                "Sensitivetypes": [
                  {
                    "Name": "Healthcare",
                    "Id": null,
                    "Classifiertype": "MLModel"
                  },
                  {
                    "Name": "EU Debit Card Number",
                    "Id": null,
                    "Mincount": 1,
                    "Maxcount": -1,
                    "Confidencelevel": "Medium"
                  }
                ]
              }
            ],
            "Operator": "And"
          }
        ]
      }
    ]
  }
}
'@
                $testParams = @{
                    Ensure       = 'Present'
                    Policy       = 'MyParentPolicy'
                    Comment      = 'New comment'
                    AdvancedRule = $desiredAdvancedRule | ConvertTo-Json -Compress
                    BlockAccess  = $False
                    Name         = 'TestPolicy'
                    Credential   = $Credential
                }

                Mock -CommandName Get-DLPComplianceRule -MockWith {
                    return @{
                        Name             = 'TestPolicy'
                        Comment          = 'New Comment'
                        ParentPolicyName = 'MyParentPolicy'
                        AdvancedRule     = $currentAdvancedRule
                        BlockAccess      = $False
                    }
                }
            }

            It 'Should ignore trainable classifier ids when testing AdvancedRules for drift' {
                $instance = New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams
                $desiredValues = $instance.GetBoundParameters()
                $currentValues = $instance.Get().ToHashtable()
                $valuesToCheck = $desiredValues.Clone()

                $result = $instance.GetCompareParameters().PostProcessing.Invoke($desiredValues, $currentValues, $valuesToCheck, @())

                $normalizedAdvancedRule = $result.Item1.AdvancedRule | ConvertFrom-Json | ConvertFrom-Json
                $sensitiveTypes = $normalizedAdvancedRule.Condition.SubConditions[0].Value[0].Groups[0].Sensitivetypes
                ($sensitiveTypes | Where-Object -FilterScript { $_.Name -eq 'Healthcare' }).Id | Should -Be $null
                ($sensitiveTypes | Where-Object -FilterScript { $_.Name -eq 'EU Debit Card Number' }).Id | Should -Be '0e9b3178-9678-47dd-a509-37222ca96b42'
            }

            It 'Should run the full Test() compare over AdvancedRules without throwing' {
                { (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Test() } | Should -Not -Throw
            }
        }

        Context -Name "Rule doesn't already exist but should with AdvancedRules containing trainable classifier ids" -Fixture {
            BeforeAll {
                $desiredAdvancedRule = @'
{
  "Version": "1.0",
  "Condition": {
    "Operator": "And",
    "SubConditions": [
      {
        "ConditionName": "ContentContainsSensitiveInformation",
        "Value": [
          {
            "Groups": [
              {
                "Name": "PHI SITs",
                "Operator": "Or",
                "Sensitivetypes": [
                  {
                    "Name": "Healthcare",
                    "Id": "11111111-1111-1111-1111-111111111111",
                    "Classifiertype": "MLModel"
                  }
                ]
              }
            ],
            "Operator": "And"
          }
        ]
      }
    ]
  }
}
'@
                $testParams = @{
                    Ensure       = 'Present'
                    Policy       = 'MyParentPolicy'
                    Comment      = 'New comment'
                    AdvancedRule = $desiredAdvancedRule | ConvertTo-Json -Compress
                    BlockAccess  = $False
                    Name         = 'TestPolicy'
                    Credential   = $Credential
                }

                $Script:AdvancedRulePassedToTest = $null
                Mock -CommandName Get-DLPComplianceRule -MockWith {
                    return $null
                }

                Mock -CommandName Compare-M365DSCResourceState -ModuleName M365DSCUtil -MockWith {
                    param($ResourceName, $DesiredValues, $CurrentValues, $ExcludedProperties, $IncludedProperties, $PostProcessing, $PostProcessingArgs)
                    $Script:AdvancedRulePassedToTest = $DesiredValues.AdvancedRule
                    return $false
                }
            }

            It 'Should not normalize AdvancedRules for missing rules' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Test() | Should -Be $false
                $Script:AdvancedRulePassedToTest | Should -Be ($desiredAdvancedRule | ConvertTo-Json -Compress)
            }
        }

        Context -Name "Rule doesn't already exist but should with EndpointDlpRestrictions" -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                  = 'Present'
                    Policy                  = 'MyParentPolicy'
                    EndpointDlpRestrictions = @(
                        [MSFT_SCDLPEndpointDlpRestriction] @{
                            Setting = 'Print'
                            Value   = 'Block'
                        }
                        [MSFT_SCDLPEndpointDlpRestriction] @{
                            Setting = 'UnallowedApps'
                            Value   = 'notepad'
                            Value2  = 'Microsoft Notepad'
                        }
                    )
                    NotifyUser              = @('user@contoso.com')
                    Name                    = 'TestPolicy'
                    Credential              = $Credential
                }

                $Script:EndpointDlpRestrictionsPassedToNew = $null
                Mock -CommandName Get-DLPComplianceRule -MockWith {
                    return $null
                }
                Mock -CommandName New-DLPComplianceRule -MockWith {
                    $Script:EndpointDlpRestrictionsPassedToNew = $EndpointDlpRestrictions
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should pass EndpointDlpRestrictions as hashtables to the New method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Set()
                $Script:EndpointDlpRestrictionsPassedToNew[0].Setting | Should -Be 'Print'
                $Script:EndpointDlpRestrictionsPassedToNew[0].Value | Should -Be 'Block'
                $Script:EndpointDlpRestrictionsPassedToNew[1].Setting | Should -Be 'UnallowedApps'
                $Script:EndpointDlpRestrictionsPassedToNew[1].Value | Should -Be 'notepad'
                $Script:EndpointDlpRestrictionsPassedToNew[1].Value2 | Should -Be 'Microsoft Notepad'
            }
        }

        Context -Name 'Rule already exists, and should with EndpointDlpRestrictions' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                  = 'Present'
                    Policy                  = 'MyParentPolicy'
                    EndpointDlpRestrictions = @(
                        [MSFT_SCDLPEndpointDlpRestriction] @{
                            Setting = 'Print'
                            Value   = 'Block'
                        }
                        [MSFT_SCDLPEndpointDlpRestriction] @{
                            Setting = 'UnallowedApps'
                            Value   = 'notepad'
                            Value2  = 'Microsoft Notepad'
                        }
                    )
                    NotifyUser              = @('user@contoso.com')
                    Name                    = 'TestPolicy'
                    Credential              = $Credential
                }

                $Script:EndpointDlpRestrictionsPassedToSet = $null
                Mock -CommandName Get-DLPComplianceRule -MockWith {
                    return @{
                        Name                    = 'TestPolicy'
                        ParentPolicyName        = 'MyParentPolicy'
                        EndpointDlpRestrictions = @(
                            @{Setting = 'Print'; Value = 'Block' },
                            @{Setting = 'UnallowedApps'; Value = 'notepad'; Value2 = 'Microsoft Notepad' }
                        )
                        NotifyUser              = @('user@contoso.com')
                    }
                }
                Mock -CommandName Set-DLPComplianceRule -MockWith {
                    $Script:EndpointDlpRestrictionsPassedToSet = $EndpointDlpRestrictions
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should pass EndpointDlpRestrictions as hashtables to the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Set()
                $Script:EndpointDlpRestrictionsPassedToSet[0].Setting | Should -Be 'Print'
                $Script:EndpointDlpRestrictionsPassedToSet[0].Value | Should -Be 'Block'
                $Script:EndpointDlpRestrictionsPassedToSet[1].Setting | Should -Be 'UnallowedApps'
                $Script:EndpointDlpRestrictionsPassedToSet[1].Value | Should -Be 'notepad'
                $Script:EndpointDlpRestrictionsPassedToSet[1].Value2 | Should -Be 'Microsoft Notepad'
            }

            It 'Should return EndpointDlpRestrictions from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Get().ToHashtable()
                $result.EndpointDlpRestrictions[0].Setting | Should -Be 'Print'
                $result.EndpointDlpRestrictions[1].Value2 | Should -Be 'Microsoft Notepad'
            }
        }

        Context -Name 'Rule should not exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure      = 'Absent'
                    Policy      = 'MyParentPolicy'
                    Comment     = ''
                    BlockAccess = $False
                    Name        = 'TestPolicy'
                    Credential  = $Credential
                }

                Mock -CommandName Get-DLPComplianceRule -MockWith {
                    return @{
                        Name                                = 'TestPolicy'
                        ParentPolicyName                    = 'MyParentPolicy'
                        ContentContainsSensitiveInformation = @(@{maxconfidence = '100'; id = 'eefbb00e-8282-433c-8620-8f1da3bffdb2'; minconfidence = '75'; rulePackId = '00000000-0000-0000-0000-000000000000'; classifiertype = 'Content'; name = 'Argentina National Identity (DNI) Number'; mincount = '1'; maxcount = '9'; })
                        Comment                             = ''
                        BlockAccess                         = $False
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should delete from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'PostProcessing sensitive information comparison' -Fixture {
            BeforeAll {
                Mock -CommandName Add-M365DSCEvent -MockWith {
                }

                $postProcessing = (New-M365DSCResourceInstance -ResourceName 'SCDLPComplianceRule' -Property @{
                        Name       = 'TestPolicy'
                        Policy     = 'MyParentPolicy'
                        Credential = $Credential
                    }).GetCompareParameters().PostProcessing
            }

            It 'Should treat a null operator and an empty operator as equal' {
                $desired = @(@{ operator = ''; groups = @() })
                $current = @(@{ operator = $null; groups = @() })
                [SCDLPComplianceRule]::TestContainsSensitiveInformationGroups($desired, $current, $true) | Should -BeTrue
                Should -Invoke -CommandName Add-M365DSCEvent -Times 0 -Exactly -Scope It
            }

            It 'Should match a sensitive information type whose name carries escaped single quotes' {
                $desired = @(@{ name = "Driver''s License"; id = 'id-1' })
                $current = @(@{ name = "Driver's License"; id = 'id-1' })
                [SCDLPComplianceRule]::TestContainsSensitiveInformation($desired, $current, $true) | Should -BeTrue
                [SCDLPComplianceRule]::TestContainsSensitiveInformationLabels($desired, $current, $true) | Should -BeTrue
            }

            It 'Should report drift when a group is missing on the current side' {
                $desired = @(@{ operator = 'Or'; groups = @(@{ name = 'Group1'; operator = 'And'; sensitivetypes = @(@{ name = 'ABA Routing Number' }) }) })
                $current = @(@{ operator = 'Or'; groups = @() })
                [SCDLPComplianceRule]::TestContainsSensitiveInformationGroups($desired, $current, $true) | Should -BeFalse
                Should -Invoke -CommandName Add-M365DSCEvent -Times 1 -Exactly -Scope It
            }

            It 'Should report drift when maxcount is present on one side only' {
                $withMaxCount = @(@{ name = 'ABA Routing Number'; maxcount = '9' })
                $withoutMaxCount = @(@{ name = 'ABA Routing Number' })
                [SCDLPComplianceRule]::TestContainsSensitiveInformation($withMaxCount, $withoutMaxCount, $false) | Should -BeFalse
                [SCDLPComplianceRule]::TestContainsSensitiveInformation($withoutMaxCount, $withMaxCount, $false) | Should -BeFalse
                Should -Invoke -CommandName Add-M365DSCEvent -Times 0 -Exactly -Scope It
            }

            It 'Should log the current value as current and the desired value as expected' {
                $desired = @(@{ name = 'ABA Routing Number'; mincount = '1' })
                $current = @(@{ name = 'ABA Routing Number'; mincount = '5' })
                [SCDLPComplianceRule]::TestContainsSensitiveInformation($desired, $current, $true) | Should -BeFalse
                Should -Invoke -CommandName Add-M365DSCEvent -Times 1 -Exactly -Scope It -ParameterFilter {
                    $Message -like '*Current value is {5} and is expected to be {1}.*'
                }
            }

            It 'Should log the current operator as current and the desired operator as expected' {
                $desired = @(@{ operator = 'And'; groups = @() })
                $current = @(@{ operator = 'Or'; groups = @() })
                [SCDLPComplianceRule]::TestContainsSensitiveInformationGroups($desired, $current, $true) | Should -BeFalse
                Should -Invoke -CommandName Add-M365DSCEvent -Times 1 -Exactly -Scope It -ParameterFilter {
                    $Message -like '*Current value is {Or} and is expected to be {And}.*'
                }
            }

            It 'Should not log drift events when PostProcessing runs in a report context' {
                $desiredValues = @{ ContentContainsSensitiveInformation = @{ SensitiveInformation = @(@{ name = 'ABA Routing Number'; mincount = '1' }) } }
                $currentValues = @{ ContentContainsSensitiveInformation = @{ SensitiveInformation = @(@{ name = 'ABA Routing Number'; mincount = '5' }) } }
                $result = $postProcessing.Invoke($desiredValues, $currentValues, $desiredValues.Clone(), @(@{ IsReport = $true }))
                $result.Item1.ContentContainsSensitiveInformation | Should -Be 'SIT-Drift-Desired'
                Should -Invoke -CommandName Add-M365DSCEvent -Times 0 -Exactly -Scope It
            }

            It 'Should log the drift event once when PostProcessing runs outside a report context' {
                $desiredValues = @{ ContentContainsSensitiveInformation = @{ SensitiveInformation = @(@{ name = 'ABA Routing Number'; mincount = '1' }) } }
                $currentValues = @{ ContentContainsSensitiveInformation = @{ SensitiveInformation = @(@{ name = 'ABA Routing Number'; mincount = '5' }) } }
                $result = $postProcessing.Invoke($desiredValues, $currentValues, $desiredValues.Clone(), @())
                $result.Item1.ContentContainsSensitiveInformation | Should -Be 'SIT-Drift-Desired'
                Should -Invoke -CommandName Add-M365DSCEvent -Times 1 -Exactly -Scope It
            }

            It 'Should walk nested AdvancedRule conditions and clear trainable classifier ids' {
                $advancedRule = @{
                    Version   = '1.0'
                    Condition = @{
                        Operator      = 'And'
                        SubConditions = @(
                            @{
                                Operator      = 'Or'
                                SubConditions = @(
                                    @{
                                        ConditionName = 'ContentContainsSensitiveInformation'
                                        Value         = @(@{
                                                Groups = @(@{
                                                        Name           = 'Nested'
                                                        Sensitivetypes = @(@{ Name = 'Healthcare'; Id = '11111111-1111-1111-1111-111111111111'; Classifiertype = 'MLModel' })
                                                    })
                                            })
                                    }
                                )
                            }
                        )
                    }
                } | ConvertTo-Json -Depth 12
                $desiredValues = @{ AdvancedRule = ($advancedRule | ConvertTo-Json -Compress) }
                $currentValues = @{ Ensure = 'Present' }
                $result = $postProcessing.Invoke($desiredValues, $currentValues, $desiredValues.Clone(), @())
                $normalized = $result.Item1.AdvancedRule | ConvertFrom-Json | ConvertFrom-Json
                $normalized.Condition.SubConditions[0].SubConditions[0].Value[0].Groups[0].Sensitivetypes[0].Id | Should -BeNullOrEmpty
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-DLPComplianceRule -MockWith {
                    return @{
                        Name                                = 'TestPolicy'
                        ParentPolicyName                    = 'MyParentPolicy'
                        ContentContainsSensitiveInformation = @(@{maxconfidence = '100'; id = 'eefbb00e-8282-433c-8620-8f1da3bffdb2'; minconfidence = '75'; rulePackId = '00000000-0000-0000-0000-000000000000'; classifiertype = 'Content'; name = 'Argentina National Identity (DNI) Number'; mincount = '1'; maxcount = '9'; })
                        EndpointDlpRestrictions             = @(
                            @{Setting = 'Print'; Value = 'Block' },
                            @{Setting = 'UnallowedApps'; Value = 'notepad'; Value2 = 'Microsoft Notepad' }
                        )
                        Comment                             = ''
                        BlockAccess                         = $False
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCDLPComplianceRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                $result | Should -Match 'EndpointDlpRestrictions'
                $result | Should -Match 'SCDLPEndpointDlpRestriction'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
