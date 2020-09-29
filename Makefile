SHELL := /bin/bash
default: help

args = `arg="$(filter-out $@,$(MAKECMDGOALS))" && echo $${arg:-${1}}`

help: ## Show this help
	@IFS=$$'\n' ; \
    help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/'`); \
    printf "%-30s %s\n" "target" "help" ; \
    printf "%-30s %s\n" "------" "----" ; \
    for help_line in $${help_lines[@]}; do \
        IFS=$$':' ; \
        help_split=($$help_line) ; \
        help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        printf '\033[36m'; \
        printf "%-30s %s" $$help_command ; \
        printf '\033[0m'; \
        printf "%s\n" $$help_info; \
    done

clean: ## Stop all running docker containers (recommended to run before 'start' command)
	docker ps -q | xargs docker stop

start: ## Create and start containers, composer dependencies etc. - everything in one command
	if [ ! -e ".env" ]; then cp sample.env .env; fi
	make up
	make composer-install

up: ## Create and start containers
	docker-compose up -d

down: ## Stop and remove containers, networks, images, and volumes
	docker-compose down

reload: ## Restart containers
	docker-compose restart

build: ## Build or re-build containers
	docker-compose build

composer-install: ## Composer install
	docker-compose exec webserver composer install

composer-update: ## Composer update
	docker-compose exec webserver composer update

bash: ## SSH webserver container (run bash)
	docker-compose exec webserver bash

test: ## Run all unit tests or given test file
	@docker-compose exec webserver ./vendor/bin/phpunit $(call args)

test-filter: ## Run unit tests of given class or test method
	@docker-compose exec webserver ./vendor/bin/phpunit --filter $(call args)

