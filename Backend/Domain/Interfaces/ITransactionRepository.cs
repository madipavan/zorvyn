using Domain.Entities;

namespace Domain.Interfaces;

public interface ITransactionRepository
{
    Task<List<Transaction>> GetByUserIdAsync(Guid userId);
    Task<Transaction?> GetByIdAsync(Guid id, Guid userId);
    Task<Transaction> CreateAsync(Transaction transaction);
    Task<Transaction> UpdateAsync(Transaction transaction);
    Task DeleteAsync(Transaction transaction);
    Task<List<Transaction>> GetRecentAsync(Guid userId, int count);
    Task<List<Transaction>> GetByDateRangeAsync(Guid userId, DateTime from, DateTime to);
}
