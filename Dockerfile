# Use the official .NET SDK image for building the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env

# Define the working directory in the container
WORKDIR /dotnet-app

# Copy all files from the host to the container
COPY . ./

# Restore NuGet packages
RUN dotnet restore

# Build and publish the application in release mode
RUN dotnet publish -c Release -o out

# Use the official .NET runtime image for running the application
FROM mcr.microsoft.com/dotnet/aspnet:8.0

# Define the working directory in the container
WORKDIR /dotnet-app

# Copy the published output from the build image
COPY --from=build-env /dotnet-app/out .

# Set the entry point for the application
ENTRYPOINT ["dotnet", "dotnetapp.dll"]
