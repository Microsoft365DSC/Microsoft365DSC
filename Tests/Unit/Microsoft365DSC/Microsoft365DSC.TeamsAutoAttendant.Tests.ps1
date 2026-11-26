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
    -DscResource 'TeamsAutoAttendant' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            function Get-MockPrincipalTable
            {
                return @{
                    'AdeleV@contoso.onmicrosoft.com'    = 'e8b5a2c4-6f1d-4d3a-9b7e-2c4f8a1d3b5e'
                    'AlexW@contoso.onmicrosoft.com'     = '9e4f7b2d-3a1c-4d8e-b5f6-2c7a9e1d4b8f'
                    'salesqueue@contoso.onmicrosoft.com' = '3f9d1c7a-2b8e-4a6f-9d1c-7e5b3a2f8c4d'
                    'mainline@contoso.onmicrosoft.com'  = '7c2e9a4b-5d3f-4e1a-8b6c-9f2d4a7e1c3b'
                    'frontdesk@contoso.onmicrosoft.com' = '5a8d3e1f-9c2b-4f7a-a6e4-1b9c8d2f5e7a'
                }
            }

            function New-MockAutoAttendant
            {
                return [PSCustomObject] @{
                    Identity                                = 'b4c7e2a9-1d3f-4a6b-8e5c-2f9d7a1b3c6e'
                    Name                                    = 'Contoso Main Line'
                    LanguageId                              = 'en-US'
                    TimeZoneId                              = 'Pacific Standard Time'
                    VoiceId                                 = 'Female'
                    VoiceResponseEnabled                    = $true
                    UserNameExtension                       = 'None'
                    MainlineAttendantEnabled                = $false
                    MainlineAttendantAgentVoiceId           = $null
                    AutoRecordingTemplateId                 = $null
                    SpamDetectionTemplateId                 = $null
                    SharedVoicemailTriageSettingsTemplateId = '4e7a1c9d-3b6f-4d2a-8e5c-1f9b7a3d6c2e'
                    DefaultCallFlow                         = [PSCustomObject] @{
                        Id                     = 'd2a6f9c1-4b8e-4d3a-9c7f-1e5b2a8d4c6f'
                        Name                   = 'Business hours'
                        ForceListenMenuEnabled = $false
                        Greetings              = @(
                            [PSCustomObject] @{
                                ActiveType         = 'TextToSpeech'
                                TextToSpeechPrompt = 'Thank you for calling Contoso.'
                            }
                        )
                        Menu                   = [PSCustomObject] @{
                            Name                  = 'Main menu'
                            DialByNameEnabled     = $true
                            DirectorySearchMethod = 'ByName'
                            Prompts               = @(
                                [PSCustomObject] @{
                                    ActiveType      = 'AudioFile'
                                    AudioFilePrompt = [PSCustomObject] @{
                                        Id       = '6e1b4d8a-2c7f-4a9e-b3d5-8f2a6c1e9b4d'
                                        FileName = 'MainMenu.wav'
                                    }
                                }
                            )
                            MenuOptions           = @(
                                [PSCustomObject] @{
                                    Action         = 'TransferCallToTarget'
                                    DtmfResponse   = 'Tone1'
                                    VoiceResponses = @('Reception')
                                    CallTarget     = [PSCustomObject] @{
                                        Id   = 'e8b5a2c4-6f1d-4d3a-9b7e-2c4f8a1d3b5e'
                                        Type = 'User'
                                    }
                                }
                                [PSCustomObject] @{
                                    Action       = 'TransferCallToTarget'
                                    DtmfResponse = 'Tone2'
                                    Description  = 'Sales'
                                    CallTarget   = [PSCustomObject] @{
                                        Id           = '3f9d1c7a-2b8e-4a6f-9d1c-7e5b3a2f8c4d'
                                        Type         = 'ApplicationEndpoint'
                                        CallPriority = 2
                                    }
                                }
                            )
                        }
                    }
                    CallFlows                               = @(
                        [PSCustomObject] @{
                            Id                     = 'a9c3e7f1-5b2d-4e8a-9f6c-3d1b7e4a2c8f'
                            Name                   = 'After hours'
                            ForceListenMenuEnabled = $false
                            Greetings              = @(
                                [PSCustomObject] @{
                                    ActiveType         = 'TextToSpeech'
                                    TextToSpeechPrompt = 'Our offices are closed.'
                                }
                            )
                            Menu                   = [PSCustomObject] @{
                                Name                  = 'After hours menu'
                                DialByNameEnabled     = $false
                                DirectorySearchMethod = 'None'
                                MenuOptions           = @(
                                    [PSCustomObject] @{
                                        Action       = 'DisconnectCall'
                                        DtmfResponse = 'Automatic'
                                    }
                                )
                            }
                        }
                    )
                    CallHandlingAssociations                = @(
                        [PSCustomObject] @{
                            Type       = 'AfterHours'
                            ScheduleId = 'c5f8a2d6-9e3b-4c1f-a7d4-6b2e9f1c5a8d'
                            CallFlowId = 'a9c3e7f1-5b2d-4e8a-9f6c-3d1b7e4a2c8f'
                            Enabled    = $true
                        }
                    )
                    Schedules                               = @(
                        [PSCustomObject] @{
                            Id   = 'c5f8a2d6-9e3b-4c1f-a7d4-6b2e9f1c5a8d'
                            Name = 'Contoso Business Hours'
                        }
                    )
                    Operator                                = [PSCustomObject] @{
                        Id   = 'e8b5a2c4-6f1d-4d3a-9b7e-2c4f8a1d3b5e'
                        Type = 'User'
                    }
                    DirectoryLookupScope                    = [PSCustomObject] @{
                        InclusionScope = [PSCustomObject] @{
                            GroupScope = [PSCustomObject] @{
                                GroupIds = @('2d7f4b9e-8a1c-4e6d-b3f5-9c2a7e4d1b8f')
                            }
                        }
                        ExclusionScope = $null
                    }
                    AuthorizedUsers                         = @([System.Guid] '9e4f7b2d-3a1c-4d8e-b5f6-2c7a9e1d4b8f')
                    HideAuthorizedUsers                     = @()
                    ApplicationInstances                    = @('7c2e9a4b-5d3f-4e1a-8b6c-9f2d4a7e1c3b')
                }
            }

            function New-DesiredParameters
            {
                return @{
                    Name                                    = 'Contoso Main Line'
                    LanguageId                              = 'en-US'
                    TimeZoneId                              = 'Pacific Standard Time'
                    VoiceId                                 = 'Female'
                    EnableVoiceResponse                     = $true
                    UserNameExtension                       = 'None'
                    SharedVoicemailTriageSettingsTemplateId = '4e7a1c9d-3b6f-4d2a-8e5c-1f9b7a3d6c2e'
                    DefaultCallFlow                         = [MSFT_TeamsAutoAttendantCallFlow] @{
                        Name                   = 'Business hours'
                        ForceListenMenuEnabled = $false
                        Greetings              = @(
                            [MSFT_TeamsAutoAttendantPrompt] @{
                                ActiveType         = 'TextToSpeech'
                                TextToSpeechPrompt = 'Thank you for calling Contoso.'
                            }
                        )
                        Menu                   = [MSFT_TeamsAutoAttendantMenu] @{
                            Name                  = 'Main menu'
                            EnableDialByName      = $true
                            DirectorySearchMethod = 'ByName'
                            Prompts               = @(
                                [MSFT_TeamsAutoAttendantPrompt] @{
                                    ActiveType              = 'AudioFile'
                                    AudioFilePromptId       = '6e1b4d8a-2c7f-4a9e-b3d5-8f2a6c1e9b4d'
                                    AudioFilePromptFileName = 'MainMenu.wav'
                                }
                            )
                            MenuOptions           = @(
                                [MSFT_TeamsAutoAttendantMenuOption] @{
                                    Action         = 'TransferCallToTarget'
                                    DtmfResponse   = 'Tone1'
                                    VoiceResponses = @('Reception')
                                    CallTarget     = [MSFT_TeamsAutoAttendantCallableEntity] @{
                                        Identity = 'AdeleV@contoso.onmicrosoft.com'
                                        Type     = 'User'
                                    }
                                }
                                [MSFT_TeamsAutoAttendantMenuOption] @{
                                    Action       = 'TransferCallToTarget'
                                    DtmfResponse = 'Tone2'
                                    Description  = 'Sales'
                                    CallTarget   = [MSFT_TeamsAutoAttendantCallableEntity] @{
                                        Identity     = 'salesqueue@contoso.onmicrosoft.com'
                                        Type         = 'ApplicationEndpoint'
                                        CallPriority = 2
                                    }
                                }
                            )
                        }
                    }
                    CallFlows                               = @(
                        [MSFT_TeamsAutoAttendantCallFlow] @{
                            Name                   = 'After hours'
                            ForceListenMenuEnabled = $false
                            Greetings              = @(
                                [MSFT_TeamsAutoAttendantPrompt] @{
                                    ActiveType         = 'TextToSpeech'
                                    TextToSpeechPrompt = 'Our offices are closed.'
                                }
                            )
                            Menu                   = [MSFT_TeamsAutoAttendantMenu] @{
                                Name                  = 'After hours menu'
                                EnableDialByName      = $false
                                DirectorySearchMethod = 'None'
                                MenuOptions           = @(
                                    [MSFT_TeamsAutoAttendantMenuOption] @{
                                        Action       = 'DisconnectCall'
                                        DtmfResponse = 'Automatic'
                                    }
                                )
                            }
                        }
                    )
                    CallHandlingAssociations                = @(
                        [MSFT_TeamsAutoAttendantCallHandlingAssociation] @{
                            Type         = 'AfterHours'
                            ScheduleName = 'Contoso Business Hours'
                            CallFlowName = 'After hours'
                            Enabled      = $true
                        }
                    )
                    Operator                                = [MSFT_TeamsAutoAttendantCallableEntity] @{
                        Identity = 'AdeleV@contoso.onmicrosoft.com'
                        Type     = 'User'
                    }
                    InclusionScopeGroupIds                  = @('2d7f4b9e-8a1c-4e6d-b3f5-9c2a7e4d1b8f')
                    AuthorizedUsers                         = @('AlexW@contoso.onmicrosoft.com')
                    ApplicationInstances                    = @('mainline@contoso.onmicrosoft.com')
                    Ensure                                  = 'Present'
                    Credential                              = $Credential
                }
            }

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

            Mock -CommandName Get-CsAutoAttendant -MockWith {
                return New-MockAutoAttendant
            }

            Mock -CommandName Get-CsOnlineUser -MockWith {
                $principals = Get-MockPrincipalTable
                foreach ($principalName in $principals.Keys)
                {
                    if ($Identity -eq $principalName -or $Identity -eq $principals[$principalName])
                    {
                        return [PSCustomObject] @{
                            Identity          = $principals[$principalName]
                            UserPrincipalName = $principalName
                        }
                    }
                }

                return $null
            }

            Mock -CommandName Get-CsOnlineSchedule -MockWith {
                return @(
                    [PSCustomObject] @{
                        Id   = 'c5f8a2d6-9e3b-4c1f-a7d4-6b2e9f1c5a8d'
                        Name = 'Contoso Business Hours'
                    }
                )
            }

            Mock -CommandName Get-CsOnlineAudioFile -MockWith {
                return [PSCustomObject] @{
                    Id       = $Identity
                    FileName = 'MainMenu.wav'
                }
            }

            Mock -CommandName New-CsAutoAttendantPrompt -MockWith {
                return [PSCustomObject] @{
                    ActiveType         = $ActiveType
                    TextToSpeechPrompt = $TextToSpeechPrompt
                    AudioFilePrompt    = $AudioFilePrompt
                }
            }

            Mock -CommandName New-CsAutoAttendantCallableEntity -MockWith {
                return [PSCustomObject] @{
                    Id           = $Identity
                    Type         = $Type
                    CallPriority = $CallPriority
                }
            }

            Mock -CommandName New-CsAutoAttendantMenuOption -MockWith {
                return [PSCustomObject] @{
                    Action         = $Action
                    DtmfResponse   = $DtmfResponse
                    VoiceResponses = $VoiceResponses
                    CallTarget     = $CallTarget
                    Prompt         = $Prompt
                    Description    = $Description
                }
            }

            Mock -CommandName New-CsAutoAttendantMenu -MockWith {
                return [PSCustomObject] @{
                    Name                  = $Name
                    Prompts               = $Prompts
                    MenuOptions           = $MenuOptions
                    DialByNameEnabled     = [System.Boolean] $EnableDialByName
                    DirectorySearchMethod = $DirectorySearchMethod
                }
            }

            Mock -CommandName New-CsAutoAttendantCallFlow -MockWith {
                return [PSCustomObject] @{
                    Id                     = (New-Guid).ToString()
                    Name                   = $Name
                    Menu                   = $Menu
                    Greetings              = $Greetings
                    ForceListenMenuEnabled = [System.Boolean] $ForceListenMenuEnabled
                }
            }

            Mock -CommandName New-CsAutoAttendantCallHandlingAssociation -MockWith {
                return [PSCustomObject] @{
                    Type       = $Type
                    ScheduleId = $ScheduleId
                    CallFlowId = $CallFlowId
                    Enabled    = -not $Disable
                }
            }

            Mock -CommandName New-CsAutoAttendantDialScope -MockWith {
                return [PSCustomObject] @{
                    GroupScope = [PSCustomObject] @{
                        GroupIds = $GroupIds
                    }
                }
            }

            Mock -CommandName New-CsAutoAttendant -MockWith {
                return [PSCustomObject] @{
                    Identity          = 'b4c7e2a9-1d3f-4a6b-8e5c-2f9d7a1b3c6e'
                    Name              = $Name
                    UserNameExtension = $null
                }
            }

            Mock -CommandName Set-CsAutoAttendant -MockWith {
            }

            Mock -CommandName Remove-CsAutoAttendant -MockWith {
            }

            Mock -CommandName New-CsOnlineApplicationInstanceAssociation -MockWith {
            }

            Mock -CommandName Remove-CsOnlineApplicationInstanceAssociation -MockWith {
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                return @{}
            }

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
                return "TeamsAutoAttendant 'TestInstance' {}`r`n"
            }

            $Script:exportedInstance = $null
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        Context -Name 'The instance should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = New-DesiredParameters

                Mock -CommandName Get-CsAutoAttendant -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-CsAutoAttendant'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the instance and associate the resource account from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-CsAutoAttendant' -Exactly 1 -ParameterFilter {
                    $Name -eq 'Contoso Main Line' -and
                    $CallHandlingAssociations[0].ScheduleId -eq 'c5f8a2d6-9e3b-4c1f-a7d4-6b2e9f1c5a8d' -and
                    $CallHandlingAssociations[0].CallFlowId -eq $CallFlows[0].Id -and
                    $Operator.Id -eq 'e8b5a2c4-6f1d-4d3a-9b7e-2c4f8a1d3b5e' -and
                    $AuthorizedUsers[0] -eq [System.Guid] '9e4f7b2d-3a1c-4d8e-b5f6-2c7a9e1d4b8f'
                }
                Should -Invoke -CommandName 'Get-CsOnlineAudioFile' -Exactly 1
                Should -Invoke -CommandName 'New-CsOnlineApplicationInstanceAssociation' -Exactly 1 -ParameterFilter {
                    $Identities -contains '7c2e9a4b-5d3f-4e1a-8b6c-9f2d4a7e1c3b' -and
                    $ConfigurationId -eq 'b4c7e2a9-1d3f-4a6b-8e5c-2f9d7a1b3c6e'
                }
                Should -Invoke -CommandName 'Set-CsAutoAttendant' -Exactly 1 -ParameterFilter {
                    $Instance.UserNameExtension -eq $testParams.UserNameExtension
                }
            }

            It 'Should throw the call target error from the Set method when a call target cannot be created' {
                Mock -CommandName New-CsAutoAttendantCallableEntity -MockWith {
                    Write-Error -Message "User ($Identity) is not Enterprise Voice enabled."
                }

                { (New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Set() } |
                    Should -Throw -ExpectedMessage 'The call target {AdeleV@contoso.onmicrosoft.com} of type {User} of a Teams Auto Attendant could not be created. Error: User (e8b5a2c4-6f1d-4d3a-9b7e-2c4f8a1d3b5e) is not Enterprise Voice enabled.'
            }
        }

        Context -Name 'The instance exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Contoso Main Line'
                    Ensure     = 'Absent'
                    Credential = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-CsAutoAttendant'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-CsAutoAttendant' -Exactly 1 -ParameterFilter {
                    $Identity -eq 'b4c7e2a9-1d3f-4a6b-8e5c-2f9d7a1b3c6e'
                }
                Should -Invoke -CommandName 'Remove-CsOnlineApplicationInstanceAssociation' -Exactly 1 -ParameterFilter {
                    $Identities -contains '7c2e9a4b-5d3f-4e1a-8b6c-9f2d4a7e1c3b'
                }
            }
        }

        Context -Name 'The instance exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = New-DesiredParameters
            }

            It 'Should return the expected values from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.Name | Should -Be 'Contoso Main Line'
                $result.LanguageId | Should -Be 'en-US'
                $result.TimeZoneId | Should -Be 'Pacific Standard Time'
                $result.EnableVoiceResponse | Should -Be $true
                $result.DefaultCallFlow.Greetings[0].TextToSpeechPrompt | Should -Be 'Thank you for calling Contoso.'
                $result.DefaultCallFlow.Menu.Prompts[0].AudioFilePromptId | Should -Be '6e1b4d8a-2c7f-4a9e-b3d5-8f2a6c1e9b4d'
                $result.DefaultCallFlow.Menu.MenuOptions[0].CallTarget.Identity | Should -Be 'AdeleV@contoso.onmicrosoft.com'
                $result.DefaultCallFlow.Menu.MenuOptions[1].CallTarget.Identity | Should -Be 'salesqueue@contoso.onmicrosoft.com'
                $result.DefaultCallFlow.Menu.MenuOptions[1].CallTarget.CallPriority | Should -Be 2
                $result.CallFlows[0].Name | Should -Be 'After hours'
                $result.CallHandlingAssociations[0].ScheduleName | Should -Be 'Contoso Business Hours'
                $result.CallHandlingAssociations[0].CallFlowName | Should -Be 'After hours'
                $result.CallHandlingAssociations[0].Type | Should -Be 'AfterHours'
                $result.Operator.Identity | Should -Be 'AdeleV@contoso.onmicrosoft.com'
                $result.InclusionScopeGroupIds | Should -Be @('2d7f4b9e-8a1c-4e6d-b3f5-9c2a7e4d1b8f')
                $result.AuthorizedUsers | Should -Be @('AlexW@contoso.onmicrosoft.com')
                $result.ApplicationInstances | Should -Be @('mainline@contoso.onmicrosoft.com')
                Should -Invoke -CommandName 'Get-CsAutoAttendant'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and its menu options are listed in another order' -Fixture {
            BeforeAll {
                $testParams = New-DesiredParameters
                $menuOptions = $testParams.DefaultCallFlow.Menu.MenuOptions
                $testParams.DefaultCallFlow.Menu.MenuOptions = @($menuOptions[1], $menuOptions[0])
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and one of its reordered menu options is NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = New-DesiredParameters
                $menuOptions = $testParams.DefaultCallFlow.Menu.MenuOptions
                $menuOptions[1].CallTarget.CallPriority = 4
                $testParams.DefaultCallFlow.Menu.MenuOptions = @($menuOptions[1], $menuOptions[0])
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'The instance exists and a greeting is NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = New-DesiredParameters
                $testParams.DefaultCallFlow.Greetings[0].TextToSpeechPrompt = 'Welcome to Contoso.'
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-CsAutoAttendant'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-CsAutoAttendant' -Exactly 1 -ParameterFilter {
                    $Instance.DefaultCallFlow.Greetings[0].TextToSpeechPrompt -eq 'Welcome to Contoso.' -and
                    $Instance.CallHandlingAssociations[0].CallFlowId -eq $Instance.CallFlows[0].Id
                }
                Should -Invoke -CommandName 'New-CsOnlineApplicationInstanceAssociation' -Exactly 0
                Should -Invoke -CommandName 'Remove-CsOnlineApplicationInstanceAssociation' -Exactly 0
            }
        }

        Context -Name 'The instance exists and its resource accounts are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = New-DesiredParameters
                $testParams.ApplicationInstances = @('frontdesk@contoso.onmicrosoft.com')
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should associate the desired and dissociate the obsolete resource account from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsAutoAttendant' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-CsOnlineApplicationInstanceAssociation' -Exactly 1 -ParameterFilter {
                    $Identities -contains '5a8d3e1f-9c2b-4f7a-a6e4-1b9c8d2f5e7a'
                }
                Should -Invoke -CommandName 'Remove-CsOnlineApplicationInstanceAssociation' -Exactly 1 -ParameterFilter {
                    $Identities -contains '7c2e9a4b-5d3f-4e1a-8b6c-9f2d4a7e1c3b'
                }
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsAutoAttendant' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                Should -Invoke -CommandName 'Get-CsAutoAttendant'
                Should -Invoke -CommandName 'Get-M365DSCExportContentForResource' -Exactly 1
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
