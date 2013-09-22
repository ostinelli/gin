# RALIS
A fast, low-latency, low-memory footprint, HTTP 1.0 and 1.1 compliant web server framework with Test Driven Development helpers and patterns.

Ralis is mainly targeted for building API applications, when you need an extra-boost in performance and scalability. It is really easy to use, especially if you are familiar with Ruby on Rails.

## Installation

### OpenResty

Ralis runs on [OpenResty](http://http://openresty.org/), a customized bundle of [Nginx](http://nginx.org/).

#### MacOS
These instructions allow you to install Ralis on a developer machine.

##### HomeBrew
You don't need to have [HomeBrew](http://brew.sh/) installed, but you'll need to install a few dependencies and having HomeBrew will make it much easier.

If you don't have it, you can easily install it by running:
```
$ ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
```

##### Perl Compatible Regular Expressions & LuaJIT:
```
$ brew install pcre luajit
````

##### OpenResty
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
Assuming you have installed OpenResty into `/usr/local/openresty` (this is the default), make the nginx executable of your OpenResty installation available in the PATH environment, appending at the end of `~/.bash_profile`:
```
export PATH=/usr/local/openresty/nginx/sbin:$PATH
```

##### Lue & Luarocks (Lua package manager)
```
$ brew install lua luarocks
```

##### The test framework
```
luarocks install busted
```

##### The Json converter
```
luarocks install lua-cjson
```

##### Lua socket
```
luarocks install luasocket
```


## TODO:

 * add query strings to params
 * create response object passed in controllers
