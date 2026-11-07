# Storage layout

## Verified discovery

- `/dev/sdb` is a 931.5 GiB WDC WD10EZEX MBR disk. It contains three NTFS partitions and `/dev/sdb4`, a 200 GiB ext4 Ubuntu root partition (UUID `372551f6-c6de-49c5-b4ee-0d84a91aa2e6`). Root had about 175 GiB free.
- `/dev/sda` is a 447.1 GiB Kingston SA400S3 MBR disk with four NTFS partitions, including the `System Reserved` and `New Volume` labels.
- Both disks contain existing Windows data. No partition has been proposed for formatting, resizing, mounting or repurposing.

## Approved directory proposal

| Purpose | Path | Filesystem/physical disk | Notes |
|---|---|---|---|
| Ubuntu | existing `/` | ext4 on WDC `/dev/sdb4` | Leave boot and Windows partitions unchanged. |
| Application files | `/srv/data/apps` | Same ext4/root disk | One directory per website. |
| PostgreSQL data | `/srv/data/postgresql` | Same ext4/root disk | Bind-mounted into the official PostgreSQL container; UID 999 by default. |
| PostgreSQL configuration | `/etc/home-server/postgresql` | Same ext4/root disk | Separate from database data; password file is mode 0600 and excluded from logs. |
| Backups | `/srv/backups/postgresql` | Same ext4/root disk | 30 timestamped sets maximum; not disk-failure protection. |
| Docker data root | `/srv/docker` | Same ext4/root disk | Docker log rotation limits each container log to 30 MiB. |
| Ollama models | `/srv/data/ollama` | Same ext4/root disk | Empty unless Ollama is explicitly enabled; model pulls are never automated. |
| Application logs | journald, `/var/log/home-server` | Same ext4/root disk | Rotated; Docker logs are size limited. |

The directory role creates only directories with restrictive permissions. It does not create a filesystem, mount a disk or add `/etc/fstab` entries. Since the database and backup directory are on one physical disk, a disk failure can destroy both. Before storing important data, add a separately verified external drive or encrypted remote backup. Do not use either NTFS disk as Docker/PostgreSQL data storage.

After attaching an external disk, rerun read-only discovery and identify it by model, serial, filesystem UUID and label. Prepare a new layout and obtain approval before partitioning, formatting, mounting or editing `/etc/fstab`.
