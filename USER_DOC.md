# User Documentation

## Services in the stack

The project provides the following services:

- MariaDB: stores the WordPress database.
- WordPress + PHP-FPM: serves the application logic.
- NGINX: exposes the site through HTTPS on port 443.

## Start and stop the project

From the project root, start the stack with:

```bash
make
```

To stop it:

```bash
make down
```

To rebuild from scratch:

```bash
make re
```

## Access the website

The application is accessed through the configured domain name:

```bash
https://teraslan.42.fr
```

The admin panel is available on the same domain after WordPress installation is complete.

## Credentials and secret management

The sensitive values are stored locally in the root-level `secrets` directory and are mounted into the containers at runtime. Check the secret files if you need to locate credentials.

### Creating secrets (quick)

Before first `make`, create the `secrets` directory and copy the example files to real secret files (do not commit these files into the repository):

```bash
mkdir -p secrets
cp secrets/db_password.txt.example secrets/db_password.txt
cp secrets/db_root_password.txt.example secrets/db_root_password.txt
cp secrets/db_admin_password.txt.example secrets/db_admin_password.txt
cp secrets/wp_admin_password.txt.example secrets/wp_admin_password.txt
```

### Verify volumes and persistence

After `make`, verify named volumes exist and are backed by the host data paths:

```bash
docker volume ls
docker volume inspect inception_mariadb_data
docker volume inspect inception_wordpress_data
```

You should see host paths under `/home/teraslan/data/...` in the inspection output. To check the running services:

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f
```

### Security note — DO NOT commit secrets

Never commit `srcs/.env` or files inside the `secrets/` directory to the Git repository. Use the provided `.example` files as templates and keep real secrets only on your local machine. If a secret file was accidentally committed, remove it from the index and history (see `DEV_DOC.md` guidance).



## Service health check

To verify the services are running:

```bash
docker ps
```

For logs:

```bash
docker compose -f ./srcs/docker-compose.yml logs -f
```

