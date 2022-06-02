If you obtained a source tarball from the "Releases" section of the main site just use the standard autotools commands:


```
$ ./configure
$ make
$ make install
To run the test suite, invoke:
```

$ make check
If the source has been checked out from a Git repository, the ./configure script has to be generated first. The easiest way is to use autoreconf:

$ autoreconf -i