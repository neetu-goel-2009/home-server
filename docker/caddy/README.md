# Caddy and website Compose deployment

The maintained Compose and Caddyfile templates are in `roles/caddy/templates/`. Ansible renders them under `/etc/home-server/caddy`. The two configured Nginx applications (`365code.in` and `harimaati.com`) and Caddy share only the private proxy bridge and publish no host ports. Change hostnames, upstreams and image tags in `inventory/group_vars/all.yml` before deployment; more sites can be added later.
