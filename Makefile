SCHEME=chibi
DOCKER_TAG=head
RNRS=r7rs
LIBRARY=system
AUTHOR=Retropikzel

SFX=scm
LIB_PATHS=
ifeq "${RNRS}" "r6rs"
SFX=sps
LIB_PATHS=-I .akku/lib
endif
VERSION != cat retropikzel/${LIBRARY}/VERSION
PACKAGE_ARGS != cat retropikzel/${LIBRARY}/PACKAGE_ARGS || echo ""
CSC_OPTIONS != cat retropikzel/${LIBRARY}/CSC_OPTIONS || echo ""
APT_PACKAGES != cat retropikzel/${LIBRARY}/APT_PACKAGES || echo ""

LIBRARY_FILE=retropikzel/${LIBRARY}.sld
DESCRIPTION != head -n1 retropikzel/${LIBRARY}/README.md
README=retropikzel/${LIBRARY}/README.html
TESTFILE=retropikzel/${LIBRARY}/test.scm

PKG=retropikzel-${LIBRARY}-${VERSION}.tgz

all: package

package: retropikzel/${LIBRARY}/VERSION retropikzel/${LIBRARY}/README.md retropikzel/${LIBRARY}/LICENSE
	echo "<pre>$$(cat retropikzel/${LIBRARY}/README.md)</pre>" > ${README}
	snow-chibi package \
		--always-yes \
		${PACKAGE_ARGS} \
		--version=${VERSION} \
		--authors=${AUTHOR} \
		--doc=${README} \
		--description="${DESCRIPTION}" \
		${LIBRARY_FILE}

${PKG}: package

install:
	snow-chibi install --impls=${SCHEME} --always-yes ${PKG}

testfiles: ${PKG}
	rm -rf .tmp
	mkdir -p .tmp
	cp -r test-resources .tmp/
	if [ "${RNRS}" = "${R6RS}" ]; then cp -r retropikzel .tmp/; fi
	# R6RS testfiles
	printf "#!r6rs\n(import (except (rnrs) remove) (srfi :64) (foreign c) (retropikzel ${LIBRARY}))" > .tmp/test.sps
	cat ${TESTFILE} >> .tmp/test.sps
	# R7RS testfiles
	echo "(import (scheme base) (scheme write) (scheme read) (scheme char) (scheme file) (scheme process-context) (srfi 64) (foreign c) (retropikzel ${LIBRARY}))" > .tmp/test.scm
	cat ${TESTFILE} >> .tmp/test.scm
	cp ${PKG} .tmp/

test: testfiles
	cd .tmp && \
		COMPILE_R7RS=${SCHEME} \
		CSC_OPTIONS="${CSC_OPTIONS}" \
		compile-r7rs ${LIB_PATHS} -o test-program test.${SFX}
	cd .tmp && ./test-program

test-docker: testfiles
	cd .tmp && \
		TEST_R7RS_DEBUG=1 \
		DOCKER_TAG=${DOCKER_TAG} \
		COMPILE_R7RS=${SCHEME} \
		CSC_OPTIONS="${CSC_OPTIONS}" \
		SNOW_PACKAGES="srfi.64 ${PKG}" \
		AKKU_PACKAGES="akku-r7rs" \
		APT_PACKAGES="${APT_PACKAGES}" \
		PASS_ENV_VARS="CSC_OPTIONS" \
		test-r7rs -o test-program test.${SFX}

clean:
	git clean -X -f
