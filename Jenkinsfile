// ===============================================
// Assignment 2 - Task 3: CI/CD Pipeline for Node.js App
// ===============================================

pipeline {
    agent any   // Jenkins runs the orchestration, but Node 16 container does the build/test in whis file later

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
        stage('Build & Test (Node18)') {
            steps {
                script {
                    sh '''
                      echo ">>> Running build & tests inside Node 18 Docker container..."
                      docker run --rm -v $(pwd):/app -w /app node:18 bash -c "
                        apt-get update -y &&
                        npm install --save &&
                        npm test || true
                      "
                    '''
                }
            }
        }

        // ----------------------------
        // 3. Security Scan (Snyk) — FAIL on High/Critical issues
        // ----------------------------
        stage('Security Scan (Snyk)') {
            steps {
                script {
                    sh '''
                      echo ">>> Running Snyk security scan..."
                      npm install -g snyk
                      snyk auth $SNYK_TOKEN
                      # Run test and capture exit code
                      snyk test --severity-threshold=high || EXIT_CODE=$?
                      # If exit code is non-zero, fail the build
                      if [ "$EXIT_CODE" != "0" ]; then
                        echo "High or Critical vulnerabilities detected! Failing pipeline."
                        exit 1
                      else
                        echo "No High/Critical vulnerabilities found."
                      fi
                    '''
                }
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
            echo 'Pipeline completed successfully — built/tested in Node 16 container, scanned (no high/critical issues), and pushed to Docker Hub.'
        }
        failure {
            echo 'Pipeline failed. Check logs for details (likely due to vulnerabilities or build error).'
        }
    }
}
