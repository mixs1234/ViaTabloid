using Microsoft.EntityFrameworkCore;
using ViaTabloidApi.Infrastructure;
using ViaTabloidApi.Middleware;
using ViaTabloidApi.Resources;
using ViaTabloidApi.Services;
using Polly;
using Context = ViaTabloidApi.Infrastructure.Context;

var builder = WebApplication.CreateBuilder(args);


builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowLocalhost3000", policy =>
    {
        policy.WithOrigins("http://localhost:3000")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddControllers();
builder.Services.AddDbContext<Context>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddScoped<IStoryRepository, StoryRepository>();
builder.Services.AddScoped<IStoryService, StoryService>();

var app = builder.Build();

app.UseMiddleware<ExceptionMiddleware>();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<Context>();
    var policy = Policy
        .Handle<Exception>()
        .WaitAndRetry(5, retryAttempt => TimeSpan.FromSeconds(5),
            (exception, timeSpan, retryCount, context) =>
            {
                Console.WriteLine($"Retry {retryCount} failed: {exception.Message}. Waiting {timeSpan.TotalSeconds} seconds...");
            });

    policy.Execute(() =>
    {
        dbContext.Database.Migrate();
        Console.WriteLine("Database migrations applied successfully.");
    });
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowLocalhost3000");
app.MapControllers();


app.Run();

