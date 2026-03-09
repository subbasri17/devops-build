pipeline {
    agent any

    // Add a parameter for branch selection
    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'dev', description: 'Branch to build and deploy')
    }

    environment {
        DEV_REGISTRY = "aarushisuba/dev"
        PROD_REGISTRY = "aarushisuba/prod"
        IMAGE_NAME = "webapp"
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/subbasri17/devops-build.git',
                    branch: "${params.BRANCH_NAME}"
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'chmod +x build.sh'
                sh "./build.sh ${params.BRANCH_NAME}"
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"

                        if (params.BRANCH_NAME == 'dev') {
                            sh "docker tag webapp:latest $DEV_REGISTRY:$IMAGE_TAG"
                            sh "docker push $DEV_REGISTRY:$IMAGE_TAG"
                        } else if (params.BRANCH_NAME == 'main') {
                            sh "docker tag webapp:latest $PROD_REGISTRY:$IMAGE_TAG"
                            sh "docker push $PROD_REGISTRY:$IMAGE_TAG"
                        } else {
                            echo "Branch is neither dev nor master. Skipping Docker push."
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                sh 'chmod +x deploy.sh'
                sh "./deploy.sh ${params.BRANCH_NAME}"
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully for branch ${params.BRANCH_NAME}!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
}
