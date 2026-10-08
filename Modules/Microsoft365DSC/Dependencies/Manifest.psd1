@{
    Dependencies = @(
        @{
            ModuleName      = 'Az.Accounts'
            RequiredVersion = '5.3.2'
        },
        @{
            ModuleName      = 'Az.ResourceGraph'
            RequiredVersion = '1.2.1'
        },
        @{
            ModuleName      = 'Az.Resources'
            RequiredVersion = '9.0.1'
        },
        @{
            ModuleName      = 'Az.Subscription'
            RequiredVersion = '0.12.0'
        },
        @{
            ModuleName      = 'Az.Security'
            RequiredVersion = '1.8.0'
        },
        @{
            ModuleName      = 'Az.SecurityInsights'
            RequiredVersion = '3.2.1'
        },
        @{
            ModuleName      = 'DSCParser'
            RequiredVersion = '3.1.0.5'
        },
        @{
            ModuleName      = 'ExchangeOnlineManagement'
            RequiredVersion = '3.9.2'
        },
        @{
            ModuleName      = 'M365DSC.mgx'
            RequiredVersion = '2.1.9'
            PowerShellCore  = $true
        },
        @{
            ModuleName      = 'M365DSC.PSDesiredStateConfiguration'
            RequiredVersion = '3.1.9'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Authentication'
            RequiredVersion = '2.41.1'
        },
        @{
            ModuleName      = 'MicrosoftTeams'
            RequiredVersion = '8.0.0'
        },
        @{
            ModuleName      = "MSCloudLoginAssistant"
            RequiredVersion = "1.2.9"
        },
        @{
            ModuleName      = 'PnP.PowerShell'
            RequiredVersion = '3.4.1'
            PowerShellCore  = $true
        },
        @{
            ModuleName      = 'ReverseDSC'
            RequiredVersion = '3.0.0.0'
        },
        @{
            ModuleName      = 'PSParallelPipeline'
            RequiredVersion = '1.3.0'
        }
    )
}
