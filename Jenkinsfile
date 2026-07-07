pipeline {
    agent {
        dockerfile {
            label 'docker-x86_64'
            filename 'Dockerfile.jenkins'
            args '-t --user=root --privileged -v /var/run/docker.sock:/var/run/docker.sock'
            reuseNode true
        }
    }

    triggers {
      GenericTrigger(
        genericVariables: [[key: 'ref', value: '$.ref']],
        causeString: 'Triggered on $ref',
        printContributedVariables: true,
        printPostContent: true,
        silentResponse: false,
        shouldNotFlatten: false,
        regexpFilterText: '$ref',
        regexpFilterExpression: 'refs/heads/' + BRANCH_NAME
      )
    }

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
    }

    environment {
        R6RS_SCHEMES='capyscheme chezscheme ikarus ironscheme mosh racket sagittarius ypsilon'
        R7RS_SCHEMES='capyscheme chibi chicken gauche kawa mosh racket sagittarius stklos ypsilon'
        LIBRARIES='system named-pipes shell download-file'
        PWD="${WORKSPACE}"
    }

    stages {
        stage('Parallel') {
            parallel {
                stage('Test R6RS Debian') {
                    steps {
                        script {
                            env.LIBRARIES.split().each { LIBRARY ->
                                stage("${LIBRARY}") {
                                    env.R6RS_SCHEMES.split().each { SCHEME ->
                                        stage("${SCHEME}") {
                                            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                                sh "make SCHEME=${SCHEME} LIBRARY=${LIBRARY} RNRS=r6rs test-docker"
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                stage('Test R7RS Debian') {
                    steps {
                        script {
                            env.LIBRARIES.split().each { LIBRARY ->
                                stage("${LIBRARY}") {
                                    env.R7RS_SCHEMES.split().each { SCHEME ->
                                        stage("${SCHEME}") {
                                            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                                sh "make SCHEME=${SCHEME} LIBRARY=${LIBRARY} RNRS=r7rs test-docker"
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
    }
    post {
        always {
            sh "chmod -R . jenkins"
            cleanWs()
        }
    }
}
