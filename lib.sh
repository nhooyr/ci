#!/bin/sh

set_shell_files() {
  if [ "${shell_files-}" ]; then
    return
  fi

  shell_files="$(shfmt -f $(git ls-files))"

  submodules_list="$(mktemp)"
  git config --file .gitmodules --get-regexp "path" | awk '{ print $2 }' > "$submodules_list"
  if [ -s "$submodules_list" ]; then
    shell_files="$(echo "$shell_files" | grep -Fvf "$submodules_list")"
  fi
}

is_go_package() {
  go list > /dev/null 2>&1
}
