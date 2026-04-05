using Domain.Entities;

namespace Domain.Interfaces;

public interface ISessionRepository
{
    Task<Session?> GetActiveSessionAsync(Guid userId, string deviceId);
    Task<Session?> GetByRefreshTokenAsync(string refreshToken);
    Task InvalidateAllUserSessionsAsync(Guid userId);
    Task InvalidateSessionAsync(Guid userId, string deviceId);
    Task CreateAsync(Session session);
    Task UpdateAsync(Session session);
}
