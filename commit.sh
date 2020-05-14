#!/bin/sh

COMMIT=$(git log --oneline $1 | tail -n 1 | awk '{print $1}')
git commit --fixup $COMMIT $1
