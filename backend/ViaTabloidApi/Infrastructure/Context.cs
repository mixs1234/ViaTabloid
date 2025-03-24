using Microsoft.EntityFrameworkCore;
using ViaTabloidApi.Infrastructure.Configuration;

namespace ViaTabloidApi.Infrastructure
{
    /// <summary>
    /// Represents the database context for the application, inheriting from <see cref="DbContext"/>.
    /// Provides access to the database sets and configuration for the entity models.
    /// </summary>
    public class Context : DbContext
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="Context"/> class with the specified options.
        /// </summary>
        /// <param name="options">The options to configure the database context.</param>
        public Context(DbContextOptions<Context> options) : base(options)
        {
        }

        /// <summary>
        /// Gets or sets the <see cref="DbSet{TEntity}"/> for the <see cref="Story"/> entity.
        /// </summary>
        public DbSet<Story> Stories { get; set; }

        /// <summary>
        /// Configures the entity models using the <see cref="ModelBuilder"/>.
        /// </summary>
        /// <param name="modelBuilder">The builder used to configure the entity models.</param>
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.ApplyConfiguration(new StoryConfiguration());
        }
    }
}