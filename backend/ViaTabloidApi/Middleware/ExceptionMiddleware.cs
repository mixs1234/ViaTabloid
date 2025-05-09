using Microsoft.AspNetCore.Http;
using System.Net;
using System.Text.Json;
using ViaTabloidApi.Error;

namespace ViaTabloidApi.Middleware
{
    /// <summary>
    /// Middleware for handling exceptions and formatting error responses.
    /// </summary>
    public class ExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly IWebHostEnvironment _env;

        /// <summary>
        /// Initializes a new instance of the <see cref="ExceptionMiddleware"/> class.
        /// </summary>
        /// <param name="next">The next middleware in the pipeline.</param>
        /// <param name="env">The hosting environment.</param>
        public ExceptionMiddleware(RequestDelegate next, IWebHostEnvironment env)
        {
            _next = next;
            _env = env;
        }

        /// <summary>
        /// Invokes the middleware to handle the HTTP request and catch exceptions.
        /// </summary>
        /// <param name="context">The HTTP context of the current request.</param>
        /// <param name="logger">The logger to log exception details.</param>
        /// <returns>A task that represents the asynchronous operation.</returns>
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