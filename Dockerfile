# syntax=docker/dockerfile:1
FROM docker.io/openwrt/rootfs:x86-64-openwrt-24.10

LABEL org.opencontainers.image.title="nixos-docker-openwrt" \
      org.opencontainers.image.description="OpenWrt 24.10 with LuCI in a container running procd/ubus for live telemetry" \
      org.opencontainers.image.source="https://github.com/maxskokov/nixos-docker-openwrt" \
      org.opencontainers.image.licenses="MIT"

RUN mkdir -p /var/lock /var/run \
 && sed -i '/kmods/d' /etc/opkg/distfeeds.conf \
 && opkg update \
 && opkg install luci \
 && rm -rf /var/opkg-lists/* /tmp/opkg-lists/* 2>/dev/null || true

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1/ || exit 1

CMD ["/sbin/init"]
