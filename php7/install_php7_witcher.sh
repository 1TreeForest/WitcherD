#!/bin/sh

rm -rf ./php-src-PHP-7.3.3;
unzip -q php-src-PHP-7.3.3.zip -d .
cd ./php-src-PHP-7.3.3;

cp ../witcher-php-install/* .;
patch -p1 < *.patch;

./buildconf --force;
autoconf;
./configure --prefix=/usr/local/php7-witcher;

make;
make test;
# sudo make install;
