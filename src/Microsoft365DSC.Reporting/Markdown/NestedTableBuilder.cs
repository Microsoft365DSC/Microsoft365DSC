using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Microsoft365DSC.Reporting.Configuration;

namespace Microsoft365DSC.Reporting.Markdown
{
    internal sealed class NestedTableBuilder
    {
        private const string CimInstanceKey = "CIMInstance";
        private const string ODataTypeName = "odataType";
        private const string ODataTypeKey = "@odata.type";
        private const string ComplexTitlePrefix = "### ";

        private static readonly ISet<string> EmptySet = new HashSet<string>();

        private readonly MarkdownTemplate _template;
        private readonly ValueEncoder _encoder;
        private readonly Dictionary<string, int> _elementCounters = new(StringComparer.OrdinalIgnoreCase);
        private readonly Dictionary<string, int> _groupCounters = new(StringComparer.OrdinalIgnoreCase);
        private readonly List<KeyValuePair<string, List<IEnumerable<string>>>> _groups = [];
        private readonly HashSet<string> _emittedTypeNames = new(StringComparer.OrdinalIgnoreCase);
        private readonly bool _includeUnsetProperties;

        public NestedTableBuilder(MarkdownTemplate template, ValueEncoder encoder, bool includeUnsetProperties)
        {
            _template = template;
            _encoder = encoder;
            _includeUnsetProperties = includeUnsetProperties;
        }

        public List<string> FillMainTable(IDictionary properties, ISet<string> ignoredProperties)
        {
            return FillRows(_template.MainTable.Rows, properties, ignoredProperties, true);
        }

        public IEnumerable<string> GetUnusedTableLines()
        {
            if (!_includeUnsetProperties)
            {
                return [];
            }

            HashSet<string> seen = new(StringComparer.OrdinalIgnoreCase);
            return _template.ComplexTables
                .Where(table => !_emittedTypeNames.Contains(table.TypeName)
                    && !_emittedTypeNames.Contains(table.TypeName + "_1")
                    && seen.Add(table.TypeName))
                .SelectMany(table => table.Lines.Concat([string.Empty]));
        }

        public IEnumerable<string> GetGeneratedTableLines()
        {
            return _groups
                .OrderBy(group => group.Key, StringComparer.InvariantCultureIgnoreCase)
                .SelectMany(group => group.Value)
                .SelectMany(table => table.Concat([string.Empty]));
        }

        private List<string> FillRows(
            IEnumerable<string> rows,
            IDictionary data,
            ISet<string> ignoredProperties,
            bool escapeLineBreaks)
        {
            List<string> filled = [];
            foreach (string row in rows)
            {
                string name = TableRowFiller.GetParameterName(row);
                if (ignoredProperties.Contains(name))
                {
                    continue;
                }

                if (!TryFindProperty(data, name, out object? value))
                {
                    if (_includeUnsetProperties)
                    {
                        filled.Add(TableRowFiller.SetValue(row, null));
                    }

                    continue;
                }

                filled.Add(TableRowFiller.SetValue(row, ResolveCell(value, escapeLineBreaks)));
            }

            return filled;
        }

        private string? ResolveCell(object? value, bool escapeLineBreaks)
        {
            switch (value)
            {
                case IDictionary element:
                    return BuildComplexTables([element]);
                case string text:
                    return _encoder.EncodeScalar(text, escapeLineBreaks);
                case IEnumerable collection:
                    List<object?> items = ConfigurationResource.Items(collection).ToList();
                    if (items.Count == 0)
                    {
                        return ValueEncoder.NullToken;
                    }

                    return items.Any(item => item is IDictionary)
                        ? BuildComplexTables(items.OfType<IDictionary>().ToList())
                        : _encoder.EncodeArray(items, escapeLineBreaks);
                default:
                    return _encoder.EncodeScalar(value, escapeLineBreaks);
            }
        }

        private string? BuildComplexTables(IReadOnlyList<IDictionary> elements)
        {
            string? typeName = ConfigurationResource.Find(elements[0], CimInstanceKey, out object? cimInstance)
                ? Convert.ToString(cimInstance)
                : null;
            if (string.IsNullOrEmpty(typeName))
            {
                return null;
            }

            List<string> elementNames = elements
                .Select(_ => $"{typeName}_{Increment(_elementCounters, typeName!)}")
                .ToList();
            string baseName = MarkdownTemplate.StripIndexSuffix(typeName!);
            string groupKey = $"{baseName}_{Increment(_groupCounters, baseName)}";
            List<IEnumerable<string>> tables = [];
            _groups.Add(new(groupKey, tables));

            TemplateTable? template = _template.FindComplexTable(typeName!);
            for (int index = 0; index < elements.Count; index++)
            {
                _emittedTypeNames.Add(elementNames[index]);
                if (template is not null)
                {
                    List<string> rows = FillRows(template.Rows, elements[index], EmptySet, false);
                    tables.Add(new[] { ComplexTitlePrefix + elementNames[index] }
                        .Concat(template.HeaderLines)
                        .Concat(rows)
                        .ToList());
                }
            }

            return string.Join(",", elementNames);
        }

        private static bool TryFindProperty(IDictionary data, string name, out object? value)
        {
            if (ConfigurationResource.Find(data, name, out value))
            {
                return true;
            }

            if (string.Equals(name, ODataTypeName, StringComparison.OrdinalIgnoreCase))
            {
                return ConfigurationResource.Find(data, ODataTypeKey, out value);
            }

            return string.Equals(name, ODataTypeKey, StringComparison.OrdinalIgnoreCase)
                && ConfigurationResource.Find(data, ODataTypeName, out value);
        }

        private static int Increment(Dictionary<string, int> counters, string key)
        {
            counters.TryGetValue(key, out int current);
            counters[key] = current + 1;
            return current + 1;
        }
    }
}
