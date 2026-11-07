# PostgreSQL administration

PostgreSQL listens on the private `home-db` Docker network. Port 5432 is not published on the host.

Open a local administrative `psql` session:

```bash
sudo docker exec -it home-postgres psql -U postgres
```

Inside `psql`:

```sql
\l                                      -- list databases
CREATE DATABASE appdb;
CREATE ROLE appuser LOGIN;
\password appuser                      -- set interactively; do not put password in shell history
GRANT CONNECT ON DATABASE appdb TO appuser;
```

For a new database with an owning user, prefer `CREATE DATABASE appdb OWNER appuser;`. For existing databases, grant only needed privileges and schemas. Do not use the superuser in web applications.

Health and Compose status:

```bash
sudo docker inspect --format '{{.State.Health.Status}}' home-postgres
sudo docker compose -f /etc/home-server/postgresql/compose.yml ps
sudo docker logs --tail 100 home-postgres
```

Connect from a trusted container attached to `home-db` using host `home-postgres`, port `5432`, database `appdb`, user `appuser`. Never add a host `ports:` mapping for PostgreSQL. For temporary remote administration, use an SSH/Tailscale tunnel only after reviewing the exact forwarding command.

Restore into a new database (review the selected file and target first):

```bash
sudo docker cp /srv/backups/postgresql/appdb_YYYYMMDDTHHMMSSZ.dump home-postgres:/tmp/restore.dump
sudo docker exec home-postgres createdb -U postgres appdb_restore
sudo docker exec --user 999 home-postgres pg_restore -U postgres --exit-on-error \
  --no-owner -d appdb_restore /tmp/restore.dump
sudo docker exec home-postgres rm -f /tmp/restore.dump
```

Inspect the restored database before directing applications to it. Recreate/adjust roles and ownership deliberately. Do not restore over a live database with `--clean` unless you have a separate verified backup and explicit maintenance approval.
