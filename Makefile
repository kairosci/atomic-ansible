.PHONY: setup silverblue kinoite update reset-home help optimize

# Default target
help:
	@echo "Available commands:"
	@echo "  make setup        - Auto-detect distro and run configuration"
	@echo "  make silverblue   - Run Silverblue desktop configuration"
	@echo "  make kinoite      - Run Kinoite desktop configuration"
	@echo "  make update       - System update and cleanup"
	@echo "  make optimize     - Install and configure earlyoom for performance (requires host sudo)"
	@echo "  make reset-home   - Reset home directory (requires confirm via prompt)"

optimize:
	@echo "Checking earlyoom status on host..."
	@flatpak-spawn --host rpm-ostree status | grep -q earlyoom || (echo "Installing earlyoom..." && flatpak-spawn --host sudo rpm-ostree install earlyoom --apply-live)
	@echo "Configuring earlyoom thresholds..."
	@flatpak-spawn --host sudo sed -i 's/^EARLYOOM_ARGS=.*/EARLYOOM_ARGS="-m 5 -s 5 --prefer \\"(electron|firefox|chrome|code)\\" --avoid \\"(gnome-shell|systemd|dbus-daemon)\\""/' /etc/default/earlyoom
	@echo "Starting earlyoom service..."
	@flatpak-spawn --host sudo systemctl enable --now earlyoom
	@flatpak-spawn --host sudo systemctl restart earlyoom
	@echo "Optimization complete."

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
