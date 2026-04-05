using Domain.Interfaces;

namespace Application.Services;

public class InsightService
{
    private readonly ITransactionRepository _transactionRepository;

    public InsightService(ITransactionRepository transactionRepository)
    {
        _transactionRepository = transactionRepository;
    }

    public async Task<object> GetInsightsAsync(Guid userId)
    {
        var allTransactions = await _transactionRepository.GetByUserIdAsync(userId);

        var categoryTotals = allTransactions
            .Where(t => t.Type == "expense")
            .GroupBy(t => t.Category)
            .ToDictionary(g => g.Key, g => g.Sum(t => t.Amount));

        var monthlyTrend = allTransactions
            .GroupBy(t => new { t.Date.Year, t.Date.Month })
            .OrderBy(g => g.Key.Year).ThenBy(g => g.Key.Month)
            .Select(g => new
            {
                month = new DateTime(g.Key.Year, g.Key.Month, 1).ToString("MMM yyyy"),
                income = g.Where(t => t.Type == "income").Sum(t => t.Amount),
                expense = g.Where(t => t.Type == "expense").Sum(t => t.Amount)
            }).ToList();

        var today = DateTime.UtcNow.Date;
        var thisWeekStart = today.AddDays(-(int)today.DayOfWeek);
        var lastWeekStart = thisWeekStart.AddDays(-7);

        var thisWeekExpense = allTransactions
            .Where(t => t.Type == "expense" && t.Date.Date >= thisWeekStart && t.Date.Date <= today)
            .Sum(t => t.Amount);

        var lastWeekExpense = allTransactions
            .Where(t => t.Type == "expense" && t.Date.Date >= lastWeekStart && t.Date.Date < thisWeekStart)
            .Sum(t => t.Amount);

        var weekComparison = new
        {
            this_week = thisWeekExpense,
            last_week = lastWeekExpense,
            change_percent = lastWeekExpense == 0 ? 0 : Math.Round((thisWeekExpense - lastWeekExpense) / lastWeekExpense * 100, 2)
        };

        var topSpendingCategory = categoryTotals.Count > 0
            ? categoryTotals.OrderByDescending(kv => kv.Value).First().Key
            : null;

        var expenseTransactions = allTransactions.Where(t => t.Type == "expense").ToList();
        var distinctDays = expenseTransactions.Select(t => t.Date.Date).Distinct().Count();
        var averageDailyExpense = distinctDays > 0
            ? Math.Round(expenseTransactions.Sum(t => t.Amount) / distinctDays, 2)
            : 0;

        return new
        {
            category_totals = categoryTotals,
            monthly_trend = monthlyTrend,
            week_comparison = weekComparison,
            top_spending_category = topSpendingCategory,
            average_daily_expense = averageDailyExpense
        };
    }
}
