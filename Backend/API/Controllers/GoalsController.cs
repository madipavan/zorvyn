using Application.Requests;
using Application.Responses;
using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

[ApiController]
[Route("api/goals")]
[Authorize]
public class GoalsController : ControllerBase
{
    private readonly GoalService _goalService;

    public GoalsController(GoalService goalService)
    {
        _goalService = goalService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var userId = (Guid)HttpContext.Items["UserId"]!;
        var result = await _goalService.GetAllAsync(userId);
        return Ok(ApiResponse<object>.Ok(result, "Goals retrieved."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateGoalRequest request)
    {
        var userId = (Guid)HttpContext.Items["UserId"]!;
        var result = await _goalService.CreateAsync(userId, request);
        return Ok(ApiResponse<object>.Ok(result, "Goal created."));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateGoalRequest request)
    {
        var userId = (Guid)HttpContext.Items["UserId"]!;
        var result = await _goalService.UpdateAsync(id, userId, request);
        return Ok(ApiResponse<object>.Ok(result, "Goal updated."));
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var userId = (Guid)HttpContext.Items["UserId"]!;
        await _goalService.DeleteAsync(id, userId);
        return Ok(ApiResponse<object>.Ok(new { }, "Goal deleted."));
    }
}
