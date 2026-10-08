using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace Microsoft365DSC.Reporting.Markdown
{
    internal sealed class TemplateTable
    {
        public TemplateTable(string title, IReadOnlyList<string> headerLines, IReadOnlyList<string> rows)
        {
            Title = title;
            HeaderLines = headerLines;
            Rows = rows;
        }

        public string Title { get; }

        public string TypeName => Title.TrimStart('#').Trim();

        public IReadOnlyList<string> HeaderLines { get; }

        public IReadOnlyList<string> Rows { get; }

        public IEnumerable<string> Lines => new[] { Title }.Concat(HeaderLines).Concat(Rows);
    }

    internal sealed class MarkdownTemplate
    {
        private static readonly Regex IndexSuffix = new("_\\d+$", RegexOptions.Compiled);

        public MarkdownTemplate(
            TemplateTable mainTable,
            IReadOnlyList<TemplateTable> complexTables,
            IReadOnlyList<string> descriptionLines)
        {
            MainTable = mainTable;
            ComplexTables = complexTables;
            DescriptionLines = descriptionLines;
        }

        public TemplateTable MainTable { get; }

        public IReadOnlyList<TemplateTable> ComplexTables { get; }

        public IReadOnlyList<string> DescriptionLines { get; }

        public static string StripIndexSuffix(string typeName)
        {
            return IndexSuffix.Replace(typeName, string.Empty);
        }

        public TemplateTable? FindComplexTable(string typeName)
        {
            string baseName = StripIndexSuffix(typeName);
            return ComplexTables.FirstOrDefault(table => string.Equals(
                StripIndexSuffix(table.TypeName),
                baseName,
                StringComparison.OrdinalIgnoreCase));
        }
    }
}
