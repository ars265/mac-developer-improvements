#!/bin/bash

display_name="" #example: Joe Smith
user_email="" #example: user@gmail.com
git_username="" #example: jsmith
env_shell="bash" #examples: bash, zsh

if [ "$(uname)" != "Darwin" ]; then
    echo "This script has been designed for Mac, unable to continue."
    exit 1
fi

# ask for admin password upfront
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

current_working_dir=$(pwd)
current_os_username=$(id -un)
shell_profile="$HOME/.bash_profile"

if [ "$env_shell" == "zsh" ]; then
    shell_profile="$HOME/.zshrc"
fi

# Mac level settings

# Sleep the display after 15 minutes
sudo pmset -a displaysleep 15
# Set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2
# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
# Disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false
# Disable automatic period substitution as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# Disable “natural” (Lion-style) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 1000
# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"
# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"
# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true
# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true
# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true
# Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true
# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool true
# Set the icon size of Dock items to 36 pixels
defaults write com.apple.dock tilesize -int 36
# Change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "scale"
# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true
# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true
# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool true
# Don’t animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false
# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1
# Don’t group windows by application in Mission Control
# (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock expose-group-by-app -bool false
# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false
# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0
# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0
# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true
# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false
# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4
# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
# Automatically download apps purchased on other Macs
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1
# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true
# Disable the all too sensitive backswipe on trackpads
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

for app in "Dock" \
	"Finder" \
	"Google Chrome" \
	"SystemUIServer"; do
	killall "${app}" &> /dev/null
done


if ! grep -q -m 1 'export EDITOR="code -w"' "$shell_profile"; then
    echo '
export EDITOR="code -w"' >> $shell_profile
fi

if ! grep -q -m 1 'export BLOCKSIZE=1k' "$shell_profile"; then
    echo '
export BLOCKSIZE=1k' >> $shell_profile
fi

if ! grep -q -m 1 'export PATH="$PATH:/usr/local/bin/"' "$shell_profile"; then
    echo '
export PATH="$PATH:/usr/local/bin/"' >> $shell_profile
fi

if [ "$env_shell" == "bash" ] && ! grep -q -m 1 'export BASH_SILENCE_DEPRECATION_WARNING=1' "$shell_profile"; then
    echo '
export BASH_SILENCE_DEPRECATION_WARNING=1' >> $shell_profile
fi

if [ "$env_shell" == "zsh" ] && ! grep -q -m 1 'setopt shwordsplit' "$shell_profile"; then
    echo "Configuring ZSH shell for compatability."
    echo '
setopt shwordsplit
setopt GLOB_COMPLETE
unsetopt EQUALS
unsetopt nomatch' >> $shell_profile
fi

if ! which xcodebuild; then
    echo "Installing XCode Tools."
    xcode-select --install
fi

if ! which brew; then
    echo "Installing Brew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo '
eval "$(/opt/homebrew/bin/brew shellenv)"' >> $shell_profile
fi

brew update && brew upgrade && brew cleanup
# install basic tooling
brew install jq git coreutils wget gnupg moreutils pyenv nvm
# install VS Code
brew install --cask visual-studio-code


# if either is set then the user already made one prior
if [ ! -f ~/.ssh/id_rsa ] && [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Generating machine SSH key for machine access, you may be prompted for information."
    ssh-keygen -t ed25519 -C "$sf_email"
    new_machine_key_generated="true"

    echo "A new SSH key has been generated for this machine."
fi

# aliases to make better defaults
if ! grep -q -m 1 'alias mkdir' "$shell_profile"; then
    echo '
alias mkdir="mkdir -pv"' >> $shell_profile
fi

if ! grep -q -m 1 'alias la' "$shell_profile"; then
    echo '
alias la="ls -la"' >> $shell_profile
fi

if ! grep -q -m 1 'alias lr' "$shell_profile"; then
    echo "
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'''" >> $shell_profile
fi

# git settings that make life easier
git config --global user.name "$display_name"
git config --global user.email "$user_email"
git config --global core.autocrlf input
git config --global pull.rebase true
git config --global --bool push.autoSetupRemote true
git config --global column.ui auto
git config --global branch.sort -committerdate
git config --global tag.sort version:refname
git config --global init.defaultBranch main
git config --global diff.algorithm histogram
git config --global diff.colorMoved plain
git config --global diff.mnemonicPrefix true
git config --global diff.renames true
git config --global push.followTags true
git config --global fetch.prune true
git config --global fetch.pruneTags true
git config --global fetch.all true
git config --global help.autocorrect prompt
git config --global rerere.enabled true
git config --global rerere.autoupdate true
git config --global core.excludesfile ~/.globalignore
git config --global rebase.autoSquash true
git config --global rebase.autoStash true
git config --global rebase.updateRefs true

echo "Now you'll want to:"
echo " - Update your ssh key on Github"
echo " - You may need to restart your machine to complete the process"

# Sources:
# https://gist.github.com/natelandau/10654137
# https://github.com/mathiasbynens/dotfiles/blob/master/.macos

