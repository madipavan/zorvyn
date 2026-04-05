using Application.Services;
using Microsoft.Extensions.DependencyInjection;

namespace Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<AuthService>();
        services.AddScoped<TransactionService>();
        services.AddScoped<GoalService>();
        services.AddScoped<DashboardService>();
        services.AddScoped<InsightService>();

        return services;
    }
}
