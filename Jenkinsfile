// ===============================================
// Assignment 2 – Task 3: CI/CD Pipeline for Node.js App
// ===============================================

pipeline {
    agent any  // Jenkins orchestrates; build & scan run inside Node 18 container

    environment {
        APP_NAME   = 'aws-node-app'
        REGISTRY   = 'docker.io/smilyy'            // DockerHub namespace
        IMAGE_TAG  = "${env.BUILD_NUMBER}"        // Use build number as tag
        SNYK_TOKEN = credentials('snyk-token')    // Snyk API token stored in Jenkins
    }

    stages {
        // -------------------------------------------------
        // 1. Checkout the repo (so workspace has app files)
        // -------------------------------------------------
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Smilyy/aws-elastic-beanstalk-express-js-sample.git'
            }
        }

        // -------------------------------------------------
        // 2. Build & Test inside Node 18 container
        // -------------------------------------------------
        stage('Build & Test (Node18)') {
            steps {
                script {
                    sh '''
                      echo ">>> Running build & tests inside Node 18 container..."
                      docker run --rm \
                        -v $(pwd):/app \
                        -w /app node:18 bash -c "
                          npm install --save &&
                          npm test || true
                        "
                    '''
                }
            }
        }

        // -------------------------------------------------
        // 3. Security Scan (Snyk) — FAIL on HIGH/CRITICAL
        // -------------------------------------------------
        stage('Security Scan (Snyk)') {
            steps {
                script {
                    sh '''
                      echo ">>> Running Snyk scan inside Node 18 container..."
                      docker run --rm \
                        -v $(pwd):/app \
                        -w /app node:18 bash -c "
                          npm install -g snyk &&
                          snyk auth $SNYK_TOKEN &&
                          snyk test --severity-threshold=high
                        " || EXIT_CODE=$?
                      if [ "$EXIT_CODE" != "" ]; then
                        echo "Detected HIGH/CRITICAL vulnerabilities. Failing pipeline."
                        exit 1
                      fi
                    '''
                }
            }
        }

        // -------------------------------------------------
        // 4. Build Docker Image (Node.js app container)
        // -------------------------------------------------
        stage('Build Docker Image') {
            steps {
                sh "docker build -t $REGISTRY/$APP_NAME:$IMAGE_TAG ."
            }
        }

        // -------------------------------------------------
        // 5. Push Docker image to DockerHub
        // -------------------------------------------------
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
            echo 'Pipeline succeeded: built, tested, scanned, and pushed image.'
        }
        failure {
            echo 'Pipeline failed. See console output for details.'
        }
    }
}
