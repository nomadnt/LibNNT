NAME=libnnt
VERSION=0.2.2

PREFIX = 

all:

install:
	install -m 0755 -d $(PREFIX)/sbin/
	install -m 0755 -d $(PREFIX)/lib/nnt

	install -m 0755 valid $(PREFIX)/sbin/
	install -m 0644 iputils.sh $(PREFIX)/lib/nnt/
	install -m 0644 iw.sh $(PREFIX)/lib/nnt/
	install -m 0644 net.sh $(PREFIX)/lib/nnt/
	install -m 0644 sys.sh $(PREFIX)/lib/nnt/
	install -m 0644 uci.sh $(PREFIX)/lib/nnt/

uninstall:
	rm -f  $(PREFIX)/sbin/valid
	rm -rf $(PREFIX)/lib/nnt

.PHONY: install uninstall all