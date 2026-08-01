.SILENT:
SCHEME=chibi
DOCKER_TAG=latest
RNRS=r7rs
LIBRARY=system
AUTHOR=Retropikzel

VERSION != cat retropikzel/${LIBRARY}/VERSION
PACKAGE_ARGS != cat retropikzel/${LIBRARY}/PACKAGE_ARGS 2> /dev/null || echo ""
CSC_OPTIONS != cat retropikzel/${LIBRARY}/CSC_OPTIONS 2> /dev/null || echo ""
APT_PACKAGES != cat retropikzel/${LIBRARY}/APT_PACKAGES 2> /dev/null || echo ""

LIBRARY_FILE=retropikzel/${LIBRARY}.sld
DESCRIPTION != head -n1 retropikzel/${LIBRARY}/README.md
README=retropikzel/${LIBRARY}/README.html
TESTFILE=retropikzel/${LIBRARY}/test.scm

PKG=retropikzel-${LIBRARY}-${VERSION}.tgz

ifeq "${SCHEME}" "capyscheme"
DOCKER_TAG=head
endif
ifeq "${SCHEME}" "chibi"
DOCKER_TAG=head
endif
ifeq "${SCHEME}" "chicken"
DOCKER_TAG=head
endif
ifeq "${SCHEME}" "gauche"
DOCKER_TAG=head
endif

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

test:
	rm -rf test-program
	COMPILE_R7RS=${SCHEME} \
	CSC_OPTIONS="${CSC_OPTIONS}" \
	compile-r7rs -o test-program ${TESTFILE}
	./test-program

test-docker:
	DOCKER_TAG=${DOCKER_TAG} \
	COMPILE_R7RS=${SCHEME} \
	CSC_OPTIONS="${CSC_OPTIONS}" \
	SNOW_PACKAGES="srfi.14 srfi.19 srfi.64 srfi.170 retropikzel.tap retropikzel.dot-locking retropikzel.debug foreign.c ${PKG}" \
	AKKU_PACKAGES="akku-r7rs chez-srfi '(foreign c)' '(retropikzel ${LIBRARY})'" \
	APT_PACKAGES="${APT_PACKAGES}" \
	PASS_ENV_VARS="CSC_OPTIONS" \
		test-r7rs -o test-program ${TESTFILE}

clean:
	git clean -X -f
