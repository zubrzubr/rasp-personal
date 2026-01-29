# setup docker
setup-docker:
	@bash setup_docker.sh

# setup rasp bridge
setup-rasp-bridge:
	@docker compose up -d --build rasp-bridge

# Homebridge commands
setup-homebridge:
	@mkdir -p homebridge
	@docker compose up -d homebridge

logs-homebridge:
	@docker compose logs -f homebridge

# Syncthing commands
setup-syncthing:
	@mkdir -p ~/syncthing
	@# Fix permissions for syncthing config dir to allow container to write
	@sudo chown -R 1000:1000 ~/syncthing || true
	@docker compose up -d syncthing

logs-syncthing:
	@docker compose logs -f syncthing

# Homepage commands
setup-homepage:
	@mkdir -p homepage/config
	@# Copy example files if they don't exist? (already created by script)
	@docker compose up -d homepage

logs-homepage:
	@docker compose logs -f homepage

logs-freshrss:
	@docker compose logs -f freshrss

# setup vpn router
setup-vpn-router:
	@bash setup_vpn_router.sh

# setup vpn aliases
setup-vpn-aliases:
	@bash setup_vpn_aliases.sh

# pihole commands
setup-pihole:
	@bash setup_pihole.sh

start-pihole:
	@docker compose up -d

stop-pihole:
	@docker compose down

logs-pihole:
	@docker compose logs -f

change-password-pihole:
	@docker exec -it pihole pihole -a -p

# speedtest-tracker commands
setup-speedtest-tracker:
	@mkdir -p speedtest/config
	@touch .env
	@if ! grep -q "SPEEDTEST_APP_KEY" .env; then \
		echo "Generating Speedtest Tracker App Key..."; \
		echo "SPEEDTEST_APP_KEY=base64:$$(openssl rand -base64 32)" >> .env; \
	fi
	@docker compose up -d speedtest-tracker
