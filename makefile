.PHONY : install
install :
	chmod +x ilf.sh
	cp ilf.sh /usr/local/bin/ilf

.PHONY : uninstall
uninstall :
	rm /usr/local/bin/ilf
