using System.ComponentModel.DataAnnotations;

namespace Application.Requests;

public class UpdateGoalRequest
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

    [Range(0, double.MaxValue)]
    public decimal CurrentAmount { get; set; }

    [Required]
    public DateTime StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public bool IsActive { get; set; }

    [Range(0, int.MaxValue)]
    public int StreakDays { get; set; }
}
