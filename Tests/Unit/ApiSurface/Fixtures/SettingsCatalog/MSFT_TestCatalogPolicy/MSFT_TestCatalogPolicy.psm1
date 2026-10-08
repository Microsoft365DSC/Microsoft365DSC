class TestCatalogPolicyDeviceSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('A setting scoped to the device.')]
    [System.String] $DeviceScopedSetting
}

[DscResource()]
class TestCatalogPolicy
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('A setting the template already carries.')]
    [ValidateSet('0', '1')]
    [System.String] $CRLcheck

    [DscProperty()]
    [System.ComponentModel.Description('The device scoped settings.')]
    [TestCatalogPolicyDeviceSettings] $DeviceSettings

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [System.String] $ExportOnly

    [TestCatalogPolicy] Get()
    {
        return $this
    }

    [void] Set()
    {
        $templateReferenceId = '11111111-1111-1111-1111-111111111111_2'
        Write-Verbose -Message $templateReferenceId
    }

    [System.Boolean] Test()
    {
        return $true
    }
}
