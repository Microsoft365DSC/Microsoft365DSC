<#
.SYNOPSIS
    Emits the resource's readme.md.
#>
function New-M365DSCReadmeFile
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel,

        [Parameter()]
        [System.String]
        $DestinationPath
    )

    $templatePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Templates\readme.template.md'
    $tokens = @{
        ResourceFriendlyName = $ResourceModel.ResourceName
        ResourceDescription  = "This resource configures a $($ResourceModel.ResourceDescription)."
    }

    if ($PSBoundParameters.ContainsKey('DestinationPath'))
    {
        return (Expand-M365DSCTemplate -TemplatePath $templatePath -Tokens $tokens -DestinationPath $DestinationPath)
    }

    return (Expand-M365DSCTemplate -TemplatePath $templatePath -Tokens $tokens)
}
