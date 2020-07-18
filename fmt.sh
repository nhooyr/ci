#!/bin/sh
set -eu

main() {
  . "$(dirname $0)/lib.sh"

  run_prettier
  run_shfmt

  if is_go_package; then
    go mod tidy
    gofmt -w -s .
    goimports -w "-local=$(go list -m)" .
  fi

  if [ "${CI-}" ]; then
    assert_unchanged
  fi
}

run_prettier() {
  set_ignored_files

  npx prettier \
    --write \
    --print-width=120 \
    --no-semi \
    --trailing-comma=all \
    --no-bracket-spacing \
    --arrow-parens=avoid \
    "--ignore-path=$ignored_files" \
    . || true
}

run_shfmt() {
  set_shell_files
  shfmt -i 2 -w -s -sr $shell_files || true
}

assert_unchanged() {
  # Cannot use git-diff here to check as it does not keep see untracked files.
  changed_files="$(git ls-files --other --modified --exclude-standard)"
  if [ ! "$changed_files" ]; then
    return
  fi

  echo "$changed_files" | sed "s/^/~ /"
  echo

  git -c color.ui=always --no-pager diff
  echo

  echo "Please run:"
  echo "./ci/fmt.sh"
  exit 1
}

main "$@"
