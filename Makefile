# Makefile for cqfd

DESTDIR=/usr/local

.PHONY: all help install uninstall tests clean

all:	help

help:
	@echo "Available make targets:"
	@echo "   help:      This help message"
	@echo "   install:   Install script, doc and resources"
	@echo "   uninstall: Remove script, doc and resources"
	@echo "   tests:     Run functional tests"
	@echo "   clean:     Clean temporary files"

install: cqfd.1.gz cqfdrc.5.gz
	install -d $(DESTDIR)/bin
	install -m 0755 cqfd $(DESTDIR)/bin/cqfd
	install -d $(DESTDIR)/share/doc/cqfd
	install -m 0644 AUTHORS CHANGELOG LICENSE README.md $(DESTDIR)/share/doc/cqfd/
	install -d $(DESTDIR)/share/man/man1
	install -m 644 cqfd.1.gz $(DESTDIR)/share/man/man1
	install -d $(DESTDIR)/share/man/man5
	install -m 644 cqfdrc.5.gz $(DESTDIR)/share/man/man5
	install -d $(DESTDIR)/share/cqfd/samples
	install -m 0644 samples/* $(DESTDIR)/share/cqfd/samples

uninstall:
	rm -rf $(DESTDIR)/bin/cqfd \
		$(DESTDIR)/share/man/man1/cqfd.1.gz \
		$(DESTDIR)/share/man/man5/cqfdrc.5.gz \
		$(DESTDIR)/share/doc/cqfd \
		$(DESTDIR)/share/cqfd

tests:
	@make -C tests

clean:
	rm -f cqfd.1.gz cqfdrc.5.gz

%.gz: %
	gzip -c $^ >$@
