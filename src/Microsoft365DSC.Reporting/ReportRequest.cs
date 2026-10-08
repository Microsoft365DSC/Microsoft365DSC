using System;
using System.Collections;
using System.Collections.Generic;
using Microsoft365DSC.Reporting.Configuration;

namespace Microsoft365DSC.Reporting
{
    /// <summary>
    /// Describes a single report conversion. It names what to convert, where to write it and
    /// how much detail the output carries.
    /// </summary>
    public sealed class ReportRequest
    {
        /// <summary>The parsed configuration resources, one dictionary per resource instance.</summary>
        public IEnumerable<IDictionary> Resources { get; set; } = new List<IDictionary>();

        /// <summary>The folder the converter writes its output to.</summary>
        public string OutputPath { get; set; } = string.Empty;

        /// <summary>
        /// The root of the Microsoft365DSC module, used to resolve the resource metadata a
        /// converter needs. Ignored when <see cref="Metadata"/> is supplied.
        /// </summary>
        public string ModuleRoot { get; set; } = string.Empty;

        /// <summary>The resource metadata source. Built from <see cref="ModuleRoot"/> when not set.</summary>
        public IResourceMetadataSource? Metadata { get; set; }

        /// <summary>The tenant domain name that is replaced by a portable token in every value.</summary>
        public string? OrganizationName { get; set; }

        /// <summary>The tenant identifier that is replaced by a portable token in every value.</summary>
        public string? TenantGuid { get; set; }

        /// <summary>
        /// When false, the report carries the name, data type and value of every property the
        /// configuration sets. When true, it carries every property the resource supports, set or
        /// not, with its attribute, allowed values and description, and the resource permissions.
        /// </summary>
        public bool IncludeAllInformation { get; set; }

        /// <summary>
        /// When false, every resource instance lands in a single document. When true, each
        /// instance becomes its own document in a folder per workload.
        /// </summary>
        public bool SplitByResource { get; set; }

        /// <summary>Whether resource instances that repeat their mandatory properties are skipped.</summary>
        public bool SuppressDuplicates { get; set; }

        /// <summary>The mandatory properties per resource type, required for duplicate suppression.</summary>
        public IMandatoryPropertySource? MandatoryProperties { get; set; }

        /// <summary>Receives the warnings raised while converting.</summary>
        public Action<string>? Warn { get; set; }
    }
}
