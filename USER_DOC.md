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

The sensitive values are stored locally in the root-level secrets directory and are mounted into the containers at runtime. Check the secret files if you need to locate credentials.

## Service health check

To verify the services are running:

```bash
docker ps
```

For logs:

```bash
docker compose -f ./srcs/docker-compose.yml logs -f
```

