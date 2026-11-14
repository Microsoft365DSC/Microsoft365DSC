function New-MgGroup
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.Boolean]
        $MailEnabled,

        [Parameter()]
        [System.Boolean]
        $SecurityEnabled,

        [Parameter()]
        [System.String]
        $MailNickName,

        [Parameter()]
        [System.String[]]
        $GroupTypes,

        [Parameter()]
        [System.String]
        $Visibility,

        [Parameter()]
        [System.Object]
        $BodyParameter
    )
}

function New-MgGroupOwnerByRef
{

    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $GroupId,

        [Parameter()]
        [System.Object]
        $BodyParameter
    )
}
function Confirm-M365DSCDependencies
{
    [CmdletBinding()]
    param()
}

function Update-MgServicePrincipal
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $ServicePrincipalId,

        [Parameter()]
        [System.String]
        $AppId,

        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String[]]
        $AlternativeNames,

        [Parameter()]
        [System.Boolean]
        $AccountEnabled,

        [Parameter()]
        [System.Boolean]
        $AppRoleAssignmentRequired,

        [Parameter()]
        [System.String]
        $ErrorUrl,

        [Parameter()]
        [System.String]
        $Homepage,

        [Parameter()]
        [System.String]
        $LogoutUrl,

        [Parameter()]
        [System.String]
        $PublisherName,

        [Parameter()]
        [System.String[]]
        $ReplyURLs,

        [Parameter()]
        [System.String]
        $SamlMetadataURL,

        [Parameter()]
        [System.String[]]
        $ServicePrincipalNames,

        [Parameter()]
        [System.String]
        $ServicePrincipalType,

        [Parameter()]
        [System.String[]]
        $Tags,

        [Parameter()]
        [PSObject]
        $PasswordCredentials,

        [Parameter()]
        [PSObject]
        $KeyCredentials,

        [Parameter()]
        [System.Object]
        $BodyParameter
    )
}

function Remove-MGServicePrincipal
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $ServicePrincipalId
    )
}

function New-MGServicePrincipal
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $AppId,

        [Parameter()]
        [System.String[]]
        $AlternativeNames,

        [Parameter()]
        [System.Boolean]
        $AccountEnabled,

        [Parameter()]
        [System.Boolean]
        $AppRoleAssignmentRequired,

        [Parameter()]
        [System.String]
        $Homepage,

        [Parameter()]
        [System.String]
        $LogoutUrl,

        [Parameter()]
        [System.String]
        $ErrorUrl,

        [Parameter()]
        [System.String]
        $PublisherName,

        [Parameter()]
        [System.String[]]
        $ReplyURLs,

        [Parameter()]
        [System.String]
        $SamlMetadataURL,

        [Parameter()]
        [System.String[]]
        $ServicePrincipalNames,

        [Parameter()]
        [System.String]
        $ServicePrincipalType,

        [Parameter()]
        [System.String[]]
        $Tags,

        [Parameter()]
        [PSObject]
        $PasswordCredentials,

        [Parameter()]
        [PSObject]
        $KeyCredentials,

        [Parameter()]
        [System.Object]
        $BodyParameter
    )
}

function Get-MgServicePrincipalOwner
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [String]
        $ServicePrincipalId,

           [Parameter()]
        [String[]]
        $ExpandProperty,

           [Parameter()]
        [String]
        $Filter,

           [Parameter()]
        [String[]]
        $Property,

           [Parameter()]
        [String]
        $Search,

           [Parameter()]
        [Int32]
        $Skip,

           [Parameter()]
        [String[]]
        $Sort,

           [Parameter()]
        [Int32]
        $Top,

           [Parameter()]
        [String]
        $ConsistencyLevel,

           [Parameter()]
        [String]
        $ResponseHeadersVariable,

           [Parameter()]
        [hashtable]
        $Headers,

           [Parameter()]
        [Int32]
        $PageSize,

        [Parameter()]
        [switch]
        $All,

        [Parameter()]
        [String]
        $CountVariable
    )
}

function New-MgBetaRoleManagementDirectoryRoleDefinition
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.Object]
        $BodyParameter,

        [Parameter()]
        [System.String]
        $ResponseHeadersVariable,

        [Parameter()]
        [System.Collections.Hashtable]
        $AdditionalProperties,

        [Parameter()]
        [System.String]
        $AllowedPrincipalTypes,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Id,

        [Parameter()]
        [System.Object]
        $InheritsPermissionsFrom,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $IsBuiltIn,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $IsEnabled,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $IsPrivileged,

        [Parameter()]
        [System.String[]]
        $ResourceScopes,

        [Parameter()]
        [System.Object]
        $RolePermissions,

        [Parameter()]
        [System.String]
        $TemplateId,

        [Parameter()]
        [System.String]
        $Version,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Break,

        [Parameter()]
        [System.Collections.IDictionary]
        $Headers,

        [Parameter()]
        [System.Object[]]
        $HttpPipelineAppend,

        [Parameter()]
        [System.Object[]]
        $HttpPipelinePrepend,

        [Parameter()]
        [System.Uri]
        $Proxy,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ProxyCredential,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ProxyUseDefaultCredentials
    )
}

function Update-MgBetaRoleManagementDirectoryRoleDefinition
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String[]]
        $ResourceScopes,

        [Parameter()]
        [System.String[]]
        $RolePermissions,

        [Parameter()]
        [System.String]
        $TemplateId,

        [Parameter()]
        [System.Boolean]
        $IsEnabled,

        [Parameter()]
        [System.String]
        $Version,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.Collections.Hashtable]
        $AdditionalProperties,

        [Parameter()]
        [System.String]
        $UnifiedRoleDefinitionId,

        [Parameter()]
        [System.Object]
        $BodyParameter
    )
}

function Remove-MgBetaRoleManagementDirectoryRoleDefinition
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $UnifiedRoleDefinitionId
    )
}

function Get-PSSession
{
    [CmdletBinding()]
    param(
    )
}

function Update-MgDirectorySetting
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $DirectorySettingId,

        [Parameter()]
        [System.Collections.Hashtable]
        $Values
    )
}

function Get-MGDirectorySetting
{
    [CmdletBinding()]
    param(
    )
}

function New-MGDirectorySetting
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $TemplateId,

        [Parameter()]
        [System.Collections.Hashtable]
        $Values
    )
}
function Remove-MgDirectorySetting
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $DirectorySettingId
    )
}

function Remove-PSSession
{
    [CmdletBinding()]
    param(
    )
}

function Get-SPOAdministrationUrl
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential
    )
}

function Connect-M365Tenant
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $Workload,

        [Parameter()]
        [System.String]
        $Url,

        [Parameter()]
        [Alias('o365Credential')]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $UseModernAuth,

        [Parameter()]
        [SecureString]
        $CertificatePassword,

        [Parameter()]
        [System.String]
        $CertificatePath,

        [Parameter()]
        [Switch]
        $Identity,

        [Parameter()]
        [System.String[]]
        $AccessTokens,

        [Parameter()]
        [System.Collections.Hashtable]
        $Endpoints,

        [Parameter()]
        [ValidateScript(
            { $Workload -eq 'ExchangeOnline' }
        )]
        [System.String[]]
        $ExchangeOnlineCmdlets = @()
    )
}

function New-M365DSCConnection
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $Workload,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $InboundParameters,

        [Parameter()]
        [System.String]
        $Url,

        [Parameter()]
        [switch]
        $EnableSearchOnlySession
    )
}

function Start-Job
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [Object]
        $ScriptBLock,

        [Parameter()]
        [System.String[]]
        $ArgumentList
    )
}

function Get-Job
{
    [CmdletBinding()]
    param()
}

#region Specific to tenants
<#
function Get-AtpPolicyForO365
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (

    )
}
#>

function Set-AddressBookPolicy
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.String[]]
        $AddressLists,

        [Parameter()]
        [System.String]
        $GlobalAddressList,

        [Parameter()]
        [System.String]
        $OfflineAddressBook,

        [Parameter()]
        [System.String]
        $RoomList
    )
}

function New-AddressBookPolicy
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String[]]
        $AddressLists,

        [Parameter()]
        [System.String]
        $GlobalAddressList,

        [Parameter()]
        [System.String]
        $OfflineAddressBook,

        [Parameter()]
        [System.String]
        $RoomList
    )
}

function Remove-DkimSigningConfig
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter()]
        [System.Boolean]
        $Confirm = $true
    )
}

function New-M365DSCLogEntry
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Source,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Message,

        [Parameter()]
        [System.Object]
        $Exception,

        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $TenantId
    )
}

function Confirm-ImportedCmdletIsAvailable
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $CmdletName
    )
}

function Get-AllSPOPackages
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable[]])]
    param(
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )
}

# EXOOfflineAddressBook cmdlets
function Set-AddressBookPolicy
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.String[]]
        $AddressLists,

        [Parameter()]
        [System.String]
        $GlobalAddressList,

        [Parameter()]
        [System.String]
        $OfflineAddressBook,

        [Parameter()]
        [System.String]
        $RoomList,

        [Parameter()]
        [System.Boolean]
        $Confirm
    )
}

function New-AddressBookPolicy
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String[]]
        $AddressLists,

        [Parameter()]
        [System.String]
        $GlobalAddressList,

        [Parameter()]
        [System.String]
        $OfflineAddressBook,

        [Parameter()]
        [System.String]
        $RoomList,

        [Parameter()]
        [System.Boolean]
        $Confirm
    )
}

# EXOGlobalAddressList cmdlets
function Get-GlobalAddressList
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [System.String]
        $Identity
    )
}

function Set-GlobalAddressList
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter()]
        [ValidateLength(1, 64)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String[]]
        $ConditionalCompany,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute1,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute10,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute11,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute12,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute13,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute14,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute15,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute2,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute3,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute4,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute5,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute6,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute7,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute8,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute9,

        [Parameter()]
        [System.String[]]
        $ConditionalDepartment,

        [Parameter()]
        [System.String[]]
        $ConditionalStateOrProvince,

        [Parameter()]
        [ValidateSet('AllRecipients', 'MailboxUsers', 'MailContacts', 'MailGroups', 'MailUsers', 'Resources')]
        [System.String[]]
        $IncludedRecipients,

        [Parameter()]
        [System.String[]]
        $RecipientFilter,

        [Parameter()]
        [System.Boolean]
        $Confirm
    )
}

function New-GlobalAddressList
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 64)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String[]]
        $ConditionalCompany,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute1,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute10,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute11,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute12,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute13,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute14,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute15,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute2,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute3,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute4,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute5,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute6,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute7,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute8,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute9,

        [Parameter()]
        [System.String[]]
        $ConditionalDepartment,

        [Parameter()]
        [System.String[]]
        $ConditionalStateOrProvince,

        [Parameter()]
        [ValidateSet('AllRecipients', 'MailboxUsers', 'MailContacts', 'MailGroups', 'MailUsers', 'Resources')]
        [System.String[]]
        $IncludedRecipients,

        [Parameter()]
        [System.String[]]
        $RecipientFilter,

        [Parameter()]
        [System.Boolean]
        $Confirm
    )
}

function Set-AddressList
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter()]
        [ValidateLength(1, 64)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String[]]
        $ConditionalCompany,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute1,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute10,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute11,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute12,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute13,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute14,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute15,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute2,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute3,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute4,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute5,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute6,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute7,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute8,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute9,

        [Parameter()]
        [System.String[]]
        $ConditionalDepartment,

        [Parameter()]
        [System.String[]]
        $ConditionalStateOrProvince,

        [Parameter()]
        [System.String[]]
        $DisplayName,

        [Parameter()]
        [ValidateSet('AllRecipients', 'MailboxUsers', 'MailContacts', 'MailGroups', 'MailUsers', 'Resources')]
        [System.String[]]
        $IncludedRecipients,

        [Parameter()]
        [System.String[]]
        $RecipientFilter,

        [Parameter()]
        [System.Boolean]
        $Confirm
    )
}

function New-AddressList
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 64)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String[]]
        $ConditionalCompany,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute1,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute10,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute11,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute12,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute13,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute14,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute15,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute2,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute3,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute4,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute5,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute6,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute7,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute8,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute9,

        [Parameter()]
        [System.String[]]
        $ConditionalDepartment,

        [Parameter()]
        [System.String[]]
        $ConditionalStateOrProvince,

        [Parameter()]
        [System.String[]]
        $DisplayName,

        [Parameter()]
        [ValidateSet('AllRecipients', 'MailboxUsers', 'MailContacts', 'MailGroups', 'MailUsers', 'Resources')]
        [System.String[]]
        $IncludedRecipients,

        [Parameter()]
        [System.String[]]
        $RecipientFilter,

        [Parameter()]
        [System.Boolean]
        $Confirm
    )
}

function Connect-Graph
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.String[]]
        $Scopes
    )
}

# function Get-MGGroupPlannerPlan
# {
#     [CmdletBinding()]
#     Param(
#         [Parameter()]
#         [System.String]
#         $GroupId
#     )
# }

function Update-MGPlannerPlan
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.String]
        $Owner,

        [Parameter()]
        [System.String]
        $Title,

        [Parameter()]
        [System.String]
        $PlannerPlanId,

        [Parameter()]
        [System.Object]
        $BodyParameter
    )
}

function Get-MgPlannerPlanBucket
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.String]
        $PlannerPlanId
    )
}

function New-MgPlannerBucket
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.String]
        $PlanId,

        [Parameter()]
        [System.String]
        $Name
    )
}

function Update-MgPlannerBucket
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.String]
        $PlanId,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $BucketId
    )
}

function Get-EOPProtectionPolicyRule
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.String]
        $Identity,

        [Parameter()]
        [System.String]
        $State
    )
}

function Enable-EOPProtectionPolicyRule
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.String]
        $Identity
    )
}

function Disable-EOPProtectionPolicyRule
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.String]
        $Identity
    )
}

function Enable-SmtpDaneInbound
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.String]
        $DomainName
    )
}

function Disable-SmtpDaneInbound
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.String]
        $DomainName
    )
}

#region MSCloudLoginAssistant
function Get-MSCloudLoginConnectionProfile{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $Workload
    )
}

function Reset-MSCloudLoginConnectionProfileContext
{
}
#endregion

#region PKI
function New-SelfSignedCertificate
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter()]
        [System.String]
        $Type,

        [Parameter()]
        [System.String[]]
        $DnsName,

        [Parameter()]
        [System.String]
        $Subject,

        [Parameter()]
        [System.String]
        $HashAlgorithm,

        [Parameter()]
        [System.DateTime]
        $NotAfter,

        [Parameter()]
        [System.String]
        $CertStoreLocation
    )
}

function Export-PfxCertificate
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Object]
        $Cert,

        [Parameter()]
        [System.String]
        $FilePath,

        [Parameter()]
        [System.Security.SecureString]
        $Password
    )
}
#endregion

#region PSDesiredStateConfiguration
function Get-DscLocalConfigurationManager
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Object]
        $CimSession
    )
}
#endregion
