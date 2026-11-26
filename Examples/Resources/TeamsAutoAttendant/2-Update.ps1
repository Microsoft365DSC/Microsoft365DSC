<#
This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.
#>

Configuration Example
{
    param
    (
        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )

    Import-DscResource -ModuleName Microsoft365DSC

    Node localhost
    {
        TeamsAutoAttendant 'TeamsAutoAttendant-Example'
        {
            Name                          = "Contoso Main Line"
            LanguageId                    = "en-US"
            VoiceId                       = "Male" # Updated Property
            TimeZoneId                    = "Pacific Standard Time"
            EnableVoiceResponse           = $true
            DefaultCallFlow               = MSFT_TeamsAutoAttendantCallFlow{
                Name                         = "Contoso Business Hours Call Flow"
                Greetings                    = @(
                    MSFT_TeamsAutoAttendantPrompt{
                        ActiveType         = "TextToSpeech"
                        TextToSpeechPrompt = "Thank you for calling Contoso."
                    }
                )
                Menu                         = MSFT_TeamsAutoAttendantMenu{
                    Name                  = "Business hours menu"
                    Prompts               = @(
                        MSFT_TeamsAutoAttendantPrompt{
                            ActiveType         = "TextToSpeech"
                            TextToSpeechPrompt = "For reception, press 1. For sales, press 2. For our address, press 3. To reach the operator, press 0."
                        }
                    )
                    MenuOptions           = @(
                        MSFT_TeamsAutoAttendantMenuOption{
                            DtmfResponse   = "Tone1"
                            Action         = "TransferCallToTarget"
                            VoiceResponses = @("Reception")
                            Description    = "Reception"
                            CallTarget     = MSFT_TeamsAutoAttendantCallableEntity{
                                Identity = "tel:+14255550100"
                                Type     = "ExternalPstn"
                            }
                        }
                        MSFT_TeamsAutoAttendantMenuOption{
                            DtmfResponse   = "Tone2"
                            Action         = "TransferCallToTarget"
                            VoiceResponses = @("Sales")
                            Description    = "Sales"
                            CallTarget     = MSFT_TeamsAutoAttendantCallableEntity{
                                Identity     = "salesqueue@$TenantId"
                                Type         = "ApplicationEndpoint"
                                CallPriority = 2
                            }
                        }
                        MSFT_TeamsAutoAttendantMenuOption{
                            DtmfResponse   = "Tone3"
                            Action         = "Announcement"
                            VoiceResponses = @("Address")
                            Description    = "Office address"
                            Prompt         = MSFT_TeamsAutoAttendantPrompt{
                                ActiveType         = "TextToSpeech"
                                TextToSpeechPrompt = "Our office is located at 1 Microsoft Way, Redmond, Washington."
                            }
                        }
                        MSFT_TeamsAutoAttendantMenuOption{
                            DtmfResponse   = "Tone0"
                            Action         = "TransferCallToOperator"
                            Description    = "Operator"
                        }
                    )
                    EnableDialByName      = $true
                    DirectorySearchMethod = "ByName"
                }
                ForceListenMenuEnabled       = $false
                RingResourceAccountDelegates = $false
            }
            CallFlows                     = @(
                MSFT_TeamsAutoAttendantCallFlow{
                    Name                         = "Contoso After Hours Call Flow"
                    Greetings                    = @(
                        MSFT_TeamsAutoAttendantPrompt{
                            ActiveType         = "TextToSpeech"
                            TextToSpeechPrompt = "Thank you for calling Contoso. Our offices are open Monday to Friday from 9 AM to 5 PM Pacific time."
                        }
                    )
                    Menu                         = MSFT_TeamsAutoAttendantMenu{
                        Name                  = "After hours menu"
                        MenuOptions           = @(
                            MSFT_TeamsAutoAttendantMenuOption{
                                DtmfResponse = "Automatic"
                                Action       = "DisconnectCall"
                            }
                        )
                        EnableDialByName      = $false
                        DirectorySearchMethod = "None"
                    }
                    ForceListenMenuEnabled       = $false
                    RingResourceAccountDelegates = $false
                }
            )
            CallHandlingAssociations      = @(
                MSFT_TeamsAutoAttendantCallHandlingAssociation{
                    Type         = "AfterHours"
                    ScheduleName = "Contoso Business Hours"
                    CallFlowName = "Contoso After Hours Call Flow"
                    Enabled      = $true
                }
            )
            Operator                      = MSFT_TeamsAutoAttendantCallableEntity{
                Identity = "tel:+14255550100"
                Type     = "ExternalPstn"
            }
            AuthorizedUsers               = @("AlexW@$TenantId", "MeganB@$TenantId")
            HideAuthorizedUsers           = @("MeganB@$TenantId")
            UserNameExtension             = "Department"
            EnableMainlineAttendant       = $false
            ApplicationInstances          = @("mainreception@$TenantId")
            Ensure                        = "Present"
            ApplicationId                 = $ApplicationId
            TenantId                      = $TenantId
            CertificateThumbprint         = $CertificateThumbprint
        }
    }
}
