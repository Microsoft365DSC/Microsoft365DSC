using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft365DSC.Reporting.Markdown;

namespace Microsoft365DSC.Reporting
{
    /// <summary>
    /// Holds the available report converters, keyed by format name. The Markdown converter is
    /// registered by default. Further formats register themselves through <see cref="Register"/>.
    /// </summary>
    public static class ReportConverterRegistry
    {
        private static readonly Dictionary<string, IReportConverter> Converters =
            new Dictionary<string, IReportConverter>(StringComparer.OrdinalIgnoreCase)
            {
                [MarkdownReportConverter.FormatName] = new MarkdownReportConverter()
            };

        /// <summary>The names of the formats that can be converted.</summary>
        public static IEnumerable<string> Formats => Converters.Keys.OrderBy(format => format, StringComparer.Ordinal);

        /// <summary>
        /// Registers a converter, replacing the one previously registered for its format.
        /// </summary>
        /// <param name="converter">The converter to register.</param>
        public static void Register(IReportConverter converter)
        {
            if (converter is null)
            {
                throw new ArgumentNullException(nameof(converter));
            }

            Converters[converter.Format] = converter;
        }

        /// <summary>
        /// Returns the converter registered for a format.
        /// </summary>
        /// <param name="format">The format name, compared without case sensitivity.</param>
        /// <returns>The converter for the format.</returns>
        public static IReportConverter Resolve(string format)
        {
            if (format is not null && Converters.TryGetValue(format, out IReportConverter? converter))
            {
                return converter;
            }

            throw new NotSupportedException($"No report converter is registered for format '{format}'.");
        }

        /// <summary>
        /// Converts a request with the converter registered for a format.
        /// </summary>
        /// <param name="format">The format name, compared without case sensitivity.</param>
        /// <param name="request">The resources to convert and the options to convert them with.</param>
        /// <returns>The paths of the files that were written.</returns>
        public static string[] Convert(string format, ReportRequest request)
        {
            return Resolve(format).Convert(request);
        }
    }
}
