using Domain.Interfaces;

namespace Application.Services;

public class DashboardService
{
    private readonly ITransactionRepository _transactionRepository;

    public DashboardService(ITransactionRepository transactionRepository)
    {
        _transactionRepository = transactionRepository;
    }

    public async Task<object> GetSummaryAsync(Guid userId)
    {
        var allTransactions = await _transactionRepository.GetByUserIdAsync(userId);

        var totalIncome = allTransactions.Where(t => t.Type == "income").Sum(t => t.Amount);
        var totalExpense = allTransactions.Where(t => t.Type == "expense").Sum(t => t.Amount);
        var totalBalance = totalIncome - totalExpense;

        var today = DateTime.UtcNow.Date;
        var weekStart = today.AddDays(-(int)today.DayOfWeek);
        var weekDays = Enumerable.Range(0, 7).Select(i => weekStart.AddDays(i)).ToList();

        var weeklyData = weekDays.Select(day =>
        {
            var dayTransactions = allTransactions.Where(t => t.Date.Date == day);
            return new
            {
                day = day.ToString("ddd"),
                income = dayTransactions.Where(t => t.Type == "income").Sum(t => t.Amount),
                expense = dayTransactions.Where(t => t.Type == "expense").Sum(t => t.Amount)
            };
        }).ToList();

        var categoryBreakdown = allTransactions
            .Where(t => t.Type == "expense")
            .GroupBy(t => t.Category)
            .ToDictionary(g => g.Key, g => g.Sum(t => t.Amount));

        var recentTransactions = (await _transactionRepository.GetRecentAsync(userId, 10))
            .Select(t => new
            {
                id = t.Id.ToString(),
                category = t.Category,
                amount = t.Amount,
                type = t.Type,
                date = t.Date,
                note = t.Note
            }).ToList();

        return new
        {
            total_balance = totalBalance,
            total_income = totalIncome,
            total_expense = totalExpense,
            weekly_data = weeklyData,
            category_breakdown = categoryBreakdown,
            recent_transactions = recentTransactions
        };
    }
}
