#! /bin/bash

set -e

export PREFIX=$HOME/.bin && mkdir -p $PREFIX && export PATH=$PATH:$PREFIX/bin

if [ "$(expr substr $LUA 1 6)" == "luajit" ]; then
  git clone http://luajit.org/git/luajit-2.0.git luajit && cd luajit
  [[ "$LUA" == "luajit2.1" ]] && git checkout v2.1 || git checkout v2.0.4
  CFLAGS="$CFLAGS -DLUAJIT_ENABLE_LUA52COMPAT" make
  make PREFIX=$PREFIX INSTALL_TSYMNAME=lua install
  [[ -f $PREFIX/bin/lua ]] || ln -sf $PREFIX/bin/luajit-2.1.0-* $PREFIX/bin/lua
else
  [[ "$LUA" == "lua5.1" ]] && wget -O - http://www.lua.org/ftp/lua-5.1.5.tar.gz | tar xz
  [[ "$LUA" == "lua5.3" ]] && wget -O - http://www.lua.org/ftp/lua-5.3.0.tar.gz | tar xz
  [[ "$LUA" == "lua5.2" || "$LUA" == "lua" ]] && wget -O - http://www.lua.org/ftp/lua-5.2.4.tar.gz | tar xz
  cd lua-5.*
  sed -i -e 's/-DLUA_COMPAT_ALL//g' -e 's/-DLUA_COMPAT_5_2//g' src/Makefile
  make linux && make INSTALL_TOP=$PREFIX install
fi

cd .. && wget -O - http://luarocks.org/releases/luarocks-2.2.2.tar.gz | tar xz && cd luarocks-*

[[ "$(expr substr $LUA 1 6)" == "luajit" ]] && ./configure --prefix=$PREFIX \
  --with-lua-include=$PREFIX/include/luajit-2.$([ "$LUA" == "luajit2.1" ] && echo "1" || echo "0") || ./configure --prefix=$PREFIX

make build && make install && cd ..
rm -rf luajit; rm -rf lua-5.*; rm -rf luarocks-*

lua -v && luarocks --version
