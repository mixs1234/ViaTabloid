/// <summary>
/// Represents a story with details such as title, content, department, and timestamps.
/// </summary>
public class Story
{
    /// <summary>
    /// Gets or sets the unique identifier for the story.
    /// </summary>
    public int Id { get; set; }
    /// <summary>
    /// Gets or sets the title of the story. This property is required.
    /// </summary>
    public required string Title { get; set; }
    /// <summary>
    /// Gets or sets the content of the story. This property is required.
    /// </summary>
    public required string Content { get; set; }
    /// <summary>
    /// Gets or sets the department associated with the story. This property is required.
    /// </summary>
    public required string Department { get; set; }
    /// <summary>
    /// Gets or sets the date and time when the story was created.
    /// </summary>
    public DateTime CreatedAt { get; set; }
    /// <summary>
    /// Gets or sets the date and time when the story was last updated.
    /// </summary>
    public DateTime UpdatedAt { get; set; }
}