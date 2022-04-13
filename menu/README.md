# menu.sh

A shell library to select menu options.


## Installation

```
curl -LOs https://raw.githubusercontent.com/jpedro/menu.sh/master/menu.sh
```


## Usage

After sourcing the `menu.sh` file just call `menu` with the first
argument being the active (selected option) and all other arguments
being the whole list of options.

The menu selected option will be available on `$MENU_SELECTED`.

```
cat <<EOS > example.sh
#!/usr/bin/env bash

source ./menu.sh
menu v2 v1 v2 v3
echo "You selected version \$MENU_SELECTED."
EOS

bash example.sh
```

Pressing `Ctrl+C` or `q` when the menu is shown will result in an unset
`$MENU_SELECTED`.


### Options

| Environment variable    | Usage                                                     | Default                   |
|-------------------------|-----------------------------------------------------------|-------------------------- |
| `MENU_COLOR_OPTIONS`    | The not-highlighted colour of the options                 | bash color 2 (greyed out) |
| `MENU_COLOR_ACTIVE`     | The colour of the highlighted option                      | bash color 0 (default)    |
| `MENU_COLOR_ARROW`      | The colour of the arrow next to the highlighted option    | bash color 36 (green)     |
