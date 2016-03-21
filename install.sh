#! /bin/sh

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

#install Command Line Tools
xcode-select --install

# borrowed from https://github.com/thoughtbot/laptop
append_to_zshrc() {
  local text="$1" zshrc
  local skip_new_line="${2:-0}"

  if [ -w "$HOME/.zshrc.local" ]; then
    zshrc="$HOME/.zshrc.local"
  else
    zshrc="$HOME/.zshrc"
  fi

  if ! grep -Fqs "$text" "$zshrc"; then
    if [ "$skip_new_line" -eq 1 ]; then
      printf "%s\n" "$text" >> "$zshrc"
    else
      printf "\n%s\n" "$text" >> "$zshrc"
    fi
  fi
}

echo "Checking for Homebrew..."
if test ! $(which brew); then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Updating brew..."
brew update

echo "Installing GNU core utils (those that come with OS X are outdated)..."
brew install coreutils

echo "Installing more recent versions of some OS X tools..."
brew tap homebrew/dupes
brew install homebrew/dupes/grep

binaries=(
  autojump
  curl
  ffmpeg
  git
  git-extras
  grep
  imagemagick --with-webp
  mackup
  node
  the_silver_searcher
  wget
  youtube-dl
  zsh
  zsh-history-substring-search
  zsh-syntax-highlighting
)

echo "Installing binaries..."
brew install ${binaries[@]}

echo "Cleaning up..."
brew cleanup

echo "Installing Cask..."
brew install caskroom/cask/brew-cask

echo "Adding nightly/beta Cask versions..."
brew tap caskroom/versions

# Apps
apps=(

  # Dev
  Anvil # Manage local sites
  iterm2-beta
  sublime-text3

  # productivity, core, runtimes
  blockblock
  doxie
  flux
  imageoptim
  macdown
  omnidisksweeper
  shrinkit # reduce pdf file size

  # Quicklook - https://github.com/sindresorhus/quick-look-plugins
  betterzipql
  qlcolorcode
  qlimagesize
  qlmarkdown
  qlstephen
  quicklook-csv
  quicklook-json

  # A/V
  handbrake
  handbrakebatch
  max
  sonos
  transmission
  vlc

  # sharing
  dropbox

  # browsers
  firefox
  google-chrome
  google-chrome-canary

  # entertainment
  battle-net
)

echo "Installing apps to /Applications..."
brew cask install --appdir="/Applications" ${apps[@]}

brew cask cleanup

echo "Making autojump work with zsh..."
append_to_zshrc '[[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh'

echo "Add syntax highlighting"
append_to_zshrc 'source `brew --prefix`/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'

#https://github.com/zsh-users/zsh-history-substring-search
echo "Add substring history searching ** must come after syntax highlighting **"
append_to_zshrc 'source `brew --prefix`/opt/zsh-history-substring-search/zsh-history-substring-search.zsh'
append_to_zshrc 'setopt HIST_FIND_NO_DUPS'

echo "Generating SSH keys (https://help.github.com/articles/generating-ssh-keys)..."
ssh-keygen -t rsa -C "mail@digitalpuddle.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
pbcopy < ~/.ssh/id_rsa.pub
open https://github.com/settings/ssh

echo "Installing nvm..."
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.26.1/install.sh | bash

echo "Installing global node packages..."
node_packages=(
  caniuse-cmd
  diff-so-fancy
  eslint
  gulp
  imageoptim-cli
  listg # list global node modules
  pure-prompt # nice prompt for zsh
)
npm install -g ${node_packages[@]}

#reload zshrc
source ~/.zshrc

echo "Customizing Sublime..."

# download and "install" Package Control
wget https://sublime.wbond.net/Package\ Control.sublime-package && mv Package\ Control.sublime-package ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages

# TODO: Add these (or atom packages/prefs and app)

# download and "install" Preferences file
# wget https://rawgit.com/kangax/osx/master/Preferences.sublime-settings && mv Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User

# download and "install" Packages file
# wget https://rawgit.com/kangax/osx/master/Package\ Control.sublime-settings && mv Package\ Control.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User

echo "***** Install App store Apps *****"
