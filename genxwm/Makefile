# genxwm - custom dynamic window manager (basado en DWM)
# Autor: Fabián Huamaní (aka g3nkzn)
# Licencia: Ver archivo LICENSE

include config.mk

SRC = drw.c dwm.c util.c \
	fibonacci.c gaplessgrid.c movestack.c shiftview.c transient.c vanitygaps.c
OBJ = ${SRC:.c=.o}

all: genxwm

.c.o:
	${CC} -c ${CFLAGS} $<

${OBJ}: config.h config.mk

config.h:
	cp config.def.h $@

genxwm: ${OBJ}
	${CC} -o $@ ${OBJ} ${LDFLAGS}

clean:
	rm -f genxwm ${OBJ} genxwm-${VERSION}.tar.gz config.h

dist: clean
	mkdir -p genxwm-${VERSION}
	cp -R LICENSE Makefile README config.def.h config.mk \
		dwm.1 drw.h util.h ${SRC} dwm.png genxwm-${VERSION}
	tar -cf genxwm-${VERSION}.tar genxwm-${VERSION}
	gzip genxwm-${VERSION}.tar
	rm -rf genxwm-${VERSION}

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f genxwm ${DESTDIR}${PREFIX}/bin/genxwm
	chmod 755 ${DESTDIR}${PREFIX}/bin/genxwm
	mkdir -p ${DESTDIR}${MANPREFIX}/man1
	sed "s/VERSION/${VERSION}/g" < dwm.1 > ${DESTDIR}${MANPREFIX}/man1/genxwm.1
	chmod 644 ${DESTDIR}${MANPREFIX}/man1/genxwm.1

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/genxwm \
		${DESTDIR}${MANPREFIX}/man1/genxwm.1

.PHONY: all clean dist install uninstall
