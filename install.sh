#!/bin/sh

echo "Setting up your Mac ❤️..."	

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it	
if test ! $(which brew); then	
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf $HOME/.zshrc
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc

# Update Homebrew recipes	
brew update

# Install Rosetta
sudo softwareupdate --install-rosetta

# Install all the dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew tap homebrew/cask-drivers
brew bundle --file $HOME/.dotfiles/Brewfile

# Set default MySQL root password and auth type.
# brew services restart mysql
# mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"	


# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles	
rm -rf $HOME/.zshrc	
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc	

mkdir $HOME/.zsh/custom
ln -s $HOME/.dotfiles/aliases.zsh $HOME/.zsh/custom/aliases.zsh

# Install tmux package manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install Pure theme
# Did not work on m1 globally anymore
git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"

# Install ZSH autosuggestion plugin	
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH/custom/plugins/zsh-autosuggestions"	

# Install zsh-nvm
git clone https://github.com/lukechilds/zsh-nvm.git "$ZSH/custom/plugins/zsh-nvm"
source $ZSH/custom/plugins/zsh-nvm/zsh-nvm.plugin.zsh

# Install aws-mfa
git clone --depth=1 https://github.com/joepjoosten/aws-cli-mfa-oh-my-zsh.git "$ZSH/custom/plugins/aws-mfa"

# # Symlink the Mackup config file to the home directory	
ln -s $HOME/.dotfiles/.mackup.cfg $HOME/.mackup.cfg	

# Set macOS preferences	
# We will run this last because this will reload the shell	
# TODO check the contents of the file; adjust; uncomment line bellow
source .macos

