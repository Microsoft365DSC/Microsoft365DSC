namespace Microsoft365DSC.Reporting
{
    /// <summary>
    /// Converts parsed configuration resources into one report format. Implement this interface
    /// and register it with <see cref="ReportConverterRegistry"/> to add a format.
    /// </summary>
    public interface IReportConverter
    {
        /// <summary>The name of the format this converter produces, as used by the callers.</summary>
        string Format { get; }

        /// <summary>
        /// Converts the resources of the request and returns the paths of the files written.
        /// </summary>
        /// <param name="request">The resources to convert and the options to convert them with.</param>
        /// <returns>The paths of the files that were written.</returns>
        string[] Convert(ReportRequest request);
    }
}
