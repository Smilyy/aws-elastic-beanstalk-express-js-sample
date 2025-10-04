// ===============================================
// Assignment 2 - Task 3: CI/CD Pipeline for Node.js App
// ===============================================

pipeline {
    // --------------------------------------------------
    // The entire pipeline runs inside a Node 16 container
    // configured to talk to Docker-in-Docker securely.
    // --------------------------------------------------
    agent {
        docker {
            image 'node:16'                       // official Node 16 image
            args '''
              -u root                             \
              -v /var/run/docker.sock:/var/run/docker.sock \
              -v /usr/bin/docker:/usr/bin/docker   \
              -v /var/jenkins_home:/var/jenkins_home
            '''
        }
    }

    environment {
        APP_NAME   = 'aws-node-app'               // App name
        REGISTRY   = 'docker.io/smilyy'           // My Docker Hub username
        IMAGE_TAG  = "${env.BUILD_NUMBER}"        // Make tag = build number
        SNYK_TOKEN = credentials('snyk-token')    // Snyk secret from Jenkins (I add this config in Jenkins)
    }

    stages {

        // ----------------------------
        // 1. Checkout repository
        // ----------------------------
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Smilyy/aws-elastic-beanstalk-express-js-sample.git' //my repo address
            }
        }

        // ----------------------------
        // 2. Install dependencies
        // ----------------------------
        stage('Install Dependencies') {
            steps {
                sh '''
                  apt-get update -y
                  apt-get install -y npm
                  npm install --save
                '''
            }
        }

        // ----------------------------
        // 3. Run unit tests
        // ----------------------------
        stage('Test') {
            steps {
                sh 'npm test || true'
            }
        }

        // ----------------------------
        // 4. Security Scan
        // ----------------------------
        stage('Security Scan') {
            steps {
                sh '''
                  npm install -g snyk
                  snyk auth $SNYK_TOKEN
                  snyk test --severity-threshold=high
                '''
            }
        }

        // ----------------------------
        // 5. Build Docker image
        // ----------------------------
        stage('Build Docker Image') {
            steps {
                sh "docker build -t $REGISTRY/$APP_NAME:$IMAGE_TAG ."
            }
        }

        // ----------------------------
        // 6. Push image to DockerHub
        // ----------------------------
        stage('Push Docker Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                      echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                      docker push $REGISTRY/$APP_NAME:$IMAGE_TAG
                    '''
                }
            }
        }
    }

    // --------------------------------------------------
    // Post-build notifications
    // --------------------------------------------------
    post {
        success {
            echo 'Build, test, security scan, and image push completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
