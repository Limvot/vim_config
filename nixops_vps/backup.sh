#!/usr/bin/env bash

set -e

pushd ~/vim_config/nixops_vps/
nix-shell --command "nixops ssh vps 'su postgres -c pg_dumpall' | gzip" > ~/synapse_backups/pg_dumpall_$(date +%F).sql.gz
nix-shell --command "nixops ssh vps 'cd /var/lib && tar czf - matrix-synapse private/mautrix-telegram'" > ~/synapse_backups/synapse_and_telegram_$(date +%F).tar.gz
