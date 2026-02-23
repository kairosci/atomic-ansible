# Atomic Ansible Agent

This document outlines the capabilities and workflows for the agent working on the Atomic Ansible project.

## Project Summary

Atomic Ansible is a powerful, **root-less** configuration management system for **Fedora Silverblue** (GNOME) and **Fedora Kinoite** (KDE), powered by Ansible.

### Key Features

- **Zero-Sudo Architecture**: All configurations happen in the user space (dotfiles, themes, fonts, Flatpaks).
- **Automatic Multi-Distro Support**: Detects if you are on Silverblue or Kinoite and applies the correct environment.
- **Minimalist CLI**: Optimized output using the `unixy` callback for a clean, distraction-free experience.
- **Toolbox Sync**: Automatically synchronizes your host theme, icons, and fonts to all your Toolbox containers.
- **Safe Maintenance**: Integrated Flatpak updates and home directory reset utilities.

## Agent Workflows

### Create a Pull Request

This workflow describes how to create a pull request with template support.

1. Check for PR template at `.github/PULL_REQUEST_TEMPLATE.md`
2. If template exists, read it and use its structure for the PR body
3. Fill in the template sections based on the commits and changes made
4. Run: `gh pr create --title "<title>" --body "<filled template>"`
5. Confirm PR was created successfully
