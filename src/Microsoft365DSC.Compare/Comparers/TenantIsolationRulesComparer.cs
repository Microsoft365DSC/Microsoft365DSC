using Microsoft365DSC.Utilities;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Management.Automation;

namespace Microsoft365DSC.Compare.Comparers
{
    internal static class TenantIsolationRulesComparer
    {
        private static readonly string[] DeltaProperties = ["RulesToInclude", "RulesToExclude"];

        // TenantIds in the declaration maps a tenant name to its id.
        public static Action<CompareRuleContext> Create(object declaration)
        {
            Dictionary<string, string> tenantIds = ReadTenantIds(declaration);
            return context => Compare(context, tenantIds);
        }

        private static void Compare(CompareRuleContext context, Dictionary<string, string> tenantIds)
        {
            object? rules = RuleValues.GetValue(context.Desired, "Rules");
            object? included = RuleValues.GetValue(context.Desired, "RulesToInclude");
            object? excluded = RuleValues.GetValue(context.Desired, "RulesToExclude");

            if (rules is not null)
            {
                object[] effective = [.. PowerShellValues.ListDictionaries(rules).Select(rule => BuildRule(ResolveTenant(rule, tenantIds), RuleValues.GetValue(rule, "Direction")))];
                RuleValues.SetValue(context.Desired, "Rules", effective);
                RuleValues.SetValue(context.ValuesToCheck, "Rules", effective);
            }
            else if (included is not null || excluded is not null)
            {
                OrderedDictionary effective = new(StringComparer.OrdinalIgnoreCase);
                foreach (IDictionary rule in PowerShellValues.ListDictionaries(RuleValues.GetValue(context.Current, "Rules")))
                {
                    string tenant = PowerShellValues.ConvertToText(RuleValues.GetValue(rule, "TenantName"));
                    effective[tenant] = BuildRule(tenant, RuleValues.GetValue(rule, "Direction"));
                }

                foreach (IDictionary rule in PowerShellValues.ListDictionaries(included))
                {
                    string tenant = ResolveTenant(rule, tenantIds);
                    effective[tenant] = BuildRule(tenant, RuleValues.GetValue(rule, "Direction"));
                }

                foreach (IDictionary rule in PowerShellValues.ListDictionaries(excluded))
                {
                    effective.Remove(ResolveTenant(rule, tenantIds));
                }

                object[] values = [.. effective.Values.Cast<object>()];
                RuleValues.SetValue(context.Desired, "Rules", values);
                RuleValues.SetValue(context.ValuesToCheck, "Rules", values);
            }

            foreach (Hashtable side in new[] { context.Desired, context.Current, context.ValuesToCheck })
            {
                foreach (string property in DeltaProperties)
                {
                    RuleValues.RemoveValue(side, property);
                }
            }
        }

        private static Hashtable BuildRule(string tenant, object? direction) =>
            new(StringComparer.OrdinalIgnoreCase) { ["TenantName"] = tenant, ["Direction"] = direction };

        private static string ResolveTenant(IDictionary rule, Dictionary<string, string> tenantIds)
        {
            string tenant = PowerShellValues.ConvertToText(RuleValues.GetValue(rule, "TenantName"));
            return tenantIds.TryGetValue(tenant, out string? id) ? id : tenant;
        }

        private static Dictionary<string, string> ReadTenantIds(object declaration)
        {
            Dictionary<string, string> tenantIds = new(StringComparer.OrdinalIgnoreCase);
            switch (MemberAccessor.TryGetMember(declaration, "TenantIds", out object? map) ? map : null)
            {
                case IDictionary dictionary:
                    foreach (DictionaryEntry entry in dictionary)
                    {
                        tenantIds[PowerShellValues.ConvertToText(entry.Key)] = PowerShellValues.ConvertToText(entry.Value);
                    }

                    break;
                case PSObject wrapped:
                    foreach (PSPropertyInfo property in wrapped.Properties)
                    {
                        tenantIds[property.Name] = PowerShellValues.ConvertToText(property.Value);
                    }

                    break;
            }

            return tenantIds;
        }
    }
}
