namespace ViaTabloidApi.Resources
{

    /// <summary>
    /// Represents a repository interface for managing stories.
    /// </summary>
    public interface IStoryRepository
    {
        /// <summary>
        /// Retrieves all stories asynchronously.
        /// </summary>
        /// <returns>A task that represents the asynchronous operation. The task result contains an enumerable collection of stories.</returns>
        Task<IEnumerable<Story>> GetAllAsync();

        /// <summary>
        /// Retrieves a story by its unique identifier asynchronously.
        /// </summary>
        /// <param name="id">The unique identifier of the story.</param>
        /// <returns>A task that represents the asynchronous operation. The task result contains the story with the specified identifier.</returns>
        Task<Story> GetByIdAsync(int id);

        /// <summary>
        /// Adds a new story asynchronously.
        /// </summary>
        /// <param name="story">The story to add.</param>
        /// <returns>A task that represents the asynchronous operation.</returns>
        /// <remarks>The task result contains the story with its unique identifier populated.</remarks>
        Task<Story> AddAsync(Story story);

        /// <summary>
        /// Updates an existing story asynchronously.
        /// </summary>
        /// <param name="story">The story to update.</param>
        /// <returns>A task that represents the asynchronous operation.</returns>
        /// <remarks>The task result contains the updated story.</remarks>
        Task<Story> UpdateAsync(Story story);

        /// <summary>
        /// Deletes a story by its unique identifier asynchronously.
        /// </summary>
        /// <param name="id">The unique identifier of the story to delete.</param>
        /// <returns>A task that represents the asynchronous operation.</returns>
        Task DeleteAsync(int id);
    }
}