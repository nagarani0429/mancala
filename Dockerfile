# The repo holds the full source inside project.zip (uploaded via GitHub web UI).
# Stage 1: unzip + build Angular
FROM node:22-alpine AS web
RUN apk add --no-cache unzip
WORKDIR /app
COPY project.zip .
RUN unzip -q project.zip -d src
WORKDIR /app/src/frontend
RUN npm install && npm run build

# Stage 2: build .NET API with the Angular build in wwwroot
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY --from=web /app/src/backend ./backend/
COPY --from=web /app/src/frontend/dist/mancala-frontend/browser ./backend/Mancala.Api/wwwroot/
RUN dotnet publish backend/Mancala.Api/Mancala.Api.csproj -c Release -o /app/publish

# Stage 3: run
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "Mancala.Api.dll"]
