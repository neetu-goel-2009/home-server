# Monitoring setup

The monitoring role deploys Uptime Kuma, Prometheus and node-exporter. Uptime Kuma is bound to the server's Tailscale IP and is the private interactive dashboard. Prometheus is bound to host loopback. Prometheus scrapes node-exporter for memory, disk and host metrics; a systemd timer writes Docker container running/health metrics, and successful backups publish a timestamp metric.

After deployment, open `http://100.67.188.50:3001` from an authorized Tailscale device and create the administrator account. Add website and private PostgreSQL monitors in Uptime Kuma:

| Monitor | Type | Target |
|---|---|---|
| Each public website | HTTP(s) | Your real site hostname after Cloudflare routes/DNS are configured. |
| PostgreSQL | TCP Port | `home-postgres`, port `5432`; Kuma is attached to the private database network. |

Prometheus collects the host, backup and Docker metrics below. Its UI is local-only; use an SSH tunnel from an authorized Tailscale workstation (`ssh -L 9090:127.0.0.1:9090 superadmin@100.67.188.50`) to view `http://127.0.0.1:9090`.

| Metric | Purpose |
|---|---|
| `up{job="host"}` | Node-exporter scrape/host agent availability while Prometheus is reachable. |
| `home_server_postgresql_backup_success_timestamp_seconds` | Latest completed backup; alert when `time() - metric > 93600` (26 hours). |
| `home_server_container_running` / `home_server_container_healthy` | Docker container process and configured health status. |
| `node_filesystem_avail_bytes` | Filesystem free space. |
| `node_memory_MemAvailable_bytes` / `node_memory_MemTotal_bytes` | Available and total memory. |

Uptime Kuma's account and monitor IDs are created interactively; no dashboard password or monitor token is invented by Ansible. Because Kuma and Prometheus run on this same server, they cannot notify you when the entire server is offline. Add an independent external uptime monitor if you need outage alerts. Prometheus currently has no Alertmanager or outbound notification destination; set those up only after selecting a destination and reviewing credentials.
