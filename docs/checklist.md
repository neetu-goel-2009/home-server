# Deployment checklist

## Before each stage

- [ ] Review `scripts/deploy.sh STAGE --check` output and diff.
- [ ] Confirm the target is `home-server` and SSH remains reachable through Tailscale.
- [ ] Confirm the stage's risk and approval; use one stage only.
- [ ] Keep Vault encrypted and verify secrets are not in diffs or logs.

## After deployment

- [ ] Confirm Ubuntu release, hostname, timezone, time sync and unattended upgrades.
- [ ] Confirm SSH key login and Tailscale access; only then consider changing password authentication in a separate reviewed step.
- [ ] Confirm UFW allows SSH on Tailscale and denies unsolicited inbound connections.
- [ ] Confirm Docker is active, data-root is `/srv/docker`, Compose v2 works, and `scripts/test-docker.sh` prints success.
- [ ] Confirm PostgreSQL health, no host port 5432 mapping, and data is under `/srv/data/postgresql`.
- [ ] Create an application database/user with limited privileges and test app connectivity on the private network.
- [ ] Trigger a backup; inspect status, timestamps, file sizes, and retention.
- [ ] Restore one backup into the temporary verifier and record the result.
- [ ] Confirm Uptime Kuma is reachable only via the configured Tailscale IP; add website and PostgreSQL monitors.
- [ ] Confirm Prometheus reports memory, disk, backup timestamp, and container health metrics.
- [ ] Configure Cloudflare tunnel/DNS interactively; verify HTTPS from an external client before announcing sites.
- [ ] Leave Ollama disabled until RAM/storage suitability is reviewed; never download a model without approval.
- [ ] Verify an off-disk backup copy before treating data as protected from disk failure.
