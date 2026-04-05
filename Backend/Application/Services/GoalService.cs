using Application.DTOs;
using Application.Requests;
using Domain.Entities;
using Domain.Exceptions;
using Domain.Interfaces;

namespace Application.Services;

public class GoalService
{
    private readonly IGoalRepository _goalRepository;

    public GoalService(IGoalRepository goalRepository)
    {
        _goalRepository = goalRepository;
    }

    public async Task<List<GoalDto>> GetAllAsync(Guid userId)
    {
        var goals = await _goalRepository.GetByUserIdAsync(userId);
        return goals.Select(MapToDto).ToList();
    }

    public async Task<GoalDto> CreateAsync(Guid userId, CreateGoalRequest request)
    {
        var goal = new Goal
        {
            UserId = userId,
            Title = request.Title,
            Type = request.Type,
            TargetAmount = request.TargetAmount,
            CurrentAmount = request.CurrentAmount,
            StartDate = request.StartDate.ToUniversalTime(),
            EndDate = request.EndDate?.ToUniversalTime(),
            IsActive = true,
            StreakDays = 0
        };

        var created = await _goalRepository.CreateAsync(goal);
        return MapToDto(created);
    }

    public async Task<GoalDto> UpdateAsync(Guid id, Guid userId, UpdateGoalRequest request)
    {
        var goal = await _goalRepository.GetByIdAsync(id, userId);
        if (goal is null)
            throw new NotFoundException("Goal not found.");

        goal.Title = request.Title;
        goal.Type = request.Type;
        goal.TargetAmount = request.TargetAmount;
        goal.CurrentAmount = request.CurrentAmount;
        goal.StartDate = request.StartDate.ToUniversalTime();
        goal.EndDate = request.EndDate?.ToUniversalTime();
        goal.IsActive = request.IsActive;
        goal.StreakDays = request.StreakDays;

        var updated = await _goalRepository.UpdateAsync(goal);
        return MapToDto(updated);
    }

    public async Task DeleteAsync(Guid id, Guid userId)
    {
        var goal = await _goalRepository.GetByIdAsync(id, userId);
        if (goal is null)
            throw new NotFoundException("Goal not found.");

        await _goalRepository.DeleteAsync(goal);
    }

    private static GoalDto MapToDto(Goal g) => new()
    {
        Id = g.Id.ToString(),
        Title = g.Title,
        Type = g.Type,
        TargetAmount = g.TargetAmount,
        CurrentAmount = g.CurrentAmount,
        StartDate = g.StartDate,
        EndDate = g.EndDate,
        IsActive = g.IsActive,
        StreakDays = g.StreakDays
    };
}
