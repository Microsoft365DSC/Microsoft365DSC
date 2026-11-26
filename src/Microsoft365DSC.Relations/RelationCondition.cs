using Microsoft365DSC.Utilities;
using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Text.RegularExpressions;

namespace Microsoft365DSC.Relations
{
    /// <summary>
    /// A predicate applied to a single item before it is treated as a relation target.
    /// Conditions are parsed once, when the index is built, rather than re-parsed per item.
    /// </summary>
    public interface IRelationCondition
    {
        /// <summary>
        /// Evaluates the condition against one item.
        /// </summary>
        /// <param name="item">The item to test. May be a hashtable, PSObject or CimInstance.</param>
        /// <returns>True when the item satisfies the condition.</returns>
        bool Evaluate(object? item);
    }

    /// <summary>
    /// Base for conditions that test a single value drawn from the item.
    /// </summary>
    /// <remarks>
    /// The subject is either a property name or <c>$_</c>, which means the item itself. The
    /// latter is what lets a condition discriminate between the entries of a plain string
    /// array, where there is no property to read.
    /// </remarks>
    internal abstract class SubjectCondition : IRelationCondition
    {
        /// <summary>The token that refers to the item itself rather than one of its properties.</summary>
        internal const string SelfSubject = "$_";

        private readonly string _subject;

        private protected SubjectCondition(string subject)
        {
            _subject = subject;
        }

        /// <inheritdoc />
        public bool Evaluate(object? item)
        {
            string? value = ResolveSubject(item);
            return value is not null && Test(value);
        }

        /// <summary>
        /// Tests the resolved subject value.
        /// </summary>
        /// <param name="value">The value read from the item.</param>
        /// <returns>True when the condition holds.</returns>
        private protected abstract bool Test(string value);

        /// <summary>
        /// Reads the value this condition applies to.
        /// </summary>
        /// <param name="item">The item under test.</param>
        /// <returns>The value, or null when it is absent or empty.</returns>
        private string? ResolveSubject(object? item)
        {
            if (!string.Equals(_subject, SelfSubject, StringComparison.Ordinal))
            {
                return MemberAccessor.GetMemberAsString(item, _subject);
            }

            object? unwrapped = MemberAccessor.Unwrap(item);
            if (unwrapped is null)
            {
                return null;
            }

            string text = unwrapped.ToString();
            return string.IsNullOrEmpty(text) ? null : text;
        }
    }

    /// <summary>
    /// Matches when the subject equals one of a set of values, case-insensitively.
    /// Source syntax: <c>propertyName in ['value1', 'value2']</c>.
    /// </summary>
    internal sealed class InCondition : SubjectCondition
    {
        private readonly HashSet<string> _allowedValues;

        internal InCondition(string subject, IEnumerable<string> allowedValues)
            : base(subject)
        {
            _allowedValues = new HashSet<string>(allowedValues, StringComparer.OrdinalIgnoreCase);
        }

        private protected override bool Test(string value) => _allowedValues.Contains(value);
    }

    /// <summary>
    /// Matches when the subject equals a single value, case-insensitively.
    /// Source syntax: <c>propertyName eq 'value'</c>.
    /// </summary>
    internal sealed class EqualsCondition : SubjectCondition
    {
        private readonly string _expectedValue;

        internal EqualsCondition(string subject, string expectedValue)
            : base(subject)
        {
            _expectedValue = expectedValue;
        }

        private protected override bool Test(string value) =>
            string.Equals(value, _expectedValue, StringComparison.OrdinalIgnoreCase);
    }

    /// <summary>
    /// Matches the subject against a wildcard pattern, case-insensitively.
    /// Source syntax: <c>$_ like '*@*'</c> or <c>$_ notlike '*@*'</c>.
    /// </summary>
    /// <remarks>
    /// Wildcards follow PowerShell's own rules, so a template can be written the way the rest
    /// of the module would express the same test.
    /// </remarks>
    internal sealed class LikeCondition : SubjectCondition
    {
        private readonly WildcardPattern _pattern;
        private readonly bool _negate;

        internal LikeCondition(string subject, string pattern, bool negate)
            : base(subject)
        {
            _pattern = new WildcardPattern(pattern, WildcardOptions.IgnoreCase | WildcardOptions.CultureInvariant);
            _negate = negate;
        }

        private protected override bool Test(string value) => _pattern.IsMatch(value) != _negate;
    }

    /// <summary>
    /// Parses the small condition grammar used by the relation templates.
    /// </summary>
    /// <remarks>
    /// Unrecognized syntax throws. The previous PowerShell implementation defaulted to
    /// "matches everything" on a syntax it did not understand, which silently turned every
    /// <c>eq</c> condition into a no-op and registered administrative unit members against
    /// every candidate target type at once.
    /// </remarks>
    public static class ConditionParser
    {
        // The subject is either a property path or $_, meaning the item itself.
        private const string Subject = @"(?<subject>\$_|[\w\.]+)";

        private static readonly Regex InPattern = new(
            @"^\s*" + Subject + @"\s+in\s+\[(?<values>.*)\]\s*$",
            RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);

        private static readonly Regex EqualsPattern = new(
            @"^\s*" + Subject + @"\s+eq\s+(?<value>.+?)\s*$",
            RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);

        private static readonly Regex LikePattern = new(
            @"^\s*" + Subject + @"\s+(?<operator>notlike|like)\s+(?<value>.+?)\s*$",
            RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);

        /// <summary>
        /// Parses a condition expression.
        /// </summary>
        /// <param name="condition">The expression, or null/empty for no condition.</param>
        /// <returns>The parsed condition, or null when there is nothing to apply.</returns>
        /// <exception cref="FormatException">The expression uses an unsupported syntax.</exception>
        public static IRelationCondition? Parse(string? condition)
        {
            if (string.IsNullOrWhiteSpace(condition))
            {
                return null;
            }

            Match inMatch = InPattern.Match(condition);
            if (inMatch.Success)
            {
                return new InCondition(
                    inMatch.Groups["subject"].Value,
                    SplitValueList(inMatch.Groups["values"].Value));
            }

            Match equalsMatch = EqualsPattern.Match(condition);
            if (equalsMatch.Success)
            {
                return new EqualsCondition(
                    equalsMatch.Groups["subject"].Value,
                    TrimQuotes(equalsMatch.Groups["value"].Value));
            }

            Match likeMatch = LikePattern.Match(condition);
            if (likeMatch.Success)
            {
                return new LikeCondition(
                    likeMatch.Groups["subject"].Value,
                    TrimQuotes(likeMatch.Groups["value"].Value),
                    string.Equals(likeMatch.Groups["operator"].Value, "notlike", StringComparison.OrdinalIgnoreCase));
            }

            throw new FormatException(
                $"Unsupported relation condition syntax: '{condition}'. Supported forms are " +
                "\"<subject> in ['a', 'b']\", \"<subject> eq 'value'\", \"<subject> like 'pattern'\" and " +
                "\"<subject> notlike 'pattern'\", where <subject> is a property name or $_ for the item itself.");
        }

        /// <summary>
        /// Splits the comma-separated body of an <c>in</c> list into its individual values.
        /// </summary>
        /// <param name="values">The text between the brackets.</param>
        /// <returns>The unquoted values, empty entries removed.</returns>
        private static List<string> SplitValueList(string values)
        {
            List<string> result = [];
            foreach (string part in values.Split(','))
            {
                string value = TrimQuotes(part);
                if (value.Length > 0)
                {
                    result.Add(value);
                }
            }

            return result;
        }

        /// <summary>
        /// Removes surrounding whitespace and a single layer of single or double quotes.
        /// </summary>
        /// <param name="value">The raw token.</param>
        /// <returns>The bare value.</returns>
        private static string TrimQuotes(string value)
        {
            return value.Trim().Trim('\'', '"').Trim();
        }
    }
}
