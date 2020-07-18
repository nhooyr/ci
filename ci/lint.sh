#!/bin/sh
set -eu

cd "$(dirname "$0")/.."
./lint.sh
