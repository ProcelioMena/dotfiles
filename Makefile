# Makefile
.PHONY: setup brew ohmyzsh claude neovim-config

# Running `make setup` triggers all these targets in order
setup: brew ohmyzsh claude neovim-config

brew:
	@echo "Installing dependencies from Brewfile..."
	brew bundle

ohmyzsh:
	@echo "Checking for Oh My Zsh..."
	@if [ ! -d "$$HOME/.oh-my-zsh" ]; then \
		echo "Installing Oh My Zsh..."; \
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
	else \
		echo "Oh My Zsh is already installed."; \
	fi

claude:
	@echo "Checking for Claude Code..."
	@if ! command -v claude &> /dev/null; then \
		echo "Installing Claude Code native binary..."; \
		curl -fsSL https://claude.ai/install.sh | bash; \
	else \
		echo "Claude Code is already installed."; \
	fi

neovim-config:
	@echo "Setting up Neovim configuration..."
	@if [ ! -d "$$HOME/.config/nvim" ]; then \
		mkdir -p "$$HOME/.config"; \
		git clone git@github.com:ProcelioMena/nvim.git "$$HOME/.config/nvim"; \
	else \
		echo "Neovim config already exists. Pulling latest updates..."; \
		git -C "$$HOME/.config/nvim" pull; \
	fi

symlink:
	@echo "Symlinking configuration files..."
	
	# Handle .zshrc
	@if [ -f "$$HOME/.zshrc" ] && [ ! -L "$$HOME/.zshrc" ]; then \
		echo "Backing up existing .zshrc..."; \
		mv "$$HOME/.zshrc" "$$HOME/.zshrc.backup"; \
	fi
	@if [ ! -L "$$HOME/.zshrc" ]; then \
		ln -s "$$PWD/.zshrc" "$$HOME/.zshrc"; \
		echo "Symlinked .zshrc successfully."; \
	fi

	# Handle SSH Config
	@echo "Setting up SSH configuration..."
	@mkdir -p "$$HOME/.ssh"
	@chmod 700 "$$HOME/.ssh"
	@if [ -f "$$HOME/.ssh/config" ] && [ ! -L "$$HOME/.ssh/config" ]; then \
		echo "Backing up existing SSH config..."; \
		mv "$$HOME/.ssh/config" "$$HOME/.ssh/config.backup"; \
	fi
	@if [ ! -L "$$HOME/.ssh/config" ]; then \
		ln -s "$$PWD/ssh_config" "$$HOME/.ssh/config"; \
		echo "Symlinked SSH config successfully."; \
	fi
