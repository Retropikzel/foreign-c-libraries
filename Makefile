SCHEME=chibi
DOCKER_TAG=latest
IMAGE=${SCHEME}:${DOCKER_TAG}
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

SFX=scm
SNOW=snow-chibi --impls=${SCHEME} install --always-yes
LIB_PATHS=
ifeq "${RNRS}" "r6rs"
SNOW=snow-chibi --impls=${SCHEME} install --always-yes --install-source-dir=. --install-library-dir=.
SFX=sps
LIB_PATHS=-I .akku/lib
endif

APT_PACKAGES=
CSC_OPTIONS=
ifeq "${LIBRARY}" "gi-repository"
APT_PACKAGES=libgirepository-2.0-dev
CSC_OPTIONS=-L -lgirepository-2.0 -L -lgobject-2.0 -L -lglib-2.0
endif

all: build

build: retropikzel/${LIBRARY}/LICENSE retropikzel/${LIBRARY}/VERSION
	echo "<pre>$$(cat retropikzel/${LIBRARY}/README.md)</pre>" > ${README}
	snow-chibi package \
		--always-yes \
		--version=${VERSION} \
		--authors=${AUTHOR} \
		--doc=${README} \
		--description="${DESCRIPTION}" \
		${LIBRARY_FILE}

install:
	snow-chibi install --impls=${SCHEME} --always-yes ${PKG}

testfiles: build
	rm -rf .tmp
	mkdir -p .tmp
	cp -r test-resources .tmp/
	cp -r retropikzel .tmp/
	cp ${PKG} .tmp/
	# R6RS testfiles
	printf "#!r6rs\n(import (except (rnrs) remove) (srfi :64) (foreign c) (retropikzel ${LIBRARY}))" > .tmp/test.sps
	cat ${TESTFILE} >> .tmp/test.sps
	# R7RS testfiles
	echo "(import (scheme base) (scheme write) (scheme read) (scheme char) (scheme file) (scheme process-context) (srfi 64) (foreign c) (retropikzel ${LIBRARY}))" > .tmp/test.scm
	cat ${TESTFILE} >> .tmp/test.scm

test: testfiles
	cd .tmp && \
		COMPILE_R7RS=${SCHEME} \
		CSC_OPTIONS="${CSC_OPTIONS}" \
		compile-r7rs \
		-o test-program \
		test.${SFX}
	cd .tmp && ./test-program

test-docker: testfiles
	cd .tmp && \
		COMPILE_R7RS=${SCHEME} \
		CSC_OPTIONS="${CSC_OPTIONS}" \
		SNOW_PACKAGES="srfi.64 foreign.c" \
		APT_PACKAGES="${APT_PACKAGES}" \
		test-r7rs \
		-o test-program \
		test.${SFX} \
		${PKG}

clean:
	git clean -X -f
