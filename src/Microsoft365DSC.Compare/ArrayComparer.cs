using System;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft365DSC.Compare
{
    internal static class ArrayComparer
    {
        public static List<CompareObjectModel> CompareArrays(Array currentArray, Array desiredArray)
        {
            List<CompareObjectModel> compareResults = [];

            if (currentArray is null || desiredArray is null)
            {
                throw new ArgumentException("Both currentValue and desiredValue must be of type Array and cannot be null.");
            }

            object[] currentObjects = (object[])Utilities.Utilities.UnwrapArray(currentArray);
            object[] desiredObjects = (object[])Utilities.Utilities.UnwrapArray(desiredArray);

            if (currentObjects.Length == 0 && desiredObjects.Length == 0)
            {
                return compareResults;
            }

            HashSet<string> currentKeys = ToKeySet(currentObjects);
            HashSet<string> desiredKeys = ToKeySet(desiredObjects);

            // Find items in desired but not in current
            foreach (object item in desiredObjects)
            {
                if (!currentKeys.Contains(ToKey(item)))
                {
                    compareResults.Add(new CompareObjectModel
                    {
                        SideIndicator = "<=",
                        InputObject = item
                    });
                }
            }

            // Find items in current but not in desired
            foreach (object item in currentObjects)
            {
                if (!desiredKeys.Contains(ToKey(item)))
                {
                    compareResults.Add(new CompareObjectModel
                    {
                        SideIndicator = "=>",
                        InputObject = item
                    });
                }
            }

            return compareResults;
        }

        public static string FormatValues(Array values)
        {
            return string.Join(", ", Utilities.Utilities.UnwrapArrayToStrings(values));
        }

        public static string FormatDelta(List<CompareObjectModel> differences)
        {
            return string.Join("; ", differences.Select(difference => $"{difference.SideIndicator} {difference.InputObject}"));
        }

        private static HashSet<string> ToKeySet(object[] items)
        {
            HashSet<string> keys = new(StringComparer.OrdinalIgnoreCase);
            foreach (object item in items)
            {
                _ = keys.Add(ToKey(item));
            }
            return keys;
        }

        private static string ToKey(object item)
        {
            return item?.ToString() ?? string.Empty;
        }
    }
}
