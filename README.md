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
  ghcr.io/maxskokov/nixos-docker-openwrt:24.10
```

`ghcr.io/maxskokov/nixos-docker-openwrt` is the image published by CI on every push to `main`. The Docker Hub tag `maxskokov/nixos-openwrt-luci:24.10` is an older manual release and is not updated by the pipeline.

With Compose:

```bash
docker compose up -d --build
```

Open http://localhost. Log in as `root` with an empty password.

## Privileged and host networking

procd and netifd manage interfaces over netlink, and ubus reads the host network stack for telemetry. Both require `--privileged` and `--network host`. This is a lab container. Do not expose it to an untrusted network. `docker-compose.yml` includes a commented capability-based block (`NET_ADMIN`, `NET_RAW`) as an untested starting point for dropping `--privileged`; procd and netifd may need more than that, so treat it as a direction, not a drop-in.

## NixOS

The flake exposes a NixOS module that runs the container declaratively through `virtualisation.oci-containers`, so the host never runs an imperative `docker run`.

```nix
{
  inputs.openwrt-router.url = "github:maxskokov/nixos-docker-openwrt";

  outputs = { nixpkgs, openwrt-router, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        openwrt-router.nixosModules.default
        { services.openwrt-router.enable = true; }
      ];
    };
  };
}
```

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
