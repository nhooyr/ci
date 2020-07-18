#!/bin/sh
set -eu

main() {
  go test -cover -coverprofile=ci/out/coverage.prof -coverpkg=./... "$@" ./...
  if [ "$GO_COVERAGE_IGNORE" ]; then
    new_coverage="$(mktemp)"
    grep -Fvf "$GO_COVERAGE_IGNORE" ci/out/coverage.prof > "$new_coverage"
    mv "$new_coverage" ci/out/coverage.prof
  fi

  # Last line is the total coverage.
  go tool cover -func ci/out/coverage.prof | tail -n1
  go tool cover -html=ci/out/coverage.prof -o=ci/out/coverage.html

  if [ "$NETLIFY_AUTH_TOKEN" ]; then
    if [ "${CI-}" ] && echo "${GITHUB_REF-}" | grep -q "master$"; then
      deploy_dir="$(mktemp -d)"
      cp ci/out/coverage.html "$deploy_dir/index.html"
      netlify deploy --prod "--dir=$deploy_dir"
    fi
  fi
}

main "$@"
