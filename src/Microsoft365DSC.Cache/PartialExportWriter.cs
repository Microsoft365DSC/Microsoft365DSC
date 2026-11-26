using System;
using System.Collections.Concurrent;
using System.IO;
using System.Text;

namespace Microsoft365DSC.Cache
{
    /// <summary>
    /// Appends exported instances to the partial export file. The runspaces of a parallel export share
    /// one lock per file. The file name is unique per export, no other process writes to it.
    /// </summary>
    public static class PartialExportWriter
    {
        private static readonly ConcurrentDictionary<string, object> _locks = new(StringComparer.OrdinalIgnoreCase);

        /// <summary>Appends content to the file as UTF-8.</summary>
        /// <param name="path">The partial export file.</param>
        /// <param name="content">The content to append.</param>
        public static void Append(string path, string content)
        {
            object gate = _locks.GetOrAdd(Path.GetFullPath(path), _ => new object());
            lock (gate)
            {
                File.AppendAllText(path, content, Encoding.UTF8);
            }
        }

        /// <summary>Releases the lock kept for the file.</summary>
        /// <param name="path">The partial export file.</param>
        public static void Release(string path)
        {
            _locks.TryRemove(Path.GetFullPath(path), out _);
        }
    }
}
