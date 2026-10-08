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

            Mock -CommandName Set-PolicyConfig -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AdvancedClassificationEnabled           = $True;
                    AuditFileActivity                       = $True;
                    BandwidthLimitEnabled                   = $False;
                    BusinessJustificationList               = @(
                        ([MSFT_PolicyConfigBusinessJustificationList] @{
                            Id                = 'businessJustification1'
                            Enable            = $True
                            justificationText = 'default:Were'
                        })
                        ([MSFT_PolicyConfigBusinessJustificationList] @{
                            Id                = 'businessJustification2'
                            Enable            = $True
                            justificationText = 'default:Not'
                        })
                        ([MSFT_PolicyConfigBusinessJustificationList] @{
                            Id                = 'businessJustification3'
                            Enable            = $True
                            justificationText = 'default:Going'
                        })
                        ([MSFT_PolicyConfigBusinessJustificationList] @{
                            Id                = 'businessJustification4'
                            Enable            = $True
                            justificationText = 'default:To'
                        })
                        ([MSFT_PolicyConfigBusinessJustificationList] @{
                            Id                = 'businessJustification5'
                            Enable            = $True
                            justificationText = 'default:Take It'
                        })
                    );
                    CloudAppMode                            = "Block";
                    CloudAppRestrictionList                 = @("contoso.net","contoso.com");
                    CustomBusinessJustificationNotification = 3;
                    DailyBandwidthLimitInMB                 = 1000;
                    DLPAppGroups                            = @(
                        ([MSFT_PolicyConfigDLPAppGroups] @{
                            Name        = 'Maracas'
                            Description = 'Lacucaracha'
                            Apps = ([MSFT_PolicyConfigDLPApp] @{
                                    ExecutableName    = 'toc.exe'
                                    Name              = 'toctoctoc'
                                    Quarantine        = $False
                                })
                        })
                    );
                    DLPNetworkShareGroups                   = @(
                        ([MSFT_PolicyConfigDLPNetworkShareGroups] @{
                            groupName    = 'Network Share Group'
                            networkPaths = @('\\share2','\\share')
                        })
                    );
                    DLPPrinterGroups                        = @(
                        ([MSFT_PolicyConfigDLPPrinterGroups] @{
                            groupName    = 'MyGroup'
                            printers = ([MSFT_PolicyConfigPrinter] @{
                                    universalPrinter = $False
                                    usbPrinter       = $True
                                    usbPrinterId     = ''
                                    name             = 'asdf'
                                    alias            = 'aasdf'
                                    usbPrinterVID    = ''
                                    ipRange          = ([MSFT_PolicyConfigIPRange] @{
                                            fromAddress = ''
                                            toAddress   = ''
                                        })
                                    corporatePrinter = $False
                                    printToLocal     = $False
                                    printToFile      = $False
                                })
                        })
                    );
                    DLPRemovableMediaGroups                 = @(
                        ([MSFT_PolicyConfigDLPRemovableMediaGroups] @{
                            groupName = 'My Removable USB device group'
                            removableMedia    = ([MSFT_PolicyConfigRemovableMedia] @{
                                    deviceId          = 'Nik'
                                    removableMediaVID = 'bob'
                                    name              = 'MaCles'
                                    alias             = 'My Device'
                                    removableMediaPID = 'asdfsd'
                                    instancePathId    = 'instance path'
                                    serialNumberId    = 'asdf'
                                    hardwareId        = 'hardware'
                                })
                        })
                    );
                    EvidenceStoreSettings                   = ([MSFT_PolicyConfigEvidenceStoreSettings] @{
                            FileEvidenceIsEnabled = $True
                            NumberOfDaysToRetain  = 7
                            StorageAccounts       = @(
                            ([MSFT_PolicyConfigStorageAccount] @{
                                    Name    = 'My storage'
                                    BlobUri = 'https://contoso.com'
                                })
                            )
                            Store                 = 'CustomerManaged'
                        });
                    IncludePredefinedUnallowedBluetoothApps = $True;
                    IsSingleInstance                        = "Yes";
                    MacDefaultPathExclusionsEnabled         = $True;
                    MacPathExclusion                        = @("/pear","/apple","/orange");
                    NetworkPathEnforcementEnabled           = $True;
                    NetworkPathExclusion                    = "\\MyFirstPath:\\MySecondPath:\\MythirdPAth";
                    PathExclusion                           = @("\\includemenot","\\excludemeWindows","\\excludeme3");
                    QuarantineParameters                    = ([MSFT_PolicyConfigQuarantineParameters] @{
                            EnableQuarantineForCloudSyncApps = $False
                            QuarantinePath                   = '%homedrive%%homepath%\Microsoft DLP\Quarantine'
                            MacQuarantinePath                = '/System/Applications/Microsoft DLP/QuarantineMA'
                            ShouldReplaceFile                = $True
                            FileReplacementText              = 'Gargamel'
                        })
                    serverDlpEnabled                        = $True;
                    SiteGroups                              = @(
                        ([MSFT_PolicyConfigDLPSiteGroups] @{
                            Name      = 'Whatever'
                            Addresses = @([MSFT_PolicyConfigSiteGroupAddress] @{
                                    MatchType    = 'UrlMatch'
                                    Url          = 'Karakette.com'
                                    AddressLower = ''
                                    AddressUpper = ''
                                })
                        })
                    );
                    TenantId                                = $OrganizationName;
                    UnallowedApp                            = @(
                        ([MSFT_PolicyConfigApp] @{
                            Value        = 'Caramel'
                            Executable   = 'cara.exe'
                        })
                    );
                    UnallowedBluetoothApp                   = @(
                        ([MSFT_PolicyConfigApp] @{
                            Value        = 'bluetooth'
                            Executable   = 'micase.exe'
                        })
                    );
                    UnallowedBrowser                        = @(
                        ([MSFT_PolicyConfigApp] @{
                            Value        = 'UC Browser'
                            Executable   = 'ucbrowser.exe'
                        })
                    );
                    UnallowedCloudSyncApp                   = @(
                        ([MSFT_PolicyConfigApp] @{
                            Value        = 'ikochou'
                            Executable   = 'gillex.msi'
                        })
                    );
                    VPNSettings                             = @("MyVPNAddress","MySecondVPNAddress");
                    Credential          = $Credential;
                }

                Mock -CommandName Get-PolicyConfig -MockWith {
                    return @{
                        EndpointDlpGlobalSettings = '[{"Value":"true","Setting":"AdvancedClassificationEnabled"},{"Value":"false","Setting":"BandwidthLimitEnabled"},{"Value":"{\"FileEvidenceIsEnabled\":true,\"NumberOfDaysToRetain\":7,\"Store\":\"CustomerManaged\",\"StorageAccounts\":[{\"BlobUri\":\"https:\/\/contoso.com\",\"Name\":\"My storage\"}]}","Setting":"EvidenceStoreSettings"},{"Value":"true","Setting":"MacDefaultPathExclusionsEnabled"},{"Value":"\\\\includemenot","Setting":"PathExclusion"},{"Value":"\\\\excludemeWindows","Setting":"PathExclusion"},{"Value":"\\\\excludeme3","Setting":"PathExclusion"},{"Value":"\/pear","Setting":"MacPathExclusion"},{"Value":"\/apple","Setting":"MacPathExclusion"},{"Value":"\/orange","Setting":"MacPathExclusion"},{"Value":"Caramel","Executable":"cara.exe","Setting":"UnallowedApp"},{"Value":"ikochou","Executable":"gillex.msi","Setting":"UnallowedCloudSyncApp"},{"Value":"true","Setting":"NetworkPathEnforcementEnabled"},{"Value":"\\\\MyFirstPath:\\\\MySecondPath:\\\\MythirdPAth","Setting":"NetworkPathExclusion"},{"Value":"{\"FileReplacementText\":\"Gargamel\",\"MacQuarantinePath\":\"\/System\/Applications\/Microsoft DLP\/QuarantineMA\",\"QuarantinePath\":\"%homedrive%%homepath%\\\\Microsoft DLP\\\\Quarantine\",\"EnableQuarantineForCloudSyncApps\":false,\"ShouldReplaceFile\":true}","Setting":"QuarantineParameters"},{"Value":"True","Setting":"IncludePredefinedUnallowedBluetoothApps"},{"Value":"bluetooth","Executable":"micase.exe","Setting":"UnallowedBluetoothApp"},{"Value":"UC Browser","Executable":"ucbrowser.exe","Setting":"UnallowedBrowser"},{"Value":"contoso.net","Setting":"CloudAppRestrictionList"},{"Value":"contoso.com","Setting":"CloudAppRestrictionList"},{"Value":"Block","Setting":"CloudAppMode"},{"Value":"3","Setting":"CustomBusinessJustificationNotification"},{"Value":"[{\"Enable\":true,\"justificationText\":[\"default:Were\"],\"Id\":\"businessJustification1\"},{\"Enable\":true,\"justificationText\":[\"default:Not\"],\"Id\":\"businessJustification2\"},{\"Enable\":true,\"justificationText\":[\"default:Going\"],\"Id\":\"businessJustification3\"},{\"Enable\":true,\"justificationText\":[\"default:To\"],\"Id\":\"businessJustification4\"},{\"Enable\":true,\"justificationText\":[\"default:Take It\"],\"Id\":\"businessJustification5\"}]","Setting":"BusinessJustificationList"},{"Value":"{\u000d\u000a  \"serverAddress\": [\u000d\u000a    \"MyVPNAddress\",\u000d\u000a    \"MySecondVPNAddress\"]\u000d\u000a}","Setting":"VPNSettings"},{"Value":"true","Setting":"serverDlpEnabled"},{"Value":"true","Setting":"AuditFileActivity"}]'
                        DlpAppGroups              = '[{"Apps":[{"ExecutableName":"toc.exe","Name":"toctoctoc","Quarantine":false}],"Description":"Lacucaracha","Id":"22a9399b-d306-49c6-987d-0504316ee1c1","Name":"Maracas"}]'
                        SiteGroups                = '[{"Id":"495844da-c2ab-4511-a996-0b9a58917920","Name":"Whatever","Description":"","Addresses":[{"Url":"Karakette.com","AddressLower":"","AddressUpper":"","MatchType":"UrlMatch"}]}]'
                        DlpPrinterGroups          = '{"groups":[{"groupName":"MyGroup","groupId":"99a4cdac-cc9c-46f4-af2f-bb7201743c2a","printers":[{"name":"asdf","usbPrinter":"true","alias":"aasdf","usbPrinterPID":"","usbPrinterVID":"","ipRange":{"from":"","to":""}}]}]}'
                        DlpNetworkShareGroups     = '{"groups":[{"groupName":"Network Share Group","groupId":"edd675bb-3b5c-482e-9b17-1fcd1af36e2d","networkPaths":["\\\\share2","\\\\share"]}]}'
                        DlpRemovableMediaGroups   = '{"groups":[{"groupName":"My Removable USB device group","removableMedia":[{"deviceId":"Nik","removableMediaVID":"bob","name":"MaCles","alias":"My Device","removableMediaPID":"asdfsd","instancePathId":"instance path","serialNumberId":"asdf","hardwareId":"hardware"}],"groupId":"0883ccc3-75c1-4ab0-adb3-d4a846313618"}]}'
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCPolicyConfig' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AdvancedClassificationEnabled           = $True;
                    AuditFileActivity                       = $True; #Drift
                    BandwidthLimitEnabled                   = $False;
                    BusinessJustificationList               = @(
                        ([MSFT_PolicyConfigBusinessJustificationList] @{
                            Id                = 'businessJustification1'
                            Enable            = $True
                            justificationText = 'default:Were'
                        })
                        ([MSFT_PolicyConfigBusinessJustificationList] @{
                            Id                = 'businessJustification2'
                            Enable            = $True
                            justificationText = 'default:Not'
                        })
                        ([MSFT_PolicyConfigBusinessJustificationList] @{
                            Id                = 'businessJustification3'
                            Enable            = $True
                            justificationText = 'default:Going'
                        })
                        ([MSFT_PolicyConfigBusinessJustificationList] @{
                            Id                = 'businessJustification4'
                            Enable            = $True
                            justificationText = 'default:To'
                        })
                        ([MSFT_PolicyConfigBusinessJustificationList] @{
                            Id                = 'businessJustification5'
                            Enable            = $True
                            justificationText = 'default:Take It'
                        })
                    );
                    CloudAppMode                            = "Block";
                    CloudAppRestrictionList                 = @("contoso.net","contoso.com");
                    CustomBusinessJustificationNotification = 3;
                    DailyBandwidthLimitInMB                 = 1000;
                    DLPAppGroups                            = @(
                        ([MSFT_PolicyConfigDLPAppGroups] @{
                            Name        = 'Maracas'
                            Description = 'Lacucaracha'
                            Apps = ([MSFT_PolicyConfigDLPApp] @{
                                    ExecutableName    = 'toc.exe'
                                    Name              = 'toctoctoc'
                                    Quarantine        = $False
                                })
                        })
                    );
                    DLPNetworkShareGroups                   = @(
                        ([MSFT_PolicyConfigDLPNetworkShareGroups] @{
                            groupName    = 'Network Share Group'
                            networkPaths = @('\\share2','\\share')
                        })
                    );
                    DLPPrinterGroups                        = @(
                        ([MSFT_PolicyConfigDLPPrinterGroups] @{
                            groupName    = 'MyGroup'
                            printers = ([MSFT_PolicyConfigPrinter] @{
                                    universalPrinter = $False
                                    usbPrinter       = $True
                                    usbPrinterId     = ''
                                    name             = 'asdf'
                                    alias            = 'aasdf'
                                    usbPrinterVID    = ''
                                    ipRange          = ([MSFT_PolicyConfigIPRange] @{
                                            fromAddress = ''
                                            toAddress   = ''
                                        })
                                    corporatePrinter = $False
                                    printToLocal     = $False
                                    printToFile      = $False
                                })
                        })
                    );
                    DLPRemovableMediaGroups                 = @(
                        ([MSFT_PolicyConfigDLPRemovableMediaGroups] @{
                            groupName = 'My Removable USB device group'
                            removableMedia    = ([MSFT_PolicyConfigRemovableMedia] @{
                                    deviceId          = 'Nik'
                                    removableMediaVID = 'bob'
                                    name              = 'MaCles'
                                    alias             = 'My Device'
                                    removableMediaPID = 'asdfsd'
                                    instancePathId    = 'instance path'
                                    serialNumberId    = 'asdf'
                                    hardwareId        = 'hardware'
                                })
                        })
                    );
                    EnableLabelCoauth                       = $False;
                    EnableSpoAipMigration                   = $False;
                    EvidenceStoreSettings                   = ([MSFT_PolicyConfigEvidenceStoreSettings] @{
                            FileEvidenceIsEnabled = $True
                            NumberOfDaysToRetain  = 7
                            StorageAccounts       = @(
                            ([MSFT_PolicyConfigStorageAccount] @{
                                    Name    = 'My storage'
                                    BlobUri = 'https://contoso.com'
                                })
                            )
                            Store                 = 'CustomerManaged'
                        });
                    IncludePredefinedUnallowedBluetoothApps = $True;
                    IsSingleInstance                        = "Yes";
                    MacDefaultPathExclusionsEnabled         = $True;
                    MacPathExclusion                        = @("/pear","/apple","/orange");
                    NetworkPathEnforcementEnabled           = $True;
                    NetworkPathExclusion                    = "\\MyFirstPath:\\MySecondPath:\\MythirdPAth";
                    PathExclusion                           = @("\\includemenot","\\excludemeWindows","\\excludeme3");
                    QuarantineParameters                    = ([MSFT_PolicyConfigQuarantineParameters] @{
                            EnableQuarantineForCloudSyncApps = $False
                            QuarantinePath                   = '%homedrive%%homepath%\Microsoft DLP\Quarantine'
                            MacQuarantinePath                = '/System/Applications/Microsoft DLP/QuarantineMA'
                            ShouldReplaceFile                = $True
                            FileReplacementText              = 'Gargamel'
                        })
                    serverDlpEnabled                        = $True;
                    SiteGroups                              = @(
                        ([MSFT_PolicyConfigDLPSiteGroups] @{
                            Name      = 'Whatever'
                            Addresses = ([MSFT_PolicyConfigSiteGroupAddress] @{
                                    MatchType    = 'UrlMatch'
                                    Url          = 'Karakette.com'
                                    AddressLower = ''
                                    AddressUpper = ''
                                })
                        })
                    );
                    TenantId                                = $OrganizationName;
                    UnallowedApp                            = @(
                        ([MSFT_PolicyConfigApp] @{
                            Value        = 'Caramel'
                            Executable   = 'cara.exe'
                        })
                    );
                    UnallowedBluetoothApp                   = @(
                        ([MSFT_PolicyConfigApp] @{
                            Value        = 'bluetooth'
                            Executable   = 'micase.exe'
                        })
                    );
                    UnallowedBrowser                        = @(
                        ([MSFT_PolicyConfigApp] @{
                            Value        = 'UC Browser'
                            Executable   = 'ucbrowser.exe'
                        })
                    );
                    UnallowedCloudSyncApp                   = @(
                        ([MSFT_PolicyConfigApp] @{
                            Value        = 'ikochou'
                            Executable   = 'gillex.msi'
                        })
                    );
                    VPNSettings                             = @("MyVPNAddress","MySecondVPNAddress");
                    Credential          = $Credential;
                }

                Mock -CommandName Get-PolicyConfig -MockWith {
                    return @{
                        EndpointDlpGlobalSettings = '[{"Value":"true","Setting":"AdvancedClassificationEnabled"},{"Value":"false","Setting":"BandwidthLimitEnabled"},{"Value":"{\"FileEvidenceIsEnabled\":true,\"NumberOfDaysToRetain\":7,\"Store\":\"CustomerManaged\",\"StorageAccounts\":[{\"BlobUri\":\"https:\/\/contoso.com\",\"Name\":\"My storage\"}]}","Setting":"EvidenceStoreSettings"},{"Value":"true","Setting":"MacDefaultPathExclusionsEnabled"},{"Value":"\\\\includemenot","Setting":"PathExclusion"},{"Value":"\\\\excludemeWindows","Setting":"PathExclusion"},{"Value":"\\\\excludeme3","Setting":"PathExclusion"},{"Value":"\/pear","Setting":"MacPathExclusion"},{"Value":"\/apple","Setting":"MacPathExclusion"},{"Value":"\/orange","Setting":"MacPathExclusion"},{"Value":"fidouda","Executable":"nik.exe","Setting":"UnallowedApp"},{"Value":"Caramel","Executable":"cara.exe","Setting":"UnallowedApp"},{"Value":"Fudge","Executable":"chocolate.exe","Setting":"UnallowedApp"},{"Value":"ikochou","Executable":"gillex.msi","Setting":"UnallowedCloudSyncApp"},{"Value":"true","Setting":"NetworkPathEnforcementEnabled"},{"Value":"\\\\MyFirstPath:\\\\MySecondPath:\\\\MythirdPAth","Setting":"NetworkPathExclusion"},{"Value":"{\"FileReplacementText\":\"Gargamel\",\"MacQuarantinePath\":\"\/System\/Applications\/Microsoft DLP\/QuarantineMA\",\"QuarantinePath\":\"%homedrive%%homepath%\\\\Microsoft DLP\\\\Quarantine\",\"EnableQuarantineForCloudSyncApps\":false,\"ShouldReplaceFile\":true}","Setting":"QuarantineParameters"},{"Value":"True","Setting":"IncludePredefinedUnallowedBluetoothApps"},{"Value":"bluetooth","Executable":"micase.exe","Setting":"UnallowedBluetoothApp"},{"Value":"PatateWeb","Executable":"patate.exe","Setting":"UnallowedBrowser"},{"Value":"UC Browser","Executable":"ucbrowser.exe","Setting":"UnallowedBrowser"},{"Value":"CapitainOS","Executable":"captn.exe","Setting":"UnallowedBrowser"},{"Value":"contosodigritti.net","Setting":"CloudAppRestrictionList"},{"Value":"contosodidlidou.com","Setting":"CloudAppRestrictionList"},{"Value":"samibou.org","Setting":"CloudAppRestrictionList"},{"Value":"Block","Setting":"CloudAppMode"},{"Value":"3","Setting":"CustomBusinessJustificationNotification"},{"Value":"[{\"Enable\":true,\"justificationText\":[\"default:Were\"],\"Id\":\"businessJustification1\"},{\"Enable\":true,\"justificationText\":[\"default:Not\"],\"Id\":\"businessJustification2\"},{\"Enable\":true,\"justificationText\":[\"default:Going\"],\"Id\":\"businessJustification3\"},{\"Enable\":true,\"justificationText\":[\"default:To\"],\"Id\":\"businessJustification4\"},{\"Enable\":true,\"justificationText\":[\"default:Take It\"],\"Id\":\"businessJustification5\"}]","Setting":"BusinessJustificationList"},{"Value":"{\u000d\u000a  \"serverAddress\": [\u000d\u000a    \"MyVPNAddress\",\u000d\u000a    \"MySecondVPNAddress\",\u000d\u000a    \"DevineQui\"\u000d\u000a  ]\u000d\u000a}","Setting":"VPNSettings"},{"Value":"true","Setting":"serverDlpEnabled"},{"Value":"false","Setting":"AuditFileActivity"}]'
                        DlpAppGroups              = '[{"Apps":[{"ExecutableName":"toc.exe","Name":"toctoctoc","Quarantine":false}],"Description":"Lacucaracha","Id":"22a9399b-d306-49c6-987d-0504316ee1c1","Name":"Maracas"}]'
                        SiteGroups                = '[{"Id":"495844da-c2ab-4511-a996-0b9a58917920","Name":"Whatever","Description":"","Addresses":[{"Url":"Karakette.com","AddressLower":"","AddressUpper":"","MatchType":"UrlMatch"}]}]'
                        DlpPrinterGroups          = '{"groups":[{"groupName":"MyGroup","groupId":"99a4cdac-cc9c-46f4-af2f-bb7201743c2a","printers":[{"name":"asdf","usbPrinter":"true","alias":"aasdf"}]}]}'
                        DlpNetworkShareGroups     = '{"groups":[{"groupName":"Network Share Group","groupId":"edd675bb-3b5c-482e-9b17-1fcd1af36e2d","networkPaths":["\\\\share2","\\\\share"]}]}'
                        DlpRemovableMediaGroups   = '{"groups":[{"groupName":"My Removable USB device group","removableMedia":[{"deviceId":"Nik","removableMediaVID":"bob","name":"MaCles","alias":"My Device","removableMediaPID":"asdfsd","instancePathId":"instance path","serialNumberId":"asdf","hardwareId":"hardware"}],"groupId":"0883ccc3-75c1-4ab0-adb3-d4a846313618"}]}'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCPolicyConfig' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCPolicyConfig' -Property $testParams).Set()
                Should -Invoke -CommandName Set-PolicyConfig -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }

                Mock -CommandName Get-PolicyConfig -MockWith {
                    return @{
                        EndpointDlpGlobalSettings = '[{"Value":"true","Setting":"AdvancedClassificationEnabled"},{"Value":"false","Setting":"BandwidthLimitEnabled"},{"Value":"{\"FileEvidenceIsEnabled\":true,\"NumberOfDaysToRetain\":7,\"Store\":\"CustomerManaged\",\"StorageAccounts\":[{\"BlobUri\":\"https:\/\/contoso.com\",\"Name\":\"My storage\"}]}","Setting":"EvidenceStoreSettings"},{"Value":"true","Setting":"MacDefaultPathExclusionsEnabled"},{"Value":"\\\\includemenot","Setting":"PathExclusion"},{"Value":"\\\\excludemeWindows","Setting":"PathExclusion"},{"Value":"\\\\excludeme3","Setting":"PathExclusion"},{"Value":"\/pear","Setting":"MacPathExclusion"},{"Value":"\/apple","Setting":"MacPathExclusion"},{"Value":"\/orange","Setting":"MacPathExclusion"},{"Value":"fidouda","Executable":"nik.exe","Setting":"UnallowedApp"},{"Value":"Caramel","Executable":"cara.exe","Setting":"UnallowedApp"},{"Value":"Fudge","Executable":"chocolate.exe","Setting":"UnallowedApp"},{"Value":"ikochou","Executable":"gillex.msi","Setting":"UnallowedCloudSyncApp"},{"Value":"true","Setting":"NetworkPathEnforcementEnabled"},{"Value":"\\\\MyFirstPath:\\\\MySecondPath:\\\\MythirdPAth","Setting":"NetworkPathExclusion"},{"Value":"{\"FileReplacementText\":\"Gargamel\",\"MacQuarantinePath\":\"\/System\/Applications\/Microsoft DLP\/QuarantineMA\",\"QuarantinePath\":\"%homedrive%%homepath%\\\\Microsoft DLP\\\\Quarantine\",\"EnableQuarantineForCloudSyncApps\":false,\"ShouldReplaceFile\":true}","Setting":"QuarantineParameters"},{"Value":"True","Setting":"IncludePredefinedUnallowedBluetoothApps"},{"Value":"bluetooth","Executable":"micase.exe","Setting":"UnallowedBluetoothApp"},{"Value":"PatateWeb","Executable":"patate.exe","Setting":"UnallowedBrowser"},{"Value":"UC Browser","Executable":"ucbrowser.exe","Setting":"UnallowedBrowser"},{"Value":"CapitainOS","Executable":"captn.exe","Setting":"UnallowedBrowser"},{"Value":"contosodigritti.net","Setting":"CloudAppRestrictionList"},{"Value":"contosodidlidou.com","Setting":"CloudAppRestrictionList"},{"Value":"samibou.org","Setting":"CloudAppRestrictionList"},{"Value":"Block","Setting":"CloudAppMode"},{"Value":"3","Setting":"CustomBusinessJustificationNotification"},{"Value":"[{\"Enable\":true,\"justificationText\":[\"default:Were\"],\"Id\":\"businessJustification1\"},{\"Enable\":true,\"justificationText\":[\"default:Not\"],\"Id\":\"businessJustification2\"},{\"Enable\":true,\"justificationText\":[\"default:Going\"],\"Id\":\"businessJustification3\"},{\"Enable\":true,\"justificationText\":[\"default:To\"],\"Id\":\"businessJustification4\"},{\"Enable\":true,\"justificationText\":[\"default:Take It\"],\"Id\":\"businessJustification5\"}]","Setting":"BusinessJustificationList"},{"Value":"{\u000d\u000a  \"serverAddress\": [\u000d\u000a    \"MyVPNAddress\",\u000d\u000a    \"MySecondVPNAddress\",\u000d\u000a    \"DevineQui\"\u000d\u000a  ]\u000d\u000a}","Setting":"VPNSettings"},{"Value":"true","Setting":"serverDlpEnabled"},{"Value":"false","Setting":"AuditFileActivity"}]'
                        DlpAppGroups              = '[{"Apps":[{"ExecutableName":"toc.exe","Name":"toctoctoc","Quarantine":false}],"Description":"Lacucaracha","Id":"22a9399b-d306-49c6-987d-0504316ee1c1","Name":"Maracas"}]'
                        SiteGroups                = '[{"Id":"495844da-c2ab-4511-a996-0b9a58917920","Name":"Whatever","Description":"","Addresses":[{"Url":"Karakette.com","AddressLower":"","AddressUpper":"","MatchType":"UrlMatch"}]}]'
                        DlpPrinterGroups          = '{"groups":[{"groupName":"MyGroup","groupId":"99a4cdac-cc9c-46f4-af2f-bb7201743c2a","printers":[{"name":"asdf","usbPrinter":"true","alias":"aasdf"}]}]}'
                        DlpNetworkShareGroups     = '{"groups":[{"groupName":"Network Share Group","groupId":"edd675bb-3b5c-482e-9b17-1fcd1af36e2d","networkPaths":["\\\\share2","\\\\share"]}]}'
                        DlpRemovableMediaGroups   = '{"groups":[{"groupName":"My Removable USB device group","removableMedia":[{"deviceId":"Nik","removableMediaVID":"bob","name":"MaCles","alias":"My Device","removableMediaPID":"asdfsd","instancePathId":"instance path","serialNumberId":"asdf","hardwareId":"hardware"}],"groupId":"0883ccc3-75c1-4ab0-adb3-d4a846313618"}]}'
                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCPolicyConfig' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
