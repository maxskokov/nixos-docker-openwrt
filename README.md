# nixos-docker-openwrt

[![build](https://github.com/maxskokov/nixos-docker-openwrt/actions/workflows/docker.yml/badge.svg)](https://github.com/maxskokov/nixos-docker-openwrt/actions/workflows/docker.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

OpenWrt 24.10 with a working LuCI web interface in a Docker container. The image boots procd as init so that ubus is available and LuCI renders live interface and traffic telemetry.

<img width="1914" height="1011" alt="LuCI running in the container" src="https://github.com/user-attachments/assets/a60cab28-f4ac-48ad-8c1a-a7e7a6969666" />

## Background

Running the official `openwrt/rootfs` image in a minimal container hits two issues.

LuCI crashed on page load with `left-hand side expression is null` in `runtime.uc`. Without procd, `ubus.call('system', 'board')` returns null and LuCI dereferenced the missing `boardinfo`. The upstream fix is merged in [openwrt/luci#8739](https://github.com/openwrt/luci/pull/8739) (closes [#8726](https://github.com/openwrt/luci/issues/8726)): a `?? {}` fallback so `boardinfo` is always an object.

Telemetry needs a live ubus. Running `uhttpd` directly serves the login page but exposes no system state. Booting `/sbin/init` starts procd and netifd, so interface stats and traffic graphs work.

This image pins OpenWrt 24.10 with LuCI and uses `/sbin/init` as the entrypoint.

## Usage

```bash
docker run -d -t \
  --name devops-router \
  --network host \
  --privileged \
  --restart always \
  maxskokov/nixos-openwrt-luci:24.10
```

With Compose:

```bash
docker compose up -d --build
```

Open http://localhost. Log in as `root` with an empty password.

## Privileged and host networking

procd and netifd manage interfaces over netlink, and ubus reads the host network stack for telemetry. Both require `--privileged` and `--network host`. This is a lab container. Do not expose it to an untrusted network. A hardened variant drops `--privileged` for the `NET_ADMIN` and `NET_RAW` capabilities at the cost of some telemetry.

## Build

```bash
docker build -t nixos-openwrt-luci:24.10 .
```

CI builds the image on every push and pull request and publishes tagged images to GHCR. See [.github/workflows/docker.yml](.github/workflows/docker.yml).

## Upstream

- [openwrt/luci#8739](https://github.com/openwrt/luci/pull/8739): fix LuCI crash on null board info in containers
- [openwrt/docker#205](https://github.com/openwrt/docker/pull/205): drop the dangling `/etc/resolv.conf` symlink that breaks `RUN` on older buildkit

## License

[MIT](LICENSE)
