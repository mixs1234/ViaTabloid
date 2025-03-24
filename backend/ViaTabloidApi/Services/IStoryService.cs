using ViaTabloidApi.Models.DTO;

namespace ViaTabloidApi.Services
{
    /// <summary>
    /// Interface for managing stories in the application.
    /// </summary>
    public interface IStoryService
    {
        /// <summary>
        /// Retrieves all stories asynchronously.
        /// </summary>
        /// <returns>A task that represents the asynchronous operation. The task result contains a collection of stories.</returns>
        Task<IEnumerable<Story>> GetAllStoriesAsync();

        /// <summary>
        /// Retrieves a specific story by its unique identifier asynchronously.
        /// </summary>
        /// <param name="id">The unique identifier of the story.</param>
        /// <returns>A task that represents the asynchronous operation. The task result contains the story with the specified ID.</returns>
        Task<Story> GetStoryByIdAsync(int id);

        /// <summary>
        /// Creates a new story asynchronously.
        /// </summary>
        /// <param name="story">The story to be created.</param>
        /// <returns>A task that represents the asynchronous operation. The task result contains the created story.</returns>
        Task<Story> CreateStoryAsync(CreateStoryDTO createStoryDTO);

        /// <summary>
        /// Updates an existing story asynchronously.
        /// </summary>
        /// <param name="story">The story with updated information.</param>
        /// <returns>A task that represents the asynchronous operation.</returns>
        Task UpdateStoryAsync(Story story);

        /// <summary>
        /// Deletes a story by its unique identifier asynchronously.
        /// </summary>
        /// <param name="id">The unique identifier of the story to be deleted.</param>
        /// <returns>A task that represents the asynchronous operation.</returns>
        Task DeleteStoryAsync(int id);
    }
}