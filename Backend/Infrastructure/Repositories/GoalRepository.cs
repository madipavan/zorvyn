using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class GoalRepository : IGoalRepository
{
    private readonly AppDbContext _context;

    public GoalRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<Goal>> GetByUserIdAsync(Guid userId)
    {
        return await _context.Goals
            .Where(g => g.UserId == userId)
            .OrderByDescending(g => g.StartDate)
            .ToListAsync();
    }

    public async Task<Goal?> GetByIdAsync(Guid id, Guid userId)
    {
        return await _context.Goals
            .FirstOrDefaultAsync(g => g.Id == id && g.UserId == userId);
    }

    public async Task<Goal> CreateAsync(Goal goal)
    {
        _context.Goals.Add(goal);
        await _context.SaveChangesAsync();
        return goal;
    }

    public async Task<Goal> UpdateAsync(Goal goal)
    {
        _context.Goals.Update(goal);
        await _context.SaveChangesAsync();
        return goal;
    }

    public async Task DeleteAsync(Goal goal)
    {
        _context.Goals.Remove(goal);
        await _context.SaveChangesAsync();
    }
}
