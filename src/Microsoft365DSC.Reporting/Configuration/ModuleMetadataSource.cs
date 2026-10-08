using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Linq;
using System.Text;

namespace Microsoft365DSC.Reporting.Configuration
{
    /// <summary>
    /// Reads resource metadata from the files a Microsoft365DSC module installation ships.
    /// Those files are SchemaDefinition.json, ResourcePermissions.json and the readme of a resource.
    /// </summary>
    public sealed class ModuleMetadataSource : IResourceMetadataSource
    {
        private const string SchemaFileName = "SchemaDefinition.json";
        private const string PermissionsFileName = "ResourcePermissions.json";
        private const string ResourcesFolderName = "DscResources";
        private const string SettingsFileName = "settings.json";
        private const string DocumentationFileName = "readme.md";
        private const string ClassPrefix = "MSFT_";
        private const string PermissionsKey = "permissions";
        private const string DescriptionKey = "Description";
        private const string LineBreak = "\r\n";

        private static readonly IDictionary EmptyPermissions = new OrderedDictionary();

        private readonly string _moduleRoot;
        private readonly Dictionary<string, string?> _documentation = new(StringComparer.OrdinalIgnoreCase);

        private Dictionary<string, ResourceClass>? _classes;
        private Dictionary<string, string>? _descriptions;
        private Dictionary<string, object?>? _settings;

        /// <summary>
        /// Creates a metadata source over a module installation.
        /// </summary>
        /// <param name="moduleRoot">The folder that holds SchemaDefinition.json.</param>
        public ModuleMetadataSource(string moduleRoot)
        {
            _moduleRoot = moduleRoot;
        }

        /// <inheritdoc />
        public ResourceClass? GetClass(string className)
        {
            _classes ??= LoadClasses();
            return _classes.TryGetValue(className, out ResourceClass? resourceClass) ? resourceClass : null;
        }

        /// <inheritdoc />
        public string? GetDocumentation(string resourceType)
        {
            if (!_documentation.TryGetValue(resourceType, out string? documentation))
            {
                documentation = ReadDocumentation(resourceType) ?? BuildDocumentation(resourceType);
                _documentation[resourceType] = documentation;
            }

            return documentation;
        }

        /// <inheritdoc />
        public IDictionary? GetPermissions(string resourceType)
        {
            _settings ??= LoadSettings();
            if (!_settings.TryGetValue(resourceType, out object? settings) || settings is not IDictionary members)
            {
                return null;
            }

            return ConfigurationResource.Find(members, PermissionsKey, out object? permissions)
                ? permissions as IDictionary ?? EmptyPermissions
                : EmptyPermissions;
        }

        private string? ReadDocumentation(string resourceType)
        {
            string path = Path.Combine(
                _moduleRoot,
                ResourcesFolderName,
                ClassPrefix + resourceType,
                DocumentationFileName);

            return File.Exists(path) ? File.ReadAllText(path, Encoding.UTF8) : null;
        }

        private string? BuildDocumentation(string resourceType)
        {
            _classes ??= LoadClasses();
            bool found = _descriptions!.TryGetValue(ClassPrefix + resourceType, out string? description);
            return found && description!.Length > 0
                ? $"# {resourceType}{LineBreak}{LineBreak}## Description{LineBreak}{LineBreak}{description}{LineBreak}"
                : null;
        }

        private Dictionary<string, ResourceClass> LoadClasses()
        {
            Dictionary<string, ResourceClass> classes = new(StringComparer.OrdinalIgnoreCase);
            _descriptions = new(StringComparer.OrdinalIgnoreCase);
            string path = Path.Combine(_moduleRoot, SchemaFileName);
            if (!File.Exists(path))
            {
                throw new FileNotFoundException($"The schema definition '{path}' was not found.", path);
            }

            foreach (object? entry in ReadJson(path) as IEnumerable<object?> ?? [])
            {
                if (entry is not IDictionary definition)
                {
                    continue;
                }

                ResourceClass resourceClass = new()
                {
                    ClassName = GetText(definition, "ClassName"),
                    Parameters = ReadParameters(definition)
                };
                classes[resourceClass.ClassName] = resourceClass;
                _descriptions[resourceClass.ClassName] = GetText(definition, DescriptionKey);
            }

            return classes;
        }

        private Dictionary<string, object?> LoadSettings()
        {
            string permissionsPath = Path.Combine(_moduleRoot, PermissionsFileName);
            if (File.Exists(permissionsPath))
            {
                Dictionary<string, object?> settings = new(StringComparer.OrdinalIgnoreCase);
                if (ReadJson(permissionsPath) is IDictionary resources)
                {
                    foreach (DictionaryEntry resource in resources)
                    {
                        settings[Convert.ToString(resource.Key) ?? string.Empty] = resource.Value;
                    }
                }

                return settings;
            }

            return LoadResourceSettings();
        }

        private Dictionary<string, object?> LoadResourceSettings()
        {
            Dictionary<string, object?> settings = new(StringComparer.OrdinalIgnoreCase);
            string resourcesRoot = Path.Combine(_moduleRoot, ResourcesFolderName);
            if (!Directory.Exists(resourcesRoot))
            {
                return settings;
            }

            foreach (string folder in Directory.GetDirectories(resourcesRoot))
            {
                string path = Path.Combine(folder, SettingsFileName);
                if (File.Exists(path))
                {
                    string name = Path.GetFileName(folder).Substring(ClassPrefix.Length);
                    settings[name] = ReadJson(path);
                }
            }

            return settings;
        }

        private static List<ResourceParameter> ReadParameters(IDictionary definition)
        {
            List<ResourceParameter> parameters = [];
            if (!ConfigurationResource.Find(definition, "Parameters", out object? value)
                || value is not IEnumerable<object?> entries)
            {
                return parameters;
            }

            foreach (object? entry in entries)
            {
                if (entry is IDictionary parameter)
                {
                    parameters.Add(new()
                    {
                        Name = GetText(parameter, "Name"),
                        Option = GetText(parameter, "Option"),
                        CimType = GetText(parameter, "CIMType"),
                        Description = GetText(parameter, "Description"),
                        ValueMap = GetTextList(parameter, "ValueMap")
                    });
                }
            }

            return parameters;
        }

        private static object? ReadJson(string path)
        {
            return JsonReader.Parse(File.ReadAllText(path, Encoding.UTF8));
        }

        private static string GetText(IDictionary source, string name)
        {
            return ConfigurationResource.Find(source, name, out object? value)
                ? Convert.ToString(value) ?? string.Empty
                : string.Empty;
        }

        private static IReadOnlyList<string>? GetTextList(IDictionary source, string name)
        {
            if (!ConfigurationResource.Find(source, name, out object? value) || value is not IEnumerable<object?> items)
            {
                return null;
            }

            return items.Select(item => Convert.ToString(item) ?? string.Empty).ToList();
        }
    }
}
