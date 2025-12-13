.SILENT: build install test-r6rs test-r6rs-docker test-r7rs test-r7rs-docker clean
.PHONY: test-r6rs test-r7rs example.scm example.sps
SCHEME=chibi
LIBRARY=system
EXAMPLE=editor
EXAMPLE_FILE=retropikzel/${LIBRARY}/examples/${EXAMPLE}
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
	echo "(import (scheme base) (scheme write) (scheme file) (scheme process-context) (foreign c) (retropikzel ${LIBRARY}) (srfi 64))" > test-r7rs.scm
	cat retropikzel/${LIBRARY}/test.scm >> test-r7rs.scm
	COMPILE_R7RS=${SCHEME} timeout 60 compile-scheme -I . -o test-r7rs test-r7rs.scm
	printf "\n" | timeout 60 ./test-r7rs

test-r7rs-docker:
	echo "Building docker image..."
	docker build --build-arg IMAGE=${DOCKERIMG} --build-arg SCHEME=${SCHEME} --tag=foreign-c-library-test-${SCHEME} --quiet .
	docker run -t foreign-c-library-test-${SCHEME} sh -c "make SCHEME=${SCHEME} LIBRARY=${LIBRARY} SNOW_CHIBI_ARGS=--always-yes build install test-r7rs"

example.scm: ${EXAMPLE_FILE}.scm
	cp ${EXAMPLE_FILE}.scm example.scm

example-r7rs: example.scm
	COMPILE_R7RS=${SCHEME} compile-scheme -I . -o example example.scm
	./example

test-r6rs:
	echo "(import (rnrs) (foreign c) (retropikzel ${LIBRARY}) (srfi :64))" > test-r6rs.sps
	cat retropikzel/${LIBRARY}/test.scm >> test-r6rs.sps
	akku install chez-srfi akku-r7rs
	COMPILE_R7RS=${SCHEME} timeout 60 compile-scheme -I .akku/lib -o test-r6rs test-r6rs.sps
	timeout 60 ./test-r6rs

test-r6rs-docker:
	echo "Building docker image..."
	docker build --build-arg IMAGE=${DOCKERIMG} --build-arg SCHEME=${SCHEME} --tag=foreign-c-library-test-${SCHEME} --quiet .
	docker run -t foreign-c-library-test-${SCHEME} sh -c "make SCHEME=${SCHEME} LIBRARY=${LIBRARY} test-r6rs"

example.sps: ${EXAMPLE_FILE}.sps
	cp ${EXAMPLE_FILE}.scm example.sps

example-r6rs: example.sps
	akku install akku-r7rs "(foreign c)"
	COMPILE_R7RS=${SCHEME} compile-scheme -I .akku/lib -o example example.sps
	./example

clean:
	git clean -X -f
