# Troubleshooting

## Ansible cannot connect

Check Tailscale reachability, host-key verification and the `ansible_host` address in `inventory/hosts.yml`. Bootstrap SSH public-key access before disabling password authentication. Use `-vvv` for connection diagnostics; do not paste passwords into commands or logs.

## Sudo prompt or permission failure

The controller prompts for become password. Confirm `superadmin` has sudo privileges. Do not set `become_ask_pass` to false unless passwordless sudo is intentionally configured.

## Docker repository or package failure

The Docker role accepts Ubuntu `noble` and `resolute` only and fails closed for other releases. Confirm the release codename, architecture and official Docker repository availability before adjusting the allowlist. Do not substitute a convenience install script.

## Docker does not start after changing data-root

The role refuses to move a nonempty `/var/lib/docker` and refuses to overwrite a different daemon config. Inspect the daemon journal and existing storage. Prepare and review a migration plan; do not delete the old Docker directory.

## PostgreSQL fails to start

Run `docker compose -f /etc/home-server/postgresql/compose.yml ps` and inspect `docker logs home-postgres`. Check that the host data directory is owned by the configured container UID, has mode 0700, and that the mounted secret is readable by that UID. Never remove the data directory to clear a startup error.

## Cloudflare Tunnel is disconnected

Confirm account authorization, the token in Ansible Vault, outbound connectivity, tunnel hostname routes to `http://caddy:80`, and DNS records. Keep the tunnel disabled until the interactive Cloudflare setup is complete.

## Backup failed

Read `/var/log/home-server/postgresql-backup.log` and `journalctl -u home-postgresql-backup.service`. A failed new set does not trigger retention deletion. Fix the reported cause and run the manual backup before changing retention.

## Low memory or full disk

Check `free -h`, `df -hT /srv`, Prometheus node metrics and container health. Stop optional workloads only after checking their state. Ollama is disabled on this 3.2 GiB host; don't download models until available RAM and storage are reviewed.
