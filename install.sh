#!/bin/bash

# Expect i3, nvim or terminal
whatToConfigure="$1"

CLONE_DEPTH=1
POLYBAR_THEMES_URL="https://github.com/bitc0d/polybar-themes.git"
DOTFILES_URL="https://github.com/bitc0d/dotfiles.git"

NERD_FONT_3270_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/3270.zip"

LOG_OUTPUT="/tmp/dotfiles.log"
CURRENT_DIR="$(pwd)"

# Check if running as root
if [[ "$USER" == "root" ]]; then
  echo "INFO: Running as root is not allowed"
  exit 1
fi

function errorMessage() {
  echo "$1"

  cd $CURRENT_DIR

  exit 1
}

function checkErrors() {
  if [[ "$1" != "0" ]]; then
    tail -n 50 $LOG_OUTPUT

    echo "For a full log check file: $LOG_OUTPUT"
    exit 1
  fi
}

function checkDotfilesFolder() {
  if [[ -d "~/.dotfiles" ]]; then
    cp -R ~/.dotfiles ~/.dotfiles.bak.bitc0d
    rm -rf ~/.dotfiles
  fi
}

function logFile() {
  echo "Please wait ... $1"
  echo "NOTE: you can see log output on file: $LOG_OUTPUT"
}

# Supported for i3: Qubes OS
function installI3() {
  if [[ "$(echo $NAME | tr '[:upper:]' '[:lower:]')" != *"qubes"* ]]; then
    errorMessage "ERROR: i3 support is just for Qubes OS"
  fi

  logFile "installing and configuring i3"

  checkDotfilesFolder

  # i3 and polybar
  sudo qubes-dom0-update -y i3 i3-settings-qubes >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
  checkErrors $statusCode
  sudo qubes-dom0-update -y polybar rofi feh dunst i3lockls >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
  checkErrors $statusCode
  git clone --depth=$CLONE_DEPTH $DOTFILES_URL ~/.dotfiles >>$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
  checkErrors $statusCode
  sudo pip3 install ~/.dotfiles/utils/modules/pywal-3.3.0.tar.gz >>$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
  checkErrors $statusCode

  # Extra tools that I may use
  sudo qubes-dom0-update -y gnome-calculator shutter >>$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
  checkErrors $statusCode
  sudo cp ~/.dotfiles/utils/bin/* /usr/local/bin/ >>$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
  checkErrors $statusCode

  bash ~/.dotfiles/utils/polybar-themes/setup.sh

  cd $CURRENT_DIR
}

function configureTerminal() {
  logFile "installing and configuring terminal"

  # install zsh and terminator
  if [[ "$(echo $NAME | tr '[:upper:]' '[:lower:]')" == *"debian"* ]]; then
    sudo apt install -y zsh terminator >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
    checkErrors $statusCode
  elif [[ "$(echo $NAME | tr '[:upper:]' '[:lower:]')" == *"fedora"* ]]; then
    sudo dnf install -y zsh terminator >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
    checkErrors $statusCode
  elif [[ "$(echo $NAME | tr '[:upper:]' '[:lower:]')" == *"ubuntu"* ]]; then
    sudo apt install -y zsh terminator >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
    checkErrors $statusCode
  else
    errorMessage "ERROR: terminal support is for Debian, Fedora or Ubuntu"
  fi
  echo "$rootPassword" | sudo -S chsh -s $(which zsh) >>$LOG_OUTPUT 2>&1

  # Install ohmyzsh
  cp -R ~/.dotfiles/utils/ohmyzsh ~/.oh-my-zsh >>$LOG_OUTPUT 2>&1
  cp -R ~/.dotfiles/utils/zsh-autosuggestions/ ~/.oh-my-zsh/plugins// >>$LOG_OUTPUT 2>&1
  cp -R ~/.dotfiles/utils/zsh-syntax-highlighting/ ~/.oh-my-zsh/plugins/ >>$LOG_OUTPUT 2>&1

  rm -rf ~/.zshrc && ln -s ~/.dotfiles/.zshrc ~/.zshrc >>$LOG_OUTPUT 2>&1
  rm -rf ~/.tmux.conf && ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf >>$LOG_OUTPUT 2>&1
  rm -rf ~/.bashrc && ln -s ~/.dotfiles/.bashrc ~/.bashrc >>$LOG_OUTPUT 2>&1
  rm -rf ~/.vimrc && ln -s ~/.dotfiles/.vimrc ~/.vimrc >>$LOG_OUTPUT 2>&1

  cd $CURRENT_DIR
}

function installNVIM() {
  logFile "installing nvim"

  # install neovim prerequisites
  if [[ "$(echo $NAME | tr '[:upper:]' '[:lower:]')" == *"debian"* ]]; then
    sudo apt-get install -y ninja-build gettext cmake curl build-essential wget unzip >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
    checkErrors $statusCode
  elif [[ "$(echo $NAME | tr '[:upper:]' '[:lower:]')" == *"fedora"* ]]; then
    sudo dnf -y install -y ninja-build cmake gcc make gettext curl glibc-gconv-extra wget unzip >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
    checkErrors $statusCode
  elif [[ "$(echo $NAME | tr '[:upper:]' '[:lower:]')" == *"ubuntu"* ]]; then
    sudo apt-get install -y ninja-build gettext cmake curl build-essential wget unzip >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
    checkErrors $statusCode
  else
    errorMessage "ERROR: terminal support is for Debian, Fedora or Ubuntu"
  fi

  # build neovim
  cd ~/.dotfiles/utils/neovim
  make CMAKE_BUILD_TYPE=RelWithDebInfo >>$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
  checkErrors $statusCode
  sudo make install >>$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
  checkErrors $statusCode
}

function configureNVIM() {
  logFile "configuring nvim"

  # Install lazygit and git
  if [[ "$(echo $NAME | tr '[:upper:]' '[:lower:]')" == *"debian"* ]]; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*') >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
    checkErrors $statusCode
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
    checkErrors $statusCode
    tar xf lazygit.tar.gz lazygit >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
    checkErrors $statusCode
    sudo install lazygit -D -t /usr/local/bin/ >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
    checkErrors $statusCode
    rm -rf lazygit.tar.gz lazygit >>$LOG_OUTPUT 2>&1
    sudo apt install -y git pkg-config xclip >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
    checkErrors $statusCode
  elif [[ "$(echo $NAME | tr '[:upper:]' '[:lower:]')" == *"fedora"* ]]; then
    sudo dnf copr enable atim/lazygit -y >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
    checkErrors $statusCode
    sudo dnf install -y lazygit git pkg-config >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
    checkErrors $statusCode
  elif [[ "$(echo $NAME | tr '[:upper:]' '[:lower:]')" == *"ubuntu"* ]]; then
    sudo apt install -y lazygit git pkg-config xclip >$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
    checkErrors $statusCode
  else
    errorMessage "ERROR: terminal support is for Debian, Fedora or Ubuntu"
  fi

  # Add nerd font
  cd /tmp && wget $NERD_FONT_3270_URL >>$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
  checkErrors $statusCode
  rm -rf ~/.local/share/fonts/3270NertFont >>$LOG_OUTPUT 2>&1
  mkdir -p ~/.local/share/fonts/3270NertFont >>$LOG_OUTPUT 2>&1
  unzip /tmp/3270.zip -d ~/.local/share/fonts/3270NertFont >>$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
  checkErrors $statusCode

  # required
  mv ~/.config/nvim{,.bak} >>$LOG_OUTPUT 2>&1

  # optional but recommended
  mv ~/.local/share/nvim{,.bak} >>$LOG_OUTPUT 2>&1
  mv ~/.local/state/nvim{,.bak} >>$LOG_OUTPUT 2>&1
  mv ~/.cache/nvim{,.bak} >>$LOG_OUTPUT 2>&1

  git clone https://github.com/LazyVim/starter ~/.config/nvim >>$LOG_OUTPUT 2>&1 && statusCode=$? || statusCode=$?
  checkErrors $statusCode
  rm -rf ~/.config/nvim/.git

  cp -R ~/.dotfiles/config/nvim/ ~/.config/nvim

  cd $CURRENT_DIR
}

source /etc/os-release

if [[ "$whatToConfigure" == "i3" ]]; then
  installI3
elif [[ "$whatToConfigure" == "invim" ]]; then
  installNVIM
elif [[ "$whatToConfigure" == "cnvim" ]]; then
  configureNVIM
elif [[ "$whatToConfigure" == "terminal" ]]; then
  echo -n "Type your root password:"
  read -s rootPassword
  export rootPassword="$rootPassword"
  configureTerminal
else
  echo "INFO: You need to run the script with an argument"
  echo " - i3"
  echo " - invim -> install nvim"
  echo " - cnvim -> configure nvim"
  echo " - terminal"
  exit 0
fi
