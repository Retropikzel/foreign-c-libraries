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
PACKAGE_ARGS=$(shell cat retropikzel/${LIBRARY}/PACKAGE_ARGS || echo "")
CSC_OPTIONS=$(shell cat retropikzel/${LIBRARY}/CSC_OPTIONS || echo "")
APTPACKAGES=$(shell cat retropikzel/${LIBRARY}/APT_PACKAGES || echo "")

PKG=retropikzel-${LIBRARY}-${VERSION}.tgz

SFX=sps
ifeq "${RNRS}" "r7rs"
SFX=scm
endif

all: package

package: retropikzel/${LIBRARY}/LICENSE retropikzel/${LIBRARY}/VERSION
	echo "<pre>$$(cat retropikzel/${LIBRARY}/README.md)</pre>" > ${README}
	snow-chibi package \
		--always-yes \
		${PACKAGE_ARGS} \
		--version=${VERSION} \
		--authors=${AUTHOR} \
		--doc=${README} \
		--description="${DESCRIPTION}" \
		${LIBRARY_FILE}

install:
	snow-chibi install --impls=${SCHEME} --always-yes ${PKG}

testfiles: package
	rm -rf .tmp
	mkdir -p .tmp
	cp -r test-resources .tmp/
	cp -r retropikzel .tmp/
	# R6RS testfiles
	printf "#!r6rs\n(import (except (rnrs) remove) (srfi :64) (foreign c) (retropikzel ${LIBRARY}))" > .tmp/test.sps
	cat ${TESTFILE} >> .tmp/test.sps
	# R7RS testfiles
	echo "(import (scheme base) (scheme write) (scheme read) (scheme char) (scheme file) (scheme process-context) (srfi 64) (foreign c) (retropikzel ${LIBRARY}))" > .tmp/test.scm
	cat ${TESTFILE} >> .tmp/test.scm
	cp -r ../foreign-c/foreign .tmp/
	cp -r ../generated-foreign-c-libraries/c2foreign-c .tmp/
	cp ${PKG} .tmp/
	cd .tmp && if [ "${RNRS}" = "r6rs" ]; then snow-chibi --impls=generic install --always-yes --install-source-dir=. --install-library-dir=. ${PKG}; fi
	cd .tmp && if [ "${RNRS}" = "r6rs" ]; then akku install akku-r7rs; fi

test: testfiles
	cd .tmp && \
		COMPILE_R7RS=${SCHEME} \
		CSC_OPTIONS="${CSC_OPTIONS}" \
		compile-r7rs ${LIB_PATHS} \
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
