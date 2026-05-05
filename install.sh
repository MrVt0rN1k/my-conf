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
install_package build-essential make libssl-dev zlib1g-dev libbz2-dev
install_package libreadline-dev libsqlite3-dev curl llvm libncursesw5-dev
install_package xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
else
install_package "${COMMON_PACKAGES[@]}"
fi
fi

# ====================== Node.js (нужен для LSP серверов) ======================

if ! command -v node &> /dev/null; then
echo -e "${YELLOW}Устанавливаю Node.js...${NC}"
if [[ "$OS" == "macos" ]]; then
brew install node
else
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
install_package nodejs
fi
fi

# ====================== LazyGit ======================

if ! command -v lazygit &> /dev/null; then
echo -e "${YELLOW}Устанавливаю LazyGit...${NC}"
if [[ "$OS" == "macos" ]]; then
brew install lazygit
else
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz
fi
echo -e "${GREEN}✓ LazyGit установлен${NC}"
fi

# ====================== LSP серверы через npm ======================

echo -e "${BLUE}Устанавливаю LSP серверы...${NC}"

sudo npm install -g \
pyright \
typescript-language-server \
yaml-language-server \
bash-language-server \
@docker/dockerfile-language-server-nodejs \
markdownlint-cli 2>/dev/null || true

# ====================== Линтеры через pip ======================

echo -e "${BLUE}Устанавливаю линтеры...${NC}"
pip install --user pylint yamllint sqlfluff black 2>/dev/null || true

# ====================== Системные линтеры и форматтеры ======================

if [[ "$OS" == "macos" ]]; then
brew install shellcheck hadolint tflint shfmt
else
install_package shellcheck hadolint tflint shfmt 2>/dev/null || true
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

# Проверяем, установлен ли pyenv
if [[ -d "$HOME/.pyenv" ]]; then
    echo -e "${GREEN}✓ pyenv уже установлен${NC}"
else
    echo -e "${YELLOW}Устанавливаю pyenv...${NC}"
    curl -fsSL https://pyenv.run | bash
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Добавляем pyenv init в .zshrc, если ещё не добавлено
if ! grep -q 'pyenv init' "$HOME/.zshrc"; then
    cat << 'EOF' >> "$HOME/.zshrc"

# >>> pyenv >>>

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# <<< pyenv <<<

EOF
    echo -e "${GREEN}✓ pyenv добавлен в .zshrc${NC}"
fi

# ====================== pyenv-virtualenv (исправлено) ======================

if [[ ! -d "$HOME/.pyenv/plugins/pyenv-virtualenv" ]]; then
echo -e "${YELLOW}Устанавливаю pyenv-virtualenv...${NC}"
git clone https://github.com/pyenv/pyenv-virtualenv.git "$HOME/.pyenv/plugins/pyenv-virtualenv"
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

# ====================== Проверка инструментов для Telescope ======================

echo -e "${BLUE}Проверяю инструменты для Telescope...${NC}"

if command -v fd &> /dev/null; then
echo -e "${GREEN}✓ fd установлен${NC}"
else
echo -e "${YELLOW}⚠️ fd не найден (нужен для Telescope find_files)${NC}"
fi

if command -v rg &> /dev/null; then
echo -e "${GREEN}✓ ripgrep установлен${NC}"
else
echo -e "${YELLOW}⚠️ ripgrep не найден (нужен для Telescope live_grep)${NC}"
fi

# ====================== Neovim конфиг ======================

echo -e "${BLUE}Настраиваю Neovim конфигурацию...${NC}"

NVIM_CONFIG_DIR="$HOME/.config/nvim"

if [[ -d "$NVIM_CONFIG_DIR" ]]; then
echo -e "${YELLOW}Бэкап существующего Neovim конфига...${NC}"
mv "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_DIR.bak.$(date +%Y%m%d_%H%M%S)"
fi

# Создаём структуру папок
mkdir -p "$NVIM_CONFIG_DIR/lua/theprimagen"
mkdir -p "$NVIM_CONFIG_DIR/after/plugin"
mkdir -p "$NVIM_CONFIG_DIR/plugin"

echo -e "${GREEN}✓ Структура Neovim конфига создана${NC}"
echo -e "${YELLOW}⚠️ Не забудьте скопировать ваши .lua файлы в ~/.config/nvim/${NC}"

# ====================== Финальное сообщение ======================

echo -e "\n${GREEN}✅ Готово!${NC}"
echo -e "${YELLOW}Теперь доступно:${NC}"
echo -e "  py     → выбрать окружение"
echo -e "  pynew  → создать окружение"
echo -e "  lazygit → открыть Git интерфейс"
echo -e ""
echo -e "${YELLOW}Для завершения настройки Neovim:${NC}"
echo -e "  1. Скопируйте ваши .lua файлы в ~/.config/nvim/"
echo -e "  2. Запустите nvim и выполните :Lazy sync"
echo -e "  3. Перезапустите nvim"
echo -e ""
echo -e "${YELLOW}Перезапусти терминал или выполни: source ~/.zshrc${NC}"
