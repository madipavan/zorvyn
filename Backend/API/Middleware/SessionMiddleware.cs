using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text.Json;
using Application.Responses;
using Domain.Interfaces;

namespace API.Middleware;

public class SessionMiddleware
{
    private readonly RequestDelegate _next;

    private static readonly string[] PublicPaths =
    {
        "/api/auth/signup",
        "/api/auth/login",
        "/api/auth/refresh",
        "/swagger",
        "/health"
    };

    public SessionMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, ISessionRepository sessionRepository)
    {
        var path = context.Request.Path.Value?.ToLower() ?? string.Empty;

        if (PublicPaths.Any(p => path.StartsWith(p)))
        {
            await _next(context);
            return;
        }

        if (!context.User.Identity?.IsAuthenticated ?? true)
        {
            await WriteUnauthorizedAsync(context, "Authentication required.");
            return;
        }

        var userIdClaim = context.User.FindFirst(JwtRegisteredClaimNames.Sub)
            ?? context.User.FindFirst(ClaimTypes.NameIdentifier);

        if (userIdClaim is null || !Guid.TryParse(userIdClaim.Value, out var userId))
        {
            await WriteUnauthorizedAsync(context, "Invalid token claims.");
            return;
        }

        var deviceId = context.Request.Headers["X-Device-Id"].FirstOrDefault();
        if (string.IsNullOrWhiteSpace(deviceId))
        {
            await WriteUnauthorizedAsync(context, "Device ID header is required.");
            return;
        }

        var session = await sessionRepository.GetActiveSessionAsync(userId, deviceId);
        if (session is null)
        {
            await WriteUnauthorizedAsync(context, "Session expired or invalid. Please log in again.");
            return;
        }

        context.Items["UserId"] = userId;
        context.Items["DeviceId"] = deviceId;

        await _next(context);
    }

    private static async Task WriteUnauthorizedAsync(HttpContext context, string message)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = 401;

        var response = ApiErrorResponse.From(message);
        var json = JsonSerializer.Serialize(response, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
        await context.Response.WriteAsync(json);
    }
}
