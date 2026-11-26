using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using Microsoft365DSC.Reporting.Configuration;
using Microsoft365DSC.Utilities;

namespace Microsoft365DSC.Reporting.Markdown
{
    /// <summary>
    /// Writes the resource instances of a configuration as Markdown, either as a single document
    /// or as one document per instance in a folder per workload.
    /// </summary>
    public sealed class MarkdownReportConverter : IReportConverter
    {
        /// <summary>The name of the format this converter produces.</summary>
        public const string FormatName = "Markdown";

        private const string LineBreak = "\r\n";
        private const string MarkdownPattern = "*.md";
        private const string MarkdownExtension = ".md";
        private const string DefaultFileName = "M365Report";
        private const string MissingMandatoryPropertySource = "Duplicate suppression requires mandatory properties.";

        private static readonly ISet<string> AuthenticationProperties =
            new HashSet<string>(Utilities.Utilities.AuthenticationPropertyNames, StringComparer.OrdinalIgnoreCase);

        private static readonly Encoding OutputEncoding = new UTF8Encoding(true);

        /// <inheritdoc />
        public string Format => FormatName;

        /// <inheritdoc />
        public string[] Convert(ReportRequest request)
        {
            if (request.SuppressDuplicates && request.MandatoryProperties is null)
            {
                throw new ArgumentException(MissingMandatoryPropertySource, nameof(request));
            }

            Action<string> warn = request.Warn ?? (_ => { });
            IEnumerable<ConfigurationResource> resources = request.Resources
                .Select(ConfigurationResource.FromDictionary);
            if (request.SuppressDuplicates)
            {
                resources = DuplicateSuppressor.Filter(resources, request.MandatoryProperties!, warn);
            }

            IResourceMetadataSource metadata = request.Metadata ?? new ModuleMetadataSource(request.ModuleRoot);
            MarkdownTemplateBuilder builder = new(
                metadata,
                request.IncludeAllInformation,
                warn);
            ValueEncoder encoder = new(request.OrganizationName, request.TenantGuid);
            Dictionary<string, MarkdownTemplate?> templates = new(StringComparer.OrdinalIgnoreCase);
            List<MarkdownDocument> documents = [];

            foreach (ConfigurationResource resource in resources)
            {
                string? area = InstanceFileNamer.ResolveArea(resource.Type);
                if (area is null)
                {
                    warn($"Skipping resource instance '{resource.InstanceName}' of unknown area '{resource.Type}'.");
                    continue;
                }

                if (!templates.TryGetValue(resource.Type, out MarkdownTemplate? template))
                {
                    template = builder.Build(resource.Type);
                    templates[resource.Type] = template;
                }

                if (template is null)
                {
                    continue;
                }

                string title = InstanceFileNamer.Sanitize(encoder.ReplaceTenantTokens(resource.InstanceName));
                string content = Render(title, template, resource, encoder, request.IncludeAllInformation);
                documents.Add(new(area, title, content));
            }

            return request.SplitByResource
                ? WritePerResource(request.OutputPath, documents)
                : [WriteSingleDocument(request.OutputPath, documents)];
        }

        internal static string Render(
            string title,
            MarkdownTemplate template,
            ConfigurationResource resource,
            ValueEncoder encoder,
            bool includeUnsetProperties)
        {
            NestedTableBuilder builder = new(template, encoder, includeUnsetProperties);
            List<string> mainRows = builder.FillMainTable(resource.Properties, AuthenticationProperties);

            IEnumerable<string> lines = new[] { "# " + title }
                .Concat(template.MainTable.HeaderLines)
                .Concat(mainRows)
                .Concat([string.Empty])
                .Concat(builder.GetGeneratedTableLines())
                .Concat(builder.GetUnusedTableLines())
                .Concat(template.DescriptionLines);

            return string.Join(LineBreak, lines).TrimEnd() + LineBreak;
        }

        private static string WriteSingleDocument(string outputPath, IReadOnlyList<MarkdownDocument> documents)
        {
            string path = Path.GetExtension(outputPath).Length > 0
                ? outputPath
                : Path.Combine(outputPath, DefaultFileName + MarkdownExtension);
            Directory.CreateDirectory(Path.GetDirectoryName(path)!);

            string content = string.Join(LineBreak, documents.Select(document => document.Content));
            File.WriteAllText(path, content, OutputEncoding);
            return path;
        }

        private static string[] WritePerResource(string outputPath, IReadOnlyList<MarkdownDocument> documents)
        {
            PrepareOutputFolder(outputPath);
            InstanceFileNamer namer = new();
            List<string> written = [];

            foreach (MarkdownDocument document in documents)
            {
                string path = namer.ReservePath(Path.Combine(outputPath, document.Area), document.Title);
                Directory.CreateDirectory(Path.GetDirectoryName(path)!);
                File.WriteAllText(path, document.Content, OutputEncoding);
                written.Add(path);
            }

            return written.ToArray();
        }

        private static void PrepareOutputFolder(string outputPath)
        {
            foreach (string area in InstanceFileNamer.Areas)
            {
                string areaFolder = Path.Combine(outputPath, area);
                if (!Directory.Exists(areaFolder))
                {
                    continue;
                }

                foreach (string file in Directory.GetFiles(areaFolder, MarkdownPattern, SearchOption.TopDirectoryOnly))
                {
                    File.Delete(file);
                }
            }
        }

        private sealed class MarkdownDocument
        {
            public MarkdownDocument(string area, string title, string content)
            {
                Area = area;
                Title = title;
                Content = content;
            }

            public string Area { get; }

            public string Title { get; }

            public string Content { get; }
        }
    }
}
