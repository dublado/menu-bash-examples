#!/bin/bash
# Bash Script with selection

PS3='What would you like for breakfast? '
menu=("Bacon and Eggs" "PB&J Sandwich" "Cereal" "Quit")
select option in "${menu[@]}"
do
    case $option in
        "Bacon and Eggs")
            echo "Option 1 selected"
            ;;
        "PB&J Sandwich")
            echo "Option 2 selected"
            ;;
        "Cereal")
            echo "Option 3 selected"
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
