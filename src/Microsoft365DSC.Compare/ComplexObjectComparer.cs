using Microsoft.Management.Infrastructure;
using Microsoft365DSC.Utilities;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace Microsoft365DSC.Compare
{
    /// <summary>
    /// Provides comprehensive comparison of complex M365DSC objects for drift detection.
    /// Supports hashtables, PSObjects, CIM instances, arrays, and nested structures.
    /// </summary>
    public static class ComplexObjectComparer
    {
        private const string ComputerNameProperty = "PSComputerName";

        /// <summary>
        /// Compares two complex M365DSC objects to detect configuration drift.
        /// </summary>
        /// <param name="source">Source (desired) object</param>
        /// <param name="target">Target (current) object</param>
        /// <param name="propertyName">Property name for drift reporting</param>
        /// <param name="excludedSet">Property names to skip during comparison</param>
        /// <returns>The drifts found and true when the objects are identical</returns>
        public static Tuple<List<Dictionary<string, object>>, bool> Compare(
            object source,
            object target,
            string propertyName,
            HashSet<string>? excludedSet)
        {
            List<Hashtable> drifts = [];
            bool result = CompareInto(source, target, propertyName, excludedSet, drifts, null);

            List<Dictionary<string, object>> converted = new(drifts.Count);
            foreach (Hashtable drift in drifts)
            {
                converted.Add(DriftRecord.ToDictionary(drift));
            }

            return new Tuple<List<Dictionary<string, object>>, bool>(converted, result);
        }

        internal static bool CompareInto(
            object? source,
            object? target,
            string propertyName,
            HashSet<string>? excludedSet,
            List<Hashtable> drifts,
            HashSet<string>? rootSkippedKeys,
            SchemaIndex? schema = null,
            string? className = null)
        {
            Traversal traversal = new(excludedSet ?? new HashSet<string>(StringComparer.OrdinalIgnoreCase), schema);
            return traversal.Run(source, target, propertyName, drifts, 0, className, rootSkippedKeys);
        }

        private readonly struct Frame
        {
            public Frame(object? left, object? right, string? propName, string? className, HashSet<string>? skippedKeys)
            {
                Left = left;
                Right = right;
                PropName = propName;
                ClassName = className;
                SkippedKeys = skippedKeys;
            }

            public object? Left { get; }

            public object? Right { get; }

            public string? PropName { get; }

            public string? ClassName { get; }

            public HashSet<string>? SkippedKeys { get; }
        }

        private sealed class Traversal
        {
            private readonly HashSet<string> _excluded;
            private readonly SchemaIndex? _schema;
            private readonly bool _pathExclusionsPresent;
            private readonly List<Stack<Frame>> _stacks = [];

            public Traversal(HashSet<string> excluded, SchemaIndex? schema)
            {
                _excluded = excluded;
                _schema = schema;
                foreach (string name in excluded)
                {
                    if (name.IndexOf('.') >= 0 || name.IndexOf('[') >= 0)
                    {
                        _pathExclusionsPresent = true;
                        break;
                    }
                }
            }

            public bool Run(
                object? left,
                object? right,
                string? propName,
                List<Hashtable>? drifts,
                int depth,
                string? className = null,
                HashSet<string>? skippedKeys = null)
            {
                bool collecting = drifts is not null;
                Stack<Frame> stack = GetStack(depth);
                stack.Push(new Frame(left, right, propName, className, skippedKeys));

                bool result = true;
                while (stack.Count > 0)
                {
                    Frame frame = stack.Pop();

                    if (frame.PropName is not null && _excluded.Contains(frame.PropName))
                    {
                        continue;
                    }

                    if (frame.Left is null && frame.Right is null)
                    {
                        continue;
                    }

                    if ((frame.Left is null) != (frame.Right is null))
                    {
                        if (!collecting)
                        {
                            return false;
                        }

                        drifts!.Add(NullMismatch(frame.PropName!, frame.Left is null, frame.Right is null));
                        result = false;
                        continue;
                    }

                    if (IsComplexArrayCandidate(frame.Left) || IsComplexArrayCandidate(frame.Right))
                    {
                        if (!CompareComplexArray(frame.Left!, frame.Right!, frame.PropName, drifts, depth, frame.ClassName))
                        {
                            if (!collecting)
                            {
                                return false;
                            }

                            result = false;
                        }

                        continue;
                    }

                    if (frame.Left is Array || frame.Right is Array)
                    {
                        Array leftArray = ToArray(frame.Left);
                        Array rightArray = ToArray(frame.Right);
                        List<CompareObjectModel> differences = ArrayComparer.CompareArrays(rightArray, leftArray);
                        if (differences.Count > 0)
                        {
                            if (!collecting)
                            {
                                return false;
                            }

                            drifts!.Add(DriftRecord.Create(
                                frame.PropName!,
                                string.Join(", ", rightArray.Cast<object>()),
                                string.Join(", ", leftArray.Cast<object>()),
                                ArrayComparer.FormatDelta(differences)));
                            result = false;
                        }

                        continue;
                    }

                    if (!CompareSingleObject(frame, drifts, stack))
                    {
                        if (!collecting)
                        {
                            return false;
                        }

                        result = false;
                    }
                }

                return result;
            }

            private Stack<Frame> GetStack(int depth)
            {
                while (_stacks.Count <= depth)
                {
                    _stacks.Add(new Stack<Frame>());
                }

                Stack<Frame> stack = _stacks[depth];
                stack.Clear();
                return stack;
            }

            private bool CompareComplexArray(object left, object right, string? propName, List<Hashtable>? drifts, int depth, string? elementClassName)
            {
                bool collecting = drifts is not null;
                Array leftArray = ToArray(left);
                Array rightArray = ToArray(right);

                if (leftArray.Length > 0 && rightArray.Length > 0 &&
                    !(leftArray.GetValue(0) is CimInstance firstLeft && IsIntuneAssignmentClass(firstLeft.CimSystemProperties.ClassName)) &&
                    TryGetPrimaryKeys(elementClassName, out List<string> primaryKeyNames) &&
                    PrimaryKeyPairing.CanPair(AsObjectArray(leftArray), primaryKeyNames) &&
                    PrimaryKeyPairing.CanPair(AsObjectArray(rightArray), primaryKeyNames))
                {
                    return CompareComplexArrayByKeys(leftArray, rightArray, propName, drifts, depth, elementClassName!, primaryKeyNames);
                }

                if (leftArray.Length != rightArray.Length)
                {
                    if (collecting)
                    {
                        drifts!.Add(DriftRecord.Create(
                            propName!,
                            $"Current value has {{{rightArray.Length}}} items",
                            $"Desired value has {{{leftArray.Length}}} items"));
                    }

                    return false;
                }

                if (leftArray.GetValue(0) is CimInstance cimInstance && IsIntuneAssignmentClass(cimInstance.CimSystemProperties.ClassName))
                {
                    return IntunePolicyAssignmentComparer.Compare(leftArray, rightArray, drifts ?? []);
                }

                bool nameNeeded = collecting || _pathExclusionsPresent;
                bool[] consumed = new bool[rightArray.Length];
                bool anyAttemptFailed = false;

                for (int i = 0; i < leftArray.Length; i++)
                {
                    object? sourceItem = leftArray.GetValue(i);
                    string? itemName = nameNeeded ? $"{propName}[{i}]" : null;
                    bool found = false;

                    for (int j = 0; j < rightArray.Length; j++)
                    {
                        if (consumed[j])
                        {
                            continue;
                        }

                        if (Run(sourceItem, rightArray.GetValue(j), itemName, null, depth + 1))
                        {
                            consumed[j] = true;
                            found = true;
                            break;
                        }

                        anyAttemptFailed = true;
                    }

                    if (found)
                    {
                        continue;
                    }

                    if (!collecting)
                    {
                        return false;
                    }

                    int before = drifts!.Count;
                    for (int j = 0; j < rightArray.Length; j++)
                    {
                        if (!consumed[j])
                        {
                            Run(sourceItem, rightArray.GetValue(j), itemName, drifts, depth + 1);
                        }
                    }

                    if (!anyAttemptFailed && drifts.Count == before)
                    {
                        drifts.Add(DriftRecord.Create(itemName!, right, left));
                    }

                    return false;
                }

                return true;
            }

            private bool CompareComplexArrayByKeys(
                Array leftArray,
                Array rightArray,
                string? propName,
                List<Hashtable>? drifts,
                int depth,
                string elementClassName,
                List<string> primaryKeyNames)
            {
                bool collecting = drifts is not null;
                var (pairs, extras) = PrimaryKeyPairing.Pair(AsObjectArray(leftArray), AsObjectArray(rightArray), primaryKeyNames);
                HashSet<string> skippedKeys = PrimaryKeyPairing.SkippedKeys(primaryKeyNames, null, false);
                bool result = true;

                foreach (var (desiredItem, currentItem, idx) in pairs)
                {
                    if (currentItem is null)
                    {
                        if (!collecting)
                        {
                            return false;
                        }

                        drifts!.Add(DriftRecord.Create($"{propName}[{idx}]", null, desiredItem));
                        result = false;
                        continue;
                    }

                    if (!Run(desiredItem, currentItem, $"{propName}[{idx}]", drifts, depth + 1, elementClassName, skippedKeys))
                    {
                        if (!collecting)
                        {
                            return false;
                        }

                        result = false;
                    }
                }

                foreach (var (extraItem, idx) in extras)
                {
                    if (!collecting)
                    {
                        return false;
                    }

                    drifts!.Add(DriftRecord.Create($"{propName}[extra:{idx}]", extraItem, null));
                    result = false;
                }

                return result;
            }

            private bool TryGetPrimaryKeys(string? className, out List<string> primaryKeyNames)
            {
                primaryKeyNames = [];
                if (_schema is null || string.IsNullOrEmpty(className) || !_schema.TryGetClass(className, out ClassDefinition definition))
                {
                    return false;
                }

                primaryKeyNames = definition.Mandatory.Names;
                return primaryKeyNames.Count > 0;
            }

            private string? GetChildClassName(string? className, string key)
            {
                if (_schema is null || string.IsNullOrEmpty(className) || !_schema.TryGetClass(className, out ClassDefinition definition))
                {
                    return null;
                }

                return definition.TryGetParameter(key, out ParameterDefinition parameter) ? parameter.ElementClassName : null;
            }

            private bool CompareSingleObject(Frame frame, List<Hashtable>? drifts, Stack<Frame> stack)
            {
                bool collecting = drifts is not null;
                bool nameNeeded = collecting || _pathExclusionsPresent;
                object? right = frame.Right is PSObject psObject ? psObject.BaseObject : frame.Right;
                bool returnResult = true;

                foreach (string key in GetObjectKeys(frame.Left!))
                {
                    if (_excluded.Contains(key))
                    {
                        continue;
                    }

                    if (frame.SkippedKeys is not null && frame.SkippedKeys.Contains(key))
                    {
                        continue;
                    }

                    if (!HasKey(right, key))
                    {
                        continue;
                    }

                    object? sourceValue = GetValue(frame.Left!, key);
                    object? targetValue = GetValue(right, key);

                    if ((sourceValue is null) != (targetValue is null))
                    {
                        if (!collecting)
                        {
                            return false;
                        }

                        drifts!.Add(NullMismatch($"{frame.PropName}.{key}", sourceValue is null, targetValue is null));
                        returnResult = false;
                        continue;
                    }

                    if (sourceValue is null)
                    {
                        continue;
                    }

                    if (IsComplexType(sourceValue))
                    {
                        stack.Push(new Frame(
                            sourceValue,
                            targetValue,
                            nameNeeded ? $"{frame.PropName}.{key}" : null,
                            GetChildClassName(frame.ClassName, key),
                            null));
                        continue;
                    }

                    if (!CompareSimpleValues(sourceValue, targetValue!))
                    {
                        if (!collecting)
                        {
                            return false;
                        }

                        drifts!.Add(DriftRecord.Create($"{frame.PropName}.{key}", targetValue, sourceValue));
                        returnResult = false;
                    }
                }

                return returnResult;
            }
        }

        private static object[] AsObjectArray(Array source)
        {
            if (source is object[] typed)
            {
                return typed;
            }

            object[] result = new object[source.Length];
            for (int i = 0; i < source.Length; i++)
            {
                result[i] = source.GetValue(i);
            }

            return result;
        }

        private static Hashtable NullMismatch(string propName, bool leftIsNull, bool rightIsNull)
        {
            return DriftRecord.Create(
                propName,
                rightIsNull ? "Current value is null" : "Current value is NOT null",
                leftIsNull ? "Desired value is null" : "Desired value is NOT null");
        }

        private static bool IsIntuneAssignmentClass(string className)
        {
            return className.Equals("MSFT_DeviceManagementConfigurationPolicyAssignments") ||
                className.Equals("MSFT_DeviceManagementMobileAppAssignment") ||
                (className.Contains("MSFT_Intune") && className.EndsWith("Assignments") &&
                !className.Equals("MSFT_IntuneDeviceRemediationPolicyAssignments"));
        }

        private static bool CompareSimpleValues(object left, object right)
        {
            if (left is PSObject psObject)
            {
                left = psObject.BaseObject;
            }

            if (right is PSObject psObjectRight)
            {
                right = psObjectRight.BaseObject;
            }

            if (left is DateTime leftDate && right is DateTime rightDate)
            {
                return leftDate == rightDate;
            }

            if (left is bool leftBool && right is bool rightBool)
            {
                return leftBool == rightBool;
            }

            if (left is string leftStr && right is string rightStr)
            {
                return string.Equals(
                    Utilities.Utilities.NormalizeLineEndings(leftStr),
                    Utilities.Utilities.NormalizeLineEndings(rightStr),
                    StringComparison.OrdinalIgnoreCase);
            }

            if (IsNumericType(left) && IsNumericType(right))
            {
                return CompareNumericValues(left, right);
            }

            return left.ToString().Equals(right.ToString(), StringComparison.OrdinalIgnoreCase);
        }

        private static bool IsNumericType(object obj)
        {
            if (obj is null)
            {
                return false;
            }

            return Type.GetTypeCode(obj.GetType())
                is TypeCode.Byte or TypeCode.SByte
                or TypeCode.Int16 or TypeCode.UInt16
                or TypeCode.Int32 or TypeCode.UInt32
                or TypeCode.Int64 or TypeCode.UInt64
                or TypeCode.Single or TypeCode.Double or TypeCode.Decimal;
        }

        private static bool CompareNumericValues(object left, object right)
        {
            try
            {
                decimal leftDecimal = Convert.ToDecimal(left);
                decimal rightDecimal = Convert.ToDecimal(right);
                return leftDecimal == rightDecimal;
            }
            catch (OverflowException)
            {
                try
                {
                    double leftDouble = Convert.ToDouble(left);
                    double rightDouble = Convert.ToDouble(right);
                    return Math.Abs(leftDouble - rightDouble) < double.Epsilon;
                }
                catch
                {
                    return Equals(left, right);
                }
            }
            catch
            {
                return Equals(left, right);
            }
        }

        private static bool IsComplexArrayCandidate(object? obj)
        {
            if (obj is Array array && array.Length > 0)
            {
                return IsComplexType(array.GetValue(0));
            }

            return false;
        }

        private static bool IsComplexType(object? obj)
        {
            if (obj is null)
            {
                return false;
            }

            if (obj is PSObject psObject && psObject.BaseObject is not null)
            {
                obj = psObject.BaseObject;
            }

            return obj is CimInstance ||
                   obj is IDictionary ||
                   obj is Array;
        }

        private static Array ToArray(object? obj)
        {
            if (obj is null)
            {
                return Array.Empty<object>();
            }

            if (obj is Array array)
            {
                return array;
            }

            if (obj is IEnumerable enumerable)
            {
                return enumerable.Cast<object>().ToArray();
            }

            return new[] { obj };
        }

        private static IEnumerable<string> GetObjectKeys(object obj)
        {
            if (obj is PSObject psObj)
            {
                return psObj.Properties
                    .Where(p => p.Name != ComputerNameProperty)
                    .Select(p => p.Name);
            }

            if (obj is IDictionary dict)
            {
                List<string> keys = new(dict.Count);
                foreach (object key in dict.Keys)
                {
                    string name = key.ToString();
                    if (name != ComputerNameProperty)
                    {
                        keys.Add(name);
                    }
                }

                return keys;
            }

            if (obj is CimInstance cimInstance)
            {
                return cimInstance.CimInstanceProperties
                    .Where(p => p.IsValueModified && p.Name != ComputerNameProperty)
                    .Select(p => p.Name);
            }

            return [];
        }

        private static bool HasKey(object? obj, string key)
        {
            if (obj is PSObject psObj)
            {
                return psObj.Properties[key] is not null;
            }

            if (obj is IDictionary dict)
            {
                return dict.Contains(key);
            }

            return false;
        }

        private static object? GetValue(object? obj, string key)
        {
            if (obj is CimInstance cimInstance)
            {
                return cimInstance.CimInstanceProperties[key]?.Value;
            }

            if (obj is PSObject psObj)
            {
                return psObj.Properties[key]?.Value;
            }

            if (obj is IDictionary dict)
            {
                return dict[key];
            }

            return null;
        }
    }
}
