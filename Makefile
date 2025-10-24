.SILENT: build install test test-docker clean ${TMPDIR}
LIBRARY=system
README=${LIBRARY}/README.html
DESCRIPTION=$(shell head -n1 ${LIBRARY}/README.md)
VERSION=$(shell cat ${LIBRARY}/VERSION)
AUTHOR=$(shell cat ${LIBRARY}/AUTHOR | tr '[:upper:]' '[:lower:]')
LIBRARY_FILE=${LIBRARY}/${AUTHOR}/${LIBRARY}.sld
PKG=${AUTHOR}-${LIBRARY}-${VERSION}.tgz
SCHEME=chibi
TMPDIR=tmp/${SCHEME}
TESTFILE=${LIBRARY}/test.scm

DOCKERIMG=${SCHEME}:head
ifeq "${SCHEME}" "chicken"
DOCKERIMG="chicken:5"
endif

all: build

build: ${LIBRARY}/LICENSE ${LIBRARY}/VERSION ${LIBRARY}/AUTHOR
	echo "<pre>$$(cat ${LIBRARY}/README.md)</pre>" > ${README}
	snow-chibi package --version=${VERSION} --authors=${AUTHOR} --doc=${README} --description="${DESCRIPTION}" ${LIBRARY_FILE}

install:
	snow-chibi install --impls=${SCHEME} ${SNOW_CHIBI_ARGS} ${PKG}

uninstall:
	-snow-chibi remove --impls=${SCHEME} ${PKG}

${TMPDIR}:
	@mkdir -p ${TMPDIR}
	@cp ${TESTFILE} ${TMPDIR}/
	@cp -r ${LIBRARY} ${TMPDIR}/

test: ${TMPDIR}
	echo "Hello"
	cd ${TMPDIR} && COMPILE_R7RS=${SCHEME} compile-r7rs -I . -o test test.scm
	cd ${TMPDIR} && ./test

test-docker: ${TMPDIR}
	docker build --build-arg IMAGE=${DOCKERIMG} --build-arg SCHEME=${SCHEME} --tag=foreign-c-test-${SCHEME} -f Dockerfile.test . 2> ${TMPDIR}/docker.log || cat ${TMPDIR}/docker.log
	docker run -it -v "${PWD}:/workdir" -w /workdir -t foreign-c-test-${SCHEME} \
		sh -c "make SCHEME=${SCHEME} SNOW_CHIBI_ARGS=--always-yes build install test; chmod -R 755 ${TMPDIR}"

clean:
	find . -name "README.html" -delete
	rm -rf ${TMPDIR}
	rm -rf *.tgz

clean-all:
	rm -rf tmp
