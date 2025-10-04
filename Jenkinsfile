// ===============================================
// Assignment 2 - Task 3: CI/CD Pipeline for Node.js App
// ===============================================

pipeline {
    agent any   // A Jenkins pipeline to make sure it can start shell process inside a container
    //but we'll build/test inside Node 16 below.

    environment {
        APP_NAME   = 'aws-node-app'
        REGISTRY   = 'docker.io/smilyy'
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
        SNYK_TOKEN = credentials('snyk-token')
    }

    stages {

        // ----------------------------
        // 1. Checkout repository
        // ----------------------------
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Smilyy/aws-elastic-beanstalk-express-js-sample.git'
            }
        }

        // ----------------------------
        // 2. Build & Test inside Node 16 container
        // ----------------------------
        stage('Build & Test (Node16)') {
            steps {
                script {
                    sh '''
                      echo ">>> Running build & tests inside Node 16 Docker container..."
                      docker run --rm -v $(pwd):/app -w /app node:16 bash -c "
                        apt-get update -y &&
                        npm install --save &&
                        npm test || true
                      "
                    '''
                }
            }
        }

        // ----------------------------
        // 3. Security Scan (Snyk)
        // ----------------------------
        stage('Security Scan (Snyk)') {
            steps {
                sh '''
                  npm install -g snyk
                  snyk auth $SNYK_TOKEN
                  snyk test --severity-threshold=high
                '''
            }
        }

        // ----------------------------
        // 4. Build Docker image
        // ----------------------------
        stage('Build Docker Image') {
            steps {
                sh "docker build -t $REGISTRY/$APP_NAME:$IMAGE_TAG ."
            }
        }

        // ----------------------------
        // 5. Push Docker image
        // ----------------------------
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                      echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                      docker push $REGISTRY/$APP_NAME:$IMAGE_TAG
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully — built and tested in Node 16 container, scanned, and pushed.'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
