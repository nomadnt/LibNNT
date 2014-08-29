NAME=libnnt
VERSION=0.2.0

DESTDIR?=/usr/local

all:

install:
	install -d -m 0755 $(DESTDIR)/sbin/
	install -m 0755 valid $(DESTDIR)/sbin/

	install -d -m 0755 $(DESTDIR)/lib/nnt
	install -m 0644 iputils.sh $(DESTDIR)/lib/nnt/
	install -m 0644 iw.sh $(DESTDIR)/lib/nnt/
	install -m 0644 net.sh $(DESTDIR)/lib/nnt/
	install -m 0644 sys.sh $(DESTDIR)/lib/nnt/
	install -m 0644 uci.sh $(DESTDIR)/lib/nnt/

uninstall:
	rm -f  $(DESTDIR)/sbin/valid
	rm -rf $(DESTDIR)/lib/nnt

.PHONY: all install uninstall
