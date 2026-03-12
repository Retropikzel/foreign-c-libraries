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
        string(name: 'R7RS_SCHEMES', defaultValue: 'chibi chicken gauche guile kawa mosh racket sagittarius stklos ypsilon', description: '')
        string(name: 'R6RS_SCHEMES', defaultValue: 'chezscheme guile ikarus ironscheme mosh racket sagittarius ypsilon', description: '')
        string(name: 'LIBRARIES', defaultValue: 'system named-pipes shell requests', description: '')
    }

    stages {
        stage('Docker image warmup') {
            steps {
                sh "docker build -f Dockerfile.test ."
            }
        }

        stage('R6RS') {
            steps {
                script {
                    params.LIBRARIES.split().each { LIBRARY ->
                        params.R6RS_SCHEMES.split().each { SCHEME ->
                            stage("${SCHEME} ${LIBRARY}") {
                                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                    sh "timeout 600 make SCHEME=${SCHEME} LIBRARY=${LIBRARY} RNRS=r6rs run-test-docker"
                                }
                            }
                        }
                    }
                }
            }
        }
        stage('R7RS') {
            steps {
                script {
                    params.LIBRARIES.split().each { LIBRARY ->
                        params.R7RS_SCHEMESsplit().each { SCHEME ->
                            stage("${SCHEME} ${LIBRARY}") {
                                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                    sh "timeout 600 make SCHEME=${SCHEME} LIBRARY=${LIBRARY} RNRS=r7rs run-test-docker"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
