using Microsoft365DSC.Utilities;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;

namespace Microsoft365DSC.Compare.Comparers
{
    /// <summary>
    /// Values are read and compared with PowerShell semantics.
    /// </summary>
    internal static class PowerShellValues
    {
        // Member access on a collection returns the members of its elements, collections among them flattened one level.
        public static object? ReadMember(object? owner, string name)
        {
            switch (MemberAccessor.Unwrap(owner))
            {
                case null:
                case string:
                    return null;
                case IDictionary dictionary:
                    return RuleValues.GetValue(dictionary, name);
                case IEnumerable items:
                    List<object?> values = [];
                    foreach (object? value in items.Cast<object?>().Select(item => ReadMember(item, name)).Where(value => value is not null))
                    {
                        values.AddRange(RuleValues.ListItems(value));
                    }

                    return values.Count switch
                    {
                        0 => null,
                        1 => values[0],
                        _ => values.ToArray()
                    };
                default:
                    return MemberAccessor.TryGetMember(owner, name, out object? member) ? member : null;
            }
        }

        public static IReadOnlyList<IDictionary> ListDictionaries(object? value) =>
            [.. RuleValues.ListItems(value).Select(MemberAccessor.Unwrap).OfType<IDictionary>()];

        // A [System.String] cast joins collection items with a space.
        public static string ConvertToText(object? value) =>
            MemberAccessor.Unwrap(value) switch
            {
                null => string.Empty,
                string text => text,
                bool flag => flag ? "True" : "False",
                IDictionary dictionary => dictionary.GetType().FullName,
                IEnumerable items => string.Join(" ", items.Cast<object?>().Select(ConvertToText)),
                IFormattable formattable => formattable.ToString(null, CultureInfo.InvariantCulture),
                var other => other.ToString()
            };

        public static bool IsEqual(string left, string right) => string.Equals(left, right, StringComparison.OrdinalIgnoreCase);

        public static bool IsEqual(object? left, object? right) => IsEqual(ConvertToText(left), ConvertToText(right));

        public static Dictionary<string, IDictionary> BuildMemberIndex(object? items, string memberName)
        {
            Dictionary<string, IDictionary> index = new(StringComparer.OrdinalIgnoreCase);
            foreach (IDictionary item in ListDictionaries(items))
            {
                string key = ConvertToText(RuleValues.GetValue(item, memberName));
                if (!index.ContainsKey(key))
                {
                    index[key] = item;
                }
            }

            return index;
        }

        public static bool IsTextListEqualIgnoringOrder(object? desired, object? current)
        {
            List<string> desiredTexts = ListTexts(desired);
            List<string> currentTexts = ListTexts(current);
            if (desiredTexts.Count != currentTexts.Count)
            {
                return false;
            }

            desiredTexts.Sort(StringComparer.OrdinalIgnoreCase);
            currentTexts.Sort(StringComparer.OrdinalIgnoreCase);
            return desiredTexts.Zip(currentTexts, IsEqual).All(isEqual => isEqual);
        }

        private static List<string> ListTexts(object? value) =>
            [.. RuleValues.ListItems(value).Select(ConvertToText).Where(text => text.Length > 0)];
    }
}
