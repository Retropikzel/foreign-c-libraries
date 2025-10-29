pipeline {
    agent {
        dockerfile {
            label 'docker-x86_64'
            filename 'Dockerfile.jenkins'
            args '--user=root --privileged -v /var/run/docker.sock:/var/run/docker.sock'
            reuseNode true
        }
    }

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
    }

    parameters {
        string(name: 'LIBRARIES', defaultValue: 'system shell', description: '')
    }

    stages {
        stage('Tests') {
            steps {
                script {
                    def implementations = 'chibi chicken foment gauche guile kawa mosh racket sagittarius stklos ypsilon'.split()

                    params.LIBRARIES.split().each { LIBRARY ->
                        stage("${LIBRARY}") {
                            parallel implementations.collectEntries { SCHEME ->
                                [(SCHEME): {
                                    stage("${SCHEME}") {
                                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                            sh "timeout 6000 make SCHEME=${SCHEME} clean test-docker"
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
    post {
        always {
            archiveArtifacts artifacts: "tmp/*/*/*.log", excludes: "tmp/*/*/docker.log", allowEmptyArchive: true
        }
    }
}
