using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOPlace : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the room mailbox that you want to modify. You can use any value that uniquely identifies the room.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the place.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The AudioDeviceName parameter specifies the name of the audio device in the room. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $AudioDeviceName

    [DscProperty()]
    [System.ComponentModel.Description('The Building parameter specifies the building name or building number that the room is in. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $Building

    [DscProperty()]
    [System.ComponentModel.Description('The Capacity parameter specifies the capacity of the room. A valid value is an integer.')]
    [System.Nullable[System.UInt32]] $Capacity

    [DscProperty()]
    [System.ComponentModel.Description('The City parameter specifies the room''s city. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $City

    [DscProperty()]
    [System.ComponentModel.Description('The CountryOrRegion parameter specifies the room''s country or region. A valid value is a valid ISO 3166-1 two-letter country code (for example, AU for Australia) or the corresponding friendly name for the country (which might be different from the official ISO 3166 Maintenance Agency short name).')]
    [System.String] $CountryOrRegion

    [DscProperty()]
    [System.ComponentModel.Description('The DisplayDeviceName parameter specifies the name of the display device in the room. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $DisplayDeviceName

    [DscProperty()]
    [System.ComponentModel.Description('The Floor parameter specifies the floor number that the room is on.')]
    [System.String] $Floor

    [DscProperty()]
    [System.ComponentModel.Description('The FloorLabel parameter specifies a descriptive label for the floor that the room is on. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $FloorLabel

    [DscProperty()]
    [System.ComponentModel.Description('The GeoCoordinates parameter specifies the room''s location in latitude, longitude and (optionally) altitude coordinates.')]
    [System.String] $GeoCoordinates

    [DscProperty()]
    [System.ComponentModel.Description('The IsWheelChairAccessible parameter specifies whether the room is wheelchair accessible.')]
    [System.Nullable[System.Boolean]] $IsWheelChairAccessible

    [DscProperty()]
    [System.ComponentModel.Description('The Label parameter specifies a descriptive label for the room (for example, a number or name). If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $Label

    [DscProperty()]
    [System.ComponentModel.Description('The MTREnabled parameter identifies the room as configured with a Microsoft Teams room system. You can add Teams room systems as audio sources in Teams meetings that involve the room.')]
    [System.Nullable[System.Boolean]] $MTREnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ParentId parameter specifies the ID of a Place in the parent location hierarchy in Microsoft Places.')]
    [System.String] $ParentId

    [DscProperty()]
    [System.ComponentModel.Description('The ParentType parameter specifies the parent type of the ParentId in Microsoft Places. Valid values are: Floor, Section')]
    [ValidateSet('Floor', 'Section', 'None')]
    [System.String] $ParentType

    [DscProperty()]
    [System.ComponentModel.Description('The Phone parameter specifies the room''s telephone number.')]
    [System.String] $Phone

    [DscProperty()]
    [System.ComponentModel.Description('The PostalCode parameter specifies the room''s postal code.')]
    [System.String] $PostalCode

    [DscProperty()]
    [System.ComponentModel.Description('The State parameter specifies the room''s state or province.')]
    [System.String] $State

    [DscProperty()]
    [System.ComponentModel.Description('The Street parameter specifies the room''s physical address.')]
    [System.String] $Street

    [DscProperty()]
    [System.ComponentModel.Description('The Tags parameter specifies additional features of the room (for example, details like the type of view or furniture type).')]
    [System.String[]] $Tags

    [DscProperty()]
    [System.ComponentModel.Description('The VideoDeviceName parameter specifies the name of the video device in the room. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $VideoDeviceName

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this Outbound connector should exist.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

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

    [EXOPlace] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOPlace]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Place for $($this.Identity)"

        $boundParameters = $this.GetBoundParameters()

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $boundParameters
                $nullReturn.Ensure = 'Absent'

                $place = Get-Place -Identity $this.Identity -ErrorAction SilentlyContinue
                if ($null -eq $place)
                {
                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        Write-Verbose -Message "Couldn't retrieve place by Id {$($this.Identity)}. Trying by DisplayName"
                        $place = Get-Place -ResultSize 'Unlimited' | Where-Object -FilterScript { $_.DisplayName -eq $this.DisplayName }
                    }

                    if ($null -eq $place)
                    {
                        return $this.AsResult($nullReturn)
                    }
                }
            }
            else
            {
                $place = $this.ExportedInstance
            }

            Write-Verbose -Message "Found Place with Identity {$($this.Identity)}"

            $TagsValue = [Array] $place.Tags
            if ($null -eq $place.Tags)
            {
                $TagsValue = @()
            }

            $result = @{
                Identity               = $place.Identity
                AudioDeviceName        = $place.AudioDeviceName
                Building               = $place.Building
                Capacity               = $place.Capacity
                City                   = $place.City
                CountryOrRegion        = $place.CountryOrRegion
                DisplayDeviceName      = $place.DisplayDeviceName
                DisplayName            = $place.DisplayName
                Floor                  = $place.Floor
                FloorLabel             = $place.FloorLabel
                GeoCoordinates         = $place.GeoCoordinates
                IsWheelChairAccessible = [Boolean] $place.IsWheelChairAccessible
                Label                  = $place.Label
                MTREnabled             = [Boolean] $place.MTREnabled
                ParentId               = $place.ParentId
                ParentType             = $place.ParentType
                Phone                  = $place.Phone
                PostalCode             = $place.PostalCode
                State                  = $place.State
                Street                 = $place.Street
                Tags                   = $TagsValue
                VideoDeviceName        = $place.VideoDeviceName
                Credential             = $this.Credential
                Ensure                 = 'Present'
                ApplicationId          = $this.ApplicationId
                CertificateThumbprint  = $this.CertificateThumbprint
                CertificatePath        = $this.CertificatePath
                CertificatePassword    = $this.CertificatePassword
                ManagedIdentity        = $this.ManagedIdentity
                TenantId               = $this.TenantId
                AccessTokens           = $this.AccessTokens
            }

            return $this.AsResult($result)
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

        Write-Verbose -Message "Setting configuration of Place for $($this.Identity)"

        $boundParameters = $this.GetBoundParameters()

        $null = $this.Connect('ExchangeOnline')

        $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $boundParameters

        $updateParameters.Remove('DisplayName') | Out-Null

        if ([System.String]::IsNullOrEmpty($this.ParentId) -and $null -ne $this.ParentType)
        {
            Write-Verbose -Message 'ParentId is $null, removing ParentType.'
            $updateParameters.Remove('ParentType') | Out-Null
        }
        Set-Place @updateParameters
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')
        try
        {
            [array]$places = Get-Place -ResultSize 'Unlimited' -ErrorAction Stop | `
                    Where-Object -FilterScript { $_.PlaceType -ne 'RoomList' }
            $dscContent = [System.Text.StringBuilder]::new()

            if ($places.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($place in $places)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($places.Length)] $($place.Identity)" -DeferWrite

                $Params = @{
                    Identity              = $place.Identity
                    DisplayName           = $place.DisplayName
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $place
                $Results = $this.GetForExport($Params)
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOPlace] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOPlace])
        {
            return $Values
        }

        $result = [EXOPlace]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
