# Environment checks
IS_CONTAINER := $(shell [ -f /run/.containerenv ] && echo yes || echo no)

ifeq ($(IS_CONTAINER),yes)
$(error This Makefile must be run from the host, not inside a container)
endif

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
	@if ! rpm-ostree status | grep -q earlyoom; then \
		echo "Installing earlyoom..."; \
		sudo rpm-ostree install earlyoom --apply-live; \
	fi
	@echo "Configuring earlyoom parameters..."
	@sudo sed -i 's/^EARLYOOM_ARGS=.*/EARLYOOM_ARGS="-m 10 -s 10 --prefer \\"(electron|firefox|chrome|code)\\" --avoid \\"(gnome-shell|plasmashell|systemd|dbus-daemon)\\""/' /etc/default/earlyoom
	@echo "Configuring kernel performance parameters (sysctl)..."
	@sudo bash -c "printf 'vm.swappiness=10\n\
vm.vfs_cache_pressure=200\n\
vm.dirty_ratio=10\n\
vm.dirty_background_ratio=5\n\
vm.overcommit_memory=0\n\
vm.max_map_count=1048576\n\
vm.admin_reserve_kbytes=262144\n\
vm.user_reserve_kbytes=524288\n\
net.core.rmem_max=16777216\n\
net.core.wmem_max=16777216\n\
net.ipv4.tcp_fastopen=3\n\
net.ipv4.tcp_congestion_control=bbr\n\
net.core.default_qdisc=cake\n\
fs.file-max=2097152\n' > /etc/sysctl.d/99-performance.conf"
	@sudo sysctl --system
	@echo "Starting earlyoom service..."
	@sudo systemctl enable --now earlyoom
	@sudo systemctl restart earlyoom
	@echo "Optimization complete."

ollama:
	ansible-playbook ansible/playbooks/ollama.yml -K $(VERBOSE)

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
	ansible-playbook ansible/playbooks/silverblue.yml -K $(VERBOSE)

kinoite:
	ansible-playbook ansible/playbooks/kinoite.yml -K $(VERBOSE)

update:
	ansible-playbook ansible/playbooks/update.yml -K $(VERBOSE)

reset-home:
	@read -p "Are you sure you want to reset home? (y/N) " confirm; \
	if [ "$$confirm" = "y" ]; then \
		ansible-playbook ansible/playbooks/reset-home.yml -e "confirm=yes" -K $(VERBOSE); \
	else \
		echo "Aborted."; \
	fi
