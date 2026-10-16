using Microsoft365DSC.Compare.Comparers;
using Microsoft365DSC.Converter;
using Microsoft365DSC.Utilities;
using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using System.Xml;

namespace Microsoft365DSC.Compare
{
    /// <summary>
    /// Shared by every rule of one paired instance.
    /// </summary>
    public sealed class CompareRuleContext
    {
        private readonly Action<string>? _log;

        internal CompareRuleContext(
            Hashtable desired,
            Hashtable current,
            Hashtable valuesToCheck,
            IReadOnlyList<string> schemaPropertyNames,
            DateTimeOffset now,
            Action<string>? log)
        {
            Desired = desired;
            Current = current;
            ValuesToCheck = valuesToCheck;
            SchemaPropertyNames = schemaPropertyNames;
            Now = now;
            _log = log;
        }

        /// <summary>
        /// A copy of the destination instance.
        /// </summary>
        public Hashtable Desired { get; }

        /// <summary>
        /// A copy of the source instance.
        /// </summary>
        public Hashtable Current { get; }

        /// <summary>
        /// Only the keys count.
        /// </summary>
        public Hashtable ValuesToCheck { get; }

        /// <summary>
        /// Empty when the schema does not declare the resource.
        /// </summary>
        public IReadOnlyList<string> SchemaPropertyNames { get; }

        /// <summary>
        /// ResourceCompareParameters.Now, or the system clock when that is null.
        /// </summary>
        public DateTimeOffset Now { get; }

        /// <summary>
        /// Logs a message indicating drift, if a log action was provided.
        /// </summary>
        public void LogDrift(string message)
        {
            _log?.Invoke(message);
        }

        internal IEnumerable<Hashtable> ListSides(RuleSide side)
        {
            if (side != RuleSide.Current)
            {
                yield return Desired;
            }

            if (side != RuleSide.Desired)
            {
                yield return Current;
            }
        }

        internal Hashtable GetSide(RuleSide side) => side == RuleSide.Current ? Current : Desired;
    }

    /// <summary>
    /// Definition of a compare rule.
    /// </summary>
    public abstract class CompareRule
    {
        private static readonly Dictionary<string, Func<object, CompareRule>> Factories = new(StringComparer.OrdinalIgnoreCase)
        {
            ["CheckAllSchemaProperties"] = _ => new CheckAllSchemaPropertiesRule(),
            ["RemoveWhen"] = RemoveWhenRule.From,
            ["CheckWhen"] = CheckWhenRule.From,
            ["SetWhen"] = SetWhenRule.From,
            ["Normalize"] = NormalizeRule.From,
            ["Equivalent"] = EquivalentRule.From,
            ["NullEqualsEmpty"] = NullEqualsEmptyRule.From,
            ["Tolerance"] = ToleranceRule.From,
            ["IgnoreNested"] = IgnoreNestedRule.From,
            ["IgnoreWhenPast"] = IgnoreWhenPastRule.From,
            ["SameInstant"] = SameInstantRule.From,
            ["Rename"] = RenameRule.From,
            ["DurationMatchesEnd"] = DurationMatchesEndRule.From,
            ["AllowCurrentExtras"] = AllowCurrentExtrasRule.From,
            ["CustomCompare"] = CustomCompareRule.From
        };

        private protected CompareRule()
        {
        }

        /// <summary>
        /// Parses a collection of rule declarations into a list of compare rules.
        /// </summary>
        /// <exception cref="ArgumentException">Thrown when an entry has an unknown rule type or misses a required member.</exception>
        public static List<CompareRule> ParseAll(object? declarations)
        {
            return [.. SchemaIndex.AsSequence(declarations).Where(entry => entry is not null).Select(Parse)];
        }

        /// <summary>
        /// Applies all the specified compare rules to the given hashtables and returns the potentially modified versions.
        /// </summary>
        public static Tuple<Hashtable, Hashtable, Hashtable> ApplyAll(
            IReadOnlyList<CompareRule> rules,
            Hashtable desired,
            Hashtable current,
            Hashtable valuesToCheck,
            IEnumerable<object> schema,
            string resourceName,
            Action<string>? log = null)
        {
            (Hashtable rewrittenDesired, Hashtable rewrittenCurrent, Hashtable rewrittenValuesToCheck) = ApplyAll(
                rules, desired, current, valuesToCheck, SchemaIndex.For(schema).GetParameterNames(resourceName), DateTimeOffset.Now, log);

            return Tuple.Create(rewrittenDesired, rewrittenCurrent, rewrittenValuesToCheck);
        }

        internal static (Hashtable Desired, Hashtable Current, Hashtable ValuesToCheck) ApplyAll(
            IReadOnlyList<CompareRule> rules,
            Hashtable desired,
            Hashtable current,
            Hashtable valuesToCheck,
            IReadOnlyList<string> schemaPropertyNames,
            DateTimeOffset now,
            Action<string>? log)
        {
            CompareRuleContext context = new(
                CompareValues.CloneWithNestedValues(desired),
                CompareValues.CloneWithNestedValues(current),
                (Hashtable)valuesToCheck.Clone(),
                schemaPropertyNames,
                now,
                log);

            foreach (CompareRule rule in rules)
            {
                rule.Apply(context);
            }

            return (context.Desired, context.Current, context.ValuesToCheck);
        }

        internal abstract void Apply(CompareRuleContext context);

        private static CompareRule Parse(object declaration)
        {
            string? type = MemberAccessor.GetMemberAsString(declaration, "Type");
            if (string.IsNullOrEmpty(type) || !Factories.TryGetValue(type!, out Func<object, CompareRule>? factory))
            {
                throw new ArgumentException($"Unknown compare rule type '{type}'.", nameof(declaration));
            }

            return factory(declaration);
        }
    }

    /// <summary>
    /// Registry for compare rules and normalizers.
    /// </summary>
    public static class CompareRuleRegistry
    {
        private static readonly ConcurrentDictionary<string, Func<object, Action<CompareRuleContext>>> ComparerFactories = new(StringComparer.OrdinalIgnoreCase)
        {
            ["SCLabelPolicy"] = _ => SCLabelPolicyComparer.Compare,
            ["SCSensitivityLabel"] = _ => SCSensitivityLabelComparer.Compare,
            ["SCAutoSensitivityLabelRule"] = _ => SensitiveInformationComparer.CompareAutoSensitivityLabelRule,
            ["SCDLPComplianceRule"] = _ => SensitiveInformationComparer.CompareDlpComplianceRule,
            ["FeatureUpdateRollout"] = _ => FeatureUpdateRolloutComparer.Compare,
            ["TenantIsolationRules"] = TenantIsolationRulesComparer.Create
        };

        private static readonly ConcurrentDictionary<string, Func<object, Func<object?, object?>>> NormalizerFactories = new(StringComparer.OrdinalIgnoreCase)
        {
            ["StripNewlines"] = _ => value => value is string text ? text.Replace("\r", string.Empty).Replace("\n", string.Empty) : value,
            ["RegexReplace"] = CreateRegexReplace,
            ["PrefixUnless"] = CreatePrefixUnless,
            ["FormatDuration"] = _ => CompareNormalizers.FormatDuration,
            ["FormatDateTime"] = _ => CompareNormalizers.FormatDateTime,
            ["FormatTimeOfDay"] = _ => CompareNormalizers.FormatTimeOfDay,
            ["FormatSize"] = _ => CompareNormalizers.FormatSize,
            ["ReformatDateTime"] = CompareNormalizers.CreateDateTimeReformat,
            ["ExchangeFilter"] = _ => CompareNormalizers.FormatExchangeFilter
        };

        /// <summary>
        /// Registers a comparer under the same name. If a comparer with the same name already exists, it will be replaced.
        /// </summary>
        public static void RegisterComparer(string name, Func<object, Action<CompareRuleContext>> factory)
        {
            ComparerFactories[name] = factory ?? throw new ArgumentNullException(nameof(factory));
        }

        /// <summary>
        /// Registers a normalizer under the same name. If a normalizer with the same name already exists, it will be replaced.
        /// </summary>
        public static void RegisterNormalizer(string name, Func<object, Func<object?, object?>> factory)
        {
            NormalizerFactories[name] = factory ?? throw new ArgumentNullException(nameof(factory));
        }

        internal static Action<CompareRuleContext> CreateComparer(string name, object declaration) =>
            ComparerFactories.TryGetValue(name, out Func<object, Action<CompareRuleContext>>? factory)
                ? factory(declaration)
                : throw new ArgumentException($"Unknown comparer '{name}'.", nameof(name));

        internal static Func<object?, object?> CreateNormalizer(string name, object declaration) =>
            NormalizerFactories.TryGetValue(name, out Func<object, Func<object?, object?>>? factory)
                ? factory(declaration)
                : throw new ArgumentException($"Unknown normalizer '{name}'.", nameof(name));

        private static Func<object?, object?> CreateRegexReplace(object declaration)
        {
            Regex pattern = RuleValues.ReadRequiredPattern(declaration, "Pattern");
            string replacement = MemberAccessor.GetMemberAsString(declaration, "Replacement") ?? string.Empty;
            return value => value is string text ? pattern.Replace(text, replacement) : value;
        }

        private static Func<object?, object?> CreatePrefixUnless(object declaration)
        {
            Regex pattern = RuleValues.ReadRequiredPattern(declaration, "Pattern");
            string format = RuleValues.ReadRequiredString(declaration, "Format");
            try
            {
                _ = string.Format(CultureInfo.InvariantCulture, format, string.Empty);
            }
            catch (FormatException exception)
            {
                throw new ArgumentException($"The PrefixUnless format '{format}' is invalid.", nameof(declaration), exception);
            }

            return value => value is string text && !pattern.IsMatch(text) ? string.Format(CultureInfo.InvariantCulture, format, text) : value;
        }
    }

    internal enum RuleSide
    {
        Desired,
        Current,
        Both
    }

    internal sealed class CheckAllSchemaPropertiesRule : CompareRule
    {
        internal override void Apply(CompareRuleContext context)
        {
            foreach (string name in context.SchemaPropertyNames)
            {
                if (!RuleValues.IsNullOrEmptyCollection(RuleValues.GetValue(context.Current, name)) ||
                    !RuleValues.IsNullOrEmptyCollection(RuleValues.GetValue(context.Desired, name)))
                {
                    RuleValues.SetValue(context.ValuesToCheck, name, null);
                    if (!RuleValues.HasKey(context.Desired, name))
                    {
                        RuleValues.SetValue(context.Desired, name, null);
                    }
                }
            }
        }
    }

    internal sealed class RemoveWhenRule : CompareRule
    {
        private readonly IReadOnlyList<string> _properties;
        private readonly Regex? _propertyPattern;
        private readonly RuleCondition? _when;
        private readonly bool _isAlsoFromDesired;

        public RemoveWhenRule(IReadOnlyList<string> properties, Regex? propertyPattern, RuleCondition? when, bool isAlsoFromDesired)
        {
            _properties = properties;
            _propertyPattern = propertyPattern;
            _when = when;
            _isAlsoFromDesired = isAlsoFromDesired;
        }

        public static CompareRule From(object declaration) => new RemoveWhenRule(
            RuleValues.ReadStrings(declaration, "Properties"),
            RuleValues.ReadPattern(declaration, "PropertyPattern"),
            RuleCondition.ReadOptional(declaration, "When"),
            RuleValues.ReadBoolean(declaration, "AlsoFromDesired"));

        internal override void Apply(CompareRuleContext context)
        {
            if (_when?.IsMet(context) == false)
            {
                return;
            }

            List<string> removedProperties = [.. _properties];
            if (_propertyPattern is not null)
            {
                removedProperties.AddRange(RuleValues.ListKeys(context.ValuesToCheck).Where(key => _propertyPattern.IsMatch(key)));
                if (_isAlsoFromDesired)
                {
                    removedProperties.AddRange(RuleValues.ListKeys(context.Desired).Where(key => _propertyPattern.IsMatch(key)));
                }
            }

            foreach (string name in removedProperties.Distinct(StringComparer.OrdinalIgnoreCase).ToArray())
            {
                RuleValues.RemoveValue(context.ValuesToCheck, name);
                if (_isAlsoFromDesired)
                {
                    RuleValues.RemoveValue(context.Desired, name);
                }
            }
        }
    }

    internal sealed class CheckWhenRule : CompareRule
    {
        private readonly string _property;
        private readonly RuleCondition? _when;

        public CheckWhenRule(string property, RuleCondition? when)
        {
            _property = property;
            _when = when;
        }

        public static CompareRule From(object declaration) => new CheckWhenRule(
            RuleValues.ReadRequiredString(declaration, "Property"),
            RuleCondition.ReadOptional(declaration, "When"));

        internal override void Apply(CompareRuleContext context)
        {
            if (_when?.IsMet(context) == false || RuleValues.HasKey(context.ValuesToCheck, _property))
            {
                return;
            }

            RuleValues.SetValue(context.ValuesToCheck, _property, null);
            RuleValues.SetValue(context.Desired, _property, null);
        }
    }

    internal sealed class SetWhenRule : CompareRule
    {
        private readonly RuleSide _side;
        private readonly string _property;
        private readonly object? _value;
        private readonly RuleCondition? _when;

        public SetWhenRule(RuleSide side, string property, object? value, RuleCondition? when)
        {
            _side = side;
            _property = property;
            _value = value;
            _when = when;
        }

        public static CompareRule From(object declaration) => new SetWhenRule(
            RuleValues.ReadSide(declaration, "Side", RuleSide.Desired),
            RuleValues.ReadRequiredString(declaration, "Property"),
            RuleValues.ReadOption(declaration, "Value"),
            RuleCondition.ReadOptional(declaration, "When"));

        internal override void Apply(CompareRuleContext context)
        {
            if (_when?.IsMet(context) == false)
            {
                return;
            }

            foreach (Hashtable values in context.ListSides(_side))
            {
                RuleValues.SetValue(values, _property, _value);
            }
        }
    }

    internal sealed class NormalizeRule : CompareRule
    {
        private readonly IReadOnlyList<string> _paths;
        private readonly RuleSide _side;
        private readonly Func<object?, object?> _normalizer;

        public NormalizeRule(IReadOnlyList<string> paths, RuleSide side, Func<object?, object?> normalizer)
        {
            _paths = paths;
            _side = side;
            _normalizer = normalizer;
        }

        public static CompareRule From(object declaration) => new NormalizeRule(
            RuleValues.ReadStrings(declaration, "Paths"),
            RuleValues.ReadSide(declaration, "Side", RuleSide.Both),
            CompareRuleRegistry.CreateNormalizer(RuleValues.ReadRequiredString(declaration, "Using"), declaration));

        internal override void Apply(CompareRuleContext context)
        {
            foreach (Hashtable values in context.ListSides(_side))
            {
                foreach (RuleSlot slot in _paths.SelectMany(path => RuleValues.ResolveSlots(values, path)).Where(slot => slot.IsPresent))
                {
                    slot.Write(RuleValues.MapScalars(slot.Read(), _normalizer));
                }
            }
        }
    }

    internal sealed class EquivalentRule : CompareRule
    {
        private readonly string _property;
        private readonly IReadOnlyList<string> _values;

        public EquivalentRule(string property, IReadOnlyList<string> values)
        {
            _property = property;
            _values = values;
        }

        public static CompareRule From(object declaration) => new EquivalentRule(
            RuleValues.ReadRequiredString(declaration, "Property"),
            RuleValues.ReadStrings(declaration, "Values"));

        internal override void Apply(CompareRuleContext context)
        {
            object? current = RuleValues.GetValue(context.Current, _property);

            if (IsEquivalentValue(RuleValues.GetValue(context.Desired, _property)) && IsEquivalentValue(current))
            {
                RuleValues.SetValue(context.Desired, _property, current);
            }
        }

        private bool IsEquivalentValue(object? value) =>
            _values.Contains(RuleValues.ConvertToText(value) ?? string.Empty, StringComparer.OrdinalIgnoreCase);
    }

    internal sealed class NullEqualsEmptyRule : CompareRule
    {
        private readonly Regex _propertyPattern;
        private readonly RuleSide _side;

        public NullEqualsEmptyRule(Regex propertyPattern, RuleSide side)
        {
            _propertyPattern = propertyPattern;
            _side = side;
        }

        public static CompareRule From(object declaration) => new NullEqualsEmptyRule(
            RuleValues.ReadRequiredPattern(declaration, "PropertyPattern"),
            RuleValues.ReadSide(declaration, "Side", RuleSide.Current));

        internal override void Apply(CompareRuleContext context)
        {
            foreach (string name in RuleValues.ListKeys(context.ValuesToCheck).Where(key => _propertyPattern.IsMatch(key)).ToArray())
            {
                foreach (Hashtable values in context.ListSides(_side).Where(values => RuleValues.GetValue(values, name) is null))
                {
                    RuleValues.SetValue(values, name, Array.Empty<object>());
                }
            }
        }
    }

    internal sealed class ToleranceRule : CompareRule
    {
        private readonly IReadOnlyList<string> _properties;
        private readonly TimeSpan _within;

        public ToleranceRule(IReadOnlyList<string> properties, TimeSpan within)
        {
            _properties = properties;
            _within = within;
        }

        public static CompareRule From(object declaration) => new ToleranceRule(
            RuleValues.ReadStrings(declaration, "Properties"),
            TimeSpan.TryParse(RuleValues.ReadRequiredString(declaration, "Within"), CultureInfo.InvariantCulture, out TimeSpan within)
                ? within
                : throw new ArgumentException("The Tolerance rule needs a Within such as 00:05:00.", nameof(declaration)));

        internal override void Apply(CompareRuleContext context)
        {
            foreach (string name in _properties)
            {
                if (RuleValues.TryReadDuration(RuleValues.GetValue(context.Desired, name), out TimeSpan desired) &&
                    RuleValues.TryReadDuration(RuleValues.GetValue(context.Current, name), out TimeSpan current) &&
                    (desired - current).Duration() <= _within)
                {
                    RuleValues.RemoveValue(context.ValuesToCheck, name);
                }
            }
        }
    }

    internal sealed class IgnoreNestedRule : CompareRule
    {
        private readonly IReadOnlyList<string> _paths;

        public IgnoreNestedRule(IReadOnlyList<string> paths)
        {
            _paths = paths;
        }

        public static CompareRule From(object declaration) => new IgnoreNestedRule(RuleValues.ReadStrings(declaration, "Paths"));

        internal override void Apply(CompareRuleContext context)
        {
            foreach (Hashtable values in context.ListSides(RuleSide.Both))
            {
                foreach (RuleSlot slot in _paths.SelectMany(path => RuleValues.ResolveSlots(values, path)).ToArray())
                {
                    slot.Remove();
                }
            }
        }
    }

    internal abstract class InstantRule : CompareRule
    {
        private readonly string _path;

        protected InstantRule(string path)
        {
            _path = path;
        }

        internal override void Apply(CompareRuleContext context)
        {
            if (RuleValues.ResolveSlots(context.Desired, _path).FirstOrDefault() is not { IsPresent: true } desired ||
                RuleValues.ResolveSlots(context.Current, _path).FirstOrDefault() is not { IsPresent: true } current ||
                !RuleValues.TryReadInstant(desired.Read(), out DateTimeOffset desiredInstant) ||
                !RuleValues.TryReadInstant(current.Read(), out DateTimeOffset currentInstant))
            {
                return;
            }

            if (CanUseCurrentDate(desiredInstant, currentInstant, context.Now))
            {
                desired.Write(current.Read());
            }
        }

        protected abstract bool CanUseCurrentDate(DateTimeOffset desired, DateTimeOffset current, DateTimeOffset now);
    }

    internal sealed class IgnoreWhenPastRule : InstantRule
    {
        public IgnoreWhenPastRule(string path)
            : base(path)
        {
        }

        public static CompareRule From(object declaration) => new IgnoreWhenPastRule(RuleValues.ReadRequiredString(declaration, "Path"));

        protected override bool CanUseCurrentDate(DateTimeOffset desired, DateTimeOffset current, DateTimeOffset now) => desired != current && desired < now;
    }

    internal sealed class SameInstantRule : InstantRule
    {
        public SameInstantRule(string path)
            : base(path)
        {
        }

        public static CompareRule From(object declaration) => new SameInstantRule(RuleValues.ReadRequiredString(declaration, "Path"));

        protected override bool CanUseCurrentDate(DateTimeOffset desired, DateTimeOffset current, DateTimeOffset now) => desired == current;
    }

    internal sealed class RenameRule : CompareRule
    {
        private readonly string _from;
        private readonly string _to;

        public RenameRule(string from, string to)
        {
            _from = from;
            _to = to;
        }

        public static CompareRule From(object declaration) => new RenameRule(
            RuleValues.ReadRequiredString(declaration, "From"),
            RuleValues.ReadRequiredString(declaration, "To"));

        internal override void Apply(CompareRuleContext context)
        {
            foreach (Hashtable values in new[] { context.Desired, context.Current, context.ValuesToCheck }.Where(values => RuleValues.HasKey(values, _from)))
            {
                object? value = RuleValues.GetValue(values, _from);
                RuleValues.RemoveValue(values, _from);
                RuleValues.SetValue(values, _to, value);
            }
        }
    }

    internal sealed class DurationMatchesEndRule : CompareRule
    {
        private readonly string _expirationPath;
        private readonly string _startPath;
        private readonly double _toleranceMinutes;

        public DurationMatchesEndRule(string expirationPath, string startPath, double toleranceMinutes)
        {
            _expirationPath = expirationPath;
            _startPath = startPath;
            _toleranceMinutes = toleranceMinutes;
        }

        private static readonly string[] ExpirationMembers = ["type", "duration", "endDateTime"];

        public static CompareRule From(object declaration) => new DurationMatchesEndRule(
            RuleValues.ReadRequiredString(declaration, "Expiration"),
            RuleValues.ReadRequiredString(declaration, "Start"),
            RuleValues.ReadNumber(declaration, "ToleranceMinutes", 1));

        internal override void Apply(CompareRuleContext context)
        {
            if (RuleValues.ResolveSlots(context.Desired, _expirationPath).FirstOrDefault()?.Read() is not IDictionary desired ||
                RuleValues.ResolveSlots(context.Current, _expirationPath).FirstOrDefault()?.Read() is not IDictionary current ||
                !HasExpirationType(desired, "afterDuration") ||
                !HasExpirationType(current, "afterDateTime"))
            {
                return;
            }

            object? start = RuleValues.ResolveSlots(context.Current, _startPath).FirstOrDefault()?.Read();
            if (!RuleValues.TryReadDuration(RuleValues.GetValue(desired, "duration"), out TimeSpan duration) ||
                !RuleValues.TryReadInstant(start, out DateTimeOffset startInstant) ||
                !RuleValues.TryReadInstant(RuleValues.GetValue(current, "endDateTime"), out DateTimeOffset endInstant) ||
                Math.Abs((endInstant - startInstant - duration).TotalMinutes) >= _toleranceMinutes)
            {
                return;
            }

            foreach (string name in ExpirationMembers)
            {
                RuleValues.SetValue(current, name, RuleValues.GetValue(desired, name));
            }
        }

        private static bool HasExpirationType(IDictionary expiration, string type) =>
            string.Equals(RuleValues.ConvertToText(RuleValues.GetValue(expiration, "type")), type, StringComparison.OrdinalIgnoreCase);
    }

    internal sealed class AllowCurrentExtrasRule : CompareRule
    {
        private readonly string _property;
        private readonly string _matchKey;

        public AllowCurrentExtrasRule(string property, string matchKey)
        {
            _property = property;
            _matchKey = matchKey;
        }

        public static CompareRule From(object declaration) => new AllowCurrentExtrasRule(
            RuleValues.ReadRequiredString(declaration, "Property"),
            RuleValues.ReadRequiredString(declaration, "MatchKey"));

        internal override void Apply(CompareRuleContext context)
        {
            if (!RuleValues.HasKey(context.Desired, _property))
            {
                return;
            }

            List<object?> desired = [.. RuleValues.ListItems(RuleValues.GetValue(context.Desired, _property))];
            HashSet<string> desiredKeys = new(desired.OfType<IDictionary>().Select(ReadMatchKey), StringComparer.OrdinalIgnoreCase);

            List<object?> extras =
            [
                .. RuleValues.ListItems(RuleValues.GetValue(context.Current, _property))
                    .OfType<IDictionary>()
                    .Where(item => !desiredKeys.Contains(ReadMatchKey(item)))
            ];

            if (extras.Count > 0)
            {
                RuleValues.SetValue(context.Desired, _property, desired.Concat(extras).ToArray());
            }
        }

        private string ReadMatchKey(IDictionary item) => RuleValues.ConvertToText(RuleValues.GetValue(item, _matchKey)) ?? string.Empty;
    }

    internal sealed class CustomCompareRule : CompareRule
    {
        private readonly Action<CompareRuleContext> _comparer;

        public CustomCompareRule(Action<CompareRuleContext> comparer)
        {
            _comparer = comparer;
        }

        public static CompareRule From(object declaration) =>
            new CustomCompareRule(CompareRuleRegistry.CreateComparer(RuleValues.ReadRequiredString(declaration, "Name"), declaration));

        internal override void Apply(CompareRuleContext context)
        {
            _comparer(context);
        }
    }

    internal sealed class RuleCondition
    {
        private static readonly string[] Operators =
            ["Equals", "NotEquals", "IsNullOrEmpty", "NotNullOrEmpty", "HasKey", "NotHasKey", "Truthy", "Falsy"];

        private readonly IReadOnlyList<RuleCondition>? _all;
        private readonly IReadOnlyList<RuleCondition>? _any;
        private readonly RuleSide _side;
        private readonly string _property = string.Empty;
        private readonly string _operator = string.Empty;
        private readonly object? _operand;

        private RuleCondition(IReadOnlyList<RuleCondition>? all, IReadOnlyList<RuleCondition>? any)
        {
            _all = all;
            _any = any;
        }

        private RuleCondition(RuleSide side, string property, string @operator, object? operand)
        {
            _side = side;
            _property = property;
            _operator = @operator;
            _operand = operand;
        }

        public static RuleCondition? ReadOptional(object declaration, string name) =>
            MemberAccessor.TryGetMember(declaration, name, out object? value) && value is not null ? Read(value) : null;

        public bool IsMet(CompareRuleContext context)
        {
            if (_all is not null)
            {
                return _all.All(condition => condition.IsMet(context));
            }

            if (_any is not null)
            {
                return _any.Any(condition => condition.IsMet(context));
            }

            Hashtable values = context.GetSide(_side);
            object? value = RuleValues.GetValue(values, _property);

            return _operator switch
            {
                "Equals" => RuleValues.IsEqual(value, _operand),
                "NotEquals" => !RuleValues.IsEqual(value, _operand),
                "IsNullOrEmpty" => RuleValues.IsNullOrEmpty(value),
                "NotNullOrEmpty" => !RuleValues.IsNullOrEmpty(value),
                "HasKey" => RuleValues.HasKey(values, _property),
                "NotHasKey" => !RuleValues.HasKey(values, _property),
                "Truthy" => RuleValues.IsTruthy(value),
                "Falsy" => !RuleValues.IsTruthy(value),
                _ => false
            };
        }

        private static RuleCondition Read(object declaration)
        {
            if (MemberAccessor.TryGetMember(declaration, "All", out object? all) && all is not null)
            {
                return new RuleCondition([.. SchemaIndex.AsSequence(all).Select(Read)], null);
            }

            if (MemberAccessor.TryGetMember(declaration, "Any", out object? any) && any is not null)
            {
                return new RuleCondition(null, [.. SchemaIndex.AsSequence(any).Select(Read)]);
            }

            string property = RuleValues.ReadRequiredString(declaration, "Property");
            foreach (string candidate in Operators)
            {
                if (MemberAccessor.TryGetMember(declaration, candidate, out object? operand))
                {
                    RuleSide side = RuleValues.ReadSide(declaration, "Side", RuleSide.Desired);
                    return side == RuleSide.Both
                        ? throw new ArgumentException($"The condition on '{property}' only reads one side, not Both.", nameof(declaration))
                        : new RuleCondition(side, property, candidate, operand);
                }
            }

            throw new ArgumentException($"The condition on '{property}' has no operator.", nameof(declaration));
        }
    }

    internal sealed class RuleSlot
    {
        private readonly IDictionary _owner;
        private readonly string _name;

        public RuleSlot(IDictionary owner, string name)
        {
            _owner = owner;
            _name = name;
        }

        public bool IsPresent => RuleValues.HasKey(_owner, _name);

        public object? Read() => RuleValues.GetValue(_owner, _name);

        public void Write(object? value) => RuleValues.SetValue(_owner, _name, value);

        public void Remove() => RuleValues.RemoveValue(_owner, _name);
    }

    /// <summary>
    /// Provides utility methods for reading values from rule declarations.
    /// </summary>
    internal static class RuleValues
    {
        private const string EachSuffix = "[]";

        public static object? ReadOption(object declaration, string name) =>
            MemberAccessor.TryGetMember(declaration, name, out object? value) ? value : null;

        public static string ReadRequiredString(object declaration, string name) =>
            MemberAccessor.GetMemberAsString(declaration, name) is { Length: > 0 } value
                ? value
                : throw new ArgumentException($"The compare rule needs a {name}.", nameof(declaration));

        public static IReadOnlyList<string> ReadStrings(object declaration, string name) =>
            ReadOption(declaration, name) switch
            {
                null => [],
                string single => [single],
                var many => [.. SchemaIndex.AsSequence(many).Where(item => item is not null).Select(item => item.ToString())]
            };

        public static Regex? ReadPattern(object declaration, string name) =>
            MemberAccessor.GetMemberAsString(declaration, name) is { Length: > 0 } pattern
                ? new Regex(pattern, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant, TimeSpan.FromSeconds(1))
                : null;

        public static Regex ReadRequiredPattern(object declaration, string name) =>
            ReadPattern(declaration, name) ?? throw new ArgumentException($"The compare rule needs a {name}.", nameof(declaration));

        public static bool ReadBoolean(object declaration, string name) =>
            MemberAccessor.Unwrap(ReadOption(declaration, name)) is string text ? bool.TryParse(text, out bool flag) && flag : IsTruthy(ReadOption(declaration, name));

        public static double ReadNumber(object declaration, string name, double fallback) =>
            double.TryParse(ConvertToText(ReadOption(declaration, name)), NumberStyles.Float, CultureInfo.InvariantCulture, out double number)
                ? number
                : fallback;

        public static RuleSide ReadSide(object declaration, string name, RuleSide fallback) =>
            Enum.TryParse(MemberAccessor.GetMemberAsString(declaration, name), ignoreCase: true, out RuleSide parsed)
                ? parsed
                : fallback;

        public static IEnumerable<string> ListKeys(IDictionary table) => table.Keys.Cast<object>().Select(key => key.ToString());

        public static bool HasKey(IDictionary table, string name) => MemberAccessor.TryFindKey(table, name, out _);

        public static object? GetValue(IDictionary table, string name) => MemberAccessor.TryGetMember(table, name, out object? value) ? value : null;

        public static void SetValue(IDictionary table, string name, object? value) =>
            table[MemberAccessor.TryFindKey(table, name, out object? key) ? key! : name] = value;

        public static void RemoveValue(IDictionary table, string name)
        {
            if (MemberAccessor.TryFindKey(table, name, out object? key))
            {
                table.Remove(key!);
            }
        }

        // A dotted path whose segment ends in [] continues into every element of that array.
        public static IEnumerable<RuleSlot> ResolveSlots(IDictionary root, string path)
        {
            string[] segments = [.. path.Split('.').Select(TrimEachSuffix)];
            IEnumerable<IDictionary> owners = [root];

            foreach (string segment in segments.Take(segments.Length - 1))
            {
                owners = [.. owners.SelectMany(owner => ListItems(GetValue(owner, segment))).OfType<IDictionary>()];
            }

            return owners.Select(owner => new RuleSlot(owner, segments[segments.Length - 1]));
        }

        public static IEnumerable<object?> ListItems(object? value) =>
            MemberAccessor.Unwrap(value) switch
            {
                null => [],
                string text => [text],
                IDictionary single => [single],
                IEnumerable sequence => sequence.Cast<object?>(),
                var other => [other]
            };

        public static object? MapScalars(object? value, Func<object?, object?> map) =>
            MemberAccessor.Unwrap(value) switch
            {
                IDictionary => value,
                string text => map(text),
                IEnumerable sequence => sequence.Cast<object?>().Select(item => MapScalar(item, map)).ToArray(),
                var other => map(other)
            };

        private static object? MapScalar(object? item, Func<object?, object?> map) =>
            MemberAccessor.Unwrap(item) switch
            {
                string text => map(text),
                IEnumerable => item,
                var other => map(other)
            };

        public static string? ConvertToText(object? value) =>
            MemberAccessor.Unwrap(value) switch
            {
                null => null,
                bool flag => flag ? "True" : "False",
                var other => Convert.ToString(other, CultureInfo.InvariantCulture)
            };

        public static bool IsNullOrEmptyCollection(object? value) =>
            MemberAccessor.Unwrap(value) switch
            {
                null => true,
                string => false,
                ICollection collection => collection.Count == 0,
                _ => false
            };

        public static bool IsNullOrEmpty(object? value) =>
            MemberAccessor.Unwrap(value) is string text ? text.Length == 0 : IsNullOrEmptyCollection(value);

        public static bool IsTruthy(object? value) =>
            MemberAccessor.Unwrap(value) switch
            {
                null => false,
                bool flag => flag,
                string text => text.Length > 0,
                ICollection collection => collection.Count > 0,
                IConvertible number when IsNumber(number) => Convert.ToDouble(number, CultureInfo.InvariantCulture) != 0,
                _ => true
            };

        public static bool IsEqual(object? value, object? operand)
        {
            object? left = MemberAccessor.Unwrap(value);
            object? right = MemberAccessor.Unwrap(operand);

            if (right is bool expected)
            {
                return left is bool actual ? actual == expected : bool.TryParse(ConvertToText(left), out bool parsed) && parsed == expected;
            }

            return (left is null) == (right is null) &&
                string.Equals(ConvertToText(left), ConvertToText(right), StringComparison.OrdinalIgnoreCase);
        }

        public static bool TryReadInstant(object? value, out DateTimeOffset instant)
        {
            switch (MemberAccessor.Unwrap(value))
            {
                case DateTimeOffset offset:
                    instant = offset;
                    return true;
                case DateTime date:
                    instant = new DateTimeOffset(date.Kind == DateTimeKind.Unspecified ? DateTime.SpecifyKind(date, DateTimeKind.Utc) : date);
                    return true;
                case string text:
                    return DateTimeOffset.TryParse(text, CultureInfo.InvariantCulture, DateTimeStyles.AssumeUniversal, out instant);
                default:
                    instant = default;
                    return false;
            }
        }

        public static bool TryReadDuration(object? value, out TimeSpan duration) =>
            TryReadIsoDuration(value, out duration) ||
            (MemberAccessor.Unwrap(value) is string text && TimeSpan.TryParse(text, CultureInfo.InvariantCulture, out duration));

        public static bool TryReadIsoDuration(object? value, out TimeSpan duration)
        {
            duration = default;
            switch (MemberAccessor.Unwrap(value))
            {
                case TimeSpan span:
                    duration = span;
                    return true;
                case string { Length: > 0 } text:
                    try
                    {
                        duration = XmlConvert.ToTimeSpan(text);
                        return true;
                    }
                    catch (Exception exception) when (exception is FormatException or OverflowException)
                    {
                        return false;
                    }
                default:
                    return false;
            }
        }

        private static string TrimEachSuffix(string segment) =>
            segment.EndsWith(EachSuffix, StringComparison.Ordinal) ? segment.Substring(0, segment.Length - EachSuffix.Length) : segment;

        private static bool IsNumber(IConvertible value) =>
            value.GetTypeCode() is >= TypeCode.SByte and <= TypeCode.Decimal;
    }

    internal static class CompareValues
    {
        public static Hashtable CloneWithNestedValues(Hashtable source)
        {
            Hashtable copy = (Hashtable)source.Clone();
            foreach (object key in source.Keys.Cast<object>().ToArray())
            {
                copy[key] = CloneValue(source[key]);
            }

            return copy;
        }

        private static object? CloneValue(object? value) =>
            MemberAccessor.Unwrap(value) switch
            {
                Hashtable table => CloneWithNestedValues(table),
                OrderedDictionary ordered => CloneEntries(ordered, new OrderedDictionary(StringComparer.OrdinalIgnoreCase)),
                IDictionary dictionary => CloneEntries(dictionary, new Hashtable(StringComparer.OrdinalIgnoreCase)),
                Array array when array.Cast<object?>().All(IsLeaf) => array.Clone(),
                var leaf when ValueClassifier.IsLeaf(leaf) => leaf,
                IEnumerable items => items.Cast<object?>().Select(CloneValue).ToArray(),
                _ => CloneNormalized(value)
            };

        private static object? CloneNormalized(object? value)
        {
            object? normalized = ObjectNormalizer.Normalize(value);
            return normalized is Hashtable or object[] ? CloneValue(normalized) : normalized;
        }

        private static bool IsLeaf(object? value) => ValueClassifier.IsLeaf(MemberAccessor.Unwrap(value));

        private static IDictionary CloneEntries(IDictionary source, IDictionary copy)
        {
            foreach (DictionaryEntry entry in source)
            {
                copy[entry.Key] = CloneValue(entry.Value);
            }

            return copy;
        }
    }
}
