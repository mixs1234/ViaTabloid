using ViaTabloidApi.Error;
using ViaTabloidApi.Models.DTO;
using ViaTabloidApi.Resources;

namespace ViaTabloidApi.Services
{
    public class StoryService : IStoryService
    {
        private readonly IStoryRepository _storyRepository;

        public StoryService(IStoryRepository storyRepository)
        {
            _storyRepository = storyRepository ?? throw new ArgumentNullException(nameof(storyRepository));
        }

        public async Task<Story> CreateStoryAsync(CreateStoryDTO createStoryDTO)
        {
            if (createStoryDTO == null)
                throw new ArgumentNullException(nameof(createStoryDTO), "CreateStoryDTO cannot be null.");
            if (string.IsNullOrWhiteSpace(createStoryDTO.Title))
                throw new ArgumentException("Story title is required.", nameof(createStoryDTO));
            if (string.IsNullOrWhiteSpace(createStoryDTO.Content))
                throw new ArgumentException("Story content is required.", nameof(createStoryDTO));

            var story = createStoryDTO.MapToEntity();

            var createdStory = await _storyRepository.AddAsync(story);
            return createdStory;
        }

        public async Task<Story> GetStoryByIdAsync(int id)
        {
            if (id <= 0)
                throw new ArgumentException("Invalid story ID.", nameof(id));

            var story = await _storyRepository.GetByIdAsync(id);
            if (story == null)
                throw new StoryNotFoundException($"Story with ID {id} not found.");

            return story;
        }

        public async Task<IEnumerable<Story>> GetAllStoriesAsync()
        {
            var stories = await _storyRepository.GetAllAsync();
            return stories ?? Enumerable.Empty<Story>();
        }

        public async Task UpdateStoryAsync(Story story)
        {
            if (story == null)
                throw new ArgumentNullException(nameof(story), "Story cannot be null.");
            if (story.Id <= 0)
                throw new ArgumentException("Invalid story ID.", nameof(story));

            var existingStory = await _storyRepository.GetByIdAsync(story.Id);
            if (existingStory == null)
                throw new StoryNotFoundException($"Story with ID {story.Id} not found.");

            if (string.IsNullOrWhiteSpace(story.Title))
                throw new ArgumentException("Story title is required.", nameof(story));

            await _storyRepository.UpdateAsync(story);
        }

        public async Task DeleteStoryAsync(int id)
        {
            if (id <= 0)
                throw new ArgumentException("Invalid story ID.", nameof(id));

            var story = await _storyRepository.GetByIdAsync(id);
            if (story == null)
                throw new StoryNotFoundException($"Story with ID {id} not found.");

            await _storyRepository.DeleteAsync(id);
        }
    }
}