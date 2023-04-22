#!/bin/sh
cd openssl-3.1.0
mkdir -p build && cd build
../Configure no-ssl3 no-threads no-shared no-weak-ssl-ciphers enable-ec_nistp_64_gcc_128
make
make test
make install
cd /
rm -rf /openssl-3.1.0
rm -f build-openssl.sh
