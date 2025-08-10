COMPOSE_FILE := srcs/docker-compose.yml

.PHONY: all
all: start

.PHONY: start
start:
	docker compose -f $(COMPOSE_FILE) up -d

.PHONY: stop
stop:
	docker compose -f $(COMPOSE_FILE) stop

.PHONY: restart
restart:
	docker compose -f $(COMPOSE_FILE) restart

.PHONY: down
down:
	docker compose -f $(COMPOSE_FILE) down

.PHONY: clean
clean:
	docker compose -f $(COMPOSE_FILE) down --rmi all --volumes

.PHONY: fclean
fclean: clean
	sudo rm -rf /home/tkitahar/data/db/*
	sudo rm -rf /home/tkitahar/data/wp/*

.PHONY: ps
ps:
	docker compose -f $(COMPOSE_FILE) ps

.PHONY: re
re: fclean all
