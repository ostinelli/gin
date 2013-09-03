# RALIS

## Installation

### MacOS

 * Install Perl Compatible Regular Expressions & LuaJIT:
```
$ brew install pcre luajit
````

 * Download & install OpenResty
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
