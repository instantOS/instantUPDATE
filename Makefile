PREFIX = /usr/

all: install

install:
	install -Dm 755 instantupdate.sh ${DESTDIR}${PREFIX}bin/instantupdate
	install -Dm 755 instantarchrun.sh ${DESTDIR}${PREFIX}bin/instantarchrun
	install -Dm 755 iadm.sh ${DESTDIR}${PREFIX}bin/iadm
	install -Dm 755 utils/iadm_utils.sh ${DESTDIR}${PREFIX}/share/instantupdate/utils/iadm_utils.sh
	mkdir -p ${DESTDIR}${PREFIX}/share/instantupdate/updates/prepacman/
	mkdir -p ${DESTDIR}${PREFIX}/share/instantupdate/updates/postpacman/
	find -regex './updates/prepacman/.*' -exec install -Dm 755 "{}" ${DESTDIR}${PREFIX}/share/instantupdate/updates/prepacman/ \;
	find -regex './updates/postpacman/.*' -exec install -Dm 755 "{}" ${DESTDIR}${PREFIX}/share/instantupdate/updates/postpacman/ \;

uninstall:
	rm ${DESTDIR}${PREFIX}bin/instantupdate
	rm ${DESTDIR}${PREFIX}bin/instantarchrun
