# macOS-only aliases, linked to ~/.zsh/custom/aliases-os.zsh
# Portable aliases live in common/zsh/aliases.zsh

#-----------------------------------------------------------------------------------#
#	*START* HOSTS
#-----------------------------------------------------------------------------------#

alias hosts='sudo subl /etc/hosts'
alias vhosts='sudo subl /etc/apache2/extra/httpd-vhosts.conf'

#-----------------------------------------------------------------------------------#
#	*END* HOSTS
#-----------------------------------------------------------------------------------#


#-----------------------------------------------------------------------------------#
#	*START* NETWORK
#-----------------------------------------------------------------------------------#

# IP addresses
alias ip_intern="ipconfig getifaddr en0"

#-----------------------------------------------------------------------------------#
#	*END* NETWORK
#-----------------------------------------------------------------------------------#


#-----------------------------------------------------------------------------------#
#	*START* FILE HANDLING
#-----------------------------------------------------------------------------------#

# File size
alias fs="stat -f \"%z bytes\""

# Empty the Trash on all mounted volumes and the main HDD
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; rm -rfv ~/.Trash"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

#-----------------------------------------------------------------------------------#
#	*END* FILE HANDLING
#-----------------------------------------------------------------------------------#


#-----------------------------------------------------------------------------------#
#	*START* SPECIALS
#-----------------------------------------------------------------------------------#

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

#-----------------------------------------------------------------------------------#
#	*END* SPECIALS
#-----------------------------------------------------------------------------------#
