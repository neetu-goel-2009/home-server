# PostgreSQL backup and disaster recovery

The systemd timer runs daily at the configurable `postgresql_backup_time` (default 02:30 server local time). Each set includes a compressed custom-format `pg_dump` archive for every connectable non-template database and a globals SQL file with cluster roles. Filenames use UTC timestamps. Credentials are read from a Docker secret inside the database container; they are not command-line arguments or logged. Backup files and logs are root-only.

The backup script validates each archive with the matching PostgreSQL image before atomically moving it into place. It writes a completion marker only after every database and globals file succeeds, then prunes older complete timestamp sets. Failed partial sets are not counted for retention and are cleaned only after a later complete set succeeds. Retention is capped at 30 sets. Check logs and timer state:

```bash
sudo systemctl list-timers home-postgresql-backup.timer
sudo journalctl -u home-postgresql-backup.service
sudo tail -n 100 /var/log/home-server/postgresql-backup.log
```

Trigger a backup:

```bash
scripts/backup-now.sh
```

## Verify by restoring to a temporary PostgreSQL instance

Choose a completed dump and run the verifier. It starts an isolated, network-disabled temporary container with a temporary password, imports matching globals, restores the archive, checks the restored catalog, then removes only that temporary container and password file. It does not modify or delete the backup.

```bash
sudo /usr/local/sbin/verify-home-server-postgresql-backup \
  /srv/backups/postgresql/appdb_YYYYMMDDTHHMMSSZ.dump
```

Schedule this manual restore test regularly (for example quarterly) and after image or backup procedure changes. A successful `pg_restore --list` during backup alone is not a restore test.

## Restore into service

1. Identify and verify the timestamped archive and matching `globals_TIMESTAMP.sql`.
2. Verify the archive in the isolated test container above.
3. Create a separate target database; do not overwrite the production database first.
4. Restore the dump, validate row counts/application behavior, and confirm role ownership.
5. Switch the application only after review. Preserve the original database and backup until recovery is confirmed.

For cluster-level disaster recovery, restore roles from the matching globals file in a controlled maintenance window, then restore each database. Major PostgreSQL version changes need a migration plan. This repository does not automatically reset or replace a production database.

## Risk and optional off-site copy

The live data and backup directory currently share the same WDC physical disk. Disk failure can destroy both. Add a separately verified external disk or remote storage and retain at least one independent copy.

### Optional Restic design

After choosing and approving an external disk or remote destination, add a separate optional Restic role/service that runs only after a successful local PostgreSQL backup. Store the repository URL and Restic repository password in Ansible Vault, write the password to a mode-0600 file, back up completed `/srv/backups/postgresql` sets, and use `restic check` plus a scheduled restore test. Apply retention (for example 30 daily snapshots) only after a successful snapshot and verification. An external filesystem must be identified by UUID and mounted only after a separate reviewed storage proposal. This project intentionally does not set a repository URL, credentials, or any paid cloud destination.
