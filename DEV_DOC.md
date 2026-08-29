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
