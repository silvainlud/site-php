.DEFAULT_GOAL := help
.PHONY: help

dockerImage = ghcr.io/aeroclub-de-saint-omer/php:latest


dockerRun = docker run --rm -it -v $(PWD):/app -w /app ${dockerImage}
dockerRunWithSymfonyPort = docker run --rm -it -v $(PWD):/app -w /app -p 8001:8001 --name acsto_site-php_dev ${dockerImage}
dockerInteractPhp = docker exec -it acsto_site-php_dev

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: dev
dev: ## Lance le serveur de développement
	docker-compose up -d
	sleep 2 && open http://localhost:8001/ >> /dev/null

init: dev ## Initialisation du serveur de développement
	docker-compose exec php composer install
	docker-compose exec yarn yarn install

.PHONY: undev
undev: ## Lance le serveur de développement
	docker-compose down

.PHONY: cmd
cmd: ## Lance un terminal dans le container php
	docker-compose exec php bash

.PHONY: php
php: ## Lance un terminal dans le container php
	docker-compose exec php bash

.PHONY: yarn
yarn: ## Lance un terminal dans le container node
	docker-compose exec yarn bash

.PHONY: log
log: ## log de développement
	docker-compose logs -f

.PHONY: lint
lint: vendor/autoload.php ## Analyse le code
	./vendor/bin/phpstan analyse  --memory-limit=-1

.PHONY: test
test: vendor/autoload.php ## Tests unitaires
	./vendor/bin/phpunit

.PHONY: format
format: ## Refomatage du code
	$(dockerRun) ./vendor/bin/php-cs-fixer fix

#.PHONY: deploy
#deploy: ## Déploiement
#	 ansible-playbook -i tools/ansible/deploy/inventory --extra-vars "ansible_user=ludwig" --ask-vault-password tools/ansible/deploy/deploy.yml