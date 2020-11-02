{ config, pkgs, lib, ... }:

let
    dataDir = "/var/lib/dendrite";
    cfg = config.services.dendrite;

    dendrite = pkgs.buildGoModule rec {
        pname = "dendrite";
        version = "0.2.1";

        src = pkgs.fetchFromGitHub {
            owner = "matrix-org";
            repo = "dendrite";
            rev = "v${version}";
            sha256 = "0469rfq997lnqswbq0z653xadgdd7x7yfp4cyfvbyn8nc14gpjyh";
        };
        vendorSha256 = "0xxbhzdngzfdlcjz8z1kx9ab94gsyflmqc45z2022g0gmj8s2djj";
        runVend = true;
        doCheck = false;

        postBuild = ''
            mkdir -p $out
            cp dendrite-config.yaml $out/dendrite-config-default.yaml
        '';

        meta = with lib; {
            homepage = https://github.com/matrix-org/dendrite;
            description = "Dendrite is a second-generation Matrix homeserver written in Go!";
            license = licenses.asl20;
        };
    };

    configFile = pkgs.runCommand "dendrite-config" {
        buildInputs = [ pkgs.remarshal pkgs.yq-go ];
        preferLocalBuild = true;
    } ''
        mkdir -p $out
        ${pkgs.remarshal}/bin/json2yaml -i ${pkgs.writeText "config.json" (builtins.toJSON cfg.configOptions)} -o ./written-config.yaml
        echo "this is the yaml"
        cat ./written-config.yaml
        ${pkgs.yq-go}/bin/yq m "./written-config.yaml" "${dendrite}/dendrite-config-default.yaml" > "$out/config.yaml"
    '';
in
with lib; {
    options.services.dendrite = {
        enable = mkEnableOption "Dendrite is a second-generation Matrix homeserver written in Go!";

        configOptions = mkOption {
            type = types.attrs;
            description = ''These options will be transformed into the YAML configuration file for the server, overwriting the default config for set options'';
            example = { };
        };
    };

    config = mkIf cfg.enable {
        systemd.services.dendrite = {
            description = "Service file for Dendrite, a second-generation Matrix homeserver written in Go!";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];

            preStart = ''
                if [ ! -f ${dataDir}/matrix_key.pem ]; then
                    ${dendrite}/bin/generate-keys --private-key ${dataDir}/matrix_key.pem
                fi
                echo "${configFile}/config.yaml"
                ${pkgs.yq-go}/bin/yq m <(printf "global:\n private_key: '${dataDir}/matrix_key.pem'\nlogging:\n- type: file\n  level: info\n  params:\n    path: ${dataDir}/dendrite-log") "${configFile}/config.yaml" > ${dataDir}/config.yaml
            '';

            serviceConfig = {
                DynamicUser = true;
                StateDirectory = "dendrite";
                WorkingDirectory = dataDir;
                ExecStart = ''
                    ${dendrite}/bin/dendrite-monolith-server --config "${dataDir}/config.yaml"
                '';
                Restart = "on-failure";
            };
        };
    };
}
