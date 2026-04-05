FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["Domain/Domain.csproj", "Domain/"]
COPY ["Application/Application.csproj", "Application/"]
COPY ["Infrastructure/Infrastructure.csproj", "Infrastructure/"]
COPY ["API/API.csproj", "API/"]

RUN dotnet restore "API/API.csproj"

COPY . .
WORKDIR "/src/API"
RUN dotnet publish "API.csproj" -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

EXPOSE 8080

ENTRYPOINT ["dotnet", "API.dll"]