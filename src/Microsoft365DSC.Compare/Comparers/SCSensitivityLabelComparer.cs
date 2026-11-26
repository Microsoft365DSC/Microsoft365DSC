using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft365DSC.Compare.Comparers
{
    internal static class SCSensitivityLabelComparer
    {
        private static readonly string[] AutoLabelingMembers = ["Operator", "AutoApplyType", "PolicyTip"];
        private static readonly string[] SensitiveTypeMembers = ["confidencelevel", "classifiertype", "mincount", "maxcount"];

        public static void Compare(CompareRuleContext context)
        {
            CompareSetting(context, "AdvancedSettings", ListAdvancedSettingDrifts, drifts => $"AdvancedSettings do not match: {string.Join(", ", drifts)}");
            CompareSetting(context, "LocaleSettings", ListLocaleSettingDrifts, drifts => $"LocaleSettings do not match: {string.Join(", ", drifts)}");
            CompareSetting(context, "AutoLabelingSettings", ListAutoLabelingDrifts, drifts => $"AutoLabelingSettings do not match: \r\n- {string.Join("\r\n- ", drifts)}");
        }

        private static void CompareSetting(
            CompareRuleContext context,
            string property,
            Func<object, object, List<string>> listDrifts,
            Func<List<string>, string> describeDrifts)
        {
            RuleValues.RemoveValue(context.ValuesToCheck, property);
            object? desired = RuleValues.GetValue(context.Desired, property);
            object? current = RuleValues.GetValue(context.Current, property);
            if (desired is null || current is null)
            {
                return;
            }

            List<string> drifts = listDrifts(desired, current);
            if (drifts.Count == 0)
            {
                return;
            }

            context.LogDrift(describeDrifts(drifts));
            Hashtable drifted = new(StringComparer.OrdinalIgnoreCase) { ["Drift"] = "desired" };
            RuleValues.SetValue(context.Desired, property, drifted);
            RuleValues.SetValue(context.Current, property, new Hashtable(StringComparer.OrdinalIgnoreCase) { ["Drift"] = "current" });
            RuleValues.SetValue(context.ValuesToCheck, property, drifted);
        }

        private static List<string> ListAdvancedSettingDrifts(object desired, object current)
        {
            Dictionary<string, IDictionary> currentSettings = PowerShellValues.BuildMemberIndex(current, "Key");
            return
            [
                .. PowerShellValues.ListDictionaries(desired)
                    .Where(setting => !IsSettingMatching(setting, currentSettings))
                    .Select(setting => PowerShellValues.ConvertToText(RuleValues.GetValue(setting, "Key")))
            ];
        }

        private static bool IsSettingMatching(IDictionary setting, Dictionary<string, IDictionary> currentSettings) =>
            currentSettings.TryGetValue(PowerShellValues.ConvertToText(RuleValues.GetValue(setting, "Key")), out IDictionary? currentSetting) &&
            PowerShellValues.IsTextListEqualIgnoringOrder(RuleValues.GetValue(setting, "Value"), RuleValues.GetValue(currentSetting, "Value"));

        private static List<string> ListLocaleSettingDrifts(object desired, object current)
        {
            List<string> drifts = [];
            Dictionary<string, IDictionary> currentLocales = PowerShellValues.BuildMemberIndex(current, "LocaleKey");
            foreach (IDictionary locale in PowerShellValues.ListDictionaries(desired))
            {
                string localeKey = PowerShellValues.ConvertToText(RuleValues.GetValue(locale, "LocaleKey"));
                Dictionary<string, IDictionary> currentSettings = currentLocales.TryGetValue(localeKey, out IDictionary? currentLocale)
                    ? PowerShellValues.BuildMemberIndex(RuleValues.GetValue(currentLocale, "LabelSettings"), "Key")
                    : new Dictionary<string, IDictionary>(StringComparer.OrdinalIgnoreCase);

                foreach (IDictionary setting in PowerShellValues.ListDictionaries(RuleValues.GetValue(locale, "LabelSettings")))
                {
                    string settingKey = PowerShellValues.ConvertToText(RuleValues.GetValue(setting, "Key"));
                    if (!IsLocaleValueFound(RuleValues.GetValue(setting, "Value"), settingKey, currentSettings))
                    {
                        drifts.Add($"{localeKey} ({settingKey})");
                    }
                }
            }

            return drifts;
        }

        // A desired value given as an array must have exactly one item.
        private static bool IsLocaleValueFound(object? desiredValue, string settingKey, Dictionary<string, IDictionary> currentSettings)
        {
            if (desiredValue is Array array)
            {
                if (array.Length != 1)
                {
                    return false;
                }

                desiredValue = array.GetValue(0);
            }

            string desiredText = PowerShellValues.ConvertToText(desiredValue);
            return currentSettings.TryGetValue(settingKey, out IDictionary? currentSetting) &&
                RuleValues.ListItems(RuleValues.GetValue(currentSetting, "Value")).Any(candidate => PowerShellValues.IsEqual(PowerShellValues.ConvertToText(candidate), desiredText));
        }

        private static List<string> ListAutoLabelingDrifts(object desired, object current)
        {
            List<string> drifts = [];
            foreach (string member in AutoLabelingMembers)
            {
                if (member == "PolicyTip" && !HasMember(desired, member))
                {
                    continue;
                }

                string desiredValue = PowerShellValues.ConvertToText(PowerShellValues.ReadMember(desired, member));
                string currentValue = PowerShellValues.ConvertToText(PowerShellValues.ReadMember(current, member));
                if (!PowerShellValues.IsEqual(desiredValue, currentValue))
                {
                    drifts.Add($"Parameter '{member}' does not match. Current: '{currentValue}'. Desired: '{desiredValue}'.");
                }
            }

            object? desiredGroups = PowerShellValues.ReadMember(desired, "Groups");
            object? currentGroups = PowerShellValues.ReadMember(current, "Groups");
            Dictionary<string, IDictionary> desiredGroupIndex = PowerShellValues.BuildMemberIndex(desiredGroups, "Name");
            Dictionary<string, IDictionary> currentGroupIndex = PowerShellValues.BuildMemberIndex(currentGroups, "Name");

            foreach (IDictionary group in PowerShellValues.ListDictionaries(desiredGroups))
            {
                string groupName = PowerShellValues.ConvertToText(RuleValues.GetValue(group, "Name"));
                if (!currentGroupIndex.TryGetValue(groupName, out IDictionary? currentGroup))
                {
                    drifts.Add($"Group '{groupName}' not found in the current settings.");
                    continue;
                }

                drifts.AddRange(ListGroupDrifts(group, currentGroup, groupName));
            }

            foreach (IDictionary group in PowerShellValues.ListDictionaries(currentGroups))
            {
                string groupName = PowerShellValues.ConvertToText(RuleValues.GetValue(group, "Name"));
                if (!desiredGroupIndex.TryGetValue(groupName, out IDictionary? desiredGroup))
                {
                    drifts.Add($"Group '{groupName}' not found in the desired settings.");
                    continue;
                }

                drifts.AddRange(ListMissingItems(group, desiredGroup, "SensitiveInformationType", name => $"Sensitive Information Type '{name}' not found in the desired settings for group '{groupName}'."));
                drifts.AddRange(ListMissingItems(group, desiredGroup, "TrainableClassifier", name => $"Trainable Classifier '{name}' not found in the desired settings for group '{groupName}'."));
            }

            return drifts;
        }

        private static IEnumerable<string> ListGroupDrifts(IDictionary group, IDictionary currentGroup, string groupName)
        {
            string desiredOperator = PowerShellValues.ConvertToText(RuleValues.GetValue(group, "Operator"));
            string currentOperator = PowerShellValues.ConvertToText(RuleValues.GetValue(currentGroup, "Operator"));
            if (!PowerShellValues.IsEqual(desiredOperator, currentOperator))
            {
                yield return $"Parameter 'Groups\\{groupName}\\Operator' does not match. Current: '{currentOperator}'. Desired: '{desiredOperator}'.";
            }

            Dictionary<string, IDictionary> currentTypes = PowerShellValues.BuildMemberIndex(RuleValues.GetValue(currentGroup, "SensitiveInformationType"), "name");
            foreach (IDictionary type in PowerShellValues.ListDictionaries(RuleValues.GetValue(group, "SensitiveInformationType")))
            {
                string typeName = PowerShellValues.ConvertToText(RuleValues.GetValue(type, "name"));
                if (!currentTypes.TryGetValue(typeName, out IDictionary? currentType))
                {
                    yield return $"Sensitive Information Type '{typeName}' not found in the current settings for group '{groupName}'.";
                    continue;
                }

                foreach (string member in SensitiveTypeMembers.Where(member => RuleValues.HasKey(type, member)))
                {
                    string desiredValue = PowerShellValues.ConvertToText(RuleValues.GetValue(type, member));
                    string currentValue = PowerShellValues.ConvertToText(RuleValues.GetValue(currentType, member));
                    if (!PowerShellValues.IsEqual(desiredValue, currentValue))
                    {
                        yield return $"Parameter '{member}' does not match for Sensitive Information Type '{typeName}' in group '{groupName}'. Current: '{currentValue}'. Desired: '{desiredValue}'.";
                    }
                }
            }

            foreach (string name in ListMissingItems(group, currentGroup, "TrainableClassifier", name => name))
            {
                yield return $"Trainable Classifier '{name}' not found in the current settings for group '{groupName}'.";
            }
        }

        private static IEnumerable<string> ListMissingItems(IDictionary group, IDictionary otherGroup, string member, Func<string, string> describe)
        {
            Dictionary<string, IDictionary> otherItems = PowerShellValues.BuildMemberIndex(RuleValues.GetValue(otherGroup, member), "name");
            return PowerShellValues.ListDictionaries(RuleValues.GetValue(group, member))
                .Select(item => PowerShellValues.ConvertToText(RuleValues.GetValue(item, "name")))
                .Where(name => !otherItems.ContainsKey(name))
                .Select(describe);
        }

        private static bool HasMember(object value, string member) =>
            value is IDictionary dictionary && RuleValues.HasKey(dictionary, member);
    }
}
