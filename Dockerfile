# https://learn.microsoft.com/en-us/dotnet/core/deploying/native-aot/?tabs=net8plus%2Clinux-alpine

# Test command
# sudo docker container rm --force teste123098; sudo docker build -t teste123098 -f Dockerfile . && sudo docker run --name teste123098 --interactive -p 127.1.2.3:80:80 teste123098
#
#


# Download the SDK image from microsoft
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build-image

# Install the C build environment
RUN apk add clang build-base zlib-dev

# Copy the files from your project (every project except for the tests)
WORKDIR /app

# COMPILATION PHASE 1
# Copy only the essential files to restore
# That way this step will be cached unless those files are changed
COPY ./Main/Main.csproj /app/Main/Main.csproj
COPY ./Comum/Comum.csproj /app/Comum/Comum.csproj
RUN dotnet restore Main --runtime linux-musl-x64

# COMPILATION PHASE 2
# Copy all files and compile
COPY ./Main.sln /app
COPY ./Main /app/Main
COPY ./Comum /app/Comum
RUN dotnet publish Main --no-restore -c Release -o /app/publish --runtime linux-musl-x64

# Download the RUNTIME image from microsoft
FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-alpine AS runtime-image

# Configure locale and timezone
RUN \
  apk add --no-cache --update musl musl-utils musl-locales tzdata && \
  echo "America/Sao_Paulo" >  /etc/timezone && \
  ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
  export TZ="America/Sao_Paulo" && \
  export LANG="pt_BR.UTF-8" && \
  export LC_ALL="pt_BR.UTF-8" && \
  export LANGUAGE="pt_BR.UTF-8"

# Install the trusted certificates at Deployment/ca-certificates
RUN mkdir -p /usr/local/share/ca-certificates
COPY Deployment/ca-certificates/*.crt /usr/local/share/ca-certificates
RUN cat /usr/local/share/ca-certificates/*.crt >> /etc/ssl/certs/ca-certificates.crt

# Set runtime environment
ENV DOTNET_URLS="http://*:80"
ENV DOTNET_SYSTEM_NET_DISABLEIPV6=1
ENV DOTNET_ENVIRONMENT="Production"

# Expose the port
EXPOSE 80

WORKDIR /app
COPY --from=build-image /app/publish .

#USER nobody

ENTRYPOINT ["./Main"]