using Application.DTOs;
using Application.Requests;
using Domain.Entities;
using Domain.Exceptions;
using Domain.Interfaces;

namespace Application.Services;

public class TransactionService
{
    private readonly ITransactionRepository _transactionRepository;

    public TransactionService(ITransactionRepository transactionRepository)
    {
        _transactionRepository = transactionRepository;
    }

    public async Task<List<TransactionDto>> GetAllAsync(Guid userId)
    {
        var transactions = await _transactionRepository.GetByUserIdAsync(userId);
        return transactions.Select(MapToDto).ToList();
    }

    public async Task<TransactionDto> CreateAsync(Guid userId, CreateTransactionRequest request)
    {
        var transaction = new Transaction
        {
            UserId = userId,
            Amount = request.Amount,
            Type = request.Type.ToLower(),
            Category = request.Category,
            Date = request.Date.ToUniversalTime(),
            Note = request.Note
        };

        var created = await _transactionRepository.CreateAsync(transaction);
        return MapToDto(created);
    }

    public async Task<TransactionDto> UpdateAsync(Guid id, Guid userId, UpdateTransactionRequest request)
    {
        var transaction = await _transactionRepository.GetByIdAsync(id, userId);
        if (transaction is null)
            throw new NotFoundException("Transaction not found.");

        transaction.Amount = request.Amount;
        transaction.Type = request.Type.ToLower();
        transaction.Category = request.Category;
        transaction.Date = request.Date.ToUniversalTime();
        transaction.Note = request.Note;

        var updated = await _transactionRepository.UpdateAsync(transaction);
        return MapToDto(updated);
    }

    public async Task DeleteAsync(Guid id, Guid userId)
    {
        var transaction = await _transactionRepository.GetByIdAsync(id, userId);
        if (transaction is null)
            throw new NotFoundException("Transaction not found.");

        await _transactionRepository.DeleteAsync(transaction);
    }

    public async Task<Dictionary<string, decimal>> GetCategorySummaryAsync(Guid userId)
    {
        var transactions = await _transactionRepository.GetByUserIdAsync(userId);
        return transactions
            .Where(t => t.Type == "expense")
            .GroupBy(t => t.Category)
            .ToDictionary(g => g.Key, g => g.Sum(t => t.Amount));
    }

    private static TransactionDto MapToDto(Transaction t) => new()
    {
        Id = t.Id.ToString(),
        Amount = t.Amount,
        Type = t.Type,
        Category = t.Category,
        Date = t.Date,
        Note = t.Note
    };
}
