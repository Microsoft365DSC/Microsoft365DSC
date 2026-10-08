[DscResource()]
class TestCatalogNone
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name.')]
    [System.String] $DisplayName

    [TestCatalogNone] Get()
    {
        return $this
    }

    [void] Set()
    {
        # The templateReferenceId of this policy is chosen by the caller.
        $filter = "templateReferenceId eq '33333333-3333-3333-3333-333333333333_1'"
        Write-Verbose -Message $filter
    }

    [System.Boolean] Test()
    {
        return $true
    }
}
