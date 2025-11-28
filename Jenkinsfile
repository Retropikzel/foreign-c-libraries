pipeline {
    agent {
        docker {
            label 'docker-x86_64'
            image 'debian'
            args '--user=root --privileged -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
    }

    parameters {
        string(name: 'R7RS_SCHEMES', defaultValue: 'chibi chicken gauche guile kawa mosh racket sagittarius stklos ypsilon', description: '')
        string(name: 'R6RS_SCHEMES', defaultValue: 'chezscheme guile ikarus ironscheme mosh racket sagittarius ypsilon', description: '')
    }

    stages {
        stage('Init') {
            steps {
                sh "apt-get update && apt-get install -y make docker.io git"
            }
        }

        stage('Tests') {
            parallel {
                stage('R6RS x86_64 Debian') {
                    steps {
                        script {
                            params.R6RS_SCHEMES.split().each { SCHEME ->
                                def IMG="${SCHEME}:head"
                                stage("${SCHEME}") {
                                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                        sh "make SCHEME=${SCHEME} test-r6rs-docker"
                                    }
                                }
                            }
                        }
                    }
                }
                stage('R7RS x86_64 Debian') {
                    steps {
                        script {
                            params.R7RS_SCHEMES.split().each { SCHEME ->
                                def IMG="${SCHEME}:head"
                                if("${SCHEME}" == "chicken") {
                                    IMG="${SCHEME}:5"
                                }
                                stage("${SCHEME}") {
                                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                        sh "make SCHEME=${SCHEME} test-r7rs-docker"
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
