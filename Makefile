.SILENT: build install test test-docker clean ${TMPDIR}
SCHEME=chibi
LIBRARY=system
AUTHOR=Retropikzel

LIBRARY_FILE=foreign/c/${LIBRARY}.sld
VERSION=$(shell cat foreign/c/${LIBRARY}/VERSION)
DESCRIPTION=$(shell head -n1 foreign/c/${LIBRARY}/README.md)
README=foreign/c/${LIBRARY}/README.html
TESTFILE=foreign/c/${LIBRARY}/test.scm

PKG=foreign-c-${LIBRARY}-${VERSION}.tgz
TMPDIR=tmp/${SCHEME}-${LIBRARY}

DOCKERIMG=${SCHEME}:head
ifeq "${SCHEME}" "chicken"
DOCKERIMG="chicken:5"
endif

all: build

build: foreign/c/${LIBRARY}/LICENSE foreign/c/${LIBRARY}/VERSION
	echo "<pre>$$(cat foreign/c/${LIBRARY}/README.md)</pre>" > ${README}
	snow-chibi package --version=${VERSION} --authors=${AUTHOR} --doc=${README} --description="${DESCRIPTION}" ${LIBRARY_FILE}

install:
	snow-chibi install --impls=${SCHEME} ${SNOW_CHIBI_ARGS} ${PKG}

uninstall:
	-snow-chibi remove --impls=${SCHEME} ${PKG}

${TMPDIR}:
	@mkdir -p ${TMPDIR}
	@cp ${TESTFILE} ${TMPDIR}/
	@mkdir -p ${TMPDIR}/foreign/c
	@cp -r foreign/c/${LIBRARY} ${TMPDIR}/foreign/c/
	@cp -r foreign/c/${LIBRARY}.s* ${TMPDIR}/foreign/c/

test: ${TMPDIR}
	echo "Hello"
	cd ${TMPDIR} && COMPILE_R7RS=${SCHEME} compile-r7rs -I . -o test test.scm
	cd ${TMPDIR} && printf "\n" | ./test

test-docker: ${TMPDIR}
	docker build --build-arg IMAGE=${DOCKERIMG} --build-arg SCHEME=${SCHEME} --tag=foreign-c-library-test-${SCHEME} -f Dockerfile.test . 2> ${TMPDIR}/docker.log || cat ${TMPDIR}/docker.log
	docker run -v "${PWD}:/workdir" -w /workdir -t foreign-c-library-test-${SCHEME} \
		sh -c "make SCHEME=${SCHEME} test; chmod -R 755 ${TMPDIR}"

clean:
	find . -name "README.html" -delete
	rm -rf ${TMPDIR}
	rm -rf *.tgz

clean-all:
	rm -rf tmp
