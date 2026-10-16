using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft365DSC.Compare.Comparers
{
    internal static class SCLabelPolicyComparer
    {
        private static readonly string[] DeltaProperties =
            ["ModernGroupLocation", "ModernGroupLocationException", "ExchangeLocation", "ExchangeLocationException", "Labels"];

        public static void Compare(CompareRuleContext context)
        {
            CompareAdvancedSettings(context);

            foreach (string property in DeltaProperties)
            {
                object? desired = RuleValues.GetValue(context.Desired, property);
                object? added = RuleValues.GetValue(context.Desired, "Add" + property);
                object? removed = RuleValues.GetValue(context.Desired, "Remove" + property);
                if (desired is null && added is null && removed is null)
                {
                    continue;
                }

                object? current = RuleValues.GetValue(context.Current, property);
                string[] expected = [.. BuildExpectedList(desired, current, removed, added).Where(item => item.Length > 0)];
                RuleValues.SetValue(context.Desired, property, expected);
                RuleValues.SetValue(context.Current, property, ListTexts(current).Where(item => item.Length > 0).ToArray());
                RuleValues.SetValue(context.ValuesToCheck, property, expected);
            }
        }

        private static void CompareAdvancedSettings(CompareRuleContext context)
        {
            object? desired = RuleValues.GetValue(context.Desired, "AdvancedSettings");
            if (desired is null)
            {
                return;
            }

            if (HasMatchForEverySetting(desired, RuleValues.GetValue(context.Current, "AdvancedSettings")))
            {
                RuleValues.RemoveValue(context.ValuesToCheck, "AdvancedSettings");
                return;
            }

            Hashtable drifted = new(StringComparer.OrdinalIgnoreCase) { ["Drift"] = "desired" };
            RuleValues.SetValue(context.Desired, "AdvancedSettings", drifted);
            RuleValues.SetValue(context.Current, "AdvancedSettings", new Hashtable(StringComparer.OrdinalIgnoreCase) { ["Drift"] = "current" });
            RuleValues.SetValue(context.ValuesToCheck, "AdvancedSettings", drifted);
        }

        // A desired setting the current settings lack counts as matching.
        private static bool HasMatchForEverySetting(object desired, object? current)
        {
            Dictionary<string, IDictionary> currentSettings = PowerShellValues.BuildMemberIndex(current, "Key");
            return PowerShellValues.ListDictionaries(desired).All(setting =>
                !currentSettings.TryGetValue(PowerShellValues.ConvertToText(RuleValues.GetValue(setting, "Key")), out IDictionary? currentSetting) ||
                PowerShellValues.IsTextListEqualIgnoringOrder(RuleValues.GetValue(setting, "Value"), RuleValues.GetValue(currentSetting, "Value")));
        }

        private static List<string> BuildExpectedList(object? desired, object? current, object? removed, object? added)
        {
            List<string> data = [];
            AddMissing(data, ListTexts(current).Concat(ListTexts(desired)));

            foreach (string item in ListTexts(removed))
            {
                data.Remove(item);
            }

            AddMissing(data, ListTexts(added));
            return data;
        }

        private static void AddMissing(List<string> data, IEnumerable<string> items)
        {
            foreach (string item in items.Where(item => !data.Contains(item)))
            {
                data.Add(item);
            }
        }

        private static IEnumerable<string> ListTexts(object? value) =>
            RuleValues.ListItems(value).Where(item => item is not null).Select(PowerShellValues.ConvertToText);
    }
}
