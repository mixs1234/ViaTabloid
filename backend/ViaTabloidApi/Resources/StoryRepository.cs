using Microsoft.EntityFrameworkCore;
using ViaTabloidApi.Error;
using ViaTabloidApi.Infrastructure;

namespace ViaTabloidApi.Resources
{
    public class StoryRepository : IStoryRepository
    {

        private readonly Context _context;

        public StoryRepository(Context context)
        {
            _context = context;
        }

        public async Task<Story> AddAsync(Story story)
        {
            var storyEntity = await _context.Stories.AddAsync(story);
            await _context.SaveChangesAsync();
            return storyEntity.Entity;
        }

        public async Task DeleteAsync(int id)
        {
            var story = await _context.Stories.FindAsync(id);
            if (story == null)
                throw new StoryNotFoundException($"Story with ID {id} not found.");
            _context.Stories.Remove(story);
            await _context.SaveChangesAsync();
        }

        public async Task<IEnumerable<Story>> GetAllAsync()
        {
            var stories = await _context.Stories.ToListAsync();
            return stories;
        }

        public async Task<Story> GetByIdAsync(int id)
        {

            var story = await _context.Stories.FindAsync(id);
            if (story == null)
                throw new StoryNotFoundException($"Story with ID {id} not found.");
            return story;
        }

        public async Task<Story> UpdateAsync(Story story)
        {
            var existingStory = await GetByIdAsync(story.Id);
            if (existingStory == null)
                throw new StoryNotFoundException($"Story with ID {story.Id} not found.");
            _context.Entry(existingStory).CurrentValues.SetValues(story);
            await _context.SaveChangesAsync();
            return existingStory;
        }
    }
}