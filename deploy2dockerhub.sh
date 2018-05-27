#! /bin/sh

set -e

scriptdir=$(dirname $0)

. "$scriptdir/travis/utils.sh"
. "$scriptdir/travis/ansi_color.sh"
#disable_color

case $1 in
  "")    FILTER="/";;
  "ext") FILTER="/ext";;
  "pkg") FILTER="/pkg:all";;
  *)     FILTER="/ghdl /pkg";;
esac

echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
for key in $FILTER; do
  for tag in `echo $(docker images ghdl$key* | awk -F ' ' '{print $1 ":" $2}') | cut -d ' ' -f2-`; do
      if [ "$tag" = "REPOSITORY:TAG" ]; then break; fi
      echo "travis_fold:start:`echo $tag | grep -oP 'ghdl/\K.*'`"
      travis_time_start
      printf "$ANSI_YELLOW[DOCKER push] ${tag}$ANSI_NOCOLOR\n"
      docker push $tag
      travis_time_finish
      echo "travis_fold:end:`echo $tag | grep -oP 'ghdl/\K.*'`"
  done
done
docker logout
