#!/bin/bash
EMAIL="mikeheft@gmail.com"
# 1. Install Xcode Command Line Tools
echo "Installing Xcode Command Line Tools..."
xcode-select --install

# 2. Check if Homebrew is installed and install it if it is not
if test ! $(which brew); then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    echo "Updating Homebrew..."
    brew update
fi

# 3. Apps and casks to install via Homebrew
apps=(
  git
  zsh
  coreutils
  automake
  autoconf
  openssl
  libyaml
  readline
  libxslt
  libtool
  unixodbc
  wxmac
  gnu-sed
  gpg
  kubectl
  terraform
  awscli
  ansible
  jenkins
  helm
  minikube
  docker-compose
)

casks=(
  google-chrome
  docker
  visual-studio-code
  intellij-idea-ce
  grafana
  firefox
)

echo "Installing apps..."
for app in "${apps[@]}"; do
    echo "Installing $app..."
    brew install "$app"
done

echo "Installing cask apps..."
for cask in "${casks[@]}"; do
    echo "Installing $cask..."
    brew install --cask "$cask"
done

# 4. Setup SSH Key
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Setting up SSH Key..."
    ssh-keygen -t ed25519 -C $EMAIL
    eval "$(ssh-agent -s)"
    if [ -f ~/.zshrc ]; then
        echo "Host *\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519" >> ~/.zshrc
    elif [ -f ~/.bashrc ]; then
        echo "Host *\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519" >> ~/.bashrc
    elif [ -f ~/.bash_profile ]; then
        echo "Host *\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519" >> ~/.bash_profile
    fi
    ssh-add -K ~/.ssh/id_ed25519
else
    echo "SSH Key already exists. Skipping setup."
fi

echo "Done. Your new SSH public key is:"
cat ~/.ssh/id_ed25519.pub

# 5. Add SSH key to GitHub
read -p "Enter your GitHub password or Personal Access Token: " -s github_pass
echo -e "\n"
ssh_key=$(cat ~/.ssh/id_ed25519.pub | awk '{print $2}')
key_exists=$(curl -u "$EMAIL:$githib_pass" https://api.github.com/user/keys | jq '.message')
if [ "$key_exists" = "Not Found" ]; then
    curl -u "$github_user:$github_pass" https://api.github.com/user/keys -d "{\"title\": \"`hostname`\", \"key\": \"$ssh_key\"}"
else
    echo "SSH Key already added to the GitHub account. Skipping."
fi

# 6. Configure Git
git config --global user.name "Mike Heft"
git config --global user.email $EMAIL

# 7. Install Oh My Zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 8. Install asdf
echo "Installing asdf..."
asdf_version=$(curl --silent "https://api.github.com/repos/asdf-vm/asdf/releases/latest" \
| grep '"tag_name":' \
| sed -E 's/.*"([^"]+)".*/\1/')
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch $asdf_version
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.zshrc
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.zshrc
source ~/.zshrc

# 9. Add plugins to asdf
asdf_plugins=(
  ruby
  nodejs
  yarn
  erlang
  java
)
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
echo "Installing asdf plugins..."
for plugin in "${asdf_plugins[@]}"; do
  echo "Installing $plugin..."
  asdf plugin-add "$plugin"
done
