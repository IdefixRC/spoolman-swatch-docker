# spoolman-swatch-docker

Self-host [Spoolman Filament Swatch](https://github.com/Disane87/spoolman-filament-swatch) on your own Docker host, kept on the latest upstream release.

Upstream publishes the app only as a static site on GitHub Pages. This repo builds a release tag unmodified and serves it with nginx. A small script checks for new releases and rebuilds.

## Requirements

- Docker with the Compose plugin (v2.17 or newer)
- `curl`
- A running [Spoolman](https://github.com/Donkie/Spoolman) instance the browser can reach

## 1. Allow the swatch in Spoolman's CORS settings

The swatch runs entirely in the browser and calls the Spoolman API directly, so Spoolman has to allow the swatch's origin. Add this to Spoolman's environment and restart it:

```yaml
SPOOLMAN_CORS_ORIGIN: "http://<docker-host>:8090"
```

Use the full origin, with the scheme and port, exactly as it appears in the browser's address bar. Recent Spoolman versions compare origins exactly, so a bare hostname does not match. Separate several origins with commas and no spaces.

If the swatch is served over HTTPS, Spoolman must be too, or the browser blocks the calls as mixed content.

## 2. Deploy

```sh
git clone https://github.com/IdefixRC/spoolman-swatch-docker.git /opt/spoolman-swatch
cd /opt/spoolman-swatch
./update.sh
```

`update.sh` creates `.env` from `.env.example`, looks up the latest release, builds it and starts the container. Change `SWATCH_PORT` in `.env` to use a port other than 8090.

Open `http://<docker-host>:8090` and enter your Spoolman URL. Each browser remembers it separately. To preset it, open `http://<docker-host>:8090/?surl=<spoolman-url>` once.

## 3. Keep it updated

Run `update.sh` daily from cron:

```sh
(crontab -l 2>/dev/null; echo "0 4 * * * /opt/spoolman-swatch/update.sh >> /var/log/spoolman-swatch.log 2>&1") | crontab -
```

It follows published releases, not the `main` branch. If a build fails, the running container and `.env` are left as they were.

Every build also pulls fresh `node` and `nginx` base images.

## Roll back

Set `SWATCH_VERSION` in `.env` to an earlier tag and run:

```sh
docker compose up -d --build
```

`update.sh` moves it forward again on its next run, so disable the cron job first if you want to stay on the old version.
