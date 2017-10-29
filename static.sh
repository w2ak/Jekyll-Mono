#!/usr/bin/env bash
set -e

OWD=$(readlink -m $(dirname $0))
WD=$(mktemp -d)

cd $WD

git clone git@vps:x/cv.git cv
cd cv
make LANG=en cv
mkdir -p $OWD/about
cp en.pdf $OWD/about/clement.durand.cv.en.pdf

cd $WD

GNUPGHOME=$WD gpg2 --keyserver 'hkps://hkps.pool.sks-keyservers.net' --recv-key 0x15247DF0CB359C59 0xEF2D00C6CAA88D40
{
  GNUPGHOME=$WD gpg2 --no-comments --armor --export 0x15247DF0CB359C59
  echo ""
  GNUPGHOME=$WD gpg2 --list-keys 0x15247DF0CB359C59
  GNUPGHOME=$WD gpg2 --no-comments --armor --export 0xEF2D00C6CAA88D40
  echo ""
  GNUPGHOME=$WD gpg2 --list-keys 0xEF2D00C6CAA88D40
} > $OWD/publickey/clement.durand.asc

cd $OWD

rm -rf $WD
