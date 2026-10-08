using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneSecurityBaselineMicrosoft365AppsForEnterprise : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Policy description')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Policy name')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The policy settings for the device scope')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineMicrosoft365AppsForEnterprise] $DeviceSettings

    [DscProperty()]
    [System.ComponentModel.Description('The policy settings for the user scope')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineMicrosoft365AppsForEnterprise] $UserSettings

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Azure Active Directory application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [IntuneSecurityBaselineMicrosoft365AppsForEnterprise] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneSecurityBaselineMicrosoft365AppsForEnterprise]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Security Baseline Microsoft365 Apps For Enterprise with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}."

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                #region resource generator code
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $this.Id -ErrorAction SilentlyContinue `
                        -ExpandProperty 'settings($expand=settingDefinitions)'
                    $settings = $getValue.settings
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Security Baseline Microsoft365 Apps For Enterprise with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Security Baseline Microsoft365 Apps For Enterprise with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Security Baseline Microsoft365 Apps For Enterprise with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

            # Retrieve policy specific settings
            if ($null -eq $settings)
            {
                [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
                    -DeviceManagementConfigurationPolicyId $resolvedId `
                    -ExpandProperty 'settingDefinitions' `
                    -All `
                    -ErrorAction Stop
            }

            $policySettings = @{}
            $policySettings = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $policySettings -ContainsDeviceAndUserSettings

            #region resource generator code
            $complexDeviceSettings = [ordered]@{}
            $complexDeviceSettings.Add('Pol_SecGuide_A001_Block_Flash', $policySettings.DeviceSettings.pol_SecGuide_A001_Block_Flash)
            $complexDeviceSettings.Add('Pol_SecGuide_Block_Flash', $policySettings.DeviceSettings.pol_SecGuide_Block_Flash)
            $complexDeviceSettings.Add('Pol_SecGuide_Legacy_JScript', $policySettings.DeviceSettings.pol_SecGuide_Legacy_JScript)
            $complexDeviceSettings.Add('POL_SG_powerpnt', $policySettings.DeviceSettings.pOL_SG_powerpnt)
            $complexDeviceSettings.Add('POL_SG_onenote', $policySettings.DeviceSettings.pOL_SG_onenote)
            $complexDeviceSettings.Add('POL_SG_mspub', $policySettings.DeviceSettings.pOL_SG_mspub)
            $complexDeviceSettings.Add('POL_SG_msaccess', $policySettings.DeviceSettings.pOL_SG_msaccess)
            $complexDeviceSettings.Add('POL_SG_visio', $policySettings.DeviceSettings.pOL_SG_visio)
            $complexDeviceSettings.Add('POL_SG_winproj', $policySettings.DeviceSettings.pOL_SG_winproj)
            $complexDeviceSettings.Add('POL_SG_winword', $policySettings.DeviceSettings.pOL_SG_winword)
            $complexDeviceSettings.Add('POL_SG_outlook', $policySettings.DeviceSettings.pOL_SG_outlook)
            $complexDeviceSettings.Add('POL_SG_excel', $policySettings.DeviceSettings.pOL_SG_excel)
            $complexDeviceSettings.Add('L_PolicyEnableSIPHighSecurityMode', $policySettings.DeviceSettings.l_PolicyEnableSIPHighSecurityMode)
            $complexDeviceSettings.Add('L_PolicyDisableHttpConnect', $policySettings.DeviceSettings.l_PolicyDisableHttpConnect)
            $complexDeviceSettings.Add('L_AddonManagement', $policySettings.DeviceSettings.l_AddonManagement)
            $complexDeviceSettings.Add('L_powerpntexe17', $policySettings.DeviceSettings.l_powerpntexe17)
            $complexDeviceSettings.Add('L_pptviewexe18', $policySettings.DeviceSettings.l_pptviewexe18)
            $complexDeviceSettings.Add('L_winwordexe21', $policySettings.DeviceSettings.l_winwordexe21)
            $complexDeviceSettings.Add('L_outlookexe22', $policySettings.DeviceSettings.l_outlookexe22)
            $complexDeviceSettings.Add('L_visioexe19', $policySettings.DeviceSettings.l_visioexe19)
            $complexDeviceSettings.Add('L_exprwdexe24', $policySettings.DeviceSettings.l_exprwdexe24)
            $complexDeviceSettings.Add('L_excelexe15', $policySettings.DeviceSettings.l_excelexe15)
            $complexDeviceSettings.Add('L_onenoteexe26', $policySettings.DeviceSettings.l_onenoteexe26)
            $complexDeviceSettings.Add('L_winprojexe20', $policySettings.DeviceSettings.l_winprojexe20)
            $complexDeviceSettings.Add('L_spdesignexe23', $policySettings.DeviceSettings.l_spdesignexe23)
            $complexDeviceSettings.Add('L_grooveexe14', $policySettings.DeviceSettings.l_grooveexe14)
            $complexDeviceSettings.Add('L_mspubexe16', $policySettings.DeviceSettings.l_mspubexe16)
            $complexDeviceSettings.Add('L_msaccessexe25', $policySettings.DeviceSettings.l_msaccessexe25)
            $complexDeviceSettings.Add('L_mse7exe27', $policySettings.DeviceSettings.l_mse7exe27)
            $complexDeviceSettings.Add('L_ConsistentMimeHandling', $policySettings.DeviceSettings.l_ConsistentMimeHandling)
            $complexDeviceSettings.Add('L_spdesignexe51', $policySettings.DeviceSettings.l_spdesignexe51)
            $complexDeviceSettings.Add('L_excelexe43', $policySettings.DeviceSettings.l_excelexe43)
            $complexDeviceSettings.Add('L_mspubexe44', $policySettings.DeviceSettings.l_mspubexe44)
            $complexDeviceSettings.Add('L_visioexe47', $policySettings.DeviceSettings.l_visioexe47)
            $complexDeviceSettings.Add('L_outlookexe50', $policySettings.DeviceSettings.l_outlookexe50)
            $complexDeviceSettings.Add('L_onenoteexe54', $policySettings.DeviceSettings.l_onenoteexe54)
            $complexDeviceSettings.Add('L_pptviewexe46', $policySettings.DeviceSettings.l_pptviewexe46)
            $complexDeviceSettings.Add('L_winprojexe48', $policySettings.DeviceSettings.l_winprojexe48)
            $complexDeviceSettings.Add('L_powerpntexe45', $policySettings.DeviceSettings.l_powerpntexe45)
            $complexDeviceSettings.Add('L_mse7exe55', $policySettings.DeviceSettings.l_mse7exe55)
            $complexDeviceSettings.Add('L_grooveexe42', $policySettings.DeviceSettings.l_grooveexe42)
            $complexDeviceSettings.Add('L_msaccessexe53', $policySettings.DeviceSettings.l_msaccessexe53)
            $complexDeviceSettings.Add('L_winwordexe49', $policySettings.DeviceSettings.l_winwordexe49)
            $complexDeviceSettings.Add('L_exprwdexe52', $policySettings.DeviceSettings.l_exprwdexe52)
            $complexDeviceSettings.Add('L_Disableusernameandpassword', $policySettings.DeviceSettings.l_Disableusernameandpassword)
            $complexDeviceSettings.Add('L_onenoteexe138', $policySettings.DeviceSettings.l_onenoteexe138)
            $complexDeviceSettings.Add('L_grooveexe126', $policySettings.DeviceSettings.l_grooveexe126)
            $complexDeviceSettings.Add('L_mse7exe139', $policySettings.DeviceSettings.l_mse7exe139)
            $complexDeviceSettings.Add('L_excelexe127', $policySettings.DeviceSettings.l_excelexe127)
            $complexDeviceSettings.Add('L_visioexe131', $policySettings.DeviceSettings.l_visioexe131)
            $complexDeviceSettings.Add('L_spdesignexe135', $policySettings.DeviceSettings.l_spdesignexe135)
            $complexDeviceSettings.Add('L_exprwdexe136', $policySettings.DeviceSettings.l_exprwdexe136)
            $complexDeviceSettings.Add('L_winwordexe133', $policySettings.DeviceSettings.l_winwordexe133)
            $complexDeviceSettings.Add('L_mspubexe128', $policySettings.DeviceSettings.l_mspubexe128)
            $complexDeviceSettings.Add('L_msaccessexe137', $policySettings.DeviceSettings.l_msaccessexe137)
            $complexDeviceSettings.Add('L_powerpntexe129', $policySettings.DeviceSettings.l_powerpntexe129)
            $complexDeviceSettings.Add('L_outlookexe134', $policySettings.DeviceSettings.l_outlookexe134)
            $complexDeviceSettings.Add('L_winprojexe132', $policySettings.DeviceSettings.l_winprojexe132)
            $complexDeviceSettings.Add('L_pptviewexe130', $policySettings.DeviceSettings.l_pptviewexe130)
            $complexDeviceSettings.Add('L_Informationbar', $policySettings.DeviceSettings.l_Informationbar)
            $complexDeviceSettings.Add('L_outlookexe120', $policySettings.DeviceSettings.l_outlookexe120)
            $complexDeviceSettings.Add('L_mspubexe114', $policySettings.DeviceSettings.l_mspubexe114)
            $complexDeviceSettings.Add('L_excelexe113', $policySettings.DeviceSettings.l_excelexe113)
            $complexDeviceSettings.Add('L_msaccessexe123', $policySettings.DeviceSettings.l_msaccessexe123)
            $complexDeviceSettings.Add('L_winprojexe118', $policySettings.DeviceSettings.l_winprojexe118)
            $complexDeviceSettings.Add('L_onenoteexe124', $policySettings.DeviceSettings.l_onenoteexe124)
            $complexDeviceSettings.Add('L_spdesignexe121', $policySettings.DeviceSettings.l_spdesignexe121)
            $complexDeviceSettings.Add('L_powerpntexe115', $policySettings.DeviceSettings.l_powerpntexe115)
            $complexDeviceSettings.Add('L_grooveexe112', $policySettings.DeviceSettings.l_grooveexe112)
            $complexDeviceSettings.Add('L_winwordexe119', $policySettings.DeviceSettings.l_winwordexe119)
            $complexDeviceSettings.Add('L_exprwdexe122', $policySettings.DeviceSettings.l_exprwdexe122)
            $complexDeviceSettings.Add('L_mse7exe125', $policySettings.DeviceSettings.l_mse7exe125)
            $complexDeviceSettings.Add('L_visioexe117', $policySettings.DeviceSettings.l_visioexe117)
            $complexDeviceSettings.Add('L_pptviewexe116', $policySettings.DeviceSettings.l_pptviewexe116)
            $complexDeviceSettings.Add('L_LocalMachineZoneLockdownSecurity', $policySettings.DeviceSettings.l_LocalMachineZoneLockdownSecurity)
            $complexDeviceSettings.Add('L_mse7exe41', $policySettings.DeviceSettings.l_mse7exe41)
            $complexDeviceSettings.Add('L_powerpntexe31', $policySettings.DeviceSettings.l_powerpntexe31)
            $complexDeviceSettings.Add('L_mspubexe30', $policySettings.DeviceSettings.l_mspubexe30)
            $complexDeviceSettings.Add('L_outlookexe36', $policySettings.DeviceSettings.l_outlookexe36)
            $complexDeviceSettings.Add('L_pptviewexe32', $policySettings.DeviceSettings.l_pptviewexe32)
            $complexDeviceSettings.Add('L_excelexe29', $policySettings.DeviceSettings.l_excelexe29)
            $complexDeviceSettings.Add('L_exprwdexe38', $policySettings.DeviceSettings.l_exprwdexe38)
            $complexDeviceSettings.Add('L_grooveexe28', $policySettings.DeviceSettings.l_grooveexe28)
            $complexDeviceSettings.Add('L_winwordexe35', $policySettings.DeviceSettings.l_winwordexe35)
            $complexDeviceSettings.Add('L_visioexe33', $policySettings.DeviceSettings.l_visioexe33)
            $complexDeviceSettings.Add('L_onenoteexe40', $policySettings.DeviceSettings.l_onenoteexe40)
            $complexDeviceSettings.Add('L_spdesignexe37', $policySettings.DeviceSettings.l_spdesignexe37)
            $complexDeviceSettings.Add('L_msaccessexe39', $policySettings.DeviceSettings.l_msaccessexe39)
            $complexDeviceSettings.Add('L_winprojexe34', $policySettings.DeviceSettings.l_winprojexe34)
            $complexDeviceSettings.Add('L_MimeSniffingSafetyFature', $policySettings.DeviceSettings.l_MimeSniffingSafetyFature)
            $complexDeviceSettings.Add('L_powerpntexe59', $policySettings.DeviceSettings.l_powerpntexe59)
            $complexDeviceSettings.Add('L_visioexe61', $policySettings.DeviceSettings.l_visioexe61)
            $complexDeviceSettings.Add('L_grooveexe56', $policySettings.DeviceSettings.l_grooveexe56)
            $complexDeviceSettings.Add('L_exprwdexe66', $policySettings.DeviceSettings.l_exprwdexe66)
            $complexDeviceSettings.Add('L_outlookexe64', $policySettings.DeviceSettings.l_outlookexe64)
            $complexDeviceSettings.Add('L_mspubexe58', $policySettings.DeviceSettings.l_mspubexe58)
            $complexDeviceSettings.Add('L_mse7exe69', $policySettings.DeviceSettings.l_mse7exe69)
            $complexDeviceSettings.Add('L_pptviewexe60', $policySettings.DeviceSettings.l_pptviewexe60)
            $complexDeviceSettings.Add('L_msaccessexe67', $policySettings.DeviceSettings.l_msaccessexe67)
            $complexDeviceSettings.Add('L_winprojexe62', $policySettings.DeviceSettings.l_winprojexe62)
            $complexDeviceSettings.Add('L_spdesignexe65', $policySettings.DeviceSettings.l_spdesignexe65)
            $complexDeviceSettings.Add('L_onenoteexe68', $policySettings.DeviceSettings.l_onenoteexe68)
            $complexDeviceSettings.Add('L_winwordexe63', $policySettings.DeviceSettings.l_winwordexe63)
            $complexDeviceSettings.Add('L_excelexe57', $policySettings.DeviceSettings.l_excelexe57)
            $complexDeviceSettings.Add('L_NavigateURL', $policySettings.DeviceSettings.l_NavigateURL)
            $complexDeviceSettings.Add('L_pptviewexe172', $policySettings.DeviceSettings.l_pptviewexe172)
            $complexDeviceSettings.Add('L_spdesignexe177', $policySettings.DeviceSettings.l_spdesignexe177)
            $complexDeviceSettings.Add('L_onenoteexe180', $policySettings.DeviceSettings.l_onenoteexe180)
            $complexDeviceSettings.Add('L_outlookexe176', $policySettings.DeviceSettings.l_outlookexe176)
            $complexDeviceSettings.Add('L_winprojexe174', $policySettings.DeviceSettings.l_winprojexe174)
            $complexDeviceSettings.Add('L_excelexe169', $policySettings.DeviceSettings.l_excelexe169)
            $complexDeviceSettings.Add('L_exprwdexe178', $policySettings.DeviceSettings.l_exprwdexe178)
            $complexDeviceSettings.Add('L_msaccessexe179', $policySettings.DeviceSettings.l_msaccessexe179)
            $complexDeviceSettings.Add('L_winwordexe175', $policySettings.DeviceSettings.l_winwordexe175)
            $complexDeviceSettings.Add('L_mspubexe170', $policySettings.DeviceSettings.l_mspubexe170)
            $complexDeviceSettings.Add('L_powerpntexe171', $policySettings.DeviceSettings.l_powerpntexe171)
            $complexDeviceSettings.Add('L_grooveexe168', $policySettings.DeviceSettings.l_grooveexe168)
            $complexDeviceSettings.Add('L_visioexe173', $policySettings.DeviceSettings.l_visioexe173)
            $complexDeviceSettings.Add('L_mse7exe181', $policySettings.DeviceSettings.l_mse7exe181)
            $complexDeviceSettings.Add('L_ObjectCachingProtection', $policySettings.DeviceSettings.l_ObjectCachingProtection)
            $complexDeviceSettings.Add('L_winwordexe77', $policySettings.DeviceSettings.l_winwordexe77)
            $complexDeviceSettings.Add('L_spdesignexe79', $policySettings.DeviceSettings.l_spdesignexe79)
            $complexDeviceSettings.Add('L_mse7exe83', $policySettings.DeviceSettings.l_mse7exe83)
            $complexDeviceSettings.Add('L_powerpntexe73', $policySettings.DeviceSettings.l_powerpntexe73)
            $complexDeviceSettings.Add('L_mspubexe72', $policySettings.DeviceSettings.l_mspubexe72)
            $complexDeviceSettings.Add('L_msaccessexe81', $policySettings.DeviceSettings.l_msaccessexe81)
            $complexDeviceSettings.Add('L_outlookexe78', $policySettings.DeviceSettings.l_outlookexe78)
            $complexDeviceSettings.Add('L_visioexe75', $policySettings.DeviceSettings.l_visioexe75)
            $complexDeviceSettings.Add('L_onenoteexe82', $policySettings.DeviceSettings.l_onenoteexe82)
            $complexDeviceSettings.Add('L_grooveexe70', $policySettings.DeviceSettings.l_grooveexe70)
            $complexDeviceSettings.Add('L_excelexe71', $policySettings.DeviceSettings.l_excelexe71)
            $complexDeviceSettings.Add('L_exprwdexe80', $policySettings.DeviceSettings.l_exprwdexe80)
            $complexDeviceSettings.Add('L_pptviewexe74', $policySettings.DeviceSettings.l_pptviewexe74)
            $complexDeviceSettings.Add('L_winprojexe76', $policySettings.DeviceSettings.l_winprojexe76)
            $complexDeviceSettings.Add('L_ProtectionFromZoneElevation', $policySettings.DeviceSettings.l_ProtectionFromZoneElevation)
            $complexDeviceSettings.Add('L_mspubexe100', $policySettings.DeviceSettings.l_mspubexe100)
            $complexDeviceSettings.Add('L_visioexe103', $policySettings.DeviceSettings.l_visioexe103)
            $complexDeviceSettings.Add('L_winwordexe105', $policySettings.DeviceSettings.l_winwordexe105)
            $complexDeviceSettings.Add('L_excelexe99', $policySettings.DeviceSettings.l_excelexe99)
            $complexDeviceSettings.Add('L_powerpntexe101', $policySettings.DeviceSettings.l_powerpntexe101)
            $complexDeviceSettings.Add('L_mse7exe111', $policySettings.DeviceSettings.l_mse7exe111)
            $complexDeviceSettings.Add('L_onenoteexe110', $policySettings.DeviceSettings.l_onenoteexe110)
            $complexDeviceSettings.Add('L_pptviewexe102', $policySettings.DeviceSettings.l_pptviewexe102)
            $complexDeviceSettings.Add('L_exprwdexe108', $policySettings.DeviceSettings.l_exprwdexe108)
            $complexDeviceSettings.Add('L_msaccessexe109', $policySettings.DeviceSettings.l_msaccessexe109)
            $complexDeviceSettings.Add('L_spdesignexe107', $policySettings.DeviceSettings.l_spdesignexe107)
            $complexDeviceSettings.Add('L_winprojexe104', $policySettings.DeviceSettings.l_winprojexe104)
            $complexDeviceSettings.Add('L_grooveexe98', $policySettings.DeviceSettings.l_grooveexe98)
            $complexDeviceSettings.Add('L_outlookexe106', $policySettings.DeviceSettings.l_outlookexe106)
            $complexDeviceSettings.Add('L_RestrictActiveXInstall', $policySettings.DeviceSettings.l_RestrictActiveXInstall)
            $complexDeviceSettings.Add('L_spDesignexe', $policySettings.DeviceSettings.l_spDesignexe)
            $complexDeviceSettings.Add('L_mse7exe', $policySettings.DeviceSettings.l_mse7exe)
            $complexDeviceSettings.Add('L_powerpntexe', $policySettings.DeviceSettings.l_powerpntexe)
            $complexDeviceSettings.Add('L_onenoteexe', $policySettings.DeviceSettings.l_onenoteexe)
            $complexDeviceSettings.Add('L_exprwdexe', $policySettings.DeviceSettings.l_exprwdexe)
            $complexDeviceSettings.Add('L_excelexe', $policySettings.DeviceSettings.l_excelexe)
            $complexDeviceSettings.Add('L_mspubexe', $policySettings.DeviceSettings.l_mspubexe)
            $complexDeviceSettings.Add('L_visioexe', $policySettings.DeviceSettings.l_visioexe)
            $complexDeviceSettings.Add('L_pptviewexe', $policySettings.DeviceSettings.l_pptviewexe)
            $complexDeviceSettings.Add('L_outlookexe', $policySettings.DeviceSettings.l_outlookexe)
            $complexDeviceSettings.Add('L_grooveexe', $policySettings.DeviceSettings.l_grooveexe)
            $complexDeviceSettings.Add('L_msaccessexe', $policySettings.DeviceSettings.l_msaccessexe)
            $complexDeviceSettings.Add('L_winprojexe', $policySettings.DeviceSettings.l_winprojexe)
            $complexDeviceSettings.Add('L_winwordexe', $policySettings.DeviceSettings.l_winwordexe)
            $complexDeviceSettings.Add('L_RestrictFileDownload', $policySettings.DeviceSettings.l_RestrictFileDownload)
            $complexDeviceSettings.Add('L_msaccessexe11', $policySettings.DeviceSettings.l_msaccessexe11)
            $complexDeviceSettings.Add('L_visioexe5', $policySettings.DeviceSettings.l_visioexe5)
            $complexDeviceSettings.Add('L_winprojexe6', $policySettings.DeviceSettings.l_winprojexe6)
            $complexDeviceSettings.Add('L_excelexe1', $policySettings.DeviceSettings.l_excelexe1)
            $complexDeviceSettings.Add('L_spdesignexe9', $policySettings.DeviceSettings.l_spdesignexe9)
            $complexDeviceSettings.Add('L_powerpntexe3', $policySettings.DeviceSettings.l_powerpntexe3)
            $complexDeviceSettings.Add('L_mspubexe2', $policySettings.DeviceSettings.l_mspubexe2)
            $complexDeviceSettings.Add('L_exprwdexe10', $policySettings.DeviceSettings.l_exprwdexe10)
            $complexDeviceSettings.Add('L_outlookexe8', $policySettings.DeviceSettings.l_outlookexe8)
            $complexDeviceSettings.Add('L_pptviewexe4', $policySettings.DeviceSettings.l_pptviewexe4)
            $complexDeviceSettings.Add('L_winwordexe7', $policySettings.DeviceSettings.l_winwordexe7)
            $complexDeviceSettings.Add('L_onenoteexe12', $policySettings.DeviceSettings.l_onenoteexe12)
            $complexDeviceSettings.Add('L_mse7exe13', $policySettings.DeviceSettings.l_mse7exe13)
            $complexDeviceSettings.Add('L_grooveexe0', $policySettings.DeviceSettings.l_grooveexe0)
            $complexDeviceSettings.Add('L_SavedfromURL', $policySettings.DeviceSettings.l_SavedfromURL)
            $complexDeviceSettings.Add('L_exprwdexe164', $policySettings.DeviceSettings.l_exprwdexe164)
            $complexDeviceSettings.Add('L_mse7exe167', $policySettings.DeviceSettings.l_mse7exe167)
            $complexDeviceSettings.Add('L_spdesignexe163', $policySettings.DeviceSettings.l_spdesignexe163)
            $complexDeviceSettings.Add('L_pptviewexe158', $policySettings.DeviceSettings.l_pptviewexe158)
            $complexDeviceSettings.Add('L_winprojexe160', $policySettings.DeviceSettings.l_winprojexe160)
            $complexDeviceSettings.Add('L_visioexe159', $policySettings.DeviceSettings.l_visioexe159)
            $complexDeviceSettings.Add('L_mspubexe156', $policySettings.DeviceSettings.l_mspubexe156)
            $complexDeviceSettings.Add('L_msaccessexe165', $policySettings.DeviceSettings.l_msaccessexe165)
            $complexDeviceSettings.Add('L_winwordexe161', $policySettings.DeviceSettings.l_winwordexe161)
            $complexDeviceSettings.Add('L_outlookexe162', $policySettings.DeviceSettings.l_outlookexe162)
            $complexDeviceSettings.Add('L_excelexe155', $policySettings.DeviceSettings.l_excelexe155)
            $complexDeviceSettings.Add('L_powerpntexe157', $policySettings.DeviceSettings.l_powerpntexe157)
            $complexDeviceSettings.Add('L_onenoteexe166', $policySettings.DeviceSettings.l_onenoteexe166)
            $complexDeviceSettings.Add('L_grooveexe154', $policySettings.DeviceSettings.l_grooveexe154)
            $complexDeviceSettings.Add('L_ScriptedWindowSecurityRestrictions', $policySettings.DeviceSettings.l_ScriptedWindowSecurityRestrictions)
            $complexDeviceSettings.Add('L_powerpntexe87', $policySettings.DeviceSettings.l_powerpntexe87)
            $complexDeviceSettings.Add('L_exprwdexe94', $policySettings.DeviceSettings.l_exprwdexe94)
            $complexDeviceSettings.Add('L_mspubexe86', $policySettings.DeviceSettings.l_mspubexe86)
            $complexDeviceSettings.Add('L_outlookexe92', $policySettings.DeviceSettings.l_outlookexe92)
            $complexDeviceSettings.Add('L_mse7exe97', $policySettings.DeviceSettings.l_mse7exe97)
            $complexDeviceSettings.Add('L_msaccessexe95', $policySettings.DeviceSettings.l_msaccessexe95)
            $complexDeviceSettings.Add('L_grooveexe84', $policySettings.DeviceSettings.l_grooveexe84)
            $complexDeviceSettings.Add('L_excelexe85', $policySettings.DeviceSettings.l_excelexe85)
            $complexDeviceSettings.Add('L_pptviewexe88', $policySettings.DeviceSettings.l_pptviewexe88)
            $complexDeviceSettings.Add('L_spdesignexe93', $policySettings.DeviceSettings.l_spdesignexe93)
            $complexDeviceSettings.Add('L_visioexe89', $policySettings.DeviceSettings.l_visioexe89)
            $complexDeviceSettings.Add('L_winprojexe90', $policySettings.DeviceSettings.l_winprojexe90)
            $complexDeviceSettings.Add('L_onenoteexe96', $policySettings.DeviceSettings.l_onenoteexe96)
            $complexDeviceSettings.Add('L_winwordexe91', $policySettings.DeviceSettings.l_winwordexe91)
            if ($complexDeviceSettings.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceSettings = $null
            }
            $policySettings.Remove('DeviceSettings') | Out-Null

            $complexUserSettings = [ordered]@{}
            $complexUserSettings.Add('MicrosoftAccess_Security_TrustCenter_L_BlockMacroExecutionFromInternet', $policySettings.UserSettings.microsoftAccess_Security_TrustCenter_L_BlockMacroExecutionFromInternet)
            $complexUserSettings.Add('MicrosoftAccess_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned', $policySettings.UserSettings.microsoftAccess_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned)
            $complexUserSettings.Add('MicrosoftAccess_Security_TrustCenterTrustedLocations_L_AllowTrustedLocationsOnTheNetwork', $policySettings.UserSettings.microsoftAccess_Security_TrustCenterTrustedLocations_L_AllowTrustedLocationsOnTheNetwork)
            $complexUserSettings.Add('MicrosoftAccess_Security_TrustCenter_L_VBAWarningsPolicy', $policySettings.UserSettings.microsoftAccess_Security_TrustCenter_L_VBAWarningsPolicy)
            $complexUserSettings.Add('MicrosoftAccess_Security_TrustCenter_L_VBAWarningsPolicy_L_Empty', $policySettings.UserSettings.microsoftAccess_Security_TrustCenter_L_VBAWarningsPolicy_L_Empty)
            $complexUserSettings.Add('L_Donotshowdataextractionoptionswhenopeningcorruptworkbooks', $policySettings.UserSettings.l_Donotshowdataextractionoptionswhenopeningcorruptworkbooks)
            $complexUserSettings.Add('L_Asktoupdateautomaticlinks', $policySettings.UserSettings.l_Asktoupdateautomaticlinks)
            $complexUserSettings.Add('L_LoadpicturesfromWebpagesnotcreatedinExcel', $policySettings.UserSettings.l_LoadpicturesfromWebpagesnotcreatedinExcel)
            $complexUserSettings.Add('L_DisableAutoRepublish', $policySettings.UserSettings.l_DisableAutoRepublish)
            $complexUserSettings.Add('L_DoNotShowAutoRepublishWarningAlert', $policySettings.UserSettings.l_DoNotShowAutoRepublishWarningAlert)
            $complexUserSettings.Add('L_Forcefileextenstionstomatch', $policySettings.UserSettings.l_Forcefileextenstionstomatch)
            $complexUserSettings.Add('L_Forcefileextenstionstomatch_L_Empty', $policySettings.UserSettings.l_Forcefileextenstionstomatch_L_Empty)
            $complexUserSettings.Add('L_DeterminewhethertoforceencryptedExcel', $policySettings.UserSettings.l_DeterminewhethertoforceencryptedExcel)
            $complexUserSettings.Add('L_DeterminewhethertoforceencryptedExcelDropID', $policySettings.UserSettings.l_DeterminewhethertoforceencryptedExcelDropID)
            $complexUserSettings.Add('L_BlockXLLFromInternet', $policySettings.UserSettings.l_BlockXLLFromInternet)
            $complexUserSettings.Add('L_BlockXLLFromInternetEnum', $policySettings.UserSettings.l_BlockXLLFromInternetEnum)
            $complexUserSettings.Add('MicrosoftExcel_Security_TrustCenter_L_BlockMacroExecutionFromInternet', $policySettings.UserSettings.microsoftExcel_Security_TrustCenter_L_BlockMacroExecutionFromInternet)
            $complexUserSettings.Add('MicrosoftExcel_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned', $policySettings.UserSettings.microsoftExcel_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned)
            $complexUserSettings.Add('L_EnableBlockUnsecureQueryFiles', $policySettings.UserSettings.l_EnableBlockUnsecureQueryFiles)
            $complexUserSettings.Add('L_DBaseIIIANDIVFiles', $policySettings.UserSettings.l_DBaseIIIANDIVFiles)
            $complexUserSettings.Add('L_DBaseIIIANDIVFilesDropID', $policySettings.UserSettings.l_DBaseIIIANDIVFilesDropID)
            $complexUserSettings.Add('L_DifAndSylkFiles', $policySettings.UserSettings.l_DifAndSylkFiles)
            $complexUserSettings.Add('L_DifAndSylkFilesDropID', $policySettings.UserSettings.l_DifAndSylkFilesDropID)
            $complexUserSettings.Add('L_Excel2MacrosheetsAndAddInFiles', $policySettings.UserSettings.l_Excel2MacrosheetsAndAddInFiles)
            $complexUserSettings.Add('L_Excel2MacrosheetsAndAddInFilesDropID', $policySettings.UserSettings.l_Excel2MacrosheetsAndAddInFilesDropID)
            $complexUserSettings.Add('L_Excel2Worksheets', $policySettings.UserSettings.l_Excel2Worksheets)
            $complexUserSettings.Add('L_Excel2WorksheetsDropID', $policySettings.UserSettings.l_Excel2WorksheetsDropID)
            $complexUserSettings.Add('L_Excel3MacrosheetsAndAddInFiles', $policySettings.UserSettings.l_Excel3MacrosheetsAndAddInFiles)
            $complexUserSettings.Add('L_Excel3MacrosheetsAndAddInFilesDropID', $policySettings.UserSettings.l_Excel3MacrosheetsAndAddInFilesDropID)
            $complexUserSettings.Add('L_Excel3Worksheets', $policySettings.UserSettings.l_Excel3Worksheets)
            $complexUserSettings.Add('L_Excel3WorksheetsDropID', $policySettings.UserSettings.l_Excel3WorksheetsDropID)
            $complexUserSettings.Add('L_Excel4MacrosheetsAndAddInFiles', $policySettings.UserSettings.l_Excel4MacrosheetsAndAddInFiles)
            $complexUserSettings.Add('L_Excel4MacrosheetsAndAddInFilesDropID', $policySettings.UserSettings.l_Excel4MacrosheetsAndAddInFilesDropID)
            $complexUserSettings.Add('L_Excel4Workbooks', $policySettings.UserSettings.l_Excel4Workbooks)
            $complexUserSettings.Add('L_Excel4WorkbooksDropID', $policySettings.UserSettings.l_Excel4WorkbooksDropID)
            $complexUserSettings.Add('L_Excel4Worksheets', $policySettings.UserSettings.l_Excel4Worksheets)
            $complexUserSettings.Add('L_Excel4WorksheetsDropID', $policySettings.UserSettings.l_Excel4WorksheetsDropID)
            $complexUserSettings.Add('L_Excel95Workbooks', $policySettings.UserSettings.l_Excel95Workbooks)
            $complexUserSettings.Add('L_Excel95WorkbooksDropID', $policySettings.UserSettings.l_Excel95WorkbooksDropID)
            $complexUserSettings.Add('L_Excel9597WorkbooksAndTemplates', $policySettings.UserSettings.l_Excel9597WorkbooksAndTemplates)
            $complexUserSettings.Add('L_Excel9597WorkbooksAndTemplatesDropID', $policySettings.UserSettings.l_Excel9597WorkbooksAndTemplatesDropID)
            $complexUserSettings.Add('L_Excel972003WorkbooksAndTemplates', $policySettings.UserSettings.l_Excel972003WorkbooksAndTemplates)
            $complexUserSettings.Add('L_Excel972003WorkbooksAndTemplatesDropID', $policySettings.UserSettings.l_Excel972003WorkbooksAndTemplatesDropID)
            $complexUserSettings.Add('MicrosoftExcel_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehavior', $policySettings.UserSettings.microsoftExcel_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehavior)
            $complexUserSettings.Add('MicrosoftExcel_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehaviorDropID', $policySettings.UserSettings.microsoftExcel_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehaviorDropID)
            $complexUserSettings.Add('L_WebPagesAndExcel2003XMLSpreadsheets', $policySettings.UserSettings.l_WebPagesAndExcel2003XMLSpreadsheets)
            $complexUserSettings.Add('L_WebPagesAndExcel2003XMLSpreadsheetsDropID', $policySettings.UserSettings.l_WebPagesAndExcel2003XMLSpreadsheetsDropID)
            $complexUserSettings.Add('L_XL4KillSwitchPolicy', $policySettings.UserSettings.l_XL4KillSwitchPolicy)
            $complexUserSettings.Add('L_EnableDataBaseFileProtectedView', $policySettings.UserSettings.l_EnableDataBaseFileProtectedView)
            $complexUserSettings.Add('MicrosoftExcel_Security_TrustCenterProtectedView_L_DoNotOpenFilesFromTheInternetZoneInProtectedView', $policySettings.UserSettings.microsoftExcel_Security_TrustCenterProtectedView_L_DoNotOpenFilesFromTheInternetZoneInProtectedView)
            $complexUserSettings.Add('MicrosoftExcel_Security_TrustCenterProtectedView_L_DoNotOpenFilesInUnsafeLocationsInProtectedView', $policySettings.UserSettings.microsoftExcel_Security_TrustCenterProtectedView_L_DoNotOpenFilesInUnsafeLocationsInProtectedView)
            $complexUserSettings.Add('MicrosoftExcel_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails', $policySettings.UserSettings.microsoftExcel_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails)
            $complexUserSettings.Add('MicrosoftExcel_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsStr3', $policySettings.UserSettings.microsoftExcel_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsStr3)
            $complexUserSettings.Add('MicrosoftExcel_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsDropID', $policySettings.UserSettings.microsoftExcel_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsDropID)
            $complexUserSettings.Add('MicrosoftExcel_Security_TrustCenterProtectedView_L_TurnOffProtectedViewForAttachmentsOpenedFromOutlook', $policySettings.UserSettings.microsoftExcel_Security_TrustCenterProtectedView_L_TurnOffProtectedViewForAttachmentsOpenedFromOutlook)
            $complexUserSettings.Add('MicrosoftExcel_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned', $policySettings.UserSettings.microsoftExcel_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned)
            $complexUserSettings.Add('MicrosoftExcel_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2', $policySettings.UserSettings.microsoftExcel_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2)
            $complexUserSettings.Add('MicrosoftExcel_Security_TrustCenterTrustedLocations_L_AllowTrustedLocationsOnTheNetwork', $policySettings.UserSettings.microsoftExcel_Security_TrustCenterTrustedLocations_L_AllowTrustedLocationsOnTheNetwork)
            $complexUserSettings.Add('MicrosoftExcel_Security_TrustCenter_L_VBAWarningsPolicy', $policySettings.UserSettings.microsoftExcel_Security_TrustCenter_L_VBAWarningsPolicy)
            $complexUserSettings.Add('L_empty4', $policySettings.UserSettings.l_empty4)
            $complexUserSettings.Add('MicrosoftExcel_Security_L_TurnOffFileValidation', $policySettings.UserSettings.microsoftExcel_Security_L_TurnOffFileValidation)
            $complexUserSettings.Add('L_WebContentWarningLevel', $policySettings.UserSettings.l_WebContentWarningLevel)
            $complexUserSettings.Add('L_WebContentWarningLevelValue', $policySettings.UserSettings.l_WebContentWarningLevelValue)
            $complexUserSettings.Add('L_NoExtensibilityCustomizationFromDocumentPolicy', $policySettings.UserSettings.l_NoExtensibilityCustomizationFromDocumentPolicy)
            $complexUserSettings.Add('L_NoExtensibilityCustomizationFromDocumentPolicyWord', $policySettings.UserSettings.l_NoExtensibilityCustomizationFromDocumentPolicyWord)
            $complexUserSettings.Add('L_NoExtensibilityCustomizationFromDocumentPolicyExcel', $policySettings.UserSettings.l_NoExtensibilityCustomizationFromDocumentPolicyExcel)
            $complexUserSettings.Add('L_NoExtensibilityCustomizationFromDocumentPolicyVisio', $policySettings.UserSettings.l_NoExtensibilityCustomizationFromDocumentPolicyVisio)
            $complexUserSettings.Add('L_NoExtensibilityCustomizationFromDocumentPolicyPowerPoint', $policySettings.UserSettings.l_NoExtensibilityCustomizationFromDocumentPolicyPowerPoint)
            $complexUserSettings.Add('L_NoExtensibilityCustomizationFromDocumentPolicyPublisher', $policySettings.UserSettings.l_NoExtensibilityCustomizationFromDocumentPolicyPublisher)
            $complexUserSettings.Add('L_NoExtensibilityCustomizationFromDocumentPolicyOutlook', $policySettings.UserSettings.l_NoExtensibilityCustomizationFromDocumentPolicyOutlook)
            $complexUserSettings.Add('L_NoExtensibilityCustomizationFromDocumentPolicyProject', $policySettings.UserSettings.l_NoExtensibilityCustomizationFromDocumentPolicyProject)
            $complexUserSettings.Add('L_NoExtensibilityCustomizationFromDocumentPolicyInfoPath', $policySettings.UserSettings.l_NoExtensibilityCustomizationFromDocumentPolicyInfoPath)
            $complexUserSettings.Add('L_NoExtensibilityCustomizationFromDocumentPolicyAccess', $policySettings.UserSettings.l_NoExtensibilityCustomizationFromDocumentPolicyAccess)
            $complexUserSettings.Add('L_ActiveXControlInitialization', $policySettings.UserSettings.l_ActiveXControlInitialization)
            $complexUserSettings.Add('L_ActiveXControlInitializationcolon', $policySettings.UserSettings.l_ActiveXControlInitializationcolon)
            $complexUserSettings.Add('L_BasicAuthProxyBehavior', $policySettings.UserSettings.l_BasicAuthProxyBehavior)
            $complexUserSettings.Add('L_AllowVbaIntranetRefs', $policySettings.UserSettings.l_AllowVbaIntranetRefs)
            $complexUserSettings.Add('L_AutomationSecurity', $policySettings.UserSettings.l_AutomationSecurity)
            $complexUserSettings.Add('L_SettheAutomationSecuritylevel', $policySettings.UserSettings.l_SettheAutomationSecuritylevel)
            $complexUserSettings.Add('L_AuthenticationFBABehavior', $policySettings.UserSettings.l_AuthenticationFBABehavior)
            $complexUserSettings.Add('L_AuthenticationFBAEnabledHostsID', $policySettings.UserSettings.l_AuthenticationFBAEnabledHostsID)
            $complexUserSettings.Add('L_authenticationFBABehaviorEnum', $policySettings.UserSettings.l_authenticationFBABehaviorEnum)
            $complexUserSettings.Add('L_DisableStrictVbaRefsSecurityPolicy', $policySettings.UserSettings.l_DisableStrictVbaRefsSecurityPolicy)
            $complexUserSettings.Add('L_DisableallTrustBarnotificationsfor', $policySettings.UserSettings.l_DisableallTrustBarnotificationsfor)
            $complexUserSettings.Add('L_Encryptiontypeforirm', $policySettings.UserSettings.l_Encryptiontypeforirm)
            $complexUserSettings.Add('L_Encryptiontypeforirmcolon', $policySettings.UserSettings.l_Encryptiontypeforirmcolon)
            $complexUserSettings.Add('L_Encryptiontypeforpasswordprotectedoffice972003', $policySettings.UserSettings.l_Encryptiontypeforpasswordprotectedoffice972003)
            $complexUserSettings.Add('L_encryptiontypecolon318', $policySettings.UserSettings.l_encryptiontypecolon318)
            $complexUserSettings.Add('L_Encryptiontypeforpasswordprotectedofficeopen', $policySettings.UserSettings.l_Encryptiontypeforpasswordprotectedofficeopen)
            $complexUserSettings.Add('L_Encryptiontypecolon', $policySettings.UserSettings.l_Encryptiontypecolon)
            $complexUserSettings.Add('L_LoadControlsinForms3', $policySettings.UserSettings.l_LoadControlsinForms3)
            $complexUserSettings.Add('L_LoadControlsinForms3colon', $policySettings.UserSettings.l_LoadControlsinForms3colon)
            $complexUserSettings.Add('L_MacroRuntimeScanScope', $policySettings.UserSettings.l_MacroRuntimeScanScope)
            $complexUserSettings.Add('L_MacroRuntimeScanScopeEnum', $policySettings.UserSettings.l_MacroRuntimeScanScopeEnum)
            $complexUserSettings.Add('L_Protectdocumentmetadataforrightsmanaged', $policySettings.UserSettings.l_Protectdocumentmetadataforrightsmanaged)
            $complexUserSettings.Add('L_Allowmixofpolicyanduserlocations', $policySettings.UserSettings.l_Allowmixofpolicyanduserlocations)
            $complexUserSettings.Add('L_DisabletheOfficeclientfrompolling', $policySettings.UserSettings.l_DisabletheOfficeclientfrompolling)
            $complexUserSettings.Add('L_DisableSmartDocumentsuseofmanifests', $policySettings.UserSettings.l_DisableSmartDocumentsuseofmanifests)
            $complexUserSettings.Add('L_OutlookSecurityMode', $policySettings.UserSettings.l_OutlookSecurityMode)
            $complexUserSettings.Add('L_OOMAddressAccess', $policySettings.UserSettings.l_OOMAddressAccess)
            $complexUserSettings.Add('L_OOMAddressAccess_Setting', $policySettings.UserSettings.l_OOMAddressAccess_Setting)
            $complexUserSettings.Add('L_OOMMeetingTaskRequest', $policySettings.UserSettings.l_OOMMeetingTaskRequest)
            $complexUserSettings.Add('L_OOMMeetingTaskRequest_Setting', $policySettings.UserSettings.l_OOMMeetingTaskRequest_Setting)
            $complexUserSettings.Add('L_OOMSend', $policySettings.UserSettings.l_OOMSend)
            $complexUserSettings.Add('L_OOMSend_Setting', $policySettings.UserSettings.l_OOMSend_Setting)
            $complexUserSettings.Add('L_Preventusersfromcustomizingattachmentsecuritysettings', $policySettings.UserSettings.l_Preventusersfromcustomizingattachmentsecuritysettings)
            $complexUserSettings.Add('L_RetrievingCRLsCertificateRevocationLists', $policySettings.UserSettings.l_RetrievingCRLsCertificateRevocationLists)
            $complexUserSettings.Add('L_empty31', $policySettings.UserSettings.l_empty31)
            $complexUserSettings.Add('L_OOMFormula', $policySettings.UserSettings.l_OOMFormula)
            $complexUserSettings.Add('L_OOMFormula_Setting', $policySettings.UserSettings.l_OOMFormula_Setting)
            $complexUserSettings.Add('L_AuthenticationwithExchangeServer', $policySettings.UserSettings.l_AuthenticationwithExchangeServer)
            $complexUserSettings.Add('L_SelecttheauthenticationwithExchangeserver', $policySettings.UserSettings.l_SelecttheauthenticationwithExchangeserver)
            $complexUserSettings.Add('L_EnableRPCEncryption', $policySettings.UserSettings.l_EnableRPCEncryption)
            $complexUserSettings.Add('L_Enablelinksinemailmessages', $policySettings.UserSettings.l_Enablelinksinemailmessages)
            $complexUserSettings.Add('L_OOMAddressBook', $policySettings.UserSettings.l_OOMAddressBook)
            $complexUserSettings.Add('L_OOMAddressBook_Setting', $policySettings.UserSettings.l_OOMAddressBook_Setting)
            $complexUserSettings.Add('L_OutlookSecurityPolicy', $policySettings.UserSettings.l_OutlookSecurityPolicy)
            $complexUserSettings.Add('L_AllowUsersToLowerAttachments', $policySettings.UserSettings.l_AllowUsersToLowerAttachments)
            $complexUserSettings.Add('L_AllowActiveXOneOffForms', $policySettings.UserSettings.l_AllowActiveXOneOffForms)
            $complexUserSettings.Add('L_empty29', $policySettings.UserSettings.l_empty29)
            $complexUserSettings.Add('L_EnableScriptsInOneOffForms', $policySettings.UserSettings.l_EnableScriptsInOneOffForms)
            $complexUserSettings.Add('L_Level2RemoveFilePolicy', $policySettings.UserSettings.l_Level2RemoveFilePolicy)
            $complexUserSettings.Add('L_removedextensions25', $policySettings.UserSettings.l_removedextensions25)
            $complexUserSettings.Add('L_MSGUnicodeformatwhendraggingtofilesystem', $policySettings.UserSettings.l_MSGUnicodeformatwhendraggingtofilesystem)
            $complexUserSettings.Add('L_OnExecuteCustomActionOOM', $policySettings.UserSettings.l_OnExecuteCustomActionOOM)
            $complexUserSettings.Add('L_OnExecuteCustomActionOOM_Setting', $policySettings.UserSettings.l_OnExecuteCustomActionOOM_Setting)
            $complexUserSettings.Add('L_DisableOutlookobjectmodelscriptsforpublicfolders', $policySettings.UserSettings.l_DisableOutlookobjectmodelscriptsforpublicfolders)
            $complexUserSettings.Add('L_BlockInternet', $policySettings.UserSettings.l_BlockInternet)
            $complexUserSettings.Add('L_SecurityLevelOutlook', $policySettings.UserSettings.l_SecurityLevelOutlook)
            $complexUserSettings.Add('L_SecurityLevel', $policySettings.UserSettings.l_SecurityLevel)
            $complexUserSettings.Add('L_Level1RemoveFilePolicy', $policySettings.UserSettings.l_Level1RemoveFilePolicy)
            $complexUserSettings.Add('L_RemovedExtensions', $policySettings.UserSettings.l_RemovedExtensions)
            $complexUserSettings.Add('L_SignatureWarning', $policySettings.UserSettings.l_SignatureWarning)
            $complexUserSettings.Add('L_signaturewarning30', $policySettings.UserSettings.l_signaturewarning30)
            $complexUserSettings.Add('L_Level1Attachments', $policySettings.UserSettings.l_Level1Attachments)
            $complexUserSettings.Add('L_Minimumencryptionsettings', $policySettings.UserSettings.l_Minimumencryptionsettings)
            $complexUserSettings.Add('L_Minimumkeysizeinbits', $policySettings.UserSettings.l_Minimumkeysizeinbits)
            $complexUserSettings.Add('L_DisableOutlookobjectmodelscripts', $policySettings.UserSettings.l_DisableOutlookobjectmodelscripts)
            $complexUserSettings.Add('L_OOMSaveAs', $policySettings.UserSettings.l_OOMSaveAs)
            $complexUserSettings.Add('L_OOMSaveAs_Setting', $policySettings.UserSettings.l_OOMSaveAs_Setting)
            $complexUserSettings.Add('L_JunkEmailprotectionlevel', $policySettings.UserSettings.l_JunkEmailprotectionlevel)
            $complexUserSettings.Add('L_Selectlevel', $policySettings.UserSettings.l_Selectlevel)
            $complexUserSettings.Add('L_RunPrograms', $policySettings.UserSettings.l_RunPrograms)
            $complexUserSettings.Add('L_RunPrograms_L_Empty', $policySettings.UserSettings.l_RunPrograms_L_Empty)
            $complexUserSettings.Add('L_Determinewhethertoforceencryptedppt', $policySettings.UserSettings.l_Determinewhethertoforceencryptedppt)
            $complexUserSettings.Add('L_DeterminewhethertoforceencryptedpptDropID', $policySettings.UserSettings.l_DeterminewhethertoforceencryptedpptDropID)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_TrustCenter_L_BlockMacroExecutionFromInternet', $policySettings.UserSettings.microsoftPowerPoint_Security_TrustCenter_L_BlockMacroExecutionFromInternet)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned', $policySettings.UserSettings.microsoftPowerPoint_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned)
            $complexUserSettings.Add('L_PowerPoint972003PresentationsShowsTemplatesandAddInFiles', $policySettings.UserSettings.l_PowerPoint972003PresentationsShowsTemplatesandAddInFiles)
            $complexUserSettings.Add('L_PowerPoint972003PresentationsShowsTemplatesandAddInFilesDropID', $policySettings.UserSettings.l_PowerPoint972003PresentationsShowsTemplatesandAddInFilesDropID)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehavior', $policySettings.UserSettings.microsoftPowerPoint_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehavior)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehaviorDropID', $policySettings.UserSettings.microsoftPowerPoint_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehaviorDropID)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_TrustCenterProtectedView_L_DoNotOpenFilesFromTheInternetZoneInProtectedView', $policySettings.UserSettings.microsoftPowerPoint_Security_TrustCenterProtectedView_L_DoNotOpenFilesFromTheInternetZoneInProtectedView)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_TrustCenterProtectedView_L_DoNotOpenFilesInUnsafeLocationsInProtectedView', $policySettings.UserSettings.microsoftPowerPoint_Security_TrustCenterProtectedView_L_DoNotOpenFilesInUnsafeLocationsInProtectedView)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails', $policySettings.UserSettings.microsoftPowerPoint_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsStr3', $policySettings.UserSettings.microsoftPowerPoint_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsStr3)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsDropID', $policySettings.UserSettings.microsoftPowerPoint_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsDropID)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_TrustCenterProtectedView_L_TurnOffProtectedViewForAttachmentsOpenedFromOutlook', $policySettings.UserSettings.microsoftPowerPoint_Security_TrustCenterProtectedView_L_TurnOffProtectedViewForAttachmentsOpenedFromOutlook)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned', $policySettings.UserSettings.microsoftPowerPoint_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2', $policySettings.UserSettings.microsoftPowerPoint_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_TrustCenterTrustedLocations_L_AllowTrustedLocationsOnTheNetwork', $policySettings.UserSettings.microsoftPowerPoint_Security_TrustCenterTrustedLocations_L_AllowTrustedLocationsOnTheNetwork)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_TrustCenter_L_VBAWarningsPolicy', $policySettings.UserSettings.microsoftPowerPoint_Security_TrustCenter_L_VBAWarningsPolicy)
            $complexUserSettings.Add('L_empty3', $policySettings.UserSettings.l_empty3)
            $complexUserSettings.Add('MicrosoftPowerPoint_Security_L_TurnOffFileValidation', $policySettings.UserSettings.microsoftPowerPoint_Security_L_TurnOffFileValidation)
            $complexUserSettings.Add('MicrosoftProject_Security_TrustCenter_L_AllowTrustedLocationsOnTheNetwork', $policySettings.UserSettings.microsoftProject_Security_TrustCenter_L_AllowTrustedLocationsOnTheNetwork)
            $complexUserSettings.Add('MicrosoftProject_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned', $policySettings.UserSettings.microsoftProject_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned)
            $complexUserSettings.Add('MicrosoftProject_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned', $policySettings.UserSettings.microsoftProject_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned)
            $complexUserSettings.Add('MicrosoftProject_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2', $policySettings.UserSettings.microsoftProject_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2)
            $complexUserSettings.Add('MicrosoftProject_Security_TrustCenter_L_VBAWarningsPolicy', $policySettings.UserSettings.microsoftProject_Security_TrustCenter_L_VBAWarningsPolicy)
            $complexUserSettings.Add('MicrosoftProject_Security_TrustCenter_L_VBAWarningsPolicy_L_Empty', $policySettings.UserSettings.microsoftProject_Security_TrustCenter_L_VBAWarningsPolicy_L_Empty)
            $complexUserSettings.Add('L_PublisherAutomationSecurityLevel', $policySettings.UserSettings.l_PublisherAutomationSecurityLevel)
            $complexUserSettings.Add('L_PublisherAutomationSecurityLevel_L_Empty', $policySettings.UserSettings.l_PublisherAutomationSecurityLevel_L_Empty)
            $complexUserSettings.Add('MicrosoftPublisherV3_Security_TrustCenter_L_BlockMacroExecutionFromInternet', $policySettings.UserSettings.microsoftPublisherV3_Security_TrustCenter_L_BlockMacroExecutionFromInternet)
            $complexUserSettings.Add('MicrosoftPublisherV2_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned', $policySettings.UserSettings.microsoftPublisherV2_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned)
            $complexUserSettings.Add('MicrosoftPublisherV2_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned', $policySettings.UserSettings.microsoftPublisherV2_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned)
            $complexUserSettings.Add('MicrosoftPublisherV2_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2', $policySettings.UserSettings.microsoftPublisherV2_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2)
            $complexUserSettings.Add('MicrosoftPublisherV2_Security_TrustCenter_L_VBAWarningsPolicy', $policySettings.UserSettings.microsoftPublisherV2_Security_TrustCenter_L_VBAWarningsPolicy)
            $complexUserSettings.Add('L_empty0', $policySettings.UserSettings.l_empty0)
            $complexUserSettings.Add('MicrosoftVisio_Security_TrustCenter_L_AllowTrustedLocationsOnTheNetwork', $policySettings.UserSettings.microsoftVisio_Security_TrustCenter_L_AllowTrustedLocationsOnTheNetwork)
            $complexUserSettings.Add('MicrosoftVisio_Security_TrustCenter_L_BlockMacroExecutionFromInternet', $policySettings.UserSettings.microsoftVisio_Security_TrustCenter_L_BlockMacroExecutionFromInternet)
            $complexUserSettings.Add('MicrosoftVisio_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned', $policySettings.UserSettings.microsoftVisio_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned)
            $complexUserSettings.Add('L_Visio2000Files', $policySettings.UserSettings.l_Visio2000Files)
            $complexUserSettings.Add('L_Visio2000FilesDropID', $policySettings.UserSettings.l_Visio2000FilesDropID)
            $complexUserSettings.Add('L_Visio2003Files', $policySettings.UserSettings.l_Visio2003Files)
            $complexUserSettings.Add('L_Visio2003FilesDropID', $policySettings.UserSettings.l_Visio2003FilesDropID)
            $complexUserSettings.Add('L_Visio50AndEarlierFiles', $policySettings.UserSettings.l_Visio50AndEarlierFiles)
            $complexUserSettings.Add('L_Visio50AndEarlierFilesDropID', $policySettings.UserSettings.l_Visio50AndEarlierFilesDropID)
            $complexUserSettings.Add('MicrosoftVisio_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned', $policySettings.UserSettings.microsoftVisio_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned)
            $complexUserSettings.Add('MicrosoftVisio_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2', $policySettings.UserSettings.microsoftVisio_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2)
            $complexUserSettings.Add('MicrosoftVisio_Security_TrustCenter_L_VBAWarningsPolicy', $policySettings.UserSettings.microsoftVisio_Security_TrustCenter_L_VBAWarningsPolicy)
            $complexUserSettings.Add('MicrosoftVisio_Security_TrustCenter_L_VBAWarningsPolicy_L_Empty', $policySettings.UserSettings.microsoftVisio_Security_TrustCenter_L_VBAWarningsPolicy_L_Empty)
            $complexUserSettings.Add('MicrosoftWord_Security_TrustCenter_L_BlockMacroExecutionFromInternet', $policySettings.UserSettings.microsoftWord_Security_TrustCenter_L_BlockMacroExecutionFromInternet)
            $complexUserSettings.Add('MicrosoftWord_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned', $policySettings.UserSettings.microsoftWord_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned)
            $complexUserSettings.Add('L_AllowDDE', $policySettings.UserSettings.l_AllowDDE)
            $complexUserSettings.Add('L_AllowDDEDropID', $policySettings.UserSettings.l_AllowDDEDropID)
            $complexUserSettings.Add('MicrosoftWord_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehavior', $policySettings.UserSettings.microsoftWord_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehavior)
            $complexUserSettings.Add('MicrosoftWord_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehaviorDropID', $policySettings.UserSettings.microsoftWord_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehaviorDropID)
            $complexUserSettings.Add('L_Word2AndEarlierBinaryDocumentsAndTemplates', $policySettings.UserSettings.l_Word2AndEarlierBinaryDocumentsAndTemplates)
            $complexUserSettings.Add('L_Word2AndEarlierBinaryDocumentsAndTemplatesDropID', $policySettings.UserSettings.l_Word2AndEarlierBinaryDocumentsAndTemplatesDropID)
            $complexUserSettings.Add('L_Word2000BinaryDocumentsAndTemplates', $policySettings.UserSettings.l_Word2000BinaryDocumentsAndTemplates)
            $complexUserSettings.Add('L_Word2000BinaryDocumentsAndTemplatesDropID', $policySettings.UserSettings.l_Word2000BinaryDocumentsAndTemplatesDropID)
            $complexUserSettings.Add('L_Word2003BinaryDocumentsAndTemplates', $policySettings.UserSettings.l_Word2003BinaryDocumentsAndTemplates)
            $complexUserSettings.Add('L_Word2003BinaryDocumentsAndTemplatesDropID', $policySettings.UserSettings.l_Word2003BinaryDocumentsAndTemplatesDropID)
            $complexUserSettings.Add('L_Word2007AndLaterBinaryDocumentsAndTemplates', $policySettings.UserSettings.l_Word2007AndLaterBinaryDocumentsAndTemplates)
            $complexUserSettings.Add('L_Word2007AndLaterBinaryDocumentsAndTemplatesDropID', $policySettings.UserSettings.l_Word2007AndLaterBinaryDocumentsAndTemplatesDropID)
            $complexUserSettings.Add('L_Word6Pt0BinaryDocumentsAndTemplates', $policySettings.UserSettings.l_Word6Pt0BinaryDocumentsAndTemplates)
            $complexUserSettings.Add('L_Word6Pt0BinaryDocumentsAndTemplatesDropID', $policySettings.UserSettings.l_Word6Pt0BinaryDocumentsAndTemplatesDropID)
            $complexUserSettings.Add('L_Word95BinaryDocumentsAndTemplates', $policySettings.UserSettings.l_Word95BinaryDocumentsAndTemplates)
            $complexUserSettings.Add('L_Word95BinaryDocumentsAndTemplatesDropID', $policySettings.UserSettings.l_Word95BinaryDocumentsAndTemplatesDropID)
            $complexUserSettings.Add('L_Word97BinaryDocumentsAndTemplates', $policySettings.UserSettings.l_Word97BinaryDocumentsAndTemplates)
            $complexUserSettings.Add('L_Word97BinaryDocumentsAndTemplatesDropID', $policySettings.UserSettings.l_Word97BinaryDocumentsAndTemplatesDropID)
            $complexUserSettings.Add('L_WordXPBinaryDocumentsAndTemplates', $policySettings.UserSettings.l_WordXPBinaryDocumentsAndTemplates)
            $complexUserSettings.Add('L_WordXPBinaryDocumentsAndTemplatesDropID', $policySettings.UserSettings.l_WordXPBinaryDocumentsAndTemplatesDropID)
            $complexUserSettings.Add('MicrosoftWord_Security_TrustCenterProtectedView_L_DoNotOpenFilesFromTheInternetZoneInProtectedView', $policySettings.UserSettings.microsoftWord_Security_TrustCenterProtectedView_L_DoNotOpenFilesFromTheInternetZoneInProtectedView)
            $complexUserSettings.Add('MicrosoftWord_Security_TrustCenterProtectedView_L_DoNotOpenFilesInUnsafeLocationsInProtectedView', $policySettings.UserSettings.microsoftWord_Security_TrustCenterProtectedView_L_DoNotOpenFilesInUnsafeLocationsInProtectedView)
            $complexUserSettings.Add('MicrosoftWord_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails', $policySettings.UserSettings.microsoftWord_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails)
            $complexUserSettings.Add('MicrosoftWord_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsDropID', $policySettings.UserSettings.microsoftWord_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsDropID)
            $complexUserSettings.Add('MicrosoftWord_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsStr3', $policySettings.UserSettings.microsoftWord_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsStr3)
            $complexUserSettings.Add('MicrosoftWord_Security_TrustCenterProtectedView_L_TurnOffProtectedViewForAttachmentsOpenedFromOutlook', $policySettings.UserSettings.microsoftWord_Security_TrustCenterProtectedView_L_TurnOffProtectedViewForAttachmentsOpenedFromOutlook)
            $complexUserSettings.Add('MicrosoftWord_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned', $policySettings.UserSettings.microsoftWord_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned)
            $complexUserSettings.Add('MicrosoftWord_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2', $policySettings.UserSettings.microsoftWord_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2)
            $complexUserSettings.Add('L_DeterminewhethertoforceencryptedWord', $policySettings.UserSettings.l_DeterminewhethertoforceencryptedWord)
            $complexUserSettings.Add('L_DeterminewhethertoforceencryptedWordDropID', $policySettings.UserSettings.l_DeterminewhethertoforceencryptedWordDropID)
            $complexUserSettings.Add('MicrosoftWord_Security_TrustCenter_L_VBAWarningsPolicy', $policySettings.UserSettings.microsoftWord_Security_TrustCenter_L_VBAWarningsPolicy)
            $complexUserSettings.Add('L_empty19', $policySettings.UserSettings.l_empty19)
            $complexUserSettings.Add('MicrosoftWord_Security_L_TurnOffFileValidation', $policySettings.UserSettings.microsoftWord_Security_L_TurnOffFileValidation)
            $complexUserSettings.Add('MicrosoftWord_Security_TrustCenterTrustedLocations_L_AllowTrustedLocationsOnTheNetwork', $policySettings.UserSettings.microsoftWord_Security_TrustCenterTrustedLocations_L_AllowTrustedLocationsOnTheNetwork)
            $complexUserSettings.Add('L_ExcelFileBlockExternalLinks', $policySettings.UserSettings.l_ExcelFileBlockExternalLinks)
            $complexUserSettings.Add('L_BlockInsecureProtocols', $policySettings.UserSettings.l_BlockInsecureProtocols)
            $complexUserSettings.Add('L_BlockOLEGraph', $policySettings.UserSettings.l_BlockOLEGraph)
            $complexUserSettings.Add('L_BlockOrgChart', $policySettings.UserSettings.l_BlockOrgChart)
            $complexUserSettings.Add('L_BlockWecFallback', $policySettings.UserSettings.l_BlockWecFallback)
            $complexUserSettings.Add('L_OLEActions', $policySettings.UserSettings.l_OLEActions)
            $complexUserSettings.Add('L_OLEActions_L_Empty', $policySettings.UserSettings.l_OLEActions_L_Empty)
            $complexUserSettings.Add('MicrosoftProjectV3_Security_TrustCenter_L_BlockMacroExecutionFromInternet', $policySettings.UserSettings.microsoftProjectV3_Security_TrustCenter_L_BlockMacroExecutionFromInternet)
            if ($complexUserSettings.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserSettings = $null
            }
            $policySettings.Remove('UserSettings') | Out-Null
            #endregion

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.Name
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                    = $getValue.Id
                DeviceSettings        = $complexDeviceSettings
                UserSettings          = $complexUserSettings
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                #endregion
            }
            $results += $policySettings

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $resolvedId
            }
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $true
            }
            $results.Add('Assignments', $assignmentResult)

            return $this.AsResult($results)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $templateReferenceId = '90316f12-246d-44c6-a767-f87692e86083_3'
        $platforms = 'windows10'
        $technologies = 'mdm'

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Security Baseline Microsoft365 Apps For Enterprise with Name {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId `
                -ContainsDeviceAndUserSettings

            $createParameters = @{
                name              = $this.DisplayName
                description       = $this.Description
                templateReference = @{ templateId = $templateReferenceId }
                platforms         = $platforms
                technologies      = $technologies
                settings          = $settings
                roleScopeTagIds   = $resolvedRoleScopeTagIds
            }

            #region resource generator code
            $policy = New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $createParameters

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/configurationPolicies'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Security Baseline Microsoft365 Apps For Enterprise with Id {$($currentInstance.Id)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId `
                -ContainsDeviceAndUserSettings

            Update-IntuneDeviceConfigurationPolicy `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Name $this.DisplayName `
                -Description $this.Description `
                -TemplateReferenceId $templateReferenceId `
                -Platforms $platforms `
                -Technologies $technologies `
                -Settings $settings `
                -RoleScopeTagIds $resolvedRoleScopeTagIds

            #region resource generator code
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/configurationPolicies'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Security Baseline Microsoft365 Apps For Enterprise with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $currentInstance.Id
            #endregion
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            #region resource generator code
            $policyTemplateID = '90316f12-246d-44c6-a767-f87692e86083_3'
            $baseFilter = "templateReference/templateId eq '$policyTemplateID'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array]$getValue = Get-M365DSCExportCachedConfigurationPolicies `
                -TemplateId $policyTemplateID `
                -Filter $mergedFilter
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                elseif (-not [string]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.Name
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($null -ne $Results.DeviceSettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceSettings `
                        -CIMInstanceName 'MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineMicrosoft365AppsForEnterprise'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceSettings') | Out-Null
                    }
                }
                if ($null -ne $Results.UserSettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserSettings `
                        -CIMInstanceName 'MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineMicrosoft365AppsForEnterprise'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserSettings') | Out-Null
                    }
                }

                if ($Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName DeviceManagementConfigurationPolicyAssignments
                    if ($complexTypeStringResult)
                    {
                        $Results.Assignments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Assignments') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('DeviceSettings', 'UserSettings', 'Assignments') `
                    -RawResults $rawResults

                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return $this.GetSettingsCatalogCompareParameters()
    }

    hidden [IntuneSecurityBaselineMicrosoft365AppsForEnterprise] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneSecurityBaselineMicrosoft365AppsForEnterprise])
        {
            return $Values
        }

        $result = [IntuneSecurityBaselineMicrosoft365AppsForEnterprise]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineMicrosoft365AppsForEnterprise
{
    [DscProperty()]
    [System.ComponentModel.Description('Block Flash activation in Office documents (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Pol_SecGuide_A001_Block_Flash

    [DscProperty()]
    [System.ComponentModel.Description('Block Flash player in Office (Device) - Depends on Pol_SecGuide_A001_Block_Flash (Block all Flash activation: Block all activation, Block embedded Flash activation only: Block embedding/linking, allow other activation, Allow all Flash activation: Allow all activation)')]
    [ValidateSet('Block all Flash activation', 'Block embedded Flash activation only', 'Allow all Flash activation')]
    [System.String] $Pol_SecGuide_Block_Flash

    [DscProperty()]
    [System.ComponentModel.Description('Restrict legacy JScript execution for Office (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Pol_SecGuide_Legacy_JScript

    [DscProperty()]
    [System.ComponentModel.Description('PowerPoint: (Device) - Depends on Pol_SecGuide_Legacy_JScript')]
    [System.Nullable[System.Int32]] $POL_SG_powerpnt

    [DscProperty()]
    [System.ComponentModel.Description('OneNote: (Device) - Depends on Pol_SecGuide_Legacy_JScript')]
    [System.Nullable[System.Int32]] $POL_SG_onenote

    [DscProperty()]
    [System.ComponentModel.Description('Publisher: (Device) - Depends on Pol_SecGuide_Legacy_JScript')]
    [System.Nullable[System.Int32]] $POL_SG_mspub

    [DscProperty()]
    [System.ComponentModel.Description('Access: (Device) - Depends on Pol_SecGuide_Legacy_JScript')]
    [System.Nullable[System.Int32]] $POL_SG_msaccess

    [DscProperty()]
    [System.ComponentModel.Description('Visio: (Device) - Depends on Pol_SecGuide_Legacy_JScript')]
    [System.Nullable[System.Int32]] $POL_SG_visio

    [DscProperty()]
    [System.ComponentModel.Description('Project: (Device) - Depends on Pol_SecGuide_Legacy_JScript')]
    [System.Nullable[System.Int32]] $POL_SG_winproj

    [DscProperty()]
    [System.ComponentModel.Description('Word: (Device) - Depends on Pol_SecGuide_Legacy_JScript')]
    [System.Nullable[System.Int32]] $POL_SG_winword

    [DscProperty()]
    [System.ComponentModel.Description('Outlook: (Device) - Depends on Pol_SecGuide_Legacy_JScript')]
    [System.Nullable[System.Int32]] $POL_SG_outlook

    [DscProperty()]
    [System.ComponentModel.Description('Excel: (Device) - Depends on Pol_SecGuide_Legacy_JScript')]
    [System.Nullable[System.Int32]] $POL_SG_excel

    [DscProperty()]
    [System.ComponentModel.Description('Configure SIP security mode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_PolicyEnableSIPHighSecurityMode

    [DscProperty()]
    [System.ComponentModel.Description('Disable HTTP fallback for SIP connection (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_PolicyDisableHttpConnect

    [DscProperty()]
    [System.ComponentModel.Description('Add-on Management (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_AddonManagement

    [DscProperty()]
    [System.ComponentModel.Description('powerpnt.exe (Device) - Depends on L_AddonManagement (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_powerpntexe17

    [DscProperty()]
    [System.ComponentModel.Description('pptview.exe (Device) - Depends on L_AddonManagement (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_pptviewexe18

    [DscProperty()]
    [System.ComponentModel.Description('winword.exe (Device) - Depends on L_AddonManagement (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winwordexe21

    [DscProperty()]
    [System.ComponentModel.Description('outlook.exe (Device) - Depends on L_AddonManagement (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_outlookexe22

    [DscProperty()]
    [System.ComponentModel.Description('visio.exe (Device) - Depends on L_AddonManagement (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_visioexe19

    [DscProperty()]
    [System.ComponentModel.Description('exprwd.exe (Device) - Depends on L_AddonManagement (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_exprwdexe24

    [DscProperty()]
    [System.ComponentModel.Description('excel.exe (Device) - Depends on L_AddonManagement (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_excelexe15

    [DscProperty()]
    [System.ComponentModel.Description('onent.exe (Device) - Depends on L_AddonManagement (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_onenoteexe26

    [DscProperty()]
    [System.ComponentModel.Description('winproj.exe (Device) - Depends on L_AddonManagement (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winprojexe20

    [DscProperty()]
    [System.ComponentModel.Description('spDesign.exe (Device) - Depends on L_AddonManagement (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_spdesignexe23

    [DscProperty()]
    [System.ComponentModel.Description('groove.exe (Device) - Depends on L_AddonManagement (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_grooveexe14

    [DscProperty()]
    [System.ComponentModel.Description('mspub.exe (Device) - Depends on L_AddonManagement (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mspubexe16

    [DscProperty()]
    [System.ComponentModel.Description('msaccess.exe (Device) - Depends on L_AddonManagement (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_msaccessexe25

    [DscProperty()]
    [System.ComponentModel.Description('mse7.exe (Device) - Depends on L_AddonManagement (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mse7exe27

    [DscProperty()]
    [System.ComponentModel.Description('Consistent Mime Handling (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_ConsistentMimeHandling

    [DscProperty()]
    [System.ComponentModel.Description('spDesign.exe (Device) - Depends on L_ConsistentMimeHandling (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_spdesignexe51

    [DscProperty()]
    [System.ComponentModel.Description('excel.exe (Device) - Depends on L_ConsistentMimeHandling (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_excelexe43

    [DscProperty()]
    [System.ComponentModel.Description('mspub.exe (Device) - Depends on L_ConsistentMimeHandling (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mspubexe44

    [DscProperty()]
    [System.ComponentModel.Description('visio.exe (Device) - Depends on L_ConsistentMimeHandling (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_visioexe47

    [DscProperty()]
    [System.ComponentModel.Description('outlook.exe (Device) - Depends on L_ConsistentMimeHandling (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_outlookexe50

    [DscProperty()]
    [System.ComponentModel.Description('onent.exe (Device) - Depends on L_ConsistentMimeHandling (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_onenoteexe54

    [DscProperty()]
    [System.ComponentModel.Description('pptview.exe (Device) - Depends on L_ConsistentMimeHandling (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_pptviewexe46

    [DscProperty()]
    [System.ComponentModel.Description('winproj.exe (Device) - Depends on L_ConsistentMimeHandling (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winprojexe48

    [DscProperty()]
    [System.ComponentModel.Description('powerpnt.exe (Device) - Depends on L_ConsistentMimeHandling (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_powerpntexe45

    [DscProperty()]
    [System.ComponentModel.Description('mse7.exe (Device) - Depends on L_ConsistentMimeHandling (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mse7exe55

    [DscProperty()]
    [System.ComponentModel.Description('groove.exe (Device) - Depends on L_ConsistentMimeHandling (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_grooveexe42

    [DscProperty()]
    [System.ComponentModel.Description('msaccess.exe (Device) - Depends on L_ConsistentMimeHandling (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_msaccessexe53

    [DscProperty()]
    [System.ComponentModel.Description('winword.exe (Device) - Depends on L_ConsistentMimeHandling (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winwordexe49

    [DscProperty()]
    [System.ComponentModel.Description('exprwd.exe (Device) - Depends on L_ConsistentMimeHandling (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_exprwdexe52

    [DscProperty()]
    [System.ComponentModel.Description('Disable user name and password (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Disableusernameandpassword

    [DscProperty()]
    [System.ComponentModel.Description('onent.exe (Device) - Depends on L_Disableusernameandpassword (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_onenoteexe138

    [DscProperty()]
    [System.ComponentModel.Description('groove.exe (Device) - Depends on L_Disableusernameandpassword (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_grooveexe126

    [DscProperty()]
    [System.ComponentModel.Description('mse7.exe (Device) - Depends on L_Disableusernameandpassword (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mse7exe139

    [DscProperty()]
    [System.ComponentModel.Description('excel.exe (Device) - Depends on L_Disableusernameandpassword (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_excelexe127

    [DscProperty()]
    [System.ComponentModel.Description('visio.exe (Device) - Depends on L_Disableusernameandpassword (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_visioexe131

    [DscProperty()]
    [System.ComponentModel.Description('spDesign.exe (Device) - Depends on L_Disableusernameandpassword (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_spdesignexe135

    [DscProperty()]
    [System.ComponentModel.Description('exprwd.exe (Device) - Depends on L_Disableusernameandpassword (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_exprwdexe136

    [DscProperty()]
    [System.ComponentModel.Description('winword.exe (Device) - Depends on L_Disableusernameandpassword (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winwordexe133

    [DscProperty()]
    [System.ComponentModel.Description('mspub.exe (Device) - Depends on L_Disableusernameandpassword (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mspubexe128

    [DscProperty()]
    [System.ComponentModel.Description('msaccess.exe (Device) - Depends on L_Disableusernameandpassword (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_msaccessexe137

    [DscProperty()]
    [System.ComponentModel.Description('powerpnt.exe (Device) - Depends on L_Disableusernameandpassword (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_powerpntexe129

    [DscProperty()]
    [System.ComponentModel.Description('outlook.exe (Device) - Depends on L_Disableusernameandpassword (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_outlookexe134

    [DscProperty()]
    [System.ComponentModel.Description('winproj.exe (Device) - Depends on L_Disableusernameandpassword (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winprojexe132

    [DscProperty()]
    [System.ComponentModel.Description('pptview.exe (Device) - Depends on L_Disableusernameandpassword (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_pptviewexe130

    [DscProperty()]
    [System.ComponentModel.Description('Information Bar (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Informationbar

    [DscProperty()]
    [System.ComponentModel.Description('outlook.exe (Device) - Depends on L_Informationbar (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_outlookexe120

    [DscProperty()]
    [System.ComponentModel.Description('mspub.exe (Device) - Depends on L_Informationbar (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mspubexe114

    [DscProperty()]
    [System.ComponentModel.Description('excel.exe (Device) - Depends on L_Informationbar (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_excelexe113

    [DscProperty()]
    [System.ComponentModel.Description('msaccess.exe (Device) - Depends on L_Informationbar (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_msaccessexe123

    [DscProperty()]
    [System.ComponentModel.Description('winproj.exe (Device) - Depends on L_Informationbar (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winprojexe118

    [DscProperty()]
    [System.ComponentModel.Description('onent.exe (Device) - Depends on L_Informationbar (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_onenoteexe124

    [DscProperty()]
    [System.ComponentModel.Description('spDesign.exe (Device) - Depends on L_Informationbar (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_spdesignexe121

    [DscProperty()]
    [System.ComponentModel.Description('powerpnt.exe (Device) - Depends on L_Informationbar (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_powerpntexe115

    [DscProperty()]
    [System.ComponentModel.Description('groove.exe (Device) - Depends on L_Informationbar (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_grooveexe112

    [DscProperty()]
    [System.ComponentModel.Description('winword.exe (Device) - Depends on L_Informationbar (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winwordexe119

    [DscProperty()]
    [System.ComponentModel.Description('exprwd.exe (Device) - Depends on L_Informationbar (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_exprwdexe122

    [DscProperty()]
    [System.ComponentModel.Description('mse7.exe (Device) - Depends on L_Informationbar (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mse7exe125

    [DscProperty()]
    [System.ComponentModel.Description('visio.exe (Device) - Depends on L_Informationbar (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_visioexe117

    [DscProperty()]
    [System.ComponentModel.Description('pptview.exe (Device) - Depends on L_Informationbar (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_pptviewexe116

    [DscProperty()]
    [System.ComponentModel.Description('Local Machine Zone Lockdown Security (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_LocalMachineZoneLockdownSecurity

    [DscProperty()]
    [System.ComponentModel.Description('mse7.exe (Device) - Depends on L_LocalMachineZoneLockdownSecurity (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mse7exe41

    [DscProperty()]
    [System.ComponentModel.Description('powerpnt.exe (Device) - Depends on L_LocalMachineZoneLockdownSecurity (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_powerpntexe31

    [DscProperty()]
    [System.ComponentModel.Description('mspub.exe (Device) - Depends on L_LocalMachineZoneLockdownSecurity (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mspubexe30

    [DscProperty()]
    [System.ComponentModel.Description('outlook.exe (Device) - Depends on L_LocalMachineZoneLockdownSecurity (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_outlookexe36

    [DscProperty()]
    [System.ComponentModel.Description('pptview.exe (Device) - Depends on L_LocalMachineZoneLockdownSecurity (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_pptviewexe32

    [DscProperty()]
    [System.ComponentModel.Description('excel.exe (Device) - Depends on L_LocalMachineZoneLockdownSecurity (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_excelexe29

    [DscProperty()]
    [System.ComponentModel.Description('exprwd.exe (Device) - Depends on L_LocalMachineZoneLockdownSecurity (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_exprwdexe38

    [DscProperty()]
    [System.ComponentModel.Description('groove.exe (Device) - Depends on L_LocalMachineZoneLockdownSecurity (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_grooveexe28

    [DscProperty()]
    [System.ComponentModel.Description('winword.exe (Device) - Depends on L_LocalMachineZoneLockdownSecurity (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winwordexe35

    [DscProperty()]
    [System.ComponentModel.Description('visio.exe (Device) - Depends on L_LocalMachineZoneLockdownSecurity (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_visioexe33

    [DscProperty()]
    [System.ComponentModel.Description('onent.exe (Device) - Depends on L_LocalMachineZoneLockdownSecurity (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_onenoteexe40

    [DscProperty()]
    [System.ComponentModel.Description('spDesign.exe (Device) - Depends on L_LocalMachineZoneLockdownSecurity (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_spdesignexe37

    [DscProperty()]
    [System.ComponentModel.Description('msaccess.exe (Device) - Depends on L_LocalMachineZoneLockdownSecurity (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_msaccessexe39

    [DscProperty()]
    [System.ComponentModel.Description('winproj.exe (Device) - Depends on L_LocalMachineZoneLockdownSecurity (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winprojexe34

    [DscProperty()]
    [System.ComponentModel.Description('Mime Sniffing Safety Feature (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_MimeSniffingSafetyFature

    [DscProperty()]
    [System.ComponentModel.Description('powerpnt.exe (Device) - Depends on L_MimeSniffingSafetyFature (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_powerpntexe59

    [DscProperty()]
    [System.ComponentModel.Description('visio.exe (Device) - Depends on L_MimeSniffingSafetyFature (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_visioexe61

    [DscProperty()]
    [System.ComponentModel.Description('groove.exe (Device) - Depends on L_MimeSniffingSafetyFature (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_grooveexe56

    [DscProperty()]
    [System.ComponentModel.Description('exprwd.exe (Device) - Depends on L_MimeSniffingSafetyFature (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_exprwdexe66

    [DscProperty()]
    [System.ComponentModel.Description('outlook.exe (Device) - Depends on L_MimeSniffingSafetyFature (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_outlookexe64

    [DscProperty()]
    [System.ComponentModel.Description('mspub.exe (Device) - Depends on L_MimeSniffingSafetyFature (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mspubexe58

    [DscProperty()]
    [System.ComponentModel.Description('mse7.exe (Device) - Depends on L_MimeSniffingSafetyFature (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mse7exe69

    [DscProperty()]
    [System.ComponentModel.Description('pptview.exe (Device) - Depends on L_MimeSniffingSafetyFature (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_pptviewexe60

    [DscProperty()]
    [System.ComponentModel.Description('msaccess.exe (Device) - Depends on L_MimeSniffingSafetyFature (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_msaccessexe67

    [DscProperty()]
    [System.ComponentModel.Description('winproj.exe (Device) - Depends on L_MimeSniffingSafetyFature (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winprojexe62

    [DscProperty()]
    [System.ComponentModel.Description('spDesign.exe (Device) - Depends on L_MimeSniffingSafetyFature (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_spdesignexe65

    [DscProperty()]
    [System.ComponentModel.Description('onent.exe (Device) - Depends on L_MimeSniffingSafetyFature (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_onenoteexe68

    [DscProperty()]
    [System.ComponentModel.Description('winword.exe (Device) - Depends on L_MimeSniffingSafetyFature (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winwordexe63

    [DscProperty()]
    [System.ComponentModel.Description('excel.exe (Device) - Depends on L_MimeSniffingSafetyFature (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_excelexe57

    [DscProperty()]
    [System.ComponentModel.Description('Navigate URL (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_NavigateURL

    [DscProperty()]
    [System.ComponentModel.Description('pptview.exe (Device) - Depends on L_NavigateURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_pptviewexe172

    [DscProperty()]
    [System.ComponentModel.Description('spDesign.exe (Device) - Depends on L_NavigateURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_spdesignexe177

    [DscProperty()]
    [System.ComponentModel.Description('onent.exe (Device) - Depends on L_NavigateURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_onenoteexe180

    [DscProperty()]
    [System.ComponentModel.Description('outlook.exe (Device) - Depends on L_NavigateURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_outlookexe176

    [DscProperty()]
    [System.ComponentModel.Description('winproj.exe (Device) - Depends on L_NavigateURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winprojexe174

    [DscProperty()]
    [System.ComponentModel.Description('excel.exe (Device) - Depends on L_NavigateURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_excelexe169

    [DscProperty()]
    [System.ComponentModel.Description('exprwd.exe (Device) - Depends on L_NavigateURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_exprwdexe178

    [DscProperty()]
    [System.ComponentModel.Description('msaccess.exe (Device) - Depends on L_NavigateURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_msaccessexe179

    [DscProperty()]
    [System.ComponentModel.Description('winword.exe (Device) - Depends on L_NavigateURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winwordexe175

    [DscProperty()]
    [System.ComponentModel.Description('mspub.exe (Device) - Depends on L_NavigateURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mspubexe170

    [DscProperty()]
    [System.ComponentModel.Description('powerpnt.exe (Device) - Depends on L_NavigateURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_powerpntexe171

    [DscProperty()]
    [System.ComponentModel.Description('groove.exe (Device) - Depends on L_NavigateURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_grooveexe168

    [DscProperty()]
    [System.ComponentModel.Description('visio.exe (Device) - Depends on L_NavigateURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_visioexe173

    [DscProperty()]
    [System.ComponentModel.Description('mse7.exe (Device) - Depends on L_NavigateURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mse7exe181

    [DscProperty()]
    [System.ComponentModel.Description('Object Caching Protection (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_ObjectCachingProtection

    [DscProperty()]
    [System.ComponentModel.Description('winword.exe (Device) - Depends on L_ObjectCachingProtection (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winwordexe77

    [DscProperty()]
    [System.ComponentModel.Description('spDesign.exe (Device) - Depends on L_ObjectCachingProtection (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_spdesignexe79

    [DscProperty()]
    [System.ComponentModel.Description('mse7.exe (Device) - Depends on L_ObjectCachingProtection (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mse7exe83

    [DscProperty()]
    [System.ComponentModel.Description('powerpnt.exe (Device) - Depends on L_ObjectCachingProtection (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_powerpntexe73

    [DscProperty()]
    [System.ComponentModel.Description('mspub.exe (Device) - Depends on L_ObjectCachingProtection (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mspubexe72

    [DscProperty()]
    [System.ComponentModel.Description('msaccess.exe (Device) - Depends on L_ObjectCachingProtection (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_msaccessexe81

    [DscProperty()]
    [System.ComponentModel.Description('outlook.exe (Device) - Depends on L_ObjectCachingProtection (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_outlookexe78

    [DscProperty()]
    [System.ComponentModel.Description('visio.exe (Device) - Depends on L_ObjectCachingProtection (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_visioexe75

    [DscProperty()]
    [System.ComponentModel.Description('onent.exe (Device) - Depends on L_ObjectCachingProtection (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_onenoteexe82

    [DscProperty()]
    [System.ComponentModel.Description('groove.exe (Device) - Depends on L_ObjectCachingProtection (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_grooveexe70

    [DscProperty()]
    [System.ComponentModel.Description('excel.exe (Device) - Depends on L_ObjectCachingProtection (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_excelexe71

    [DscProperty()]
    [System.ComponentModel.Description('exprwd.exe (Device) - Depends on L_ObjectCachingProtection (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_exprwdexe80

    [DscProperty()]
    [System.ComponentModel.Description('pptview.exe (Device) - Depends on L_ObjectCachingProtection (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_pptviewexe74

    [DscProperty()]
    [System.ComponentModel.Description('winproj.exe (Device) - Depends on L_ObjectCachingProtection (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winprojexe76

    [DscProperty()]
    [System.ComponentModel.Description('Protection From Zone Elevation (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_ProtectionFromZoneElevation

    [DscProperty()]
    [System.ComponentModel.Description('mspub.exe (Device) - Depends on L_ProtectionFromZoneElevation (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mspubexe100

    [DscProperty()]
    [System.ComponentModel.Description('visio.exe (Device) - Depends on L_ProtectionFromZoneElevation (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_visioexe103

    [DscProperty()]
    [System.ComponentModel.Description('winword.exe (Device) - Depends on L_ProtectionFromZoneElevation (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winwordexe105

    [DscProperty()]
    [System.ComponentModel.Description('excel.exe (Device) - Depends on L_ProtectionFromZoneElevation (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_excelexe99

    [DscProperty()]
    [System.ComponentModel.Description('powerpnt.exe (Device) - Depends on L_ProtectionFromZoneElevation (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_powerpntexe101

    [DscProperty()]
    [System.ComponentModel.Description('mse7.exe (Device) - Depends on L_ProtectionFromZoneElevation (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mse7exe111

    [DscProperty()]
    [System.ComponentModel.Description('onent.exe (Device) - Depends on L_ProtectionFromZoneElevation (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_onenoteexe110

    [DscProperty()]
    [System.ComponentModel.Description('pptview.exe (Device) - Depends on L_ProtectionFromZoneElevation (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_pptviewexe102

    [DscProperty()]
    [System.ComponentModel.Description('exprwd.exe (Device) - Depends on L_ProtectionFromZoneElevation (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_exprwdexe108

    [DscProperty()]
    [System.ComponentModel.Description('msaccess.exe (Device) - Depends on L_ProtectionFromZoneElevation (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_msaccessexe109

    [DscProperty()]
    [System.ComponentModel.Description('spDesign.exe (Device) - Depends on L_ProtectionFromZoneElevation (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_spdesignexe107

    [DscProperty()]
    [System.ComponentModel.Description('winproj.exe (Device) - Depends on L_ProtectionFromZoneElevation (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winprojexe104

    [DscProperty()]
    [System.ComponentModel.Description('groove.exe (Device) - Depends on L_ProtectionFromZoneElevation (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_grooveexe98

    [DscProperty()]
    [System.ComponentModel.Description('outlook.exe (Device) - Depends on L_ProtectionFromZoneElevation (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_outlookexe106

    [DscProperty()]
    [System.ComponentModel.Description('Restrict ActiveX Install (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_RestrictActiveXInstall

    [DscProperty()]
    [System.ComponentModel.Description('spDesign.exe (Device) - Depends on L_RestrictActiveXInstall (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_spDesignexe

    [DscProperty()]
    [System.ComponentModel.Description('mse7.exe (Device) - Depends on L_RestrictActiveXInstall (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mse7exe

    [DscProperty()]
    [System.ComponentModel.Description('powerpnt.exe (Device) - Depends on L_RestrictActiveXInstall (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_powerpntexe

    [DscProperty()]
    [System.ComponentModel.Description('onent.exe (Device) - Depends on L_RestrictActiveXInstall (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_onenoteexe

    [DscProperty()]
    [System.ComponentModel.Description('exprwd.exe (Device) - Depends on L_RestrictActiveXInstall (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_exprwdexe

    [DscProperty()]
    [System.ComponentModel.Description('excel.exe (Device) - Depends on L_RestrictActiveXInstall (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_excelexe

    [DscProperty()]
    [System.ComponentModel.Description('mspub.exe (Device) - Depends on L_RestrictActiveXInstall (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mspubexe

    [DscProperty()]
    [System.ComponentModel.Description('visio.exe (Device) - Depends on L_RestrictActiveXInstall (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_visioexe

    [DscProperty()]
    [System.ComponentModel.Description('pptview.exe (Device) - Depends on L_RestrictActiveXInstall (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_pptviewexe

    [DscProperty()]
    [System.ComponentModel.Description('outlook.exe (Device) - Depends on L_RestrictActiveXInstall (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_outlookexe

    [DscProperty()]
    [System.ComponentModel.Description('groove.exe (Device) - Depends on L_RestrictActiveXInstall (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_grooveexe

    [DscProperty()]
    [System.ComponentModel.Description('msaccess.exe (Device) - Depends on L_RestrictActiveXInstall (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_msaccessexe

    [DscProperty()]
    [System.ComponentModel.Description('winproj.exe (Device) - Depends on L_RestrictActiveXInstall (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winprojexe

    [DscProperty()]
    [System.ComponentModel.Description('winword.exe (Device) - Depends on L_RestrictActiveXInstall (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winwordexe

    [DscProperty()]
    [System.ComponentModel.Description('Restrict File Download (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_RestrictFileDownload

    [DscProperty()]
    [System.ComponentModel.Description('msaccess.exe (Device) - Depends on L_RestrictFileDownload (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_msaccessexe11

    [DscProperty()]
    [System.ComponentModel.Description('visio.exe (Device) - Depends on L_RestrictFileDownload (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_visioexe5

    [DscProperty()]
    [System.ComponentModel.Description('winproj.exe (Device) - Depends on L_RestrictFileDownload (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winprojexe6

    [DscProperty()]
    [System.ComponentModel.Description('excel.exe (Device) - Depends on L_RestrictFileDownload (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_excelexe1

    [DscProperty()]
    [System.ComponentModel.Description('spDesign.exe (Device) - Depends on L_RestrictFileDownload (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_spdesignexe9

    [DscProperty()]
    [System.ComponentModel.Description('powerpnt.exe (Device) - Depends on L_RestrictFileDownload (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_powerpntexe3

    [DscProperty()]
    [System.ComponentModel.Description('mspub.exe (Device) - Depends on L_RestrictFileDownload (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mspubexe2

    [DscProperty()]
    [System.ComponentModel.Description('exprwd.exe (Device) - Depends on L_RestrictFileDownload (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_exprwdexe10

    [DscProperty()]
    [System.ComponentModel.Description('outlook.exe (Device) - Depends on L_RestrictFileDownload (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_outlookexe8

    [DscProperty()]
    [System.ComponentModel.Description('pptview.exe (Device) - Depends on L_RestrictFileDownload (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_pptviewexe4

    [DscProperty()]
    [System.ComponentModel.Description('winword.exe (Device) - Depends on L_RestrictFileDownload (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winwordexe7

    [DscProperty()]
    [System.ComponentModel.Description('onent.exe (Device) - Depends on L_RestrictFileDownload (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_onenoteexe12

    [DscProperty()]
    [System.ComponentModel.Description('mse7.exe (Device) - Depends on L_RestrictFileDownload (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mse7exe13

    [DscProperty()]
    [System.ComponentModel.Description('groove.exe (Device) - Depends on L_RestrictFileDownload (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_grooveexe0

    [DscProperty()]
    [System.ComponentModel.Description('Saved from URL (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_SavedfromURL

    [DscProperty()]
    [System.ComponentModel.Description('exprwd.exe (Device) - Depends on L_SavedfromURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_exprwdexe164

    [DscProperty()]
    [System.ComponentModel.Description('mse7.exe (Device) - Depends on L_SavedfromURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mse7exe167

    [DscProperty()]
    [System.ComponentModel.Description('spDesign.exe (Device) - Depends on L_SavedfromURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_spdesignexe163

    [DscProperty()]
    [System.ComponentModel.Description('pptview.exe (Device) - Depends on L_SavedfromURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_pptviewexe158

    [DscProperty()]
    [System.ComponentModel.Description('winproj.exe (Device) - Depends on L_SavedfromURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winprojexe160

    [DscProperty()]
    [System.ComponentModel.Description('visio.exe (Device) - Depends on L_SavedfromURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_visioexe159

    [DscProperty()]
    [System.ComponentModel.Description('mspub.exe (Device) - Depends on L_SavedfromURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mspubexe156

    [DscProperty()]
    [System.ComponentModel.Description('msaccess.exe (Device) - Depends on L_SavedfromURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_msaccessexe165

    [DscProperty()]
    [System.ComponentModel.Description('winword.exe (Device) - Depends on L_SavedfromURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winwordexe161

    [DscProperty()]
    [System.ComponentModel.Description('outlook.exe (Device) - Depends on L_SavedfromURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_outlookexe162

    [DscProperty()]
    [System.ComponentModel.Description('excel.exe (Device) - Depends on L_SavedfromURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_excelexe155

    [DscProperty()]
    [System.ComponentModel.Description('powerpnt.exe (Device) - Depends on L_SavedfromURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_powerpntexe157

    [DscProperty()]
    [System.ComponentModel.Description('onent.exe (Device) - Depends on L_SavedfromURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_onenoteexe166

    [DscProperty()]
    [System.ComponentModel.Description('groove.exe (Device) - Depends on L_SavedfromURL (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_grooveexe154

    [DscProperty()]
    [System.ComponentModel.Description('Scripted Window Security Restrictions (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_ScriptedWindowSecurityRestrictions

    [DscProperty()]
    [System.ComponentModel.Description('powerpnt.exe (Device) - Depends on L_ScriptedWindowSecurityRestrictions (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_powerpntexe87

    [DscProperty()]
    [System.ComponentModel.Description('exprwd.exe (Device) - Depends on L_ScriptedWindowSecurityRestrictions (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_exprwdexe94

    [DscProperty()]
    [System.ComponentModel.Description('mspub.exe (Device) - Depends on L_ScriptedWindowSecurityRestrictions (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mspubexe86

    [DscProperty()]
    [System.ComponentModel.Description('outlook.exe (Device) - Depends on L_ScriptedWindowSecurityRestrictions (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_outlookexe92

    [DscProperty()]
    [System.ComponentModel.Description('mse7.exe (Device) - Depends on L_ScriptedWindowSecurityRestrictions (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_mse7exe97

    [DscProperty()]
    [System.ComponentModel.Description('msaccess.exe (Device) - Depends on L_ScriptedWindowSecurityRestrictions (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_msaccessexe95

    [DscProperty()]
    [System.ComponentModel.Description('groove.exe (Device) - Depends on L_ScriptedWindowSecurityRestrictions (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_grooveexe84

    [DscProperty()]
    [System.ComponentModel.Description('excel.exe (Device) - Depends on L_ScriptedWindowSecurityRestrictions (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_excelexe85

    [DscProperty()]
    [System.ComponentModel.Description('pptview.exe (Device) - Depends on L_ScriptedWindowSecurityRestrictions (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_pptviewexe88

    [DscProperty()]
    [System.ComponentModel.Description('spDesign.exe (Device) - Depends on L_ScriptedWindowSecurityRestrictions (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_spdesignexe93

    [DscProperty()]
    [System.ComponentModel.Description('visio.exe (Device) - Depends on L_ScriptedWindowSecurityRestrictions (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_visioexe89

    [DscProperty()]
    [System.ComponentModel.Description('winproj.exe (Device) - Depends on L_ScriptedWindowSecurityRestrictions (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winprojexe90

    [DscProperty()]
    [System.ComponentModel.Description('onent.exe (Device) - Depends on L_ScriptedWindowSecurityRestrictions (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_onenoteexe96

    [DscProperty()]
    [System.ComponentModel.Description('winword.exe (Device) - Depends on L_ScriptedWindowSecurityRestrictions (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_winwordexe91
}

class MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineMicrosoft365AppsForEnterprise
{
    [DscProperty()]
    [System.ComponentModel.Description('Block macros from running in Office files from the Internet (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftAccess_Security_TrustCenter_L_BlockMacroExecutionFromInternet

    [DscProperty()]
    [System.ComponentModel.Description('Disable Trust Bar Notification for unsigned application add-ins and block them (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftAccess_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned

    [DscProperty()]
    [System.ComponentModel.Description('Allow Trusted Locations on the network (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftAccess_Security_TrustCenterTrustedLocations_L_AllowTrustedLocationsOnTheNetwork

    [DscProperty()]
    [System.ComponentModel.Description('VBA Macro Notification Settings (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftAccess_Security_TrustCenter_L_VBAWarningsPolicy

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on MicrosoftAccess_Security_TrustCenter_L_VBAWarningsPolicy (2: Disable all with notification, 3: Disable all except digitally signed macros, 4: Disable all without notification, 1: Enable all macros (not recommended))')]
    [ValidateSet('2', '3', '4', '1')]
    [System.Nullable[System.Int32]] $MicrosoftAccess_Security_TrustCenter_L_VBAWarningsPolicy_L_Empty

    [DscProperty()]
    [System.ComponentModel.Description('Do not show data extraction options when opening corrupt workbooks (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Donotshowdataextractionoptionswhenopeningcorruptworkbooks

    [DscProperty()]
    [System.ComponentModel.Description('Ask to update automatic links (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Asktoupdateautomaticlinks

    [DscProperty()]
    [System.ComponentModel.Description('Load pictures from Web pages not created in Excel (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_LoadpicturesfromWebpagesnotcreatedinExcel

    [DscProperty()]
    [System.ComponentModel.Description('Disable AutoRepublish (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_DisableAutoRepublish

    [DscProperty()]
    [System.ComponentModel.Description('Do not show AutoRepublish warning alert (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_DoNotShowAutoRepublishWarningAlert

    [DscProperty()]
    [System.ComponentModel.Description('Force file extension to match file type (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Forcefileextenstionstomatch

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on L_Forcefileextenstionstomatch (0: Allow different, 1: Allow different, but warn, 2: Always match file type)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $L_Forcefileextenstionstomatch_L_Empty

    [DscProperty()]
    [System.ComponentModel.Description('Scan encrypted macros in Excel Open XML workbooks (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_DeterminewhethertoforceencryptedExcel

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on L_DeterminewhethertoforceencryptedExcel (0: Scan encrypted macros (default), 1: Scan if anti-virus software available, 2: Load macros without scanning)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $L_DeterminewhethertoforceencryptedExcelDropID

    [DscProperty()]
    [System.ComponentModel.Description('Block Excel XLL Add-ins that come from an untrusted source (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_BlockXLLFromInternet

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on L_BlockXLLFromInternet (1: Block, 0: Show Additional Warning, 2: Allow)')]
    [ValidateSet('1', '0', '2')]
    [System.Nullable[System.Int32]] $L_BlockXLLFromInternetEnum

    [DscProperty()]
    [System.ComponentModel.Description('Block macros from running in Office files from the Internet (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_TrustCenter_L_BlockMacroExecutionFromInternet

    [DscProperty()]
    [System.ComponentModel.Description('Disable Trust Bar Notification for unsigned application add-ins and block them (User) (Deprecated) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned

    [DscProperty()]
    [System.ComponentModel.Description('Always prevent untrusted Microsoft Query files from opening (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_EnableBlockUnsecureQueryFiles

    [DscProperty()]
    [System.ComponentModel.Description('dBase III / IV files (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_DBaseIIIANDIVFiles

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_DBaseIIIANDIVFiles (0: Do not block, 2: Open/Save blocked, use open policy)')]
    [ValidateSet('0', '2')]
    [System.Nullable[System.Int32]] $L_DBaseIIIANDIVFilesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Dif and Sylk files (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_DifAndSylkFiles

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_DifAndSylkFiles (0: Do not block, 1: Save blocked, 2: Open/Save blocked, use open policy)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $L_DifAndSylkFilesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Excel 2 macrosheets and add-in files (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Excel2MacrosheetsAndAddInFiles

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Excel2MacrosheetsAndAddInFiles (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Excel2MacrosheetsAndAddInFilesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Excel 2 worksheets (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Excel2Worksheets

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Excel2Worksheets (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Excel2WorksheetsDropID

    [DscProperty()]
    [System.ComponentModel.Description('Excel 3 macrosheets and add-in files (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Excel3MacrosheetsAndAddInFiles

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Excel3MacrosheetsAndAddInFiles (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Excel3MacrosheetsAndAddInFilesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Excel 3 worksheets (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Excel3Worksheets

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Excel3Worksheets (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Excel3WorksheetsDropID

    [DscProperty()]
    [System.ComponentModel.Description('Excel 4 macrosheets and add-in files (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Excel4MacrosheetsAndAddInFiles

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Excel4MacrosheetsAndAddInFiles (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Excel4MacrosheetsAndAddInFilesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Excel 4 workbooks (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Excel4Workbooks

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Excel4Workbooks (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Excel4WorkbooksDropID

    [DscProperty()]
    [System.ComponentModel.Description('Excel 4 worksheets (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Excel4Worksheets

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Excel4Worksheets (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Excel4WorksheetsDropID

    [DscProperty()]
    [System.ComponentModel.Description('Excel 95 workbooks (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Excel95Workbooks

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Excel95Workbooks (0: Do not block, 1: Save blocked, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '1', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Excel95WorkbooksDropID

    [DscProperty()]
    [System.ComponentModel.Description('Excel 95-97 workbooks and templates (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Excel9597WorkbooksAndTemplates

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Excel9597WorkbooksAndTemplates (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Excel9597WorkbooksAndTemplatesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Excel 97-2003 workbooks and templates (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Excel972003WorkbooksAndTemplates

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Excel972003WorkbooksAndTemplates (0: Do not block, 1: Save blocked, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '1', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Excel972003WorkbooksAndTemplatesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Set default file block behavior (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehavior

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on MicrosoftExcel_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehavior (0: Blocked files are not opened, 1: Blocked files open in Protected View and can not be edited, 2: Blocked files open in Protected View and can be edited)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehaviorDropID

    [DscProperty()]
    [System.ComponentModel.Description('Web pages and Excel 2003 XML spreadsheets (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_WebPagesAndExcel2003XMLSpreadsheets

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_WebPagesAndExcel2003XMLSpreadsheets (0: Do not block, 1: Save blocked, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '1', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_WebPagesAndExcel2003XMLSpreadsheetsDropID

    [DscProperty()]
    [System.ComponentModel.Description('Prevent Excel from running XLM macros (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_XL4KillSwitchPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Always open untrusted database files in Protected View (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_EnableDataBaseFileProtectedView

    [DscProperty()]
    [System.ComponentModel.Description('Do not open files from the Internet zone in Protected View (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_TrustCenterProtectedView_L_DoNotOpenFilesFromTheInternetZoneInProtectedView

    [DscProperty()]
    [System.ComponentModel.Description('Do not open files in unsafe locations in Protected View (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_TrustCenterProtectedView_L_DoNotOpenFilesInUnsafeLocationsInProtectedView

    [DscProperty()]
    [System.ComponentModel.Description('Set document behavior if file validation fails (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails

    [DscProperty()]
    [System.ComponentModel.Description('Checked: Allow edit.  Unchecked: Do not allow edit. (User) - Depends on MicrosoftExcel_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsStr3

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on MicrosoftExcel_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails (0: Block files, 1: Open in Protected View)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsDropID

    [DscProperty()]
    [System.ComponentModel.Description('Turn off Protected View for attachments opened from Outlook (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_TrustCenterProtectedView_L_TurnOffProtectedViewForAttachmentsOpenedFromOutlook

    [DscProperty()]
    [System.ComponentModel.Description('Require that application add-ins are signed by Trusted Publisher (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned

    [DscProperty()]
    [System.ComponentModel.Description('Disable Trust Bar Notification for unsigned application add-ins and block them (User) - Depends on MicrosoftExcel_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2

    [DscProperty()]
    [System.ComponentModel.Description('Allow Trusted Locations on the network (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_TrustCenterTrustedLocations_L_AllowTrustedLocationsOnTheNetwork

    [DscProperty()]
    [System.ComponentModel.Description('VBA Macro Notification Settings (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_TrustCenter_L_VBAWarningsPolicy

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on MicrosoftExcel_Security_TrustCenter_L_VBAWarningsPolicy (2: Disable VBA macros with notification, 3: Disable VBA macros except digitally signed macros, 4: Disable VBA macros without notification, 1: Enable VBA macros (not recommended))')]
    [ValidateSet('2', '3', '4', '1')]
    [System.Nullable[System.Int32]] $L_empty4

    [DscProperty()]
    [System.ComponentModel.Description('Turn off file validation (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftExcel_Security_L_TurnOffFileValidation

    [DscProperty()]
    [System.ComponentModel.Description('WEBSERVICE Function Notification Settings (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_WebContentWarningLevel

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on L_WebContentWarningLevel (0: Enable all WEBSERVICE functions (not recommended), 1: Disable all with notification, 2: Disable all without notification)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $L_WebContentWarningLevelValue

    [DscProperty()]
    [System.ComponentModel.Description('Disable UI extending from documents and templates (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_NoExtensibilityCustomizationFromDocumentPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Disallow in Word (User) - Depends on L_NoExtensibilityCustomizationFromDocumentPolicy (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_NoExtensibilityCustomizationFromDocumentPolicyWord

    [DscProperty()]
    [System.ComponentModel.Description('Disallow in Excel (User) - Depends on L_NoExtensibilityCustomizationFromDocumentPolicy (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_NoExtensibilityCustomizationFromDocumentPolicyExcel

    [DscProperty()]
    [System.ComponentModel.Description('Disallow in Visio (User) - Depends on L_NoExtensibilityCustomizationFromDocumentPolicy (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_NoExtensibilityCustomizationFromDocumentPolicyVisio

    [DscProperty()]
    [System.ComponentModel.Description('Disallow in PowerPoint (User) - Depends on L_NoExtensibilityCustomizationFromDocumentPolicy (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_NoExtensibilityCustomizationFromDocumentPolicyPowerPoint

    [DscProperty()]
    [System.ComponentModel.Description('Disallow in Publisher (User) - Depends on L_NoExtensibilityCustomizationFromDocumentPolicy (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_NoExtensibilityCustomizationFromDocumentPolicyPublisher

    [DscProperty()]
    [System.ComponentModel.Description('Disallow in Outlook (User) - Depends on L_NoExtensibilityCustomizationFromDocumentPolicy (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_NoExtensibilityCustomizationFromDocumentPolicyOutlook

    [DscProperty()]
    [System.ComponentModel.Description('Disallow in Project (User) - Depends on L_NoExtensibilityCustomizationFromDocumentPolicy (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_NoExtensibilityCustomizationFromDocumentPolicyProject

    [DscProperty()]
    [System.ComponentModel.Description('Disallow in InfoPath (User) - Depends on L_NoExtensibilityCustomizationFromDocumentPolicy (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_NoExtensibilityCustomizationFromDocumentPolicyInfoPath

    [DscProperty()]
    [System.ComponentModel.Description('Disallow in Access (User) - Depends on L_NoExtensibilityCustomizationFromDocumentPolicy (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_NoExtensibilityCustomizationFromDocumentPolicyAccess

    [DscProperty()]
    [System.ComponentModel.Description('ActiveX Control Initialization (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_ActiveXControlInitialization

    [DscProperty()]
    [System.ComponentModel.Description('ActiveX Control Initialization: (User) - Depends on L_ActiveXControlInitialization (1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6)')]
    [ValidateSet('1', '2', '3', '4', '5', '6')]
    [System.Nullable[System.Int32]] $L_ActiveXControlInitializationcolon

    [DscProperty()]
    [System.ComponentModel.Description('Allow Basic Authentication prompts from network proxies (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_BasicAuthProxyBehavior

    [DscProperty()]
    [System.ComponentModel.Description('Allow VBA to load typelib references by path from untrusted intranet locations (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_AllowVbaIntranetRefs

    [DscProperty()]
    [System.ComponentModel.Description('Automation Security (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_AutomationSecurity

    [DscProperty()]
    [System.ComponentModel.Description('Set the Automation Security level (User) - Depends on L_AutomationSecurity (3: Disable macros by default, 2: Use application macro security level, 1: Macros enabled (default))')]
    [ValidateSet('3', '2', '1')]
    [System.Nullable[System.Int32]] $L_SettheAutomationSecuritylevel

    [DscProperty()]
    [System.ComponentModel.Description('Control how Office handles form-based sign-in prompts (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_AuthenticationFBABehavior

    [DscProperty()]
    [System.ComponentModel.Description('Specify hosts allowed to show form-based sign-in prompts to users: (User) - Depends on L_AuthenticationFBABehavior')]
    [System.String] $L_AuthenticationFBAEnabledHostsID

    [DscProperty()]
    [System.ComponentModel.Description('Behavior: (User) - Depends on L_AuthenticationFBABehavior (1: Block all prompts, 2: Ask the user what to do for each new host, 3: Show prompts only from allowed hosts)')]
    [ValidateSet('1', '2', '3')]
    [System.Nullable[System.Int32]] $L_authenticationFBABehaviorEnum

    [DscProperty()]
    [System.ComponentModel.Description('Disable additional security checks on VBA library references that may refer to unsafe locations on the local machine (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_DisableStrictVbaRefsSecurityPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Disable all Trust Bar notifications for security issues (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_DisableallTrustBarnotificationsfor

    [DscProperty()]
    [System.ComponentModel.Description('Encryption mode for Information Rights Management (IRM) (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Encryptiontypeforirm

    [DscProperty()]
    [System.ComponentModel.Description('IRM Encryption Mode: (User) - Depends on L_Encryptiontypeforirm (1: Cipher Block Chaining (CBC), 2: Electronic Codebook (ECB))')]
    [ValidateSet('1', '2')]
    [System.Nullable[System.Int32]] $L_Encryptiontypeforirmcolon

    [DscProperty()]
    [System.ComponentModel.Description('Encryption type for password protected Office 97-2003 files (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Encryptiontypeforpasswordprotectedoffice972003

    [DscProperty()]
    [System.ComponentModel.Description('Encryption type: (User) - Depends on L_Encryptiontypeforpasswordprotectedoffice972003')]
    [System.String] $L_encryptiontypecolon318

    [DscProperty()]
    [System.ComponentModel.Description('Encryption type for password protected Office Open XML files (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Encryptiontypeforpasswordprotectedofficeopen

    [DscProperty()]
    [System.ComponentModel.Description('Encryption type: (User) - Depends on L_Encryptiontypeforpasswordprotectedofficeopen')]
    [System.String] $L_Encryptiontypecolon

    [DscProperty()]
    [System.ComponentModel.Description('Load Controls in Forms3 (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_LoadControlsinForms3

    [DscProperty()]
    [System.ComponentModel.Description('Load Controls in Forms3: (User) - Depends on L_LoadControlsinForms3 (1: 1, 2: 2, 3: 3, 4: 4)')]
    [ValidateSet('1', '2', '3', '4')]
    [System.Nullable[System.Int32]] $L_LoadControlsinForms3colon

    [DscProperty()]
    [System.ComponentModel.Description('Macro Runtime Scan Scope (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_MacroRuntimeScanScope

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on L_MacroRuntimeScanScope (0: Disable for all documents, 1: Enable for low trust documents, 2: Enable for all documents)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $L_MacroRuntimeScanScopeEnum

    [DscProperty()]
    [System.ComponentModel.Description('Protect document metadata for rights managed Office Open XML Files (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Protectdocumentmetadataforrightsmanaged

    [DscProperty()]
    [System.ComponentModel.Description('Allow mix of policy and user locations (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Allowmixofpolicyanduserlocations

    [DscProperty()]
    [System.ComponentModel.Description('Disable the Office client from polling the SharePoint Server for published links (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_DisabletheOfficeclientfrompolling

    [DscProperty()]
    [System.ComponentModel.Description('Disable Smart Document''s use of manifests (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_DisableSmartDocumentsuseofmanifests

    [DscProperty()]
    [System.ComponentModel.Description('Outlook Security Mode (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_OutlookSecurityMode

    [DscProperty()]
    [System.ComponentModel.Description('Configure Outlook object model prompt when reading address information (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_OOMAddressAccess

    [DscProperty()]
    [System.ComponentModel.Description('Guard behavior: (User) (1: Prompt User, 2: Automatically Approve, 0: Automatically Deny, 3: Prompt user based on computer security)')]
    [ValidateSet('1', '2', '0', '3')]
    [System.Nullable[System.Int32]] $L_OOMAddressAccess_Setting

    [DscProperty()]
    [System.ComponentModel.Description('Configure Outlook object model prompt when responding to meeting and task requests (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_OOMMeetingTaskRequest

    [DscProperty()]
    [System.ComponentModel.Description('Guard behavior: (User) (1: Prompt User, 2: Automatically Approve, 0: Automatically Deny, 3: Prompt user based on computer security)')]
    [ValidateSet('1', '2', '0', '3')]
    [System.Nullable[System.Int32]] $L_OOMMeetingTaskRequest_Setting

    [DscProperty()]
    [System.ComponentModel.Description('Configure Outlook object model prompt when sending mail (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_OOMSend

    [DscProperty()]
    [System.ComponentModel.Description('Guard behavior: (User) (1: Prompt User, 2: Automatically Approve, 0: Automatically Deny, 3: Prompt user based on computer security)')]
    [ValidateSet('1', '2', '0', '3')]
    [System.Nullable[System.Int32]] $L_OOMSend_Setting

    [DscProperty()]
    [System.ComponentModel.Description('Prevent users from customizing attachment security settings (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Preventusersfromcustomizingattachmentsecuritysettings

    [DscProperty()]
    [System.ComponentModel.Description('Retrieving CRLs (Certificate Revocation Lists) (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_RetrievingCRLsCertificateRevocationLists

    [DscProperty()]
    [System.ComponentModel.Description(' (0: Use system Default, 1: When online always retreive the CRL, 2: Never retreive the CRL)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $L_empty31

    [DscProperty()]
    [System.ComponentModel.Description('Configure Outlook object model prompt When accessing the Formula property of a UserProperty object (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_OOMFormula

    [DscProperty()]
    [System.ComponentModel.Description('Guard behavior: (User) (1: Prompt User, 2: Automatically Approve, 0: Automatically Deny, 3: Prompt user based on computer security)')]
    [ValidateSet('1', '2', '0', '3')]
    [System.Nullable[System.Int32]] $L_OOMFormula_Setting

    [DscProperty()]
    [System.ComponentModel.Description('Authentication with Exchange Server (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_AuthenticationwithExchangeServer

    [DscProperty()]
    [System.ComponentModel.Description('Select the authentication with Exchange server. (User) (9: Kerberos/NTLM Password Authentication, 16: Kerberos Password Authentication, 10: NTLM Password Authentication, 2147545088: Insert a smart card)')]
    [ValidateSet('9', '16', '10', '2147545088')]
    [System.String] $L_SelecttheauthenticationwithExchangeserver

    [DscProperty()]
    [System.ComponentModel.Description('Enable RPC encryption (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_EnableRPCEncryption

    [DscProperty()]
    [System.ComponentModel.Description('Allow hyperlinks in suspected phishing e-mail messages (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Enablelinksinemailmessages

    [DscProperty()]
    [System.ComponentModel.Description('Configure Outlook object model prompt when accessing an address book (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_OOMAddressBook

    [DscProperty()]
    [System.ComponentModel.Description('Guard behavior: (User) (1: Prompt User, 2: Automatically Approve, 0: Automatically Deny, 3: Prompt user based on computer security)')]
    [ValidateSet('1', '2', '0', '3')]
    [System.Nullable[System.Int32]] $L_OOMAddressBook_Setting

    [DscProperty()]
    [System.ComponentModel.Description('Outlook Security Policy: (User) - Depends on L_OutlookSecurityMode (0: Outlook Default Security, 1: Use Security Form from ''Outlook Security Settings'' Public Folder, 2: Use Security Form from ''Outlook 10 Security Settings'' Public Folder, 3: Use Outlook Security Group Policy)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $L_OutlookSecurityPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Allow users to demote attachments to Level 2 (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_AllowUsersToLowerAttachments

    [DscProperty()]
    [System.ComponentModel.Description('Allow Active X One Off Forms (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_AllowActiveXOneOffForms

    [DscProperty()]
    [System.ComponentModel.Description('Sets which ActiveX controls to allow. (0: Load only Outlook Controls, 1: Allows only Safe Controls, 2: Allows all ActiveX Controls)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $L_empty29

    [DscProperty()]
    [System.ComponentModel.Description('Allow scripts in one-off Outlook forms (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_EnableScriptsInOneOffForms

    [DscProperty()]
    [System.ComponentModel.Description('Remove file extensions blocked as Level 2 (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Level2RemoveFilePolicy

    [DscProperty()]
    [System.ComponentModel.Description('Removed Extensions: (User)')]
    [System.String] $L_removedextensions25

    [DscProperty()]
    [System.ComponentModel.Description('Use Unicode format when dragging e-mail message to file system (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_MSGUnicodeformatwhendraggingtofilesystem

    [DscProperty()]
    [System.ComponentModel.Description('Set Outlook object model custom actions execution prompt (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_OnExecuteCustomActionOOM

    [DscProperty()]
    [System.ComponentModel.Description('When executing a custom action: (User) (1: Prompt User, 2: Automatically Approve, 0: Automatically Deny, 3: Prompt user based on computer security)')]
    [ValidateSet('1', '2', '0', '3')]
    [System.Nullable[System.Int32]] $L_OnExecuteCustomActionOOM_Setting

    [DscProperty()]
    [System.ComponentModel.Description('Do not allow Outlook object model scripts to run for public folders (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_DisableOutlookobjectmodelscriptsforpublicfolders

    [DscProperty()]
    [System.ComponentModel.Description('Include Internet in Safe Zones for Automatic Picture Download (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_BlockInternet

    [DscProperty()]
    [System.ComponentModel.Description('Security setting for macros (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_SecurityLevelOutlook

    [DscProperty()]
    [System.ComponentModel.Description('Security Level (User) (2: Always warn, 4: Never warn, disable all, 3: Warn for signed, disable unsigned, 1: No security check)')]
    [ValidateSet('2', '4', '3', '1')]
    [System.Nullable[System.Int32]] $L_SecurityLevel

    [DscProperty()]
    [System.ComponentModel.Description('Remove file extensions blocked as Level 1 (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Level1RemoveFilePolicy

    [DscProperty()]
    [System.ComponentModel.Description('Removed Extensions: (User)')]
    [System.String] $L_RemovedExtensions

    [DscProperty()]
    [System.ComponentModel.Description('Signature Warning (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_SignatureWarning

    [DscProperty()]
    [System.ComponentModel.Description('Signature Warning (User) (0: Let user decide if they want to be warned, 1: Always warn about invalid signatures, 2: Never warn about invalid signatures)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $L_signaturewarning30

    [DscProperty()]
    [System.ComponentModel.Description('Display Level 1 attachments (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Level1Attachments

    [DscProperty()]
    [System.ComponentModel.Description('Minimum encryption settings (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Minimumencryptionsettings

    [DscProperty()]
    [System.ComponentModel.Description('Minimum key size (in bits): (User)')]
    [System.Nullable[System.Int32]] $L_Minimumkeysizeinbits

    [DscProperty()]
    [System.ComponentModel.Description('Do not allow Outlook object model scripts to run for shared folders (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_DisableOutlookobjectmodelscripts

    [DscProperty()]
    [System.ComponentModel.Description('Configure Outlook object model prompt when executing Save As (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_OOMSaveAs

    [DscProperty()]
    [System.ComponentModel.Description('Guard behavior: (User) (1: Prompt User, 2: Automatically Approve, 0: Automatically Deny, 3: Prompt user based on computer security)')]
    [ValidateSet('1', '2', '0', '3')]
    [System.Nullable[System.Int32]] $L_OOMSaveAs_Setting

    [DscProperty()]
    [System.ComponentModel.Description('Junk E-mail protection level (User) - Depends on L_OutlookSecurityMode (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_JunkEmailprotectionlevel

    [DscProperty()]
    [System.ComponentModel.Description('Select level: (User) (4294967295: No Protection, 6: Low (Default), 3: High, 2147483648: Trusted Lists Only)')]
    [ValidateSet('4294967295', '6', '3', '2147483648')]
    [System.String] $L_Selectlevel

    [DscProperty()]
    [System.ComponentModel.Description('Run Programs (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_RunPrograms

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on L_RunPrograms (0: disable (don''t run any programs), 1: enable (prompt user before running), 2: enable all (run without prompting))')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $L_RunPrograms_L_Empty

    [DscProperty()]
    [System.ComponentModel.Description('Scan encrypted macros in PowerPoint Open XML presentations (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Determinewhethertoforceencryptedppt

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on L_Determinewhethertoforceencryptedppt (0: Scan encrypted macros (default), 1: Scan if anti-virus software available, 2: Load macros without scanning)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $L_DeterminewhethertoforceencryptedpptDropID

    [DscProperty()]
    [System.ComponentModel.Description('Block macros from running in Office files from the Internet (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_TrustCenter_L_BlockMacroExecutionFromInternet

    [DscProperty()]
    [System.ComponentModel.Description('Disable Trust Bar Notification for unsigned application add-ins and block them (User) (Deprecated) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned

    [DscProperty()]
    [System.ComponentModel.Description('PowerPoint 97-2003 presentations, shows, templates and add-in files (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_PowerPoint972003PresentationsShowsTemplatesandAddInFiles

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_PowerPoint972003PresentationsShowsTemplatesandAddInFiles (0: Do not block, 1: Save blocked, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '1', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_PowerPoint972003PresentationsShowsTemplatesandAddInFilesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Set default file block behavior (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehavior

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on MicrosoftPowerPoint_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehavior (0: Blocked files are not opened, 1: Blocked files open in Protected View and can not be edited, 2: Blocked files open in Protected View and can be edited)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehaviorDropID

    [DscProperty()]
    [System.ComponentModel.Description('Do not open files from the Internet zone in Protected View (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_TrustCenterProtectedView_L_DoNotOpenFilesFromTheInternetZoneInProtectedView

    [DscProperty()]
    [System.ComponentModel.Description('Do not open files in unsafe locations in Protected View (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_TrustCenterProtectedView_L_DoNotOpenFilesInUnsafeLocationsInProtectedView

    [DscProperty()]
    [System.ComponentModel.Description('Set document behavior if file validation fails (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails

    [DscProperty()]
    [System.ComponentModel.Description('Checked: Allow edit.  Unchecked: Do not allow edit. (User) - Depends on MicrosoftPowerPoint_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsStr3

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on MicrosoftPowerPoint_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails (0: Block files, 1: Open in Protected View)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsDropID

    [DscProperty()]
    [System.ComponentModel.Description('Turn off Protected View for attachments opened from Outlook (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_TrustCenterProtectedView_L_TurnOffProtectedViewForAttachmentsOpenedFromOutlook

    [DscProperty()]
    [System.ComponentModel.Description('Require that application add-ins are signed by Trusted Publisher (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned

    [DscProperty()]
    [System.ComponentModel.Description('Disable Trust Bar Notification for unsigned application add-ins and block them (User) - Depends on MicrosoftPowerPoint_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2

    [DscProperty()]
    [System.ComponentModel.Description('Allow Trusted Locations on the network (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_TrustCenterTrustedLocations_L_AllowTrustedLocationsOnTheNetwork

    [DscProperty()]
    [System.ComponentModel.Description('VBA Macro Notification Settings (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_TrustCenter_L_VBAWarningsPolicy

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on MicrosoftPowerPoint_Security_TrustCenter_L_VBAWarningsPolicy (2: Disable all with notification, 3: Disable all except digitally signed macros, 4: Disable all without notification, 1: Enable all macros (not recommended))')]
    [ValidateSet('2', '3', '4', '1')]
    [System.Nullable[System.Int32]] $L_empty3

    [DscProperty()]
    [System.ComponentModel.Description('Turn off file validation (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPowerPoint_Security_L_TurnOffFileValidation

    [DscProperty()]
    [System.ComponentModel.Description('Allow Trusted Locations on the network (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftProject_Security_TrustCenter_L_AllowTrustedLocationsOnTheNetwork

    [DscProperty()]
    [System.ComponentModel.Description('Disable Trust Bar Notification for unsigned application add-ins and block them (User) (Deprecated) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftProject_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned

    [DscProperty()]
    [System.ComponentModel.Description('Require that application add-ins are signed by Trusted Publisher (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftProject_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned

    [DscProperty()]
    [System.ComponentModel.Description('Disable Trust Bar Notification for unsigned application add-ins and block them (User) - Depends on MicrosoftProject_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftProject_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2

    [DscProperty()]
    [System.ComponentModel.Description('VBA Macro Notification Settings (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftProject_Security_TrustCenter_L_VBAWarningsPolicy

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on MicrosoftProject_Security_TrustCenter_L_VBAWarningsPolicy (2: Disable all with notification, 3: Disable all except digitally signed macros, 4: Disable all without notification, 1: Enable all macros (not recommended))')]
    [ValidateSet('2', '3', '4', '1')]
    [System.Nullable[System.Int32]] $MicrosoftProject_Security_TrustCenter_L_VBAWarningsPolicy_L_Empty

    [DscProperty()]
    [System.ComponentModel.Description('Publisher Automation Security Level (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_PublisherAutomationSecurityLevel

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on L_PublisherAutomationSecurityLevel (1: Low (enabled), 2: By UI (prompted), 3: High (disabled))')]
    [ValidateSet('1', '2', '3')]
    [System.Nullable[System.Int32]] $L_PublisherAutomationSecurityLevel_L_Empty

    [DscProperty()]
    [System.ComponentModel.Description('Block macros from running in Office files from the internet (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPublisherV3_Security_TrustCenter_L_BlockMacroExecutionFromInternet

    [DscProperty()]
    [System.ComponentModel.Description('Disable Trust Bar Notification for unsigned application add-ins (User) (Deprecated) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPublisherV2_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned

    [DscProperty()]
    [System.ComponentModel.Description('Require that application add-ins are signed by Trusted Publisher (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPublisherV2_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned

    [DscProperty()]
    [System.ComponentModel.Description('Disable Trust Bar Notification for unsigned application add-ins (User) - Depends on MicrosoftPublisherV2_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPublisherV2_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2

    [DscProperty()]
    [System.ComponentModel.Description('VBA Macro Notification Settings (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftPublisherV2_Security_TrustCenter_L_VBAWarningsPolicy

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on MicrosoftPublisherV2_Security_TrustCenter_L_VBAWarningsPolicy (2: Disable all with notification, 3: Disable all except digitally signed macros, 4: Disable all without notification, 1: Enable all macros (not recommended))')]
    [ValidateSet('2', '3', '4', '1')]
    [System.Nullable[System.Int32]] $L_empty0

    [DscProperty()]
    [System.ComponentModel.Description('Allow Trusted Locations on the network (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftVisio_Security_TrustCenter_L_AllowTrustedLocationsOnTheNetwork

    [DscProperty()]
    [System.ComponentModel.Description('Block macros from running in Office files from the Internet (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftVisio_Security_TrustCenter_L_BlockMacroExecutionFromInternet

    [DscProperty()]
    [System.ComponentModel.Description('Disable Trust Bar Notification for unsigned application add-ins and block them (User) (Deprecated) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftVisio_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned

    [DscProperty()]
    [System.ComponentModel.Description('Visio 2000-2002 Binary Drawings, Templates and Stencils (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Visio2000Files

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Visio2000Files (0: Do not block, 2: Open/Save blocked)')]
    [ValidateSet('0', '2')]
    [System.Nullable[System.Int32]] $L_Visio2000FilesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Visio 2003-2010 Binary Drawings, Templates and Stencils (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Visio2003Files

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Visio2003Files (0: Do not block, 1: Save blocked, 2: Open/Save blocked)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $L_Visio2003FilesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Visio 5.0 or earlier Binary Drawings, Templates and Stencils (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Visio50AndEarlierFiles

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Visio50AndEarlierFiles (0: Do not block, 2: Open/Save blocked)')]
    [ValidateSet('0', '2')]
    [System.Nullable[System.Int32]] $L_Visio50AndEarlierFilesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Require that application add-ins are signed by Trusted Publisher (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftVisio_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned

    [DscProperty()]
    [System.ComponentModel.Description('Disable Trust Bar Notification for unsigned application add-ins and block them (User) - Depends on MicrosoftVisio_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftVisio_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2

    [DscProperty()]
    [System.ComponentModel.Description('VBA Macro Notification Settings (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftVisio_Security_TrustCenter_L_VBAWarningsPolicy

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on MicrosoftVisio_Security_TrustCenter_L_VBAWarningsPolicy (2: Disable all with notification, 3: Disable all except digitally signed macros, 4: Disable all without notification, 1: Enable all macros (not recommended))')]
    [ValidateSet('2', '3', '4', '1')]
    [System.Nullable[System.Int32]] $MicrosoftVisio_Security_TrustCenter_L_VBAWarningsPolicy_L_Empty

    [DscProperty()]
    [System.ComponentModel.Description('Block macros from running in Office files from the Internet (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_TrustCenter_L_BlockMacroExecutionFromInternet

    [DscProperty()]
    [System.ComponentModel.Description('Disable Trust Bar Notification for unsigned application add-ins and block them (User) (Deprecated) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned

    [DscProperty()]
    [System.ComponentModel.Description('Dynamic Data Exchange (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_AllowDDE

    [DscProperty()]
    [System.ComponentModel.Description('Dynamic Data Exchange setting (User) - Depends on L_AllowDDE (1: Limited Dynamic Data Exchange, 2: Allow Dynamic Data Exchange)')]
    [ValidateSet('1', '2')]
    [System.Nullable[System.Int32]] $L_AllowDDEDropID

    [DscProperty()]
    [System.ComponentModel.Description('Set default file block behavior (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehavior

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on MicrosoftWord_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehavior (0: Blocked files are not opened, 1: Blocked files open in Protected View and can not be edited, 2: Blocked files open in Protected View and can be edited)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_TrustCenterFileBlockSettings_L_SetDefaultFileBlockBehaviorDropID

    [DscProperty()]
    [System.ComponentModel.Description('Word 2 and earlier binary documents and templates (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Word2AndEarlierBinaryDocumentsAndTemplates

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Word2AndEarlierBinaryDocumentsAndTemplates (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Word2AndEarlierBinaryDocumentsAndTemplatesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Word 2000 binary documents and templates (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Word2000BinaryDocumentsAndTemplates

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Word2000BinaryDocumentsAndTemplates (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Word2000BinaryDocumentsAndTemplatesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Word 2003 binary documents and templates (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Word2003BinaryDocumentsAndTemplates

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Word2003BinaryDocumentsAndTemplates (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Word2003BinaryDocumentsAndTemplatesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Word 2007 and later binary documents and templates (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Word2007AndLaterBinaryDocumentsAndTemplates

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Word2007AndLaterBinaryDocumentsAndTemplates (0: Do not block, 1: Save blocked, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '1', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Word2007AndLaterBinaryDocumentsAndTemplatesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Word 6.0 binary documents and templates (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Word6Pt0BinaryDocumentsAndTemplates

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Word6Pt0BinaryDocumentsAndTemplates (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Word6Pt0BinaryDocumentsAndTemplatesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Word 95 binary documents and templates (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Word95BinaryDocumentsAndTemplates

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Word95BinaryDocumentsAndTemplates (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Word95BinaryDocumentsAndTemplatesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Word 97 binary documents and templates (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_Word97BinaryDocumentsAndTemplates

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_Word97BinaryDocumentsAndTemplates (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_Word97BinaryDocumentsAndTemplatesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Word XP binary documents and templates (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_WordXPBinaryDocumentsAndTemplates

    [DscProperty()]
    [System.ComponentModel.Description('File block setting: (User) - Depends on L_WordXPBinaryDocumentsAndTemplates (0: Do not block, 2: Open/Save blocked, use open policy, 3: Block, 4: Open in Protected View, 5: Allow editing and open in Protected View)')]
    [ValidateSet('0', '2', '3', '4', '5')]
    [System.Nullable[System.Int32]] $L_WordXPBinaryDocumentsAndTemplatesDropID

    [DscProperty()]
    [System.ComponentModel.Description('Do not open files from the Internet zone in Protected View (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_TrustCenterProtectedView_L_DoNotOpenFilesFromTheInternetZoneInProtectedView

    [DscProperty()]
    [System.ComponentModel.Description('Do not open files in unsafe locations in Protected View (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_TrustCenterProtectedView_L_DoNotOpenFilesInUnsafeLocationsInProtectedView

    [DscProperty()]
    [System.ComponentModel.Description('Set document behavior if file validation fails (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on MicrosoftWord_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails (0: Block files, 1: Open in Protected View)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsDropID

    [DscProperty()]
    [System.ComponentModel.Description('Checked: Allow edit.  Unchecked: Do not allow edit. (User) - Depends on MicrosoftWord_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFails (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_TrustCenterProtectedView_L_SetDocumentBehaviorIfFileValidationFailsStr3

    [DscProperty()]
    [System.ComponentModel.Description('Turn off Protected View for attachments opened from Outlook (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_TrustCenterProtectedView_L_TurnOffProtectedViewForAttachmentsOpenedFromOutlook

    [DscProperty()]
    [System.ComponentModel.Description('Require that application add-ins are signed by Trusted Publisher (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned

    [DscProperty()]
    [System.ComponentModel.Description('Disable Trust Bar Notification for unsigned application add-ins and block them (User) - Depends on MicrosoftWord_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_TrustCenter_L_DisableTrustBarNotificationforunsigned_v2

    [DscProperty()]
    [System.ComponentModel.Description('Scan encrypted macros in Word Open XML documents (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_DeterminewhethertoforceencryptedWord

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on L_DeterminewhethertoforceencryptedWord (0: Scan encrypted macros (default), 1: Scan if anti-virus software available, 2: Load macros without scanning)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $L_DeterminewhethertoforceencryptedWordDropID

    [DscProperty()]
    [System.ComponentModel.Description('VBA Macro Notification Settings (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_TrustCenter_L_VBAWarningsPolicy

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on MicrosoftWord_Security_TrustCenter_L_VBAWarningsPolicy (2: Disable all with notification, 3: Disable all except digitally signed macros, 4: Disable all without notification, 1: Enable all macros (not recommended))')]
    [ValidateSet('2', '3', '4', '1')]
    [System.Nullable[System.Int32]] $L_empty19

    [DscProperty()]
    [System.ComponentModel.Description('Turn off file validation (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_L_TurnOffFileValidation

    [DscProperty()]
    [System.ComponentModel.Description('Allow Trusted Locations on the network (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftWord_Security_TrustCenterTrustedLocations_L_AllowTrustedLocationsOnTheNetwork

    [DscProperty()]
    [System.ComponentModel.Description('File Block includes external link files (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_ExcelFileBlockExternalLinks

    [DscProperty()]
    [System.ComponentModel.Description('Block Insecure Protocols (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_BlockInsecureProtocols

    [DscProperty()]
    [System.ComponentModel.Description('Block OLE Graph (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_BlockOLEGraph

    [DscProperty()]
    [System.ComponentModel.Description('Block OrgChart (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_BlockOrgChart

    [DscProperty()]
    [System.ComponentModel.Description('Restrict Apps from FPRPC Fallback (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_BlockWecFallback

    [DscProperty()]
    [System.ComponentModel.Description('OLE Active Content (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $L_OLEActions

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on L_OLEActions (0: disable (don''t allow activating OLE Active Content), 1: enable (prompt user before activating OLE Active Content), 2: enable all (allow activating OLE Active Content without prompting))')]
    [ValidateSet('0', '1', '2')]
    [System.String] $L_OLEActions_L_Empty

    [DscProperty()]
    [System.ComponentModel.Description('Block macros from running in Office files from the internet (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $MicrosoftProjectV3_Security_TrustCenter_L_BlockMacroExecutionFromInternet
}

class MSFT_DeviceManagementConfigurationPolicyAssignments
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the target assignment.')]
    [ValidateSet('#microsoft.graph.cloudPcManagementGroupAssignmentTarget', '#microsoft.graph.groupAssignmentTarget', '#microsoft.graph.allLicensedUsersAssignmentTarget', '#microsoft.graph.allDevicesAssignmentTarget', '#microsoft.graph.exclusionGroupAssignmentTarget', '#microsoft.graph.configurationManagerCollectionAssignmentTarget')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('The type of filter of the target assignment i.e. Exclude or Include. Possible values are:none, include, exclude.')]
    [ValidateSet('none', 'include', 'exclude')]
    [System.String] $deviceAndAppManagementAssignmentFilterType

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterId

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The group Id that is the target of the assignment.')]
    [System.String] $groupId

    [DscProperty()]
    [System.ComponentModel.Description('The group Display Name that is the target of the assignment.')]
    [System.String] $groupDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The collection Id that is the target of the assignment.(ConfigMgr)')]
    [System.String] $collectionId
}
