{
  description = "Declarative OpenWrt 24.10 + LuCI container for NixOS hosts";

  outputs = { self, ... }: {
    nixosModules.default = { config, lib, ... }:
      let
        cfg = config.services.openwrt-router;
      in
      {
        options.services.openwrt-router = {
          enable = lib.mkEnableOption "OpenWrt 24.10 + LuCI container";

          image = lib.mkOption {
            type = lib.types.str;
            default = "ghcr.io/maxskokov/nixos-docker-openwrt:24.10";
            description = "Container image to run.";
          };
        };

        config = lib.mkIf cfg.enable {
          virtualisation.oci-containers.containers.openwrt-router = {
            image = cfg.image;
            extraOptions = [ "--network=host" "--privileged" "--tty" ];
          };
        };
      };
  };
}
