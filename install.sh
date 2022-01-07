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
mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"	

# Install PHP extensions with PECL	
pecl pecl install imagick redis

# Install global Composer	
curl -sS https://getcomposer.org/installer | php	
mv composer.phar /usr/local/bin/composer	

# Install global Composer packages	
/usr/local/bin/composer global require laravel/installer laravel/spark-installer laravel/valet	

# Install Laravel Valet	
$HOME/.composer/vendor/bin/valet install	

# Create a Sites directories	
mkdir $HOME/Sites
mkdir $HOME/Sites/Tests	
mkdir $HOME/Sites/Packages	
mkdir $HOME/Sites/Forks	
mkdir $HOME/Sites/Clients

# Create directory for screenshots  
mkdir $HOME/Desktop/Screenshots/

# Clone Github repositories	
./clone.sh	

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles	
rm -rf $HOME/.zshrc	
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc	

# Install Pure theme
# Did not work on m1 globally anymore
#npm install --global pure-prompt
git clone https://github.com/sindresorhus/pure.git "$HOME/.dotfiles/plugins/pure"

# Install ZSH autosuggestion plugin	
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.dotfiles/plugins/zsh-autosuggestions	


# Symlink the Mackup config file to the home directory	
ln -s $HOME/.dotfiles/.mackup.cfg $HOME/.mackup.cfg	

# Set macOS preferences	
# We will run this last because this will reload the shell	
source .macos
