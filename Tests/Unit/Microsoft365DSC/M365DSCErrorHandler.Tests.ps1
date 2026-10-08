BeforeAll {
    Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCErrorHandler.psm1" -Force
}

Describe 'Test-M365DSCTransientError' {
    Context 'When the error is a timeout' {
        It 'Should return $true for "<Message>"' -ForEach @(
            @{ Message = 'The operation has timed out.' }
            @{ Message = 'The request timed out while connecting to the remote service.' }
            @{ Message = 'Connection timeout reached after 30 seconds.' }
            @{ Message = 'The task was canceled due to timeout.' }
        ) {
            try
            {
                throw $Message
            }
            catch
            {
                $result = Test-M365DSCTransientError -ErrorRecord $_
                $result | Should -BeTrue
            }
        }
    }

    Context 'When the error is a server error (5XX)' {
        It 'Should return $true for "<Message>"' -ForEach @(
            @{ Message = 'Response status code does not indicate success: 500 (Internal Server Error).' }
            @{ Message = 'Response status code does not indicate success: 502 (Bad Gateway).' }
            @{ Message = 'Response status code does not indicate success: 503 (Service Unavailable).' }
            @{ Message = 'Response status code does not indicate success: 504 (Gateway Timeout).' }
            @{ Message = 'The remote server returned an error: (503) Service Unavailable.' }
        ) {
            try
            {
                throw $Message
            }
            catch
            {
                $result = Test-M365DSCTransientError -ErrorRecord $_
                $result | Should -BeTrue
            }
        }
    }

    Context 'When the error is a throttling error' {
        It 'Should return $true for "<Message>"' -ForEach @(
            @{ Message = 'Response status code does not indicate success: 429 (Too Many Requests).' }
            @{ Message = 'Request was throttled. Retry after 30 seconds.' }
        ) {
            try
            {
                throw $Message
            }
            catch
            {
                $result = Test-M365DSCTransientError -ErrorRecord $_
                $result | Should -BeTrue
            }
        }
    }

    Context 'When the error is a connection failure' {
        It 'Should return $true for "<Message>"' -ForEach @(
            @{ Message = 'Unable to connect to the remote server.' }
            @{ Message = 'The underlying connection was closed: A connection that was expected to be kept alive was closed by the server.' }
            @{ Message = 'An existing connection was forcibly closed by the remote host.' }
        ) {
            try
            {
                throw $Message
            }
            catch
            {
                $result = Test-M365DSCTransientError -ErrorRecord $_
                $result | Should -BeTrue
            }
        }
    }

    Context 'When the error is NOT transient' {
        It 'Should return $false for "<Message>"' -ForEach @(
            @{ Message = 'Request_ResourceNotFound: Resource does not exist.' }
            @{ Message = 'Insufficient privileges to complete the operation.' }
            @{ Message = 'Access denied.' }
            @{ Message = 'The specified object was not found.' }
            @{ Message = 'Parameter validation failed.' }
        ) {
            try
            {
                throw $Message
            }
            catch
            {
                $result = Test-M365DSCTransientError -ErrorRecord $_
                $result | Should -BeFalse
            }
        }
    }
}

Describe 'Test-M365DSCNotFoundError' {
    Context 'When the error is a Graph "not found"' {
        It 'Should return $true for "<Message>"' -ForEach @(
            @{ Message = "[ResourceNotFound] : {`n  ""_version"": 3,`n  ""Message"": ""An error has occurred"" }" }
            @{ Message = 'Resource ''MyPolicy'' does not exist or one of its queried reference-property objects are not present.' }
            @{ Message = "Response status code does not indicate success: 404 (Not Found)." }
        ) {
            try
            {
                throw $Message
            }
            catch
            {
                $result = Test-M365DSCNotFoundError -ErrorRecord $_
                $result | Should -BeTrue
            }
        }
    }

    Context 'When the error is an Exchange "not found"' {
        It 'Should return $true for "<Message>"' -ForEach @(
            @{ Message = "The operation couldn't be completed because object 'TestDomain.com' couldn't be found on 'YOURSERVER.outlook.com'." }
            @{ Message = "The specified object was not found in the store." }
            @{ Message = "|Microsoft.Exchange.Management.Tasks.ComplianceCaseTaskException|Unable to execute the task. Reason: The compliance case ""Contoso Litigation 2026"" doesn't exist. Please create the case." }
            @{ Message = "|Microsoft.Exchange.Configuration.Tasks.ManagementObjectNotFoundException|Policy ""Litigation Hold 2026"" wasn't found.  Make sure you typed the policy name correctly." }
        ) {
            try
            {
                throw $Message
            }
            catch
            {
                $result = Test-M365DSCNotFoundError -ErrorRecord $_
                $result | Should -BeTrue
            }
        }
    }

    Context 'When the error is a SharePoint/PnP "not found"' {
        It 'Should return $true for "<Message>"' -ForEach @(
            @{ Message = 'Site Script Not Found' }
            @{ Message = 'File Not Found.' }
            @{ Message = 'Group cannot be found.' }
        ) {
            try
            {
                throw $Message
            }
            catch
            {
                $result = Test-M365DSCNotFoundError -ErrorRecord $_
                $result | Should -BeTrue
            }
        }
    }

    Context 'When the error is NOT a "not found" error' {
        It 'Should return $false for "<Message>"' -ForEach @(
            @{ Message = 'Insufficient privileges to complete the operation.' }
            @{ Message = 'Access denied.' }
            @{ Message = 'Response status code does not indicate success: 500 (Internal Server Error).' }
            @{ Message = 'The operation has timed out.' }
            @{ Message = 'The remote server returned an error: (503) Service Unavailable.' }
        ) {
            try
            {
                throw $Message
            }
            catch
            {
                $result = Test-M365DSCNotFoundError -ErrorRecord $_
                $result | Should -BeFalse
            }
        }
    }
}

Describe 'Invoke-M365DSCCommand' {
    Context 'When the scriptblock succeeds' {
        It 'Should return the result of the scriptblock' {
            $result = Invoke-M365DSCCommand -ScriptBlock { 'Hello World' }
            $result | Should -Be 'Hello World'
        }

        It 'Should return complex objects' {
            $result = Invoke-M365DSCCommand -ScriptBlock {
                @{ Name = 'Test'; Value = 42 }
            }
            $result.Name | Should -Be 'Test'
            $result.Value | Should -Be 42
        }
    }

    Context 'When the scriptblock returns $null' {
        It 'Should return $null without error' {
            $result = Invoke-M365DSCCommand -ScriptBlock { $null }
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'When a not-found error occurs with SuppressNotFoundError' {
        It 'Should return $null instead of throwing' {
            $result = Invoke-M365DSCCommand -ScriptBlock {
                throw "Request_ResourceNotFound: Resource does not exist."
            } -SuppressNotFoundError
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'When a not-found error occurs without SuppressNotFoundError' {
        It 'Should throw the error' {
            {
                Invoke-M365DSCCommand -ScriptBlock {
                    throw "Request_ResourceNotFound: Resource does not exist."
                }
            } | Should -Throw '*Request_ResourceNotFound*'
        }
    }

    Context 'When a not-found error occurs with RetryOnNotFoundError' {
        It 'Should not throw the error if limit is not reached' {
            {
                $Script:limit = 1
                $Script:count = 0
                $baseDelay = 0
                Invoke-M365DSCCommand -ScriptBlock {
                    $Script:count++
                    if ($Script:count -le $Script:limit)
                    {
                        throw "Request_ResourceNotFound: Resource does not exist. Attempt $Script:count of $Script:limit."
                    }
                    return "Success on attempt $Script:count"
                } -RetryOnNotFoundError -BaseDelayInSeconds $baseDelay
            } | Should -Not -Throw
        }

        It 'Should throw the error if the limit is reached' {
            {
                $baseDelay = 0
                Invoke-M365DSCCommand -ScriptBlock {
                    throw "Request_ResourceNotFound: Resource does not exist."
                } -RetryOnNotFoundError -BaseDelayInSeconds $baseDelay -MaxRetries 2
            } | Should -Throw '*Request_ResourceNotFound*'
        }
    }

    Context 'When a transient error occurs and then succeeds' {
        It 'Should retry and return the result' {
            $script:callCount = 0
            $result = Invoke-M365DSCCommand -ScriptBlock {
                $script:callCount++
                if ($script:callCount -eq 1)
                {
                    throw 'The operation has timed out.'
                }
                'Success after retry'
            } -BaseDelayInSeconds 0
            $result | Should -Be 'Success after retry'
            $script:callCount | Should -Be 2
        }
    }

    Context 'When a transient error persists beyond max retries' {
        It 'Should throw after exhausting retries' {
            {
                Invoke-M365DSCCommand -ScriptBlock {
                    throw 'Response status code does not indicate success: 503 (Service Unavailable).'
                } -MaxRetries 2 -BaseDelayInSeconds 0
            } | Should -Throw '*503*Service Unavailable*'
        }
    }

    Context 'When a permanent error occurs' {
        It 'Should throw immediately without retrying' {
            $script:callCount = 0
            {
                Invoke-M365DSCCommand -ScriptBlock {
                    $script:callCount++
                    throw 'Insufficient privileges to complete the operation.'
                } -BaseDelayInSeconds 0
            } | Should -Throw '*Insufficient privileges*'
            $script:callCount | Should -Be 1
        }
    }

    Context 'When multiple transient errors occur before success' {
        It 'Should retry multiple times and succeed' {
            $script:callCount = 0
            $result = Invoke-M365DSCCommand -ScriptBlock {
                $script:callCount++
                if ($script:callCount -le 2)
                {
                    throw 'The operation has timed out.'
                }
                'Finally succeeded'
            } -MaxRetries 3 -BaseDelayInSeconds 0
            $result | Should -Be 'Finally succeeded'
            $script:callCount | Should -Be 3
        }
    }
}

Describe 'Wait-M365DSCCondition' {
    BeforeAll {
        Mock -CommandName Start-Sleep -ModuleName M365DSCErrorHandler -MockWith {}
    }

    Context 'When the condition is met' {
        It 'Should return $true without sleeping when met on the first attempt' {
            $script:callCount = 0
            $result = Wait-M365DSCCondition -Description 'object' -ScriptBlock {
                $script:callCount++
                $true
            }
            $result | Should -BeTrue
            $script:callCount | Should -Be 1
            Should -Invoke -CommandName Start-Sleep -ModuleName M365DSCErrorHandler -Exactly 0
        }

        It 'Should reset the count after an unmet result and require consecutive met results' {
            $script:results = @($true, $false, $true, $true)
            $script:callCount = 0
            $result = Wait-M365DSCCondition -Description 'object' -ConsecutiveCount 2 -RetryDelayInSeconds 3 -ScriptBlock {
                $script:results[$script:callCount++]
            }
            $result | Should -BeTrue
            $script:callCount | Should -Be 4
            Should -Invoke -CommandName Start-Sleep -ModuleName M365DSCErrorHandler -Exactly 1 -ParameterFilter { $Seconds -eq 3 }
        }
    }

    Context 'When the condition is never met' {
        It 'Should return $false after the maximum attempts' {
            $script:callCount = 0
            $result = Wait-M365DSCCondition -Description 'object' -MaxAttempts 3 -ScriptBlock {
                $script:callCount++
                $null
            }
            $result | Should -BeFalse
            $script:callCount | Should -Be 3
            Should -Invoke -CommandName Start-Sleep -ModuleName M365DSCErrorHandler -Exactly 2
        }
    }
}

Describe 'Save-M365DSCPartialExport' {
    BeforeAll {
        Import-Module "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCDllLoader.psm1" -Force -Global
        Initialize-M365DSCDllLoader
        $Script:ErrorHandlerPath = (Resolve-Path -Path "$PSScriptRoot/../../../Modules/Microsoft365DSC/Modules/M365DSCErrorHandler.psm1").Path
    }

    It 'keeps every instance written concurrently by several runspaces' {
        $fileName = "$(New-Guid).partial.ps1"
        $filePath = Join-Path -Path $env:TEMP -ChildPath $fileName
        $workers = foreach ($worker in 1..4)
        {
            $powershell = [System.Management.Automation.PowerShell]::Create()
            $null = $powershell.AddScript({
                    param ($ModulePath, $FileName, $Worker)
                    Import-Module $ModulePath
                    foreach ($instance in 1..50)
                    {
                        Save-M365DSCPartialExport -Content "worker $Worker instance $instance`r`n" -FileName $FileName
                    }
                }).AddArgument($Script:ErrorHandlerPath).AddArgument($fileName).AddArgument($worker)
            [pscustomobject]@{ PowerShell = $powershell; Handle = $powershell.BeginInvoke() }
        }

        try
        {
            foreach ($entry in $workers)
            {
                $entry.PowerShell.EndInvoke($entry.Handle)
                $entry.PowerShell.Streams.Error | Should -BeNullOrEmpty
            }

            $lines = @(Get-Content -Path $filePath)
            $lines.Count | Should -Be 200
            @($lines | Sort-Object -Unique).Count | Should -Be 200
        }
        finally
        {
            $workers | ForEach-Object -Process { $_.PowerShell.Dispose() }
            Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue
        }
    }
}
