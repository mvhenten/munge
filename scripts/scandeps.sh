git grep -h -E '^\s+?use [[:alnum:]:]+;' | \
grep -v -E 'use [strict|utf8|warnings]' | \
grep -v 'Munge' | \
sed -E 's/\s+?use(.+);/\1/g'
