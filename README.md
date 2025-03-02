# Dotfiles
This repo contains my personal files for setting up a (new) Mac, both personal and work related things in separated files.

The order of the steps is critical to make sure everything works as expected


## iTerm2
Since we are going to use this to install all other things: download and install [iTerm2 from here](https://iterm2.com/)


## OMZ
Oh My Zsh is a must for me, get that [from here](https://ohmyz.sh/#install)


## Homebrew
Now the terminal is fixed, lets (install Homebrew)[https://brew.sh/] to install all other software

Install casks:
```~/dotfiles/install-homebrew-casks.sh```

Install formulae:
```~/dotfiles/install-homebrew-formulae.sh```

### Enable syncthing
Run

```brew services start syncthing``` 


### Enabling fzf

Run:

```sh
/opt/homebrew/opt/fzf/install
```

Prompt answers:

- `Do you want to enable fuzzy auto-completion? ([y]/n)` → `y`
- `Do you want to enable key bindings? ([y]/n)` → `y`
- `Do you want to update your shell configuration files? ([y]/n)` → `n`
