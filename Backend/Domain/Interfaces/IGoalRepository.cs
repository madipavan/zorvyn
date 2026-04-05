using Domain.Entities;

namespace Domain.Interfaces;

public interface IGoalRepository
{
    Task<List<Goal>> GetByUserIdAsync(Guid userId);
    Task<Goal?> GetByIdAsync(Guid id, Guid userId);
    Task<Goal> CreateAsync(Goal goal);
    Task<Goal> UpdateAsync(Goal goal);
    Task DeleteAsync(Goal goal);
}
