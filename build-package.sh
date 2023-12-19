#!/bin/bash

set -e

cd package

version=$(sed -n 's/.*"Version" *: *"\([^"]\+\)"[ ,]*/\1/p' metadata.json)
zip -9r "../audiodeviceswitcher-ng-v$version.plasmoid" *
