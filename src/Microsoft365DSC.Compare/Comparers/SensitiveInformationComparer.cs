using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft365DSC.Compare.Comparers
{
    internal static class SensitiveInformationComparer
    {
        private const string DriftedDesired = "SIT-Drift-Desired";
        private const string DriftedCurrent = "SIT-Drift-Current";
        private const string NotInDesiredState = "DLP Compliance Rule was not in the desired state.\r\n";

        private static readonly string[] ContentProperties = ["ContentContainsSensitiveInformation", "ExceptIfContentContainsSensitiveInformation"];
        private static readonly string[] TypeMembers = ["id", "maxconfidence", "minconfidence", "classifiertype", "mincount", "maxcount"];
        private static readonly string[] LabelMembers = ["id", "type"];
        private static readonly string[] RestrictionMembers = ["Setting", "Value", "Value2"];

        public static void CompareAutoSensitivityLabelRule(CompareRuleContext context)
        {
            CompareContent(context, isSensitiveTypesRead: false);
        }

        public static void CompareDlpComplianceRule(CompareRuleContext context)
        {
            CompareContent(context, isSensitiveTypesRead: true);
            TrimEndpointRestrictions(context);
            CompareAdvancedRule(context);
        }

        private static void CompareContent(CompareRuleContext context, bool isSensitiveTypesRead)
        {
            foreach (string property in ContentProperties)
            {
                object? desired = RuleValues.GetValue(context.Desired, property);
                if (desired is null)
                {
                    continue;
                }

                object? current = RuleValues.GetValue(context.Current, property);
                bool isMatch = PowerShellValues.ReadMember(desired, "groups") is null
                    ? HasMatchForEveryType(ListSensitiveInformation(desired), ListSensitiveInformation(current), context)
                    : HasMatchForEveryGroup(desired, current, isSensitiveTypesRead, context);

                if (isMatch)
                {
                    RuleValues.RemoveValue(context.Desired, property);
                    RuleValues.RemoveValue(context.Current, property);
                    RuleValues.RemoveValue(context.ValuesToCheck, property);
                }
                else
                {
                    RuleValues.SetValue(context.Desired, property, DriftedDesired);
                    RuleValues.SetValue(context.Current, property, DriftedCurrent);
                    RuleValues.SetValue(context.ValuesToCheck, property, DriftedDesired);
                }
            }
        }

        private static IReadOnlyList<IDictionary> ListSensitiveInformation(object? content) =>
            PowerShellValues.ListDictionaries(PowerShellValues.ReadMember(content, "SensitiveInformation"));

        private static IReadOnlyList<IDictionary> ListGroupTypes(IDictionary group, bool isSensitiveTypesRead) =>
            isSensitiveTypesRead
                ? [.. PowerShellValues.ListDictionaries(RuleValues.GetValue(group, "SensitiveInformation")), .. PowerShellValues.ListDictionaries(RuleValues.GetValue(group, "SensitiveTypes"))]
                : PowerShellValues.ListDictionaries(RuleValues.GetValue(group, "SensitiveInformation"));

        private static bool HasMatchForEveryGroup(object desired, object? current, bool isSensitiveTypesRead, CompareRuleContext context)
        {
            string desiredOperator = PowerShellValues.ConvertToText(PowerShellValues.ReadMember(desired, "operator"));
            string currentOperator = PowerShellValues.ConvertToText(PowerShellValues.ReadMember(current, "operator"));
            if (!PowerShellValues.IsEqual(desiredOperator, currentOperator))
            {
                context.LogDrift($"{NotInDesiredState}DLP Compliance Rule has invalid value for property operator. Current value is {{{currentOperator}}} and is expected to be {{{desiredOperator}}}.");
                return false;
            }

            Dictionary<string, IDictionary> currentGroups = PowerShellValues.BuildMemberIndex(PowerShellValues.ReadMember(current, "groups"), "name");
            foreach (IDictionary group in PowerShellValues.ListDictionaries(PowerShellValues.ReadMember(desired, "groups")))
            {
                string groupName = PowerShellValues.ConvertToText(RuleValues.GetValue(group, "name"));
                if (!currentGroups.TryGetValue(groupName, out IDictionary? currentGroup))
                {
                    context.LogDrift($"{NotInDesiredState}An action on {{{groupName}}} Sensitive Information Type is missing.");
                    return false;
                }

                string desiredGroupOperator = PowerShellValues.ConvertToText(RuleValues.GetValue(group, "operator"));
                string currentGroupOperator = PowerShellValues.ConvertToText(RuleValues.GetValue(currentGroup, "operator"));
                if (!PowerShellValues.IsEqual(desiredGroupOperator, currentGroupOperator))
                {
                    context.LogDrift($"{NotInDesiredState}Group {{{groupName}}} has invalid value for property operator. Current value is {{{currentGroupOperator}}} and is expected to be {{{desiredGroupOperator}}}.");
                    return false;
                }

                IReadOnlyList<IDictionary> desiredTypes = ListGroupTypes(group, isSensitiveTypesRead);
                if (desiredTypes.Count > 0 && !HasMatchForEveryType(desiredTypes, ListGroupTypes(currentGroup, isSensitiveTypesRead), context))
                {
                    return false;
                }

                IReadOnlyList<IDictionary> desiredLabels = PowerShellValues.ListDictionaries(RuleValues.GetValue(group, "labels"));
                if (desiredLabels.Count > 0 && !HasMatchForEveryLabel(desiredLabels, PowerShellValues.ListDictionaries(RuleValues.GetValue(currentGroup, "labels")), context))
                {
                    return false;
                }
            }

            return true;
        }

        private static bool HasMatchForEveryType(IReadOnlyList<IDictionary> desired, IReadOnlyList<IDictionary> current, CompareRuleContext context) =>
            HasMatchForEveryItem(desired, current, TypeMembers, "Sensitive Information Type", context);

        private static bool HasMatchForEveryLabel(IReadOnlyList<IDictionary> desired, IReadOnlyList<IDictionary> current, CompareRuleContext context) =>
            HasMatchForEveryItem(desired, current, LabelMembers, "Sensitive Information label", context);

        private static bool HasMatchForEveryItem(
            IReadOnlyList<IDictionary> desired,
            IReadOnlyList<IDictionary> current,
            IReadOnlyList<string> members,
            string itemKind,
            CompareRuleContext context)
        {
            Dictionary<string, IDictionary> currentItems = PowerShellValues.BuildMemberIndex(current, "name");
            foreach (IDictionary item in desired)
            {
                string name = PowerShellValues.ConvertToText(RuleValues.GetValue(item, "name"));
                if (!currentItems.TryGetValue(name.Replace("''", "'"), out IDictionary? match))
                {
                    context.LogDrift($"{NotInDesiredState}An action on {{{name}}} {itemKind} is missing.");
                    return false;
                }

                foreach (string member in members)
                {
                    string desiredValue = PowerShellValues.ConvertToText(RuleValues.GetValue(item, member));
                    string currentValue = PowerShellValues.ConvertToText(RuleValues.GetValue(match, member));
                    if (!PowerShellValues.IsEqual(desiredValue, currentValue))
                    {
                        context.LogDrift($"{NotInDesiredState}Sensitive Information Action {{{name}}} has invalid value for property {{{member}}}. Current value is {{{currentValue}}} and is expected to be {{{desiredValue}}}.");
                        return false;
                    }
                }
            }

            return true;
        }

        private static void TrimEndpointRestrictions(CompareRuleContext context)
        {
            object? desired = RuleValues.GetValue(context.Desired, "EndpointDlpRestrictions");
            if (desired is null)
            {
                return;
            }

            object[] desiredRestrictions = KeepRestrictionMembers(desired);
            RuleValues.SetValue(context.Desired, "EndpointDlpRestrictions", desiredRestrictions);
            RuleValues.SetValue(context.ValuesToCheck, "EndpointDlpRestrictions", desiredRestrictions);
            object? current = RuleValues.GetValue(context.Current, "EndpointDlpRestrictions");
            RuleValues.SetValue(context.Current, "EndpointDlpRestrictions", current is null ? null : KeepRestrictionMembers(current));
        }

        private static object[] KeepRestrictionMembers(object restrictions) =>
            [.. PowerShellValues.ListDictionaries(restrictions).Select(restriction =>
            {
                Hashtable kept = new(StringComparer.OrdinalIgnoreCase);
                foreach (string member in RestrictionMembers.Where(member => RuleValues.GetValue(restriction, member) is not null))
                {
                    kept[member] = RuleValues.GetValue(restriction, member);
                }

                return kept;
            })];

        private static void CompareAdvancedRule(CompareRuleContext context)
        {
            object? desired = RuleValues.GetValue(context.Desired, "AdvancedRule");
            object? current = RuleValues.GetValue(context.Current, "AdvancedRule");
            if (desired is null ||
                !PowerShellValues.IsEqual(RuleValues.GetValue(context.Current, "Ensure"), "Present") ||
                !JsonTree.TryParse(PowerShellValues.ConvertToText(desired), out object? desiredTree) ||
                !JsonTree.TryParse(PowerShellValues.ConvertToText(current), out object? currentTree))
            {
                return;
            }

            ClearModelIds(desiredTree);
            if (JsonTree.IsEqual(desiredTree, currentTree))
            {
                RuleValues.SetValue(context.Desired, "AdvancedRule", current);
                RuleValues.SetValue(context.ValuesToCheck, "AdvancedRule", current);
            }
        }

        private static void ClearModelIds(object? advancedRule)
        {
            Queue<object?> conditions = new(RuleValues.ListItems(PowerShellValues.ReadMember(advancedRule, "Condition")));
            while (conditions.Count > 0)
            {
                object? condition = conditions.Dequeue();
                foreach (object? subCondition in RuleValues.ListItems(PowerShellValues.ReadMember(condition, "SubConditions")))
                {
                    conditions.Enqueue(subCondition);
                }

                if (PowerShellValues.ConvertToText(PowerShellValues.ReadMember(condition, "ConditionName")).IndexOf("ContentContainsSensitiveInformation", StringComparison.OrdinalIgnoreCase) < 0)
                {
                    continue;
                }

                object? sensitiveTypes = PowerShellValues.ReadMember(PowerShellValues.ReadMember(PowerShellValues.ReadMember(condition, "Value"), "Groups"), "Sensitivetypes");
                foreach (IDictionary sensitiveType in PowerShellValues.ListDictionaries(sensitiveTypes))
                {
                    if (PowerShellValues.IsEqual(RuleValues.GetValue(sensitiveType, "Classifiertype"), "MLModel") && RuleValues.GetValue(sensitiveType, "Id") is not null)
                    {
                        RuleValues.SetValue(sensitiveType, "Id", null);
                    }
                }
            }
        }
    }
}
