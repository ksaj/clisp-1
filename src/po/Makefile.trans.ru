# This is the translator's makefile, not the user's makefile.

# Package name.
PACKAGE = clisp

# Language being translated.
LINGUA = ru

# Programs.
MSGMERGE = msgmerge -v -w 1000
GMSGFMT = gmsgfmt
MAKE = gmake

all : $(LINGUA).pox

.SUFFIXES:
.SUFFIXES: .po .pox .gmo

.po.pox:
	$(MAKE) -f Makefile.devel $(PACKAGE).pot
	$(MSGMERGE) $< $(PACKAGE).pot -o $*.pox

.po.gmo:
	$(GMSGFMT) -o $@ $<

