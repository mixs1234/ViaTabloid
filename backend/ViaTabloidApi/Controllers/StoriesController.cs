using Microsoft.AspNetCore.Mvc;
using ViaTabloidApi.Models.DTO;
using ViaTabloidApi.Services;

namespace ViaTabloidApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class StoriesController : ControllerBase
    {
        private readonly IStoryService _storyService;

        public StoriesController(IStoryService storyService)
        {
            _storyService = storyService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Story>>> GetStories()
        {
            var stories = await _storyService.GetAllStoriesAsync();
            return Ok(stories);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Story>> GetStory(int id)
        {
            var story = await _storyService.GetStoryByIdAsync(id);
            if (story == null) return NotFound();
            return Ok(story);
        }

        [HttpPost]
        public async Task<ActionResult<Story>> PostStory(CreateStoryDTO createStoryDTO)
        {
            var createdStory = await _storyService.CreateStoryAsync(createStoryDTO);
            return CreatedAtAction(nameof(GetStory), new { id = createdStory.Id }, createdStory);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> PutStory(int id, Story story)
        {
            if (id != story.Id) return BadRequest();
            await _storyService.UpdateStoryAsync(story);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteStory(int id)
        {
            await _storyService.DeleteStoryAsync(id);
            return NoContent();
        }
    }
}