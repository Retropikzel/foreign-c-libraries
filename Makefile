SCHEME=chibi
RNRS=r7rs
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

run-test-venv: build
	rm -rf venv
	scheme-venv ${SCHEME} venv
	echo "(import (scheme base) (scheme write) (scheme read) (scheme char) (scheme file) (scheme process-context) (srfi 64) (retropikzel ${LIBRARY}))" > venv/test.scm
	printf "#!r6rs\n(import (except (rnrs) remove) (srfi :64) (retropikzel ${LIBRARY}))" > venv/test.sps
	cat ${TESTFILE} >> venv/test.scm
	cat ${TESTFILE} >> venv/test.sps
	if [ "${RNRS}" = "r6rs" ]; then if [ -d ../foreign-c ]; then cp -r ../foreign-c/foreign venv/lib/; fi; fi
	if [ "${RNRS}" = "r6rs" ]; then cp -r retropikzel venv/lib/; fi
	#if [ "${SCHEME}" = "chezscheme" ]; then ./venv/bin/akku install akku-r7rs chez-srfi; fi
	#if [ "${SCHEME}" = "ikarus" ]; then ./venv/bin/akku install akku-r7rs chez-srfi; fi
	#if [ "${SCHEME}" = "ironscheme" ]; then ./venv/bin/akku install akku-r7rs chez-srfi; fi
	#if [ "${SCHEME}" = "racket" ]; then ./venv/bin/akku install akku-r7rs chez-srfi; fi
	if [ "${RNRS}" = "r6rs" ]; then ./venv/bin/akku install akku-r7rs chez-srfi; fi
	if [ "${SCHEME}" = "chicken" ]; then ./venv/bin/snow-chibi install --always-yes srfi.64; fi
	if [ "${SCHEME}-${RNRS}" = "mosh-r7rs" ]; then ./venv/bin/snow-chibi install --always-yes srfi.64; fi
	if [ "${RNRS}" = "r7rs" ]; then ./venv/bin/snow-chibi install ${PKG}; fi
	if [ "${RNRS}" = "r6rs" ]; then ./venv/bin/scheme-compile venv/test.sps; fi
	if [ "${RNRS}" = "r7rs" ]; then CSC_OPTIONS="-L -lcurl -L -lSDL2 -L -lSDL2_image" ./venv/bin/scheme-compile venv/test.scm; fi
	./venv/test

run-test-system: build
	rm -rf tmp
	mkdir -p tmp
	printf "#!r6rs\n(import (except (rnrs) remove) (srfi :64) (retropikzel ${LIBRARY}))" > tmp/test.sps
	cat ${TESTFILE} >> tmp/test.sps
	echo "(import (scheme base) (scheme write) (scheme read) (scheme char) (scheme file) (scheme process-context) (srfi 64) (retropikzel ${LIBRARY}))" > tmp/test.scm
	cat ${TESTFILE} >> tmp/test.scm
	if [ "${RNRS}" = "r6rs" ]; then cp -r retropikzel tmp/lib/; fi
	if [ "${RNRS}" = "r6rs" ]; then snow-chibi install --impls=generic --install-source-dir=tmp/lib --install-library-dir=tmp/lib --always-yes foreign.c; fi
	if [ "${RNRS}" = "r6rs" ]; then cd tmp && akku install akku-r7rs chez-srfi; fi
	if [ "${RNRS}" = "r7rs" ]; then snow-chibi install --impls=${SCHEME} --always-yes --skip-tests?=1 srfi.64; fi
	if [ "${RNRS}" = "r7rs" ]; then snow-chibi install --impls=${SCHEME} --always-yes --skip-tests?=1 foreign.c; fi
	if [ "${RNRS}" = "r7rs" ]; then snow-chibi install --impls=${SCHEME} --always-yes ${PKG}; fi
	if [ "${RNRS}" = "r6rs" ]; then cd tmp && COMPILE_R7RS=${SCHEME} compile-scheme -o test test.sps; fi
	if [ "${RNRS}" = "r7rs" ]; then cd tmp && CSC_OPTIONS="-L -lcurl -L -lSDL2 -L -lSDL2_image" COMPILE_R7RS=${SCHEME} compile-scheme -o test test.scm; fi
	cd tmp && ./test

run-test-docker:
	docker build --build-arg IMAGE=${DOCKERIMG} --build-arg SCHEME=${SCHEME} --tag=foreign-c-library-test-${SCHEME} -f Dockerfile.test .
	docker run -v "${PWD}/logs:/workdir/logs" -w /workdir -t foreign-c-library-test-${SCHEME} sh -c "make SCHEME=${SCHEME} LIBRARY=${LIBRARY} RNRS=${RNRS} run-test-system"

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
	echo "(import (except (rnrs) remove) (foreign c) (retropikzel ${LIBRARY}) (srfi :64))" > test-r6rs.sps
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
