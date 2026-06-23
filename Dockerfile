FROM docker.io/openwrt/rootfs:x86-64-openwrt-24.10

RUN mkdir -p /var/lock /var/run

RUN sed -i '/kmods/d' /etc/opkg/distfeeds.conf

RUN opkg update && opkg install luci

CMD ["/sbin/init"]
