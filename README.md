# Minecraft Velocity Proxy

## Third Party Software
### [papermc.io](https://docs.papermc.io/)

### [Velocity](https://docs.papermc.io/velocity/getting-started)

---

If you want to use a specific version of Velocity, you can set the `VERSION` and `BUILD` environment variables. If you don't set these variables, the latest version of Velocity will be used.

Note: If you specify `BUILD`, you also need to specify `VERSION` or the build will be ignored. If you specify `VERSION`, the latest build will be used along with the version you specified. If you specify both `VERSION` and `BUILD`, both will be used.

It's a good idea to create a volume for the `/velocity` directory so that it can stay the same between container restarts. Alternatively, you can connect the `/velocity` directory to your computer. Also, make sure you publish port 25577.

To use this image, you have to change the `velocity.toml` file. To do this, make a local config folder and connect it to the container at `/config`. The container will copy the default config files into the `/config` directory if it's empty. Then, you can change the config files as you need. If you don't want to use the default config files, you can create your own and connect them to the `/config` directory.

If you're using Velocity and the Minecraft server on the same machine, you can set the server in the `velocity.toml` file as `server:25565` or whatever you call the app in the `docker-compose.yml` file.


## Example `docker-compose.yml`
```yaml
version: '3.9'
services:
  app:
    image: ghcr.io/redactdigital/docker-minecraft-proxy:latest
    container_name: minecraft-proxy
    restart: unless-stopped
    ports:
      - 25577:25577
    volumes:
      - minecraft-velocity:/velocity
      - ./velocity-config:/config
    environment:
      VERSION: '' # Optional, defaults to latest
      BUILD: '' # Optional, defaults to latest

  server:
    image: ghcr.io/redactdigital/docker-minecraft-server:latest
    container_name: minecraft
    restart: unless-stopped
    volumes:
      - minecraft-server:/minecraft
      - ./minecraft-config:/config
      - ./plugins:/minecraft/plugins
      - ./custom-world:/minecraft/world
      - ./custom-world-nether:/minecraft/world_nether
      - ./custom-world-the-end:/minecraft/world_the_end
    environment:
      EULA: 'true'
      VERSION: '' # Optional, defaults to latest
      BUILD: '' # Optional, defaults to latest

volumes:
  minecraft-server:
  minecraft-velocity:
```

## Example `docker run` command
```bash
docker run -d \
  --name=minecraft-proxy \
  -p 25577:25577 \
  -v minecraft-velocity:/velocity \
  -v ./velocity.toml:/velocity/velocity.toml \
  -e VERSION='' \
  -e BUILD='' \
  --restart unless-stopped \
  ghcr.io/redactdigital/docker-minecraft-proxy:latest

docker run -d \
  --name=minecraft \
  -v minecraft-server:/minecraft \
  -v ./minecraft-config:/config \
  -v ./plugins:/minecraft/plugins \
  -v ./custom-world:/minecraft/world \
  -v ./custom-world-nether:/minecraft/world_nether \
  -v ./custom-world-the-end:/minecraft/world_the_end \
  -e EULA='true' \
  -e VERSION='' \
  -e BUILD='' \
  --restart unless-stopped \
  ghcr.io/redactdigital/docker-minecraft-server:latest
```
