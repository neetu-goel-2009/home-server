# Architecture

The Windows workstation (preferably WSL Ubuntu) is the Ansible controller. It connects over Tailscale SSH to the single `home_servers` inventory group. Ansible changes are split into numbered stages; `site.yml` is deliberately read-only so a routine run cannot deploy everything at once.

Docker Compose v2 runs PostgreSQL, Caddy, two example Nginx sites (`365code.in` and `harimaati.com`), Cloudflare Tunnel, Uptime Kuma, Prometheus, node-exporter and (only when explicitly enabled) Ollama. Caddy and site containers share the `home-proxy` bridge. PostgreSQL is on the internal `home-db` bridge and publishes no host port. Cloudflare Tunnel makes an outbound connection and routes named hosts to Caddy. The monitoring UI binds only to the server's Tailscale address; Prometheus binds to loopback.

The present server has an i3-2120 (2 cores/4 threads), 3.2 GiB RAM, integrated Intel graphics and about 175 GiB free on the Ubuntu root partition. PostgreSQL is capped at 384 MiB and Ollama remains disabled. Adding more websites and workloads will leave little headroom; monitor memory pressure as you expand. Do not expect useful LLM inference on this hardware without testing a very small quantized model after explicit approval.

## Data paths

The approved initial plan uses directories on the existing Ubuntu root filesystem: `/srv/data/postgresql`, `/srv/backups/postgresql`, `/srv/docker`, `/srv/data/ollama` and `/srv/data/apps`. No Windows partition is mounted or changed. PostgreSQL backups on this same WDC disk do not protect against disk failure. Use an external disk or remote destination for an independent copy; no paid service is configured.

## Network boundaries

No Docker daemon TCP API is configured. PostgreSQL has no published port. Websites and Caddy have no host-published ports. Cloudflare connects to Caddy over the private bridge. Monitoring binds to `100.67.188.50:3001`; change this to the host's current Tailscale address after migration. Ollama, when enabled, binds only to `127.0.0.1:11434`.
