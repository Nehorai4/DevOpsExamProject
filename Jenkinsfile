pipeline {
    agent any
    
    environment {
        DOCKERHUB_USERNAME = 'nehoraiiii'
        IMAGE_NAME = "${DOCKERHUB_USERNAME}/flask-aws-monitor"
    }
    
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'feature/fix-bug', url: 'https://github.com/Nehorai4/DevOpsExamProject.git'
            }
        }
        
        stage('Parallel Checks') {
            parallel {
                stage('Linting') {
                    steps {
                        echo 'Running Flake8 linting (mock)'
                        echo 'Running ShellCheck (mock)'
                        echo 'Running Hadolint for Dockerfile (mock)'
                    }
                }
                stage('Security Scan') {
                    steps {
                        echo 'Running Trivy for Docker image (mock)'
                        echo 'Running Bandit for Python (mock)'
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                dir('app') {
                    sh 'docker build -t ${IMAGE_NAME}:latest .'
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-password', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh 'echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin'
                    sh 'docker push ${IMAGE_NAME}:latest'
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check logs for details.'
        }
    }
}