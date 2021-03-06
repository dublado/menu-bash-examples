#!/bin/bash
TMPFILE=$(mktemp)

dialog --menu "Choose one:" 10 30 3 \
    1 Red \
    2 Green \
    3 Blue 2>$TMPFILE

RESULT=$(cat $TMPFILE)

case $RESULT in
    1) echo "Red";;
    2) echo "Green";;
    3) echo "Blue";;
    *) echo "Unknown color";;
esac

rm $TMPFILE
