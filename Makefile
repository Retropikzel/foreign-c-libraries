.DEFAULT: all
.POSIX:
SCHEME=chibi
VERSION=$$(cat retropikzel/${LIBRARY}/VERSION)
PKG=retropikzel-${LIBRARY}-${VERSION}.tgz
LIBRARY=system
AUTHOR=Retropikzel
DOCKER_TAG=latest


PACKAGE_ARGS=$$(cat retropikzel/${LIBRARY}/PACKAGE_ARGS 2> /dev/null || echo "")
CSC_OPTIONS=$$(cat retropikzel/${LIBRARY}/CSC_OPTIONS 2> /dev/null || echo "")
APT_PACKAGES=$$(cat retropikzel/${LIBRARY}/APT_PACKAGES 2> /dev/null || echo "")

TESTFILE=retropikzel/${LIBRARY}/test.scm


all: package

package: retropikzel/${LIBRARY}/VERSION retropikzel/${LIBRARY}/README.md retropikzel/${LIBRARY}/LICENSE
	snow-chibi package \
		--always-yes \
		${PACKAGE_ARGS} \
		--version="${VERSION}" \
		--authors="${AUTHOR}" \
		--doc="retropikzel/${LIBRARY}/README.md" \
		--test="retropikzel/${LIBRARY}/test.scm" \
		--description="$$(head -n1 retropikzel/${LIBRARY}/README.md)" \
		retropikzel/${LIBRARY}.sld

git-index: package
	snow-chibi git-index ${PKG}

install:
	snow-chibi install --impls=${SCHEME} --skip-tests?=1 ${PKG}

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
