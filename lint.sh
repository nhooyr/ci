#!/bin/sh
set -eu

main() {
  . "$(dirname $0)/lib.sh"

  set_shell_files
  if [ "$shell_files" ]; then
    shellcheck -e SC1090,SC2086,SC2154,SC2046,SC1091 $shell_files
  fi

  if is_go_package; then
    go vet ./...
    golint -set_exit_status ./...
  fi
}

main "$@"
