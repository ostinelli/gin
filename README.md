# RALIS
A fast, low-latency, low-memory footprint, web JSON-API framework with Test Driven Development helpers and patterns.

Ralis is helpful when you need an extra-boost in performance and scalability. It is really easy to use, especially if you are familiar with Ruby on Rails.

## Installation
These instructions allow you to install Ralis on a OSX developer machine.

### 1. Homebrew
You don't need to have [HomeBrew](http://brew.sh/) installed, but you'll need to install a few dependencies and having HomeBrew will make it much easier.

If you don't have it, you can easily install it by running:
```
$ ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
```

### 2. OpenResty
Ralis runs on [OpenResty](http://openresty.org/), a customized bundle of [Nginx](http://nginx.org/).

#### 2.1 Install Perl Compatible Regular Expressions & LuaJIT:
```
$ brew install pcre luajit
````

#### 2.2 Install OpenResty
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

#### 2.3 Configure the PATH to OpenResty
Assuming you have installed OpenResty into `/usr/local/openresty` (this is the default), make the nginx executable of your OpenResty installation available in the PATH environment, appending at the end of `~/.bash_profile`:
```
export PATH=/usr/local/openresty/nginx/sbin:$PATH
```

### 3. Lua & Luarocks
Lua and a lua package manager.

```
$ brew install lua luarocks
```

### 4. Ralis
```
$ git clone git@github.com:ostinelli/ralis.git
$ cd ralis
$ luarocks make
```

## Using models

Initialize a DB, let's say that it's called `DB` for the purpose of this example.

Create models like this:

```
DB:define_model('User', 'users')
```

Use the model in controllers:

```
local users = User.all()
```
