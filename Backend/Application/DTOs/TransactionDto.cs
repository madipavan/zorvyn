namespace Application.DTOs;

public class TransactionDto
{
    public string Id { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string Type { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public DateTime Date { get; set; }
    public string? Note { get; set; }
}
