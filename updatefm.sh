#!/usr/bin/env bash

while getopts :i:d:p:r: option; do
  case "$option" in
    i ) instance="${OPTARG}" ;;
    d ) windowid="${OPTARG}" ;;
    p ) path="${OPTARG}" ;;
    r ) newrule="${OPTARG}" ;;
  esac
done

if [[ -n $newrule ]]; then
  # store/update newrule in dir-list
  parserules "$path" "$newrule"
else
  # or get the rule for the current dir (path)
  newrule="$(parserules "$path")" 
fi

oldrule="${instance#*-}"

if [[ $newrule != "$oldrule" ]]; then
  # apply new layout
  [[ $oldrule =~ (a|d)   ]] && oldorder="${BASH_REMATCH[1]}"
  [[ $oldrule =~ (s|t|n) ]] && oldsort="${BASH_REMATCH[1]}"
  [[ $oldrule =~ ([1-7]|l)   ]] && oldlayout="${BASH_REMATCH[1]}"
  [[ $newrule =~ (a|d)   ]] && neworder="${BASH_REMATCH[1]}"
  [[ $newrule =~ (s|t|n) ]] && newsort="${BASH_REMATCH[1]}"
  [[ $newrule =~ ([1-7]|l)   ]] && newlayout="${BASH_REMATCH[1]}"

  combo="ctrl+alt+shift+"

  if [[ $newlayout =~ [1-7] ]] || [[ ${oldsort}${oldorder} != "${newsort}${neworder}" ]]; then
    # switching to iconview in separate command to
    # add short sleep, otherwise sorttoggling
    # doesn't work properly..
    [[ $oldlayout = l ]] && iconkeys=("${combo}1")

      # iconsize
      [[ $newlayout =~ [1-7] ]] && [[ $oldlayout != "$newlayout" ]] && {
        case "$newlayout" in
          1 ) iconkeys+=("${combo}0" "alt+shift+minus" "alt+shift+minus" "alt+shift+minus") ;;
          2 ) iconkeys+=("${combo}0" "alt+shift+minus" "alt+shift+minus")  ;;
          3 ) iconkeys+=("${combo}0" "alt+shift+minus")    ;;
          4 ) iconkeys+=("${combo}0")   ;;
          5 ) iconkeys+=("${combo}0" "alt+shift+plus")    ;;
          6 ) iconkeys+=("${combo}0" "alt+shift+plus" "alt+shift+plus")   ;;
          7 ) iconkeys+=("${combo}0" "alt+shift+plus" "alt+shift+plus" "alt+shift+plus")  ;;
        esac
      }

      xdotool key --delay 8 --clearmodifiers --window "$windowid" ${iconkeys[*]}
      sleep .04
    fi


    [[ $oldorder  != "$neworder" ]] && keys+=("${combo}$neworder")
    [[ $oldsort   != "$newsort"  ]] && keys+=("${combo}$newsort")

  fi

  [[ $newlayout = l ]] && {
    [[ $newlayout != l ]] \
      && keys+=("${combo}0" "${combo}minus" "${combo}minus" "${combo}minus")
    keys+=("${combo}2")
  }

  xdotool key --delay 8 --clearmodifiers --window "$windowid" ${keys[*]} \
          set_window --classname "thunar-$newrule" "$windowid"

