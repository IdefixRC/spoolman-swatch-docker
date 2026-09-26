# syntax=docker/dockerfile:1

# Builds an upstream release of spoolman-filament-swatch, unmodified, and serves it with nginx.
# SWATCH_VERSION is an upstream release tag such as v1.16.0.
ARG SWATCH_VERSION

# The build output is plain static files, so the build stage runs once on the builder's own
# platform and only the nginx stage is per-architecture. Debian rather than Alpine: the lockfile's
# native binaries (esbuild, Tailwind's oxide engine) are glibc builds.
FROM --platform=$BUILDPLATFORM node:24-slim AS build
ARG SWATCH_VERSION
ADD --keep-git-dir=false https://github.com/Disane87/spoolman-filament-swatch.git#${SWATCH_VERSION} /app
WORKDIR /app
RUN npm ci && npm run build

FROM nginx:stable-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
