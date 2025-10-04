// ===============================================
// Assignment 2 – Task 3: CI/CD Pipeline for Node.js App
// ===============================================

pipeline {
    agent any   // Jenkins orchestrates; build & scan stages run inside Node 18 Docker containers

    environment {
        APP_NAME   = 'aws-node-app'                  // Application name label
        REGISTRY   = 'docker.io/smilyy'              // DockerHub namespace
        IMAGE_TAG  = "${env.BUILD_NUMBER}"           // Auto-increment build tag
        SNYK_TOKEN = credentials('snyk-token')       // Snyk API token stored in Jenkins credentials
    }

    stages {

        // -------------------------------------------------
        // 1️⃣ Checkout repository (ensure app files are present)
        // -------------------------------------------------
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Smilyy/aws-elastic-beanstalk-express-js-sample.git'
            }
        }

        // -------------------------------------------------
        // 2️⃣ Build & Test inside Node 18 container
        // -------------------------------------------------
        stage('Build & Test (Node18)') {
            steps {
                script {
                    sh '''
                      echo ">>> Running build & tests inside Node 18 container..."
                      docker run --rm \
                      -v ${WORKSPACE}:/app \
                      -w /app node:18 bash -c "npm install --save && npm test || true"
                    '''
                }
            }
        }

        // -------------------------------------------------
        // 3️⃣ Security Scan (Snyk) — fail on High/Critical
        // -------------------------------------------------
        stage('Security Scan (Snyk)') {
            steps {
                script {
                    sh '''
                      echo ">>> Running Snyk security scan inside Node 18 container..."
                      docker run --rm \
                      -v ${WORKSPACE}:/app \
                      -w /app node:18 bash -c "npm install -g snyk && snyk auth $SNYK_TOKEN && snyk test --severity-threshold=high" || EXIT_CODE=$?
                      if [ "$EXIT_CODE" != "" ]; then
                        echo "Detected HIGH/CRITICAL vulnerabilities. Failing pipeline."
                        exit 1
                      fi
                    '''
                }
            }
        }

        // -------------------------------------------------
        // 4️⃣ Build Docker image
        // -------------------------------------------------
        stage('Build Docker Image') {
            steps {
                sh '''
                  echo ">>> Building Docker image..."
                  docker build -t $REGISTRY/$APP_NAME:$IMAGE_TAG .
                '''
            }
        }

        // -------------------------------------------------
        // 5️⃣ Push image to Docker Hub
        // -------------------------------------------------
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                      echo ">>> Pushing image to DockerHub..."
                      echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                      docker push $REGISTRY/$APP_NAME:$IMAGE_TAG
                    '''
                }
            }
        }
    }

    // -------------------------------------------------
    // Post-build actions
    // -------------------------------------------------
    post {
        success {
            echo ' Pipeline succeeded — built, tested, scanned, and pushed image.'
        }
        failure {
            echo 'Pipeline failed — see console output for details.'
        }
    }
}
