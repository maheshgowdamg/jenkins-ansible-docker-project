pipeline {
    agent any
    tools {
        maven 'maven'
    }
    environment {
        DOCKER_IMAGE = 'app'
        CONTAINER_NAME = 'webapp'
        REMOTE_HOST = '172.31.4.174'
        REMOTE_USER = 'ansible'
    }

    stages {
        stage('Pull Source Code') {
            steps {
                git branch: 'main', url: 'https://github.com/maheshgowdamg/jenkins-ansible-docker-project.git'
            }
        }

        stage('Build Application') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Debug Files') {
            steps {
                sh 'ls -l target/'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t $DOCKER_IMAGE ."
                }
            }
        }

        stage('Transfer Files to Remote Server') {
            steps {
                sshPublisher(
                    publishers: [
                        sshPublisherDesc(
                            configName: 'sshserver',
                            transfers: [
                                sshTransfer(
                                    sourceFiles: 'Dockerfile, target/webapp.war', // Fix file path
                                    remoteDirectory: '/home/ansible',
                                    removePrefix: '',
                                    execCommand: ''
                                )
                            ],
                            usePromotionTimestamp: false,
                            verbose: true
                        )
                    ]
                )
            }
        }

        stage('Deploy on Remote Server') {
            steps {
                sshPublisher(
                    publishers: [
                        sshPublisherDesc(
                            configName: 'sshserver',
                            transfers: [
                                sshTransfer(
                                    execCommand: """
                                    cd /home/ansible
                                    docker stop $CONTAINER_NAME || true
                                    docker rm $CONTAINER_NAME || true
                                    docker build -t $DOCKER_IMAGE .
                                    docker run -d --name $CONTAINER_NAME -p 8081:8080 $DOCKER_IMAGE
                                    """
                                )
                            ]
                        )
                    ]
                )
            }
        }
    }

    post {
        success {
            echo "Deployment Successful!"
        }
        failure {
            echo "Deployment Failed!"
        }
    }
}
