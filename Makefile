#!/usr/bin/make -f
INSTALL ?= install
PREFIX ?= /usr/local
MANPAGES ?= dh_python2.1 pycompile.1 pyclean.1

clean:
	find . -name '*.py[co]' -delete
	rm -f .coverage

install-dev:
	$(INSTALL) -m 755 -d $(DESTDIR)$(PREFIX)/bin \
		$(DESTDIR)$(PREFIX)/share/python/runtime.d
	$(INSTALL) -m 755 runtime.d/* $(DESTDIR)$(PREFIX)/share/python/runtime.d/

install-runtime:
	$(INSTALL) -m 755 -d $(DESTDIR)$(PREFIX)/share/python/debpython $(DESTDIR)$(PREFIX)/bin
	$(INSTALL) -m 644 debpython/*.py $(DESTDIR)$(PREFIX)/share/python/debpython/
	$(INSTALL) -m 755 pycompile $(DESTDIR)$(PREFIX)/bin/
	$(INSTALL) -m 755 pyclean $(DESTDIR)$(PREFIX)/bin/

install: install-dev install-runtime

check_versions:
	@set -e;\
	DEFAULT=`sed -rn 's,^DEFAULT = \(([0-9]+)\, ([0-9]+)\),\1.\2,p' debpython/version.py`;\
	SUPPORTED=`sed -rn 's,^SUPPORTED = \[\(([0-9]+)\, ([0-9]+)\)\, \(([0-9]+)\, ([0-9]+)\)\],\1.\2 \3.\4,p' debpython/version.py`;\
	DEB_DEFAULT=`sed -rn 's,^default-version = python([0-9.]*),\1,p' debian/debian_defaults`;\
	DEB_SUPPORTED=`sed -rn 's|^supported-versions = (.*)|\1|p' debian/debian_defaults | sed 's/python//g;s/,//g'`;\
	[ "$$DEFAULT" = "$$DEB_DEFAULT" ] || \
	(echo "Please update DEFAULT in debpython/version.py ($$DEFAULT vs. $$DEB_DEFAULT)" >/dev/stderr; false);\
	[ "$$SUPPORTED" = "$$DEB_SUPPORTED" ] || \
	(echo "Please update SUPPORTED in debpython/version.py ($$SUPPORTED vs. $$DEB_SUPPORTED)" >/dev/stderr; false)

pdebuild:
	pdebuild --debbuildopts -I

# TESTS
nose:
	nosetests --with-doctest --with-coverage

.PHONY: clean tests test% check_versions
