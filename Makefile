# System-wide install, for packagers and `sudo make install`.
# Per-user installs: use ./install.sh instead.
#
#   make install PREFIX=/usr DESTDIR=pkgroot
#
# xscreensaver only looks for hack settings XML in the directory it was
# built with, which is /usr/share/xscreensaver/config on most distros.

PREFIX       ?= /usr/local
DESTDIR      ?=
BINDIR       ?= $(PREFIX)/bin
DOCDIR       ?= $(PREFIX)/share/doc/matrix-saver
XSS_CONFDIR  ?= /usr/share/xscreensaver/config

all:

install:
	install -Dm755 matrix-saver $(DESTDIR)$(BINDIR)/matrix-saver
	install -Dm644 xscreensaver/matrix-saver.xml $(DESTDIR)$(XSS_CONFDIR)/matrix-saver.xml
	install -Dm644 matrix-saver.conf.example $(DESTDIR)$(DOCDIR)/matrix-saver.conf.example
	install -Dm644 README.md $(DESTDIR)$(DOCDIR)/README.md

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/matrix-saver
	rm -f $(DESTDIR)$(XSS_CONFDIR)/matrix-saver.xml
	rm -rf $(DESTDIR)$(DOCDIR)

check:
	shellcheck matrix-saver install.sh tests/smoke.sh
	xmllint --noout xscreensaver/matrix-saver.xml

.PHONY: all install uninstall check
