using Application.Requests;
using Application.Responses;
using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

[ApiController]
[Route("api/transactions")]
[Authorize]
public class TransactionsController : ControllerBase
{
    private readonly TransactionService _transactionService;

    public TransactionsController(TransactionService transactionService)
    {
        _transactionService = transactionService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var userId = (Guid)HttpContext.Items["UserId"]!;
        var result = await _transactionService.GetAllAsync(userId);
        return Ok(ApiResponse<object>.Ok(result, "Transactions retrieved."));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateTransactionRequest request)
    {
        var userId = (Guid)HttpContext.Items["UserId"]!;
        var result = await _transactionService.CreateAsync(userId, request);
        return Ok(ApiResponse<object>.Ok(result, "Transaction created."));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateTransactionRequest request)
    {
        var userId = (Guid)HttpContext.Items["UserId"]!;
        var result = await _transactionService.UpdateAsync(id, userId, request);
        return Ok(ApiResponse<object>.Ok(result, "Transaction updated."));
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var userId = (Guid)HttpContext.Items["UserId"]!;
        await _transactionService.DeleteAsync(id, userId);
        return Ok(ApiResponse<object>.Ok(new { }, "Transaction deleted."));
    }

    [HttpGet("summary/categories")]
    public async Task<IActionResult> GetCategorySummary()
    {
        var userId = (Guid)HttpContext.Items["UserId"]!;
        var result = await _transactionService.GetCategorySummaryAsync(userId);
        return Ok(ApiResponse<object>.Ok(result, "Category summary retrieved."));
    }
}
