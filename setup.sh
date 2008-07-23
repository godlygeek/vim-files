#!/bin/sh

# Requires GNU Coreutils for stat(1) and perl for relative paths
# Works with posh, should work with any POSIX-compliant shell


SRC="$(pwd)"
DST="$HOME"
FFLAG=0
VFLAG=0

usage() {
  echo >&2 "Usage: $0 [-vf]"
  echo >&2 "\t-v  Be more verbose"
  echo >&2 "\t-f  Force removal of existing files"
  exit 1
}

linkfile() {
  # Link "$1" from "$DST" to "$SRC"
  # Abort if the file already exists as something other than the correct link
  # unless $FFLAG is set, to force us to remove it.
  if [ $# != 1 ]; then
    echo >&2 "linkfile(file) called with wrong args"
    exit 1
  elif [ "$FFLAG" -eq 0 -a -e "$DST/$1" ]; then
    if [ $(stat -Lc %i "$DST/$1") -ne $(stat -Lc %i "$SRC/$1") ]; then
      echo >&2 "$DST/$1 exists and -f not given; skipping."
    elif [ "$VFLAG" -ne 0 ]; then
      echo "Link $DST/$1 already exists, skipping."
    fi
    return
  fi

  local path
  src=$(perl -MFile::Spec -le 'print File::Spec->abs2rel(@ARGV)' "$SRC" "$DST")

  ( cd "$DST" && ln -sf "$src/$1" )
}


while getopts vf flag; do
  case "$flag" in
    v)   VFLAG=$(($VFLAG+1)) ;;
    f)   FFLAG=$(($FFLAG+1)) ;;
    [?]) usage ;;
  esac
done

shift $(($OPTIND-1))

[ $# != 0 ] && usage

cat links | sed -e '/\s*#/d' -e '/^\s*$/d' | while read file; do
  linkfile "$file"
done
