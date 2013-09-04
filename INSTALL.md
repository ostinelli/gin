# RALIS

## Installation

### MacOS

##### Install Perl Compatible Regular Expressions & LuaJIT:
```
$ brew install pcre luajit
````

##### Download & install OpenResty
```
$ wget http://openresty.org/download/ngx_openresty-VERSION.tar.gz
$ tar zxvf ngx_openresty-VERSION.tar.gz
$ cd ngx_openresty-VERSION/
$ ./configure \
	--with-cc-opt="-I/usr/local/Cellar/pcre/PCRE-VERSION/include" \
	--with-ld-opt="-L/usr/local/Cellar/pcre/PCRE-VERSION/lib" \
	--with-luajit
$ make
$ make install
```

##### Configure the PATH
Assuming you have installed OpenResty into `/usr/local/openresty` (this is the default), we make our nginx executable of our OpenResty installation available in our PATH environment, adding at the end of `~/.bash_profile`:
```
export PATH=/usr/local/openresty/nginx/sbin:$PATH
```

##### Install Lua & Luarocks (Lua package manager)
```
$ brew install lua luarocks
```

##### Install test framework
```
luarocks install busted
```
