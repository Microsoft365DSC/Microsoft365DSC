<#
.SYNOPSIS
    Connects a workload and returns the proxy module its cmdlets live in.

.DESCRIPTION
    Exchange Online and Security and Compliance cmdlets are generated at connect time into an
    implicit remoting module with a generated name. The module is found by probing the loaded
    modules for a command only that workload exports.

.PARAMETER Workload
    Specifies the workload to connect.

.PARAMETER KnownCommand
    Specifies a command only that workload's proxy exports.

.PARAMETER InboundParameters
    Specifies the authentication values for New-M365DSCConnection.

.OUTPUTS
    The proxy module. Throws when no loaded module exports KnownCommand.
#>
function Get-ConnectedWorkloadModule
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSModuleInfo])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('ExchangeOnline', 'SecurityComplianceCenter')]
        [System.String]
        $Workload,

        [Parameter(Mandatory = $true)]
        [System.String]
        $KnownCommand,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $InboundParameters
    )

    $null = New-M365DSCConnection -Workload $Workload -InboundParameters $InboundParameters

    $found = @(Get-Module | Where-Object -FilterScript {
            $_.ExportedCommands.Values.Name -ccontains $KnownCommand
        })

    if ($found.Count -eq 0)
    {
        throw "Connected to '$Workload' but no loaded module exports '$KnownCommand'."
    }

    return $found[0]
}

<#
.SYNOPSIS
    Connects every requested tenant workload and returns the proxy modules.

.DESCRIPTION
    A failure downgrades the run rather than ending it. The proxies that did connect are kept and
    the message is carried back for the report.

.PARAMETER Workload
    Specifies the workloads the capture was asked for.

.PARAMETER RepositoryRoot
    Specifies the root of the Microsoft365DSC repository, which holds New-M365DSCConnection.

.PARAMETER Credential
    Specifies the credential to authenticate with.

.PARAMETER ApplicationId
    Specifies the application registration.

.PARAMETER TenantId
    Specifies the tenant domain name.

.PARAMETER CertificateThumbprint
    Specifies the certificate registered on the application.

.PARAMETER WorkloadAuthentication
    Specifies per-workload overrides of ApplicationId and CertificateThumbprint.

.OUTPUTS
    An ordered dictionary with Module, a map of workload to proxy module, and Error.
#>
function Connect-TenantWorkload
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Workload,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RepositoryRoot,

        [Parameter()]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $TenantId,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [System.Collections.IDictionary]
        $WorkloadAuthentication = @{}
    )

    $modules = @{}
    $errors = [System.Collections.Generic.List[System.String]]::new()

    try
    {
        Import-Module -Name (Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC/Microsoft365DSC.psd1') `
            -Force -Global -ErrorAction Stop
    }
    catch
    {
        $message = "Microsoft365DSC could not be imported, so no workload was connected. $($_.Exception.Message)"
        Write-Warning -Message $message
        return [ordered]@{ Module = @{}; Error = $message }
    }

    foreach ($probe in (Get-ConnectedWorkloadProbe))
    {
        # One workload failing must not cost the others their capture.
        try
        {
            if ($probe.Workload -notin $Workload)
            {
                continue
            }

            $override = @{}
            if ($WorkloadAuthentication.Contains($probe.Workload))
            {
                $override = $WorkloadAuthentication[$probe.Workload]
            }

            $application = $ApplicationId
            if (-not [System.String]::IsNullOrEmpty([System.String] $override['ApplicationId']))
            {
                $application = [System.String] $override['ApplicationId']
            }

            $thumbprint = $CertificateThumbprint
            if (-not [System.String]::IsNullOrEmpty([System.String] $override['CertificateThumbprint']))
            {
                $thumbprint = [System.String] $override['CertificateThumbprint']
            }

            $parameters = New-ConnectionParameter -Credential $Credential `
                -ApplicationId $application `
                -TenantId $TenantId `
                -CertificateThumbprint $thumbprint

            if ($null -eq $parameters)
            {
                throw 'No authentication was supplied. Pass a credential, or an application id with a tenant name and a certificate thumbprint.'
            }

            $modules[$probe.Workload] = Get-ConnectedWorkloadModule -Workload $probe.Workload `
                -KnownCommand $probe.KnownCommand `
                -InboundParameters $parameters
        }
        catch
        {
            $message = "$($probe.Workload) was not captured. $($_.Exception.Message)"
            Write-Warning -Message $message
            $errors.Add($message)
        }
    }

    return [ordered]@{ Module = $modules; Error = ($errors -join ' ') }
}

<#
.SYNOPSIS
    Opens a Microsoft Graph session for the settings catalog capture.

.PARAMETER RepositoryRoot
    Specifies the root of the Microsoft365DSC repository.

.PARAMETER Credential
    Specifies the credential to authenticate with.

.PARAMETER ApplicationId
    Specifies the application registration.

.PARAMETER TenantId
    Specifies the tenant domain name.

.PARAMETER CertificateThumbprint
    Specifies the certificate registered on the application.

.PARAMETER WorkloadAuthentication
    Specifies per-workload overrides of ApplicationId and CertificateThumbprint.

.OUTPUTS
    An ordered dictionary with Connected and Error.
#>
function Connect-TenantGraph
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $RepositoryRoot,

        [Parameter()]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $TenantId,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [System.Collections.IDictionary]
        $WorkloadAuthentication = @{}
    )

    try
    {
        Import-Module -Name (Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC/Microsoft365DSC.psd1') `
            -Force -Global -ErrorAction Stop

        $override = @{}
        if ($WorkloadAuthentication.Contains('MicrosoftGraph'))
        {
            $override = $WorkloadAuthentication['MicrosoftGraph']
        }

        $application = $ApplicationId
        if (-not [System.String]::IsNullOrEmpty([System.String] $override['ApplicationId']))
        {
            $application = [System.String] $override['ApplicationId']
        }

        $thumbprint = $CertificateThumbprint
        if (-not [System.String]::IsNullOrEmpty([System.String] $override['CertificateThumbprint']))
        {
            $thumbprint = [System.String] $override['CertificateThumbprint']
        }

        $parameters = New-ConnectionParameter -Credential $Credential `
            -ApplicationId $application `
            -TenantId $TenantId `
            -CertificateThumbprint $thumbprint

        if ($null -eq $parameters)
        {
            throw 'No authentication was supplied. Pass a credential, or an application id with a tenant name and a certificate thumbprint.'
        }

        $null = New-M365DSCConnection -Workload 'MicrosoftGraph' -InboundParameters $parameters -ErrorAction Stop

        return [ordered]@{ Connected = $true; Error = '' }
    }
    catch
    {
        $message = "Microsoft Graph was not connected. $($_.Exception.Message)"
        Write-Warning -Message $message
        return [ordered]@{ Connected = $false; Error = $message }
    }
}

<#
.SYNOPSIS
    Returns the workloads a connected capture covers, with the command that identifies each proxy.

.OUTPUTS
    Objects with Workload and KnownCommand.
#>
function Get-ConnectedWorkloadProbe
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param ()

    # Order matters. The proxies overlap and the first probe to export a cmdlet owns it.
    return @(
        [PSCustomObject]@{ Workload = 'ExchangeOnline'; KnownCommand = 'Get-Mailbox' }
        [PSCustomObject]@{ Workload = 'SecurityComplianceCenter'; KnownCommand = 'Set-ComplianceCase' }
    )
}

<#
.SYNOPSIS
    Builds the InboundParameters hashtable New-M365DSCConnection expects.

.PARAMETER Credential
    Specifies the credential to authenticate with.

.PARAMETER ApplicationId
    Specifies the application registration.

.PARAMETER TenantId
    Specifies the tenant domain name.

.PARAMETER CertificateThumbprint
    Specifies the certificate registered on the application.

.OUTPUTS
    The hashtable, or null when nothing was supplied.
#>
function New-ConnectionParameter
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $TenantId,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $CertificateThumbprint
    )

    if ($null -ne $Credential)
    {
        if (-not [System.String]::IsNullOrEmpty($CertificateThumbprint))
        {
            throw 'Supply either a credential or a certificate thumbprint, not both.'
        }

        return @{ Credential = $Credential }
    }

    if ([System.String]::IsNullOrEmpty($ApplicationId) -or
        [System.String]::IsNullOrEmpty($TenantId) -or
        [System.String]::IsNullOrEmpty($CertificateThumbprint))
    {
        return $null
    }

    if ([System.Guid]::TryParse($TenantId, [ref] [System.Guid]::Empty))
    {
        throw 'TenantId has to be the tenant domain name, for example contoso.onmicrosoft.com, not its GUID.'
    }

    return @{
        ApplicationId         = $ApplicationId
        TenantId              = $TenantId
        CertificateThumbprint = $CertificateThumbprint
    }
}
