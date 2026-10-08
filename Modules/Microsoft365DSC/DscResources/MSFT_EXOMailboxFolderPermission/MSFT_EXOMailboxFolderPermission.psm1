using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOMailboxFolderPermission : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the target mailbox and folder. The syntax is MailboxID:\\ParentFolder[\\SubFolder]. For the MailboxID you can use any value that uniquely identifies the mailbox.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Mailbox Folder Permissions for the current user.')]
    [MSFT_EXOMailboxFolderUserPermission[]] $UserPermissions

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether or not the permission should exist on the mailbox. This resource cannot be removed and the value must be set to ''Ensure''.')]
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

    [EXOMailboxFolderPermission] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOMailboxFolderPermission]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Mailbox Folder Permission with Identity {$($this.Identity)}"

        try
        {
            $null = $this.Connect('ExchangeOnline')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $instances = Get-MailboxFolderPermission -Identity $this.Identity -ErrorAction SilentlyContinue
            if ($null -eq $instances)
            {
                Write-Verbose -Message "No Mailbox Folder Permissions found for $($this.Identity)"
                return $this.AsResult($nullResult)
            }

            $permissionsObj = @()
            foreach ($mailboxfolderPermission in $instances)
            {
                $currentPermission = @{}
                $currentPermission.Add('User', $mailboxFolderPermission.User.ToString())
                $currentPermission.Add('AccessRights', [System.String[]]@($mailboxFolderPermission.AccessRights | ForEach-Object { $_.ToString() }))
                if ($null -ne $mailboxFolderPermission.SharingPermissionFlags)
                {
                    $currentPermission.Add('SharingPermissionFlags', $mailboxFolderPermission.SharingPermissionFlags)
                }
                $permissionsObj += $currentPermission
            }

            $results = @{
                Identity              = $this.Identity
                UserPermissions       = $permissionsObj
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }
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
        $currentValues = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of Mailbox Folder Permission with Identity {$($this.Identity)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $currentMailboxFolderPermissions = $currentInstance.UserPermissions

        if ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "There was some error in fetching the mailbox folder permissions for the folder {$($this.Identity)}."
            return
        }
        elseif ($this.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Supplying Ensure = 'Absent' doesn't remove the permissions for the current mailbox folder. Send an array of required permissions instead."
            return
        }

        # Remove all the current existing pemrissions on this folder.
        # Skip removing the default and anonymous permissions, as can't be removed, and should just be directly updated.
        foreach ($currentUserPermission in $currentMailboxFolderPermissions)
        {
            if ($currentUserPermission.User.ToString().ToLower() -ne 'default' -and $currentUserPermission.User.ToString().ToLower() -ne 'anonymous')
            {
                Remove-MailboxFolderPermission -Identity $this.Identity -User $currentUserPermission.User -Confirm:$false
            }
        }

        # Add the desired state permissions on the mailbox folder
        # For Default and anonymous users, as the permissions were not removed, we just need to call set.
        foreach ($userPermission in $this.UserPermissions)
        {
            if ($userPermission.User.ToString().ToLower() -eq 'default' -or $userPermission.User.ToString().ToLower() -eq 'anonymous')
            {
                if ($userPermission.SharingPermissionFlags -eq '')
                {
                    Set-MailboxFolderPermission -Identity $this.Identity -User $userPermission.User -AccessRights $userPermission.AccessRights
                }
                else
                {
                    Set-MailboxFolderPermission -Identity $this.Identity -User $userPermission.User -AccessRights $userPermission.AccessRights -SharingPermissionFlags $userPermission.SharingPermissionFlags
                }
            }
            else
            {
                if ($userPermission.SharingPermissionFlags -eq '')
                {
                    Add-MailboxFolderPermission -Identity $this.Identity -User $userPermission.User -AccessRights $userPermission.AccessRights
                }
                else
                {
                    Add-MailboxFolderPermission -Identity $this.Identity -User $userPermission.User -AccessRights $userPermission.AccessRights -SharingPermissionFlags $userPermission.SharingPermissionFlags
                }
            }
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $mailboxes = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            # Ensure the cmdlet is available
            $dscContent = [System.Text.StringBuilder]::new()
            $cmdletInfo = Get-Command Get-MailboxFolder -ErrorAction SilentlyContinue

            if ($null -eq $cmdletInfo)
            {
                Write-M365DSCHost -Message "    `r`n$($Global:M365DSCEmojiYellowCircle) The Get-MailboxFolder cmdlet is not available. Service Principals do not have mailboxes." -CommitWrite
                return ''
            }

            [Array]$mailboxFolders = Get-MailboxFolder -Recurse

            if ($mailboxes.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            $j = 1
            foreach ($mailboxFolder in $mailboxFolders)
            {
                Write-M365DSCHost -Message "        |---[$j/$($mailboxFolders.Count)] $($mailboxFolder.Identity)" -DeferWrite
                Write-M365DSCHost -Message "`r`n" -DeferWrite

                $Params = @{
                    Identity              = $mailboxFolder.Identity
                    UserPermissions       = $null
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $MailboxFolderPermissions = $this.GetForExport($Params)

                $Result = $MailboxFolderPermissions
                if ($Result.UserPermissions)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Result.UserPermissions `
                        -CIMInstanceName 'EXOMailboxFolderUserPermission' `
                        -IsArray
                    if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                    {
                        $Result.UserPermissions = $complexTypeStringResult
                    }
                    else
                    {
                        $Result.Remove('UserPermissions') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Result `
                    -Credential $this.Credential `
                    -NoEscape @('UserPermissions')

                [void]$dscContent.Append($currentDSCBlock)

                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName

                $j++
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOMailboxFolderPermission] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOMailboxFolderPermission])
        {
            return $Values
        }

        $result = [EXOMailboxFolderPermission]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_EXOMailboxFolderUserPermission
{
    [DscProperty()]
    [System.ComponentModel.Description('The AccessRights parameter specifies the permissions that you want to add for the user on the mailbox folder.')]
    [System.String[]] $AccessRights

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The User parameter specifies who gets the permissions on the mailbox folder.')]
    [System.String] $User

    [DscProperty()]
    [System.ComponentModel.Description('The SharingPermissionFlags parameter assigns calendar delegate permissions. This parameter only applies to calendar folders and can only be used when the AccessRights parameter value is Editor. Valid values are: None, Delegate, CanViewPrivateItems')]
    [System.String] $SharingPermissionFlags
}
