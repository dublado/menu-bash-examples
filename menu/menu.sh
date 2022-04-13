#!/usr/bin/env bash
# set -eu
MENU_LOG=/tmp/menu.sh.log
MENU_INDEX=-1
MENU_COUNT=0
MENU_ACTIVE=""
MENU_OPTIONS=()

MENU_COLOR_OPTIONS=${MENU_COLOR_OPTIONS:-2}
MENU_COLOR_ACTIVE=${MENU_COLOR_ACTIVE:-0}
MENU_COLOR_ARROW=${MENU_COLOR_ARROW:-36}

### Prints the options
menu.show() {
  local counter=0
  for i in "${MENU_OPTIONS[@]}"
  do
    if [ "$i" = "$MENU_SELECTED" ]
    then
      MENU_INDEX=$counter
      printf "\033[%sm>\033[0m \033[%sm%s\033[0m\n" \
        $MENU_COLOR_ARROW $MENU_COLOR_ACTIVE "${i}"
    else
      printf "  \e[2m%s\e[22m\n" "${i}"
    fi
    counter=$((counter + 1))
  done
}

### Selects an active option by index, clears the screen and prints the options
menu.select() {
  local index=$1

  ### Boundary checks
  if [ $index -ge $MENU_COUNT ]
  then
    # echo "Max reached" >> $MENU_LOG
    index=$((MENU_COUNT - 1))
  elif [ $index -lt 0 ]
  then
    # echo "Min reached" >> $MENU_LOG
    index=0
  fi

  ### This clears <MENU_COUNT> lines
  echo -e "\033[$((MENU_COUNT + 1))A"
  MENU_SELECTED="${MENU_OPTIONS[index]}"
  menu.show
}

menu() {
  MENU_SELECTED=${1:-}
  MENU_COUNT=$(($# - 1))
  MENU_OPTIONS=(${@:2})

  ESCAPE_SEQ=$'\033'
  ARROW_UP=$'A'
  ARROW_DOWN=$'B'

  menu.show
  while true
  do
    read -rsn 1 key1
    case "$key1" in
      $ESCAPE_SEQ)
        read -rsn 1 -t 1 key2
        if [[ "$key2" == "[" ]]
        then
          read -rsn 1 -t 1 key3
          case "$key3" in
            $ARROW_UP)
              [[ $MENU_INDEX -eq 0 ]] \
                && menu.select $MENU_COUNT \
                || menu.select $((MENU_INDEX - 1))
              ;;
            $ARROW_DOWN)
              [[ $MENU_INDEX -eq $(( $MENU_COUNT - 1 )) ]] \
                && menu.select 0 \
                || menu.select $((MENU_INDEX + 1))
              ;;
          esac
        fi
        ;;

      "q")    unset MENU_SELECTED;  return ;;
      "")     export MENU_SELECTED; return ;;
    esac
  done
}

