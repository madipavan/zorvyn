using Application.Responses;
using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

[ApiController]
[Route("api/insights")]
[Authorize]
public class InsightsController : ControllerBase
{
    private readonly InsightService _insightService;

    public InsightsController(InsightService insightService)
    {
        _insightService = insightService;
    }

    [HttpGet]
    public async Task<IActionResult> GetInsights()
    {
        var userId = (Guid)HttpContext.Items["UserId"]!;
        var data = await _insightService.GetInsightsAsync(userId);
        return Ok(ApiResponse<object>.Ok(data, "Insights retrieved."));
    }
}
