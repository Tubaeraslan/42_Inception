# Inception

*This project has been created as part of the 42 curriculum by teraslan.*

## Description

This project sets up a small Docker-based infrastructure composed of a MariaDB container, a WordPress + PHP-FPM container, and an NGINX container with TLS enabled. The goal is to understand system administration basics, networking, volumes, Docker Compose orchestration, and secure configuration practices.

The stack is built around three dedicated services connected through a Docker network, with persistent storage managed through Docker volumes. WordPress files and database data are kept separate, while the public entry point is limited to HTTPS on port 443.

## Docker and design choices

- Virtual Machines vs Docker: Docker containers are lighter-weight than full virtual machines and share the host kernel, which makes them faster to deploy and easier to isolate for a small multi-service stack.
- Secrets vs Environment Variables: environment variables are used for non-sensitive configuration such as the domain name and service names, while confidential values like database credentials are stored in local secret files and mounted to the containers at runtime.
- Docker Network vs Host Network: the application uses a dedicated bridge network so that services can communicate over private names without exposing internal ports to the host.
- Docker Volumes vs Bind Mounts: this project uses Docker named volumes for persistence, with host paths configured under the local data directory to keep data accessible on the host machine while maintaining the expected volume behavior.

## Instructions

1. Ensure Docker and Docker Compose are installed on the host machine.
2. Create the host data directories and the secret files inside the root-level secrets folder.
3. Run the following command from the project root:

   make

4. The stack will build the images and start the services automatically.
5. Open the website in a browser using the configured domain, for example:

   https://teraslan.42.fr

6. To stop the stack, run:

   make down

7. To rebuild everything from scratch:

   make re

## Resources

- Docker documentation: https://docs.docker.com/
- Docker Compose reference: https://docs.docker.com/compose/
- MariaDB documentation: https://mariadb.com/kb/en/
- WordPress installation guide: https://wordpress.org/support/article/how-to-install-wordpress/
- NGINX TLS configuration: https://nginx.org/en/docs/http/configuring_https_servers.html

AI usage: AI was used to help with structure validation, troubleshooting Docker configuration, and checking configuration consistency. The generated material was reviewed and adapted to the project requirements before use.
