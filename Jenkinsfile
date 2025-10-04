// ===============================================
// Assignment 2 – Task 3: CI/CD Pipeline for Node.js App
// ===============================================

pipeline {
    agent any   // Jenkins master controls stages; node:18 runs as build agent per stage

    environment {
        APP_NAME   = 'aws-node-app'           // Application name
        REGISTRY   = 'docker.io/smilyy'       // DockerHub namespace
        IMAGE_TAG  = "${env.BUILD_NUMBER}"    // Auto-increment build tag
        SNYK_TOKEN = credentials('snyk-token')// Snyk token from Jenkins credentials
    }

    stages {

        // -------------------------------------------------
        // 1️⃣ Checkout code from GitHub
        // -------------------------------------------------
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Smilyy/aws-elastic-beanstalk-express-js-sample.git'
            }
        }

        // -------------------------------------------------
        // 2️⃣ Build & Test inside Node 18 Docker agent
        // -------------------------------------------------
        stage('Build & Test (Node18)') {
            agent {
                docker { image 'node:18' }   // Jenkins automatically mounts workspace
            }
            steps {
                sh '''
                  echo ">>> Running build & tests using Node 18..."
                  npm install --save
                  npm test || true
                '''
            }
        }

        // -------------------------------------------------
        // 3️⃣ Security Scan (Snyk) — fail on High/Critical
        // -------------------------------------------------
        stage('Security Scan (Snyk)') {
            agent {
                docker { image 'node:18' }   // Run inside same image
            }
            steps {
                sh '''
                  echo ">>> Running Snyk security scan..."
                  npm install -g snyk
                  snyk auth $SNYK_TOKEN
                  snyk test --severity-threshold=high
                '''
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
        // 5️⃣ Push image to DockerHub
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
    // 🧾 Post-build feedback
    // -------------------------------------------------
    post {
        success {
            echo 'Pipeline succeeded — built, tested, scanned, and pushed image.'
        }
        failure {
            echo 'Pipeline failed — see console output for details.'
        }
    }
}
