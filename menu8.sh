SelectItemArrows() {	# [--nr] Request_string + Item list (strings). Exit: 0: valid selection, 1: empty list, 90: cancel. Returns (if exit-code: 0) to StdOut:
local ItemLinesShown=10 # Selected Item/Item's number (if option '--nr' supplied). Notes: Prints Item list + Request string to StdErr so that they are shown in
local PrintNumber=false # 'Selection=$(SelectItemArrows ...)'. Long lists will be partially shown (10 Lines only) but the user will be able to 'scroll' through
if [[ "$1" == "--nr" ]] # all Items. Examples: 'SelectItemArrows --nr "Select" One Two 3', 'SelectedItem=$(SelectItemArrows "Select Item" "${ItemList[@]}")'.
  then
    PrintNumber=true;shift
fi
if [[ $# -lt 2 ]]
  then		  
    return 1
fi
local Line Key ArrowDown ArrowLeft ArrowRight ArrowUp DeleteLine CursorUp
while read -r Line
  do
    Key="${Line%=*}"
    case "$Key" in
      key_down) ArrowDown="${Line#*=}";ArrowDown=$(printf '%b' "${ArrowDown%,*}");;
      key_left) ArrowLeft="${Line#*=}";ArrowLeft=$(printf '%b' "${ArrowLeft%,*}");;
      key_right) ArrowRight="${Line#*=}";ArrowRight=$(printf '%b' "${ArrowRight%,*}");;
      key_up) ArrowUp="${Line#*=}";ArrowUp=$(printf '%b' "${ArrowUp%,*}");;
      delete_line) DeleteLine="${Line#*=}";DeleteLine="${DeleteLine%,*}";;
      cursor_up) CursorUp="${Line#*=}";CursorUp="${CursorUp%,*}";;
    esac
  done < <(infocmp -L1 linux | egrep "key_down|key_left|key_right|key_up|delete_line|cursor_up") # Wrong values in terminal emulator with 'infocmp -L1 $TERM'.
local Char ItemNr Prefix ArrowPosition=0 ArrowNewPosition=1 ScrollShift=0 ScrollNewShift=0 Request="(↑↓ and →, cancel: ←) $1";shift
if [[ $# -lt $ItemLinesShown ]]
  then
    ItemLinesShown=$#
fi
Line=0
until [[ "$Key" == "$ArrowLeft" || "$Key" == "$ArrowRight" || "$Key" == "$(printf '%b' "\n")" ]] # $ArrowRight or "\n" (Enter): Select; $ArrowLeft: Cancel.
  do
    if [[ $ArrowPosition -ne $ArrowNewPosition || $ScrollShift -ne $ScrollNewShift ]]
      then
        ArrowPosition=$ArrowNewPosition;ScrollShift=$ScrollNewShift
        while [[ $Line -gt 0 ]]
          do # Delete lines written in previous main loop run.
            ((Line--))
             printf '%b' "${DeleteLine}${CursorUp}\r${DeleteLine}" 1>&2
          done # After loop $Line is 0.
        while [[ $Line -lt $ItemLinesShown ]]
          do # Write new lines according to new conditions.
            ((Line++))
            ((ItemNr = Line + ScrollShift))
            case  "$Line" in
              1)
                if [[ $ScrollShift -eq 0 ]]
                  then
                    Prefix=" "
                  else
                    Prefix="↑"
                fi;;
              ${ItemLinesShown})
                if [[ $ItemNr -lt $# ]]
                  then
                    Prefix="↓"
                  else
                    Prefix=" "
                fi;;
              *) Prefix=" ";;
            esac
            if [[ $ArrowPosition -eq $Line ]]
              then
                Prefix="${Prefix}→"
              else
                Prefix="${Prefix} "
            fi
            printf '%s\n' "${Prefix}'${!ItemNr}'" 1>&2
          done # After loop $Line is $ItemLinesShown.
        printf '\n%s' "$Request" 1>&2 # '\n%s': List + Empty line separator + Request. No NewLine after $Request.
        ((Line++)) # To account for Empty line separator.
    fi
    if read -s -r -n 1 Char
      then
        Key="$Char"
        while read -s -n 1 -t 0.01 Char # Timeout (ExitCode != 0) if no more characters available.
          do
            Key="${Key}$Char"
          done
    fi
    case $(printf '%b' "$Key") in
      ${ArrowUp})
        if [[ $ArrowPosition -gt 1 ]]
          then
            ((ArrowNewPosition--))
          else
            if [[ $ScrollShift -gt 0 ]]
              then
                ((ScrollNewShift--))
            fi
        fi;;
      ${ArrowDown})
        if [[ $ArrowPosition -lt $ItemLinesShown ]]
          then
            ((ArrowNewPosition++))
          else
            if [[ $ScrollShift -lt $(($# - ItemLinesShown)) ]]
              then
                ((ScrollNewShift++))
            fi
        fi;;
      ${ArrowRight});;
      ${ArrowLeft});;
    esac
  done
printf '\n' 1>&2 # $Request line was printed without NewLine.
if [[ "$Key" == "$ArrowLeft" ]]
  then
    return 90 # Selection cancelled by user.
fi # $ArrowRight or "\n" (Enter - undocumented) have been pressed.
((ItemNr = ArrowPosition + ScrollShift))
if $PrintNumber
  then
    printf '%s\n' $ItemNr
  else
    printf '%s\n' "${!ItemNr}"
fi
return 0
}
