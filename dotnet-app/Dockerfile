FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
# mcr.microsoft.com/dotnet/sdk:8.0 -> runtime do .NET 8.0

WORKDIR /dotnet-webapp

# Copy everything
COPY . ./
# Restore as distinct layers
RUN dotnet restore
# Build and publish a release
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /dotnet-webapp
COPY --from=build-env /dotnet-webapp/out .
ENTRYPOINT ["dotnet", "dotnet-webapp.dll"]