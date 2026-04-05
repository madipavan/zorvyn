using Application.Responses;
using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

[ApiController]
[Route("api/dashboard")]
[Authorize]
public class DashboardController : ControllerBase
{
    private readonly DashboardService _dashboardService;

    public DashboardController(DashboardService dashboardService)
    {
        _dashboardService = dashboardService;
    }

    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary()
    {
        var userId = (Guid)HttpContext.Items["UserId"]!;
        var data = await _dashboardService.GetSummaryAsync(userId);
        return Ok(ApiResponse<object>.Ok(data, "Dashboard summary retrieved."));
    }
}
