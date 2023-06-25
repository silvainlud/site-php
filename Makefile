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
	${dockerRunWithSymfonyPort} symfony server:start --no-tls --port 8001

.PHONY: undev
undev: ## Lance le serveur de développement
	#symfony server:stop
	docker-compose down

.PHONY: cmd
cmd: ## Lance le serveur de développement
	#symfony server:stop
	${dockerInteractPhp} bash


.PHONY: lint
lint: vendor/autoload.php ## Analyse le code
	$(dockerRun) ./vendor/bin/phpstan analyse  --memory-limit=-1

.PHONY: format
format: ## Refomatage du code
	$(dockerRun) ./vendor/bin/php-cs-fixer fix

#.PHONY: deploy
#deploy: ## Déploiement
#	 ansible-playbook -i tools/ansible/deploy/inventory --extra-vars "ansible_user=ludwig" --ask-vault-password tools/ansible/deploy/deploy.yml