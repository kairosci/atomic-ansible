.PHONY: setup silverblue kinoite update reset-home help optimize

# Default target
help:
	@echo "Available commands:"
	@echo "  make setup        - Auto-detect distro and run configuration"
	@echo "  make silverblue   - Run Silverblue desktop configuration"
	@echo "  make kinoite      - Run Kinoite desktop configuration"
	@echo "  make update       - System update and cleanup"
	@echo "  make optimize     - Install and configure earlyoom for performance (requires host sudo)"
	@echo "  make ollama       - Setup Ollama toolbox container for local AI"
	@echo "  make reset-home   - Reset home directory (requires confirm via prompt)"

optimize:
	@echo "Checking environment and earlyoom status..."
	@RUN_ON_HOST=$$(command -v flatpak-spawn >/dev/null && echo "flatpak-spawn --host" || echo ""); \
	$$RUN_ON_HOST rpm-ostree status | grep -q earlyoom || (echo "Installing earlyoom..." && $$RUN_ON_HOST sudo rpm-ostree install earlyoom --apply-live --allow-replacement); \
	$$RUN_ON_HOST sudo sed -i 's/^EARLYOOM_ARGS=.*/EARLYOOM_ARGS="-m 10 -s 10 --prefer \\"(electron|firefox|chrome|code)\\" --avoid \\"(gnome-shell|plasmashell|systemd|dbus-daemon)\\""/' /etc/default/earlyoom; \
	echo "Configuring kernel performance parameters (sysctl)..."; \
	$$RUN_ON_HOST sudo bash -c "printf 'vm.swappiness=10\nvm.vfs_cache_pressure=200\nvm.dirty_ratio=10\nvm.dirty_background_ratio=5\nvm.overcommit_memory=0\nvm.max_map_count=1048576\nvm.admin_reserve_kbytes=262144\nvm.user_reserve_kbytes=524288\nnet.core.rmem_max=16777216\nnet.core.wmem_max=16777216\nnet.ipv4.tcp_fastopen=3\nnet.ipv4.tcp_congestion_control=bbr\nnet.core.default_qdisc=cake\nfs.file-max=2097152\n' > /etc/sysctl.d/99-performance.conf"; \
	$$RUN_ON_HOST sudo sysctl --system; \
	echo "Starting earlyoom service..."; \
	$$RUN_ON_HOST sudo systemctl enable --now earlyoom; \
	$$RUN_ON_HOST sudo systemctl restart earlyoom; \
	echo "Optimization complete."

ollama:
	ansible-playbook ansible/playbooks/ollama.yml $(VERBOSE)

setup:
	@DISTRO=$$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"'); \
	if [ "$$DISTRO" = "fedora" ]; then \
		VARIANT=$$(grep ^VARIANT_ID= /etc/os-release | cut -d= -f2 | tr -d '"'); \
		if [ "$$VARIANT" = "silverblue" ]; then \
			$(MAKE) silverblue; \
		elif [ "$$VARIANT" = "kinoite" ]; then \
			$(MAKE) kinoite; \
		else \
			echo "Unsupported Fedora variant: $$VARIANT"; \
		fi \
	else \
		echo "Unsupported distro: $$DISTRO"; \
	fi

silverblue:
	ansible-playbook ansible/playbooks/silverblue.yml $(VERBOSE)

kinoite:
	ansible-playbook ansible/playbooks/kinoite.yml $(VERBOSE)

update:
	ansible-playbook ansible/playbooks/update.yml $(VERBOSE)

reset-home:
	@read -p "Are you sure you want to reset home? (y/N) " confirm; \
	if [ "$$confirm" = "y" ]; then \
		ansible-playbook ansible/playbooks/reset-home.yml -e "confirm=yes" $(VERBOSE); \
	else \
		echo "Aborted."; \
	fi
