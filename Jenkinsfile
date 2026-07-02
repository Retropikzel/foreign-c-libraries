pipeline {
    agent {
        dockerfile {
            label 'docker-x86_64'
            filename 'Dockerfile.jenkins'
            args '--user=root --privileged -v /var/run/docker.sock:/var/run/docker.sock'
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
        R7RS_SCHEMES='chibi chicken gauche guile kawa mosh racket sagittarius stklos ypsilon'
        R6RS_SCHEMES='chezscheme guile ikarus ironscheme mosh racket sagittarius ypsilon'
        LIBRARIES='system named-pipes shell download-file'
    }

    stages {
        stage('Test R6RS Debian') {
            steps {
                script {
                    env.LIBRARIES.split().each { LIBRARY ->
                        env.R6RS_SCHEMES.split().each { SCHEME ->
                            stage("${SCHEME} ${LIBRARY}") {
                                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                    sh "make SCHEME=${SCHEME} LIBRARY=${LIBRARY} RNRS=r6rs test-docker"
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
                        env.R7RS_SCHEMESsplit().each { SCHEME ->
                            stage("${SCHEME} ${LIBRARY}") {
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
    post {
        always {
            cleanWs()
        }
    }
}
