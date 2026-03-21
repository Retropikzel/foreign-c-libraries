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

all: build

build: retropikzel/${LIBRARY}/LICENSE retropikzel/${LIBRARY}/VERSION
	echo "<pre>$$(cat retropikzel/${LIBRARY}/README.md)</pre>" > ${README}
	snow-chibi package --always-yes --version=${VERSION} --authors=${AUTHOR} --doc=${README} --description="${DESCRIPTION}" ${LIBRARY_FILE}

install:
	snow-chibi install --impls=${SCHEME} --always-yes ${PKG}

test: build
	rm -rf .tmp
	mkdir -p .tmp
	# R6RS testfiles
	printf "#!r6rs\n(import (except (rnrs) remove) (srfi :64) (retropikzel ${LIBRARY}))" > .tmp/test.sps
	cat ${TESTFILE} >> .tmp/test.sps
	# R7RS testfiles
	echo "(import (scheme base) (scheme write) (scheme read) (scheme char) (scheme file) (scheme process-context) (srfi 64) (retropikzel ${LIBRARY}))" > .tmp/test.scm
	cat ${TESTFILE} >> .tmp/test.scm
	# Tests
	cd .tmp && ${SNOW} srfi.64
	cd .tmp && ${SNOW} retropikzel.ctrf
	cd .tmp && ${SNOW} ../${PKG}
	cd .tmp && akku install akku-r7rs 2> /dev/null
	cd .tmp && CSC_OPTIONS="-L -lcurl -L -lSDL2 -L -lSDL2_image" COMPILE_R7RS=${SCHEME} compile-r7rs ${LIB_PATHS} -o test test.${SFX}
	cd .tmp && ./test

test-docker:
	docker build --build-arg SCHEME=${SCHEME} --build-arg IMAGE=${IMAGE} --tag=foreign-c-library-test-${SCHEME} -f Dockerfile.test .
	docker run -v "${PWD}/logs:/workdir/logs" -w /workdir -t foreign-c-library-test-${SCHEME} sh -c "make SCHEME=${SCHEME} LIBRARY=${LIBRARY} RNRS=${RNRS} test"

clean:
	git clean -X -f
