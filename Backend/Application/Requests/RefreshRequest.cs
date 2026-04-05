using System.ComponentModel.DataAnnotations;

namespace Application.Requests;

public class RefreshRequest
{
    [Required]
    public string RefreshToken { get; set; } = string.Empty;

    [Required]
    public string DeviceId { get; set; } = string.Empty;
}
