using Application.DTOs;
using Application.Requests;
using Domain.Entities;
using Domain.Exceptions;
using Domain.Interfaces;

namespace Application.Services;

public class AuthService
{
    private readonly IUserRepository _userRepository;
    private readonly ISessionRepository _sessionRepository;
    private readonly IJwtService _jwtService;

    public AuthService(IUserRepository userRepository, ISessionRepository sessionRepository, IJwtService jwtService)
    {
        _userRepository = userRepository;
        _sessionRepository = sessionRepository;
        _jwtService = jwtService;
    }

    public async Task<UserDto> SignupAsync(SignupRequest request)
    {
        var existing = await _userRepository.GetByEmailAsync(request.Email);
        if (existing is not null)
            throw new BadRequestException("An account with this email already exists.");

        var user = new User
        {
            Name = request.Name,
            Email = request.Email.ToLower(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            CreatedAt = DateTime.UtcNow
        };

        await _userRepository.CreateAsync(user);

        return new UserDto
        {
            Id = user.Id.ToString(),
            Name = user.Name,
            Email = user.Email,
            AvatarUrl = null,
            AccessToken = string.Empty,
            RefreshToken = string.Empty
        };
    }

    public async Task<UserDto> LoginAsync(LoginRequest request)
    {
        var user = await _userRepository.GetByEmailAsync(request.Email);
        if (user is null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            throw new UnauthorizedException("Invalid email or password.");

        await _sessionRepository.InvalidateAllUserSessionsAsync(user.Id);

        var refreshToken = _jwtService.GenerateRefreshToken();
        var session = new Session
        {
            UserId = user.Id,
            DeviceId = request.DeviceId,
            RefreshToken = refreshToken,
            IsActive = true,
            ExpiresAt = DateTime.UtcNow.AddDays(7),
            CreatedAt = DateTime.UtcNow
        };

        await _sessionRepository.CreateAsync(session);

        var accessToken = _jwtService.GenerateAccessToken(user.Id, user.Email);

        return new UserDto
        {
            Id = user.Id.ToString(),
            Name = user.Name,
            Email = user.Email,
            AvatarUrl = null,
            AccessToken = accessToken,
            RefreshToken = refreshToken
        };
    }

    public async Task<UserDto> RefreshAsync(RefreshRequest request)
    {
        var session = await _sessionRepository.GetByRefreshTokenAsync(request.RefreshToken);
        if (session is null || session.DeviceId != request.DeviceId)
            throw new UnauthorizedException("Invalid or expired refresh token.");

        var user = await _userRepository.GetByIdAsync(session.UserId);
        if (user is null)
            throw new UnauthorizedException("User not found.");

        var newRefreshToken = _jwtService.GenerateRefreshToken();
        session.RefreshToken = newRefreshToken;
        session.ExpiresAt = DateTime.UtcNow.AddDays(7);
        await _sessionRepository.UpdateAsync(session);

        var accessToken = _jwtService.GenerateAccessToken(user.Id, user.Email);

        return new UserDto
        {
            Id = user.Id.ToString(),
            Name = user.Name,
            Email = user.Email,
            AvatarUrl = null,
            AccessToken = accessToken,
            RefreshToken = newRefreshToken
        };
    }

    public async Task LogoutAsync(Guid userId, string deviceId)
    {
        await _sessionRepository.InvalidateSessionAsync(userId, deviceId);
    }
}
