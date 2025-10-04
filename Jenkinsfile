// ===============================================
// ISEC6000 Assignment 2 – Secure DevOps CI/CD Pipeline
// Author: Laura Jiang
// Description: Automates build, test, security scan, and Docker image push
// ===============================================

pipeline {
    agent any   // Use official Node 18 as agent laterin this file because node:16 has a release error and will fail my pipeline. 
                //please refer to the screen shot in my report. 

    environment {
        APP_NAME   = 'aws-node-app'             // Application name
        REGISTRY   = 'docker.io/smilyy'         // my DockerHub username
        IMAGE_TAG  = "${env.BUILD_NUMBER}"      // Auto-increment build tag for versioning
        SNYK_TOKEN = credentials('snyk-token')  // Snyk token stored in Jenkins credentials
    }

    stages {

        // -------------------------------------------------
        // 1. Checkout Code from GitHub
        // -------------------------------------------------
        stage('Checkout') {
            steps {
                // Clone the forked AWS sample app repository
                git branch: 'main',
                    url: 'https://github.com/Smilyy/aws-elastic-beanstalk-express-js-sample.git'
            }
        }

        // -------------------------------------------------
        // 2️. Build & Test inside Node.js Docker Agent
        // -------------------------------------------------
        stage('Build & Test (Node18)') {
            agent {
                // Use official Node 18 Docker image 
                docker { image 'node:18' }
            }
            steps {
                sh '''
                  echo ">>> Running build & tests using Node 18..."
                  
                  # Install project dependencies
                  npm install --save
                  
                  # Run tests (non-fatal, as this sample repo has no test script)
                  npm test || true
                '''
            }
        }

        // -------------------------------------------------
        // 3. Security Scan (Snyk) and make it fail on High/Critical Issues
        // -------------------------------------------------
        stage('Security Scan (Snyk)') {
            agent {
                docker { image 'node:18' }
            }
            steps {
                sh '''
                  echo ">>> Running Snyk security scan..."

                  # Install Snyk locally in the container
                  npm install snyk
                  
                  # Authenticate Snyk using the Jenkins credential token
                  npx snyk auth $SNYK_TOKEN
                  
                  # Run Snyk scan; if any High/Critical vulnerabilities are found, fail the build
                  npx snyk test --severity-threshold=high || {
                      echo "High or Critical vulnerabilities detected — failing build."
                      exit 1
                  }
                '''
            }
        }

        // -------------------------------------------------
        // 4️. Build Docker Image for the Application
        // -------------------------------------------------
        stage('Build Docker Image') {
            steps {
                sh '''
                  echo ">>> Building Docker image..."
                  
                  # Build image using Dockerfile in repository root
                  docker build -t $REGISTRY/$APP_NAME:$IMAGE_TAG .
                '''
            }
        }

        // -------------------------------------------------
        // 5️. Push Docker Image to DockerHub Registry
        // -------------------------------------------------
        stage('Push Docker Image') {
            steps {
                // Use stored DockerHub credentials for secure login
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                      echo ">>> Pushing image to DockerHub..."
                      
                      # Authenticate and push image to your DockerHub registry
                      echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                      docker push $REGISTRY/$APP_NAME:$IMAGE_TAG
                    '''
                }
            }
        }
    }

    // -------------------------------------------------
    // 6. Post-build Feedback (Final Status)
    // -------------------------------------------------
    post {
        success {
            echo 'Pipeline succeeded — built, tested, scanned, and pushed image.'
        }
        failure {
            echo 'Pipeline failed, check console logs for details.'
        }
    }
}
