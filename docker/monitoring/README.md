# Monitoring Compose deployment

The maintained Compose and Prometheus templates are in `roles/monitoring/templates/`. Uptime Kuma binds to the configured Tailscale IP; Prometheus binds to loopback. Node exporter reports disk/RAM and backup timestamp metrics; a root-owned timer publishes Docker running/health metrics. Configure website and PostgreSQL monitors in Uptime Kuma after first login.
