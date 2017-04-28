#!/bin/sh

rm -rf /output/*
echo $NETTY_TCNATIVE_TAG > /output/$NETTY_TCNATIVE_TAG
mkdir -p /output/openssl-dynamic
mkdir -p /output/openssl-static
mkdir -p /output/boringssl-static
mkdir -p /output/libressl-static

git clone https://github.com/netty/netty-tcnative
cd netty-tcnative
git checkout tags/$NETTY_TCNATIVE_TAG
#sed -i -e 's#<module>openssl-static</module>#<!--<module>openssl-static</module>-->#g' pom.xml
sed -i -e 's#<module>openssl-dynamic</module>#<!--<module>openssl-dynamic</module>-->#g' pom.xml
sed -i -e 's#<module>boringssl-static</module>#<!--<module>boringssl-static</module>-->#g' pom.xml
sed -i -e 's#<module>libressl-static</module>#<!--<module>libressl-static</module>-->#g' pom.xml
sed -i -e 's#<opensslVersion>1.0.2j</opensslVersion>#<opensslVersion>1.0.2k</opensslVersion>#g' pom.xml
sed -i -e 's#<opensslSha256>e7aff292be21c259c6af26469c7a9b3ba26e9abaaffd325e3dccc9785256c431</opensslSha256>#<opensslSha256>6b3977c61f2aedf0f96367dcfb5c6e578cf37e7b8d913b4ecb6643c3cb88d8c0</opensslSha256>#g' pom.xml

mvn clean package

mv openssl-static/target/*.jar /output/openssl-static
mv openssl-dynamic/target/*.jar /output/openssl-dynamic
mv boringssl-static/target/*.jar /output/boringssl-static
mv libressl-static/target/*.jar /output/libressl-static