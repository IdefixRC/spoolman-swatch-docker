# spoolman-swatch-docker

A Docker image of [Spoolman Filament Swatch](https://github.com/Disane87/spoolman-filament-swatch), kept on the latest upstream release.

Upstream publishes the app only as a static site on GitHub Pages. This repo builds each upstream release unmodified, serves it with nginx, and publishes the image to GitHub Container Registry:

```
ghcr.io/idefixrc/spoolman-swatch-docker
```

| Tag | Meaning |
|---|---|
| `latest` | Newest upstream release |
| `1.16.0` | An exact upstream release |
| `1.16` | Newest patch of a minor release |

Images are built for `linux/amd64` and `linux/arm64`.

## How it stays current

A GitHub Actions workflow runs daily. It looks up the latest upstream release, and if that version is not published yet, builds it and pushes it with the tags above. Nothing is built when upstream has not released.

Every Monday the current release is rebuilt anyway, to pick up security fixes in the `nginx` and `node` base images. This republishes the same version tags with a new image, so an auto-updater restarts the container about once a week.

Pair it with [Watchtower](https://containrrr.dev/watchtower/) or a similar tool to pick up new `latest` images automatically.

## 1. Allow the swatch in Spoolman's CORS settings

The swatch runs entirely in the browser and calls the Spoolman API directly, so Spoolman has to allow the swatch's origin. Add this to Spoolman's environment and restart it:

```yaml
SPOOLMAN_CORS_ORIGIN: "http://<docker-host>:8090"
```

Use the full origin, with the scheme and port, exactly as it appears in the browser's address bar. Recent Spoolman versions compare origins exactly, so a bare hostname does not match. Separate several origins with commas and no spaces.

If the swatch is served over HTTPS, Spoolman must be too, or the browser blocks the calls as mixed content.

## 2. Run it

```yaml
services:
  swatch:
    image: ghcr.io/idefixrc/spoolman-swatch-docker:latest
    container_name: spoolman-swatch
    restart: unless-stopped
    ports:
      - "8090:80"
```

```sh
docker compose up -d
```

Open `http://<docker-host>:8090` and enter your Spoolman URL. Each browser remembers it separately. To preset it, open `http://<docker-host>:8090/?surl=<spoolman-url>` once.

To stay on one version, replace `latest` with a version tag such as `1.16.0`.

## Building locally

```sh
docker build --build-arg SWATCH_VERSION=v1.16.0 -t spoolman-swatch .
```

`SWATCH_VERSION` is an upstream release tag, including the `v`.

## License

The build files in this repo are MIT licensed. The app itself is [Spoolman Filament Swatch](https://github.com/Disane87/spoolman-filament-swatch) by Disane87, also under the MIT license.
