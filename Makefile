.SILENT: build install test test-docker clean ${TMPDIR}
SCHEME=chibi
LIBRARY=system
AUTHOR=Retropikzel

LIBRARY_FILE=retropikzel/${LIBRARY}.sld
VERSION=$(shell cat retropikzel/${LIBRARY}/VERSION)
DESCRIPTION=$(shell head -n1 retropikzel/${LIBRARY}/README.md)
README=retropikzel/${LIBRARY}/README.html
TESTFILE=retropikzel/${LIBRARY}/test.scm

PKG=foreign-c-${LIBRARY}-${VERSION}.tgz
TMPDIR=.tmp/${LIBRARY}/${SCHEME}

DOCKERIMG=${SCHEME}:head
ifeq "${SCHEME}" "chicken"
DOCKERIMG="chicken:5"
endif

all: build

build: retropikzel/${LIBRARY}/LICENSE retropikzel/${LIBRARY}/VERSION
	echo "<pre>$$(cat retropikzel/${LIBRARY}/README.md)</pre>" > ${README}
	snow-chibi package --version=${VERSION} --authors=${AUTHOR} --doc=${README} --description="${DESCRIPTION}" ${LIBRARY_FILE}

install:
	snow-chibi install --impls=${SCHEME} ${SNOW_CHIBI_ARGS} ${PKG}

uninstall:
	-snow-chibi remove --impls=${SCHEME} ${PKG}

.akku:
	akku install chez-srfi akku-r7rs

tmpdir: .akku
	mkdir -p ${TMPDIR}
	cp ${TESTFILE} ${TMPDIR}/
	mkdir -p ${TMPDIR}/retropikzel
	cp -r retropikzel/${LIBRARY} ${TMPDIR}/retropikzel/
	cp -r retropikzel/${LIBRARY}.s* ${TMPDIR}/retropikzel/

test-r7rs: tmpdir
	cd ${TMPDIR} && echo "(import (scheme base) (scheme write) (scheme file) (scheme process-context) (retropikzel ${LIBRARY}) (srfi 64))" > test-r7rs.scm
	cd ${TMPDIR} && cat retropikzel/${LIBRARY}/test.scm >> test-r7rs.scm
	cd ${TMPDIR} && COMPILE_R7RS=${SCHEME} compile-scheme -I . -o test-r7rs test-r7rs.scm
	cd ${TMPDIR} && printf "\n" | ./test-r7rs

test-r7rs-docker:
	docker build --build-arg IMAGE=${DOCKERIMG} --build-arg SCHEME=${SCHEME} --tag=foreign-c-library-test-${SCHEME} .
	docker run -t foreign-c-library-test-${SCHEME} sh -c "make SCHEME=${SCHEME} test-r7rs"

test-r6rs: tmpdir
	cd ${TMPDIR} && echo "(import (rnrs) (retropikzel ${LIBRARY}) (srfi :64))" > test-r6rs.sps
	cd ${TMPDIR} && cat retropikzel/${LIBRARY}/test.scm >> test-r6rs.sps
	cd ${TMPDIR} && akku install
	cp -r .akku/* ${TMPDIR}/.akku/
	cd ${TMPDIR} && COMPILE_R7RS=${SCHEME} compile-scheme -I .akku/lib -o test-r6rs test-r6rs.sps
	cd ${TMPDIR} && ./test-r6rs

test-r6rs-docker:
	docker build --build-arg IMAGE=${DOCKERIMG} --build-arg SCHEME=${SCHEME} --tag=foreign-c-library-test-${SCHEME} .
	docker run -t foreign-c-library-test-${SCHEME} sh -c "make SCHEME=${SCHEME} test-r6rs"

clean:
	git clean -X -f
