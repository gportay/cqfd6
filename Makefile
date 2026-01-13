# Makefile for cqfd6

PREFIX ?= /usr/local
VERSION ?= $(shell bash cqfd --version)
COMPAT ?= $(shell bash cqfd --compatibility)

.PHONY: all help doc install uninstall test tests check clean maintainer-clean sources FORCE

all:	help

help:
	@echo "Available make targets:"
	@echo "   help:      This help message"
	@echo "   doc:       Generate documentation"
	@echo "   install:   Install script, doc and resources"
	@echo "   uninstall: Remove script, doc and resources"
	@echo "   test:      Run functional tests"
	@echo "   check:     Run analysis tool"
	@echo "   clean:     Clean temporary files"
	@echo "   sources:   Make sources needed for packaging."

doc: cqfd.1.gz cqfdrc.5.gz

install: DOCKERLIBDIR ?= $(PREFIX)/lib/docker
install:
	install -d $(DESTDIR)$(PREFIX)/bin/
	install -m 0755 cqfd $(DESTDIR)$(PREFIX)/bin/cqfd$(COMPAT)
	for i in linux-amd64 linux-arm linux-arm64 linux-ppc64le linux-riscv64 linux-s390x; do \
		ln -sf cqfd6 $(DESTDIR)$(PREFIX)/bin/$$i-cqfd6; \
	done
	install -D -m 755 docker-cqfd $(DESTDIR)$(DOCKERLIBDIR)/cli-plugins/docker-cqfd
	install -d $(DESTDIR)$(PREFIX)/share/doc/cqfd6/
	install -m 0644 AUTHORS CHANGELOG.md LICENSE README.md $(DESTDIR)$(PREFIX)/share/doc/cqfd6/
	if [ -e cqfd.1.gz ]; then \
		install -d $(DESTDIR)$(PREFIX)/share/man/man1/; \
		install -m 644 cqfd.1.gz $(DESTDIR)$(PREFIX)/share/man/man1/cqfd6.1.gz; \
	fi
	if [ -e cqfdrc.5.gz ]; then \
		install -d $(DESTDIR)$(PREFIX)/share/man/man5/; \
		install -m 644 cqfdrc.5.gz $(DESTDIR)$(PREFIX)/share/man/man5/cqfdrc6.5.gz; \
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

uninstall: DOCKERLIBDIR ?= $(PREFIX)/lib/docker
uninstall:
	rm -rf $(DESTDIR)$(PREFIX)/bin/cqfd6 \
	        $(DESTDIR)$(DOCKERLIBDIR)/cli-plugins/docker-cqfd \
		$(DESTDIR)$(PREFIX)/share/man/man1/cqfd6.1.gz \
		$(DESTDIR)$(PREFIX)/share/man/man5/cqfdrc6.5.gz \
		$(DESTDIR)$(PREFIX)/share/doc/cqfd6 \
		$(DESTDIR)$(PREFIX)/share/cqfd6
	for i in linux-amd64 linux-arm linux-arm64 linux-ppc64le linux-riscv64 linux-s390x; do \
		rm -f $(DESTDIR)$(PREFIX)/bin/$$i-cqfd6; \
	done
	completionsdir=$${COMPLETIONSDIR:-$$(pkg-config --define-variable=prefix=$(PREFIX) \
	                                                --define-variable=datadir=$(PREFIX)/share \
	                                                --variable=completionsdir \
	                                                bash-completion)}; \
	if [ -n "$$completionsdir" ]; then \
		rm -rf $(DESTDIR)$$completionsdir/cqfd6; \
	fi

user-install user-uninstall:
user-%:
	$(MAKE) $* PREFIX=$$HOME/.local BASHCOMPLETIONSDIR=$$HOME/.local/share/bash-completion/completions DOCKERLIBDIR=$$HOME/.docker

test tests:
	@$(MAKE) -C tests GIT_DIR=$(CURDIR)/.git CQFD_COMPAT=$(COMPAT)

check:
	shellcheck cqfd
	shellcheck --shell bash bash-completion
	@$(MAKE) -C tests check

clean:
	rm -f cqfd.1.gz cqfdrc.5.gz

maintainer-clean: clean
	rm -f *.tar.gz
	rm -f rpmbuild/SOURCES/*.tar.gz

%.1: %.1.adoc
	asciidoctor -b manpage -o $@ $<

%.5: %.5.adoc
	asciidoctor -b manpage -o $@ $<

%.gz: %
	gzip -c $^ >$@

sources: cqfd6-$(VERSION).tar.gz rpmbuild/SOURCES/v$(VERSION).tar.gz FORCE

rpmbuild/SOURCES/$(VERSION).tar.gz:
rpmbuild/SOURCES/v%.tar.gz: FORCE
	git archive --prefix cqfd6-$*/ --format tar.gz --output $@ HEAD

cqfd6-$(VERSION).tar.gz:
%.tar.gz: FORCE
	git archive --prefix $*/ --format tar.gz --output $@ HEAD

FORCE:
