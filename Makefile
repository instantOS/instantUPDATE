PREFIX = /usr/

all: install

install:
	install -Dm 755 instantupdate.sh ${DESTDIR}${PREFIX}bin/instantupdate
	install -Dm 755 instantarchrun.sh ${DESTDIR}${PREFIX}bin/instantarchrun

uninstall:
	rm ${DESTDIR}${PREFIX}bin/instantupdate
	rm ${DESTDIR}${PREFIX}bin/instantarchrun
