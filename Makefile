# Makefile for cqfd6

PREFIX?=/usr/local

.PHONY: all help doc install install-cli-plugin uninstall user-uninstall-cli-plugin test tests check

all:	help

help:
	@echo "Available make targets:"
	@echo "   help:      This help message"
	@echo "   doc:       Generate documentation"
	@echo "   install:   Install script, doc and resources"
	@echo "   uninstall: Remove script, doc and resources"
	@echo "   tests:     Run functional tests"
	@echo "   clean:     Clean temporary files"

doc: cqfd.1.gz cqfdrc.5.gz

install:
	install -d $(DESTDIR)$(PREFIX)/bin/
	install -m 0755 cqfd $(DESTDIR)$(PREFIX)/bin/cqfd6
	ln -sf cqfd6 $(DESTDIR)$(PREFIX)/bin/cqfd
	install -d $(DESTDIR)$(PREFIX)/share/doc/cqfd6/
	install -m 0644 AUTHORS CHANGELOG.md LICENSE README.md $(DESTDIR)$(PREFIX)/share/doc/cqfd6/
	if [ -e cqfd.1.gz ]; then \
		install -d $(DESTDIR)$(PREFIX)/share/man/man1/; \
		install -m 644 cqfd.1.gz $(DESTDIR)$(PREFIX)/share/man/man1/; \
	fi
	if [ -e cqfdrc.5.gz ]; then \
		install -d $(DESTDIR)$(PREFIX)/share/man/man5/; \
		install -m 644 cqfdrc.5.gz $(DESTDIR)$(PREFIX)/share/man/man5/; \
	fi
	install -d $(DESTDIR)$(PREFIX)/share/cqfd6/samples/
	install -m 0644 samples/* $(DESTDIR)$(PREFIX)/share/cqfd6/samples/
	completionsdir=$${COMPLETIONSDIR:-$$(pkg-config --define-variable=prefix=$(PREFIX) \
	                                                --define-variable=datadir=$(PREFIX)/share \
	                                                --variable=completionsdir \
	                                                bash-completion)}; \
	if [ -n "$$completionsdir" ]; then \
		install -d $(DESTDIR)$$completionsdir/; \
		install -m 644 bash-completion $(DESTDIR)$$completionsdir/cqfd6; \
	fi

install-cli-plugin: DOCKERLIBDIR ?= $(PREFIX)/lib/docker
install-cli-plugin:
	install -D -m 755 docker-cqfd $(DESTDIR)$(DOCKERLIBDIR)/cli-plugins/docker-cqfd

uninstall:
	rm -rf $(DESTDIR)$(PREFIX)/bin/cqfd6 \
		$(DESTDIR)$(PREFIX)/bin/cqfd \
		$(DESTDIR)$(PREFIX)/share/man/man1/cqfd.1.gz \
		$(DESTDIR)$(PREFIX)/share/man/man5/cqfdrc.5.gz \
		$(DESTDIR)$(PREFIX)/share/doc/cqfd6 \
		$(DESTDIR)$(PREFIX)/share/cqfd6
	completionsdir=$${COMPLETIONSDIR:-$$(pkg-config --define-variable=prefix=$(PREFIX) \
	                                                --define-variable=datadir=$(PREFIX)/share \
	                                                --variable=completionsdir \
	                                                bash-completion)}; \
	if [ -n "$$completionsdir" ]; then \
		rm -rf $(DESTDIR)$$completionsdir/cqfd6; \
	fi

uninstall-cli-plugin: DOCKERLIBDIR ?= $(PREFIX)/lib/docker
uninstall-cli-plugin:
	rm -f $(DESTDIR)$(DOCKERLIBDIR)/cli-plugins/docker-cqfd

user-install user-uninstall user-install-cli-plugin user-uninstall-cli-plugin:
user-%:
	$(MAKE) $* PREFIX=$$HOME/.local BASHCOMPLETIONSDIR=$$HOME/.local/share/bash-completion/completions DOCKERLIBDIR=$$HOME/.docker

test tests:
	@$(MAKE) -C tests GIT_DIR=$(CURDIR)/.git

check:
	shellcheck cqfd
	@$(MAKE) -C tests check

clean:
	rm -f cqfd.1.gz cqfdrc.5.gz

%.1: %.1.adoc
	asciidoctor -b manpage -o $@ $<

%.5: %.5.adoc
	asciidoctor -b manpage -o $@ $<

%.gz: %
	gzip -c $^ >$@

%.tar.gz:
	git archive --prefix $*/ --format tar.gz --output $@ HEAD
