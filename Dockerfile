# syntax=docker/dockerfile:1

# Builds an upstream release of spoolman-filament-swatch, unmodified, and serves it with nginx.
# SWATCH_VERSION is a release tag such as v1.16.0; compose passes it in from .env.
ARG SWATCH_VERSION

# Debian rather than Alpine for the build: the lockfile's native binaries (esbuild, Tailwind's
# oxide engine) are glibc builds.
FROM node:24-slim AS build
ARG SWATCH_VERSION
ADD --keep-git-dir=false https://github.com/Disane87/spoolman-filament-swatch.git#${SWATCH_VERSION} /app
WORKDIR /app
RUN npm ci && npm run build

FROM nginx:stable-alpine
ARG SWATCH_VERSION
LABEL org.opencontainers.image.source="https://github.com/Disane87/spoolman-filament-swatch" \
      org.opencontainers.image.version="${SWATCH_VERSION}"
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
