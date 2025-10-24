pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile.jenkins'
            args '--user=root --privileged -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
    }

    parameters {
        string(name: 'LIBRARIES', defaultValue: 'system', description: '')
    }

    stages {
        stage('Tests') {
            steps {
                script {
                    def implementations = sh(script: 'compile-r7rs --list-r7rs-schemes', returnStdout: true).split()

                    params.LIBRARIES.split().each { LIBRARY ->
                        stage("${LIBRARY}") {
                            parallel implementations.collectEntries { SCHEME ->
                                [(SCHEME): {
                                    stage("${SCHEME}") {
                                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                            sh "make SCHEME=${SCHEME} clean test-docker"
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
