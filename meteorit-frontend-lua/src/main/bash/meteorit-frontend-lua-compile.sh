#!/bin/bash

cd '${project.build.directory}/${lua.name_}'


if [ -e src/luajit ]; then
	echo 'Lua already built, skipping'
	exit 0
fi

echo 'Starting lua build...'

echo 'Compiling:'
# The amalg build optimises the resulting binary
make amalg PREFIX=${lua.installfolder_} | pv -l -f -p -s 32  > ./make.output

# the make install script uses a prefix DESTDIR environment variable which we use to create a complete temp install
echo 'Installing:'
make install PREFIX=${lua.installfolder_} DESTDIR=${lua.tempfolder_} | pv -l -f -p -s 18 >> ./make.output

echo 'Starting LuaRedisParser build...'
cd '${lua-redisparser.sourcefolder_}'
make PREFIX=${lua.installfolder_} \
	 LUA_INCLUDE_DIR="${lua.tempfolder_}/${lua.installfolder_}/include/luajit-2.0" \
	 LUA_LIB_DIR=${lua.tempfolder_}/${lua.installfolder_}/lib/lua/5.1 | pv -l -f -p -s 1 >> ./make.output
echo 'Installing to target folder:'
make install DESTDIR=${lua.tempfolder_} LUA_LIB_DIR=${lua.installfolder_}/lib/lua/5.1 | pv -l -f -p -s 1 >> ./make.output
#make test

echo 'Completed'