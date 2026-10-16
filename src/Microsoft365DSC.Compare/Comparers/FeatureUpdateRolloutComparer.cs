using System;
using System.Collections;

namespace Microsoft365DSC.Compare.Comparers
{
    internal static class FeatureUpdateRolloutComparer
    {
        private const string Property = "RolloutSettings";

        public static void Compare(CompareRuleContext context)
        {
            if (IsRolloutMatching(RuleValues.GetValue(context.Desired, Property), RuleValues.GetValue(context.Current, Property), context.Now))
            {
                RuleValues.RemoveValue(context.ValuesToCheck, Property);
                return;
            }

            Hashtable drifted = new(StringComparer.OrdinalIgnoreCase) { ["Drift"] = "desired" };
            RuleValues.SetValue(context.Desired, Property, drifted);
            RuleValues.SetValue(context.Current, Property, new Hashtable(StringComparer.OrdinalIgnoreCase) { ["Drift"] = "current" });
            RuleValues.SetValue(context.ValuesToCheck, Property, drifted);
        }

        // A start date in the past and an end date in the past or before the start may differ from the current ones.
        private static bool IsRolloutMatching(object? desired, object? current, DateTimeOffset now)
        {
            if (desired is null || current is null)
            {
                return desired is null && current is null;
            }

            DateTimeOffset? start = ReadDate(desired, "OfferStartDateTimeInUTC");
            DateTimeOffset? end = ReadDate(desired, "OfferEndDateTimeInUTC");
            DateTimeOffset? currentStart = ReadDate(current, "OfferStartDateTimeInUTC");
            DateTimeOffset? currentEnd = ReadDate(current, "OfferEndDateTimeInUTC");

            if (end.HasValue != currentEnd.HasValue)
            {
                return false;
            }

            if (start is null || currentStart is null)
            {
                return true;
            }

            if (start != currentStart && start > now)
            {
                return false;
            }

            if (end is null || currentEnd is null)
            {
                return true;
            }

            if (end != currentEnd && end > now && end > start)
            {
                return false;
            }

            return PowerShellValues.IsEqual(PowerShellValues.ReadMember(desired, "OfferIntervalInDays"), PowerShellValues.ReadMember(current, "OfferIntervalInDays"));
        }

        private static DateTimeOffset? ReadDate(object settings, string member) =>
            RuleValues.TryReadInstant(PowerShellValues.ReadMember(settings, member), out DateTimeOffset instant) ? instant : null;
    }
}
