using System;
using System.Collections;
using System.Collections.Generic;

namespace Microsoft365DSC.Compare
{
    /// <summary>
    /// Decides which properties identify one instance of a resource, so two configurations can be
    /// paired instance by instance before their values are compared.
    /// </summary>
    public static class ResourceKeyResolver
    {
        private static readonly string[] DisplayNameResources =
        [
            "AADGroup", "IntuneDeviceEnrollmentPlatformRestriction", "TeamsChannel", "TeamsTeam"
        ];

        /// <summary>
        /// Resolves the key property names for a parsed resource instance.
        /// </summary>
        /// <param name="resource">
        /// A parsed resource, including its ResourceName. Its shape decides branches the schema
        /// alone cannot, such as whether an AADGroup carries a MailNickname.
        /// </param>
        /// <param name="schema">The deserialized SchemaDefinition.json.</param>
        /// <returns>The key property names, or an empty array when the resource declares none.</returns>
        public static string[] Resolve(Hashtable resource, IEnumerable<object> schema)
        {
            return Resolve(resource, SchemaIndex.For(schema), new Dictionary<string, string[]>(StringComparer.OrdinalIgnoreCase));
        }

        internal static string[] Resolve(Hashtable resource, SchemaIndex schema, Dictionary<string, string[]> keysByResource)
        {
            string? resourceName = resource["ResourceName"]?.ToString();
            if (string.IsNullOrEmpty(resourceName))
            {
                return [];
            }

            if (!keysByResource.TryGetValue(resourceName!, out string[] keys))
            {
                keys = ResolveUncached(resource, resourceName!, schema);
                keysByResource[resourceName!] = keys;
            }

            return keys;
        }

        private static string[] ResolveUncached(Hashtable resource, string resourceName, SchemaIndex schema)
        {
            MandatoryParameters mandatory = schema.GetMandatory(resourceName);

            if (Has(resource, "IsSingleInstance") && mandatory.Contains("IsSingleInstance"))
            {
                return ["IsSingleInstance"];
            }

            if (Has(resource, "DisplayName") && mandatory.Contains("DisplayName") &&
                Array.IndexOf(DisplayNameResources, resourceName) > -1)
            {
                return ResolveDisplayNameResource(resource, resourceName);
            }

            if (Has(resource, "Identity") && mandatory.Contains("Identity"))
            {
                return ["Identity"];
            }

            if (Has(resource, "Name") && mandatory.Contains("Name"))
            {
                return ["Name"];
            }

            if (Has(resource, "Url") && mandatory.Contains("Url"))
            {
                return ["Url"];
            }

            if (Has(resource, "Organization") && mandatory.Contains("Organization"))
            {
                return ["Organization"];
            }

            if (Has(resource, "CDNType") && mandatory.Contains("CDNType"))
            {
                return ["CDNType"];
            }

            if (Has(resource, "Action") && resourceName == "SCComplianceSearchAction" && mandatory.Contains("Action"))
            {
                return ["SearchName", "Action"];
            }

            if (Has(resource, "Workload") && resourceName == "SCAuditConfigurationPolicy" && mandatory.Contains("Workload"))
            {
                return ["Workload"];
            }

            if (Has(resource, "Title") && resourceName == "SPOSiteDesign" && mandatory.Contains("Title"))
            {
                return ["Title"];
            }

            if (Has(resource, "SiteDesignTitle") && mandatory.Contains("SiteDesignTitle"))
            {
                return ["SiteDesignTitle"];
            }

            if (Has(resource, "Key") && resourceName == "SPOStorageEntity" && mandatory.Contains("Key"))
            {
                return ["Key"];
            }

            if (Has(resource, "Usage") && mandatory.Contains("Usage"))
            {
                return ["Usage"];
            }

            if (Has(resource, "OrgWideAccount") && mandatory.Contains("OrgWideAccount"))
            {
                return ["OrgWideAccount"];
            }

            if (mandatory.Count == 0)
            {
                return [];
            }

            if (resourceName == "EXOTenantAllowBlockListItems")
            {
                List<string> names = [];
                foreach (string name in mandatory.Names)
                {
                    if (!string.Equals(name, "Action", StringComparison.OrdinalIgnoreCase))
                    {
                        names.Add(name);
                    }
                }

                return [.. names];
            }

            return [.. mandatory.Names];
        }

        private static string[] ResolveDisplayNameResource(Hashtable resource, string resourceName)
        {
            switch (resourceName)
            {
                case "AADGroup" when HasValue(resource, "MailNickname"):
                    return ["DisplayName", "MailNickname"];

                case "IntuneDeviceEnrollmentPlatformRestriction" when HasKeyLike(resource, "Restriction"):
                    return ["ResourceInstanceName"];

                case "TeamsChannel" when HasValue(resource, "TeamName"):
                    return ["TeamName", "DisplayName"];

                case "TeamsTeam" when HasValue(resource, "MailNickName"):
                    return ["MailNickName", "DisplayName"];

                default:
                    return ["DisplayName"];
            }
        }

        private static bool Has(Hashtable resource, string name) => resource.ContainsKey(name);

        private static bool HasValue(Hashtable resource, string name) =>
            resource.ContainsKey(name) && !string.IsNullOrEmpty(resource[name]?.ToString());

        private static bool HasKeyLike(Hashtable resource, string suffix)
        {
            foreach (object key in resource.Keys)
            {
                if (key?.ToString()?.EndsWith(suffix, StringComparison.OrdinalIgnoreCase) == true)
                {
                    return true;
                }
            }

            return false;
        }
    }
}
