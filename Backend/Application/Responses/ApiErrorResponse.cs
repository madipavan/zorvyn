namespace Application.Responses;

public class ApiErrorResponse
{
    public bool Success => false;
    public string Message { get; set; } = string.Empty;
    public List<string> Errors { get; set; } = new();

    public static ApiErrorResponse From(string message, IEnumerable<string>? errors = null)
    {
        return new ApiErrorResponse
        {
            Message = message,
            Errors = errors?.ToList() ?? new List<string>()
        };
    }
}
