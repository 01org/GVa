#!/bin/bash

set -e

cd $(dirname $0)
mkdir -p m4
autoreconf -fi
./configure "$@"
