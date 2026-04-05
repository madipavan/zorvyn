using System.ComponentModel.DataAnnotations;

namespace Application.Requests;

public class CreateGoalRequest
{
    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string Type { get; set; } = string.Empty;

    [Required]
    [Range(0.01, double.MaxValue)]
    public decimal TargetAmount { get; set; }

    public decimal CurrentAmount { get; set; } = 0;

    [Required]
    public DateTime StartDate { get; set; }

    public DateTime? EndDate { get; set; }
}
