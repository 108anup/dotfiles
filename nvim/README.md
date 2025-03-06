# Setup instructions
1. Install lua and luarocks.
```
sudo apt install lua5.1

curl -R -O http://www.lua.org/ftp/lua-5.4.7.tar.gz
tar -zxf lua-5.4.7.tar.gz
cd lua-5.4.7
make linux test
sudo make install
```
2. Install luarocks
```
wget https://luarocks.github.io/luarocks/releases/luarocks-3.11.1.tar.gz
tar -zxf luarocks-3.11.1.tar.gz
cd luarocks-3.11.1.tar.gz
./configure --with-lua-include=/usr/local/include
make
sudo make install
```
