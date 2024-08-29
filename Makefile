PACKAGE = issuegen
#TOPSRCDIR ?= $(shell git rev-parse --show-toplevel)
GITREV = $(shell git rev-parse HEAD)
#PACKAGE_DIR = $(TOPSRCDIR)/$(PACKAGE)
PACKAGE_DIR=$(CURDIR)/rpmbuild/

PREFIX ?= /usr
libexecdir ?= $(PREFIX)/libexec
tmpfilesdir ?= $(PREFIX)/lib/tmpfiles.d
unitdir ?= $(PREFIX)/lib/systemd/system
udevrulesdir ?= $(PREFIX)/lib/udev/rules.d

.PHONY: all clean install rpm clean_rpm
all:
	@echo "(Nothing to build)"

clean:
	@echo "(Nothing to clean)"

install: all
	mkdir -p ${DESTDIR}/run/issue.d/
	install -Dm 0755 -t ${DESTDIR}/${libexecdir}/${PACKAGE}/ \
		$(CURDIR)/bin/issuegen-netif \
		$(CURDIR)/bin/issuegen-ssh-host-keys
	install -Dm 0644 $(CURDIR)/systemd/issuegen-netif-online.service ${DESTDIR}/${unitdir}/${PACKAGE}-netif-online.service
	install -Dm 0644 $(CURDIR)/systemd/issuegen-netif@.service ${DESTDIR}/${unitdir}/${PACKAGE}-netif@.service
	install -Dm 0644 $(CURDIR)/systemd/issuegen-ssh-host-keys.service ${DESTDIR}/${unitdir}/${PACKAGE}-ssh-host-keys.service
	install -Dm 0644 $(CURDIR)/tmpfiles.d/issuegen.conf ${DESTDIR}/${tmpfilesdir}/${PACKAGE}.conf
	install -Dm 0644 $(CURDIR)/udev/rules.d/99-issuegen-netif.rules ${DESTDIR}/${udevrulesdir}/99-${PACKAGE}-netif.rules

rpm:
	mkdir -p $(PACKAGE_DIR)
	git archive --format=tar --prefix=$(PACKAGE)/ -o $(PACKAGE_DIR)/$(PACKAGE)-$(GITREV).tar $(GITREV)
	cp $(CURDIR)/$(PACKAGE).spec $(PACKAGE_DIR)/$(PACKAGE).spec
	sed -i \
		-e 's/Source0: .*$$/Source0: $(PACKAGE)-$(GITREV).tar/' \
		-e 's/%setup/%setup -n $(PACKAGE)/' \
		$(PACKAGE_DIR)/$(PACKAGE).spec
	env -C $(PACKAGE_DIR) rpmbuild \
		--define "_sourcedir $(PACKAGE_DIR)/" \
		--define "_specdir $(PACKAGE_DIR)/" \
		--define "_builddir $(PACKAGE_DIR)/.build" \
		--define "_srcrpmdir $(PACKAGE_DIR)/rpms" \
		--define "_rpmdir $(PACKAGE_DIR)/rpms" \
		--define "_buildrootdir $(PACKAGE_DIR)/.buildroot" \
		-ba $(PACKAGE).spec

# Remove archives and RPM artifacts from previous builds.
clean_rpm:
	$(RM) -r $(PACKAGE_DIR)/.build \
		$(PACKAGE_DIR)/.buildroot \
		$(PACKAGE_DIR)/rpms/*; \
	$(RM) $(PACKAGE_DIR)/*.tar
