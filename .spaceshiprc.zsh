# ========== SPACESHIP PROMPT CUSTOM CONFIG ==========

# Общие настройки
SPACESHIP_PROMPT_ADD_NEWLINE=true
SPACESHIP_PROMPT_SEPARATE_LINE=true
SPACESHIP_PROMPT_FIRST_PREFIX_SHOW=true

# Символ приглашения
SPACESHIP_CHAR_SYMBOL="➜"
SPACESHIP_CHAR_COLOR_SUCCESS="bright_green"
SPACESHIP_CHAR_COLOR_FAILURE="bright_red"
SPACESHIP_CHAR_SUFFIX=" "
SPACESHIP_GIT_SYMBOL=""
SPACESHIP_PACKAGE_SYMBOL="📦"
SPACESHIP_NODE_SYMBOL="⬢"
SPACESHIP_RUBY_SYMBOL="💎"
SPACESHIP_PYTHON_SYMBOL="🐍 "
SPACESHIP_GOLANG_SYMBOL="🐹"
SPACESHIP_PHP_SYMBOL="🐘"
SPACESHIP_RUST_SYMBOL="🦀"
SPACESHIP_DOCKER_SYMBOL="🐳"
SPACESHIP_AWS_SYMBOL="☁️"
SPACESHIP_KUBECTL_SYMBOL="☸️"
# Компоненты, порядок отображения
SPACESHIP_PROMPT_ORDER=(
  user
  host
  dir
  git
  package
  node
  python
  ruby
  golang
  rust
  java
  php
  docker
  aws
  kubectl
  venv
  conda
  exec_time
  line_sep
  battery
  char
)

# Цвета юзера и хоста
SPACESHIP_USER_COLOR="bright_yellow"
SPACESHIP_HOST_COLOR="bright_black"

# Директория
SPACESHIP_DIR_TRUNC=3
SPACESHIP_DIR_COLOR="bright_blue"

# Git
SPACESHIP_GIT_BRANCH_COLOR="bright_magenta"
SPACESHIP_GIT_STATUS_COLOR="red"
SPACESHIP_GIT_SYMBOL=""

# Языки и окружения
SPACESHIP_NODE_COLOR="bright_green"
SPACESHIP_PYTHON_COLOR="bright_cyan"
SPACESHIP_RUBY_COLOR="bright_red"
SPACESHIP_GOLANG_COLOR="cyan"
SPACESHIP_RUST_COLOR="208"   # насыщенный оранжевый
SPACESHIP_JAVA_COLOR="220"   # жёлто-оранжевый
SPACESHIP_PHP_COLOR="27"     # глубокий синий

# Docker / AWS / Kube
SPACESHIP_DOCKER_COLOR="bright_cyan"
SPACESHIP_AWS_COLOR="214"     # янтарный
SPACESHIP_KUBECTL_COLOR="bright_green"

# Время выполнения
SPACESHIP_EXEC_TIME_THRESHOLD=1
SPACESHIP_EXEC_TIME_COLOR="244" # тёмно-серый

# Батарея
SPACESHIP_BATTERY_SHOW=true
SPACESHIP_BATTERY_SHOW_PERCENT=true
SPACESHIP_BATTERY_PREFIX=""

# Своя функция отображения батареи
spaceship_battery() {
  local percent=$(_battery_percent)
  local symbol=$(_battery_icon)
  local color=$(_battery_color "$percent")

  spaceship::section \
    "%F{$color}" \
    "$symbol $percent%%" \
    "%f"
}

_battery_percent() {
  pmset -g batt | grep -o '[0-9]\+%' | tr -d '%'
}

_battery_icon() {
  if pmset -g batt | grep -q "AC Power"; then
    echo "⚡"
  else
    echo "🔋"
  fi
}

_battery_color() {
  local p=$1
  if [[ $p -ge 80 ]]; then
    echo "green"
  elif [[ $p -ge 50 ]]; then
    echo "yellow"
  elif [[ $p -ge 20 ]]; then
    echo "208" # оранжевый
  else
    echo "red"
  fi
}

