using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Reflection;

namespace Microsoft365DSC.Intune
{
    /// <summary>
    /// Internal representation of a Setting Instance Template from the Microsoft Graph API.
    /// These templates define the schema/structure for setting instances in Settings Catalog policies.
    ///
    /// The PowerShell code accesses these as <c>$settingTemplate.SettingInstanceTemplate</c> objects
    /// returned by <c>Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate</c>.
    /// </summary>
    public class SettingInstanceTemplateInfo
    {
        /// <summary>The setting definition ID this template targets.</summary>
        public string SettingDefinitionId { get; set; }

        /// <summary>The unique template ID for this setting instance.</summary>
        public string SettingInstanceTemplateId { get; set; }

        /// <summary>
        /// The OData type of the instance template (e.g., <c>#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstanceTemplate</c>).
        /// Extracted from <c>'@odata.type'</c>.
        /// </summary>
        public string ODataType { get; set; }

        /// <summary>
        /// The OData type of the value template, already transformed from <c>ValueTemplate</c> to <c>Value</c>.
        /// For example: <c>#microsoft.graph.deviceManagementConfigurationChoiceSettingValue</c>.
        /// Null if no value template exists (e.g., GroupSettingCollection without explicit value template).
        /// </summary>
        public string ValueTemplateODataType { get; set; }

        /// <summary>
        /// The <c>settingValueTemplateId</c> from the value template.
        /// Null if the value template has no ID or if the ID is an array
        /// (edge case: ThreatTypeSettings in IntuneAntivirusPolicyLinux).
        /// </summary>
        public string ValueTemplateId { get; set; }

        /// <summary>
        /// Child instance templates from the value template's <c>children</c> array.
        /// Used for GroupSettingCollection and ChoiceSetting children.
        /// </summary>
        public List<SettingInstanceTemplateInfo> Children { get; set; } = [];

        /// <summary>
        /// The computed value name derived from the OData type.
        /// For GroupSettingCollectionInstance -> <c>groupSettingCollectionValue</c>.
        /// Stored to avoid recomputing during recursive traversal.
        /// </summary>
        public string SettingValueName { get; set; }
    }

    /// <summary>
    /// Wraps a setting template from the Graph API, containing both the instance template and its definitions.
    /// Corresponds to the objects returned by <c>Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate</c>.
    /// </summary>
    public class SettingTemplateInfo
    {
        /// <summary>The setting instance template with schema information.</summary>
        public SettingInstanceTemplateInfo SettingInstanceTemplate { get; set; }

        /// <summary>The setting definitions associated with this template.</summary>
        public List<SettingDefinitionInfo> SettingDefinitions { get; set; } = [];
    }

    /// <summary>
    /// Maps raw Graph API SettingInstanceTemplate objects to <see cref="SettingInstanceTemplateInfo"/>.
    ///
    /// The template objects have a dual nature:
    /// <list type="bullet">
    /// <item>Root templates (from <c>$settingTemplate.SettingInstanceTemplate</c>): most data one level down</item>
    /// <item>Child templates (from value template's <c>children</c>): data at top level (plain dictionaries)</item>
    /// </list>
    /// </summary>
    internal static class SettingInstanceTemplateMapper
    {
        private const string ODataTypePrefix = "#microsoft.graph.deviceManagementConfiguration";

        /// <summary>
        /// Maps a Graph SettingInstanceTemplate object to <see cref="SettingInstanceTemplateInfo"/>.
        /// </summary>
        /// <param name="template">The raw Graph SDK object, PSObject, or Hashtable.</param>
        /// <param name="isRoot">
        /// True for root-level templates where OData type and value templates are nested one level down.
        /// False for child templates where data is at the top level.
        /// </param>
        public static SettingInstanceTemplateInfo FromGraphObject(object template)
        {
            if (template is null)
                return null;

            var info = new SettingInstanceTemplateInfo
            {
                SettingDefinitionId = SettingDefinitionMapper.TryGetProperty(template, "settingDefinitionId"),
                SettingInstanceTemplateId = SettingDefinitionMapper.TryGetProperty(template, "settingInstanceTemplateId"),
                // Extract OData type
                ODataType = SettingDefinitionMapper.TryGetProperty(template, "@odata.type")
            };

            if (string.IsNullOrEmpty(info.ODataType))
                return info;

            // Derive the setting value name from the OData type
            // e.g., #...GroupSettingCollectionInstanceTemplate -> GroupSettingCollectionValue -> groupSettingCollectionValue
            string settingType = info.ODataType.Replace("InstanceTemplate", "Instance");
            string settingValueName = settingType.Replace(ODataTypePrefix, "").Replace("Instance", "Value");
            if (settingValueName.Length > 0)
            {
                settingValueName = SettingsCatalogHelper.ToCamelCase(settingValueName);
            }
            info.SettingValueName = settingValueName;

            // The value template key name is the settingValueName + "Template"
            string valueTemplateKey = settingValueName + "Template";

            // Extract the value template object
            object valueTemplateRaw = SettingDefinitionMapper.TryGetPropertyRaw(template, valueTemplateKey);

            // Collection types (GroupSettingCollection, SimpleSettingCollection, ChoiceSettingCollection)
            // return an array of value templates. Unwrap to the first element which defines the repeating structure.
            if (valueTemplateRaw is IEnumerable<object> valueTemplateCollection)
            {
                valueTemplateRaw = valueTemplateCollection.FirstOrDefault();
            }

            if (valueTemplateRaw is not null)
            {
                // Extract @odata.type from value template and transform ValueTemplate->Value
                string valueTemplateODataType = SettingDefinitionMapper.TryGetProperty(valueTemplateRaw, "@odata.type");
                if (!string.IsNullOrEmpty(valueTemplateODataType))
                {
                    info.ValueTemplateODataType = valueTemplateODataType.Replace("ValueTemplate", "Value");
                }

                // Extract settingValueTemplateId - handle array edge case
                object templateIdRaw = SettingDefinitionMapper.TryGetPropertyRaw(valueTemplateRaw, "settingValueTemplateId");
                if (templateIdRaw is not null)
                {
                    if (templateIdRaw is string templateIdStr)
                    {
                        info.ValueTemplateId = templateIdStr;
                    }
                    else if (templateIdRaw is IEnumerable && templateIdRaw is not string)
                    {
                        // Array of template IDs (e.g., ThreatTypeSettings in IntuneAntivirusPolicyLinux)
                        // The IDs are from child settings, not from the parent - set null
                        info.ValueTemplateId = null;
                    }
                    else
                    {
                        info.ValueTemplateId = templateIdRaw.ToString();
                    }
                }

                // Extract children from the value template
                var childrenRaw = SettingDefinitionMapper.TryGetPropertyAsEnumerable(valueTemplateRaw, "children");
                if (childrenRaw is not null)
                {
                    foreach (var child in childrenRaw)
                    {
                        var childInfo = FromGraphObject(child);
                        if (childInfo is not null)
                        {
                            info.Children.Add(childInfo);
                        }
                    }
                }
            }

            // Special case: ChoiceSettingValue without a value template type
            if (string.IsNullOrEmpty(info.ValueTemplateODataType) && settingValueName == "choiceSettingValue")
            {
                info.ValueTemplateODataType = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue";
            }

            return info;
        }

    }

    /// <summary>
    /// Maps raw Graph API setting template objects to <see cref="SettingTemplateInfo"/>.
    /// These are the objects returned by <c>Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate</c>.
    /// </summary>
    internal static class SettingTemplateMapper
    {
        /// <summary>
        /// Maps a single setting template from the Graph API.
        /// Extracts <c>SettingInstanceTemplate</c> and <c>SettingDefinitions</c> properties.
        /// </summary>
        public static SettingTemplateInfo FromGraphObject(object settingTemplate)
        {
            if (settingTemplate is null)
                return null;

            var info = new SettingTemplateInfo();

            // Extract SettingInstanceTemplate
            var instanceTemplateRaw = SettingDefinitionMapper.TryGetPropertyRaw(settingTemplate, "SettingInstanceTemplate");
            if (instanceTemplateRaw is not null)
            {
                info.SettingInstanceTemplate = SettingInstanceTemplateMapper.FromGraphObject(instanceTemplateRaw);
            }

            // Extract SettingDefinitions
            var definitionsRaw = SettingDefinitionMapper.TryGetPropertyAsEnumerable(settingTemplate, "SettingDefinitions");
            if (definitionsRaw is not null)
            {
                info.SettingDefinitions = SettingDefinitionMapper.FromGraphObjects(definitionsRaw);
            }

            return info;
        }

        /// <summary>
        /// Maps a collection of setting template objects.
        /// </summary>
        public static List<SettingTemplateInfo> FromGraphObjects(IEnumerable<object> settingTemplates)
        {
            return settingTemplates.Select(FromGraphObject).Where(t => t is not null).ToList();
        }
    }
}
