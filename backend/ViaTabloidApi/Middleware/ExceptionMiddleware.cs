using Microsoft.AspNetCore.Http;
using System.Net;
using System.Text.Json;
using ViaTabloidApi.Error;

namespace ViaTabloidApi.Middleware
{
    public class ExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly IWebHostEnvironment _env;

        public ExceptionMiddleware(RequestDelegate next, IWebHostEnvironment env)
        {
            _next = next;
            _env = env;
        }

        public async Task InvokeAsync(HttpContext context, ILogger<ExceptionMiddleware> logger)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                await HandleExceptionAsync(context, ex, _env);
                logger.LogError(ex, "An unhandled exception occurred.");
            }
        }
        private static Task HandleExceptionAsync(HttpContext context, Exception exception, IWebHostEnvironment env)
        {
            context.Response.ContentType = "application/json";
            var statusCode = exception switch
            {
                StoryNotFoundException => (int)HttpStatusCode.NotFound,
                _ => (int)HttpStatusCode.InternalServerError
            };
            context.Response.StatusCode = statusCode;

            var response = new
            {
                StatusCode = statusCode,
                Message = env.IsDevelopment() ? exception.Message : "An error occurred.",
                Details = env.IsDevelopment() ? exception.GetType().Name : null
            };

            return context.Response.WriteAsync(JsonSerializer.Serialize(response));
        }
    }
}