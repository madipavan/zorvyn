using System.ComponentModel.DataAnnotations;

namespace Application.Requests;

public class LoginRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string Password { get; set; } = string.Empty;

    [Required]
    public string DeviceId { get; set; } = string.Empty;
}
