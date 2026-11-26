using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using Microsoft365DSC.Reporting.Configuration;
using Microsoft365DSC.Utilities;

namespace Microsoft365DSC.Reporting.Markdown
{
    internal sealed class MarkdownTemplateBuilder
    {
        private const string ClassPrefix = "MSFT_";
        private const string CredentialClass = "MSFT_Credential";
        private const string CredentialType = "PSCredential";
        private const string FullHeader = "| Parameter | Attribute | DataType | Description | Allowed Values | Value |";
        private const string FullSeparator = "| --- | --- | --- | --- | --- | --- |";
        private const string CompactHeader = "| Parameter | DataType | Value |";
        private const string CompactSeparator = "| --- | --- | --- |";
        private const string MainParametersHeading = "## Parameters";
        private const string ComplexParametersHeading = "#### Parameters";
        private const string PermissionsHeading = "## Permissions";
        private const string NoPermissions = "No permission information available";

        private static readonly string[] RoleApis = ["exchange", "purview"];

        private static readonly Regex DocumentationHeading = new(
            "^\\s*#\\s+.+\\r?\\n\\r?\\n",
            RegexOptions.Compiled);

        private static readonly Regex ArraySuffix = new("\\[\\]$", RegexOptions.Compiled);

        private readonly IResourceMetadataSource _metadata;
        private readonly bool _includeAllInformation;
        private readonly Action<string> _warn;

        public MarkdownTemplateBuilder(
            IResourceMetadataSource metadata,
            bool includeAllInformation,
            Action<string> warn)
        {
            _metadata = metadata;
            _includeAllInformation = includeAllInformation;
            _warn = warn;
        }

        public MarkdownTemplate? Build(string resourceType)
        {
            ResourceClass? resourceClass = _metadata.GetClass(ClassPrefix + resourceType);
            if (resourceClass is null)
            {
                _warn($"Skipping resource type '{resourceType}': the schema definition does not contain it.");
                return null;
            }

            TemplateTable mainTable = new(
                "# " + resourceType,
                BuildHeaderLines(MainParametersHeading),
                BuildRows(resourceClass, true));

            List<TemplateTable> complexTables = GetEmbeddedClasses(resourceClass)
                .Select(embedded => new TemplateTable(
                    "### " + embedded.ClassName,
                    BuildHeaderLines(ComplexParametersHeading),
                    BuildRows(embedded, false)))
                .ToList();

            return new(mainTable, complexTables, BuildDescriptionLines(resourceType));
        }

        private IReadOnlyList<string> BuildHeaderLines(string parametersHeading)
        {
            return
            [
                string.Empty,
                parametersHeading,
                string.Empty,
                _includeAllInformation ? FullHeader : CompactHeader,
                _includeAllInformation ? FullSeparator : CompactSeparator
            ];
        }

        private IReadOnlyList<string> BuildRows(ResourceClass resourceClass, bool skipAuthenticationProperties)
        {
            IEnumerable<ResourceParameter> parameters = skipAuthenticationProperties
                ? resourceClass.Parameters.Where(parameter =>
                    !Utilities.Utilities.IsAuthenticationProperty(parameter.Name))
                : resourceClass.Parameters;

            return parameters.Select(BuildRow).ToList();
        }

        private string BuildRow(ResourceParameter parameter)
        {
            string dataType = Regex.Replace(
                parameter.CimType,
                CredentialClass,
                CredentialType,
                RegexOptions.IgnoreCase);
            if (!_includeAllInformation)
            {
                return $"| **{parameter.Name}** | {dataType} | |";
            }

            string description = parameter.Description.Length > 0
                ? " " + parameter.Description.Replace("<", "&lt;").Replace(">", "&gt;")
                : string.Empty;
            string allowedValues = parameter.ValueMap is { Count: > 0 }
                ? " " + string.Join(", ", parameter.ValueMap.Select(value => $"`{value}`"))
                : string.Empty;

            return $"| **{parameter.Name}** | {parameter.Option} | {dataType} |{description} |{allowedValues} | |";
        }

        private List<ResourceClass> GetEmbeddedClasses(ResourceClass resourceClass)
        {
            List<ResourceClass> embedded = [];
            HashSet<string> visited = new(StringComparer.OrdinalIgnoreCase) { resourceClass.ClassName };
            Queue<ResourceClass> pending = new();
            pending.Enqueue(resourceClass);

            while (pending.Count > 0)
            {
                foreach (ResourceParameter parameter in pending.Dequeue().Parameters)
                {
                    string className = ArraySuffix.Replace(parameter.CimType, string.Empty);
                    if (!className.StartsWith(ClassPrefix, StringComparison.OrdinalIgnoreCase)
                        || string.Equals(className, CredentialClass, StringComparison.OrdinalIgnoreCase)
                        || !visited.Add(className))
                    {
                        continue;
                    }

                    ResourceClass? embeddedClass = _metadata.GetClass(className);
                    if (embeddedClass is null)
                    {
                        _warn($"The complex type '{className}' of class '{resourceClass.ClassName}' "
                            + "is missing from the schema definition.");
                        continue;
                    }

                    embedded.Add(embeddedClass);
                    pending.Enqueue(embeddedClass);
                }
            }

            return embedded;
        }

        private IReadOnlyList<string> BuildDescriptionLines(string resourceType)
        {
            if (!_includeAllInformation)
            {
                return [];
            }

            List<string> lines = [];
            string? documentation = _metadata.GetDocumentation(resourceType);
            if (documentation is not null)
            {
                lines.AddRange(SplitLines(DocumentationHeading.Replace(documentation, string.Empty)));
            }
            else
            {
                _warn($"The documentation of resource type '{resourceType}' was not found.");
            }

            lines.AddRange(BuildPermissionLines(_metadata.GetPermissions(resourceType)));
            return lines;
        }

        private static List<string> BuildPermissionLines(IDictionary? permissions)
        {
            if (permissions is null)
            {
                return [string.Empty, NoPermissions];
            }

            List<string> lines = [PermissionsHeading];
            List<DictionaryEntry> apis = permissions.Cast<DictionaryEntry>().ToList();
            foreach (string roleApi in RoleApis)
            {
                DictionaryEntry api = apis.FirstOrDefault(entry => IsApi(entry, roleApi));
                if (api.Value is IDictionary rolePermissions)
                {
                    lines.AddRange(BuildRolePermissionLines(Capitalize(roleApi), rolePermissions));
                }
            }

            foreach (DictionaryEntry api in apis.Where(entry => !RoleApis.Any(role => IsApi(entry, role))))
            {
                if (api.Value is IDictionary apiPermissions)
                {
                    string apiName = Capitalize(Convert.ToString(api.Key) ?? string.Empty);
                    lines.AddRange(BuildApiPermissionLines(apiName, apiPermissions));
                }
            }

            return lines;
        }

        private static IEnumerable<string> BuildRolePermissionLines(string apiName, IDictionary permissions)
        {
            ConfigurationResource.Find(permissions, "requiredRoles", out object? roles);
            ConfigurationResource.Find(permissions, "requiredRoleGroups", out object? roleGroups);

            return
            [
                string.Empty,
                $"### {apiName}",
                string.Empty,
                $"To authenticate with Microsoft {apiName}, this resource requires the following permissions:",
                string.Empty,
                "#### Roles",
                string.Empty,
                "* **Read**",
                "  * " + JoinNames(roles, "read", string.Empty),
                "* **Update**",
                "  * " + JoinNames(roles, "update", string.Empty),
                string.Empty,
                "#### Role Groups",
                string.Empty,
                "* **Read**",
                "  * " + JoinNames(roleGroups, "read", "None"),
                "* **Update**",
                "  * " + JoinNames(roleGroups, "update", "None")
            ];
        }

        private static IEnumerable<string> BuildApiPermissionLines(string apiName, IDictionary permissions)
        {
            ConfigurationResource.Find(permissions, "delegated", out object? delegated);
            ConfigurationResource.Find(permissions, "application", out object? application);

            return
            [
                string.Empty,
                $"### {apiName}",
                string.Empty,
                $"To authenticate with the {apiName} API, this resource requires the following permissions:",
                string.Empty,
                "#### Delegated permissions",
                string.Empty,
                "* **Read**",
                "  * " + JoinNames(delegated, "read", "None"),
                string.Empty,
                "* **Update**",
                "  * " + JoinNames(delegated, "update", "None"),
                string.Empty,
                "#### Application permissions",
                string.Empty,
                "* **Read**",
                "  * " + JoinNames(application, "read", "None"),
                string.Empty,
                "* **Update**",
                "  * " + JoinNames(application, "update", "None")
            ];
        }

        private static string JoinNames(object? permissions, string access, string fallback)
        {
            if (permissions is not IDictionary members
                || !ConfigurationResource.Find(members, access, out object? entries)
                || entries is not IEnumerable<object?> items)
            {
                return fallback;
            }

            List<string> names = items.Select(GetPermissionName).Where(name => name.Length > 0).ToList();
            return names.Count > 0 ? string.Join(", ", names) : fallback;
        }

        private static string GetPermissionName(object? permission)
        {
            if (permission is IDictionary member && ConfigurationResource.Find(member, "name", out object? name))
            {
                return Convert.ToString(name) ?? string.Empty;
            }

            return Convert.ToString(permission) ?? string.Empty;
        }

        private static bool IsApi(DictionaryEntry entry, string apiName)
        {
            return string.Equals(Convert.ToString(entry.Key), apiName, StringComparison.OrdinalIgnoreCase);
        }

        private static string Capitalize(string text)
        {
            return text.Length > 0 ? char.ToUpperInvariant(text[0]) + text.Substring(1) : text;
        }

        private static IEnumerable<string> SplitLines(string text)
        {
            return text.Split('\n').Select(line => line.TrimEnd('\r'));
        }
    }
}
