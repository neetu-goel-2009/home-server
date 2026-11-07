# PostgreSQL Compose deployment

The maintained Compose template is [roles/postgresql/templates/compose.yml.j2](../../roles/postgresql/templates/compose.yml.j2). Ansible renders it to `/etc/home-server/postgresql/compose.yml`. It pins PostgreSQL 17.11, bind-mounts database files at `/srv/data/postgresql`, stores configuration separately, uses the private `home-db` network, sets resource limits and publishes no host port. Password input comes from Ansible Vault and a protected file secret.
