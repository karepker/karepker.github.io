#! /bin/bash

root_dir="$(cd "$(dirname $0)/../"; pwd -P)"

bbb2 sync --replace-newer "${root_dir}/media" b2://karepker-com/
