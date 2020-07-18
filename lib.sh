#!/bin/sh

set_ignored_files() {
  if [ "${ignored_files-}" ]; then
    return
  fi

  ignored_files="$(mktemp)"
  git config --file .gitmodules --get-regexp "path" | awk '{ print $2 }' > "$ignored_files"
  git ls-files -io --exclude-standard --directory >> "$ignored_files"
}

set_shell_files() {
  if [ "${shell_files-}" ]; then
    return
  fi

  set_ignored_files
  shell_files="$(shfmt -f $(git ls-files))"
  if [ -s "$ignored_files" ]; then
    shell_files="$(echo "$shell_files" | grep -Fvf "$ignored_files" || true)"
  fi
}

is_go_package() {
  go list > /dev/null 2>&1
}
