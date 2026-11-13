BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
    Initialize-M365DSCDllLoader
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Microsoft365DSC.psd1" -Global

    if (-not (Test-Path -Path 'Function:\Invoke-MgGraphRequest'))
    {
        Import-Module -Name "$PSScriptRoot/../Stubs/Microsoft365.psm1" -Function 'Invoke-MgGraphRequest' -Global -WarningAction SilentlyContinue
    }

    $Script:DefinedStubs = @()

    function global:Invoke-M365DSCTestMgxBatch
    {
        [CmdletBinding()]
        param (
            [Parameter(ValueFromPipeline = $true)]
            $InputObject,

            [System.String]
            $ApiVersion,

            [switch]
            $FollowNextLink
        )

        process
        {
            foreach ($errorId in $global:M365DSCTestMgxErrorIds)
            {
                if ($errorId -eq 'BatchItemError' -and $InputObject.Id -ne '2')
                {
                    continue
                }
                Write-Error -Message "$errorId for $($InputObject.Id)" -ErrorId $errorId
            }
            if ($InputObject.Id -ne $global:M365DSCTestMgxDroppedId)
            {
                @{ Id = $InputObject.Id; Status = 200; Body = @{ value = @() }; Url = $InputObject.Url }
            }
        }
    }
    $Script:DefinedStubs += 'Invoke-M365DSCTestMgxBatch'

    function global:New-M365DSCTestBatchRequests
    {
        param ([System.Int32] $Count)

        $requests = @()
        for ($n = 1; $n -le $Count; $n++)
        {
            $requests += @{ id = [System.String] $n; method = 'GET'; url = "/users/$n" }
        }
        return , $requests
    }
    $Script:DefinedStubs += 'New-M365DSCTestBatchRequests'
}

AfterAll {
    foreach ($stubName in $Script:DefinedStubs)
    {
        Remove-Item -Path "Function:\global:$stubName" -ErrorAction SilentlyContinue
    }
    Remove-Variable -Name 'M365DSCTestBatchState', 'M365DSCTestMgxErrorIds', 'M365DSCTestMgxDroppedId' -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Resolve-M365DSCBatchResponsePaging' {
    BeforeEach {
        Mock -ModuleName M365DSCUtil -CommandName Write-Warning
    }

    It 'merges every page into the value collection' {
        Mock -ModuleName M365DSCUtil -CommandName Invoke-MgGraphRequest -MockWith {
            if ($Uri -eq 'page2')
            {
                return @{ value = @(@{ id = 'b' }); '@odata.nextLink' = 'page3' }
            }
            return @{ value = @(@{ id = 'c' }) }
        }

        $response = @{ id = '1'; status = 200; body = @{ value = @(@{ id = 'a' }); '@odata.nextLink' = 'page2' } }
        InModuleScope -ModuleName M365DSCUtil -Parameters @{ Response = $response } {
            param ($Response)
            Resolve-M365DSCBatchResponsePaging -Response $Response
        }

        $response.body.value.id | Should -Be @('a', 'b', 'c')
        $response.ContainsKey('pagingIncomplete') | Should -BeFalse
    }

    It 'keeps the pages already read and flags the response when a page fails' {
        Mock -ModuleName M365DSCUtil -CommandName Invoke-MgGraphRequest -MockWith {
            if ($Uri -eq 'page2')
            {
                return @{ value = @(@{ id = 'b' }); '@odata.nextLink' = 'page3' }
            }
            throw 'Response status code does not indicate success: TooManyRequests.'
        }

        $response = @{ id = '1'; status = 200; body = @{ value = @(@{ id = 'a' }); '@odata.nextLink' = 'page2' } }
        {
            InModuleScope -ModuleName M365DSCUtil -Parameters @{ Response = $response } {
                param ($Response)
                Resolve-M365DSCBatchResponsePaging -Response $Response
            }
        } | Should -Not -Throw

        $response.body.value.id | Should -Be @('a', 'b')
        $response.pagingIncomplete | Should -BeTrue
        Should -Invoke -ModuleName M365DSCUtil -CommandName Write-Warning -Times 1 -Exactly -ParameterFilter {
            $Message -like 'Paging stopped at page3*TooManyRequests*'
        }
    }

    It 'tolerates a first or next page without a value array' {
        Mock -ModuleName M365DSCUtil -CommandName Invoke-MgGraphRequest -MockWith {
            return @{ '@odata.nextLink' = $null }
        }

        $response = @{ id = '1'; status = 200; body = @{ value = $null; '@odata.nextLink' = 'page2' } }
        {
            InModuleScope -ModuleName M365DSCUtil -Parameters @{ Response = $response } {
                param ($Response)
                Resolve-M365DSCBatchResponsePaging -Response $Response
            }
        } | Should -Not -Throw

        @($response.body.value).Count | Should -Be 0
    }
}

Describe 'Invoke-M365DSCLegacyBatchRequest' {
    BeforeEach {
        Mock -ModuleName M365DSCUtil -CommandName Write-Warning
        Mock -ModuleName M365DSCUtil -CommandName Start-Sleep
        $global:M365DSCTestBatchState = @{
            Sent           = @()
            ThrottledIds   = @()
            ThrottleRounds = 0
            RetryAfter     = $null
            EmptyFromCall  = 0
        }

        # Answers 200 for every sub-request, except the configured ids for the configured number of calls
        Mock -ModuleName M365DSCUtil -CommandName Invoke-MgGraphRequest -ParameterFilter { $Method -eq 'POST' } -MockWith {
            $state = $global:M365DSCTestBatchState
            $payload = $Body | ConvertFrom-Json
            $ids = @($payload.requests | ForEach-Object -Process { [System.String] $_.id })
            $state.Sent += , $ids
            if ($state.EmptyFromCall -gt 0 -and $state.Sent.Count -ge $state.EmptyFromCall)
            {
                return @{}
            }
            $throttle = $state.ThrottleRounds -gt 0
            $state.ThrottleRounds--

            $responses = @()
            foreach ($id in $ids)
            {
                if ($throttle -and $state.ThrottledIds -contains $id)
                {
                    $headers = @{}
                    if ($null -ne $state.RetryAfter)
                    {
                        $headers['Retry-After'] = $state.RetryAfter
                    }
                    $responses += @{ id = $id; status = 429; headers = $headers }
                }
                else
                {
                    $responses += @{ id = $id; status = 200; body = @{ value = @(@{ id = "item$id" }) } }
                }
            }
            return @{ responses = $responses }
        }
    }

    It 'retries only the throttled sub-requests of the first window and keeps the rest' {
        $global:M365DSCTestBatchState.ThrottledIds = @('3', '7')
        $global:M365DSCTestBatchState.ThrottleRounds = 1

        $requests = New-M365DSCTestBatchRequests -Count 25
        $result = InModuleScope -ModuleName M365DSCUtil -Parameters @{ Requests = $requests } {
            param ($Requests)
            Invoke-M365DSCLegacyBatchRequest -Requests $Requests
        }

        $result.Count | Should -Be 25
        @($result | ForEach-Object -Process { $_.id } | Sort-Object -Property { [System.Int32] $_ }) | Should -Be @(1..25 | ForEach-Object -Process { [System.String] $_ })
        @($result | Where-Object -FilterScript { $_.status -ne 200 }).Count | Should -Be 0

        $sent = $global:M365DSCTestBatchState.Sent
        $sent[0].Count | Should -Be 20
        $sent[1] | Should -Be @('3', '7')
        # The batch size is halved for the windows after the throttled request
        $sent[2] | Should -Be @('21', '22', '23', '24', '25')
        Should -Invoke -ModuleName M365DSCUtil -CommandName Start-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -eq 5 }
    }

    It 'stops after five retries with exponential backoff and returns the throttled row' {
        $global:M365DSCTestBatchState.ThrottledIds = @('2')
        $global:M365DSCTestBatchState.ThrottleRounds = 100

        $requests = New-M365DSCTestBatchRequests -Count 3
        $result = InModuleScope -ModuleName M365DSCUtil -Parameters @{ Requests = $requests } {
            param ($Requests)
            Invoke-M365DSCLegacyBatchRequest -Requests $Requests
        }

        $result.Count | Should -Be 3
        ($result | Where-Object -FilterScript { $_.id -eq '2' }).status | Should -Be 429
        $global:M365DSCTestBatchState.Sent.Count | Should -Be 6
        foreach ($delay in @(5, 10, 20, 40, 80))
        {
            Should -Invoke -ModuleName M365DSCUtil -CommandName Start-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -eq $delay }
        }
        Should -Invoke -ModuleName M365DSCUtil -CommandName Write-Warning -Times 1 -Exactly -ParameterFilter {
            $Message -like 'Throttling persisted after 5 retries*2*'
        }
    }

    It 'waits for the Retry-After header when the sub-response carries one' {
        $global:M365DSCTestBatchState.ThrottledIds = @('1')
        $global:M365DSCTestBatchState.ThrottleRounds = 1
        $global:M365DSCTestBatchState.RetryAfter = '17'

        $requests = New-M365DSCTestBatchRequests -Count 2
        $result = InModuleScope -ModuleName M365DSCUtil -Parameters @{ Requests = $requests } {
            param ($Requests)
            Invoke-M365DSCLegacyBatchRequest -Requests $Requests
        }

        $result.Count | Should -Be 2
        Should -Invoke -ModuleName M365DSCUtil -CommandName Start-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -eq 17 }
    }

    It 'returns the throttled rows when the retry call returns no responses' {
        $global:M365DSCTestBatchState.ThrottledIds = @('19', '20')
        $global:M365DSCTestBatchState.ThrottleRounds = 1
        $global:M365DSCTestBatchState.EmptyFromCall = 2

        $requests = New-M365DSCTestBatchRequests -Count 20
        $result = InModuleScope -ModuleName M365DSCUtil -Parameters @{ Requests = $requests } {
            param ($Requests)
            Invoke-M365DSCLegacyBatchRequest -Requests $Requests
        }

        $result.Count | Should -Be 20
        @($result | Where-Object -FilterScript { $_.status -eq 429 } | ForEach-Object -Process { $_.id }) | Should -Be @('19', '20')
        $global:M365DSCTestBatchState.Sent.Count | Should -Be 2
        Should -Invoke -ModuleName M365DSCUtil -CommandName Write-Warning -Times 1 -Exactly -ParameterFilter {
            $Message -like 'Batch retry returned no responses*19, 20*'
        }
    }

    It 'returns nothing extra when the first call returns no responses' {
        $global:M365DSCTestBatchState.EmptyFromCall = 1

        $requests = New-M365DSCTestBatchRequests -Count 3
        $result = InModuleScope -ModuleName M365DSCUtil -Parameters @{ Requests = $requests } {
            param ($Requests)
            Invoke-M365DSCLegacyBatchRequest -Requests $Requests
        }

        $result.Count | Should -Be 0
        Should -Invoke -ModuleName M365DSCUtil -CommandName Write-Warning -Times 0 -Exactly -ParameterFilter {
            $Message -like 'Batch retry returned no responses*'
        }
        Should -Invoke -ModuleName M365DSCUtil -CommandName Write-Warning -Times 1 -Exactly -ParameterFilter {
            $Message -like 'Batch request returned no responses. Skipping batch sub-requests: 1, 2, 3.'
        }
    }
}

Describe 'Invoke-M365DSCMgxBatchRequest' {
    BeforeEach {
        Mock -ModuleName M365DSCUtil -CommandName Write-Warning
        $global:M365DSCTestMgxErrorIds = @()
        $global:M365DSCTestMgxDroppedId = $null
    }

    It 'warns about batch-level failures but not about per-item or paging errors' {
        $global:M365DSCTestMgxErrorIds = @('BatchItemError', 'BatchItemNotSent', 'BatchPagingFailed', 'BatchChunkFailed')
        $requests = New-M365DSCTestBatchRequests -Count 2

        $result = InModuleScope -ModuleName M365DSCUtil -Parameters @{ Requests = $requests; BatchCommand = (Get-Command -Name 'Invoke-M365DSCTestMgxBatch') } {
            param ($Requests, $BatchCommand)
            Invoke-M365DSCMgxBatchRequest -Requests $Requests -BatchCommand $BatchCommand
        }

        $result.Count | Should -Be 2
        Should -Invoke -ModuleName M365DSCUtil -CommandName Write-Warning -Times 2 -Exactly
        Should -Invoke -ModuleName M365DSCUtil -CommandName Write-Warning -Times 2 -Exactly -ParameterFilter {
            $Message -like 'Batch request failed: BatchChunkFailed*'
        }
    }

    It 'reports the request ids that returned no row' {
        $global:M365DSCTestMgxDroppedId = '2'
        $requests = New-M365DSCTestBatchRequests -Count 3
        Mock -ModuleName M365DSCUtil -CommandName Write-Verbose

        $result = InModuleScope -ModuleName M365DSCUtil -Parameters @{ Requests = $requests; BatchCommand = (Get-Command -Name 'Invoke-M365DSCTestMgxBatch') } {
            param ($Requests, $BatchCommand)
            Invoke-M365DSCMgxBatchRequest -Requests $Requests -BatchCommand $BatchCommand
        }

        $result.Count | Should -Be 2
        Should -Invoke -ModuleName M365DSCUtil -CommandName Write-Verbose -Times 1 -Exactly -ParameterFilter {
            $Message -eq 'Batch sub-requests without a response: 2'
        }
    }
}
