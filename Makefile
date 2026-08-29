NAME=inception

COMPOSE=docker compose -f ./srcs/docker-compose.yml


all:
	@mkdir -p /home/teraslan/data/mysql
	@mkdir -p /home/teraslan/data/wordpress
	@$(COMPOSE) up -d --build


up:
	@$(COMPOSE) up -d


down:
	@$(COMPOSE) down


clean:
	@$(COMPOSE) down -v


fclean:
	@$(COMPOSE) down -v --rmi all


re: fclean all


.PHONY: all up down clean fclean re
