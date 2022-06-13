
[jq json parser](https://stedolan.github.io/jq/download/)

You can build it using the usual ./configure && make && sudo make install rigmarole.

If you're interested in using the lastest development version, try:

```
git clone https://github.com/stedolan/jq.git
cd jq
autoreconf -i
./configure --disable-maintainer-mode
make
sudo make install
```
To build it from a git clone, you'll need to install a few packages first:

GCC
Make
Autotools