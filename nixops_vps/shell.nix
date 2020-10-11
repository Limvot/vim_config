# As per https://christine.website/blog/how-i-start-nix-2020-03-08
# and https://github.com/nmattia/niv
let
    sources = import ./nix/sources.nix;
    base_overlay = _: pkgs: 
    {
        niv = import sources.niv {};
    };

    pkgs = import sources.nixpkgs { overlays = [ base_overlay ]; config = {}; };
in
pkgs.mkShell {
    buildInputs = with pkgs; [
        niv.niv
        nix nixops
        vim
    ];
    NIX_PATH="nixpkgs=${sources.nixpkgs}";
    NIXOPS_STATE="localstate.nixops";
    SSL_CERT_FILE="/etc/ssl/certs/ca-bundle.crt";
}
