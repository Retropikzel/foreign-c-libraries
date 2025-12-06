pipeline {
    agent {
        dockerfile {
            label 'docker-x86_64'
            filename 'Dockerfile.jenkins'
            args '--user=root --privileged -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
    }

    parameters {
        //string(name: 'R7RS_SCHEMES', defaultValue: 'chibi chicken gauche guile kawa mosh racket sagittarius stklos ypsilon', description: '')
        string(name: 'R7RS_SCHEMES', defaultValue: 'chibi', description: '')
        //string(name: 'R6RS_SCHEMES', defaultValue: 'chezscheme guile ikarus ironscheme mosh racket sagittarius ypsilon', description: '')
        string(name: 'R6RS_SCHEMES', defaultValue: 'chezscheme', description: '')
        //string(name: 'R6RS_SCHEMES', defaultValue: 'chezscheme', description: '')
        string(name: 'LIBRARIES', defaultValue: 'system', description: '')
    }

    stages {
        stage('Tests') {
            parallel {
                /*
                stage('R6RS') {
                    steps {
                        script {
                            params.LIBRARIES.split().each { LIBRARY ->
                            stage("${LIBRARY}") {
                                    params.R6RS_SCHEMES.split().each { SCHEME ->
                                        def IMG="${SCHEME}:head"
                                        stage("${SCHEME} - ${LIBRARY}") {
                                            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                                sh "timeout 600 make SCHEME=${SCHEME} LIBRARY=${LIBRARY} test-r6rs-docker"
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                */
                stage('R7RS') {
                    steps {
                        script {
                            params.LIBRARIES.split().each { LIBRARY ->
                                stage("${LIBRARY}") {
                                    parallel params.R7RS_SCHEMES.collectEntries().each { SCHEME ->
                                        [(SCHEME): {
                                            def IMG="${SCHEME}:head"
                                            if("${SCHEME}" == "chicken") {
                                                IMG="${SCHEME}:5"
                                            }
                                            stage("${SCHEME} - ${LIBRARY}") {
                                                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                                    sh "timeout 600 make SCHEME=${SCHEME} LIBRARY=${LIBRARY} test-r7rs-docker"
                                                }
                                            }
                                        }]
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

    }
}
