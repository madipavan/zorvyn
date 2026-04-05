using System.Security.Claims;

namespace Domain.Interfaces;

public interface IJwtService
{
    string GenerateAccessToken(Guid userId, string email);
    string GenerateRefreshToken();
    ClaimsPrincipal? ValidateToken(string token);
}
