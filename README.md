# Example DotNet with Docker+Alpine+Aot

This project is an example of how to run your dotnet project inside a container image with the most advanced techniques:

| Feature       |Meaning             |Result                         | Official
|---------------|--------------------|-------------------------------|----------
| AOT           | Compiled as binary | 3x smaller + faster execution | YES
| Alpine Images | Smaller Images     | 2x smaller                    | YES
| Restore Cache |                    | Faster compilation            | YES

**There are no tricks or hacks here**. 

All those features are well documented on Microsoft, but are fragmented. 

The objective of this project is only to assemble them in one integrated example.


# Command history

### Crating project
```
dotnet new sln --output Main
dotnet new gitignore
dotnet new xunit --name Tests
dotnet sln add Tests
dotnet new webapiaot --name Main
dotnet sln add Main
```

### Publish locally
```
dotnet publish -o publish
```

### Build test container and run
```
sudo docker container rm --force teste123098; \
sudo docker build -t teste123098 -f Dockerfile . && \
x2() { sleep 2; xdg-open http://127.1.2.3:80; }; x2 & \
sudo docker run --name teste123098 --interactive -p 127.1.2.3:80:80 teste123098 
```

### Cleanup 
```
sudo docker container rm --force teste123098
sudo docker image rm --force teste123098 
```


# Results

```
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
teste        latest    553574ccfed0   51 seconds ago   32.2MB <- alpine/aot dotnet Dockerfile 
teste        latest    61fde56b7952   42 seconds ago   129MB  <-     alpine dotnet Dockerfile
<none>       <none>    b0da634f1567   8 minutes ago    239MB  <-   standard dotnet Dockerfile (debian based)
```

