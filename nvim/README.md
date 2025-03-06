# Setup instructions
0. `sudo apt install ripgrep fd-find`
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
3. `cargo install --locked tree-sitter-cli`
4. Install npm
```
# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
nvm install 22

# Verify the Node.js version:
node -v # Should print "v22.14.0".
nvm current # Should print "v22.14.0".

# Verify npm version:
npm -v # Should print "10.9.2".
```
