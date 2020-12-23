#!/bin/bash
# Setup script for setting up a new macos machine

echo "Starting setup"

# install Xcode CLI
xcode-select --install

# Check for Homebrew to be present, install if it's missing
if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update homebrew recipes
brew update

PACKAGES=(
  postgres
  coreutils
  gpg
  curl
  git
  asdf
)

echo "Installing packages..."
brew install ${PACKAGES[@]}

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
source ~/.zshrc
chsh -s /usr/local/bin/zsh

echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.zshrc
exec zsh

echo "################################ SETUP SSH KEY #################################"
if [ ! -f ~/.ssh/id_rsa ]; then
echo "Please enter your github email address:"

echo "Please enter your github email address:"
read email

ssh-keygen -t rsa -b 4096 -C $email

eval "$(ssh-agent -s)"

# touch ~/.ssh/config

cat <<'EOF' > ~/.ssh/config
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_rsa
EOF

ssh-add -K ~/.ssh/id_rsa

else echo "File at ~/.ssh/id_rsa already exists, skipping SSH key setup"
fi
echo "################################################################################"

# Make default directory for projects
cd ~/Desktop/
mkdir code
# Clone dot files
# TODO: Uncomment when dotfiles are updated for asdf
#git clone git@github.com:mikeyduece/dot_files.git

# Create file for asdf to install default gems
FILE=~/.default-gems
touch $FILE

cat > $FILE << 'EOF'
bundler
rails
docker-sync
EOF

# Install asdf plugins
# Ruby
asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
# Node
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
# Import the Node.js release team's OpenPGP keys to main keyring:
bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'
# Yarn
asdf plugin add yarn
# Erlang
asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git

# Install asdf versions for plugings
VERSIONS=(
  ruby
  node-js
  yarn
  erlang
  elixir
)
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"
asdf install ${VERSIONS[@]} latest
asdf global ${VERSIONS[@]} latest

echo 'Installing apps...'

CASKS=(
    iterm2
    slack
    spotify
    rubymine
    google-chrome
    git-fork
    sublime-text
    docker
)

brew cask install ${CASKS[@]}

brew cleanup

#"Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate"
defaults write com.apple.dock tilesize -int 36
#"Setting Dock to auto-hide and removing the auto-hiding delay"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
#"Setting screenshots location to ~/Desktop"
defaults write com.apple.screencapture location -string "$HOME/Desktop"
