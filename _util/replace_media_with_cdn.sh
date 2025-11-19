#! /bin/bash

if (( $# < 1 )); then
	echo "Usage: $0 FILE"
	exit 1
fi

# Match:
# 1. Cover image.
# 2. Inline markdown images.
# 3. Named markdown images.
sed -i \
	-e 's#^image: /media/\([^ ]\+\)$#image: https://media.karepker.com/file/karepker-com/\1#g' \
	-e 's#^!\[\([^]]\+\)\](/media/\([^ ]\+\))$#![\1](https://media.karepker.com/file/karepker-com/\2)#g' \
	-e 's#^\[\([^]]\+\)\]: /media/\([^ ]\+\)$#[\1]: https://media.karepker.com/file/karepker-com/\2#g' \
	"$1"
