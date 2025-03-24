using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ViaTabloidApi.Infrastructure.Configuration
{
    /// <summary>
    /// Configures the entity type <see cref="Story"/> for the database context.
    /// </summary>
    public class StoryConfiguration : IEntityTypeConfiguration<Story>
    {
        /// <summary>
        /// Configures the properties and relationships of the <see cref="Story"/> entity.
        /// </summary>
        /// <param name="builder">The builder used to configure the <see cref="Story"/> entity.</param>
        public void Configure(EntityTypeBuilder<Story> builder)
        {
            // Table mapping
            builder.ToTable("Stories");

            // Primary key with auto-increment
            builder.HasKey(story => story.Id);
            builder.Property(story => story.Id)
                .ValueGeneratedOnAdd(); // Auto-generates Id (serial in PostgreSQL)

            // Title configuration
            builder.Property(story => story.Title)
                .HasMaxLength(255)
                .IsRequired();

            // Content configuration
            builder.Property(story => story.Content)
                .HasMaxLength(4000)
                .IsRequired();

            // Department configuration
            builder.Property(story => story.Department)
                .HasMaxLength(255)
                .IsRequired();

            // CreatedAt: Auto-set to current UTC timestamp on insert
            builder.Property(story => story.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("NOW() AT TIME ZONE 'UTC'") // PostgreSQL UTC timestamp
                .ValueGeneratedOnAdd();

            // UpdatedAt: Auto-set to current UTC timestamp on insert and update
            builder.Property(story => story.UpdatedAt)
                .IsRequired()
                .HasDefaultValueSql("NOW() AT TIME ZONE 'UTC'") // PostgreSQL UTC timestamp
                .ValueGeneratedOnAddOrUpdate();
        }
    }
}