#! /bin/bash

root_dir="$(cd "$(dirname $0)/../"; pwd -P)"
~/.local/bin/build_website --site webzone --root "$root_dir" --output "${root_dir}/_site"
