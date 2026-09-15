.PHONY: deb clean

PACKAGE_NAME=wifi-watchdog
PACKAGE_VERSION ?= $(or $(VERSION),0.0.0~dev)
PACKAGE_ARCH=all
STAGING=$(CURDIR)/.build/$(PACKAGE_NAME)

deb:
	rm -rf $(STAGING)
	mkdir -p $(STAGING)/DEBIAN
	mkdir -p $(STAGING)/usr/local/bin
	mkdir -p $(STAGING)/lib/systemd/system
	mkdir -p $(STAGING)/etc/default

	install -m755 wifi-watchdog.sh $(STAGING)/usr/local/bin/wifi-watchdog.sh
	install -m644 wifi-watchdog.service $(STAGING)/lib/systemd/system/wifi-watchdog.service
	install -m644 etc/default/wifi-watchdog $(STAGING)/etc/default/wifi-watchdog
	install -m644 debian/control $(STAGING)/DEBIAN/control
	sed -i 's/^Version: .*/Version: $(PACKAGE_VERSION)/' $(STAGING)/DEBIAN/control
	install -m755 debian/postinst $(STAGING)/DEBIAN/postinst
	install -m755 debian/prerm $(STAGING)/DEBIAN/prerm

	sed -i 's|%i|/etc/default/wifi-watchdog|g' $(STAGING)/lib/systemd/system/wifi-watchdog.service

	dpkg-deb --build $(STAGING) $(CURDIR)/$(PACKAGE_NAME)_$(PACKAGE_VERSION)_$(PACKAGE_ARCH).deb
	@echo "Built $(PACKAGE_NAME)_$(PACKAGE_VERSION)_$(PACKAGE_ARCH).deb"

clean:
	rm -rf $(STAGING) $(PACKAGE_NAME)_$(PACKAGE_VERSION)_$(PACKAGE_ARCH).deb
