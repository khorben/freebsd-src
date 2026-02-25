pkg - a package manager for FreeBSD
====================================

 * Sourcehut FreeBSD: [![builds.sr.ht status](https://builds.sr.ht/~bapt/pkg/commits/master/freebsd.svg)](https://builds.sr.ht/~bapt/pkg/commits/master/freebsd?)
 * Sourcehut Alpine: [![builds.sr.ht status](https://builds.sr.ht/~bapt/pkg/commits/master/alpine.svg)](https://builds.sr.ht/~bapt/pkg/commits/master/alpine?)
 * Sourcehut Debian: [![builds.sr.ht status](https://builds.sr.ht/~bapt/pkg/commits/master/debian.svg)](https://builds.sr.ht/~bapt/pkg/commits/master/debian?)
 * Github Actions: [![build](https://github.com/freebsd/pkg/actions/workflows/build.yaml/badge.svg)](https://github.com/freebsd/pkg/actions/workflows/build.yaml)

Table of Contents:
------------------

* [libpkg](#libpkg)
* [pkg package format](#pkgfmt)
* [Installing packages](#pkginst)
* [pkg bootstrap](#pkgbootstrap)
* [Additional resources](#resources)


<a name="libpkg"></a>
### libpkg

pkg is built on top of libpkg, a new library to interface with the package
registration backends.
It abstracts package management details such as registration, remote
repositories, package creation, updating, etc.

<a name="pkgfmt"></a>
### pkg package format

The `pkg` package format is a tar archive that may be raw or compressed using one of the following algorithms: `gz`, `bzip2`, `zstd`, or `xz`. The default compression algorithm is `zstd`.

The tar archive itself is composed of two types of elements:

* the special files at the beginning of the archive, starting with a "+"
* the data.

<a name="pkginst"></a>
### Installing packages

pkg can install a package archive from the local disk, remote HTTP server or
remote SSH server.

<a name="pkgbootstrap"></a>
### Pkg bootstrap

Previous versions of FreeBSD contained a placeholder at /usr/sbin/pkg a.k.a
*pkg(7)*.  This small program had just the minimum functionality required to
install the real pkg(8).

pkg(7) intercepted the command, and if you confirmed that was your intention,
downloaded the pkg(8) tarball, installed pkg(8) from it, bootstrapped the local
package database and then proceeded to run the command originally requested.
This mechanism is no longer necessary or supported.

Later versions of pkg(7) understood `pkg -N` as a test to see if
pkg(8) was installed without triggering the installation, and
conversely, `pkg bootstrap [-f]` to install pkg(8) (or force it to be
reinstalled) without performing any other actions.
This test is no longer necessary or supported either.

<a name="resources"></a>
### Additional resources

* The Git repository of [pkg is hosted on GitHub](https://github.com/freebsd/pkg)

To contact us, you can find us in the **#pkg** channel on [Libera Chat IRC Network](https://libera.chat/).

If you hit a bug when using pkg, you can always submit an issue in the
[pkg issue tracker](https://github.com/freebsd/pkg/issues).
