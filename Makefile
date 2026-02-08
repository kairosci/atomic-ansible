.PHONY: setup silverblue kinoite update reset-home help

# Default target
help:
	@echo "Available commands:"
	@echo "  make setup        - Auto-detect distro and run configuration"
	@echo "  make silverblue   - Run Silverblue desktop configuration"
	@echo "  make kinoite      - Run Kinoite desktop configuration"
	@echo "  make update       - System update and cleanup"
	@echo "  make reset-home   - Reset home directory (requires confirm via prompt)"

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
