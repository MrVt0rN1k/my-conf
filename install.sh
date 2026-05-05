#!/usr/bin/env bash

set -euo pipefail

echo -e "\033[1;34m=== Dotfiles Bootstrap Script ===\033[0m"

# ====================== Цвета ======================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ====================== Определение ОС ======================

if [[ "$(uname)" == "Darwin" ]]; then
OS="macos"
elif [[ "$(uname)" == "Linux" ]]; then
OS="linux"
else
echo -e "${RED}❌ Неподдерживаемая ОС${NC}"
exit 1
fi

echo -e "${BLUE}➜ Обнаружена система: $OS${NC}"

# ====================== Установка пакетов ======================

install_package() {
if [[ "$OS" == "macos" ]]; then
brew install "$@"
elif command -v apt &> /dev/null; then
sudo apt update && sudo apt install -y "$@"
elif command -v pacman &> /dev/null; then
sudo pacman -S --noconfirm "$@"
elif command -v dnf &> /dev/null; then
sudo dnf install -y "$@"
else
echo -e "${RED}Неизвестный пакетный менеджер${NC}"
exit 1
fi
}

# ====================== Homebrew ======================

if [[ "$OS" == "macos" ]] && ! command -v brew &> /dev/null; then
echo -e "${YELLOW}Устанавливаю Homebrew...${NC}"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ====================== Базовые пакеты ======================

echo -e "${BLUE}Устанавливаю основные пакеты...${NC}"

COMMON_PACKAGES=(
git curl wget zsh neovim
eza bat btop duf ncdu fd ripgrep gping tldr micro
zoxide fzf
)

if [[ "$OS" == "macos" ]]; then
brew install "${COMMON_PACKAGES[@]}" || true
brew install openssl readline sqlite3 xz zlib tcl-tk
else
if command -v apt &> /dev/null; then
install_package "${COMMON_PACKAGES[@]}" 
build-essential make libssl-dev zlib1g-dev libbz2-dev 
libreadline-dev libsqlite3-dev curl llvm libncursesw5-dev 
xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
else
install_package "${COMMON_PACKAGES[@]}"
fi
fi

# ====================== Oh My Zsh ======================

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
echo -e "${YELLOW}Устанавливаю Oh My Zsh...${NC}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
if [[ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]]; then
git clone --depth=1 https://github.com/zsh-users/$plugin "$ZSH_CUSTOM/plugins/$plugin"
fi
done

# ====================== Симлинки ======================

echo -e "${BLUE}Создаю симлинки...${NC}"

cd "$HOME/.config" || exit 1

LINKS=( ".zshrc" ".vimrc" ".spaceshiprc.zsh" )

for file in "${LINKS[@]}"; do
if [[ -f "$HOME/.config/$file" ]]; then
[[ -e "$HOME/$file" && ! -L "$HOME/$file" ]] && mv "$HOME/$file" "$HOME/$file.bak"
ln -sf "$HOME/.config/$file" "$HOME/$file"
echo -e "${GREEN}✓ $file${NC}"
fi
done

# ====================== pyenv ======================

if ! command -v pyenv &> /dev/null; then
echo -e "${YELLOW}Устанавливаю pyenv...${NC}"
curl -fsSL https://pyenv.run | bash
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# ====================== pyenv init ======================

if ! grep -q 'pyenv init' "$HOME/.zshrc"; then
cat << 'EOF' >> "$HOME/.zshrc"

# >>> pyenv >>>

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# <<< pyenv <<<

EOF
fi

# ====================== pyenv-virtualenv ======================

if [[ ! -d "$HOME/.pyenv/plugins/pyenv-virtualenv" ]]; then
echo -e "${YELLOW}Устанавливаю pyenv-virtualenv...${NC}"
git clone https://github.com/pyenv/pyenv-virtualenv.git 
"$HOME/.pyenv/plugins/pyenv-virtualenv"
fi

# ====================== Python ======================

echo -e "${BLUE}Устанавливаю Python...${NC}"

eval "$(pyenv init -)"

PYTHON_VERSION="3.10.13"

if ! pyenv versions --bare | grep -q "$PYTHON_VERSION"; then
pyenv install "$PYTHON_VERSION"
fi

pyenv global "$PYTHON_VERSION"

# ====================== Default env ======================

if ! pyenv virtualenvs --bare | grep -q "default"; then
pyenv virtualenv "$PYTHON_VERSION" default
fi

echo -e "\n${GREEN}✅ Готово!${NC}"
echo -e "${YELLOW}Теперь доступно:${NC}"
echo -e "  py     → выбрать окружение"
echo -e "  pynew  → создать окружение"
echo -e "\nПерезапусти терминал или выполни: source ~/.zshrc"

