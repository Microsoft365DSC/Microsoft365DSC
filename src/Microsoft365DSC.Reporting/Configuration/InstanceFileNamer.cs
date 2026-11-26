using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace Microsoft365DSC.Reporting.Configuration
{
    internal sealed class InstanceFileNamer
    {
        private const string Extension = ".md";

        private static readonly KeyValuePair<string, string>[] AreaPrefixes =
        [
            new("AAD", "AzureAD"),
            new("ADO", "AzureDevOps"),
            new("Azure", "Azure"),
            new("Commerce", "Commerce"),
            new("Defender", "Defender"),
            new("EXO", "Exchange"),
            new("Fabric", "Fabric"),
            new("Intune", "Intune"),
            new("M365DSC", "General"),
            new("O365", "Office365"),
            new("OD", "OneDrive"),
            new("Planner", "Planner"),
            new("PP", "PowerPlatform"),
            new("SC", "SecurityCompliance"),
            new("Sentinel", "Sentinel"),
            new("SH", "ServicesHub"),
            new("SPO", "Sharepoint"),
            new("Teams", "Teams"),
            new("Viva", "Viva")
        ];

        private static readonly char[] InvalidCharacters =
        [
            '<', '>', ':', '"', '/', '\\', '|', '?', '*', ' ', '[', ']', '(', ')',
            '“', '”', '„', '‟'
        ];

        private readonly HashSet<string> _reservedPaths = new(StringComparer.OrdinalIgnoreCase);

        public static IEnumerable<string> Areas => AreaPrefixes.Select(area => area.Value).Distinct();

        public static string? ResolveArea(string resourceType)
        {
            foreach (KeyValuePair<string, string> area in AreaPrefixes)
            {
                if (resourceType.StartsWith(area.Key, StringComparison.Ordinal))
                {
                    return area.Value;
                }
            }

            return null;
        }

        public static string Sanitize(string instanceName)
        {
            char[] characters = instanceName.ToCharArray();
            for (int index = 0; index < characters.Length; index++)
            {
                if (Array.IndexOf(InvalidCharacters, characters[index]) >= 0)
                {
                    characters[index] = '_';
                }
            }

            return new string(characters);
        }

        public string ReservePath(string areaFolder, string sanitizedName)
        {
            string path = Path.Combine(areaFolder, sanitizedName + Extension);
            for (int suffix = 2; !_reservedPaths.Add(path); suffix++)
            {
                path = Path.Combine(areaFolder, $"{sanitizedName}-{suffix}{Extension}");
            }

            return path;
        }
    }
}
