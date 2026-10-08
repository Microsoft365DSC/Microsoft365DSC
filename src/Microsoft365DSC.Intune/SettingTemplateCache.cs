using System;
using System.Collections.Concurrent;

namespace Microsoft365DSC.Intune
{
    /// <summary>
    /// Process-wide cache of Settings Catalog template payloads (setting templates with their
    /// definitions), keyed by template id.
    /// </summary>
    public static class SettingTemplateCache
    {
        private static readonly ConcurrentDictionary<string, object[]> Templates = new(StringComparer.OrdinalIgnoreCase);

        public static int Count => Templates.Count;

        public static bool TryGet(string templateId, out object[]? templates)
        {
            templates = null;
            return !string.IsNullOrEmpty(templateId) && Templates.TryGetValue(templateId, out templates);
        }

        public static void Set(string templateId, object[]? templates)
        {
            if (string.IsNullOrEmpty(templateId) || templates is null)
            {
                return;
            }

            Templates.TryAdd(templateId, templates);
        }

        public static void Reset()
        {
            Templates.Clear();
        }
    }
}
