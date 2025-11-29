.SILENT: build install test test-docker clean
.PHONY: test-r6rs test-r7rs
SCHEME=chibi
LIBRARY=system
AUTHOR=Retropikzel

LIBRARY_FILE=retropikzel/${LIBRARY}.sld
VERSION=$(shell cat retropikzel/${LIBRARY}/VERSION)
DESCRIPTION=$(shell head -n1 retropikzel/${LIBRARY}/README.md)
README=retropikzel/${LIBRARY}/README.html
TESTFILE=retropikzel/${LIBRARY}/test.scm

PKG=retropikzel-${LIBRARY}-${VERSION}.tgz

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

test-r7rs:
	echo "(import (scheme base) (scheme write) (scheme file) (scheme process-context) (retropikzel ${LIBRARY}) (srfi 64))" > test-r7rs.scm
	cat retropikzel/${LIBRARY}/test.scm >> test-r7rs.scm
	COMPILE_R7RS=${SCHEME} compile-scheme -I . -o test-r7rs test-r7rs.scm
	printf "\n" | ./test-r7rs

test-r7rs-docker:
	docker build --build-arg IMAGE=${DOCKERIMG} --build-arg SCHEME=${SCHEME} --tag=foreign-c-library-test-${SCHEME} .
	docker run -t foreign-c-library-test-${SCHEME} sh -c "make SCHEME=${SCHEME} LIBRARY=${LIBRARY} SNOW_CHIBI_ARGS=--always-yes build install test-r7rs"

test-r6rs:
	echo "(import (rnrs) (retropikzel ${LIBRARY}) (srfi :64))" > test-r6rs.sps
	cat retropikzel/${LIBRARY}/test.scm >> test-r6rs.sps
	akku install chez-srfi akku-r7rs
	COMPILE_R7RS=${SCHEME} compile-scheme -I .akku/lib -o test-r6rs test-r6rs.sps
	./test-r6rs

test-r6rs-docker:
	docker build --build-arg IMAGE=${DOCKERIMG} --build-arg SCHEME=${SCHEME} --tag=foreign-c-library-test-${SCHEME} .
	docker run -t foreign-c-library-test-${SCHEME} sh -c "make SCHEME=${SCHEME} LIBRARY=${LIBRARY} test-r6rs"

clean:
	git clean -X -f
