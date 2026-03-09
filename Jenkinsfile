pipeline {
    agent any

    environment {
        IMAGE_NAME = "webapp"
    }

    stages {

        stage('Checkout') {
            steps {
                git url: 'https://github.com/subbasri17/devops-build.git',
                    branch: "${BRANCH_NAME}"
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh 'chmod +x build.sh'
                        sh "./build.sh ${BRANCH_NAME}"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                sh 'chmod +x deploy.sh'
                sh "./deploy.sh ${BRANCH_NAME}"
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully for branch ${BRANCH_NAME}!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
}
