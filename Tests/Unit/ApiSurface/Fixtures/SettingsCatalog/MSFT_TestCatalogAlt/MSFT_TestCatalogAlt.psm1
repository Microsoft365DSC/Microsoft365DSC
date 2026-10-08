[DscResource()]
class TestCatalogAlt
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name.')]
    [System.String] $DisplayName

    [TestCatalogAlt] Get()
    {
        return $this
    }

    [void] Set()
    {
        $policyTemplateId = '22222222-2222-2222-2222-222222222222_1'
        Write-Verbose -Message $policyTemplateId
    }

    [System.Boolean] Test()
    {
        return $true
    }
}
