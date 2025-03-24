namespace ViaTabloidApi.Models.DTO
{
    public class CreateStoryDTO
    {
        public string Title { get; set; }
        public string Content { get; set; }
        public string Department { get; set; }

        public Story MapToEntity()
        {
            return new Story
            {
                Title = this.Title,
                Content = this.Content,
                Department = this.Department
            };
        }
    }
}