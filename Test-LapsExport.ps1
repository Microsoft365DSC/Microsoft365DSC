# Requires Microsoft365DSC module to be installed and basic authentication configured.
# You will be prompted to authenticate to your Microsoft 365 Tenant.

Write-Host "Exporting AADDeviceRegistrationPolicy configuration..."

# Export the AADDeviceRegistrationPolicy to check if LocalAdminPasswordIsEnabled is captured correctly
Export-M365DSCConfiguration -Components @("AADDeviceRegistrationPolicy") -Path ".\TenantConfig"

Write-Host "Export completed. Please check the generated configuration in the .\TenantConfig folder."
Write-Host "Verify if the LocalAdminPasswordIsEnabled property is present and matches the value in your Entra portal."
