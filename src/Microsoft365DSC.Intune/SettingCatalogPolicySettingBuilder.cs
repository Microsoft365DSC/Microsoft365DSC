using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using Microsoft.Management.Infrastructure;

namespace Microsoft365DSC.Intune
{
    /// <summary>
    /// C# port of <c>Get-IntuneSettingCatalogPolicySetting</c> and <c>Get-IntuneSettingCatalogPolicySettingInstanceValue</c>.
    /// Builds the Settings Catalog policy body (array of setting instances) from DSC parameters and setting templates.
    ///
    /// <para><b>Architecture:</b></para>
    /// <list type="bullet">
    /// <item>The Graph API call to fetch setting templates remains in PowerShell.</item>
    /// <item>This class receives the raw Graph SDK template objects and the DSC parameter hashtable.</item>
    /// <item>All template/definition objects are mapped to C# models at the boundary via <see cref="SettingTemplateMapper"/>
    /// and <see cref="SettingDefinitionMapper"/>, then the builder works purely with C# models.</item>
    /// <item>Value resolution delegates to <see cref="SettingValueResolver.Resolve"/> (already ported).</item>
    /// <item>CIM instances from DSC parameters are handled via direct <c>CimInstance</c> access.</item>
    /// </list>
    /// </summary>
    public static class SettingCatalogPolicySettingBuilder
    {
        private const string ODataTypePrefix = "#microsoft.graph.deviceManagementConfiguration";
        private const string SettingODataType = "#microsoft.graph.deviceManagementConfigurationSetting";
        private const string GroupSettingCollectionInstanceType = "#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance";
        private const string SettingGroupCollectionDefinitionType = "#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition";
        private const string ChoiceSettingInstanceType = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance";
        private const string ChoiceSettingDefinitionType = "#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition";
        private const string ChoiceSettingCollectionInstanceType = "#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance";
        private const string ChoiceSettingCollectionDefinitionType = "#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionDefinition";
        private const string SimpleSettingCollectionInstanceType = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance";
        private const string SimpleSettingCollectionDefinitionType = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionDefinition";
        private const string ChoiceSettingValueType = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue";
        private const string SecretSettingValueType = "#microsoft.graph.deviceManagementConfigurationSecretSettingValue";
        private const string DefaultSettingInstanceName = "MSFT_MicrosoftGraphIntuneSettingsCatalog";

        /// <summary>
        /// Builds the Settings Catalog policy body from DSC parameters and setting templates.
        /// Entry point called from PowerShell after template fetching.
        /// </summary>
        /// <param name="settingTemplatesFromGraph">
        /// Raw Graph SDK objects from <c>Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate</c>.
        /// </param>
        /// <param name="dscParams">The DSC parameters hashtable (Identity/DisplayName/Description already removed).</param>
        /// <param name="containsDeviceAndUserSettings">True if the policy has separate device_ and user_ prefixed settings.</param>
        /// <returns>Array of Hashtables, each representing a <c>deviceManagementConfigurationSetting</c>.</returns>
        public static Hashtable[] Build(
            IList<object> settingTemplatesFromGraph,
            Hashtable dscParams,
            bool containsDeviceAndUserSettings = false)
        {
            // Map all Graph objects to internal models at the boundary
            List<SettingTemplateInfo> settingTemplates = SettingTemplateMapper.FromGraphObjects(settingTemplatesFromGraph);

            return containsDeviceAndUserSettings
                ? BuildDeviceAndUserSettings(settingTemplates, dscParams)
                : BuildCore(settingTemplates, dscParams);
        }

        /// <summary>
        /// Core build logic that processes setting templates and produces setting instance Hashtables.
        /// </summary>
        private static Hashtable[] BuildCore(
            List<SettingTemplateInfo> settingTemplates,
            Hashtable dscParams)
        {
            // Collect all definitions across all templates
            List<SettingDefinitionInfo> allDefinitions = settingTemplates.SelectMany(t => t.SettingDefinitions).ToList();
            List<Hashtable> settingInstances = [];
            HashSet<string> processedSettingDefinitionIds = new(StringComparer.Ordinal);

            foreach (var settingTemplate in settingTemplates)
            {
                if (settingTemplate.SettingInstanceTemplate is null)
                    continue;

                var instanceTemplate = settingTemplate.SettingInstanceTemplate;

                // Find root definition: matches SettingDefinitionId and has no dependentOn/optionsDependentOn
                var settingDefinition = settingTemplate.SettingDefinitions
                    .Where(d => string.Equals(d.Id, instanceTemplate.SettingDefinitionId, StringComparison.OrdinalIgnoreCase) &&
                                d.DependentOnParentSettingIds.Count == 0 &&
                                d.OptionsDependentOnParentSettingIds.Count == 0)
                    .FirstOrDefault();

                if (settingDefinition is null)
                    continue;

                if (processedSettingDefinitionIds.Contains(settingDefinition.Id))
                    continue; // Skip if we've already processed this definition via another template

                // Derive setting type: InstanceTemplate -> Instance
                string settingType = instanceTemplate.ODataType?.Replace("InstanceTemplate", "Instance") ?? string.Empty;

                // Build the setting instance hashtable
                var settingInstance = new Hashtable(StringComparer.OrdinalIgnoreCase)
                {
                    ["@odata.type"] = settingType
                };

                if (!string.IsNullOrEmpty(instanceTemplate.SettingInstanceTemplateId))
                {
                    settingInstance["settingInstanceTemplateReference"] = new Hashtable(StringComparer.OrdinalIgnoreCase)
                    {
                        ["settingInstanceTemplateId"] = instanceTemplate.SettingInstanceTemplateId
                    };
                }

                // Use pre-computed values from the template mapper
                string settingValueName = instanceTemplate.SettingValueName;
                string settingValueType = instanceTemplate.ValueTemplateODataType ?? string.Empty;
                string settingValueTemplateId = instanceTemplate.ValueTemplateId;

                // Build the setting instance value recursively
                var settingValue = BuildSettingInstanceValue(
                    dscParams,
                    settingDefinition,
                    instanceTemplate,
                    allDefinitions,
                    settingTemplate.SettingDefinitions,
                    settingType,
                    settingValueName,
                    settingValueType,
                    settingValueTemplateId,
                    DefaultSettingInstanceName,
                    level: 1);

                if (settingValue is null || settingValue.Count == 0)
                    continue;

                // Skip empty group setting collections
                if (settingValue.ContainsKey("groupSettingCollectionValue"))
                {
                    var groupValue = settingValue["groupSettingCollectionValue"] as IList;
                    if (groupValue is not null && groupValue.Count > 0)
                    {
                        var firstGroup = groupValue[0] as Hashtable;
                        var children = firstGroup?["children"] as IList;
                        if (children is not null && children.Count == 0)
                            continue;
                    }
                }

                // Merge the setting value into the setting instance
                foreach (DictionaryEntry entry in settingValue)
                {
                    settingInstance[entry.Key] = entry.Value;
                }

                if (!settingInstance.ContainsKey("settingDefinitionId"))
                {
                    settingInstance["settingDefinitionId"] = instanceTemplate.SettingDefinitionId;
                }

                settingInstances.Add(new Hashtable(StringComparer.OrdinalIgnoreCase)
                {
                    ["@odata.type"] = SettingODataType,
                    ["settingInstance"] = settingInstance
                });
                processedSettingDefinitionIds.Add(settingDefinition.Id);
            }

            return settingInstances.ToArray();
        }

        /// <summary>
        /// Handles policies with separate device and user settings.
        /// Splits templates by prefix, extracts CIM-based DSC params for each scope, builds separately.
        /// </summary>
        private static Hashtable[] BuildDeviceAndUserSettings(
            List<SettingTemplateInfo> settingTemplates,
            Hashtable dscParams)
        {
            // User scope is always announced through the user_ prefix; everything else is
            // device-scoped (the CSP default context), including definitions without a
            // device_ prefix whose base URI goes straight to ./Vendor/MSFT.
            var deviceTemplates = settingTemplates
                .Where(t => t.SettingInstanceTemplate?.SettingDefinitionId?.StartsWith("user_", StringComparison.OrdinalIgnoreCase) != true)
                .ToList();
            var userTemplates = settingTemplates
                .Where(t => t.SettingInstanceTemplate?.SettingDefinitionId?.StartsWith("user_", StringComparison.OrdinalIgnoreCase) == true)
                .ToList();

            var deviceDscParams = ExtractCimPropertiesCamelCase(dscParams["DeviceSettings"]);
            var userDscParams = ExtractCimPropertiesCamelCase(dscParams["UserSettings"]);

            var combinedInstances = new List<Hashtable>();
            combinedInstances.AddRange(BuildCore(deviceTemplates, deviceDscParams));
            combinedInstances.AddRange(BuildCore(userTemplates, userDscParams));

            return combinedInstances.ToArray();
        }

        /// <summary>
        /// Recursive method that builds a setting instance value subtree.
        /// Mirrors <c>Get-IntuneSettingCatalogPolicySettingInstanceValue</c> exactly.
        ///
        /// Handles 5 setting types:
        /// 1. GroupSettingCollectionInstance / SettingGroupCollectionDefinition
        /// 2. ChoiceSettingInstance / ChoiceSettingDefinition
        /// 3. ChoiceSettingCollectionInstance / ChoiceSettingCollectionDefinition
        /// 4. SimpleSettingCollectionInstance / SimpleSettingCollectionDefinition
        /// 5. Default (Simple settings: Integer/String)
        /// </summary>
        private static Hashtable BuildSettingInstanceValue(
            Hashtable dscParams,
            SettingDefinitionInfo settingDefinition,
            SettingInstanceTemplateInfo instanceTemplate,
            List<SettingDefinitionInfo> allDefinitions,
            List<SettingDefinitionInfo> currentDefinitions,
            string settingType,
            string settingValueName,
            string settingValueType,
            string settingValueTemplateId,
            string settingInstanceName,
            int level)
        {
            // GroupSettingCollection
            if (IsGroupSettingCollection(settingType))
            {
                return BuildGroupSettingCollectionValue(
                    dscParams, settingDefinition, instanceTemplate,
                    allDefinitions, currentDefinitions,
                    settingInstanceName, level);
            }

            // ChoiceSetting (not Collection)
            if (IsChoiceSetting(settingType))
            {
                return BuildChoiceSettingValue(
                    dscParams, settingDefinition, instanceTemplate,
                    allDefinitions, currentDefinitions,
                    settingValueType, settingValueTemplateId,
                    settingInstanceName);
            }

            // ChoiceSettingCollection
            if (IsChoiceSettingCollection(settingType))
            {
                return BuildChoiceSettingCollectionValue(
                    dscParams, settingDefinition, allDefinitions,
                    settingValueType);
            }

            // SimpleSettingCollection
            if (IsSimpleSettingCollection(settingType))
            {
                return BuildSimpleSettingCollectionValue(
                    dscParams, settingDefinition, allDefinitions,
                    settingValueType, settingValueName);
            }

            // Default: Simple settings (Integer/String)
            return BuildSimpleSettingValue(
                dscParams, settingDefinition, allDefinitions,
                settingValueType, settingValueName, settingValueTemplateId);
        }

        #region GroupSettingCollection
        // GroupSettingCollections are a collection of settings without a value of their own
        private static Hashtable BuildGroupSettingCollectionValue(
            Hashtable dscParams,
            SettingDefinitionInfo settingDefinition,
            SettingInstanceTemplateInfo instanceTemplate,
            List<SettingDefinitionInfo> allDefinitions,
            List<SettingDefinitionInfo> currentDefinitions,
            string settingInstanceName,
            int level)
        {
            var result = new Hashtable(StringComparer.OrdinalIgnoreCase);
            var groupSettingCollectionValue = new List<object>();

            // Find child definitions that depend on this setting
            var childDefinitions = FindChildDefinitions(currentDefinitions, settingDefinition.Id);

            int instanceCount = 1;
            string cimParamName = null;
            Hashtable effectiveDscParams = dscParams;
            List<SettingDefinitionInfo> effectiveAllDefinitions = allDefinitions;
            string childInstanceName = settingInstanceName;

            // Multi-instance detection
            bool isMultiInstance =
                (level > 1 && childDefinitions.Count > 1) ||
                (level == 1 && settingDefinition.MaximumCount > 1 && childDefinitions.Count >= 1 &&
                 !childDefinitions.Any(c => string.Equals(c.ODataType, SettingGroupCollectionDefinitionType, StringComparison.OrdinalIgnoreCase)));

            if (isMultiInstance)
            {
                string settingName = SettingsCatalogHelper.WithoutDoubledParent(
                    SettingsCatalogHelper.GetSettingName(settingDefinition, allDefinitions));
                string fullClassName = settingInstanceName + settingName;
                childInstanceName = fullClassName;

                var (paramName, cimInstances) = FindCimInstancesByClassName(dscParams, fullClassName);
                cimParamName = paramName;

                if (cimInstances.Count > 0)
                {
                    var newParams = new Hashtable(StringComparer.OrdinalIgnoreCase);
                    var instanceList = new List<Hashtable>();
                    foreach (var cimInstance in cimInstances)
                    {
                        instanceList.Add(ExtractCimPropertiesModifiedOnly(cimInstance));
                    }
                    instanceCount = instanceList.Count;
                    newParams[cimParamName] = instanceCount == 1 ? (object)instanceList[0] : instanceList.ToArray();
                    effectiveDscParams = newParams;
                }

                effectiveAllDefinitions = new(childDefinitions) { settingDefinition };
            }

            // Iterate over instances
            for (int i = 0; i < instanceCount; i++)
            {
                List<Hashtable> groupChildren = [];
                Hashtable currentDscParams = ResolveCurrentDscParams(effectiveDscParams, cimParamName, instanceCount, i);

                foreach (var childDef in childDefinitions)
                {
                    // Derive child setting type, value name, value type
                    string childSettingType = childDef.ODataType?
                        .Replace("Definition", "Instance")
                        .Replace("SettingGroup", "GroupSetting") ?? string.Empty;
                    string childSettingValueName = childSettingType
                        .Replace(ODataTypePrefix, "")
                        .Replace("Instance", "Value");
                    string childSettingValueType = ODataTypePrefix + childSettingValueName;
                    if (childSettingValueName.Length > 0)
                    {
                        childSettingValueName = SettingsCatalogHelper.ToCamelCase(childSettingValueName);
                    }

                    // Find matching child template from parent's children
                    var childTemplate = instanceTemplate?.Children
                        ?.FirstOrDefault(c => string.Equals(c.SettingDefinitionId, childDef.Id, StringComparison.OrdinalIgnoreCase));

                    string childValueTemplateId = null;
                    if (childTemplate is not null)
                    {
                        // Extract the value template ID from the child template
                        childValueTemplateId = childTemplate.ValueTemplateId;
                    }

                    string childIdSuffix = GetChildNameFromId(settingDefinition.Id, childDef.Id);
                    if (childIdSuffix.Length > 0 && currentDscParams.ContainsKey(childIdSuffix))
                    {
                        string resolvedName = SettingsCatalogHelper.GetSettingName(childDef, effectiveAllDefinitions);
                        if (!string.IsNullOrEmpty(resolvedName) && !currentDscParams.ContainsKey(resolvedName))
                        {
                            currentDscParams[resolvedName] = currentDscParams[childIdSuffix];
                        }
                    }

                    var childValue = BuildSettingInstanceValue(
                        currentDscParams,
                        childDef,
                        childTemplate,
                        effectiveAllDefinitions,
                        currentDefinitions,
                        childDef.ODataType ?? string.Empty,
                        childSettingValueName,
                        childSettingValueType,
                        childValueTemplateId,
                        childInstanceName,
                        level + 1);

                    if (childValue is null || childValue.Count == 0)
                        continue;

                    // Special wrapping case: single child definition with maxCount=1 but multiple group values
                    // If only one child item is allowed but we have multiple values, we need to create an object for each child
                    // Happens e.g. for the IntuneDeviceControlPolicyWindows10 resource --> {ruleid} and {ruleid}_ruledata definitions
                    if (childValue.ContainsKey("groupSettingCollectionValue"))
                    {
                        var innerGroupValues = childValue["groupSettingCollectionValue"] as object[];
                        if (innerGroupValues is not null && innerGroupValues.Length > 1 &&
                            childDef.MaximumCount == 1 && childDefinitions.Count == 1)
                        {
                            // Wrap each inner group value in its own parent group
                            foreach (var innerGroupValue in innerGroupValues)
                            {
                                var innerGroupHt = innerGroupValue as Hashtable;
                                if (innerGroupHt is null) continue;

                                var wrappedChild = new Hashtable(StringComparer.OrdinalIgnoreCase)
                                {
                                    ["children"] = new object[]
                                    {
                                        new Hashtable(StringComparer.OrdinalIgnoreCase)
                                        {
                                            ["@odata.type"] = GroupSettingCollectionInstanceType,
                                            ["groupSettingCollectionValue"] = new object[]
                                            {
                                                new Hashtable(StringComparer.OrdinalIgnoreCase)
                                                {
                                                    ["children"] = innerGroupHt["children"]
                                                }
                                            },
                                            ["settingDefinitionId"] = childDef.Id
                                        }
                                    }
                                };
                                groupSettingCollectionValue.Add(wrappedChild);
                            }
                            continue;
                        }
                    }

                    // Normal case: add settingDefinitionId and @odata.type
                    if (!childValue.ContainsKey("settingDefinitionId"))
                    {
                        childValue["settingDefinitionId"] = childDef.Id;
                    }
                    childValue["@odata.type"] = childSettingType;
                    groupChildren.Add(childValue);
                }

                // Only add if there are children (does not happen for wrapped children)
                if (groupChildren.Count > 0)
                {
                    groupSettingCollectionValue.Add(new Hashtable(StringComparer.OrdinalIgnoreCase)
                    {
                        ["children"] = groupChildren.Cast<object>().ToArray()
                    });
                }
            }

            if (childDefinitions.Count > 0 && groupSettingCollectionValue.Count > 0)
            {
                result["groupSettingCollectionValue"] = groupSettingCollectionValue.ToArray();
            }

            return result;
        }

        #endregion

        #region ChoiceSetting
        // ChoiceSetting is a choice (e.g. dropdown) setting that, depending on the choice, can have children settings
        private static Hashtable BuildChoiceSettingValue(
            Hashtable dscParams,
            SettingDefinitionInfo settingDefinition,
            SettingInstanceTemplateInfo instanceTemplate,
            List<SettingDefinitionInfo> allDefinitions,
            List<SettingDefinitionInfo> currentDefinitions,
            string settingValueType,
            string settingValueTemplateId,
            string settingInstanceName)
        {
            var result = new Hashtable(StringComparer.OrdinalIgnoreCase);
            var choiceSettingValue = new Hashtable(StringComparer.OrdinalIgnoreCase);
            var choiceChildren = new List<Hashtable>();

            // Find child definitions
            var childDefinitions = FindChildDefinitions(currentDefinitions, settingDefinition.Id);

            foreach (var childDef in childDefinitions)
            {
                string childSettingType = childDef.ODataType?.Replace("Definition", "Instance") ?? string.Empty;
                string childSettingValueName = childSettingType
                    .Replace(ODataTypePrefix, "")
                    .Replace("Instance", "Value");
                string childSettingValueType = ODataTypePrefix + childSettingValueName;
                if (childSettingValueName.Length > 0)
                {
                    childSettingValueName = SettingsCatalogHelper.ToCamelCase(childSettingValueName);
                }

                // Find child template from parent's choiceSettingValueTemplate.children
                var childTemplate = instanceTemplate?.Children
                    ?.FirstOrDefault(c => string.Equals(c.SettingDefinitionId, childDef.Id, StringComparison.OrdinalIgnoreCase));

                // Extract value template ID - may need to match by settingDefinitionId
                string childValueTemplateId = null;
                if (childTemplate is not null)
                {
                    childValueTemplateId = childTemplate.ValueTemplateId;
                }

                var childValue = BuildSettingInstanceValue(
                    dscParams, childDef, childTemplate,
                    allDefinitions, currentDefinitions,
                    childDef.ODataType ?? string.Empty,
                    childSettingValueName, childSettingValueType,
                    childValueTemplateId, settingInstanceName,
                    level: 1);

                if (childValue is null || childValue.Count == 0)
                    continue;

                if (!childValue.ContainsKey("settingDefinitionId"))
                {
                    childValue["settingDefinitionId"] = childDef.Id;
                }

                if (childTemplate is not null && !string.IsNullOrEmpty(childTemplate.SettingInstanceTemplateId))
                {
                    childValue["settingInstanceTemplateReference"] = new Hashtable(StringComparer.OrdinalIgnoreCase)
                    {
                        ["settingInstanceTemplateId"] = childTemplate.SettingInstanceTemplateId
                    };
                }

                // Fix: SettingGroupCollectionInstance -> GroupSettingCollectionInstance
                if (childSettingType == "#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionInstance")
                {
                    childSettingType = GroupSettingCollectionInstanceType;
                }

                childValue["@odata.type"] = childSettingType;
                choiceChildren.Add(childValue);
            }

            var nestedChildren = choiceChildren
                .Where(child => child["settingDefinitionId"] is string childId &&
                    choiceChildren.Any(sibling => !ReferenceEquals(sibling, child) && ContainsSettingDefinition(sibling, childId)))
                .ToList();
            foreach (var nestedChild in nestedChildren)
            {
                choiceChildren.Remove(nestedChild);
            }

            // Children array is required - either populated children or empty array
            choiceSettingValue["children"] = childDefinitions.Count > 0
                ? choiceChildren.Cast<object>().ToArray()
                : [];

            // Resolve the choice value from DSC params
            var valueResult = SettingValueResolver.Resolve(
                settingValueType, settingDefinition, allDefinitions, dscParams);

            if (valueResult?.Value is not null)
            {
                choiceSettingValue["value"] = valueResult.Value;
                // Derive the value @odata.type
                string odataType = (settingDefinition.ODataType ?? string.Empty)
                    .Replace("Definition", "Value")
                    .Replace("Instance", "Value");
                // If settingType passed was already an Instance type, handle that too
                if (string.IsNullOrEmpty(odataType) || !odataType.Contains("Value"))
                {
                    odataType = ChoiceSettingValueType;
                }
                choiceSettingValue["@odata.type"] = odataType;

                if (!string.IsNullOrEmpty(settingValueTemplateId))
                {
                    choiceSettingValue["settingValueTemplateReference"] = new Hashtable(StringComparer.OrdinalIgnoreCase)
                    {
                        ["settingValueTemplateId"] = settingValueTemplateId
                    };
                }
            }

            // Add to result only if there are children or a value
            if ((choiceChildren.Count > 0) || choiceSettingValue.ContainsKey("value"))
            {
                result["choiceSettingValue"] = choiceSettingValue;
            }

            return result;
        }

        #endregion

        #region ChoiceSettingCollection
        // ChoiceSettingCollection is a collection of ChoiceSettings
        private static Hashtable BuildChoiceSettingCollectionValue(
            Hashtable dscParams,
            SettingDefinitionInfo settingDefinition,
            List<SettingDefinitionInfo> allDefinitions,
            string settingValueType)
        {
            var result = new Hashtable(StringComparer.OrdinalIgnoreCase);

            if (string.IsNullOrEmpty(settingValueType))
            {
                settingValueType = "microsoft.graph.deviceManagementConfigurationChoiceSettingCollection";
            }

            var valueResult = SettingValueResolver.Resolve(
                settingValueType, settingDefinition, allDefinitions, dscParams);

            if (valueResult?.Value is null)
                return result;

            var values = valueResult.Value as IEnumerable;
            if (values is null && valueResult.Value is not null)
            {
                values = new[] { valueResult.Value };
            }

            // Add all values to the collection, each with its own children array (empty) and @odata.type
            List<Hashtable> collection = [];
            foreach (var value in values)
            {
                collection.Add(new Hashtable(StringComparer.OrdinalIgnoreCase)
                {
                    ["value"] = value,
                    ["children"] = Array.Empty<object>(),
                    ["@odata.type"] = ChoiceSettingValueType
                });
            }

            if (collection.Count > 0)
            {
                result["choiceSettingCollectionValue"] = collection.Cast<object>().ToArray();
            }

            return result;
        }

        #endregion

        #region SimpleSettingCollection
        // SimpleSettingCollections are collections of simple settings, e.g. strings or integers
        private static Hashtable? BuildSimpleSettingCollectionValue(
            Hashtable dscParams,
            SettingDefinitionInfo settingDefinition,
            List<SettingDefinitionInfo> allDefinitions,
            string settingValueType,
            string settingValueName)
        {
            var result = new Hashtable(StringComparer.OrdinalIgnoreCase);

            var valuesResult = SettingValueResolver.Resolve(
                settingValueType, settingDefinition, allDefinitions, dscParams);

            if (valuesResult is null)
                return null;

            // Derive the collection item type from the value definition
            string itemODataType = settingValueType;
            if (valuesResult.SettingDefinition?.ValueDefinition?.ODataType is not null)
            {
                itemODataType = valuesResult.SettingDefinition.ValueDefinition.ODataType.Replace("Definition", "");
            }

            List<Hashtable> collection = [];
            var values = valuesResult.Value as IEnumerable;
            if (values is null && valuesResult.Value is not null)
            {
                values = new[] { valuesResult.Value };
            }

            if (values is not null)
            {
                foreach (var v in values)
                {
                    collection.Add(new Hashtable(StringComparer.OrdinalIgnoreCase)
                    {
                        ["value"] = v,
                        ["@odata.type"] = itemODataType
                    });
                }
            }

            if (collection.Count > 0)
            {
                result[settingValueName] = collection.Cast<object>().ToArray();
            }

            return result;
        }

        #endregion

        #region Simple setting (default)

        private static Hashtable? BuildSimpleSettingValue(
            Hashtable dscParams,
            SettingDefinitionInfo settingDefinition,
            List<SettingDefinitionInfo> allDefinitions,
            string settingValueType,
            string settingValueName,
            string settingValueTemplateId)
        {
            var result = new Hashtable(StringComparer.OrdinalIgnoreCase);

            var valueResult = SettingValueResolver.Resolve(
                settingValueType, settingDefinition, allDefinitions, dscParams);

            if (valueResult is null || valueResult.Value is null)
                return null;

            // Update to resolved types
            string resolvedValueType = valueResult.SettingValueType ?? settingValueType;
            var resolvedDefinition = valueResult.SettingDefinition ?? settingDefinition;

            var settingValue = new Hashtable(StringComparer.OrdinalIgnoreCase);

            if (!string.IsNullOrEmpty(resolvedValueType))
            {
                // Handle secret settings
                if (resolvedDefinition?.ValueDefinition?.IsSecret == true)
                {
                    resolvedValueType = SecretSettingValueType;
                    settingValue["valueState"] = "NotEncrypted";
                }
                settingValue["@odata.type"] = resolvedValueType;
            }

            if (!string.IsNullOrEmpty(settingValueTemplateId))
            {
                settingValue["settingValueTemplateReference"] = new Hashtable(StringComparer.OrdinalIgnoreCase)
                {
                    ["settingValueTemplateId"] = settingValueTemplateId
                };
            }

            settingValue["value"] = valueResult.Value;

            result[settingValueName] = settingValue;
            result["settingDefinitionId"] = resolvedDefinition?.Id ?? settingDefinition.Id;

            return result;
        }

        #endregion

        #region Helper methods

        /// <summary>
        /// Finds child setting definitions that depend on the given parent setting ID.
        /// Checks both <c>dependentOn.parentSettingId</c> and <c>options.dependentOn.parentSettingId</c>.
        /// </summary>
        private static List<SettingDefinitionInfo> FindChildDefinitions(
            List<SettingDefinitionInfo> definitions,
            string parentSettingId)
        {
            return SettingsCatalogHelper.DefinitionLookups.For(definitions).ChildrenOf(parentSettingId);
        }

        /// <summary>
        /// Resolves the current DSC params for the current iteration of a multi-instance group.
        /// </summary>
        private static Hashtable ResolveCurrentDscParams(Hashtable dscParams, string cimParamName, int instanceCount, int index)
        {
            if (instanceCount == 1)
            {
                if (!string.IsNullOrEmpty(cimParamName) && dscParams.ContainsKey(cimParamName))
                {
                    var single = dscParams[cimParamName];
                    return single is Hashtable ht ? ht : dscParams;
                }
                return dscParams;
            }

            if (!string.IsNullOrEmpty(cimParamName) && dscParams.ContainsKey(cimParamName))
            {
                var arr = dscParams[cimParamName] as object[];
                if (arr is not null && index < arr.Length)
                {
                    return arr[index] as Hashtable ?? new Hashtable(StringComparer.OrdinalIgnoreCase);
                }
            }

            return new Hashtable(StringComparer.OrdinalIgnoreCase);
        }

        private static bool IsGroupSettingCollection(string settingType)
        {
            return IsAnyOf(settingType, GroupSettingCollectionInstanceType, SettingGroupCollectionDefinitionType);
        }

        private static bool IsChoiceSetting(string settingType)
        {
            return IsAnyOf(settingType, ChoiceSettingInstanceType, ChoiceSettingDefinitionType);
        }

        private static bool IsChoiceSettingCollection(string settingType)
        {
            return IsAnyOf(settingType, ChoiceSettingCollectionInstanceType, ChoiceSettingCollectionDefinitionType);
        }

        private static bool IsSimpleSettingCollection(string settingType)
        {
            return IsAnyOf(settingType, SimpleSettingCollectionInstanceType, SimpleSettingCollectionDefinitionType);
        }

        /// <summary>
        /// A setting type arrives either as the instance OData type or as the matching definition
        /// type, so every check above accepts both spellings.
        /// </summary>
        private static bool IsAnyOf(string settingType, string instanceType, string definitionType)
        {
            return string.Equals(settingType, instanceType, StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(settingType, definitionType, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Returns true when a setting instance with the given definition id is nested anywhere below the instance.
        /// </summary>
        private static bool ContainsSettingDefinition(object node, string settingDefinitionId)
        {
            switch (node)
            {
                case Hashtable table:
                    foreach (DictionaryEntry entry in table)
                    {
                        if (entry.Value is Hashtable nested &&
                            string.Equals(nested["settingDefinitionId"] as string, settingDefinitionId, StringComparison.OrdinalIgnoreCase))
                        {
                            return true;
                        }
                        if (ContainsSettingDefinition(entry.Value, settingDefinitionId))
                        {
                            return true;
                        }
                    }
                    return false;
                case IEnumerable items when node is not string:
                    foreach (var item in items)
                    {
                        if (item is Hashtable nested &&
                            string.Equals(nested["settingDefinitionId"] as string, settingDefinitionId, StringComparison.OrdinalIgnoreCase))
                        {
                            return true;
                        }
                        if (ContainsSettingDefinition(item, settingDefinitionId))
                        {
                            return true;
                        }
                    }
                    return false;
                default:
                    return false;
            }
        }

        #endregion

        #region CIM Instance helpers

        private static bool ContainsValue(object value) => value switch
        {
            null => false,
            string text => text.Length > 0,
            ICollection collection => collection.Count > 0,
            _ => true,
        };

        private static string GetChildNameFromId(string parentId, string childId)
        {
            if (string.IsNullOrEmpty(parentId) || string.IsNullOrEmpty(childId))
                return string.Empty;

            string prefix = parentId + "_";
            return childId.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)
                ? childId.Substring(prefix.Length)
                : string.Empty;
        }

        private static string GetClassNameOf(object value) => value switch
        {
            CimInstance cim => cim.CimClass?.CimSystemProperties?.ClassName
                ?? cim.CimSystemProperties?.ClassName
                ?? string.Empty,
            null => string.Empty,
            _ => value.GetType().Name,
        };

        /// <summary>
        /// Scans DSCParams values for embedded instances matching the expected CIM class name.
        /// Matches exact class name or alternate <c>{name}_Intune*</c> pattern.
        /// </summary>
        internal static (string ParamName, List<object> Instances) FindCimInstancesByClassName(
            Hashtable dscParams,
            string expectedClassName)
        {
            string alternateName = expectedClassName + "_Intune";
            List<object> instances = [];
            string paramName = string.Empty;

            bool Matches(string className)
            {
                if (string.IsNullOrEmpty(className))
                    return false;

                if (string.Equals(className, expectedClassName, StringComparison.OrdinalIgnoreCase) ||
                    className.StartsWith(alternateName, StringComparison.OrdinalIgnoreCase))
                    return true;

                if (!className.StartsWith(expectedClassName, StringComparison.OrdinalIgnoreCase))
                    return false;

                string suffix = className.Substring(expectedClassName.Length);
                return suffix.Length > 1
                    && (suffix[0] == 'V' || suffix[0] == 'v')
                    && suffix.Skip(1).All(char.IsDigit);
            }

            void Collect(object candidate, object key)
            {
                object value = candidate is PSObject pso ? pso.BaseObject : candidate;
                if (value is null)
                    return;

                if (value is IEnumerable enumerable and not string and not Hashtable)
                {
                    foreach (var item in enumerable)
                        Collect(item, key);
                    return;
                }

                if (!Matches(GetClassNameOf(value)))
                    return;

                instances.Add(value);
                paramName = key?.ToString() ?? string.Empty;
            }

            foreach (DictionaryEntry entry in dscParams)
                Collect(entry.Value, entry.Key);

            return (paramName, instances);
        }

        /// <summary>
        /// Extracts the properties an embedded instance carries a value for.
        /// Property names are PascalCase. Nested instances are preserved as-is for recursive processing.
        /// </summary>
        internal static Hashtable ExtractCimPropertiesModifiedOnly(object instance)
        {
            var result = new Hashtable(StringComparer.OrdinalIgnoreCase);
            object value = instance is PSObject pso ? pso.BaseObject : instance;
            if (value is null)
                return result;

            if (value is Hashtable hashtable)
                return hashtable;

            if (value is CimInstance cimInstance)
            {
                foreach (var property in cimInstance.CimInstanceProperties)
                {
                    if (property.IsValueModified)
                    {
                        result[property.Name] = property.Value;
                    }
                }

                return result;
            }

            foreach (var property in value.GetType().GetProperties())
            {
                if (!property.CanRead || property.GetIndexParameters().Length > 0)
                    continue;

                object propertyValue = property.GetValue(value);
                if (ContainsValue(propertyValue))
                {
                    result[property.Name] = propertyValue;
                }
            }

            return result;
        }

        /// <summary>
        /// Extracts properties from an embedded instance with camelCase property names.
        /// Carries only the properties that hold a value, and excludes PSComputerName.
        /// Mirrors <c>Convert-M365DSCDRGComplexTypeToHashtable -SingleLevel -ExcludeUnchangedProperties</c>.
        /// </summary>
        internal static Hashtable ExtractCimPropertiesCamelCase(object value)
        {
            var result = new Hashtable(StringComparer.OrdinalIgnoreCase);
            if (value is null)
                return result;

            // Unwrap PSObject
            if (value is PSObject pso)
                value = pso.BaseObject;

            if (value is CimInstance or not Hashtable)
            {
                foreach (DictionaryEntry entry in ExtractCimPropertiesModifiedOnly(value))
                {
                    string name = entry.Key?.ToString() ?? string.Empty;
                    if (name.Length == 0 ||
                        string.Equals(name, "PSComputerName", StringComparison.OrdinalIgnoreCase))
                        continue;

                    result[SettingsCatalogHelper.ToCamelCase(name)] = entry.Value;
                }
            }
            else if (value is Hashtable ht)
            {
                // Already a hashtable - return as-is
                return ht;
            }

            return result;
        }

        #endregion
    }
}
