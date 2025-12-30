# Dotfiles

- Here is the structure of the dotfiles

```txt
~/.dotfiles/
├── common/         # Common
├── os/             # OS-specific configs
│   ├── macos/
│   ├── arch/
│   └── wsl/
└── hosts/          # Machine-specific overrides (not used as of now)
    └── my-macbook/
```

- To stow them -

```sh
stow -d os/macos -t ~ alacritty zsh tmux
```

- The default behavior of stow is to create entire directories as symlinks.
  This creates problem when we add local configs. So added `--no-folding` in
  `.stowrc`.

  - This creates proper directories and only symlinks the files.
