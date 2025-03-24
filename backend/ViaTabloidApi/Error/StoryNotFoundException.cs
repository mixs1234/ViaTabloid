using System;

namespace ViaTabloidApi.Error
{
    public class StoryNotFoundException : Exception
    {
        public StoryNotFoundException(string message) : base(message) { }
    }
}