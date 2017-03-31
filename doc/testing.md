# Testing gin

## Prerequisites

Gin is meant to be run within [openresty](http://openresty.org/)
using [luadbi](https://code.google.com/p/luadbi/). Both need to
be installed to be able to run the busted test suite.

You need to install

- [luarocks](http://luarocks.org/)
- development versions of PostgreSQL and MySQL. You need at least
  the libraries and headers to compile the rocks, e.g 
	`apt-get install libpsql-dev libmysqlclient-dev`

You need to install the following rocks

- [busted](https://github.com/Olivine-Labs/busted). **It is vital
  to force the stable version**, e.g. `luarocks install busted 1.11.1`,
	because the current 2.0 revision does not work yet with gin.
	**If you have a newer busted version installed, purge it and 
	reinstall the stable version.**
- luadbi
- luadbi-postgres (you may need to pass the postgres headers location, e.g.
  `luarocks install luadbi-postgresql POSTGRES_INCDIR=/usr/include/postgresql/`)
- luadbi-mysql (you may need to pass the mysql headers location, e.g.
  `luarocks install luadbi-mysql MYSQL_INCDIR=/usr/include/mysql`)
- luaposix
- luasocket
- luafilesystem

## Running the busted test suite

For the basic test suite nothing more is needed. You should be able
to run the tests using `busted` from your local checkout.

Note that the test suite currently never actually launches nginx.
It sets the `'test'` environment preventing the launchers to 
actually do something. 

## Integration tests

For a full integration test it would be necessary that you have 
openresty installed, and that the openresty nginx binary is in your 
path. The test suite should then figure out a free port, actually
launch openresty with gin, fire some requests to that instance and
shut down the instance after testing is done.

`which nginx` should yield something 
like `/usr/local/openresty/nginx/sbin/nginx` with a vanilla 
openresty setup. If this is not the case, add the path:
`export PATH=/usr/local/openresty/nginx/sbin:$PATH`.
Verify that you can actually run this binary: `nginx`
