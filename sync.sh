#!/bin/sh

set -e

. $(git --exec-path)/git-sh-setup

require_work_tree

if [ x"$1" = xpull ]; then
  echo "pulling from origin"
  git pull

  git remote -v | sed 's/\t.*//' | while read remote; do
    if [ x"$remote" != xorigin ]; then
      echo "pulling from $remote"
      git subtree pull --prefix="runtimes/$remote" "$remote" "master"
    fi
  done
fi

if [ x"$1" = xpush ]; then
  git remote -v | sed 's/\t.*//' | while read remote; do
    if [ x"$remote" != xorigin ]; then
      echo "pushing to $remote"
      git push "$remote" "$(git subtree split --prefix="runtimes/$remote"):master"
    fi
  done

  echo "pushing to origin"
  git push
fi
