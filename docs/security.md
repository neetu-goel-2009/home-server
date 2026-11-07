# Security

- Use SSH over Tailscale. The firewall rule for SSH is added on `tailscale0` before UFW is enabled. Password authentication remains enabled until a separate SSH-key login has been tested; the role refuses a password-disable override by default.
- Tailscale package installation does not authenticate a new device. Complete `sudo tailscale up` and device authorization interactively when required.
- UFW defaults to deny incoming and allow outgoing. The HTTP/HTTPS example path uses Cloudflare Tunnel and requires no router forwarding.
- Docker daemon TCP sockets are not enabled. Do not add `superadmin` to the `docker` group: that group grants root-equivalent control of the host.
- PostgreSQL, Ollama and public website origin ports are not published. PostgreSQL is on an internal Docker network. Uptime Kuma binds only to the configured Tailscale IP; Prometheus binds to loopback.
- Keep the Ansible Vault encrypted. Never store passwords, tunnel tokens or private keys in ordinary inventory or Compose files. Secret-bearing tasks use `no_log` and mode 0600 files.
- Docker's published ports bypass some UFW rules. This project only binds monitoring to the Tailscale address and Ollama/Prometheus to loopback; inspect every future `ports:` change.
- Use pinned image tags and review updates before applying. Keep a tested PostgreSQL backup before changing its major version; major upgrades require a migration plan.
- A password was entered into this chat during initial discovery. Rotate that SSH password and use SSH keys for future administration.
