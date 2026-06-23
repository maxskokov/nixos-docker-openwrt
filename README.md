# nixos-docker-openwrt
# Declarative OpenWrt LuCI Router Container for NixOS Environments

An optimized, production-ready configuration designed to deploy a virtual OpenWrt 24.10 router with a stable LuCI graphical web interface inside a Docker container on modern Linux hosts, specifically tailored for NixOS deployments.

## Problem Statement
Official OpenWrt rootfs images currently experience an architectural limitation where the new `ucode` LuCI rendering engine encounters a fatal `left-hand side expression is null` exception when executed within minimal container runtimes that lack an active init system. This behavior causes `ubus` system status inquiries to return null values, crashing the interface on page load (tracked in upstream issue #8726).

This repository provides a verifiable workaround by properly configuring container filesystem layers and initializing the `/sbin/init` process within the Docker daemon to orchestrate underlying system buses correctly.

## Deployment

To deploy this virtual router instance with functional real-time telemetry, execute the following command:

```bash
docker run -d -t \
  --name devops-router \
  --network host \
  --privileged \
  --restart always \
  maxskokov/nixos-openwrt-luci:24.10
```

## Accessing the Dashboard
Once the container status is verified as active, navigate to the local interface via a web browser:
URL: http://localhost
- **Username:** `root`
- **Password:** *Leave blank and select Login*

## Core Features
- Fully operational LuCI web administration interface built on OpenWrt 24.10.
- Native `ubus` data bus initialization enabling live traffic graphs and interface telemetry visualization within a container context.
- Optimized network namespace management compatible with cutting-edge Linux kernels (6.12+) and Wayland compositors.
