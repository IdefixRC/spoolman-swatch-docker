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

The swatch runs entirely in the browser and calls the Spoolman API directly, so Spoolman has to allow the swatch's origin. Add this to the Spoolman service in its compose file and restart it:

```yaml
    environment:
      - SPOOLMAN_CORS_ORIGIN=http://<docker-host>:8090
```

Use the swatch's origin, not Spoolman's: the full address you open the swatch at, with the scheme and port, exactly as it appears in the browser's address bar. Behind a reverse proxy that is something like `https://swatch.example.com`. Spoolman compares origins exactly, so a bare hostname does not match, whatever other guides say. Separate several origins with commas and no spaces.

In this list form, don't quote the value on its own. `- SPOOLMAN_CORS_ORIGIN="http://..."` passes the quote characters to Spoolman and nothing matches.

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
    environment:
      # true: open the app directly instead of the landing page
      - DIRECT_APP_PAGE=false
```

```sh
docker compose up -d
```

Open `http://<docker-host>:8090` and enter your Spoolman URL. Each browser remembers it separately. To preset it, open `http://<docker-host>:8090/?surl=<spoolman-url>` once.

To stay on one version, replace `latest` with a version tag such as `1.16.0`.

## Options

| Variable | Default | Effect |
|---|---|---|
| `DIRECT_APP_PAGE` | `false` | `true` redirects `/` straight to the app, skipping the landing page. Query parameters such as `?surl=` are kept. |

The redirect happens only when `/` is loaded from the server. Inside the app, links that point back to the landing page still show it.

## Building locally

```sh
docker build --build-arg SWATCH_VERSION=v1.16.0 -t spoolman-swatch .
```

`SWATCH_VERSION` is an upstream release tag, including the `v`.

## License

The build files in this repo are MIT licensed. The app itself is [Spoolman Filament Swatch](https://github.com/Disane87/spoolman-filament-swatch) by Disane87, also under the MIT license.
