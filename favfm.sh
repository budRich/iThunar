#!/usr/bin/env bash

# --MODE history, bookmark, both(default)

# ENVIRONMENT variables:
: "${LAUNCHFM_DEFAULT_CONTAINER:=D}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${THUNAR_HISTORY:="$XDG_CONFIG_HOME/Thunar/history"}"
: "${THUNAR_BOOKMARKS:="$XDG_CONFIG_HOME/Thunar/bookmarks"}"

main() {
  local dest

  # expands leading literal tilde to HOME
  [[ ${dest:=$1} =~ ^[~] ]] && dest=${1/'~'/~}

  if [[ -d $dest ]]; then
    updatehistory "$dest"
  else
    trgcon="${1:-$LAUNCHFM_DEFAULT_CONTAINER}"

    dest="$(cat "$THUNAR_BOOKMARKS" "$THUNAR_HISTORY" | \
            i3menu --prompt "'GoTo: '" \
                   --layout "$trgcon"  \
                   --top "$(cat "$THUNAR_BOOKMARKS")" \
           )"

    [[ -z $dest ]] && exit 1
    [[ $dest =~ ^[~] ]] && dest=${dest/'~'/~}

    [[ -d $dest ]] || {
      notify-send "favfm: dir $dest doesn't exist"
      updatehistory remove "$dest"
      exit 1
    }

    launchfm -c "$trgcon" -p "$dest"
  fi
}

updatehistory() {

  # ${!#} is last arg ($1 can be command remove)
  local tmpfile dest=${!#}

  # translate leading HOME to '~'
  [[ ${dest:=${!#}} =~ ^$HOME ]] && dest=${dest/~/'~'}

  {
    [[ $1 = remove ]] || echo "$dest"
    # remove entries with both variants of home
    [[ -f $THUNAR_HISTORY ]] \
      && grep -Ev "^$dest|${dest/'~'/~}" "$THUNAR_HISTORY"
  } > "${tmpfile:=$(mktemp)}"

  mv -f "$tmpfile" "$THUNAR_HISTORY"
  
}

main "${@}"


