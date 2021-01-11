#!/bin/sh

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle

# Set default MySQL root password and auth type.
mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"

# Install PHP extensions with PECL
pecl install memcached imagick

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Install global Composer packages
/usr/local/bin/composer global require laravel/installer laravel/spark-installer laravel/valet

# Install Laravel Valet
$HOME/.composer/vendor/bin/valet install

# Create a Sites directory
mkdir $HOME/Sites

# Create a Test Sites directory
mkdir $HOME/Sites/Tests

# Create Packages directory
mkdir $HOME/Sites/Packages

# Create Forks directory
mkdir $HOME/Sites/Forks

# Create Clients directory
mkdir $HOME/Sites/Clients

# Clone Github repositories
./clone.sh

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf $HOME/.zshrc
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc

# Install Pure theme
npm install --global pure-prompt

# Install ZSH autosuggestion plugin
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.dotfiles/plugins/zsh-autosuggestions


# Symlink the Mackup config file to the home directory
ln -s $HOME/.dotfiles/.mackup.cfg $HOME/.mackup.cfg

# Create directory for screenshots
mkdir $HOME/Desktop/Screenshots/

# Set macOS preferences
# We will run this last because this will reload the shell
source .macos
