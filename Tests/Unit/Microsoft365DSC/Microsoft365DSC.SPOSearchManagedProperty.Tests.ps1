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
    -DscResource 'SPOSearchManagedProperty' -GenericStubModule $GenericStubPath

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
            $existingValueXML = "<?xml version=`"1.0`" encoding=`"ISO-8859-1`"?>
            <SearchConfigurationSettings xmlns:i=`"http://www.w3.org/2001/XMLSchema-instance`" xmlns=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Portability`">
            <SearchQueryConfigurationSettings>
            <SearchQueryConfigurationSettings>
            <BestBets xmlns:d4p1=`"http://www.microsoft.com/sharepoint/search/KnownTypes/2008/08`"/>
            <DefaultSourceId>00000000-0000-0000-0000-000000000000</DefaultSourceId>
            <DefaultSourceIdSet>true</DefaultSourceIdSet>
            <DeployToParent>false</DeployToParent>
            <DisableInheritanceOnImport>false</DisableInheritanceOnImport>
            <QueryRuleGroups xmlns:d4p1=`"http://www.microsoft.com/sharepoint/search/KnownTypes/2008/08`"/>
            <QueryRules xmlns:d4p1=`"http://www.microsoft.com/sharepoint/search/KnownTypes/2008/08`"/>
            <ResultTypes xmlns:d4p1=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration`"/>
            <Sources xmlns:d4p1=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration.Query`"/>
            <UserSegments xmlns:d4p1=`"http://www.microsoft.com/sharepoint/search/KnownTypes/2008/08`"/>
            </SearchQueryConfigurationSettings>
            </SearchQueryConfigurationSettings>
            <SearchRankingModelConfigurationSettings>
            <RankingModels xmlns:d3p1=`"http://schemas.microsoft.com/2003/10/Serialization/Arrays`"/>
            </SearchRankingModelConfigurationSettings>
            <SearchSchemaConfigurationSettings>
            <Aliases xmlns:d3p1=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration`">
            <d3p1:LastItemName i:nil=`"true`"/>
            <d3p1:dictionary xmlns:d4p1=`"http://schemas.microsoft.com/2003/10/Serialization/Arrays`">
            <d4p1:KeyValueOfstringAliasInfoy6h3NzC8>
            <d4p1:Key>Alias1</d4p1:Key>
            <d4p1:Value>
            <d3p1:Name>Alias1</d3p1:Name>
            <d3p1:ManagedPid>7777</d3p1:ManagedPid>
            <d3p1:SchemaId>6408</d3p1:SchemaId>
            </d4p1:Value>
            </d4p1:KeyValueOfstringAliasInfoy6h3NzC8>
            </d3p1:dictionary>
            </Aliases>
            <CategoriesAndCrawledProperties xmlns:d3p1=`"http://schemas.microsoft.com/2003/10/Serialization/Arrays`"/>
            <CrawledProperties xmlns:d3p1=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration`" i:nil=`"true`"/>
            <ManagedProperties xmlns:d3p1=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration`">
            <d3p1:LastItemName i:nil=`"true`"/>
            <d3p1:dictionary xmlns:d4p1=`"http://schemas.microsoft.com/2003/10/Serialization/Arrays`">
            <d4p1:KeyValueOfstringManagedPropertyInfoy6h3NzC8>
            <d4p1:Key>TestMP</d4p1:Key>
            <d4p1:Value>
            <d3p1:Name>TestMP</d3p1:Name>
            <d3p1:CompleteMatching>false</d3p1:CompleteMatching>
            <d3p1:Context>0</d3p1:Context>
            <d3p1:DeleteDisallowed>false</d3p1:DeleteDisallowed>
            <d3p1:Description>This is a test</d3p1:Description>
            <d3p1:EnabledForScoping>false</d3p1:EnabledForScoping>
            <d3p1:EntityExtractorBitMap>4161</d3p1:EntityExtractorBitMap>
            <d3p1:ExpandSegments>false</d3p1:ExpandSegments>
            <d3p1:FullTextIndex>0</d3p1:FullTextIndex>
            <d3p1:HasMultipleValues>false</d3p1:HasMultipleValues>
            <d3p1:IndexOptions>0</d3p1:IndexOptions>
            <d3p1:IsImplicit>false</d3p1:IsImplicit>
            <d3p1:IsReadOnly>false</d3p1:IsReadOnly>
            <d3p1:LanguageNeutralWordBreaker>true</d3p1:LanguageNeutralWordBreaker>
            <d3p1:ManagedType>Text</d3p1:ManagedType>
            <d3p1:MappingDisallowed>false</d3p1:MappingDisallowed>
            <d3p1:Pid>7777</d3p1:Pid>
            <d3p1:Queryable>false</d3p1:Queryable>
            <d3p1:Refinable>true</d3p1:Refinable>
            <d3p1:RefinerConfiguration>
            <d3p1:Anchoring>Auto</d3p1:Anchoring>
            <d3p1:CutoffMaxBuckets>1000</d3p1:CutoffMaxBuckets>
            <d3p1:Divisor>1</d3p1:Divisor>
            <d3p1:Intervals>4</d3p1:Intervals>
            <d3p1:Resolution>1</d3p1:Resolution>
            <d3p1:Type>Deep</d3p1:Type>
            </d3p1:RefinerConfiguration>
            <d3p1:RemoveDuplicates>true</d3p1:RemoveDuplicates>
            <d3p1:RespectPriority>false</d3p1:RespectPriority>
            <d3p1:Retrievable>false</d3p1:Retrievable>
            <d3p1:SafeForAnonymous>false</d3p1:SafeForAnonymous>
            <d3p1:Searchable>false</d3p1:Searchable>
            <d3p1:Sortable>true</d3p1:Sortable>
            <d3p1:SortableType>Enabled</d3p1:SortableType>
            <d3p1:TokenNormalization>true</d3p1:TokenNormalization>
            </d4p1:Value>
            </d4p1:KeyValueOfstringManagedPropertyInfoy6h3NzC8>
            </d3p1:dictionary>
            <d3p1:TotalCount>0</d3p1:TotalCount>
            </ManagedProperties>
            <Mappings xmlns:d3p1=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration`">
            <d3p1:LastItemName i:nil=`"true`"/>
            <d3p1:dictionary xmlns:d4p1=`"http://schemas.microsoft.com/2003/10/Serialization/Arrays`"/>
            </Mappings>
            <Overrides xmlns:d3p1=`"http://schemas.datacontract.org/2004/07/Microsoft.Office.Server.Search.Administration`">
            <d3p1:LastItemName i:nil=`"true`"/>
            <d3p1:dictionary xmlns:d4p1=`"http://schemas.microsoft.com/2003/10/Serialization/Arrays`"/>
            </Overrides>
            </SearchSchemaConfigurationSettings>
            <SearchSubscriptionSettingsConfigurationSettings i:nil=`"true`"/>
            <SearchTaxonomyConfigurationSettings i:nil=`"true`"/>
            </SearchConfigurationSettings>"

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the Managed Property doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                        = 'TestMPWrongName'
                    Type                        = 'Text'
                    Description                 = 'This is a test'
                    Searchable                  = $false
                    FullTextContext             = 0
                    Queryable                   = $false
                    Retrievable                 = $false
                    AllowMultipleValues         = $false
                    Refinable                   = 'No'
                    Sortable                    = 'No'
                    Safe                        = $false
                    Aliases                     = @('Alias1')
                    TokenNormalization          = $true
                    CompleteMatching            = $false
                    LanguageNeutralTokenization = $true
                    FinerQueryTokenization      = $false
                    CompanyNameExtraction       = $true
                    Ensure                      = 'Present'
                    Credential                  = $Credential
                }
                $xmlTemplatePath = Join-Path -Path $PSScriptRoot `
                    -ChildPath '../../../Modules/Microsoft365DSC/Dependencies/SearchConfigurationSettings.xml' `
                    -Resolve
                $emptyXMLTemplate = Get-Content $xmlTemplatePath
                Mock -CommandName Get-PnPSearchConfiguration -MockWith {
                    return $emptyXMLTemplate
                }

                Mock -CommandName Set-PnPSearchConfiguration -MockWith {

                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSearchManagedProperty' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be "Absent"
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSearchManagedProperty' -Property $testParams).Test() | Should -Be $false
            }

            It 'Creates the managed property in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSearchManagedProperty' -Property $testParams).Set()
                Should -Invoke -CommandName Set-PnPSearchConfiguration
            }

            It 'Throws when a new managed property is refinable or sortable' {
                $params = $testParams.Clone()
                $params.Refinable = 'Yes'
                { (New-M365DSCResourceInstance -ResourceName 'SPOSearchManagedProperty' -Property $params).Set() } |
                    Should -Throw '*only creates managed properties of type Text or YesNo*'
            }
        }

        Context -Name 'When the Managed Property already exists' -Fixture {
            BeforeAll {
                $Script:RecentMPExtract = $null
                $testParams = @{
                    Name                        = 'TestMP'
                    Type                        = 'Text'
                    Description                 = 'This is a test'
                    Searchable                  = $false
                    FullTextContext             = 0
                    Queryable                   = $false
                    Retrievable                 = $false
                    AllowMultipleValues         = $false
                    Refinable                   = 'Yes'
                    Sortable                    = 'Yes'
                    Safe                        = $false
                    Aliases                     = @('Alias1')
                    TokenNormalization          = $true
                    CompleteMatching            = $false
                    LanguageNeutralTokenization = $true
                    FinerQueryTokenization      = $false
                    CompanyNameExtraction       = $true
                    Ensure                      = 'Present'
                    Credential                  = $Credential
                }
                Mock -CommandName Get-PnPSearchConfiguration -MockWith {
                    return $existingValueXML
                }

                Mock -CommandName Set-PnPSearchConfiguration -MockWith {

                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SPOSearchManagedProperty' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSearchManagedProperty' -Property $testParams).Test() | Should -Be $true
            }

            It 'Update the managed property in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SPOSearchManagedProperty' -Property $testParams).Set()
            }

            It 'Returns No for Refinable and Sortable when the schema has false' {
                Mock -CommandName Get-PnPSearchConfiguration -MockWith {
                    return ($existingValueXML -replace '<d3p1:Refinable>true', '<d3p1:Refinable>false' -replace '<d3p1:Sortable>true', '<d3p1:Sortable>false')
                }

                $result = (New-M365DSCResourceInstance -ResourceName 'SPOSearchManagedProperty' -Property $testParams).Get().ToHashtable()
                $result.Refinable | Should -Be 'No'
                $result.Sortable | Should -Be 'No'
            }
        }

        Context -Name 'When Invalid values are used' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                        = 'TestMP'
                    Type                        = 'Text'
                    Description                 = 'This is a test'
                    Searchable                  = $false
                    FullTextContext             = 0
                    Queryable                   = $false
                    Retrievable                 = $false
                    AllowMultipleValues         = $false
                    Refinable                   = 'No'
                    Sortable                    = 'No'
                    Safe                        = $false
                    Aliases                     = @('Alias1')
                    TokenNormalization          = $true
                    CompleteMatching            = $true
                    LanguageNeutralTokenization = $true
                    FinerQueryTokenization      = $false
                    CompanyNameExtraction       = $true
                    Ensure                      = 'Present'
                    Credential                  = $Credential
                }
            }

            It 'Should throw and errors' {
                { (New-M365DSCResourceInstance -ResourceName 'SPOSearchManagedProperty' -Property $testParams).Set() } | Should -Throw 'You cannot have CompleteMatching set to True if LanguageNeutralTokenization is set to True'
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPSearchConfiguration -MockWith {
                    return $existingValueXML
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SPOSearchManagedProperty' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
