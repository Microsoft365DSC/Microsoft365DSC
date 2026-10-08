using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOMailboxPermission : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Identity parameter specifies the mailbox where you want to assign permissions to the user. You can use any value that uniquely identifies the mailbox.')]
    [System.String] $Identity

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The AccessRights parameter specifies the permission that you want to add for the user on the mailbox. Valid values are: ChangeOwner, ChangePermission, DeleteItem, ExternalAccount, FullAccess and ReadPermission.')]
    [System.String[]] $AccessRights

    [DscProperty(Key)]
    [System.ComponentModel.Description('The User parameter specifies who gets the permissions on the mailbox.')]
    [System.String] $User

    [DscProperty(Key)]
    [System.ComponentModel.Description('The InheritanceType parameter specifies how permissions are inherited by folders in the mailbox. Valid values are: None, All, Children, Descendents, SelfAndChildren.')]
    [ValidateSet('None', 'All', 'Children', 'Descendents', 'SelfAndChildren')]
    [System.String] $InheritanceType

    [DscProperty()]
    [System.ComponentModel.Description('The Owner parameter specifies the owner of the mailbox object.')]
    [System.String] $Owner

    [DscProperty()]
    [System.ComponentModel.Description('The Deny switch specifies that the permissions you''re adding are Deny permissions.')]
    [System.Nullable[System.Boolean]] $Deny

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether or not the permission should exist on the mailbox.')]
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

    [EXOMailboxPermission] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOMailboxPermission]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting permissions for Mailbox {$($this.Identity)}"

        try
        {
            if (-not $this.ExportedInstance -or $null -eq $this.ResourceCache['UsersCache'] -or $this.ResourceCache['UsersCache'][$this.ExportedInstance.Identity] -ne $this.Identity)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = @{
                    Identity = $this.Identity
                    Ensure   = 'Absent'
                }

                [Array]$permissions = Get-MailboxPermission -Identity $this.Identity -ErrorAction SilentlyContinue
                $permission = $permissions | Where-Object -FilterScript { $_.User -eq $this.User -and (Compare-Object -ReferenceObject $_.AccessRights.Replace(' ', '').Split(',') -DifferenceObject $this.AccessRights).Count -eq 0 }

                if ($null -eq $permission)
                {
                    Write-Verbose -Message "Permission for mailbox {$($this.Identity)} do not exist."
                    return $this.AsResult($nullResult)
                }

                $userInfo = (Get-User -Identity $permission.Identity).UserPrincipalName
            }
            else
            {
                $permission = $this.ExportedInstance
                $userInfo = $this.ResourceCache['UsersCache'][$permission.Identity]
            }

            $result = @{
                Identity              = $userInfo
                AccessRights          = [System.String[]]$permission.AccessRights.Replace(' ', '').Split(',')
                InheritanceType       = $permission.InheritanceType
                Owner                 = $permission.Owner
                User                  = $permission.User
                Deny                  = [Boolean]$permission.Deny
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                TenantId              = $this.TenantId
                AccessTokens          = $this.AccessTokens
            }

            Write-Verbose -Message "Found permissions for mailbox {$($this.Identity)}"
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

        Write-Verbose -Message "Setting configuration of Mailbox Permissions for {$($this.Identity)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentValues = $this.Get().ToHashtable()
        $instanceParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Adding new permission for user {$($this.User)} on Mailbox {$($this.Identity)}"
            Add-MailboxPermission @instanceParams | Out-Null
        }
        elseif ($this.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Removing permission for user {$($this.User)} on Mailbox {$($this.Identity)}"
            Remove-MailboxPermission @instanceParams
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$mailboxes = Get-M365DSCExportCachedCollection -Collection 'exoMailboxes'
            if ($mailboxes.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($null -eq $this.ResourceCache['UsersCache'])
            {
                $this.ResourceCache['UsersCache'] = [System.Collections.Generic.Dictionary[System.String, System.String]]::new()
                [array]$exoUsers = Get-M365DSCExportCachedCollection -Collection 'exoUsers'
                foreach ($exoUser in $exoUsers)
                {
                    $this.ResourceCache['UsersCache'][$exoUser.Identity] = $exoUser.UserPrincipalName
                }
            }
            foreach ($mailbox in $mailboxes)
            {
                Write-M365DSCHost -Message "    |---[$i/$($mailboxes.Count)] $($mailbox.UserPrincipalName)" -DeferWrite

                [Array]$permissions = Get-MailboxPermission -Identity $mailbox.UserPrincipalName

                $j = 1
                Write-M365DSCHost -Message "`r`n" -DeferWrite
                foreach ($permission in $permissions)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "        |---[$j/$($permissions.Count)] $($permission.Identity)" -DeferWrite
                    $Params = @{
                        Identity              = $mailbox.UserPrincipalName
                        AccessRights          = [System.String[]]$permission.AccessRights.Replace(' ', '').Replace('SendAs,', '').Split(',') # ignore SendAs permissions since they are not supported by *-MailboxPermission cmdlets
                        InheritanceType       = $permission.InheritanceType
                        User                  = $permission.User
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        CertificatePath       = $this.CertificatePath
                        AccessTokens          = $this.AccessTokens
                    }

                    $this.ExportedInstance = $permission
                    $Results = $this.GetForExport($Params)
                    if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
                    {
                        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                            -ConnectionMode $ConnectionMode `
                            -ModulePath $this.GetModulePath() `
                            -Results $Results `
                            -Credential $this.Credential
                        [void]$dscContent.Append($currentDSCBlock)

                        Save-M365DSCPartialExport -Content $currentDSCBlock `
                            -FileName $Global:PartialExportFileName

                        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    }
                    else
                    {
                        Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
                    }
                    $j++
                }

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

    hidden [EXOMailboxPermission] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOMailboxPermission])
        {
            return $Values
        }

        $result = [EXOMailboxPermission]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
