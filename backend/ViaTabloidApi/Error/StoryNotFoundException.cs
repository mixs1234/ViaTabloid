using System;

namespace ViaTabloidApi.Error
{
    /// <summary>
    /// Exception thrown when a story is not found.
    /// </summary>
    public class StoryNotFoundException : Exception
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="StoryNotFoundException"/> class with a specified error message.
        /// </summary>
        /// <param name="message">The message that describes the error.</param>
        public StoryNotFoundException(string message) : base(message) { }
    }
}