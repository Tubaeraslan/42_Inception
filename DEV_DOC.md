# Developer Documentation

## Environment setup

Before running the project:

1. Verify that Docker and Docker Compose are installed.
2. Ensure the host directories exist:

   ```bash
   mkdir -p /home/teraslan/data/mariadb /home/teraslan/data/wordpress
   ```

3. Create the required local secret files in the root `secrets` directory:

   - `db_password.txt`
   - `db_root_password.txt`
   - `db_admin_password.txt`
   - `wp_admin_password.txt`

4. The main environment values are configured in `srcs/.env`.

## Base image selection rationale

For each `Dockerfile` this project pins a Debian-based image. The evaluation subject requests images be based on the "penultimate stable" version of Alpine or Debian to ensure a known, recent-but-not-latest base. Using an explicit, named tag (for example `debian:12.1` rather than `debian:bookworm` or an unpinned `debian:latest`) improves reproducibility and avoids unexpected breaking changes when the distribution updates. Choose the penultimate stable tag available at image build time and document the chosen tag here so evaluators can verify the constraint.

Example: `FROM debian:12.1` (document why this tag was chosen in this file).

## Build and launch

From the repository root:

```bash
make
```

This will build the images and launch the service stack with Docker Compose.

## Useful commands

```bash
docker compose -f ./srcs/docker-compose.yml ps

docker compose -f ./srcs/docker-compose.yml logs mariadb

docker compose -f ./srcs/docker-compose.yml logs wordpress

docker compose -f ./srcs/docker-compose.yml logs nginx
```

To stop the stack:

```bash
make down
```

To remove all data and images:

```bash
make fclean
```

## Persistence and data storage

Persistent data is stored through Docker named volumes mounted to the host paths:

- `/home/teraslan/data/mariadb`
- `/home/teraslan/data/wordpress`

This keeps the MariaDB data directory and WordPress files available even when containers are restarted or rebuilt.

## Evaluation preparation and cleanup

Before any evaluator starts, run the following cleanup command to ensure no leftover containers, images, volumes or networks interfere with the evaluation:

```bash
docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null
```

If you accidentally added secret files or `srcs/.env` to the Git repository, remove them from the index immediately (do NOT re-add the real secrets):

```bash
git rm --cached secrets/*.txt || true
git rm --cached srcs/.env || true
git commit -m "Remove local secrets from repository" || true

# If secrets were pushed and need to be purged from history, use BFG or git filter-repo
# Example (BFG):
# bfg --delete-files secrets/db_password.txt
# After using BFG, follow its instructions to force-push cleaned history.
```

## Changing service configuration during defense (port change example)

If the reviewer asks you to change a service port (for example change NGINX host port), follow these steps:

1. Edit `srcs/docker-compose.yml` and change the `ports:` mapping for the service. Example change NGINX host port from `443:443` to `444:443`:

```yaml
   nginx:
      ports:
         - "444:443"
```

2. Rebuild and restart the stack:

```bash
make re
```

3. Verify the service is reachable on the new port and still serving TLS:

```bash
curl -vk https://teraslan.42.fr:444 --resolve teraslan.42.fr:444:127.0.0.1
```

If you need to change an internal port (inside container), adjust the corresponding Dockerfile or service configuration, then rebuild with `make re`.

## Secrets setup (create before first run)

Create the `secrets` directory at the repository root and populate the required files (do not commit real secrets; use the `.example` files as template):

```bash
cp secrets/db_password.txt.example secrets/db_password.txt
cp secrets/db_root_password.txt.example secrets/db_root_password.txt
cp secrets/db_admin_password.txt.example secrets/db_admin_password.txt
cp secrets/wp_admin_password.txt.example secrets/wp_admin_password.txt
mkdir -p /home/teraslan/data/mariadb /home/teraslan/data/wordpress
```

The compose configuration uses named volumes that are backed by host paths. After launching, verify volumes point to the expected host directories:

```bash
docker volume ls
docker volume inspect inception_mariadb_data
docker volume inspect inception_wordpress_data
```

Look for `Mountpoint` or `Options`/`Device` showing `/home/teraslan/data/mariadb` and `/home/teraslan/data/wordpress` respectively.

## Notes on initialization scripts

The MariaDB and WordPress services use entrypoint scripts to bootstrap databases and perform automatic WP installation. Ensure the secret files above are present so initialization runs correctly. If initialization fails, check service logs:

```bash
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml logs wordpress
```
