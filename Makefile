# ==========================================
# Global Stable Versions
# ==========================================
TF_VERSION = 1.9.5
PYTHON_VERSION = 3.11.9
NODE_VERSION = 22.11.0

# Makefile
.PHONY: setup brew ohmyzsh claude neovim-config asdf-setup zsh-plugins

# Running `make setup` triggers all these targets in order
setup: brew ohmyzsh claude neovim-config asdf-setup zsh-plugins

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

asdf-setup:
	@echo "Setting up asdf plugins..."
	@asdf plugin add terraform || true
	@asdf plugin add python || true
	@asdf plugin add nodejs || true

	@echo "Installing stable versions (this might take a minute for Python/Node)..."
	@asdf install terraform $(TF_VERSION)
	@asdf install python $(PYTHON_VERSION)
	@asdf install nodejs $(NODE_VERSION)
	
	@echo "Setting global defaults..."
	@asdf set --home terraform $(TF_VERSION)
	@asdf set --home python $(PYTHON_VERSION)
	@asdf set --home nodejs $(NODE_VERSION)
	@echo "Global toolchain locked and loaded."

zsh-plugins:
	@echo "Installing custom Zsh plugins..."
	@if [ ! -d "$$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then \
		git clone https://github.com/zsh-users/zsh-autosuggestions "$$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"; \
	else \
		echo "zsh-autosuggestions already installed."; \
	fi
	@if [ ! -d "$$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then \
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"; \
	else \
		echo "zsh-syntax-highlighting already installed."; \
	fi

