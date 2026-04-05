using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class SessionRepository : ISessionRepository
{
    private readonly AppDbContext _context;

    public SessionRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<Session?> GetActiveSessionAsync(Guid userId, string deviceId)
    {
        return await _context.Sessions
            .FirstOrDefaultAsync(s => s.UserId == userId && s.DeviceId == deviceId && s.IsActive && s.ExpiresAt > DateTime.UtcNow);
    }

    public async Task<Session?> GetByRefreshTokenAsync(string refreshToken)
    {
        return await _context.Sessions
            .FirstOrDefaultAsync(s => s.RefreshToken == refreshToken && s.IsActive && s.ExpiresAt > DateTime.UtcNow);
    }

    public async Task InvalidateAllUserSessionsAsync(Guid userId)
    {
        await _context.Sessions
            .Where(s => s.UserId == userId && s.IsActive)
            .ExecuteUpdateAsync(s => s.SetProperty(x => x.IsActive, false));
    }

    public async Task InvalidateSessionAsync(Guid userId, string deviceId)
    {
        await _context.Sessions
            .Where(s => s.UserId == userId && s.DeviceId == deviceId && s.IsActive)
            .ExecuteUpdateAsync(s => s.SetProperty(x => x.IsActive, false));
    }

    public async Task CreateAsync(Session session)
    {
        _context.Sessions.Add(session);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(Session session)
    {
        _context.Sessions.Update(session);
        await _context.SaveChangesAsync();
    }
}
