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
