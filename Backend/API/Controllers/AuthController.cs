using Application.Requests;
using Application.Responses;
using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly AuthService _authService;

    public AuthController(AuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("signup")]
    public async Task<IActionResult> Signup([FromBody] SignupRequest request)
    {
        var result = await _authService.SignupAsync(request);
        return Ok(ApiResponse<object>.Ok(new { result.Id, result.Name, result.Email }, "Account created successfully."));
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var result = await _authService.LoginAsync(request);
        return Ok(ApiResponse<object>.Ok(new
        {
            id = result.Id,
            name = result.Name,
            email = result.Email,
            avatar_url = result.AvatarUrl,
            access_token = result.AccessToken,
            refresh_token = result.RefreshToken
        }, "Login successful."));
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh([FromBody] RefreshRequest request)
    {
        var result = await _authService.RefreshAsync(request);
        return Ok(ApiResponse<object>.Ok(new
        {
            id = result.Id,
            name = result.Name,
            email = result.Email,
            avatar_url = result.AvatarUrl,
            access_token = result.AccessToken,
            refresh_token = result.RefreshToken
        }, "Token refreshed successfully."));
    }

    [Authorize]
    [HttpPost("logout")]
    public async Task<IActionResult> Logout()
    {
        var userId = (Guid)HttpContext.Items["UserId"]!;
        var deviceId = (string)HttpContext.Items["DeviceId"]!;

        await _authService.LogoutAsync(userId, deviceId);
        return Ok(ApiResponse<object>.Ok(new { }, "Logged out successfully."));
    }
}
