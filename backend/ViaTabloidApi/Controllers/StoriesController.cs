using Microsoft.AspNetCore.Mvc;
using ViaTabloidApi.Models.DTO;
using ViaTabloidApi.Services;

namespace ViaTabloidApi.Controllers
{
    /// <summary>
    /// Controller for managing stories in the API.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class StoriesController : ControllerBase
    {
        private readonly IStoryService _storyService;

        /// <summary>
        /// Initializes a new instance of the <see cref="StoriesController"/> class.
        /// </summary>
        /// <param name="storyService">The service for managing stories.</param>
        public StoriesController(IStoryService storyService)
        {
            _storyService = storyService;
        }

        /// <summary>
        /// Retrieves all stories.
        /// </summary>
        /// <returns>A list of stories.</returns>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Story>>> GetStories()
        {
            var stories = await _storyService.GetAllStoriesAsync();
            return Ok(stories);
        }

        /// <summary>
        /// Retrieves a specific story by its ID.
        /// </summary>
        /// <param name="id">The ID of the story to retrieve.</param>
        /// <returns>The requested story if found, otherwise a 404 Not Found response.</returns>
        [HttpGet("{id}")]
        public async Task<ActionResult<Story>> GetStory(int id)
        {
            var story = await _storyService.GetStoryByIdAsync(id);
            if (story == null) return NotFound();
            return Ok(story);
        }

        /// <summary>
        /// Creates a new story.
        /// </summary>
        /// <param name="createStoryDTO">The data transfer object containing the details of the story to create.</param>
        /// <returns>The created story with a 201 Created response.</returns>
        [HttpPost]
        public async Task<ActionResult<Story>> PostStory(CreateStoryDTO createStoryDTO)
        {
            var createdStory = await _storyService.CreateStoryAsync(createStoryDTO);
            return CreatedAtAction(nameof(GetStory), new { id = createdStory.Id }, createdStory);
        }

        /// <summary>
        /// Updates an existing story.
        /// </summary>
        /// <param name="id">The ID of the story to update.</param>
        /// <param name="story">The updated story object.</param>
        /// <returns>No content if the update is successful, otherwise a bad request response.</returns>
        [HttpPut("{id}")]
        public async Task<IActionResult> PutStory(int id, Story story)
        {
            if (id != story.Id) return BadRequest();
            await _storyService.UpdateStoryAsync(story);
            return NoContent();
        }

        /// <summary>
        /// Deletes a story by its ID.
        /// </summary>
        /// <param name="id">The ID of the story to delete.</param>
        /// <returns>No content if the deletion is successful.</returns>
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteStory(int id)
        {
            await _storyService.DeleteStoryAsync(id);
            return NoContent();
        }
    }
}