# Atomic Ansible (v3.0)

A powerful, **root-less** configuration management system for **Fedora Silverblue** (GNOME) and **Fedora Kinoite** (KDE), powered by Ansible.

> [!IMPORTANT]
> **v3.0 is a complete rewrite.** We have migrated from shell scripts to a pure Ansible architecture. The system now runs entirely as a local user, requiring zero `sudo` privileges for configuration.

## Key Features

- **Zero-Sudo Architecture**: All configurations happen in the user space (dotfiles, themes, fonts, Flatpaks).
- **Automatic Multi-Distro Support**: Detects if you are on Silverblue or Kinoite and applies the correct environment.
- **Minimalist CLI**: Optimized output using the `unixy` callback for a clean, distraction-free experience.
- **Toolbox Sync**: Automatically synchronizes your host theme, icons, and fonts to all your Toolbox containers.
- **Safe Maintenance**: Integrated Flatpak updates and home directory reset utilities.

## Requirements

- **Fedora Atomic** (Silverblue or Kinoite)
- **Ansible** installed in your user environment or a venv.

## Quick Start

```bash
git clone https://github.com/kairosci/atomic-ansible.git
cd atomic-ansible

# Run the full setup (Automatic detection)
make setup

# Or run specific desktop configurations
make silverblue
make kinoite
```

## Available Commands

| Command | Description |
|---------|-------------|
| `make setup` | Detects distro and applies full configuration |
| `make update` | Updates user-level Flatpaks and cleans up |
| `make reset-home` | Resets dotfiles (with confirmation) |
| `make VERBOSE="-v"` | Run any command with Ansible verbosity |

## Structure

```text
.
├── Makefile                # Main entry point
├── ansible.cfg             # Optimized Ansible settings
├── ansible/
│   ├── playbooks/          # Main orchestration files
│   └── roles/              # Specialized kebab-case roles
│       ├── system-config   # Dotfiles and aliases
│       ├── package-config  # Flatpak remotes
│       ├── toolbox-config  # Theme synchronization
│       ├── gnome-*        # GNOME specific theme/ext
│       └── kde-*          # KDE specific theme/config
```

## Performance & Debugging

Atomic Ansible v3.0 uses the `unixy` output plugin to eliminate the "stars" and noise of standard Ansible. For deep debugging, use the verbosity flag:

```bash
make setup VERBOSE="-vvv"
```

## License

Apache License 2.0
