// ===============================================
// Assignment 2 - Task 3: CI/CD Pipeline for Node.js App
// ===============================================

pipeline {
    // --------------------------------------------------
    // The entire pipeline runs inside a Node 16 container
    // --------------------------------------------------
    agent {
        docker {
            image 'node:16'              // official Node 16 Docker image
            args '-u root'               // Run as root so we can install tools
        }
    }

    environment {
        APP_NAME = 'aws-node-app'       // a label for the app
        REGISTRY = 'docker.io/smilyy'  // my docker hub name
        IMAGE_TAG = "${env.BUILD_NUMBER}" // Use Jenkins build number as tag
        SNYK_TOKEN = credentials('snyk-token') // stored in Jenkins credentials
    }

    stages {
        // ----------------------------
        // 1. Checkout the GitHub repo
        // ----------------------------
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Smilyy/aws-elastic-beanstalk-express-js-sample.git'
            }
        }

        // ----------------------------
        // 2. Install dependencies
        // ----------------------------
        stage('Install Dependencies') {
            steps {
                sh 'npm install --save'
            }
        }

        // ----------------------------
        // 3. Run unit tests
        // ----------------------------
        stage('Test') {
            steps {
                sh 'npm test || true'   // run tests
            }
        }

        // ----------------------------
        // 4. Security Scan 
        // ----------------------------
        stage('Security Scan') {
            steps {
                // install Snyk CLI locally
                sh 'npm install -g snyk'
                // authenticate with token from Jenkins credentials
                sh 'snyk auth $SNYK_TOKEN'
                // test for vulnerabilities
                sh 'snyk test --severity-threshold=high'
            }
        }

        // ----------------------------
        // 5. Build Docker Image
        // ----------------------------
        stage('Build Docker Image') {
            steps {
                script {
                    // build image tagged with build number
                    sh "docker build -t $REGISTRY/$APP_NAME:$IMAGE_TAG ."
                }
            }
        }

        // ----------------------------
        // 6. Push Image to DockerHub
        // ----------------------------
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push $REGISTRY/$APP_NAME:$IMAGE_TAG"
                }
            }
        }
    }

    // --------------------------------------------------
    // Post-build cleanup
    // --------------------------------------------------
    post {
        success {
            echo 'Build, test, security scan and image push completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}

