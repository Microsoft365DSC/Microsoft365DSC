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
            @{ Message = "The operation couldn't be performed because object 'Block 500 users' couldn't be found on 'EXSERVER'." }
            @{ Message = "Property 'sessionTimeoutInMinutes' is invalid." }
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

        It 'Should return $false for a 400 response whose message matches a transient pattern' {
            $exception = [System.Exception]::new('The operation has timed out.')
            $exception | Add-Member -MemberType NoteProperty -Name Response -Value ([pscustomobject]@{ StatusCode = 400 })
            $errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, 'Test', 'NotSpecified', $null)
            Test-M365DSCTransientError -ErrorRecord $errorRecord | Should -BeFalse
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
            @{ Message = "The term 'Get-CalendarProcessing' is not recognized as a name of a cmdlet, function, script file, or executable program." }
            @{ Message = 'Access denied. The requested object was not found or you do not have permission.' }
            @{ Message = 'The request failed. client-request-id: 7f3a9c2e-404b-4d1e-9a40-1c2d3e4f5a6b' }
            @{ Message = "Error on server 'AM9PR04MB4049.eurprd04.prod.outlook.com'." }
            @{ Message = "A parameter cannot be found that matches parameter name 'IncludeHidden'." }
            @{ Message = "Property 'foo' does not exist as a declared property or extension property." }
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

        It 'Should return $false for a <StatusCode> response whose message matches a not-found pattern' -ForEach @(
            @{ StatusCode = 400 }
            @{ StatusCode = 409 }
            @{ StatusCode = 429 }
            @{ StatusCode = 503 }
        ) {
            $exception = [System.Exception]::new('The resource was not found in the backend cache.')
            $exception | Add-Member -MemberType NoteProperty -Name Response -Value ([pscustomobject]@{ StatusCode = $StatusCode })
            $errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, 'Test', 'NotSpecified', $null)
            Test-M365DSCNotFoundError -ErrorRecord $errorRecord | Should -BeFalse
        }

        It 'Should return $false for local parameter binding and provider errors' {
            $errorRecords = @()
            try { Get-Date -NoSuchParameter 'x' -ErrorAction Stop } catch { $errorRecords += $_ }
            try { Get-Item -Path (Join-Path -Path $TestDrive -ChildPath 'missing.txt') -ErrorAction Stop } catch { $errorRecords += $_ }

            $errorRecords.Count | Should -Be 2
            foreach ($errorRecord in $errorRecords)
            {
                Test-M365DSCNotFoundError -ErrorRecord $errorRecord | Should -BeFalse
            }
        }
    }

    Context 'When the error contains a 404 status' {
        It 'Should return $true when the response status code is 404' {
            $exception = [System.Exception]::new('The request failed.')
            $exception | Add-Member -MemberType NoteProperty -Name Response -Value ([pscustomobject]@{ StatusCode = 404 })
            $errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, 'Test', 'NotSpecified', $null)
            Test-M365DSCNotFoundError -ErrorRecord $errorRecord | Should -BeTrue
        }

        It 'Should return $true when the error details has a 404 error' {
            try
            {
                throw 'The request failed.'
            }
            catch
            {
                $_.ErrorDetails = [System.Management.Automation.ErrorDetails]::new('{"error":{"code":"404","message":"Gone"}}')
                Test-M365DSCNotFoundError -ErrorRecord $_ | Should -BeTrue
            }
        }
    }
}

Describe 'Test-M365DSCAccessError' {
    Context 'When the error is an authentication or permission error' {
        It 'Should return $true for "<Message>"' -ForEach @(
            @{ Message = 'Response status code does not indicate success: 401 (Unauthorized).' }
            @{ Message = 'Response status code does not indicate success: 403 (Forbidden).' }
            @{ Message = 'Authorization_RequestDenied: Insufficient privileges to complete the operation.' }
            @{ Message = 'Access denied. You do not have permission to perform this action or access this resource.' }
            @{ Message = 'AADSTS7000215: Invalid client secret provided.' }
            @{ Message = "The term 'Get-CalendarProcessing' is not recognized as a name of a cmdlet, function, script file, or executable program." }
        ) {
            try
            {
                throw $Message
            }
            catch
            {
                $result = Test-M365DSCAccessError -ErrorRecord $_
                $result | Should -BeTrue
            }
        }

        It 'Should return $true when the error details carry the permission error' {
            try
            {
                throw 'The request failed.'
            }
            catch
            {
                $_.ErrorDetails = [System.Management.Automation.ErrorDetails]::new('{"error":{"code":"Authorization_RequestDenied"}}')
                $result = Test-M365DSCAccessError -ErrorRecord $_
                $result | Should -BeTrue
            }
        }
    }

    Context 'When the error is NOT an authentication or permission error' {
        It 'Should return $false for "<Message>"' -ForEach @(
            @{ Message = "The operation couldn't be performed because object 'Room1' couldn't be found." }
            @{ Message = "The value 'Unknown' is not valid for property 'CallAnswerRule'." }
            @{ Message = 'Response status code does not indicate success: 429 (Too Many Requests).' }
            @{ Message = 'The operation has timed out.' }
        ) {
            try
            {
                throw $Message
            }
            catch
            {
                $result = Test-M365DSCAccessError -ErrorRecord $_
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

        It 'Should return $null when the name of the object contains a status code' {
            $result = Invoke-M365DSCCommand -ScriptBlock {
                throw "The operation couldn't be performed because object 'Block 500 users' couldn't be found on 'EXSERVER'."
            } -SuppressNotFoundError -BaseDelayInSeconds 0
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

    Context 'When the scriptblock writes a non-terminating error' {
        BeforeEach {
            # Matches the default preference of the calling resources
            $ErrorActionPreference = 'Continue'
        }

        It 'Should return $null for a not-found error with SuppressNotFoundError' {
            $result = Invoke-M365DSCCommand -ScriptBlock {
                Write-Error -Message 'Request_ResourceNotFound: Resource does not exist.'
                'should not be returned'
            } -SuppressNotFoundError
            $result | Should -BeNullOrEmpty
        }

        It 'Should keep the original error record' {
            $caught = $null
            try
            {
                Invoke-M365DSCCommand -ScriptBlock {
                    Get-Item -Path 'TestDrive:\does\not\exist'
                }
            }
            catch
            {
                $caught = $_
            }
            $caught | Should -Not -BeNullOrEmpty
            $caught.Exception | Should -BeOfType [System.Management.Automation.ItemNotFoundException]
            $caught.FullyQualifiedErrorId | Should -BeLike 'PathNotFound*'
        }

        It 'Should retry a transient error' {
            $script:callCount = 0
            $result = Invoke-M365DSCCommand -ScriptBlock {
                $script:callCount++
                if ($script:callCount -eq 1)
                {
                    Write-Error -Message 'The operation has timed out.'
                    return
                }
                'Success after retry'
            } -BaseDelayInSeconds 0
            $result | Should -Be 'Success after retry'
            $script:callCount | Should -Be 2
        }

        It 'Should throw a permanent error' {
            {
                Invoke-M365DSCCommand -ScriptBlock {
                    Write-Error -Message 'Insufficient privileges to complete the operation.'
                }
            } | Should -Throw '*Insufficient privileges*'
        }

        It 'Should ignore errors silenced inside the scriptblock' {
            $result = Invoke-M365DSCCommand -ScriptBlock {
                Write-Error -Message 'Ignored' -ErrorAction SilentlyContinue
                'value'
            }
            $result | Should -Be 'value'
        }

        It 'Should return all output objects when no error occurs' {
            $result = Invoke-M365DSCCommand -ScriptBlock { 1, 2, 3 }
            $result | Should -Be @(1, 2, 3)
        }
    }

    Context 'When an error is both transient and not-found with SuppressNotFoundError' {
        It 'Should retry and throw instead of returning $null' {
            $script:callCount = 0
            {
                Invoke-M365DSCCommand -ScriptBlock {
                    $script:callCount++
                    throw 'Response status code does not indicate success: 503 (Service Unavailable). Item not found in cache.'
                } -SuppressNotFoundError -MaxRetries 1 -BaseDelayInSeconds 0
            } | Should -Throw '*503*'
            $script:callCount | Should -Be 2
        }
    }

    Context 'When a cmdlet is not available with SuppressNotFoundError' {
        It 'Should throw instead of returning $null' {
            {
                Invoke-M365DSCCommand -ScriptBlock {
                    Get-M365DSCCmdletThatDoesNotExist -ErrorAction Stop
                } -SuppressNotFoundError
            } | Should -Throw '*is not recognized*'
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

    It 'releases the lock of a file written by another runspace' {
        $fileName = "$(New-Guid).partial.ps1"
        $filePath = [System.IO.Path]::GetFullPath((Join-Path -Path $env:TEMP -ChildPath $fileName))
        $locks = [Microsoft365DSC.Cache.PartialExportWriter].GetField('_locks', [System.Reflection.BindingFlags] 'NonPublic, Static').GetValue($null)
        $powershell = [System.Management.Automation.PowerShell]::Create()
        try
        {
            $null = $powershell.AddScript({
                    param ($ModulePath, $FileName)
                    Import-Module $ModulePath
                    Save-M365DSCPartialExport -Content 'instance' -FileName $FileName
                }).AddArgument($Script:ErrorHandlerPath).AddArgument($fileName).Invoke()
            $locks.ContainsKey($filePath) | Should -BeTrue

            Close-M365DSCPartialExport -FileName $fileName
            $locks.ContainsKey($filePath) | Should -BeFalse
        }
        finally
        {
            $powershell.Dispose()
            Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue
        }
    }
}
