using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace Microsoft365DSC.Utilities
{
    public static class Utilities
    {
        /// <summary>
        /// The property names every resource carries for authentication. Callers build their own
        /// set from these so each keeps its own string comparer.
        /// </summary>
        public static IReadOnlyList<string> AuthenticationPropertyNames { get; } =
        [
            "Credential", "ApplicationId", "ApplicationSecret", "TenantId", "CertificateThumbprint",
            "CertificatePath", "CertificatePassword", "ManagedIdentity", "AccessTokens"
        ];

        private static readonly HashSet<string> AuthenticationPropertySet =
            new(AuthenticationPropertyNames, StringComparer.OrdinalIgnoreCase);

        public static bool IsAuthenticationProperty(string name)
        {
            return AuthenticationPropertySet.Contains(name);
        }

        public static string NormalizeLineEndings(string text)
        {
            return text.IndexOf('\r') < 0 ? text : text.Replace("\r\n", "\n");
        }

        /// <summary>
        /// The characters that cannot appear in a DSC instance name without escaping. The
        /// smart quotes are listed by code point because this file is written in ASCII.
        /// </summary>
        private static readonly char[] UnsupportedInstanceNameCharacters =
        [
            '<', '>', ':', '"', '/', '\\', '|', '?', '*', '\'', '[', ']', '(', ')', '`', '$', ' ',
            (char)0x2019, (char)0x201C, (char)0x201D, (char)0x201E, (char)0x201F
        ];

        /// <summary>
        /// Replaces every character that would need escaping inside a DSC instance name with
        /// an underscore.
        /// </summary>
        /// <param name="input">The value to turn into an instance name segment.</param>
        /// <returns>A value that renders the same wherever it is written.</returns>
        public static string RemoveSpecialCharacters(string input)
        {
            if (string.IsNullOrEmpty(input) || input.IndexOfAny(UnsupportedInstanceNameCharacters) < 0)
            {
                return input;
            }

            char[] characters = input.ToCharArray();
            for (int i = 0; i < characters.Length; i++)
            {
                if (Array.IndexOf(UnsupportedInstanceNameCharacters, characters[i]) >= 0)
                {
                    characters[i] = '_';
                }
            }

            return new string(characters);
        }

        /// <summary>
        /// Method to update special characters in strings.
        /// This method handles the conversion of special characters similar to Update-M365DSCSpecialCharacters.
        /// This function updates special characters in a string to be escaped in a DSC configuration.
        /// The function replaces the following characters:
        ///     - 0x201C = “
        ///     - 0x201D = ”
        ///     - 0x201E = „
        /// </summary>
        /// <param name="input">The input string to process</param>
        /// <returns>The processed string with special characters updated</returns>
        public static string UpdateSpecialCharacters(string input)
        {
            input = input.Replace(((char)0x201C).ToString(), "`" + ((char)0x201C).ToString());
            input = input.Replace(((char)0x201D).ToString(), "`" + ((char)0x201D).ToString());
            input = input.Replace(((char)0x201E).ToString(), "`" + ((char)0x201E).ToString());
            return input;
        }

        public static List<Hashtable> FilterHashtablesByResourceAndKey(IEnumerable<object> hashtables, string resourceName, string key, string? keyValue)
        {
            List<Hashtable> results = [];
            foreach (Hashtable entry in hashtables.Cast<Hashtable>())
            {
                if (entry["ResourceName"]?.ToString() == resourceName &&
                    entry[key]?.ToString() == keyValue)
                {
                    results.Add(entry);
                }
            }
            return results;
        }

        public static Array UnwrapArray(Array array)
        {
            object[] unwrapped = new object[array.Length];
            for (int i = 0; i < array.Length; i++)
            {
                object? item = array.GetValue(i);
                unwrapped[i] = item is PSObject psObject ? psObject.BaseObject : item;
            }
            return unwrapped;
        }

        public static List<string> UnwrapArrayToStrings(Array array)
        {
            List<string> results = [];
            foreach (object item in array)
            {
                object? innerItem = item;
                if (item is PSObject psObject)
                    innerItem = psObject.BaseObject;

                if (innerItem is string str)
                    results.Add(str);
                else
                    results.Add(innerItem.ToString());
            }
            return results;
        }
    }
}
